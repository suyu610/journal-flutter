library verification_code;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 模式
enum CodeMode {
  //文字
  text
}

/// 样式
enum CodeStyle {
  //表格
  form,
  //方块
  rectangle,
  //横线
  line,
  //圈圈
  circle
}

/// 验证码
class VerificationCode extends StatefulWidget {
  const VerificationCode({
    super.key,
    this.maxLength = 4,
    this.height = 50,
    this.mode = CodeMode.text,
    this.style = CodeStyle.form,
    this.codeBgColor = Colors.transparent,
    this.borderWidth = 2,
    this.borderColor = Colors.grey,
    this.borderSelectColor = Colors.red,
    this.borderRadius = 3,
    this.contentColor = Colors.black,
    this.contentSize = 16,
    this.itemWidth = 50,
    this.itemSpace = 16,
    this.autoFocused = false,
    required this.onCompleted,
    this.onChanged,
  });

  final int maxLength;

  //高度
  final double height;

  //验证码模式
  final CodeMode mode;

  //验证码样式
  final CodeStyle style;

  //背景色
  final Color codeBgColor;

  //边框宽度
  final double borderWidth;

  //边框默认颜色
  final Color borderColor;

  //边框选中颜色
  final Color borderSelectColor;

  //边框圆角
  final double borderRadius;

  //内容颜色
  final Color contentColor;

  //内容大小
  final double contentSize;

  // 单个Item宽度
  final double itemWidth;

  //Item之间的间隙
  final int itemSpace;

  //完成回调
  final ValueChanged<String> onCompleted;

  //输入回调
  final ValueChanged<String>? onChanged;

  final bool autoFocused;

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  FocusNode focusNode = FocusNode();

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.autoFocused) focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var size = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            size: size,
            painter: CodeCustomPainter(
              widget.maxLength,
              size.width,
              size.height,
              widget.mode,
              widget.style,
              widget.codeBgColor,
              widget.borderWidth,
              widget.borderColor,
              widget.borderSelectColor,
              widget.borderRadius,
              widget.contentColor,
              widget.contentSize,
              widget.itemWidth,
              widget.itemSpace,
              focusNode,
              controller,
            ),
            child: TextField(
              //控制焦点
              focusNode: focusNode,
              controller: controller,
              //光标不显示
              showCursor: false,
              //光标颜色透明
              cursorColor: Colors.transparent,
              enableInteractiveSelection: false,
              //设置最大长度
              maxLength: widget.maxLength,
              //文字样式为透明
              style: const TextStyle(
                                        
                color: Colors.transparent,
              ),
              //只允许数据数字
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                widget.onChanged?.call(value);
                if (value.isNotEmpty && value.length == widget.maxLength) {
                  widget.onCompleted.call(value);
                }
              },
              //弹出数字键盘
              keyboardType: TextInputType.number,
              //边框样式取消
              decoration: null,
            ),
          );
        },
      ),
    );
  }
}

class CodeCustomPainter extends CustomPainter {
  final double width;
  final double height;
  final int maxLength;

  //验证码模式
  final CodeMode mode;

  //验证码样式
  final CodeStyle style;

  //背景色
  final Color codeBgColor;

  //边框宽度
  final double borderWidth;

  //边框默认颜色
  final Color borderColor;

  //边框选中颜色
  final Color borderSelectColor;

  //边框圆角
  final double borderRadius;

  //内容颜色
  final Color contentColor;

  //内容大小
  final double contentSize;

  // 单个Item宽度
  double itemWidth;

  //Item之间的间隙
  final int itemSpace;

  //焦点
  final FocusNode focusNode;

  final TextEditingController controller;

  //线路画笔
  late Paint linePaint;

  //文字画笔
  late TextPainter textPainter;

  //当前文字索引
  int currentIndex = 0;

  //左右间距值
  double space = 0;

  int codeItemSpace = 0;

  CodeCustomPainter(
    this.maxLength,
    this.width,
    this.height,
    this.mode,
    this.style,
    this.codeBgColor,
    this.borderWidth,
    this.borderColor,
    this.borderSelectColor,
    this.borderRadius,
    this.contentColor,
    this.contentSize,
    this.itemWidth,
    this.itemSpace,
    this.focusNode,
    this.controller,
  ) {
    linePaint = Paint()
      ..color = borderColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth;

    textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    codeItemSpace = (style == CodeStyle.form) ? 0 : itemSpace;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //当前索引（待输入的光标位置）
    currentIndex = controller.text.length;
    //Item宽度（这里判断如果设置了宽度并且合理就使用当前设置的宽度，否则平均计算）
    if (itemWidth != -1 &&
        (itemWidth * maxLength + codeItemSpace * (maxLength - 1)) <= width) {
      itemWidth = itemWidth;
    } else {
      itemWidth = ((width - codeItemSpace * (maxLength - 1)) / maxLength);
    }

    //计算左右间距大小
    space =
        (width - itemWidth * maxLength - codeItemSpace * (maxLength - 1)) / 2;

    //绘制样式
    switch (style) {
      //表格
      case CodeStyle.form:
        _drawFormCode(canvas, size);
        break;
      //方块
      case CodeStyle.rectangle:
        _drawRectangleCode(canvas, size);
        break;
      //横线
      case CodeStyle.line:
        _drawLineCode(canvas, size);
        break;
      //圈圈
      case CodeStyle.circle:
        _drawCircleCode(canvas, size);
        break;
      // 拓展
    }

    //绘制文字内容
    _drawContentCode(canvas, size);
  }

