import 'package:journal/components/bruno/src/components/navbar/brn_appbar_theme.dart';
import 'package:journal/components/bruno/src/theme/base/brn_base_config.dart';
import 'package:journal/components/bruno/src/theme/base/brn_default_config_utils.dart';
import 'package:journal/components/bruno/src/theme/base/brn_text_style.dart';
import 'package:journal/components/bruno/src/theme/brn_theme_configurator.dart';
import 'package:journal/components/bruno/src/theme/configs/brn_common_config.dart';

import 'package:flutter/material.dart';

import 'brn_appbar_config.dart';

/// 查看大图配置
class BrnGalleryDetailConfig extends BrnBaseConfig {
  /// 遵循全局配置
  /// 默认为 [BrnDefaultConfigUtils.defaultGalleryDetailConfig]
  BrnGalleryDetailConfig({
    BrnTextStyle? appbarTitleStyle,
    BrnTextStyle? appbarActionStyle,
    Color? appbarBackgroundColor,
    BrnAppBarConfig? appbarConfig,
    BrnTextStyle? tabBarUnSelectedLabelStyle,
    BrnTextStyle? tabBarLabelStyle,
    Color? tabBarBackgroundColor,
    Color? pageBackgroundColor,
    Color? bottomBackgroundColor,
    BrnTextStyle? titleStyle,
    BrnTextStyle? contentStyle,
    BrnTextStyle? actionStyle,
    Color? iconColor,
    String configId = GLOBAL_CONFIG_ID,
  })  : _appbarTitleStyle = appbarTitleStyle,
        _appbarActionStyle = appbarActionStyle,
        _appbarBackgroundColor = appbarBackgroundColor,
        _appbarConfig = appbarConfig,
        _tabBarUnSelectedLabelStyle = tabBarUnSelectedLabelStyle,
        _tabBarLabelStyle = tabBarLabelStyle,
        _tabBarBackgroundColor = tabBarBackgroundColor,
        _pageBackgroundColor = pageBackgroundColor,
        _bottomBackgroundColor = bottomBackgroundColor,
        _titleStyle = titleStyle,
        _contentStyle = contentStyle,
        _actionStyle = actionStyle,
        _iconColor = iconColor,
        super(configId: configId);

  /// 黑色主题
  BrnGalleryDetailConfig.dark({
    String configId = GLOBAL_CONFIG_ID,
  }) : super(configId: configId) {
    _appbarTitleStyle = BrnTextStyle(color: commonConfig.colorTextBaseInverse);
    _appbarActionStyle = BrnTextStyle(color: BrnAppBarTheme.lightTextColor);
    _appbarBackgroundColor = Colors.black;
    _appbarConfig = BrnAppBarConfig.dark();
    _tabBarUnSelectedLabelStyle = BrnTextStyle(color: const Color(0XFFCCCCCC));
    _tabBarLabelStyle = BrnTextStyle(color: commonConfig.colorTextBaseInverse);
    _tabBarBackgroundColor = Colors.black;
    _pageBackgroundColor = Colors.black;
    _bottomBackgroundColor = const Color(0X88000000);
    _titleStyle = BrnTextStyle(color: commonConfig.colorTextBaseInverse);
    _contentStyle = BrnTextStyle(color: const Color(0xFFCCCCCC));
    _actionStyle = BrnTextStyle(color: commonConfig.colorTextBaseInverse);
    _iconColor = Colors.white;
  }

  /// 白色主题
  BrnGalleryDetailConfig.light({
    String configId = GLOBAL_CONFIG_ID,
  }) : super(configId: configId) {
    _appbarTitleStyle = BrnTextStyle(color: commonConfig.colorTextBase);
    _appbarActionStyle = BrnTextStyle(color: commonConfig.colorTextBase);
    _appbarBackgroundColor = commonConfig.fillBody;
    _appbarConfig = BrnAppBarConfig.light();
    _tabBarUnSelectedLabelStyle = BrnTextStyle(
      color: commonConfig.colorTextBase,
    );
    _tabBarLabelStyle = BrnTextStyle(color: commonConfig.brandPrimary);
    _tabBarBackgroundColor = commonConfig.fillBody;
    _pageBackgroundColor = commonConfig.fillBody;
    _bottomBackgroundColor = commonConfig.fillBody.withOpacity(.85);
    _titleStyle = BrnTextStyle(color: commonConfig.colorTextBase);
    _contentStyle = BrnTextStyle(color: commonConfig.colorTextBase);
    _actionStyle = BrnTextStyle(color: commonConfig.colorTextSecondary);
    _iconColor = commonConfig.colorTextSecondary;
  }

  /// appbar   brightness待定

  /// appbar 标题样式
  ///
  /// BrnTextStyle(
  ///   color: [BrnCommonConfig.colorTextBaseInverse],
  ///   fontSize: [BrnCommonConfig.fontSizeHead],
  ///   fontWeight: FontWeight.w600,
  /// )
  BrnTextStyle? _appbarTitleStyle;

