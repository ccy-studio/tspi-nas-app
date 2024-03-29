// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

///文件分享Model
class FileShareInfoVo {
  ///自增主键
  final int id;

  ///分享签名KEY
  final String signKey;

  ///过期时间,为空永久
  final String? expirationTime;

  ///访问密码
  final String? accessPassword;

  ///访问次数
  final int? clickCount;

  ///是否是直链
  final bool isSymlink;

  ///文件名
  final String fileName;

  ///桶名
  final String bucketsName;

  ///文件大小
  final int fileSize;
  FileShareInfoVo({
    required this.id,
    required this.signKey,
    this.expirationTime,
    this.accessPassword,
    this.clickCount,
    required this.isSymlink,
    required this.fileName,
    required this.bucketsName,
    required this.fileSize,
  });

  FileShareInfoVo copyWith({
    int? id,
    String? signKey,
    String? expirationTime,
    String? accessPassword,
    int? clickCount,
    bool? isSymlink,
    String? fileName,
    String? bucketsName,
    int? fileSize,
  }) {
    return FileShareInfoVo(
      id: id ?? this.id,
      signKey: signKey ?? this.signKey,
      expirationTime: expirationTime ?? this.expirationTime,
      accessPassword: accessPassword ?? this.accessPassword,
      clickCount: clickCount ?? this.clickCount,
      isSymlink: isSymlink ?? this.isSymlink,
      fileName: fileName ?? this.fileName,
      bucketsName: bucketsName ?? this.bucketsName,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'signKey': signKey,
      'expirationTime': expirationTime,
      'accessPassword': accessPassword,
      'clickCount': clickCount,
      'isSymlink': isSymlink,
      'fileName': fileName,
      'bucketsName': bucketsName,
      'fileSize': fileSize,
    };
  }

  factory FileShareInfoVo.fromMap(Map<String, dynamic> map) {
    return FileShareInfoVo(
      id: map['id'] as int,
      signKey: map['signKey'] as String,
      expirationTime: map['expirationTime'] != null
          ? map['expirationTime'] as String
          : null,
      accessPassword: map['accessPassword'] != null
          ? map['accessPassword'] as String
          : null,
      clickCount: map['clickCount'] != null ? map['clickCount'] as int : null,
      isSymlink: map['isSymlink'] as bool,
      fileName: map['fileName'] as String,
      bucketsName: map['bucketsName'] as String,
      fileSize: map['fileSize'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileShareInfoVo.fromJson(String source) =>
      FileShareInfoVo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FileShareInfoVo(id: $id, signKey: $signKey, expirationTime: $expirationTime, accessPassword: $accessPassword, clickCount: $clickCount, isSymlink: $isSymlink, fileName: $fileName, bucketsName: $bucketsName, fileSize: $fileSize)';
  }

  @override
  bool operator ==(covariant FileShareInfoVo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.signKey == signKey &&
        other.expirationTime == expirationTime &&
        other.accessPassword == accessPassword &&
        other.clickCount == clickCount &&
        other.isSymlink == isSymlink &&
        other.fileName == fileName &&
        other.bucketsName == bucketsName &&
        other.fileSize == fileSize;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        signKey.hashCode ^
        expirationTime.hashCode ^
        accessPassword.hashCode ^
        clickCount.hashCode ^
        isSymlink.hashCode ^
        fileName.hashCode ^
        bucketsName.hashCode ^
        fileSize.hashCode;
  }
}