  /*
   * 绘制表格样式
   */
  void _drawFormCode(Canvas canvas, Size size) {
    //绘制表格边框
    Rect rect = Rect.fromLTRB(space, 0, width - space, height);
    RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    linePaint.color = borderColor;
    canvas.drawRRect(rRect, linePaint);

    //绘制表格中间分割线
    for (int i = 1; i < maxLength; i++) {
      double startX = space + itemWidth * i + codeItemSpace * i;
      double startY = 0;
      double stopY = height;
      canvas.drawLine(Offset(startX, startY), Offset(startX, stopY), linePaint);
    }

    //绘制当前位置边框
    for (int i = 0; i < maxLength; i++) {
      if (currentIndex != -1 && currentIndex == i && focusNode.hasFocus) {
        //计算每个表格的左边距离
        double left = 0;
        if (i == 0) {
          left = (space + itemWidth * i);
        } else {
          left = ((space + itemWidth * i + codeItemSpace * i));
        }
        linePaint.color = borderSelectColor;
        //第一个
        if (i == 0) {
          RRect rRect = RRect.fromLTRBAndCorners(
              left, 0, left + itemWidth, height,
              topLeft: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(borderRadius));
          canvas.drawRRect(rRect, linePaint);
        }
        //最后一个
        else if (i == maxLength - 1) {
          RRect rRect = RRect.fromLTRBAndCorners(
              left, 0, left + itemWidth, height,
              topRight: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius));
          canvas.drawRRect(rRect, linePaint);
        }
        //其他
        else {
          RRect rRect =
              RRect.fromLTRBAndCorners(left, 0, left + itemWidth, height);
          canvas.drawRRect(rRect, linePaint);
        }
      }
    }
  }

  /*
   * 绘制方块样式
   */
  void _drawRectangleCode(Canvas canvas, Size size) {
    for (int i = 0; i < maxLength; i++) {
      double left = 0;
      if (i == 0) {
        left = space + i * itemWidth;
      } else {
        left = space + i * itemWidth + codeItemSpace * i;
      }
      Rect rect = Rect.fromLTRB(left, 0, left + itemWidth, height);
      RRect rRect =
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
      //当前光标样式
      if (currentIndex != -1 && currentIndex == i && focusNode.hasFocus) {
        linePaint.color = borderSelectColor;
        canvas.drawRRect(rRect, linePaint);
      }
      //默认样式
      else {
        linePaint.color = borderColor;
        canvas.drawRRect(rRect, linePaint);
      }
    }
  }

  /*
   * 绘制横线样式
   */
  void _drawLineCode(Canvas canvas, Size size) {
    for (int i = 0; i < maxLength; i++) {
      //当前选中状态
      if (controller.value.text.length == i && focusNode.hasFocus) {
        linePaint.color = borderSelectColor;
      }
      //默认状态
      else {
        linePaint.color = borderColor;
      }
      double startX = space + itemWidth * i + codeItemSpace * i;
      double startY = height - borderWidth;
      double stopX = startX + itemWidth;
      double stopY = startY;
      canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), linePaint);
    }
  }

  /*
   * 绘制圈圈样式
   */
  void _drawCircleCode(Canvas canvas, Size size) {
    for (int i = 0; i < maxLength; i++) {
      //当前绘制的圆圈的左x轴坐标
      double left = 0;
      if (i == 0) {
        left = space + i * itemWidth;
      } else {
        left = space + i * itemWidth + codeItemSpace * i;
      }
      //圆心坐标
      double cx = left + itemWidth / 2.0;
      double cy = height / 2.0;
      //圆形半径
      double radius = itemWidth / 5.0;
      //默认样式
      if (i >= currentIndex) {
        linePaint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy), radius, linePaint);
      }
    }
  }

  /*
   * 绘制验证码文字
   */
  void _drawContentCode(Canvas canvas, Size size) {
    String textStr = controller.text;
    for (int i = 0; i < maxLength; i++) {
      if (textStr.isNotEmpty && i < textStr.length) {
        switch (mode) {
          case CodeMode.text:
            String code = textStr[i].toString();
            textPainter.text = TextSpan(
              text: code,
              style: TextStyle(
                                        color: contentColor, fontSize: contentSize),
            );
            textPainter.layout();
            double x = space +
                itemWidth * i +
                codeItemSpace * i +
                (itemWidth - textPainter.width) / 2;
            double y = (height - textPainter.height) / 2;
            textPainter.paint(canvas, Offset(x, y));
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
