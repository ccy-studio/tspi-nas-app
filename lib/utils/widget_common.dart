import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

///Toast工具类
class ToastUtil {
  static show({@required dynamic msg, Toast length = Toast.LENGTH_SHORT}) {
    if (!(msg is String)) {
      msg = msg.toString();
    }
    Fluttertoast.showToast(
        msg: msg,
        textColor: Colors.white,
        backgroundColor: Colors.black54,
        gravity: ToastGravity.BOTTOM,
        toastLength: length);
  }
}

///对话框工具类
class DialogUtil {
  static bool _isLoading = false;

  ///显示一个Alert 提示框
  static void showAlertMessageDialog(BuildContext context, String message,
      {Function? call, String title = "提示"}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: "确认",
      dismissOnTouchOutside: true,
      btnOkOnPress: () {
        if (call != null) {
          call();
        }
      },
    ).show();
  }

  ///弹出一个询问框
  static void showConfirmDialog(BuildContext context, String message,
      {Function? ok,
      Function? cancel,
      String okText = "确定",
      String cancenText = "取消",
      String title = "提示"}) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: title,
        desc: message,
        btnOkText: okText,
        btnCancelText: cancenText,
        dismissOnTouchOutside: true,
        btnOkOnPress: () {
          if (ok != null) {
            ok();
          }
        },
        btnCancelOnPress: () {
          if (cancel != null) {
            cancel();
          }
        }).show();
  }

  ///打开加载对话框
  static void showLoading(BuildContext context, String msg,
      {bool barrierDismissible = true}) {
    if (_isLoading) {
      Navigator.pop(context);
    }
    _isLoading = true;
    showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return UnconstrainedBox(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2 + 50,
              child: CupertinoAlertDialog(
                content: Column(
                  children: [
                    const CupertinoActivityIndicator(
                      animating: true,
                      radius: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(msg),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showSmallLoading(BuildContext context) {
    if (_isLoading) {
      Navigator.pop(context);
    }
    _isLoading = true;
    double size = MediaQuery.of(context).size.width / 2;
    showDialog(
        context: context,
        builder: (context) {
          return UnconstrainedBox(
            child: SizedBox(
              width: size,
              child: AlertDialog(
                content: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          );
        });
  }

  ///关闭加载对话框
  static void closeLoading(BuildContext context) {
    if (_isLoading) {
      Navigator.pop(context);
      _isLoading = false;
    }
  }

  ///只是设置为flag为关闭
  static void closeLoadingFlag() {
    _isLoading = false;
  }

  //显示一个输入框
  static void showInputDialog(BuildContext context,
      {Function(String value)? call,
      bool Function(String value)? validate,
      String title = "提示",
      String? placeholder,
      DialogType dialogType = DialogType.question,
      String? initVal}) {
    TextEditingController editingController = TextEditingController();
    if (initVal != null && initVal.isNotEmpty) {
      editingController.text = initVal;
    }
    AwesomeDialog(
        context: context,
        dialogType: dialogType,
        animType: AnimType.scale,
        title: title,
        btnOkText: "提交",
        btnCancelText: "取消",
        dismissOnTouchOutside: true,
        dismissOnBackKeyPress: true,
        autoDismiss: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 3,
              ),
              TextField(
                autocorrect: true,
                controller: editingController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  isDense: true,
                  hintText: placeholder,
                ),
              )
            ],
          ),
        ),
        btnOkOnPress: () {
          if (editingController.text.isEmpty) {
            ToastUtil.show(msg: "请输入完整");
            return;
          }
          if (validate != null && !validate(editingController.text)) {
            return;
          }
          closeSoftKeyboardDisplay();
          if (call != null) {
            Navigator.pop(context);
            call(editingController.text);
          }
        },
        onDismissCallback: (t) {
          if (t == DismissType.btnOk) {
            return;
          }
          Navigator.pop(context);
        }).show();
  }
}

///判断是否显示了软键盘
bool isSoftKeyboardDisplay(MediaQueryData data) {
  return data.viewInsets.bottom / data.size.height > 0.3;
}

///收起软键盘
void closeSoftKeyboardDisplay() {
  FocusManager.instance.primaryFocus?.unfocus();
}

///设置状态栏的颜色
void setUiOverlayStyle(Brightness color) {
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarBrightness: color,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}
