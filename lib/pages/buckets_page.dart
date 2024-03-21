import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/model/app/file_router_entity.dart';
import 'package:tspi_nas_app/model/buckets_model.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/stream_util.dart';
import 'package:tspi_nas_app/utils/widget_common.dart';
import 'package:tspi_nas_app/widget/search_widget.dart';
import 'package:tspi_nas_app/widget/text_head_widget.dart';

class BucketsPage extends StatefulWidget {
  const BucketsPage({super.key});

  @override
  State<BucketsPage> createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage>
    with SingleTickerProviderStateMixin, MultDataLine {
  static const _dataLineBucket = "_dataLineBucket";

  final _bucketsArr = List<BucketsModel>.empty(growable: true);

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      _reloadBuckets();
    });
    super.initState();
  }

  Future<void> _reloadBuckets() {
    closeSoftKeyboardDisplay();
    return ApiMap.getUserBucketAll().then((value) {
      _bucketsArr.clear();
      context.read<GlobalStateProvider>().setBuckets(value);
      _bucketsArr.addAll(value);
      getLine(_dataLineBucket).setData(_bucketsArr, filterIdentical: false);
      return;
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const TextHedaerWidget(
          title: "存储桶",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: SearchWidget(
            placehoder: "搜索",
            callback: (_) => closeSoftKeyboardDisplay(),
            onChange: onSearch,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        Expanded(
            child: RefreshIndicator(
                onRefresh: _reloadBuckets, child: widgetGridView()))
      ],
    );
  }

  Widget widgetGridView() {
    return getLine<List<BucketsModel>>(_dataLineBucket,
        waitWidget: Center(
          child: svg(
              name: "empty_big",
              width: MediaQuery.of(context).size.width / 3 * 2),
        )).addObserver((context, pack) {
      return GridView.builder(
          itemCount: pack.data?.length ?? 0,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            var item = pack.data![index];
            return GestureDetector(
              onTap: () => _onBucketClick(item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  svg(name: "bucket", width: 50),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    item.bucketsName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  )
                ],
              ),
            );
          });
    });
  }

  ///本地化搜索
  void onSearch(String txt) {
    if (txt.isEmpty) {
      getLine(_dataLineBucket).setData(_bucketsArr);
    } else {
      getLine(_dataLineBucket).setData(_bucketsArr
          .where((element) => element.bucketsName.contains(txt))
          .toList());
    }
  }

  void _onBucketClick(BucketsModel mode) {
    context.read<GlobalStateProvider>().setBucketId(mode.id);
    var rootFile = FileObjectModel(
        id: mode.rootFolderId, fileName: "/", filePath: "/", isDir: true);
    var data = FileRoutrerDataEntity(
        bucketsModel: mode,
        trees: [rootFile],
        levelNameList: ["/"],
        rootObject: rootFile);
    context.push("/file", extra: data);
  }
}
