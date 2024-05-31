import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/common/global_event.dart';
import 'package:tspi_nas_app/model/file_share_model.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';
import 'package:tspi_nas_app/widget/text_head_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  StreamSubscription<EventShareUpdate>? _subscription;
  final List<FileShareInfoVo> _rows = [];
  final int _pageSize = 30;
  int _pageNum = 1;
  int _total = 0;

  @override
  void initState() {
    _subscription = Application.globalEventBus
        .on<EventShareUpdate>()
        .listen(_onEventRefresh);
    Future.delayed(Duration.zero).then((value) {});
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _onEventRefresh(e) {
    _rows.clear();
    _pageNum = 1;
    _loadRows();
  }

  Future<void> _loadRows() async {
    return ApiMap.getFileObjectShareAll(pageNum: _pageNum, pageSize: _pageSize)
        .then((v) {
      _total = v.total;
      _rows.addAll(v.rows);
      setState(() {});
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const TextHedaerWidget(
          title: "我的分享",
        ),
        Expanded(
            child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: _total > _rows.length,
          onRefresh: () async {
            _rows.clear();
            _pageNum = 1;
            await _loadRows();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            if (_total > _rows.length) {
              _pageNum++;
              await _loadRows();
            }
            _refreshController.loadComplete();
          },
          child: _rows.isEmpty
              ? Center(
                  child: svg(
                      name: "empty_big",
                      width: MediaQuery.of(context).size.width / 3 * 2),
                )
              : ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    var item = _rows[index];
                    return Slidable(
                      key: const ValueKey(0),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            spacing: 2,
                            onPressed: (_) => _onRemoveShare(item),
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            padding: const EdgeInsets.all(0),
                            label: '删除',
                          ),
                          SlidableAction(
                            spacing: 2,
                            onPressed: (_) => _onCopyShare(item),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            icon: Icons.copy,
                            padding: const EdgeInsets.all(0),
                            label: '复制链接',
                          ),
                          SlidableAction(
                            spacing: 2,
                            onPressed: (_) => _onShowPwd(item),
                            backgroundColor: Theme.of(context).primaryColorDark,
                            foregroundColor: Colors.white,
                            icon: Icons.abc,
                            padding: const EdgeInsets.all(0),
                            label: '密码',
                          )
                        ],
                      ),
                      child: ListTile(
                          leading: svg(
                              name: getFileIcon("unknown", item.fileName),
                              height: 30),
                          trailing: Text(
                            "存储桶: ${item.bucketsName}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          title: Text(
                            item.fileName,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "过期时间: ${item.expirationTime ?? "永久"}",
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                          )),
                    );
                  }),
        ))
      ],
    );
  }

  void _onRemoveShare(FileShareInfoVo vo) {
    ApiMap.deleteFileObjectShare(id: vo.id).then((value) {
      ToastUtil.show(msg: "删除成功");
      _pageNum = 1;
      _rows.clear();
      _refreshController.requestRefresh();
    });
  }

  void _onCopyShare(FileShareInfoVo vo) {
    var url = ApiMap.getShareSymlinkUrl(vo);
    url += "?pwd=${vo.accessPassword}";
    Clipboard.setData(ClipboardData(text: url));
    ToastUtil.show(msg: "复制成功");
  }

  void _onShowPwd(FileShareInfoVo vo) {
    DialogUtil.showAlertMessageDialog(context,
        "密码: ${vo.accessPassword?.isEmpty ?? true ? '无' : vo.accessPassword}");
  }
}
