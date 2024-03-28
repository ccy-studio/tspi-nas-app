import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tspi_nas_app/application.dart';
import 'package:tspi_nas_app/model/file_object_model.dart';
import 'package:tspi_nas_app/provider/global_state.dart';
import 'package:tspi_nas_app/utils/icon_util.dart';
import 'package:tspi_nas_app/utils/log_util.dart';
import 'package:tspi_nas_app/utils/sp_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PreviewImagePage extends StatefulWidget {
  final List<FileObjectModel> files;
  final int current;

  const PreviewImagePage(
      {super.key, required this.files, required this.current});

  @override
  State<PreviewImagePage> createState() => _PreviewImagePageState();
}

class _PreviewImagePageState extends State<PreviewImagePage> {
  final Map<String, String> _headers = {};

  int currentIndex = 0;

  late ExtendedPageController pageController;

  @override
  void initState() {
    currentIndex = widget.current;
    pageController = ExtendedPageController(initialPage: widget.current);
    SpUtil.getToken().then((value) {
      _headers["X-AUTH-TYPE"] = "token";
      _headers["Authorization"] = value ?? "";
      _headers["X-BK"] = "${context.read<GlobalStateProvider>().getBId}";
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.black87,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButton(
              color: Colors.white,
            ),
            Expanded(
              child: ExtendedImageSlidePage(
                slideAxis: SlideAxis.both,
                slideType: SlideType.onlyImage,
                child: ExtendedImageGesturePageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var item = widget.files[index];
                    Widget image = ExtendedImage.network(
                      "${Application.BASE_URL}/fs/preview?objectId=${item.id}",
                      headers: _headers,
                      enableSlideOutPage: true,
                      fit: BoxFit.contain,
                      imageCacheName: item.filePath,
                      mode: ExtendedImageMode.gesture,
                      enableLoadState: true,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return const Center(
                              child: SpinKitPouringHourGlassRefined(
                                  color: Colors.white),
                            );
                          case LoadState.completed:
                            return null;
                          case LoadState.failed:
                            return Center(
                                child: svg(
                                    name: "img_load_fail",
                                    height: MediaQuery.of(context).size.height /
                                        2));
                        }
                      },
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                          minScale: 0.9,
                          animationMinScale: 0.7,
                          maxScale: 3.0,
                          animationMaxScale: 3.5,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: true,
                          cacheGesture: true,
                          initialAlignment: InitialAlignment.center,
                        );
                      },
                    );
                    image = Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: image,
                      ),
                    );
                    if (index == currentIndex) {
                      return Hero(
                        tag: item.filePath + index.toString(),
                        child: image,
                      );
                    } else {
                      return image;
                    }
                  },
                  itemCount: widget.files.length,
                  onPageChanged: (int index) {
                    currentIndex = index;
                    // rebuild.add(index);
                  },
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
