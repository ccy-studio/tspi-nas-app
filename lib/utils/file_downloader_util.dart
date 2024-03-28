import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:background_downloader_sql/background_downloader_sql.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/app/file_event_model.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/model/file_sign_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';

class FileObjectDownloaderUtil {
  static final EventBus eventBus = EventBus();

  static void install() {
    WidgetsFlutterBinding.ensureInitialized();
    FileDownloader(persistentStorage: SqlitePersistentStorage())
        .configure(globalConfig: [
      (Config.requestTimeout, const Duration(seconds: 100)),
      (Config.checkAvailableSpace, Config.always),
      (Config.holdingQueue, (5, null, null))
    ], androidConfig: [
      (Config.useCacheDir, Config.whenAble),
      (Config.bypassTLSCertificateValidation, true),
      (Config.runInForegroundIfFileLargerThan, 100),
      (Config.runInForeground, Config.always),
      (Config.useExternalStorage, Config.never)
    ], iOSConfig: [
      (Config.localize, {'取消': '停止'}),
    ]).then((result) => debugPrint('Configuration result = $result'));

    FileDownloader().trackTasks();
    FileDownloader().updates.listen(_listener);
  }

  static void _listener(TaskUpdate event) {
    switch (event) {
      case TaskStatusUpdate():
        eventBus.fire(FileEventStatus(status: event.status, task: event.task));
        LogUtil.logInfo(
            'Status update for ${event.task.filename} with status ${event.status}');
        if (event.status == TaskStatus.complete) {
          //完成
          if (event.task is DownloadTask) {
            _downloadComplete(event.task as DownloadTask);
          } else if (event.task is UploadTask) {
            LogUtil.logInfo("上传任务完成");
          }
        }
        break;
      case TaskProgressUpdate():
        eventBus.fire(FileEventProgress(task: event.task, progress: event));
        LogUtil.logInfo(
            'Progress update for ${event.task.filename} with progress ${event.progress}');
        break;
    }
  }

  ///下载完成后的回调处理
  static void _downloadComplete(DownloadTask task) async {
    LogUtil.logInfo("下载完成的真实路径:${await task.filePath()}");
    if (await requestMediaPermission()) {
      var file = FileObjectModel.fromJson(task.metaData);

      SharedStorage storage = SharedStorage.external;
      if (file.fileContentType!.startsWith("image")) {
        storage = SharedStorage.images;
      }
      if (file.fileContentType!.startsWith("video")) {
        storage = SharedStorage.video;
      }
      if (file.fileContentType!.startsWith("audio")) {
        storage = SharedStorage.audio;
      }

      final path = await FileDownloader()
          .moveToSharedStorage(task, storage, mimeType: file.fileContentType);
      LogUtil.logInfo('移动到共享目录成功路径 = ${path ?? "permission denied"}');
      eventBus.fire(FileEventMoveShareStore(
          task: task, isSuccess: true, targetPath: path));
    } else {
      eventBus.fire(FileEventMoveShareStore(task: task, isSuccess: false));
    }
  }

  ///构造一个下载任务实体
  static Future<DownloadTask> createDownloadTask(FileObjectSignModel sign,
      FileObjectModel file, BuildContext context) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getDownloadsDirectory();
    }
    dir ??= await getApplicationDocumentsDirectory();

    LogUtil.logInfo("任务创建的下载路径：${dir.path}");

    final (baseDirectory, directory, _) = await Task.split(filePath: dir.path);
    return ParallelDownloadTask(
        url: Uri.encodeFull(
            "${Application.BASE_URL}/file/s/download/${sign.objectId}_${sign.fileName}"),
        chunks: (sign.fileSize ?? 1) >= 104857600 ? 3 : 1,
        filename: sign.fileName,
        httpRequestMethod: "GET",
        directory: directory,
        updates: Updates.statusAndProgress,
        allowPause: true,
        baseDirectory: baseDirectory,
        requiresWiFi: false,
        retries: 3,
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
  static void pushQueue(Task task) {
    FileDownloader().enqueue(task);
  }

  ///创建一个上传任务
  static Future<UploadTask> createUploadTask(
      int parentId, String filePath, BuildContext context) async {
    final (baseDirectory, directory, filename) =
        await Task.split(filePath: filePath);
    return UploadTask(
        url: "${Application.BASE_URL}/fs/object",
        filename: filename,
        baseDirectory: baseDirectory,
        fileField: "file",
        httpRequestMethod: "post",
        updates: Updates.statusAndProgress,
        requiresWiFi: false,
        retries: 3,
        fields: {
          "targetFolder": "$parentId",
          "fileName": filename,
          "isOverwrite": "true"
        },
        directory: directory,
        headers: {
          "X-AUTH-TYPE": "token",
          "Authorization": "${await SpUtil.getToken()}",
          "X-BK": "${context.read<GlobalStateProvider>().getBId}"
        });
  }

  ///申请权限
  static Future<bool> requestStorePermission() async {
    // //获取系统权限
    if (Platform.isAndroid) {
      bool isShown = await ph.Permission.storage.shouldShowRequestRationale;
      var status = await ph.Permission.storage.status;
      if (status.isDenied) {
        //权限没允许
        //如果弹框不在出现了，那就跳转到设置页。
        //如果弹框还能出现，那就不用管了，申请权限就行了
        if (!isShown) {
          _openSetting("获取存储权限失败请手动在设置里打开!");
          return false;
        } else {
          if (!(await ph.Permission.storage.request().isGranted)) {
            ToastUtil.show(msg: "请允许存储权限，并重试！");
            return false;
          }
        }
      }
    }
    return true;
  }

  static _openSetting(String message) {
    DialogUtil.showAlertMessageDialog(Application.currentContext!, message,
        call: () => ph.openAppSettings());
  }

  static Future<bool> requestMediaPermission() async {
    if (Platform.isAndroid) {
      var auth = await FileDownloader()
          .permissions
          .status(PermissionType.androidSharedStorage);
      if (auth != PermissionStatus.granted) {
        auth = await FileDownloader()
            .permissions
            .request(PermissionType.androidSharedStorage);
      }
      if (auth == PermissionStatus.granted) {
        return true;
      } else {
        LogUtil.logError('androidSharedStorage 权限获取失败');
      }
    }
    return false;
  }
}
