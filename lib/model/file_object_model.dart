// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FileObjectModel {
  int id;

  String fileName;

  String? fileContentType;

  String filePath;

  int? fileSize;

  bool isDir;

  int? parentId;

  String? createTime;

  bool check;

  FileObjectModel({
    required this.id,
    required this.fileName,
    this.fileContentType,
    required this.filePath,
    this.fileSize,
    required this.isDir,
    this.parentId,
    this.createTime,
    this.check = false,
  });

  FileObjectModel copyWith({
    int? id,
    String? fileName,
    String? fileContentType,
    String? filePath,
    int? fileSize,
    bool? isDir,
    int? parentId,
    String? createTime,
    bool? check,
  }) {
    return FileObjectModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileContentType: fileContentType ?? this.fileContentType,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      isDir: isDir ?? this.isDir,
      parentId: parentId ?? this.parentId,
      createTime: createTime ?? this.createTime,
      check: check ?? this.check,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'fileName': fileName,
      'fileContentType': fileContentType,
      'filePath': filePath,
      'fileSize': fileSize,
      'isDir': isDir,
      'parentId': parentId,
      'createTime': createTime,
      'check': check,
    };
  }

  factory FileObjectModel.fromMap(Map<String, dynamic> map) {
    return FileObjectModel(
      id: map['id'] as int,
      fileName: map['fileName'] as String,
      fileContentType: map['fileContentType'] != null
          ? map['fileContentType'] as String
          : null,
      filePath: map['filePath'] as String,
      fileSize: map['fileSize'] != null ? map['fileSize'] as int : null,
      isDir: map['isDir'] as bool,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      createTime:
          map['createTime'] != null ? map['createTime'] as String : null,
      check: map['check'] != null ? map['check'] as bool : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileObjectModel.fromJson(String source) =>
      FileObjectModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FileObjectModel(id: $id, fileName: $fileName, fileContentType: $fileContentType, filePath: $filePath, fileSize: $fileSize, isDir: $isDir, parentId: $parentId, createTime: $createTime, check: $check)';
  }

  @override
  bool operator ==(covariant FileObjectModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.fileName == fileName &&
        other.fileContentType == fileContentType &&
        other.filePath == filePath &&
        other.fileSize == fileSize &&
        other.isDir == isDir &&
        other.parentId == parentId &&
        other.createTime == createTime &&
        other.check == check;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fileName.hashCode ^
        fileContentType.hashCode ^
        filePath.hashCode ^
        fileSize.hashCode ^
        isDir.hashCode ^
        parentId.hashCode ^
        createTime.hashCode ^
        check.hashCode;
  }
}