  /// 右侧操作区域文案样式
  ///
  /// BrnTextStyle(
  ///   color: AppBarBrightness(brightness).textColor,
  ///   fontSize: BrnAppBarTheme.actionFontSize,
  ///   fontWeight: FontWeight.w600,
  /// )
  BrnTextStyle? _appbarActionStyle;

  /// appBar 背景色
  /// 默认为 Colors.black
  Color? _appbarBackgroundColor;

  /// appbar brightness
  /// 默认为 [Brightness.dark]
  BrnAppBarConfig? _appbarConfig;

  /// tabBar 标题普通样式
  ///
  /// BrnTextStyle(
  ///   color: Colors.red,
  ///   fontSize: [BrnCommonConfig.fontSizeSubHead],
  /// )
  BrnTextStyle? _tabBarUnSelectedLabelStyle;

  /// tabBar 标题选中样式
  ///
  /// BrnTextStyle(
  ///   color: [BrnCommonConfig.colorTextBaseInverse],
  ///   fontSize: [BrnCommonConfig.fontSizeSubHead],
  ///   fontWeight: FontWeight.w600,
  /// )
  BrnTextStyle? _tabBarLabelStyle;

  /// tabBar 背景色
  /// 默认为 Colors.black
  Color? _tabBarBackgroundColor;

  /// 页面 背景色
  /// 默认为 Colors.black
  Color? _pageBackgroundColor;

  /// 底部内容区域的背景色
  /// 默认为 Color(0x88000000)
  Color? _bottomBackgroundColor;

  /// 标题文案样式
  ///
  /// BrnTextStyle(
  ///   color: [BrnCommonConfig.colorTextBaseInverse],
  ///   fontSize: [BrnCommonConfig.fontSizeHead],
  ///   fontWeight: FontWeight.w600,
  /// )
  BrnTextStyle? _titleStyle;

  /// 内容文案样式
  ///
  /// BrnTextStyle(
  ///   color: Color(0xFFCCCCCC),
  ///   fontSize: [BrnCommonConfig.fontSizeBase],
  /// )
  BrnTextStyle? _contentStyle;

  /// 右侧展开收起样式
  ///
  /// BrnTextStyle(
  ///   color: [BrnCommonConfig.colorTextBaseInverse],
  ///   fontSize: [BrnCommonConfig.fontSizeBase],
  /// )
  BrnTextStyle? _actionStyle;

  /// icon 颜色
  /// 默认为 Colors.white
  Color? _iconColor;

  BrnTextStyle get appbarTitleStyle =>
      _appbarTitleStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.appbarTitleStyle;

  BrnTextStyle get appbarActionStyle =>
      _appbarActionStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.appbarActionStyle;

  Color get appbarBackgroundColor =>
      _appbarBackgroundColor ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.appbarBackgroundColor;

  BrnAppBarConfig get appbarConfig =>
      _appbarConfig ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.appbarConfig;

  BrnTextStyle get tabBarUnSelectedLabelStyle =>
      _tabBarUnSelectedLabelStyle ??
      BrnDefaultConfigUtils
          .defaultGalleryDetailConfig.tabBarUnSelectedLabelStyle;

  BrnTextStyle get tabBarLabelStyle =>
      _tabBarLabelStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.tabBarLabelStyle;

  Color get tabBarBackgroundColor =>
      _tabBarBackgroundColor ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.tabBarBackgroundColor;

  Color get pageBackgroundColor =>
      _pageBackgroundColor ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.pageBackgroundColor;

  Color get bottomBackgroundColor =>
      _bottomBackgroundColor ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.bottomBackgroundColor;

  BrnTextStyle get titleStyle =>
      _titleStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.titleStyle;

  BrnTextStyle get contentStyle =>
      _contentStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.contentStyle;

  BrnTextStyle get actionStyle =>
      _actionStyle ??
      BrnDefaultConfigUtils.defaultGalleryDetailConfig.actionStyle;

  Color get iconColor =>
      _iconColor ?? BrnDefaultConfigUtils.defaultGalleryDetailConfig.iconColor;

