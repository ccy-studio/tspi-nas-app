import 'dart:convert';

class BaseResponse {
  final int code;

  String? msg;

  dynamic data;

  String? traceId;
  BaseResponse({
    required this.code,
    this.msg,
    this.data,
    this.traceId,
  });

  BaseResponse copyWith({
    int? code,
    String? msg,
    dynamic data,
    String? traceId,
  }) {
    return BaseResponse(
      code: code ?? this.code,
      msg: msg ?? this.msg,
      data: data ?? this.data,
      traceId: traceId ?? this.traceId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'msg': msg,
      'data': data,
      'traceId': traceId,
    };
  }

  factory BaseResponse.fromMap(Map<String, dynamic> map) {
    return BaseResponse(
      code: map['code'] as int,
      msg: map['msg'] != null ? map['msg'] as String : null,
      data: map['data'] as dynamic,
      traceId: map['traceId'] != null ? map['traceId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseResponse.fromJson(String source) =>
      BaseResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BaseResponse(code: $code, msg: $msg, data: $data, traceId: $traceId)';
  }

  @override
  bool operator ==(covariant BaseResponse other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.msg == msg &&
        other.data == data &&
        other.traceId == traceId;
  }

  @override
  int get hashCode {
    return code.hashCode ^ msg.hashCode ^ data.hashCode ^ traceId.hashCode;
  }
}
