import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/pages/profile/index.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';

import 'index.dart';

class AiConfigPage extends GetView<AiConfigController> {
  AiConfigPage({super.key});

  // 主视图
  Widget _buildView(context) {
    ProfileController profileController = Get.find<ProfileController>();

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (profileController.user.value.aiAvatarUrl != null &&
                    profileController.user.value.aiAvatarUrl!
                        .startsWith("http")) {
                  //通过url快速生成配置
                  List<BrnPhotoGroupConfig> allConfig = [
                    BrnPhotoGroupConfig.url(title: '头像', urls: <String>[
                      profileController.user.value.aiAvatarUrl!,
                    ])
                  ];
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: BrnGalleryDetailPage(
                          allConfig: allConfig,
                          initGroupId: 0,
                          initIndexId: 0,
                        ),
                      );
                    },
                  ));
                }
              },
              child: Obx(
                () => profileController.user.value.aiAvatarUrl == "" ||
                        profileController.user.value.aiAvatarUrl == null
                    ? const CircleAvatar(
                        backgroundColor: Color(0xff1144d1),
                        radius: 100,
                        child: Text(
                          "头像",
                          style: TextStyle(color: Colors.white),
                        ))
                    : Image.network(
                        profileController.user.value.aiAvatarUrl!,
                        fit: BoxFit.fitWidth,
                        width: 385.w,
                        height: 300,
                      ),
              ),
            ),
            Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () {
                    profileController.generateAiAvatar(context);
                  },
                  child: Container(
                      color: Colors.black54,
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(6),
                      child: const Center(
                        child: Text(
                          "生成\n头像",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                )),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Obx(() => BrnTextSelectFormItem(
                    title: "描述",
                    isEdit: true,
                    hint: "请选择描述",
                    value: profileController.user.value.personality,
                    onTap: () {
                      _showPersonalityMulSelectTagPicker(context);
                    },
                  )),
              const SizedBox(
                height: 10,
              ),
              BrnTextSelectFormItem(
                title: "他/她是你的",
                isEdit: true,
                hint: "请选择关系",
                value: profileController.user.value.relationship,
                onTap: () {
                  int selectedIndex = 0;
                  showDialog(
                      barrierDismissible: true,
                      barrierLabel: "close",
                      context: context,
                      builder: (_) => StatefulBuilder(
                            builder: (context, state) {
                              return BrnSingleSelectDialog(
                                  isClose: true,
                                  title: '他/她是你的',
                                  conditions: Get.find<LayoutController>()
                                      .systemConfig['relationship']
                                      .split(","),
                                  checkedItem: Get.find<LayoutController>()
                                      .systemConfig['relationship']
                                      .split(",")[selectedIndex],
                                  submitText: '确定',
                                  isCustomFollowScroll: true,
                                  onItemClick:
                                      (BuildContext context, int index) {
                                    selectedIndex = index;
                                    Get.find<LayoutController>()
                                        .systemConfig['relationship']
                                        .split(",")[index];
                                  },
                                  onSubmitClick: (data) {
                                    controller.modifyRelationship(
                                        data!, context);
                                  });
                            },
                          ));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              BrnTextInputFormItem(
                title: "称呼我为",
                isEdit: true,
                hint: "称呼你为什么",
                controller: controller.salutationController,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  controller.modifySalutation(value, context);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              BrnBigMainButton(
                title: "保存",
                onTap: () => Get.back(),
              ),
            ],
          ),
        )
      ],
    );
  }

  // 选择性格
  void _showPersonalityMulSelectTagPicker(BuildContext context) {
    List<BrnTagItemBean> items = [];

    List<String> personalityList =
        Get.find<LayoutController>().systemConfig['personality'].split(",");

    for (int i = 0; i < personalityList.length; i++) {
      String it = personalityList[i];
      BrnTagItemBean item =
          BrnTagItemBean(name: it, code: it, index: i, isSelect: false);
      items.add(item);
    }

    BrnMultiSelectTagsPicker(
      context: context,
      //排列样式
      layoutStyle: BrnMultiSelectTagsLayoutStyle.average,
      //一行多少个
      crossAxisCount: 2,
      //最大选中数目 - 不设置 或者设置为0 则可以全选
      maxSelectItemCount: 5,
      onItemClick: (BrnTagItemBean onTapTag, bool isSelect) {
        // BrnToast.show(onTapTag.toString(), context);
      },
      onMaxSelectClick: () {
        BrnToast.show('最大数值不能超过5个', context);
      },
      pickerTitleConfig: const BrnPickerTitleConfig(
        titleContent: '智能体描述',
      ),
      tagPickerConfig: BrnTagsPickerConfig(
          tagItemSource: items,
          tagBackgroudColor: Colors.grey[100],
          selectedTagTitleColor: Colors.white,
          selectedTagBackgroudColor: BrnThemeConfigurator.instance
              .getConfig()
              .commonConfig
              .brandPrimary),
      onConfirm: (value) {
        var items = value as List<BrnTagItemBean>;

        controller.modifyPersonality(items, context);
      },
      onCancel: () {
        // BrnToast.show('点击了取消按钮', context);
      },
      onTagValueGetter: (choice) {
        return choice.name;
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiConfigController>(
      init: AiConfigController(),
      id: "ai_config",
      builder: (_) {
        return Scaffold(
          appBar: BrnAppBar(
            showDefaultBottom: true,
            showLeadingDivider: true,
            title: "人设",
            // actions: [const Icon(Icons.shuffle_rounded)],
          ),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
