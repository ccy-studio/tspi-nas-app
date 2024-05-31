import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/model/user_info_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';
import 'package:tspi_nas_app/widget/text_head_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextHedaerWidget(
          title: "设置",
          expand: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: _logout,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                label: const Text(
                  "退出登录",
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                )),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 30,
                  child: Text(
                    context
                            .select<GlobalStateProvider, UserInfoModel?>(
                                (value) => value.currentUser)
                            ?.nickName
                            ?.substring(0, 1) ??
                        "-",
                    style: const TextStyle(
                        fontSize: 30 * 1.2, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Center(
                child: Text(
                  "昵称: ${context.select<GlobalStateProvider, String?>((value) => value.currentUser?.nickName ?? value.currentUser?.userAccount ?? "-")}",
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox.fromSize(
                size: const Size.fromHeight(20),
              ),
              const ListTile(
                title: Text("泰山派轻NAS"),
              ),
              const ListTile(
                title: Text("GPL3.0 开源协议"),
                subtitle:
                    Text("Github: https://github.com/ccy-studio/tspi-nas-app"),
              ),
              const ListTile(
                title: Text("立创开源地址"),
                subtitle:
                    Text("https://oshwhub.com/yc_chen/taishan-nas-server"),
              ),
              const ListTile(
                title: Text("版本"),
                subtitle: Text("Bate V1.0"),
              )
            ],
          ),
        ))
      ],
    );
  }

  void _logout() {
    DialogUtil.showConfirmDialog(context, "您确定要退出登录吗?", ok: () {
      context.read<GlobalStateProvider>().setUserInfo(null);
      context.read<GlobalStateProvider>().setBuckets([]);
      SpUtil.cleanToken();
      context.go("/login");
    });
  }
}
