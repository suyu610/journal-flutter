// ignore_for_file: depend_on_referenced_packages, use_key_in_widget_constructors, must_be_immutable, no_leading_underscores_for_local_identifiers


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var url = Get.arguments['url'];
    var title = Get.arguments['title'];
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    // 加载网页
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(url));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BrnAppBar(title: title),
      body: GestureDetector(
          onLongPressStart: (LongPressStartDetails longPress) async {
            String imgUrl =
                'document.elementFromPoint(${longPress.localPosition.dx}, ${longPress.localPosition.dy}).src';
            controller.runJavaScriptReturningResult(imgUrl).then((value) async {
              String _value = value.toString().replaceAll("\"", "");
              if (_value.isNotEmpty) {
                // Log().d('我获取到了====$_value');
                // List<String> itemList = ["保存图片", "转发到微信"];

                // ToastUtil.showBottomSheet(context, itemList, (index) {
                //   if (index == 0) {
                //     Log().d("index:$index");
                //     // 保存图片
                //     saveImage(_value);
                //   }

                //   if (index == 1) {
                //     Navigator.pop(context);
                //     fluwx.share(WeChatShareImageModel(
                //         WeChatImage.network(_value),
                //         scene: WeChatScene.session,
                //         title: "图片分享"));
                //   }
                // });
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: WebViewWidget(controller: controller),
          )),
    );
  }

  // ignore: unused_element
  // _initFluwx() async {
  //   await fluwx.registerApi(
  //     appId: 'wx2f6af8ec967dde40',
  //     doOnAndroid: true,
  //     doOnIOS: true,
  //     universalLink: 'https://static.vigolive.cn/links/',
  //   );
  //   await fluwx.isWeChatInstalled;
  // }

  // Future<void> saveImage(String url) async {
  //   final http.Response response = await http.get(Uri.parse(url));
  //   Random random = Random();
  //   // 获取临时的文件夹
  //   final dir = await getTemporaryDirectory();

  //   // 创建一个图像名称
  //   var filename = '${dir.path}/SaveImage${random.nextInt(100)}.png';

  //   // 保存到文件系统
  //   final file = File(filename);
  //   await file.writeAsBytes(response.bodyBytes);

  //   // 询问用户是否保存它
  //   final params = SaveFileDialogParams(sourceFilePath: file.path);
  //   final filePath = await FlutterFileDialog.saveFile(params: params);

  //   if (filePath != null) {
  //     ToastUtil.show(msg: 'Image saved to disk');
  //   }
  // }
}
