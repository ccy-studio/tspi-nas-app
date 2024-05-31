import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/v1.dart';

import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/model/file_sign_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/object_util.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';

class FileApiUtil {
  static final EventBus eventBus = EventBus();
  static const int _downloadTaskMaxCount = 5;
  static const int _uploadTaskMaxCount = 5;
  static final uploadTaskPool = List<FileApiUploadTask>.empty(growable: true);
  static final downloadTaskPool =
      List<FileApiDownloadTask>.empty(growable: true);
  static const _idGen = UuidV1();

  static final _http = Dio(BaseOptions(
    baseUrl: Application.BASE_URL,
    connectTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static int getUploadTaskActiveCount() {
    return uploadTaskPool
        .where((e) => e.status == FileApiTaskStatus.running)
        .length;
  }

  static int getDownloadTaskActiveCount() {
    return downloadTaskPool
        .where((e) => e.status == FileApiTaskStatus.running)
        .length;
  }

  static void pushUploadTask(int parentId, String filePath) {
    var task = FileApiUploadTask(
        fileName: p.basename(filePath),
        targetParentId: parentId,
        filePath: filePath,
        taskId: _idGen.generate());
    uploadTaskPool.add(task);
    _scanTaskManage();
  }

  static void pushDownloadTask(FileObjectModel file) {
    var task = FileApiDownloadTask(
        fileObj: file, taskId: _idGen.generate(), fileName: file.fileName);
    downloadTaskPool.add(task);
    _scanTaskManage();
  }

  static void _scanTaskManage() {
    for (int i = 0;
        i < _downloadTaskMaxCount - getDownloadTaskActiveCount();
        i++) {
      FileApiDownloadTask? task = downloadTaskPool
          .firstWhereOrNull((e) => e.status == FileApiTaskStatus.queue);
      if (task != null) {
        task.status = FileApiTaskStatus.running;
        _execDownloadTask(task);
      }
    }

    for (int i = 0; i < _uploadTaskMaxCount - getUploadTaskActiveCount(); i++) {
      FileApiUploadTask? task = uploadTaskPool
          .firstWhereOrNull((e) => e.status == FileApiTaskStatus.queue);
      if (task != null) {
        task.status = FileApiTaskStatus.running;
        _execUploadTask(task);
      }
    }
  }

  static Future<void> _execDownloadTask(FileApiDownloadTask task) async {
    task.status = FileApiTaskStatus.running;
    Directory? dir;
    if (Platform.isAndroid) {
      //dir = await getExternalStorageDirectory();
      dir = await getDownloadsDirectory();
    } else {
      dir = await getDownloadsDirectory();
    }
    dir ??= await getApplicationDocumentsDirectory();
    FileObjectSignModel sign =
        await ApiMap.getDownloadFileSignInfo(objectId: task.fileObj.id);
    var filePath = "${dir.path}/${sign.fileName}";
    LogUtil.logInfo("任务创建的下载路径：$filePath");
    var uri =
        Uri.encodeFull("/file/s/download/${sign.objectId}_${sign.fileName}");
    await _http.download(
      uri,
      filePath,
      options: Options(headers: {
        "X-SIGN": sign.signString,
        "account": Application.currentContext!
            .read<GlobalStateProvider>()
            .currentUser!
            .userAccount,
        "bucketId": "${sign.bkId}",
        "objectId": "${sign.objectId}",
        "uuid": sign.uuid,
        "expire": "${sign.expireTime}",
        "X-DESC": "true"
      }),
      onReceiveProgress: (received, total) {
        if (total <= 0) {
          task.status = FileApiTaskStatus.error;
          return;
        }

        task.percentage = '${(received / total * 100).toStringAsFixed(0)}%';
        task.count = total;
        task.progress = received;
        if (received == total) {
          task.status = FileApiTaskStatus.success;
        }
      },
    );
    if (task.status != FileApiTaskStatus.success) {
      task.status = FileApiTaskStatus.error;
    }
    _scanTaskManage();
  }

  static Future<void> _execUploadTask(FileApiUploadTask task) async {
    FormData formData = FormData.fromMap({
      "file":
          await MultipartFile.fromFile(task.filePath, filename: task.fileName),
    });
    await _http.post(
      "/fs/object",
      data: formData,
      queryParameters: {
        "targetFolder": "${task.targetParentId}",
        "fileName": task.fileName,
        "isOverwrite": "true"
      },
      options: Options(headers: {
        "X-AUTH-TYPE": "token",
        "Authorization": "${await SpUtil.getToken()}",
        "X-BK":
            "${Application.currentContext!.read<GlobalStateProvider>().getBId}"
      }),
      onSendProgress: (received, total) {
        if (total <= 0) {
          task.status = FileApiTaskStatus.error;
          return;
        }
        task.percentage = '${(received / total * 100).toStringAsFixed(0)}%';
        task.count = total;
        task.progress = received;
        if (received == total) {
          task.status = FileApiTaskStatus.success;
        } else {
          eventBus.fire(task);
        }
      },
    );
    if (task.status != FileApiTaskStatus.success) {
      task.status = FileApiTaskStatus.error;
    }
    eventBus.fire(task);
    _scanTaskManage();
  }

  ///申请权限
  static Future<bool> requestStorePermission() async {
    // //获取系统权限
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      LogUtil.logInfo("SDK:${androidInfo.version.sdkInt}");
      if (androidInfo.version.sdkInt > 32) {
        var plist = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
          Permission.manageExternalStorage,
        ].request();

        plist.forEach((permission, status) async {
          if (status.isGranted) {
            LogUtil.logInfo('$permission 权限已授予');
          } else if (status.isDenied) {
            LogUtil.logInfo('$permission 权限被拒绝');
            await permission.request();
          } else if (status.isPermanentlyDenied) {
            LogUtil.logInfo('$permission 权限被永久拒绝');
          }
        });
      }
      // bool isShown = await Permission.storage.shouldShowRequestRationale;
      var status = await Permission.storage.status;
      if (status.isDenied) {
        if (!(await Permission.storage.request().isGranted)) {
          _openSetting("获取存储权限失败请手动在设置里打开!");
          return false;
        }
      }
    }
    return true;
  }

