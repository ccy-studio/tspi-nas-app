// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

///获得文件临时签名数据信息
class FileObjectSignModel {
  ///SHA256签名
  final String signString;

  ///过期时间
  final int expireTime;

  ///随机字符串
  final String uuid;

  ///对象ID
  final int objectId;

  ///桶ID
  final int bkId;

  ///文件大小
  int? fileSize;

  ///文件名
  final String fileName;

  FileObjectSignModel({
    required this.signString,
    required this.expireTime,
    required this.uuid,
    required this.objectId,
    required this.bkId,
    this.fileSize,
    required this.fileName,
  });

  FileObjectSignModel copyWith({
    String? signString,
    int? expireTime,
    String? uuid,
    int? objectId,
    int? bkId,
    int? fileSize,
    String? fileName,
  }) {
    return FileObjectSignModel(
      signString: signString ?? this.signString,
      expireTime: expireTime ?? this.expireTime,
      uuid: uuid ?? this.uuid,
      objectId: objectId ?? this.objectId,
      bkId: bkId ?? this.bkId,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'signString': signString,
      'expireTime': expireTime,
      'uuid': uuid,
      'objectId': objectId,
      'bkId': bkId,
      'fileSize': fileSize,
      'fileName': fileName,
    };
  }

  factory FileObjectSignModel.fromMap(Map<String, dynamic> map) {
    return FileObjectSignModel(
      signString: map['signString'] as String,
      expireTime: map['expireTime'] as int,
      uuid: map['uuid'] as String,
      objectId: map['objectId'] as int,
      bkId: map['bkId'] as int,
      fileSize: map['fileSize'] != null ? map['fileSize'] as int : null,
      fileName: map['fileName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileObjectSignModel.fromJson(String source) =>
      FileObjectSignModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FileObjectSignModel(signString: $signString, expireTime: $expireTime, uuid: $uuid, objectId: $objectId, bkId: $bkId, fileSize: $fileSize, fileName: $fileName)';
  }

  @override
  bool operator ==(covariant FileObjectSignModel other) {
    if (identical(this, other)) return true;

    return other.signString == signString &&
        other.expireTime == expireTime &&
        other.uuid == uuid &&
        other.objectId == objectId &&
        other.bkId == bkId &&
        other.fileSize == fileSize &&
        other.fileName == fileName;
  }

  @override
  int get hashCode {
    return signString.hashCode ^
        expireTime.hashCode ^
        uuid.hashCode ^
        objectId.hashCode ^
        bkId.hashCode ^
        fileSize.hashCode ^
        fileName.hashCode;
  }
}
