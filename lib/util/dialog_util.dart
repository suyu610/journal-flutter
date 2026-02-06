import 'dart:ui';
import 'package:flutter/material.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';

class PremiumGlassDialog extends StatefulWidget {
  final String? title;
  final String? content;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  // 普通回调（无输入）
  final VoidCallback? onConfirm;
  // 输入回调（带输入），如果传了这个，会自动显示输入框
  final ValueChanged<String>? onConfirmWithInput;
  final bool isDestructive;
  // 输入框相关配置
  final String? inputHintText;
  final TextInputAction? textInputAction;

  const PremiumGlassDialog({
    Key? key,
    this.title,
    this.content,
    this.cancelText = "取消",
    this.confirmText = "确定",
    this.onCancel,
    this.onConfirm,
    this.onConfirmWithInput,
    this.isDestructive = false,
    this.inputHintText,
    this.textInputAction,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    String? title,
    String? content,
    String cancelText = "取消",
    String confirmText = "确定",
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    // 新增：输入确认回调
    ValueChanged<String>? onConfirmWithInput,
    String? inputHintText,
    TextInputAction? textInputAction,
    bool isDestructive = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.6), // 深色遮罩稍微加深一点，更聚焦
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return PremiumGlassDialog(
          title: title,
          content: content,
          cancelText: cancelText,
          confirmText: confirmText,
          onCancel: onCancel,
          onConfirm: onConfirm,
          onConfirmWithInput: onConfirmWithInput,
          inputHintText: inputHintText,
          textInputAction: textInputAction,
          isDestructive: isDestructive,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutCubic.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(
            0.0,
            0.0,
            curvedValue * 20, // 稍微减小位移距离，更精致
          ),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PremiumGlassDialog> createState() => _PremiumGlassDialogState();
}

class _PremiumGlassDialogState extends State<PremiumGlassDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final bool isInputMode = widget.onConfirmWithInput != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: 16, sigmaY: 16), // 加大模糊度，质感更好
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            // 使用卡片背景色的高不透明度版本
                            // 这样在亮色是白透，深色是黑透
                            appColors.cardBackground.withOpacity(0.90),
                            appColors.cardBackground.withOpacity(0.80),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          // 边框也适配：使用主色的极低透明度
                          color: appColors.primaryText.withOpacity(0.05),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: -2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 32),
                          // --- 标题 ---
                          if (widget.title != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                widget.title!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: appColors.primaryText, // 适配文字
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),

                          // --- 内容文本 ---
                          if (widget.content != null) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                widget.content!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: appColors.secondaryText, // 适配文字
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],

                          // --- 输入框区域 ---
                          if (isInputMode) ...[
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Material(
                                color: Colors.transparent,
                                child: TextField(
                                  controller: _textController,
                                  autofocus: true,
                                  textInputAction: widget.textInputAction,
                                  cursorColor: appColors.primaryText, // 光标颜色
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: appColors.primaryText), // 输入文字颜色
                                  decoration: InputDecoration(
                                    filled: true,
                                    // 输入框背景：淡色主题背景
                                    fillColor:
                                        appColors.primaryText.withOpacity(0.04),
                                    hintText: widget.inputHintText ?? "请输入...",
                                    hintStyle: TextStyle(
                                        color: appColors.secondaryText
                                            .withOpacity(0.5)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      // 聚焦边框：主色
                                      borderSide: BorderSide(
                                          color: appColors.primaryText
                                              .withOpacity(0.3),
                                          width: 1),
                                    ),
                                  ),
                                  onSubmitted: (v) {
                                    widget.onConfirmWithInput?.call(v);
                                  },
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // --- 按钮区域 ---
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildButton(
                                    context,
                                    appColors, // 传入 colors
                                    text: widget.cancelText,
                                    isPrimary: false,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      widget.onCancel?.call();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildButton(
                                    context,
                                    appColors, // 传入 colors
                                    text: widget.confirmText,
                                    isPrimary: true,
                                    isDestructive: widget.isDestructive,
                                    onTap: () {
                                      if (isInputMode) {
                                        widget.onConfirmWithInput
                                            ?.call(_textController.text);
                                      } else {
                                        Navigator.of(context).pop();
                                        widget.onConfirm?.call();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    AppThemeColors appColors, {
    required String text,
    required bool isPrimary,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    // 计算背景色
    Color backgroundColor;
    Color textColor;

    if (isPrimary) {
      if (isDestructive) {
        // 毁灭性操作（如删除）：浅红背景 + 红色文字
        backgroundColor = const Color(0xFFE34D59).withOpacity(0.1);
        textColor = const Color(0xFFE34D59);
      } else {
        // 普通确认：主按钮色
        backgroundColor = appColors.mainButtonBg;
        textColor = appColors.mainButtonIcon;
      }
    } else {
      // 取消按钮：极淡的背景 + 次要文字
      backgroundColor = appColors.primaryText.withOpacity(0.05);
      textColor = appColors.secondaryText;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
