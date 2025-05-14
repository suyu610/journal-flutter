import 'package:flutter/material.dart';

///  TextStyle处理类  用来将内部属性重新赋值进行copyWith 和 merge操作
class BrnTextStyle {
  BrnTextStyle(
      {this.color,
      this.fontSize,
      this.fontWeight,
      this.decoration,
      this.textBaseline,
      this.height,
      this.fontFamily});

  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  TextDecoration? decoration;
  double? height;
  TextBaseline? textBaseline;
  String? fontFamily;

  BrnTextStyle.withStyle(TextStyle? style) {
    if (style == null) {
      return;
    }
    color = style.color ?? color;
    fontSize = style.fontSize ?? fontSize;
    fontWeight = style.fontWeight ?? fontWeight;
    decoration = style.decoration ?? decoration;
    height = style.height ?? height;
    textBaseline = style.textBaseline ?? textBaseline;
    fontFamily = style.fontFamily ?? fontFamily;
  }

  TextStyle generateTextStyle() {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration ?? TextDecoration.none,
      height: height,
      textBaseline: textBaseline,
      fontFamily: fontFamily,
    );
  }

  void flatTextStyle(BrnTextStyle? defaultTextStyle) {
    if (defaultTextStyle == null) {
      return;
    }
    color ??= defaultTextStyle.color;
    fontSize ??= defaultTextStyle.fontSize;
    fontWeight ??= defaultTextStyle.fontWeight;
    fontFamily ??= defaultTextStyle.fontFamily;
    decoration ??= defaultTextStyle.decoration;
    height ??= defaultTextStyle.height;
    textBaseline ??= defaultTextStyle.textBaseline;
  }

  BrnTextStyle copyWith({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    double? height,
    TextBaseline? textBaseline,
    String? fontFamily,
  }) {
    return BrnTextStyle(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      decoration: decoration ?? this.decoration,
      height: height ?? this.height,
      textBaseline: textBaseline ?? this.textBaseline,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  BrnTextStyle merge(BrnTextStyle? other) {
    if (other == null) return this;
    return copyWith(
      color: other.color,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      decoration: other.decoration,
      height: other.height,
      textBaseline: other.textBaseline,
      fontFamily: other.fontFamily,
    );
  }
}