  static _openSetting(String message) {
    DialogUtil.showAlertMessageDialog(Application.currentContext!, message,
        call: () => openAppSettings());
  }
}

class _BaseFileTask {
  FileApiTaskStatus status;
  int progress;
  int count;
  String? percentage;
  final String fileName;
  final String taskId;
  _BaseFileTask(
      {this.status = FileApiTaskStatus.queue,
      this.progress = 0,
      this.count = 0,
      this.percentage,
      required this.fileName,
      required this.taskId});

  _BaseFileTask copyWith({
    FileApiTaskStatus? status,
    int? progress,
    int? count,
    String? percentage,
    String? fileName,
    String? taskId,
  }) {
    return _BaseFileTask(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
      fileName: fileName ?? this.fileName,
      taskId: taskId ?? this.taskId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.name,
      'progress': progress,
      'count': count,
      'percentage': percentage,
      'fileName': fileName,
      'taskId': taskId,
    };
  }

  factory _BaseFileTask.fromMap(Map<String, dynamic> map) {
    return _BaseFileTask(
      status: EnumUtil.enumFromString(
          FileApiTaskStatus.values, map['status'] as String)!,
      progress: map['progress'] as int,
      count: map['count'] as int,
      percentage:
          map['percentage'] != null ? map['percentage'] as String : null,
      fileName: map['fileName'] as String,
      taskId: map['taskId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory _BaseFileTask.fromJson(String source) =>
      _BaseFileTask.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '_BaseFileTask(status: $status, progress: $progress, count: $count, percentage: $percentage, fileName: $fileName, taskId: $taskId)';
  }

  @override
  bool operator ==(covariant _BaseFileTask other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.progress == progress &&
        other.count == count &&
        other.percentage == percentage &&
        other.fileName == fileName &&
        other.taskId == taskId;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        progress.hashCode ^
        count.hashCode ^
        percentage.hashCode ^
        fileName.hashCode ^
        taskId.hashCode;
  }
}

class FileApiDownloadTask extends _BaseFileTask {
  final FileObjectModel fileObj;
  FileApiDownloadTask({
    required this.fileObj,
    required super.taskId,
    required super.fileName,
  });

  @override
  String toString() => 'FileApiDownloadTask(fileObj: $fileObj)';

  @override
  bool operator ==(covariant FileApiDownloadTask other) {
    if (identical(this, other)) return true;

    return other.fileObj == fileObj;
  }

  @override
  int get hashCode => fileObj.hashCode;
}

class FileApiUploadTask extends _BaseFileTask {
  final String filePath;
  final int targetParentId;
  FileApiUploadTask({
    required this.filePath,
    required this.targetParentId,
    required super.fileName,
    required super.taskId,
  });

  @override
  String toString() =>
      'FileApiUploadTask(filePath: $filePath, targetParentId: $targetParentId)';

  @override
  bool operator ==(covariant FileApiUploadTask other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath && other.targetParentId == targetParentId;
  }

  @override
  int get hashCode => filePath.hashCode ^ targetParentId.hashCode;
}

enum FileApiTaskStatus { queue, running, error, success }
