import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class AICharacter {
  String avatarUrl;
  String name;
  String description;
  bool selected = false;
  AICharacter(
      {required this.avatarUrl, required this.name, required this.description});
}

List<AICharacter> characters = [
  AICharacter(
    avatarUrl: "https://avatars.githubusercontent.com/caixuan29",
    name: "学霸姐姐",
    description:
        "聪明、勤奋、自律，学习成绩优异。她把记账也当成一种学习和管理生活的方式，非常注重细节和数据分析。她会用科学的方法帮助用户制定预算和理财计划，同时还会分享一些学习方法和时间管理技巧，鼓励用户在提升自己的同时，也能合理规划财务，实现全面发展。",
  ),
  AICharacter(
      avatarUrl: "https://avatars.githubusercontent.com/Jayclelon",
      name: "账房先生",
      description:
          "古灵精怪，对数字极为敏感，虽然看似年轻但却有着丰富的记账经验。他说话幽默风趣，常常会用一些古代的典故或者俗语来解释记账的道理，让记账这件事变得生动有趣。"),
  AICharacter(
      avatarUrl: "https://avatars.githubusercontent.com/Jayclelon",
      name: "小刚",
      description:
          "性格特点：充满活力，热情洋溢，对新鲜事物充满好奇。他用嘻哈的态度对待记账，觉得记账也可以很潮很酷。他说话幽默风趣，经常会蹦出一些流行的嘻哈词汇和段子，让记账过程变得轻松愉快。他还喜欢分享一些时尚的消费观念和理财小技巧，鼓励用户在合理规划财务的同时，也不要忘记享受生活。"),
];

class AiConfigV2Page extends GetView<AiConfigV2Controller> {
  const AiConfigV2Page({super.key});

  // 主视图
  Widget _buildView() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: TDInput(
                    backgroundColor: Colors.white,
                    maxLines: 1,
                    // leftLabelSpace: 150,
                    leftIcon: const Flex(
                      children: [
                        Text(
                          "角色称呼你为",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )
                      ],
                      direction: Axis.horizontal,
                    ),
                    leftLabelStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    hintText: "请输入角色称呼你为",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    type: TDInputType.normal,
                    contentAlignment: TextAlign.end,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 16),
                          child: Text(
                            "角色开场白为",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TDInput(
                          backgroundColor: Colors.white,
                          leftLabelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          hintText: "在此输入角色开场白",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          type: TDInputType.twoLine,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
                child: Text(
                  "角色列表",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: characters
                    .map((e) => AiCharacterItem(e, onTap: () {
                          controller.selectCharacter(e);
                        }))
                    .toList(),
              ),
              const SizedBox(height: 80,)
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: characters.length,
              //     itemBuilder: (context, index) {
              //       return AiCharacterItem(
              //         characters[index],
              //         onTap: () {
              //           controller.selectCharacter(characters[index]);
              //         },
              //       );
              //     },
              //   ),
              // )
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: TDButton(
            margin: EdgeInsets.only(top: 28.h, left: 16, right: 16),
            height: 44,
            isBlock: true,
            theme: TDButtonTheme.primary,
            text: "保存",
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget AiCharacterItem(AICharacter character, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    width: 2,
                    color: controller.selectedCharacter.value != null &&
                            controller.selectedCharacter.value!.name ==
                                character.name
                        ? const Color(0xff0052D9)
                        : const Color(0xffDCDCDC)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          character.avatarUrl,
                          height: 40.r,
                          width: 40.r,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        character.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xffF3F3F3),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                              text: TextSpan(children: <TextSpan>[
                            const TextSpan(
                                text: "性格特点：",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            TextSpan(
                                text: character.description,
                                style: const TextStyle(color: Colors.black))
                          ])),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: controller.selectedCharacter.value != null &&
                  controller.selectedCharacter.value!.name == character.name,
              child: Positioned(
                  child: CustomPaint(
                      painter: TrianglePainter(),
                      child: const Padding(
                        padding: EdgeInsets.only(
                            right: 8.0, top: 4, left: 4, bottom: 6),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ))),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiConfigV2Controller>(
      init: AiConfigV2Controller(),
      id: "ai_config_v2",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
              title: const Text("选择角色",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          body: SafeArea(
            bottom: false,
            child: _buildView(),
          ),
        );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double radius; // 圆角的半径
  TrianglePainter({this.radius = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff0052D9)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height + 10);
    path.lineTo(size.width + 8, 0);
    path.lineTo(8, 0);
    path.arcToPoint(
      const Offset(0, 8),
      radius: const Radius.circular(9),
      largeArc: false,
      clockwise: false,
    );

    // path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TriangleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(),
      child: const SizedBox(
        width: 100,
        height: 100,
      ),
    );
  }
}
