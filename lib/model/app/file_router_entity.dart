// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import 'package:tspi_nas_app/model/buckets_model.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';

class FileRoutrerDataEntity {
  final BucketsModel bucketsModel;
  final List<String> levelNameList;
  final List<FileObjectModel> trees;
  FileObjectModel rootObject;

  FileRoutrerDataEntity({
    required this.bucketsModel,
    required this.levelNameList,
    required this.trees,
    required this.rootObject,
  });

  FileRoutrerDataEntity copyWith({
    BucketsModel? bucketsModel,
    List<String>? levelNameList,
    List<FileObjectModel>? trees,
    FileObjectModel? rootObject,
  }) {
    return FileRoutrerDataEntity(
      bucketsModel: bucketsModel ?? this.bucketsModel,
      levelNameList: levelNameList ?? this.levelNameList,
      trees: trees ?? this.trees,
      rootObject: rootObject ?? this.rootObject,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bucketsModel': bucketsModel.toMap(),
      'levelNameList': levelNameList,
      'trees': trees.map((x) => x.toMap()).toList(),
      'rootObject': rootObject.toMap(),
    };
  }

  @override
  String toString() {
    return 'FileRoutrerDataEntity(bucketsModel: $bucketsModel, levelNameList: $levelNameList, trees: $trees, rootObject: $rootObject)';
  }

  @override
  bool operator ==(covariant FileRoutrerDataEntity other) {
    if (identical(this, other)) return true;

    return other.bucketsModel == bucketsModel &&
        listEquals(other.levelNameList, levelNameList) &&
        listEquals(other.trees, trees) &&
        other.rootObject == rootObject;
  }

  @override
  int get hashCode {
    return bucketsModel.hashCode ^
        levelNameList.hashCode ^
        trees.hashCode ^
        rootObject.hashCode;
  }
}
