import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IndexHomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const IndexHomePage({super.key, required this.navigationShell});

  @override
  State<IndexHomePage> createState() => _IndexHomePageState();
}

class _IndexHomePageState extends State<IndexHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.storage_rounded, title: '存储'),
          // TabItem(icon: Icons.history, title: '最近'),
          TabItem(icon: Icons.account_circle_rounded, title: '我的'),
          TabItem(icon: Icons.settings, title: '设置'),
        ],
        onTap: _onTap,
      ),
      body: widget.navigationShell,
    );
  }

  void _onTap(index) {
    widget.navigationShell.goBranch(index,
        initialLocation: index == widget.navigationShell.currentIndex);
  }
}
