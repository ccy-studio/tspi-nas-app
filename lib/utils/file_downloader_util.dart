import 'package:background_downloader/background_downloader.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/model/file_sign_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';

class FileObjectDownloaderUtil {
  static late final FileDownloader downloader;

  static final EventBus eventBus = EventBus();

  static void install() {
    downloader = FileDownloader();
    downloader.trackTasks();
    downloader.updates.listen(_initListener);
  }

  static void _initListener(TaskUpdate event) {
    eventBus.fire(event);
    switch (event) {
      case TaskStatusUpdate():
        print('Status update for ${event.task} with status ${event.status}');
        if (event.status == TaskStatus.complete) {
          var file = FileObjectModel.fromJson(event.task.metaData);
          if (event.task is DownloadTask) {
            if (file.fileContentType!.startsWith("image")) {
              downloader.moveToSharedStorage(
                  event.task as DownloadTask, SharedStorage.images,
                  mimeType: file.fileContentType);
            }
            if (file.fileContentType!.startsWith("video")) {
              downloader.moveToSharedStorage(
                  event.task as DownloadTask, SharedStorage.video,
                  mimeType: file.fileContentType);
            }
            if (file.fileContentType!.startsWith("audio")) {
              downloader.moveToSharedStorage(
                  event.task as DownloadTask, SharedStorage.audio,
                  mimeType: file.fileContentType);
            }
          }
        }
      case TaskProgressUpdate():
        print(
            'Progress update for ${event.task} with progress ${event.progress}');
    }
  }

  ///构造一个下载任务实体
  static ParallelDownloadTask createDownloadTask(
      FileObjectSignModel sign, FileObjectModel file, BuildContext context) {
    return ParallelDownloadTask(
        url: "${Application.BASE_URL}/file/s/download",
        chunks: 5,
        filename: sign.fileName,
        httpRequestMethod: "GET",
        directory: "download",
        updates: Updates.statusAndProgress,
        allowPause: true,
        baseDirectory: BaseDirectory.applicationDocuments,
        metaData: file.toJson(),
        headers: {
          "X-SIGN": sign.signString,
          "account":
              context.read<GlobalStateProvider>().currentUser!.userAccount,
          "bucketId": "${sign.bkId}",
          "objectId": "${sign.objectId}",
          "uuid": sign.uuid,
          "expire": "${sign.expireTime}",
          "X-DESC": "true"
        });
  }

  ///入队开始下载
  static void pushQueueDownload(DownloadTask task) {
    downloader.enqueue(task);
  }
}
