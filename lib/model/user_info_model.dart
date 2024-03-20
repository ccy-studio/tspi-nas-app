// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserInfoModel {
  int id;
  String userAccount;
  String? nickName;
  String? mobile;
  String? accessKey;
  String? createTime;

  UserInfoModel({
    required this.id,
    required this.userAccount,
    this.nickName,
    this.mobile,
    this.accessKey,
    this.createTime,
  });

  UserInfoModel copyWith({
    int? id,
    String? userAccount,
    String? nickName,
    String? mobile,
    String? accessKey,
    String? createTime,
  }) {
    return UserInfoModel(
      id: id ?? this.id,
      userAccount: userAccount ?? this.userAccount,
      nickName: nickName ?? this.nickName,
      mobile: mobile ?? this.mobile,
      accessKey: accessKey ?? this.accessKey,
      createTime: createTime ?? this.createTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userAccount': userAccount,
      'nickName': nickName,
      'mobile': mobile,
      'accessKey': accessKey,
      'createTime': createTime,
    };
  }

  factory UserInfoModel.fromMap(Map<String, dynamic> map) {
    return UserInfoModel(
      id: map['id'] as int,
      userAccount: map['userAccount'] as String,
      nickName: map['nickName'] != null ? map['nickName'] as String : null,
      mobile: map['mobile'] != null ? map['mobile'] as String : null,
      accessKey: map['accessKey'] != null ? map['accessKey'] as String : null,
      createTime:
          map['createTime'] != null ? map['createTime'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromJson(String source) =>
      UserInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserInfoModel(id: $id, userAccount: $userAccount, nickName: $nickName, mobile: $mobile, accessKey: $accessKey, createTime: $createTime)';
  }

  @override
  bool operator ==(covariant UserInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userAccount == userAccount &&
        other.nickName == nickName &&
        other.mobile == mobile &&
        other.accessKey == accessKey &&
        other.createTime == createTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userAccount.hashCode ^
        nickName.hashCode ^
        mobile.hashCode ^
        accessKey.hashCode ^
        createTime.hashCode;
  }
}
