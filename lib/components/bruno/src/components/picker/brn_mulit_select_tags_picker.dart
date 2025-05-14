import 'package:journal/components/bruno/src/components/picker/base/brn_picker_title_config.dart';
import 'package:journal/components/bruno/src/components/picker/brn_tags_common_picker.dart';
import 'package:journal/components/bruno/src/components/picker/brn_tags_picker_config.dart';
import 'package:journal/components/bruno/src/l10n/brn_intl.dart';
import 'package:journal/components/bruno/src/theme/brn_theme.dart';
import 'package:flutter/material.dart';

///样式的枚举类型
/// [average] 等分布局
/// [auto] 流式布局
enum BrnMultiSelectTagsLayoutStyle {
  ///等分布局
  average,

  ///流式布局
  auto,
}

typedef BrnMultiSelectTagStringBuilder<V> = String Function(V data);
typedef BrnMultiSelectTagOnItemClick = void Function(
    BrnTagItemBean onTapTag, bool isSelect);

/// 多选标签弹框,适用于底部弹出 Picker，且选择样式为 Tag 的场景。
/// 功能：多选标签弹框，适用于从底部弹出的情况，属于 Picker；
/// 可自定义标题、默认选中、字体大小等。
// ignore: must_be_immutable
class BrnMultiSelectTagsPicker extends CommonTagsPicker {
  BrnMultiSelectTagsPicker({
    Key? key,
    required this.context,
    required this.onConfirm,
    this.onCancel,
    required this.tagPickerConfig,
    required this.onTagValueGetter,
    this.onMaxSelectClick,
    this.onItemClick,
    this.maxSelectItemCount = 0,
    this.crossAxisCount,
    this.itemHeight = 34.0,
    this.layoutStyle = BrnMultiSelectTagsLayoutStyle.average,
    BrnPickerTitleConfig pickerTitleConfig = BrnPickerTitleConfig.Default,
    BrnPickerConfig? themeData,
  }) : super(
            key: key,
            context: context,
            onConfirm: onConfirm,
            onCancel: onCancel,
            pickerTitleConfig: pickerTitleConfig,
            themeData: themeData);

  /// 父类属性
  @override
  final BuildContext context;

  /// 点击提交功能
  @override
  final ValueChanged onConfirm;

  /// 点击取消按钮
  @override
  final VoidCallback? onCancel;

  /// 当点击到最大数目时的点击事件
  final VoidCallback? onMaxSelectClick;

  /// 点击某个按钮的回调
  final BrnMultiSelectTagOnItemClick? onItemClick;

  /// 一行多少个数据，默认4个
  final int? crossAxisCount;

  /// 最多选择多少个item，默认可以无限选
  final int maxSelectItemCount;

  /// 本类属性
  final BrnTagsPickerConfig tagPickerConfig;

  /// 传入的泛型数据转换为 [BrnTagItemBean]
  /// 默认以填充Widget
  final BrnMultiSelectTagStringBuilder<BrnTagItemBean> onTagValueGetter;

  /// 是等分样式还是流式布局样式，[BrnMultiSelectTagsLayoutStyle]，默认等分
  final BrnMultiSelectTagsLayoutStyle layoutStyle;

  /// item的高度, 默认数值是34
  final double itemHeight;

  /// 操作类型属性
  late List<BrnTagItemBean> _selectedTags;
  late List<BrnTagItemBean> _sourceTags;

  @override
  void show() {
    _dataSetup();
    super.show();
  }

  @override
  Object getConfirmData() {
    return _selectedTags;
  }

