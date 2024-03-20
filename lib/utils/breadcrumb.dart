// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/utils/log_util.dart';

class Breadcrumb with ChangeNotifier {
  late _BreadcrumbItem _nodeRoot;
  late _BreadcrumbItem _nodeLast;

  FileObjectModel get frist => _nodeRoot.model;
  FileObjectModel get last => _nodeLast.model;
  List<FileObjectModel> get lastChild => _nodeLast.child;
  bool get lastIsLoadDone => _nodeLast.child.length >= _nodeLast.total;

  List<String> get pathBreadcrumb {
    List<String> list = [];
    _BreadcrumbItem? node = _nodeRoot.next;
    while (node != null) {
      list.add(node.model.fileName);
      node = node.next;
    }
    return list;
  }

  Breadcrumb(FileObjectModel fRoot) {
    _nodeRoot = _BreadcrumbItem(filePath: fRoot.filePath, model: fRoot);
    _nodeLast = _nodeRoot;
  }

  void push(FileObjectModel model) {
    //检查是否在链表内存在此路径
    _BreadcrumbItem? node = _nodeRoot.next;
    while (node != null) {
      if (node.filePath == model.filePath) {
        node.next = null;
        //发送更新通知
        notifyListeners();
        return;
      }
      node = node.next;
    }
    var newNode = _BreadcrumbItem(filePath: model.filePath, model: model);
    newNode.pre = _nodeLast;
    _nodeLast.next = newNode;
    _nodeLast = newNode;
    notifyListeners();
  }

  _BreadcrumbItem? _getByPath(String path) {
    _BreadcrumbItem? node = _nodeRoot;
    while (node != null) {
      if (node.filePath == path) {
        return node;
      }
      node = node.next;
    }
    return null;
  }

  ///加载数据
  Future<bool> loadChildFile(FileObjectModel model) async {
    if (lastIsLoadDone) {
      return Future.value(true);
    }
    _BreadcrumbItem? node = _getByPath(model.filePath);
    if (node == null) {
      return Future.error("不存在的文件路径");
    }
    node.pageNum++;
    return ApiMap.getFileObjectList(
            parentId: model.parentId, pageSize: 20, pageNum: node.pageNum)
        .then((value) {
      node.total = value.total;
      node.child.addAll(value.rows);
      notifyListeners();
      return true;
    }).catchError((e) {
      LogUtil.logError(e);
      return false;
    });
  }
}

class _BreadcrumbItem {
  String filePath;
  FileObjectModel model;
  List<FileObjectModel> child = List.empty(growable: true);
  int total;
  int pageNum;

  _BreadcrumbItem({
    required this.filePath,
    required this.model,
    this.total = 0,
    this.pageNum = 0,
  });
  _BreadcrumbItem? pre;
  _BreadcrumbItem? next;

  _BreadcrumbItem copyWith({
    String? filePath,
    FileObjectModel? model,
    int? total,
    int? pageNum,
  }) {
    return _BreadcrumbItem(
      filePath: filePath ?? this.filePath,
      model: model ?? this.model,
      total: total ?? this.total,
      pageNum: pageNum ?? this.pageNum,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'filePath': filePath,
      'model': model.toMap(),
      'total': total,
      'pageNum': pageNum,
    };
  }

  factory _BreadcrumbItem.fromMap(Map<String, dynamic> map) {
    return _BreadcrumbItem(
      filePath: map['filePath'] as String,
      model: FileObjectModel.fromMap(map['model'] as Map<String, dynamic>),
      total: map['total'] as int,
      pageNum: map['pageNum'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory _BreadcrumbItem.fromJson(String source) =>
      _BreadcrumbItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '_BreadcrumbItem(filePath: $filePath, model: $model, total: $total, pageNum: $pageNum)';
  }

  @override
  bool operator ==(covariant _BreadcrumbItem other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        other.model == model &&
        other.total == total &&
        other.pageNum == pageNum;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        model.hashCode ^
        total.hashCode ^
        pageNum.hashCode;
  }
}
