import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/pages/buckets_page.dart';
import 'package:tspi_nas_app/pages/index.dart';
import 'package:tspi_nas_app/pages/login_page.dart';
import 'package:tspi_nas_app/pages/my_page.dart';
import 'package:tspi_nas_app/pages/setting_page.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
        )
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: "/my",
          builder: (context, state) => const MyPage(),
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
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    _navTabPagerRouter,
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
  redirect: (context, state) async {
    Application.context = context;
    if (state.path != '/login' &&
        context.read<GlobalStateProvider>().currentUser == null) {
      if ((await SpUtil.getToken()) != null) {
        try {
          EasyLoading.showInfo("正在请求服务器...", dismissOnTap: false);
          var resp = await ApiMap.getCurrentUserInfo();
          Application.context.read<GlobalStateProvider>().setUserInfo(resp);
          EasyLoading.dismiss();
          return null;
        } catch (e) {
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