  @override
  Widget createBuilder(BuildContext context, VoidCallback? onUpdate) {
    if (tagPickerConfig.tagItemSource.isNotEmpty) {
      return _buildContent(context, onUpdate);
    } else {
      return Container(
        height: 200,
        child: Center(
          child: Text(BrnIntl.of(context).localizedResource.noTagDataTip),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context, VoidCallback? onUpdate) {
    if (layoutStyle == BrnMultiSelectTagsLayoutStyle.average) {
      return LayoutBuilder(
        builder: (_, constraints) {
          double maxWidth = constraints.maxWidth;
          return _buildGridViewWidget(context, onUpdate, maxWidth);
        },
      );
    } else {
      return _buildWrapViewWidget(context, onUpdate);
    }
  }

  ///等宽度的布局
  Widget _buildGridViewWidget(
      BuildContext context, VoidCallback? onUpdate, double maxWidth) {
    int brnCrossAxisCount =
        (crossAxisCount == null || crossAxisCount == 0) ? 4 : crossAxisCount!;
    double width =
        (maxWidth - (brnCrossAxisCount - 1) * 12 - 40) / brnCrossAxisCount;
    //计算宽高比
    double brnChildAspectRatio = width / itemHeight;
    Color selectedTagTitleColor =
        tagPickerConfig.selectedTagTitleColor ?? Colors.black;
    Color tagTitleColor = tagPickerConfig.tagTitleColor ??
        BrnThemeConfigurator.instance
            .getConfig()
            .commonConfig
            .colorTextImportant;
    Color tagBackgroundColor =
        tagPickerConfig.tagBackgroudColor ?? const Color.fromARGB(0, 248, 248, 248);
    Color selectedTagBackgroundColor =
        tagPickerConfig.selectedTagBackgroudColor ??
            BrnThemeConfigurator.instance
                .getConfig()
                .commonConfig
                .brandPrimary
                .withAlpha(0x14);
    return Container(
      padding:
          const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 0.0),
      constraints: const BoxConstraints(maxHeight: 322, minHeight: 120),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: brnCrossAxisCount,
        //水平子Widget之间间距
        crossAxisSpacing: 6.0,
        //垂直子Widget之间间距
        mainAxisSpacing: 12.0,
        //宽高比
        childAspectRatio: brnChildAspectRatio,
        //GridView内边距
        padding: const EdgeInsets.only(
            top: 20.0, left: 0.0, right: 0.0, bottom: 20.0),
        primary: true,
        children: _sourceTags.map((choice) {
          bool selected = choice.isSelect;
          Color titleColor = selected ? selectedTagTitleColor : tagTitleColor;
          EdgeInsets edgeInsets = tagPickerConfig.chipPadding ??
              const EdgeInsets.only(
                  top: 9.0, left: 10.0, right: 10, bottom: 11.0);
          return ChoiceChip(
            selected: selected,
            side: BorderSide.none,
            padding: edgeInsets,
            checkmarkColor: titleColor,
            pressElevation: 0,
            backgroundColor: tagBackgroundColor,
            selectedColor: selectedTagBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0)),
            label: Container(
              width: width,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: Text(
                onTagValueGetter(choice),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
                style: TextStyle(
                    height: 1,
                    color: titleColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: tagPickerConfig.tagTitleFontSize),
              ),
            ),
            onSelected: (bool value) {
              if (_selectedTags.length >= maxSelectItemCount &&
                  maxSelectItemCount > 0 &&
                  value == true) {
                if (onMaxSelectClick != null) {
                  // ignore: unnecessary_statements
                  onMaxSelectClick!();
                }
                return;
              }
              _clickTag(value, choice);
              onUpdate!();
            },
          );
        }).toList(),
      ),
    );
  }

  ///流式布局
  Widget _buildWrapViewWidget(BuildContext context, VoidCallback? onUpdate) {
    BrnTagConfig tagConfig = BrnThemeConfigurator.instance
        .getConfig(configId: themeData!.configId)
        .tagConfig
        .merge(BrnTagConfig());
    tagConfig = tagConfig.merge(BrnTagConfig(
        selectTagTextStyle: BrnTextStyle(
            height: 1,
            color: tagPickerConfig.selectedTagTitleColor,
            fontSize: tagPickerConfig.tagTitleFontSize,
            fontWeight: FontWeight.w600),
        tagTextStyle: BrnTextStyle(
            height: 1,
            color: tagPickerConfig.tagTitleColor,
            fontSize: tagPickerConfig.tagTitleFontSize,
            fontWeight: FontWeight.w400),
        tagBackgroundColor: tagPickerConfig.tagBackgroudColor,
        selectedTagBackgroundColor: tagPickerConfig.selectedTagBackgroudColor));

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Wrap(
          spacing: 15.0,
          runSpacing: 15.0,
          children: _sourceTags.map((choice) {
            bool selected = choice.isSelect;
            Color titleColor = selected
                ? tagConfig.selectTagTextStyle.color!
                : tagConfig.tagTextStyle.color!;
            EdgeInsets edgeInsets = tagPickerConfig.chipPadding ??
                const EdgeInsets.only(
                    top: 9.0, left: 10.0, right: 10, bottom: 11.0);
            return ChoiceChip(
              selected: selected,
              padding: edgeInsets,
              pressElevation: 0,
              backgroundColor: tagConfig.tagBackgroundColor,
              selectedColor: tagConfig.selectedTagBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0)),
              label: Text(
                onTagValueGetter(choice),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
                style: TextStyle(
                    height: 1,
                    color: titleColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: tagPickerConfig.tagTitleFontSize),
              ),
              onSelected: (bool value) {
                if (_selectedTags.length >= maxSelectItemCount &&
                    maxSelectItemCount > 0 &&
                    value == true) {
                  if (onMaxSelectClick != null) {
                    // ignore: unnecessary_statements
                    onMaxSelectClick!();
                  }
                  return;
                }
                _clickTag(value, choice);
                onUpdate!();
              },
            );
          }).toList(),
        ));
  }

  void _dataSetup() {
    List<BrnTagItemBean> tagItems = [];
    List<BrnTagItemBean> tagSelectItems = [];
    for (BrnTagItemBean item in tagPickerConfig.tagItemSource) {
      tagItems.add(item);
      //选中的按钮
      if (item.isSelect == true) {
        tagSelectItems.add(item);
      }
    }
    _sourceTags = tagItems;

    // 默认选中tags
    _selectedTags = tagSelectItems;
  }

  ///每一个item的点击事件
  void _clickTag(bool selected, BrnTagItemBean tagName) {
    if (selected) {
      tagName.isSelect = true;
      _selectedTags.add(tagName);
    } else {
      tagName.isSelect = false;
      _selectedTags.remove(tagName);
    }

    ///点击tag
    if (onItemClick != null) {
      onItemClick!(tagName, selected);
    }
  }
}
