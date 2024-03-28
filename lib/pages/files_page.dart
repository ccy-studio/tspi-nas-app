import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/common/page_widget_enum.dart';
import 'package:tspi_nas_app/model/app/file_event_model.dart';
import 'package:tspi_nas_app/model/app/file_router_entity.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/file_downloader_util.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/object_util.dart';
import 'package:tspi_nas_app/utils/stream_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';
import 'package:tspi_nas_app/widget/file_move_widget.dart';
import 'package:tspi_nas_app/widget/icon_button_widget.dart';

final EventBus _filePageEvent = EventBus();

// enum _DataLine { select }

class FileObjectPage extends StatefulWidget {
  final FileRoutrerDataEntity routrerData;

  FileObjectPage({super.key, required this.routrerData}) {
    _filePageEvent.fire("refresh");
  }

  @override
  State<FileObjectPage> createState() => _FileObjectPageState();
}

class _FileObjectPageState extends State<FileObjectPage> with MultDataLine {
  final _scrollController = ScrollController();
  final _gridViewScrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  StreamSubscription? _fileObjectSubscription;

  final int _pageSize = 30;
  int _pageNum = 1;
  int _total = 0;
  final List<FileObjectModel> _rows = List.empty(growable: true);
  StreamSubscription<String>? _streamSubscription;

  final Set<int> _selectFileIds = LinkedHashSet.identity();

  ///是否显示多选文件后的菜单组件
  bool _isShowSelectMenu = false;

