import 'package:flutter/material.dart';
import 'package:tspi_nas_app/utils/log_util.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    LogUtil.logInfo("Init");
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    LogUtil.logInfo("Stop");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("MyPage"),
      ),
    );
  }
}
