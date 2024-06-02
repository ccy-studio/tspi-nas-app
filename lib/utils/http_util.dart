import "package:dio/dio.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/common/global_event.dart';
import 'package:tspi_nas_app/model/base_response.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';

class HttpUtil {
  static final _log = Logger(level: Level.all);

  static final _http = Dio(BaseOptions(
    baseUrl: Application.BASE_URL,
    connectTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers["X-AUTH-TYPE"] = "token";
        options.headers["Authorization"] = await SpUtil.getToken();
        options.headers["X-BK"] = Application.currentContext != null
            ? Provider.of<GlobalStateProvider>(Application.currentContext!,
                    listen: false)
                .getBId
            : "";
        _log.i(
            "--->Request: Url${options.path} Method:${options.method},Params:${options.queryParameters},Data:${options.data}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        _log.i(
            "--->Resonse: Path:${response.requestOptions.path} Data:${response.data}");
        if (response.data != null && response.data is Map) {
          var code = response.data["code"];
          //获取错误码，判断错误类型
          if (code != null) {
            if (code == 4001 || code == 4002 || code == 4003) {
              //跳转登录页
              SpUtil.cleanToken();
              Application.currentContext!
                  .read<GlobalStateProvider>()
                  .setUserInfo(null);
              EasyLoading.showToast("登录过期请");
              Application.currentContext!.go("/login");
            } else if (code == 40003 || code == 50000) {
              EasyLoading.showToast("没有权限");
              Application.globalEventBus.fire(EventPermisionChange());
            } else if (code == 40001) {
              EasyLoading.showToast("文件对象不存在");
            } else if (code == 5002) {
              EasyLoading.showToast("此数据拒绝操作");
            }
          }
        }
        handler.next(response);
      },
      onError: (error, handler) {
        _log.e("DioError请求错误Resp内容: ${error.response?.data}");
        handler.reject(error);
      },
    ));

  ///进行Post的请求
  static Future<BaseResponse> request(String url, String method,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? headers,
      bool urlParams = false,
      CancelToken? cancelToken}) async {
    try {
      var response = await _http.request(url,
          data: !urlParams ? data : null,
          cancelToken: cancelToken,
          queryParameters: urlParams ? data : null,
          options: Options(method: method, headers: headers));
      var resp = BaseResponse.fromMap(response.data);
      if (resp.code != 200) {
        return Future.error(resp);
      }
      return resp;
    } catch (e) {
      _log.e("请求异常：$e");
      return Future.error(BaseResponse(code: 500, msg: "系统请求异常"));
    }
  }

  static Dio get baseReqest => _http;
}
