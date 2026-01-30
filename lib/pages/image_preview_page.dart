import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<String> urls; // 改为接收列表

  final int initialIndex; // 初始显示的索引

  // 提供两个构造方法方便调用
  const ImagePreviewPage(
      {super.key, required this.urls, required this.initialIndex});

  // 方便单图调用的工厂构造
  factory ImagePreviewPage.single({required String url}) {
    return ImagePreviewPage(urls: [url], initialIndex: 0);
  }

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  double _dragOffset = 0.0;
  double _opacity = 1.0;
  bool _showUI = false;
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // 背景颜色随下拉透明度变化
      backgroundColor: CupertinoColors.black.withValues(alpha: _opacity),
      child: Stack(
        children: [
          // 1. 图片层（支持单图预览或列表滑动预览）
          GestureDetector(
            onTap: () {
              setState(() {
                _showUI = !_showUI; // 点击切换 UI 显示
              });
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dy;
                _opacity = (1 - (_dragOffset / 300)).clamp(0.0, 1.0);
              });
            },
            onVerticalDragEnd: (details) {
              // 增加一个判断：如果下拉速度很快，或者偏移量足够
              if (_dragOffset > 150 || details.primaryVelocity! > 500) {
                // 触发退出
                Get.back();
              } else {
                // 弹性回滚动画
                setState(() {
                  _dragOffset = 0.0;
                  _opacity = 1.0;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(0, _dragOffset > 0 ? _dragOffset : 0),
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: widget.urls[index].startsWith('http')
                        ? CachedNetworkImageProvider(widget.urls[index],
                            cacheKey: widget.urls[index].split('?').first)
                        : FileImage(File(widget.urls[index])),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 10,
                  );
                },
                itemCount: widget.urls.length,
                loadingBuilder: (context, event) =>
                    const Center(child: CupertinoActivityIndicator()),
                backgroundDecoration:
                    const BoxDecoration(color: CupertinoColors.transparent),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),

          // 2. 顶部导航栏层
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showUI ? 0 : -100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showUI ? 1.0 : 0.0,
              child: CupertinoNavigationBar(
                backgroundColor: Color.fromRGBO(0, 0, 0, _opacity * 0.5),
                // 如果是多图，显示进度 (1/5)，单图只显示“图片预览”
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
    );
  }
}
