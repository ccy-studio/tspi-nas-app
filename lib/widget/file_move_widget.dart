import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tspi_nas_app/api/api_map.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/stream_util.dart';

const _dataLineList = "_dataLineList";

class FileMoveWidget extends StatefulWidget {
  final FileObjectModel fileRoot;
  final Function(FileObjectModel) onSelectCall;

  const FileMoveWidget({
    super.key,
    required this.fileRoot,
    required this.onSelectCall,
  });

  @override
  State<FileMoveWidget> createState() => _FileMoveWidgetState();
}

class _FileMoveWidgetState extends State<FileMoveWidget> with MultDataLine {
  final List<FileObjectModel> _rows = List.empty(growable: true);

  final List<FileObjectModel> _trees = [];

  @override
  void initState() {
    _trees.add(widget.fileRoot);
    Future.delayed(Duration.zero).then((value) {
      _onLoadFileDir();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    LogUtil.logDebug("_FileMoveWidgetState dispose()");
  }

  void _onLoadFileDir() {
    ApiMap.getFileObjectList(pageNum: 1, pageSize: -1, parentId: _trees.last.id)
        .then((value) {
      _rows.clear();
      _rows.addAll(value.rows.where((element) => element.isDir).toList());
      getLine(_dataLineList).setData(_rows, filterIdentical: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BackButton(
                onPressed: _onBackClick,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: getLine(_dataLineList, initData: _rows)
                      .addObserver((context, pack) => Text(
                            _trees.last.fileName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ))),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: getLine(_dataLineList, initData: _rows)
                  .addObserver((context, pack) => ListView.builder(
                      itemCount: pack.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            _trees.add(pack.data![index]);
                            _onLoadFileDir();
                          },
                          leading: svg(name: "file_types/floder", height: 26),
                          title: Text(
                            pack.data![index].fileName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }))),
          Center(
            child: TextButton.icon(
                onPressed: _onSelectClick,
                icon: const Icon(Icons.done),
                label: const Text("确定")),
          )
        ],
      ),
    );
  }

  void _onSelectClick() {
    widget.onSelectCall(_trees.last);
    context.pop();
  }

  void _onBackClick() {
    if (_trees.length > 1) {
      _trees.removeLast();
      _onLoadFileDir();
    } else {
      context.pop();
    }
  }
}
