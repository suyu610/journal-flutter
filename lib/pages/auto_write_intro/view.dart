import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class AutowriteintroPage extends GetView<AutowriteintroController> {
  const AutowriteintroPage({super.key});

  // 主视图
  Widget _buildView() {
    return const Center(
      child: Text("AutowriteintroPage"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AutowriteintroController>(
      init: AutowriteintroController(),
      id: "autowriteintro",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xffF3F3F3),
          appBar: AppBar(
              title: const Text(
            "自动记账",
            style: TextStyle(fontSize: 16),
          )),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