  @override
  void initState() {
    _fileObjectSubscription =
        FileObjectDownloaderUtil.eventBus.on().listen(_fileObjectEventListener);
    Future.delayed(Duration.zero).then((value) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.ease,
      );
    });
    _streamSubscription = _filePageEvent.on<String>().listen((event) {
      setState(() {
        _pageNum = 1;
        _total = 0;
        _rows.clear();
        _loadFiles();
      });
      Future.delayed(Duration.zero).then((value) => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          ));
    });
    super.initState();
    BackButtonInterceptor.add(_onSysBackInterceptor);
  }

  @override
  void dispose() {
    _fileObjectSubscription?.cancel();
    disposeDataLine();
    _scrollController.dispose();
    _gridViewScrollController.dispose();
    _streamSubscription?.cancel();
    _refreshController.dispose();
    BackButtonInterceptor.remove(_onSysBackInterceptor);
    super.dispose();
  }

  bool _onSysBackInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    // 在这里执行你想要的操作
    // 如果你想要阻止返回操作，返回true；如果允许返回操作，返回false
    LogUtil.logInfo("router: ${info.currentRoute(context)?.settings}");
    if (widget.routrerData.trees.length != 1) {
      _onBackClick();
      return true;
    }
    return false;
  }

  ///加载文件列表数据
  Future<void> _loadFiles() async {
    var data = widget.routrerData;
    ApiMap.getFileObjectList(
            parentId: data.rootObject.id,
            pageSize: _pageSize,
            pageNum: _pageNum)
        .then((value) {
      _total = value.total;
      _rows.addAll(value.rows);
      if (_pageNum == 1) {
        _selectFileIds.clear();
      }
      if (mounted) {
        setState(() {});
      }
      return;
    });
  }

  ///返回文件列表的组件
  Widget? _getPlanWidget(BuildContext context) {
    if (_rows.isEmpty) {
      return null;
    }
    PlanType planType = context
        .select<GlobalStateProvider, PlanType>((value) => value.planType);
    if (planType == PlanType.grid) {
      return GridView.builder(
          controller: _gridViewScrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: _rows.length,
          itemBuilder: (context, index) {
            var f = _rows[index];
            return GestureDetector(
              onTap: () {
                _onFileClick(f);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    svg(
                        name: getFileIcon(f.fileContentType, f.fileName),
                        height: 50),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      f.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      f.createTime ?? "",
                      style:
                          const TextStyle(color: Colors.black38, fontSize: 8),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Transform.scale(
                        scale: 0.7,
                        child: SizedBox(
                          width: double.infinity,
                          height: 12,
                          child: Checkbox(
                            activeColor: Colors.blueAccent,
                            value: f.check,
                            onChanged: (value) {
                              f.check = !f.check;
                              if (f.check) {
                                _selectFileIds.add(f.id);
                              } else {
                                _selectFileIds.remove(f.id);
                              }
                              //检查是否具有选择
                              _onShowSelectMenuModal();
                              setState(() {});
                            },
                            shape: const CircleBorder(), //这里就是实现圆形的设置
                          ),
                        ))
                  ],
                ),
              ),
            );
          });
    } else if (planType == PlanType.list) {}
    return null;
  }

  ///复选框选择文件后底部展示的可操作按钮组
  List<Widget> _getFileActionAuthButton() {
    var bk = widget.routrerData.bucketsModel;
    List<Widget> list = [];
    var textStyle = const TextStyle(fontSize: 12, color: Colors.black54);
    const double height = 23;
    list.add(IconTextButton(
      onTap: _selectedBtnGroupDownload,
      icon: svg(name: "file_download", height: height),
      label: "下载",
      textStyle: textStyle,
    ));
    if (bk.acl.share) {
      list.add(IconTextButton(
          onTap: _selectedBtnGroupShare,
          icon: svg(name: "file_share", height: height),
          label: "分享",
          textStyle: textStyle));
    }
    if (bk.acl.delete) {
      list.add(IconTextButton(
          onTap: _selectedBtnGroupDel,
          icon: svg(name: "file_del", height: height),
          label: "删除",
          textStyle: textStyle));
    }
    if (bk.acl.write) {
      list.add(IconTextButton(
          onTap: _selectedBtnGroupCopy,
          icon: svg(name: "file_copy", height: height),
          label: "复制",
          textStyle: textStyle));
      list.add(IconTextButton(
          onTap: _selectedBtnGroupMove,
          icon: svg(name: "file_move", height: height, color: Colors.black),
          label: "移动",
          textStyle: textStyle));
      if (_selectFileIds.length == 1) {
        list.add(IconTextButton(
            onTap: _selectedBtnGroupRename,
            icon: svg(name: "file_rename", height: height),
            label: "重命名",
            textStyle: textStyle));
      }
    }
    if (_selectFileIds.length == 1) {
      list.add(IconTextButton(
          onTap: _selectedBtnGroupFileInfo,
          icon: svg(name: "file_info", height: height),
          label: "详细信息",
          textStyle: textStyle));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SpeedDial(
        visible: _selectFileIds.isEmpty,
        icon: Icons.add,
        activeBackgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        activeIcon: Icons.close,
        spacing: 3,
        mini: true,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        direction: SpeedDialDirection.up,
        switchLabelPosition: false,
        closeManually: false,
        heroTag: 'speed-dial-hero-tag',
        useRotationAnimation: true, //旋转动画
        elevation: 3.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        children: [
          SpeedDialChild(
            // elevation: 1,
            child: svg(name: "new_folder", height: 30, color: Colors.white),
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.white,
            label: '新建文件夹',
            onTap: _floatBtnNewFolder,
            onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: svg(name: "new_file", height: 30, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            label: '选择文件',
            onTap: () => _floatBtnPickFile(true),
          ),
          SpeedDialChild(
            child: svg(name: "new_media", height: 23, color: Colors.white),
            backgroundColor: Colors.orangeAccent.shade200,
            foregroundColor: Colors.white,
            label: '选择图片视频',
            onTap: () => _floatBtnPickFile(false),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              // width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(
                        onPressed: _onBackClick,
                      ),
                      Expanded(
                          child: _selectFileIds.isNotEmpty
                              ? Center(
                                  child: Text(
                                    overflow: TextOverflow.clip,
                                    "已选择${_selectFileIds.length}个文件",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                )
                              : const SizedBox()),
                      _selectFileIds.isEmpty //判断是否展示搜索图标
                          ? IconButton(
                              onPressed: () {}, icon: const Icon(Icons.search))
                          : const SizedBox(),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                    ],
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 0.5,
                          spreadRadius: 0.6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          widget.routrerData.bucketsModel.bucketsName.substring(
                              0,
                              min(
                                  10,
                                  widget.routrerData.bucketsModel.bucketsName
                                      .length)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  widget.routrerData.levelNameList.length,
                                  (index) {
                                var sp = "";
                                if (index <
                                    widget.routrerData.levelNameList.length -
                                        1) {
                                  sp = ">";
                                }
                                return GestureDetector(
                                  onTap: () => _onGotoFile(
                                      widget.routrerData.levelNameList[index]),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 1),
                                    child: Text(
                                      "${widget.routrerData.levelNameList[index]} $sp",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Text(
                      widget.routrerData.rootObject.fileName,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: _total > _rows.length,
                      onRefresh: () async {
                        _rows.clear();
                        await _loadFiles();
                        if (mounted) {
                          setState(() {
                            _refreshController.refreshCompleted();
                          });
                        }
                      },
                      onLoading: () async {
                        if (_total > _rows.length) {
                          _pageNum++;
                          await _loadFiles();
                        }
                        if (mounted) setState(() {});
                        _refreshController.loadComplete();
                      },
                      child: _getPlanWidget(context) ??
                          Center(
                            child: svg(
                                name: "empty_big",
                                height:
                                    MediaQuery.of(context).size.width / 3 * 2),
                          ),
                    ),
                  )),
                  _selectFileIds.isNotEmpty //判断是否显示文件多选后的按钮组
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 1,
                                    offset: Offset(0, 1))
                              ]),
                          margin: const EdgeInsets.only(
                              bottom: 30, left: 5, right: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 10,
                            children: _getFileActionAuthButton(),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///点击文件的判断操作
  ///1. 如果是文件夹类型则打开此文件夹重新加载页面数据
  ///2. 如果是文件则打开文件预览功能
  void _onFileClick(FileObjectModel model) {
    if (_selectFileIds.isNotEmpty) {
      model.check = !model.check;
      if (model.check) {
        _selectFileIds.add(model.id);
      } else {
        _selectFileIds.remove(model.id);
      }
      if (_selectFileIds.isEmpty) {
        _isShowSelectMenu = false;
      }
      setState(() {});
      return;
    }
    if (model.isDir) {
      var routerData = widget.routrerData.copyWith();
      routerData.levelNameList.add(model.fileName);
      routerData.rootObject = model;
      routerData.trees.add(model);
      context.pushReplacement("/file", extra: routerData);
    } else {
      //文件预览
      //1. 图片 视频 音频 文字可以在线预览
      if (model.fileContentType!.startsWith("image")) {
        var images = _rows
            .where((element) =>
                element.fileContentType?.startsWith("image") ?? false)
            .toList();
        int index = 0;
        for (int i = 0; i < images.length; i++) {
          if (images[i].id == model.id) {
            index = i;
            break;
          }
        }
        context.pushNamed("preview-image",
            extra: images, pathParameters: {"index": index.toString()});
      }
    }
  }

  ///点击返回按钮的逻辑
  ///从routerData中的层级数组的长度进行选择跳转的逻辑
  ///1. 不等于1 则回退历史上一级的文件夹内数据
  ///2. 等于1 代表根目录再次点击返回按钮则退出返回存储桶页面
  void _onBackClick() {
    if (widget.routrerData.levelNameList.length != 1) {
      var routerData = widget.routrerData.copyWith();
      routerData.levelNameList.removeLast();
      routerData.trees.removeLast();
      routerData.rootObject = routerData.trees.last;
      context.pushReplacement("/file", extra: routerData);
    } else {
      context.pop();
    }
  }

  ///点击面包屑跳转到点击的文件夹内数据
  void _onGotoFile(String fileName) {
    var routerData = widget.routrerData.copyWith();
    while (routerData.trees.last.fileName != fileName) {
      routerData.trees.removeLast();
      routerData.levelNameList.removeLast();
      routerData.rootObject = routerData.trees.last;
    }
    context.pushReplacement("/file", extra: routerData);
  }

  ///判断是否有选择文件，判断是否展示选择功能组件
  void _onShowSelectMenuModal() {
    if (_selectFileIds.isNotEmpty && !_isShowSelectMenu) {
      _isShowSelectMenu = true;
    } else if (_selectFileIds.isEmpty) {
      _isShowSelectMenu = false;
    }
  }

  ///---------------文件选中的按钮组点击事件------------------------------//
  ///
  ///下载、分享、删除、复制、移动、重命名、详细信息
  ///

  ///展示文件复制或者移动选择目标文件夹的窗口
  void _onClickShowFileCopyModal(Function(FileObjectModel) onSelectCall) {
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        isScrollControlled: true,
        elevation: 10,
        barrierColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height / 3 * 2,
            width: double.infinity,
            child: FileMoveWidget(
              onSelectCall: onSelectCall,
              fileRoot: widget.routrerData.trees.first,
            ),
          );
        });
  }

  ///下载文件
  void _selectedBtnGroupDownload() async {
    // //获取系统权限
    if (await FileObjectDownloaderUtil.requestStorePermission() == false) {
      return;
    }

    //下载开始
    if (_selectFileIds.isEmpty) {
      return;
    }
    for (int id in _selectFileIds) {
      if (mounted) {
        var file = _rows.lastWhere((element) => element.id == id);
        if (file.isDir) {
          continue;
        }
        var task = await FileObjectDownloaderUtil.createDownloadTask(
          await ApiMap.getDownloadFileSignInfo(objectId: id),
          file,
          context,
        );
        FileObjectDownloaderUtil.pushQueue(task);
      }
    }
    setState(() {
      _selectFileIds.clear();
      for (var element in _rows) {
        element.check = false;
      }
    });
    EasyLoading.showToast("已添加到下载队列!");
  }

  ///分享
  void _selectedBtnGroupShare() {}

  ///删除
  void _selectedBtnGroupDel() {
    DialogUtil.showConfirmDialog(
        context, "您确定要删除${_selectFileIds.length}个文件吗，且不可恢复!", ok: () async {
      bool state = true;
      for (int id in _selectFileIds) {
        if (!(await ApiMap.deleteFile(fileObjectId: id))) {
          state = false;
        } else {
          _rows.removeWhere((element) => element.id == id);
        }
      }
      ToastUtil.show(msg: state ? "删除成功" : "删除失败");
      _selectFileIds.clear();
      setState(() {});
    });
  }

  ///复制
  void _selectedBtnGroupCopy() {
    if (_selectFileIds.isNotEmpty) {
      _onClickShowFileCopyModal((v) async {
        //选择完成
        EasyLoading.show(status: "正在复制中...");
        bool state = true;
        for (int id in _selectFileIds) {
          var res = await ApiMap.copyFile(fileObjectId: id, targetId: v.id);
          if (!res) {
            state = false;
          }
        }
        EasyLoading.dismiss();
        ToastUtil.show(msg: state ? "复制成功" : "复制失败");
        setState(() {
          _selectFileIds.clear();
          for (var element in _rows) {
            element.check = false;
          }
        });
      });
    }
  }

  ///移动
  void _selectedBtnGroupMove() {
    if (_selectFileIds.isNotEmpty) {
      _onClickShowFileCopyModal((v) async {
        //选择完成
        EasyLoading.show(status: "正在移动中...");
        bool state = true;
        for (int id in _selectFileIds) {
          var res = await ApiMap.moveFile(fileObjectId: id, targetId: v.id);
          if (!res) {
            state = false;
          }
        }
        EasyLoading.dismiss();
        ToastUtil.show(msg: state ? "移动成功" : "移动失败");
        _selectFileIds.clear();
        _rows.clear();
        _pageNum = 1;
        _loadFiles();
      });
    }
  }

  ///重命名
  void _selectedBtnGroupRename() {
    int id = _selectFileIds.last;
    var file = _rows.lastWhere((element) => element.id == id);
    DialogUtil.showInputDialog(context, dialogType: DialogType.noHeader,
        call: (value) {
      ApiMap.renameFile(fileObjectId: id, newName: value).then((v) {
        file.fileName = value;
        setState(() {
          _selectFileIds.clear();
          for (var element in _rows) {
            element.check = false;
          }
        });
      }).catchError((e) => ToastUtil.show(msg: "修改失败"));
    }, title: "重命名文件", placeholder: "请输入新文件名", initVal: file.fileName);
  }

  ///文件详细信息
  void _selectedBtnGroupFileInfo() {
    var file = _rows.lastWhere((element) => element.id == _selectFileIds.last);
    List<ListTile> tile = [];
    tile.add(ListTile(
      dense: true,
      title: Text("文件路径: ${file.filePath}"),
    ));
    if (!file.isDir) {
      tile.add(ListTile(
        dense: true,
        title: Text("文件大小: ${formatBytes(file.fileSize ?? 0)}"),
      ));
      tile.add(ListTile(
        dense: true,
        title: Text("文件类型: ${file.fileContentType}"),
      ));
    }
    tile.add(ListTile(
      dense: true,
      title: Text("创建时间: ${file.createTime}"),
    ));

    AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        title: "文件详情",
        dismissOnTouchOutside: true,
        dismissOnBackKeyPress: true,
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                file.fileName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 3,
              ),
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: tile,
              ))
            ],
          ),
        )).show();
  }

  ///---------------浮动按钮组点击事件------------------------------//
  ///
  ///新建文件夹、选择文件、选择媒体文件
  ///

  ///新建文件夹
  void _floatBtnNewFolder() {
    DialogUtil.showInputDialog(
      context,
      dialogType: DialogType.noHeader,
      placeholder: "请输入文件夹名称",
      title: "新建文件夹",
      call: (value) async {
        if (await ApiMap.mkdir(
            parentId: widget.routrerData.rootObject.id, fileName: value)) {
          _pageNum = 1;
          _rows.clear();
          _refreshController.requestRefresh();
        } else {
          EasyLoading.showToast("创建失败");
        }
      },
    );
  }

  ///选择文件
  void _floatBtnPickFile(bool all) async {
    if (await FileObjectDownloaderUtil.requestStorePermission()) {
      EasyLoading.show();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          withData: false,
          withReadStream: true,
          allowMultiple: true,
          type: all ? FileType.any : FileType.media);
      EasyLoading.dismiss();
      if (result != null) {
        for (String? path in result.paths) {
          if (path != null) {
            var task = await FileObjectDownloaderUtil.createUploadTask(
                widget.routrerData.rootObject.id, path, context);
            FileObjectDownloaderUtil.pushQueue(task);
          }
        }
        EasyLoading.showToast("成功加入到上传队列");
      }
    }
  }

  ///文件上传Event监听
  void _fileObjectEventListener(dynamic event) {
    if (event is FileEventStatus) {
      if (event.status == TaskStatus.complete) {
        _rows.clear();
        _pageNum = 1;
        _refreshController.requestRefresh();
      } else if (event.status == TaskStatus.failed) {
        EasyLoading.showToast("文件上传失败", duration: const Duration(seconds: 3));
      }
    }
  }
}
