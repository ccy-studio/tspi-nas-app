import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/app/file_router_entity.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/pages/buckets_page.dart';
import 'package:tspi_nas_app/pages/files_page.dart';
import 'package:tspi_nas_app/pages/index.dart';
import 'package:tspi_nas_app/pages/login_page.dart';
import 'package:tspi_nas_app/pages/my_page.dart';
import 'package:tspi_nas_app/pages/preview_image.dart';
import 'package:tspi_nas_app/pages/setting_page.dart';
import 'package:tspi_nas_app/pages/share_page.dart';
import 'package:tspi_nas_app/pages/task_page.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';

///Nav导航Tab页面子路由
final _navTabPagerRouter = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return IndexHomePage(
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(routes: [
        GoRoute(
            path: "/",
            builder: (context, state) => const BucketsPage(),
            routes: [
              GoRoute(
                  path: "file",
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                        child: FileObjectPage(
                          routrerData: state.extra as FileRoutrerDataEntity,
                        ),
                        transitionsBuilder: _anim1);
                  })
            ])
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: "/task",
          builder: (context, state) => const TaskPage(),
        )
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: "/share",
          builder: (context, state) => const SharePage(),
        )
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: "/setting",
          builder: (context, state) => const SettingPage(),
        )
      ])
    ]);

final GoRouter goRouter = GoRouter(
  navigatorKey: Application.rootNavigatorKey,
  initialLocation: '/',
  routes: [
    _navTabPagerRouter,
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/preview/image/:index',
      name: "preview-image",
      builder: (context, state) => PreviewImagePage(
        files: state.extra as List<FileObjectModel>,
        current: int.parse(state.pathParameters["index"] ?? "0"),
      ),
    ),
  ],
  redirect: (context, state) async {
    if (state.path != '/login' &&
        context.read<GlobalStateProvider>().currentUser == null) {
      if ((await SpUtil.getToken()) != null) {
        try {
          EasyLoading.showInfo("正在请求服务器...", dismissOnTap: false);
          var resp = await ApiMap.getCurrentUserInfo();
          if (context.mounted) {
            context.read<GlobalStateProvider>().setUserInfo(resp);
          } else {
            return "/login";
          }
          EasyLoading.dismiss();
          return null;
        } catch (e, stackTrace) {
          LogUtil.logError("Router守卫获取用户信息错误: $e, \n堆栈信息:$stackTrace");
          SpUtil.cleanToken();
          EasyLoading.dismiss();
          ToastUtil.show(msg: e);
        }
      }
      return "/login";
    }
    return null;
  },
);

Widget _anim1(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  // return FadeThroughTransition(
  //   fillColor: Theme.of(context).scaffoldBackgroundColor,
  //   animation: animation,
  //   secondaryAnimation: secondaryAnimation,
  //   child: child,
  // );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}
