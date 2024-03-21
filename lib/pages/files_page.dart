import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/common/page_widget_enum.dart';
import 'package:tspi_nas_app/model/app/file_router_entity.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/stream_util.dart';

final EventBus _filePageEvent = EventBus();

enum _DataLine { select }

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
    LogUtil.logInfo("FilePage Init");
    Future.delayed(Duration.zero).then((value) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.ease,
      );
    });
    _streamSubscription = _filePageEvent.on<String>().listen((event) {
      LogUtil.logInfo(
          "===>FilePage listen ${widget.routrerData.levelNameList}");
      setState(() {
        _pageNum = 1;
        _total = 0;
        _rows.clear();
        _selectFileIds.clear();
        _loadFiles();
      });
      Future.delayed(Duration.zero).then((value) => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          ));
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _gridViewScrollController.dispose();
    _streamSubscription?.cancel();
    _refreshController.dispose();
    LogUtil.logInfo("FilePage Dispose");
    super.dispose();
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
      if (mounted) {
        setState(() {});
      }
      return;
    });
  }

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
                      child: getLine(f.filePath, initData: f.filePath)
                          .addObserver((context, pack) => SizedBox(
                                width: double.infinity,
                                height: 12,
                                child: Checkbox(
                                  activeColor: Colors.blueAccent,
                                  value: f.check,
                                  onChanged: (value) {
                                    f.check = value ?? false;
                                    if (f.check) {
                                      _selectFileIds.add(f.id);
                                    } else {
                                      _selectFileIds.remove(f.id);
                                    }
                                    //检查是否具有选择
                                    _onShowSelectMenuModal();
                                    getLine(f.filePath).setData(f.filePath,
                                        filterIdentical: false);
                                    getLine(_DataLine.select.name).setData(
                                        _selectFileIds,
                                        filterIdentical: false);
                                  },
                                  shape: const CircleBorder(), //这里就是实现圆形的设置
                                ),
                              )),
                    )
                  ],
                ),
              ),
            );
          });
    } else if (planType == PlanType.list) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                        child: getLine(_DataLine.select.name,
                                initData: _selectFileIds)
                            .addObserver(
                                (context, pack) => pack.data!.isNotEmpty
                                    ? Center(
                                        child: Text(
                                          overflow: TextOverflow.clip,
                                          "已选择${pack.data!.length}个文件",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      )
                                    : const SizedBox())),
                    getLine(_DataLine.select.name, initData: _selectFileIds)
                        .addObserver((context, pack) => pack.data!.isEmpty
                            ? IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search))
                            : const SizedBox()),
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
                                  widget.routrerData.levelNameList.length - 1) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              ],
            ),
          ),
          getLine(_DataLine.select.name, initData: _selectFileIds)
              .addObserver((context, pack) => Align(
                    alignment: Alignment.bottomRight,
                    child: Visibility(
                      visible: pack.data!.isEmpty,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 20, right: 20),
                          child: Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: const CircleBorder(),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50.0),
                                onTap: _onClickAddMenu,
                                child: const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )),
                    ),
                  )),
        ],
      ),
    );
  }

  void _onFileClick(FileObjectModel model) {
    if (_selectFileIds.isNotEmpty) {
      model.check = !model.check;
      if (model.check) {
        _selectFileIds.add(model.id);
      } else {
        _selectFileIds.remove(model.id);
      }
      getLine(model.filePath).setData(model.filePath, filterIdentical: false);
      getLine(_DataLine.select.name)
          .setData(_selectFileIds, filterIdentical: false);
      if (_selectFileIds.isEmpty) {
        _isShowSelectMenu = false;
      }
      return;
    }
    if (model.isDir) {
      var routerData = widget.routrerData.copyWith();
      routerData.levelNameList.add(model.fileName);
      routerData.rootObject = model;
      routerData.trees.add(model);
      context.pushReplacement("/file", extra: routerData);
    } else {}
  }

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

  void _onClickAddMenu() {
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
            height: 100,
            child: Checkbox(
              activeColor: Colors.blueAccent,
              value: true,
              onChanged: (value) {},
              shape: CircleBorder(), //这里就是实现圆形的设置
            ),
          );
        });
  }
}
