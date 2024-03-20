// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UploadTaskModel {
  String uuid;
  String fileName;
  int id;
  String fileMd5;
  UploadTaskModel({
    required this.uuid,
    required this.fileName,
    required this.id,
    required this.fileMd5,
  });

  UploadTaskModel copyWith({
    String? uuid,
    String? fileName,
    int? id,
    String? fileMd5,
  }) {
    return UploadTaskModel(
      uuid: uuid ?? this.uuid,
      fileName: fileName ?? this.fileName,
      id: id ?? this.id,
      fileMd5: fileMd5 ?? this.fileMd5,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'fileName': fileName,
      'id': id,
      'fileMd5': fileMd5,
    };
  }

  factory UploadTaskModel.fromMap(Map<String, dynamic> map) {
    return UploadTaskModel(
      uuid: map['uuid'] as String,
      fileName: map['fileName'] as String,
      id: map['id'] as int,
      fileMd5: map['fileMd5'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UploadTaskModel.fromJson(String source) =>
      UploadTaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UploadTaskModel(uuid: $uuid, fileName: $fileName, id: $id, fileMd5: $fileMd5)';
  }

  @override
  bool operator ==(covariant UploadTaskModel other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.fileName == fileName &&
        other.id == id &&
        other.fileMd5 == fileMd5;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^ fileName.hashCode ^ id.hashCode ^ fileMd5.hashCode;
  }
}
