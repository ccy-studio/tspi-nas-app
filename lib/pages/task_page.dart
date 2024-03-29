// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:tspi_nas_app/model/app/file_event_model.dart';
import 'package:tspi_nas_app/utils/file_downloader_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/time.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';
import 'package:tspi_nas_app/widget/text_head_widget.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  StreamSubscription? _fileListenerSubscription;

  final List<_TaskExt> _task = [];
  final List<_TaskExt> _taskDownload = [];
  final List<_TaskExt> _taskUpload = [];

  @override
  void initState() {
    _fileListenerSubscription = FileObjectDownloaderUtil.eventBus
        .on<FileEventStatus>()
        .listen(_fileListener);
    Future.delayed(Duration.zero).then((value) => _onRefresh());
    super.initState();
  }

  @override
  void dispose() {
    _fileListenerSubscription?.cancel();
    super.dispose();
  }

  ///文件监听器
  void _fileListener(FileEventStatus event) {
    _onRefresh();
  }

  Widget _widgetCreateTabBarItem(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextHedaerWidget(
          title: "任务",
          expand: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                onPressed: () async {
                  await FileDownloader().database.deleteAllRecords();
                  _onRefresh();
                  ToastUtil.show(msg: "清空成功");
                },
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.grey,
                )),
          ),
        ),
        Expanded(
            child: ContainedTabBarView(
          tabBarProperties: TabBarProperties(
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 1),
          tabs: [_widgetCreateTabBarItem("下载"), _widgetCreateTabBarItem("上传")],
          views: [
            _TabListView(
              onRefresh: _onRefresh,
              rows: _taskDownload,
              prefixText: "下载",
            ),
            _TabListView(
              onRefresh: _onRefresh,
              rows: _taskUpload,
              prefixText: "上传",
            ),
          ],
        ))
      ],
    );
  }

  Future<void> _onRefresh() async {
    var records = await FileDownloader().database.allRecords();
    final ids = <String>{};
    records.retainWhere((x) => ids.add(x.taskId));
    _task.clear();
    _taskDownload.clear();
    _taskUpload.clear();
    records.sort((a, b) => b.task.creationTime.compareTo(a.task.creationTime));
    for (var item in records) {
      if (item.status == TaskStatus.canceled ||
          item.status == TaskStatus.notFound) {
        continue;
      }
      Task? queueTask = await FileDownloader().taskForId(item.taskId);
      TaskStatus status = item.status;
      if (queueTask != null) {
        status = TaskStatus.running;
      }
      var task = _TaskExt(
        status: status,
        record: item,
        taskId: item.taskId,
        isDownload: item.task is DownloadTask,
      );
      _task.add(task);
      if (task.isDownload) {
        _taskDownload.add(task);
      } else {
        _taskUpload.add(task);
      }
      LogUtil.logInfo(
          "Record: name:${item.task.filename},status: ${item.status},datetime: ${item.task.creationTime}");
    }

    setState(() {});
    return;
  }
}

class _TaskExt {
  final TaskRecord record;
  final String taskId;
  final TaskStatus status;
  final bool isDownload;
  _TaskExt({
    required this.record,
    required this.status,
    required this.taskId,
    required this.isDownload,
  });

  @override
  bool operator ==(covariant _TaskExt other) {
    if (identical(this, other)) return true;

    return other.record == record &&
        other.taskId == taskId &&
        other.isDownload == isDownload;
  }

  @override
  int get hashCode {
    return record.hashCode ^ taskId.hashCode ^ isDownload.hashCode;
  }

  @override
  String toString() {
    return '_TaskExt(record: $record, taskId: $taskId, status: $status, isDownload: $isDownload)';
  }
}

class _TabListView extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final List<_TaskExt> rows;
  final String prefixText;

  const _TabListView(
      {super.key,
      required this.onRefresh,
      required this.rows,
      required this.prefixText});

  @override
  State<_TabListView> createState() => __TabListViewState();
}

class __TabListViewState extends State<_TabListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final idSet = <String>{};
    widget.rows.retainWhere((element) => idSet.add(element.taskId));
    super.build(context);
    return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView.builder(
          itemBuilder: (context, index) {
            var t = widget.rows[index];
            var s = t.status;
            if (s == TaskStatus.complete || s == TaskStatus.failed) {
              return ListTile(
                title: Text(
                  t.record.task.filename,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
                subtitle: Text(
                  DateUtil.formatDate(t.record.task.creationTime),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                trailing: Text(s == TaskStatus.complete
                    ? "${widget.prefixText}完成"
                    : "${widget.prefixText}失败"),
              );
            } else {
              return DownloadProgressIndicator(
                FileObjectDownloaderUtil.eventBus
                    .on<TaskUpdate>()
                    .where((event) => event.task.taskId == t.taskId),
                showCancelButton: true,
                showPauseButton: true,
                backgroundColor: Colors.transparent,
                maxExpandable: 3,
              );
            }
          },
          itemCount: widget.rows.length,
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
