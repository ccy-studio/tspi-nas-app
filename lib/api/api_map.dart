import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:tspi_nas_app/application.dart";
import "package:tspi_nas_app/model/base_response.dart";
import "package:tspi_nas_app/model/buckets_model.dart";
import "package:tspi_nas_app/model/file_object_model.dart";
import "package:tspi_nas_app/model/file_share_model.dart";
import "package:tspi_nas_app/model/file_sign_model.dart";
import "package:tspi_nas_app/model/page_model.dart";
import "package:tspi_nas_app/model/user_info_model.dart";
import "package:tspi_nas_app/provider/global_state.dart";
import "package:tspi_nas_app/utils/object_util.dart";
import "package:tspi_nas_app/utils/sp_util.dart";
import "package:tspi_nas_app/utils/time.dart";
import "package:uuid/uuid.dart";

import "../utils/http_util.dart";

class ApiMap {
  static const _uuid = Uuid();

  ///登录系统
  static Future<BaseResponse> login(String username, String password) {
    return HttpUtil.request("/sys/login", "POST",
        data: {"account": username, "password": md5Str(password)});
  }

  ///获取当前登录的用户信息
  static Future<UserInfoModel> getCurrentUserInfo() async {
    if ((await SpUtil.getToken()) == null) {
      throw Exception("未登录");
    }
    var resp = await HttpUtil.request("/sys/current-user", "get");
    return UserInfoModel.fromMap(resp.data);
  }

  ///返回当前用户的存储桶
  static Future<List<BucketsModel>> getUserBucketAll({String? query}) async {
    var resp = await HttpUtil.request("/fs/buckets", "get",
        urlParams: true, data: {"keyword": query, "displayPermission": true});
    return (resp.data as List).map((e) => BucketsModel.fromMap(e)).toList();
  }

  ///返回文件列表数据
  static Future<PageModel<FileObjectModel>> getFileObjectList(
      {int? parentId,
      int? pageNum = 1,
      int? pageSize = 20,
      String? gotoPath,
      String? searchName}) async {
    var resp =
        await HttpUtil.request("/fs/object", "get", urlParams: true, data: {
      "current": pageNum,
      "size": pageSize,
      "gotoPath": gotoPath,
      "searchName": searchName,
      "parentId": parentId
    });
    return PageModel<FileObjectModel>.fromMap(
        resp.data, (v) => FileObjectModel.fromMap(v));
  }

  ///文件复制
  static Future<bool> copyFile(
      {required int fileObjectId, required int targetId}) async {
    return HttpUtil.request("/fs/object/copy", "put", data: {
      "objectId": fileObjectId,
      "targetObject": targetId,
      "isOverwrite": true
    }).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///文件移动
  static Future<bool> moveFile(
      {required int fileObjectId, required int targetId}) async {
    return HttpUtil.request("/fs/object/move", "put", data: {
      "objectId": fileObjectId,
      "targetObject": targetId,
      "isOverwrite": false
    }).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///文件重命名
  static Future<bool> renameFile(
      {required int fileObjectId, required String newName}) async {
    return HttpUtil.request("/fs/object/rename", "put", data: {
      "objectId": fileObjectId,
      "newName": newName,
    }).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///文件删除
  static Future<bool> deleteFile({required int fileObjectId}) async {
    return HttpUtil.request("/fs/object", "delete",
        data: {"objectId": fileObjectId}).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///新建文件夹
  static Future<bool> mkdir(
      {required int parentId, required String fileName}) async {
    return HttpUtil.request("/fs/object/folder", "put", data: {
      "targetFolder": parentId,
      "fileName": fileName,
      "isOverwrite": false
    }).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///检查文件是否存在
  static Future<bool> hasFile(
      {required int parentId, required String fileName}) async {
    return HttpUtil.request("/fs/object/has", "get",
        urlParams: true,
        data: {"targetFolder": parentId, "fileName": fileName}).then((value) {
      return true;
    }).catchError((e, stack) {
      return false;
    });
  }

  ///获取下载文件的临时签名
  static Future<FileObjectSignModel> getDownloadFileSignInfo(
      {required int objectId}) async {
    return HttpUtil.request("/fs/sign/download", "post",
        data: {"objectId": objectId, "uuid": _uuid.v4()}).then((value) {
      return FileObjectSignModel.fromMap(value.data);
    });
  }

  ///获取上传文件的临时签名
  static Future<FileObjectSignModel> getUploadFileSignInfo(
      {required int objectId}) async {
    return HttpUtil.request("/fs/sign/upload", "post",
        data: {"objectId": objectId, "uuid": _uuid.v4()}).then((value) {
      return FileObjectSignModel.fromMap(value.data);
    });
  }

  ///返回构造预览的url+参数
  static Future<String> generatorDoanloadParams(
      {required int objectId, required BuildContext context}) async {
    var sign = await getDownloadFileSignInfo(objectId: objectId);
    var query = Transformer.urlEncodeMap({
      "X-SIGN": sign.signString,
      "account": context.read<GlobalStateProvider>().currentUser!.userAccount,
      "bucketId": "${sign.bkId}",
      "objectId": "${sign.objectId}",
      "uuid": sign.uuid,
      "expire": "${sign.expireTime}",
    });
    return "${Application.BASE_URL}/file/s/download?$query";
  }

  ///创建文件外链分享
  static Future<FileShareInfoVo> createFileObjectShare(
      {required int objectId, required int exprie, required String pwd}) async {
    String? exprieStr;
    if (exprie > 0) {
      exprieStr =
          DateUtil.formatDate(DateTime.now().add(Duration(days: exprie)));
    }
    return HttpUtil.request("/fs/share", "post", data: {
      "objectId": objectId,
      "expirationTime": exprieStr,
      "accessPassword": pwd,
      "symlink": true
    }).then((value) {
      return FileShareInfoVo.fromMap(value.data);
    });
  }

  ///删除一个分享通过ID
  static Future<void> deleteFileObjectShare({required int id}) async {
    return HttpUtil.request("/fs/share", "delete", data: {
      "id": id,
    }).then((value) {
      return;
    });
  }

  ///获取用户的创建分享数据
  static Future<PageModel<FileShareInfoVo>> getFileObjectShareAll({
    String? fileName,
    int? pageNum = 1,
    int? pageSize = 20,
  }) async {
    return HttpUtil.request("/fs/share", "get", data: {"fileName": fileName})
        .then((value) {
      return PageModel<FileShareInfoVo>.fromMap(
          value.data, (v) => FileShareInfoVo.fromMap(v));
    });
  }

  ///转换获取分享的直链URL访问地址
  static String getShareSymlinkUrl(FileShareInfoVo infoVo) {
    return "${Application.BASE_URL}/share/object/${infoVo.signKey}";
  }
}
