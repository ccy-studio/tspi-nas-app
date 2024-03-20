// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

class PageModel<T> {
  int pageSize;
  int pageNum;
  int total;
  List<T> rows;
  PageModel({
    required this.pageSize,
    required this.pageNum,
    required this.total,
    required this.rows,
  });

  PageModel<T> copyWith({
    int? pageSize,
    int? pageNum,
    int? total,
    List<T>? rows,
  }) {
    return PageModel<T>(
      pageSize: pageSize ?? this.pageSize,
      pageNum: pageNum ?? this.pageNum,
      total: total ?? this.total,
      rows: rows ?? this.rows,
    );
  }

  factory PageModel.fromMap(
      Map<String, dynamic> map, T Function(dynamic) convert) {
    return PageModel<T>(
        pageSize: map['pageSize'] as int,
        pageNum: map['pageNum'] as int,
        total: map['total'] as int,
        rows: (map['rows'] as List).map<T>(convert).toList());
  }

  @override
  String toString() {
    return 'PageModel(pageSize: $pageSize, pageNum: $pageNum, total: $total, rows: $rows)';
  }

  @override
  bool operator ==(covariant PageModel<T> other) {
    if (identical(this, other)) return true;

    return other.pageSize == pageSize &&
        other.pageNum == pageNum &&
        other.total == total &&
        listEquals(other.rows, rows);
  }

  @override
  int get hashCode {
    return pageSize.hashCode ^
        pageNum.hashCode ^
        total.hashCode ^
        rows.hashCode;
  }
}

abstract class PageConvert<R> {
  R convert(dynamic res);
}
