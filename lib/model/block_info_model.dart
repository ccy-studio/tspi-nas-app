// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class BlockInfoModel {
  String fileName;
  String fileMd5;
  int fileSize;
  int blockCount;
  bool isOverwrite;
  List<BlockCurrentInfoModel>? currentBlocks;
  BlockInfoModel({
    required this.fileName,
    required this.fileMd5,
    required this.fileSize,
    required this.blockCount,
    required this.isOverwrite,
    this.currentBlocks,
  });

  BlockInfoModel copyWith({
    String? fileName,
    String? fileMd5,
    int? fileSize,
    int? blockCount,
    bool? isOverwrite,
    List<BlockCurrentInfoModel>? currentBlocks,
  }) {
    return BlockInfoModel(
      fileName: fileName ?? this.fileName,
      fileMd5: fileMd5 ?? this.fileMd5,
      fileSize: fileSize ?? this.fileSize,
      blockCount: blockCount ?? this.blockCount,
      isOverwrite: isOverwrite ?? this.isOverwrite,
      currentBlocks: currentBlocks ?? this.currentBlocks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileName': fileName,
      'fileMd5': fileMd5,
      'fileSize': fileSize,
      'blockCount': blockCount,
      'isOverwrite': isOverwrite,
      'currentBlocks': currentBlocks?.map((x) => x.toMap()).toList(),
    };
  }

  factory BlockInfoModel.fromMap(Map<String, dynamic> map) {
    return BlockInfoModel(
      fileName: map['fileName'] as String,
      fileMd5: map['fileMd5'] as String,
      fileSize: map['fileSize'] as int,
      blockCount: map['blockCount'] as int,
      isOverwrite: map['isOverwrite'] as bool,
      currentBlocks: map['currentBlocks'] != null
          ? List<BlockCurrentInfoModel>.from(
              (map['currentBlocks'] as List<int>).map<BlockCurrentInfoModel?>(
                (x) => BlockCurrentInfoModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockInfoModel.fromJson(String source) =>
      BlockInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BlockInfoModel(fileName: $fileName, fileMd5: $fileMd5, fileSize: $fileSize, blockCount: $blockCount, isOverwrite: $isOverwrite, currentBlocks: $currentBlocks)';
  }

  @override
  bool operator ==(covariant BlockInfoModel other) {
    if (identical(this, other)) return true;

    return other.fileName == fileName &&
        other.fileMd5 == fileMd5 &&
        other.fileSize == fileSize &&
        other.blockCount == blockCount &&
        other.isOverwrite == isOverwrite &&
        listEquals(other.currentBlocks, currentBlocks);
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        fileMd5.hashCode ^
        fileSize.hashCode ^
        blockCount.hashCode ^
        isOverwrite.hashCode ^
        currentBlocks.hashCode;
  }
}

class BlockCurrentInfoModel {
  ///文件名称
  String fileName;

  ///序号
  int number;

  ///文件大小
  int size;
  BlockCurrentInfoModel({
    required this.fileName,
    required this.number,
    required this.size,
  });

  BlockCurrentInfoModel copyWith({
    String? fileName,
    int? number,
    int? size,
  }) {
    return BlockCurrentInfoModel(
      fileName: fileName ?? this.fileName,
      number: number ?? this.number,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileName': fileName,
      'number': number,
      'size': size,
    };
  }

  factory BlockCurrentInfoModel.fromMap(Map<String, dynamic> map) {
    return BlockCurrentInfoModel(
      fileName: map['fileName'] as String,
      number: map['number'] as int,
      size: map['size'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockCurrentInfoModel.fromJson(String source) =>
      BlockCurrentInfoModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BlockCurrentInfoModel(fileName: $fileName, number: $number, size: $size)';

  @override
  bool operator ==(covariant BlockCurrentInfoModel other) {
    if (identical(this, other)) return true;

    return other.fileName == fileName &&
        other.number == number &&
        other.size == size;
  }

  @override
  int get hashCode => fileName.hashCode ^ number.hashCode ^ size.hashCode;
}
