import "package:tspi_nas_app/model/base_response.dart";
import "package:tspi_nas_app/model/buckets_model.dart";
import "package:tspi_nas_app/model/file_object_model.dart";
import "package:tspi_nas_app/model/page_model.dart";
import "package:tspi_nas_app/model/user_info_model.dart";
import "package:tspi_nas_app/utils/object_util.dart";
import "package:tspi_nas_app/utils/sp_util.dart";

import "../utils/http_util.dart";

class ApiMap {
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
}
