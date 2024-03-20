// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

///存储桶实体类
class BucketsModel {
  ///ID
  int id;

  ///桶名
  String bucketsName;

  ///挂载点路径
  String? mountPoint;

  ///资源ID
  int resId;

  int rootFolderId;

  ///创建时间
  String createTime;

  ///用户的ACL
  BucketsAclModel acl;

  BucketsModel({
    required this.id,
    required this.bucketsName,
    this.mountPoint,
    required this.resId,
    required this.rootFolderId,
    required this.createTime,
    required this.acl,
  });

  BucketsModel copyWith({
    int? id,
    String? bucketsName,
    String? mountPoint,
    int? resId,
    int? rootFolderId,
    String? createTime,
    BucketsAclModel? acl,
  }) {
    return BucketsModel(
      id: id ?? this.id,
      bucketsName: bucketsName ?? this.bucketsName,
      mountPoint: mountPoint ?? this.mountPoint,
      resId: resId ?? this.resId,
      rootFolderId: rootFolderId ?? this.rootFolderId,
      createTime: createTime ?? this.createTime,
      acl: acl ?? this.acl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bucketsName': bucketsName,
      'mountPoint': mountPoint,
      'resId': resId,
      'rootFolderId': rootFolderId,
      'createTime': createTime,
      'acl': acl.toMap(),
    };
  }

  factory BucketsModel.fromMap(Map<String, dynamic> map) {
    return BucketsModel(
      id: map['id'] as int,
      bucketsName: map['bucketsName'] as String,
      mountPoint:
          map['mountPoint'] != null ? map['mountPoint'] as String : null,
      resId: map['resId'] as int,
      rootFolderId: map['rootFolderId'] as int,
      createTime: map['createTime'] as String,
      acl: BucketsAclModel.fromMap(map['acl'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory BucketsModel.fromJson(String source) =>
      BucketsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BucketsModel(id: $id, bucketsName: $bucketsName, mountPoint: $mountPoint, resId: $resId, rootFolderId: $rootFolderId, createTime: $createTime, acl: $acl)';
  }

  @override
  bool operator ==(covariant BucketsModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.bucketsName == bucketsName &&
        other.mountPoint == mountPoint &&
        other.resId == resId &&
        other.rootFolderId == rootFolderId &&
        other.createTime == createTime &&
        other.acl == acl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bucketsName.hashCode ^
        mountPoint.hashCode ^
        resId.hashCode ^
        rootFolderId.hashCode ^
        createTime.hashCode ^
        acl.hashCode;
  }
}

///用户桶的权限
class BucketsAclModel {
  int bucketsId;
  bool read;
  bool write;
  bool delete;
  bool share;
  bool manage;
  BucketsAclModel({
    required this.bucketsId,
    required this.read,
    required this.write,
    required this.delete,
    required this.share,
    required this.manage,
  });

  BucketsAclModel copyWith({
    int? bucketsId,
    bool? read,
    bool? write,
    bool? delete,
    bool? share,
    bool? manage,
  }) {
    return BucketsAclModel(
      bucketsId: bucketsId ?? this.bucketsId,
      read: read ?? this.read,
      write: write ?? this.write,
      delete: delete ?? this.delete,
      share: share ?? this.share,
      manage: manage ?? this.manage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bucketsId': bucketsId,
      'read': read,
      'write': write,
      'delete': delete,
      'share': share,
      'manage': manage,
    };
  }

  factory BucketsAclModel.fromMap(Map<String, dynamic> map) {
    return BucketsAclModel(
      bucketsId: map['bucketsId'] ?? 0,
      read: map['read'] as bool,
      write: map['write'] as bool,
      delete: map['delete'] as bool,
      share: map['share'] as bool,
      manage: map['manage'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory BucketsAclModel.fromJson(String source) =>
      BucketsAclModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BucketsAclModel(bucketsId: $bucketsId, read: $read, write: $write, delete: $delete, share: $share, manage: $manage)';
  }

  @override
  bool operator ==(covariant BucketsAclModel other) {
    if (identical(this, other)) return true;

    return other.bucketsId == bucketsId &&
        other.read == read &&
        other.write == write &&
        other.delete == delete &&
        other.share == share &&
        other.manage == manage;
  }

  @override
  int get hashCode {
    return bucketsId.hashCode ^
        read.hashCode ^
        write.hashCode ^
        delete.hashCode ^
        share.hashCode ^
        manage.hashCode;
  }
}
