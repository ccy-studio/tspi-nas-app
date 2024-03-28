import 'package:background_downloader/background_downloader.dart';

class FileEventStatus {
  final TaskStatus status;
  final Task task;
  FileEventStatus({
    required this.status,
    required this.task,
  });

  FileEventStatus copyWith({
    TaskStatus? status,
    Task? task,
  }) {
    return FileEventStatus(
      status: status ?? this.status,
      task: task ?? this.task,
    );
  }

  @override
  String toString() => 'FileEventStatus(status: $status, task: $task)';

  @override
  bool operator ==(covariant FileEventStatus other) {
    if (identical(this, other)) return true;

    return other.status == status && other.task == task;
  }

  @override
  int get hashCode => status.hashCode ^ task.hashCode;
}

class FileEventProgress {
  final Task task;
  final TaskProgressUpdate progress;
  FileEventProgress({
    required this.task,
    required this.progress,
  });

  FileEventProgress copyWith({
    Task? task,
    TaskProgressUpdate? progress,
  }) {
    return FileEventProgress(
      task: task ?? this.task,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() => 'FileEventProgress(task: $task, progress: $progress)';

  @override
  bool operator ==(covariant FileEventProgress other) {
    if (identical(this, other)) return true;

    return other.task == task && other.progress == progress;
  }

  @override
  int get hashCode => task.hashCode ^ progress.hashCode;
}

class FileEventMoveShareStore {
  final DownloadTask task;
  final String? targetPath;
  final bool isSuccess;
  FileEventMoveShareStore({
    required this.task,
    this.targetPath,
    required this.isSuccess,
  });

  FileEventMoveShareStore copyWith({
    DownloadTask? task,
    String? targetPath,
    bool? isSuccess,
  }) {
    return FileEventMoveShareStore(
      task: task ?? this.task,
      targetPath: targetPath ?? this.targetPath,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() =>
      'FileEventMoveShareStore(task: $task, targetPath: $targetPath, isSuccess: $isSuccess)';

  @override
  bool operator ==(covariant FileEventMoveShareStore other) {
    if (identical(this, other)) return true;

    return other.task == task &&
        other.targetPath == targetPath &&
        other.isSuccess == isSuccess;
  }

  @override
  int get hashCode => task.hashCode ^ targetPath.hashCode ^ isSuccess.hashCode;
}
