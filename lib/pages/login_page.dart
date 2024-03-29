import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/base_response.dart';
import 'package:tspi_nas_app/model/user_info_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/http_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final account = TextEditingController();
  final pwd = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    SpUtil.getVal("account").then((value) {
      var val = value?["account"];
      if (val != null) {
        account.value = TextEditingValue(text: val);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    account.dispose();
    pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            // alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  onPressed: _openSetting,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "油条云轻NAS",
                      style: TextStyle(color: Colors.black, fontSize: 32),
                    ),
                    const Text("登录后继续体验",
                        style: TextStyle(color: Colors.black45, fontSize: 12)),
                    const SizedBox(height: 60.0),
                    Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              autocorrect: false,
                              style: const TextStyle(fontSize: 13),
                              controller: account,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1)),
                                hintText: "用户名",
                                icon: const Icon(Icons.person),
                              ),
                              // 校验用户名
                              validator: (v) {
                                return v!.trim().isNotEmpty ? null : "用户名不能为空";
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              autocorrect: false,
                              style: const TextStyle(fontSize: 13),
                              controller: pwd,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1)),
                                hintText: "您的登录密码",
                                icon: const Icon(Icons.lock),
                              ),
                              obscureText: true,
                              //校验密码
                              validator: (v) {
                                return v!.trim().isNotEmpty ? null : "密码不能为空";
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 30.0),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 3 * 2,
                        child: ElevatedButton(
                          onPressed: _onLoginClick,
                          child: const Text("登录"),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox())
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  void _openSetting() async {
    SpUtil.getBaseUrl().then((value) => {
          DialogUtil.showInputDialog(
            context,
            initVal: value,
            placeholder: "输入NAS服务器Http路径",
            validate: (value) {
              if (!value.trim().startsWith("http")) {
                ToastUtil.show(msg: "请以http开头");
                return false;
              }
              return true;
            },
            call: (value) {
              SpUtil.setBaseUrl(value.trim());
              Application.BASE_URL = value;
              HttpUtil.baseReqest.options.baseUrl = value;
            },
          )
        });
  }

  void _onLoginClick() {
    closeSoftKeyboardDisplay();
    if ((_formKey.currentState as FormState).validate()) {
      //验证通过提交数据
      EasyLoading.show(
        status: '登录中...',
        dismissOnTap: true,
      );
      ApiMap.login(account.text, pwd.text).then((value) {
        var userInfo = UserInfoModel.fromMap(value.data["userInfo"]);
        var token = value.data["tokenPair"]["accessToken"];
        SpUtil.setToken(token);
        context.read<GlobalStateProvider>().setUserInfo(userInfo);
        //保存用户名
        SpUtil.save("account", {"account": account.text});
        LogUtil.logInfo("UserInfo:$userInfo,Token:$token");
        EasyLoading.dismiss();
        context.go("/");
      }).catchError((e) {
        LogUtil.logError("Error:$e");
        EasyLoading.dismiss();
        ToastUtil.show(msg: (e as BaseResponse).msg);
      });
    }
  }
}
