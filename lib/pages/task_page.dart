/*
 * @Description: 
 * @Blog: saisaiwa.com
 * @Author: ccy
 * @Date: 2024-05-31 11:11:18
 * @LastEditTime: 2024-05-31 17:53:38
 */
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tspi_nas_app/utils/file_api.dart';
import 'package:tspi_nas_app/widget/text_head_widget.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  StreamSubscription? _fileListenerSubscription;

  final _rows = List<FileApiBaseTask>.empty(growable: true);

  @override
  void initState() {
    _fileListenerSubscription =
        FileApiUtil.eventBus.on<dynamic>().listen(_fileListener);
    Future.delayed(Duration.zero).then((value) => _onRefresh());
    super.initState();
  }

  @override
  void dispose() {
    _fileListenerSubscription?.cancel();
    super.dispose();
  }

  ///文件监听器
  void _fileListener(dynamic event) {
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const TextHedaerWidget(
          title: "传输任务",
        ),
        Expanded(
            child: ListView.builder(
          itemBuilder: (context, index) {
            var item = _rows[index];
            String type = item is FileApiDownloadTask ? "下载" : "上传";
            String status = "";
            Icon icon = item is FileApiDownloadTask
                ? const Icon(Icons.download)
                : const Icon(Icons.upload);
            switch (item.status) {
              case FileApiTaskStatus.running:
                status = item.percentage ?? "0%";
                break;
              case FileApiTaskStatus.queue:
                status = "等待中";
                break;
              case FileApiTaskStatus.success:
                status = "完成";
                break;
              case FileApiTaskStatus.error:
                status = "失败";
                break;
            }
            return ListTile(
              leading: icon,
              title: Text(
                item.fileName,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(type),
              trailing: Text(status),
            );
          },
          itemCount: _rows.length,
        ))
      ],
    );
  }

  Future<void> _onRefresh() async {
    _rows.clear();
    _rows.addAll(FileApiUtil.downloadTaskPool);
    _rows.addAll(FileApiUtil.uploadTaskPool);
    _rows.sort((a, b) {
      if (a.status == FileApiTaskStatus.running) {
        return 1;
      }
      return -1;
    });
  }
}