  @override
  void initThemeConfig(
    String configId, {
    BrnCommonConfig? currentLevelCommonConfig,
  }) {
    super.initThemeConfig(
      configId,
      currentLevelCommonConfig: currentLevelCommonConfig,
    );

    /// 用户全局组件配置
    BrnGalleryDetailConfig galleryDetailConfig = BrnThemeConfigurator.instance
        .getConfig(configId: configId)
        .galleryDetailConfig;

    _appbarTitleStyle = galleryDetailConfig.appbarTitleStyle.merge(
      BrnTextStyle(
        color: commonConfig.colorTextBaseInverse,
        fontSize: commonConfig.fontSizeSubHead,
      ).merge(_appbarTitleStyle),
    );
    _appbarActionStyle = galleryDetailConfig.appbarActionStyle.merge(
      _appbarActionStyle,
    );
    _appbarConfig ??= galleryDetailConfig.appbarConfig;
    _appbarBackgroundColor ??= galleryDetailConfig.appbarBackgroundColor;
    _tabBarUnSelectedLabelStyle = galleryDetailConfig.tabBarUnSelectedLabelStyle
        .merge(BrnTextStyle(fontSize: commonConfig.fontSizeSubHead))
        .merge(_tabBarUnSelectedLabelStyle);
    _tabBarLabelStyle = galleryDetailConfig.tabBarLabelStyle
        .merge(
          BrnTextStyle(
            color: commonConfig.colorTextBaseInverse,
            fontSize: commonConfig.fontSizeSubHead,
          ),
        )
        .merge(_tabBarLabelStyle);
    _tabBarBackgroundColor ??= galleryDetailConfig._tabBarBackgroundColor;
    _pageBackgroundColor ??= galleryDetailConfig._pageBackgroundColor;
    _bottomBackgroundColor ??= galleryDetailConfig._bottomBackgroundColor;
    _titleStyle = galleryDetailConfig.titleStyle
        .merge(
          BrnTextStyle(
            color: commonConfig.colorTextBaseInverse,
            fontSize: commonConfig.fontSizeHead,
          ),
        )
        .merge(_titleStyle);
    _contentStyle = galleryDetailConfig.contentStyle
        .merge(BrnTextStyle(fontSize: commonConfig.fontSizeBase))
        .merge(_contentStyle);
    _actionStyle = galleryDetailConfig.actionStyle
        .merge(
          BrnTextStyle(
            color: commonConfig.colorTextBaseInverse,
            fontSize: commonConfig.fontSizeBase,
          ),
        )
        .merge(_actionStyle);
    _iconColor ??= galleryDetailConfig._iconColor;
  }

  BrnGalleryDetailConfig copyWith({
    BrnTextStyle? appbarTitleStyle,
    BrnTextStyle? appbarActionStyle,
    Color? appbarBackgroundColor,
    BrnAppBarConfig? appbarConfig,
    BrnTextStyle? tabBarUnSelectedLabelStyle,
    Color? tabBarUnselectedLabelColor,
    BrnTextStyle? tabBarLabelStyle,
    Color? tabBarLabelColor,
    Color? tabBarBackgroundColor,
    Color? indicatorColor,
    Color? pageBackgroundColor,
    Color? bottomBackgroundColor,
    BrnTextStyle? titleStyle,
    BrnTextStyle? contentStyle,
    BrnTextStyle? actionStyle,
    Color? iconColor,
  }) {
    return BrnGalleryDetailConfig(
      appbarTitleStyle: appbarTitleStyle ?? _appbarTitleStyle,
      appbarActionStyle: appbarActionStyle ?? _appbarActionStyle,
      appbarBackgroundColor: appbarBackgroundColor ?? _appbarBackgroundColor,
      appbarConfig: appbarConfig ?? _appbarConfig,
      tabBarUnSelectedLabelStyle:
          tabBarUnSelectedLabelStyle ?? _tabBarUnSelectedLabelStyle,
      tabBarLabelStyle: tabBarLabelStyle ?? _tabBarLabelStyle,
      tabBarBackgroundColor: tabBarBackgroundColor ?? _tabBarBackgroundColor,
      pageBackgroundColor: pageBackgroundColor ?? _pageBackgroundColor,
      bottomBackgroundColor: bottomBackgroundColor ?? _bottomBackgroundColor,
      titleStyle: titleStyle ?? _titleStyle,
      contentStyle: contentStyle ?? _contentStyle,
      actionStyle: actionStyle ?? _actionStyle,
      iconColor: iconColor ?? _iconColor,
    );
  }

  BrnGalleryDetailConfig merge(BrnGalleryDetailConfig? other) {
    if (other == null) return this;
    return copyWith(
      appbarTitleStyle: appbarTitleStyle.merge(other._appbarTitleStyle),
      appbarActionStyle: appbarActionStyle.merge(other._appbarActionStyle),
      appbarBackgroundColor: other._appbarBackgroundColor,
      appbarConfig: other._appbarConfig,
      tabBarUnSelectedLabelStyle:
          tabBarUnSelectedLabelStyle.merge(other._tabBarUnSelectedLabelStyle),
      tabBarLabelStyle: tabBarLabelStyle.merge(other._tabBarLabelStyle),
      tabBarBackgroundColor: other._tabBarBackgroundColor,
      pageBackgroundColor: other._pageBackgroundColor,
      bottomBackgroundColor: other._bottomBackgroundColor,
      titleStyle: titleStyle.merge(other._titleStyle),
      contentStyle: contentStyle.merge(other._contentStyle),
      actionStyle: actionStyle.merge(other._actionStyle),
      iconColor: other._iconColor,
    );
  }
}
