import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const ImagePreviewPage({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  factory ImagePreviewPage.single({required String url}) {
    return ImagePreviewPage(urls: [url], initialIndex: 0);
  }

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late int _currentIndex;
  bool _showUI = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      // 👇 显式声明类型，并加上 ? 表示它们是可选的，完美契合底层 typedef
      slideEndHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
        ScaleEndDetails? details,
      }) {
        // offset.dy 是 Y 轴（上下）滑动的距离
        if (offset.dy.abs() > 150) {
          return true; // 退出页面
        }

        // offset.dx 是 X 轴（横向）滑动距离
        if (offset.dx.abs() > 200) {
          return true;
        }

        // 没达到距离，返回 false 触发回弹动画
        return false;
      },
      slideAxis: SlideAxis.both, // 允许全向拖拽（上下左右斜着都能拉）
      slideType: SlideType.onlyImage, // 拖拽时只让图片动，不让整个页面动（微信效果）
      onSlidingPage: (state) {
        // 当用户开始下拉拖拽时，立刻隐藏顶部导航栏
        if (state.isSliding && _showUI) {
          setState(() => _showUI = false);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent, // 背景交给 SlidePage 去控制透明度
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 2. 图片画廊层
            GestureDetector(
              onTap: () {
                setState(() => _showUI = !_showUI);
              },
              // 配合 ExtendedImageGesturePageView 使用，完美解决左右翻页手势冲突
              child: ExtendedImageGesturePageView.builder(
                itemCount: widget.urls.length,
                controller:
                    ExtendedPageController(initialPage: widget.initialIndex),
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final url = widget.urls[index];
                  final isNetwork = url.startsWith('http');

                  // 3. 构建单张可交互图片
                  return isNetwork
                      ? ExtendedImage.network(
                          url,
                          fit: BoxFit.contain,
                          mode: ExtendedImageMode.gesture, // 开启手势模式
                          enableSlideOutPage: true, // 核心：允许这张图片被下拉拖出！
                          initGestureConfigHandler: _gestureConfig,
                          loadStateChanged: _loadStateChanged,
                        )
                      : ExtendedImage.file(
                          File(url),
                          fit: BoxFit.contain,
                          mode: ExtendedImageMode.gesture,
                          enableSlideOutPage: true,
                          initGestureConfigHandler: _gestureConfig,
                        );
                },
              ),
            ),

            // 4. 顶部导航栏 UI 层
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _showUI ? 0 : -100,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showUI ? 1.0 : 0.0,
                child: CupertinoNavigationBar(
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                  middle: Text(
                    widget.urls.length > 1
                        ? '${_currentIndex + 1} / ${widget.urls.length}'
                        : '图片预览',
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.back,
                        color: CupertinoColors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureConfig _gestureConfig(ExtendedImageState state) {
    return GestureConfig(
      minScale: 0.9,
      animationMinScale: 0.7,
      maxScale: 4.0,
      animationMaxScale: 4.5,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: true,
    );
  }

  // 网络图片加载状态处理
  Widget? _loadStateChanged(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.loading) {
      return const Center(
          child: CupertinoActivityIndicator(color: Colors.white));
    }
    return null;
  }
}
