import 'dart:ui';
import 'package:flutter/material.dart';

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
      barrierColor: Colors.black.withOpacity(0.4),
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
        final curvedValue = Curves.easeIn.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(
            0.0,
            0.0,
            curvedValue * 200,
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
    // 只有当传入了 input 回调时，才认为是输入模式
    final bool isInputMode = widget.onConfirmWithInput != null;

    return Scaffold(
      // 使用 Scaffold 确保键盘弹出时布局自适应
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(), // 点击空白处关闭
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: SingleChildScrollView(
              // 防止键盘遮挡
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: -5,
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D2129),
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4E5969),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],

                          // --- 输入框区域 (仅在输入模式下显示) ---
                          if (isInputMode) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Material(
                                color: Colors.transparent,
                                child: TextField(
                                  controller: _textController,
                                  autofocus: true, // 自动聚焦，体验更好
                                  textInputAction: widget.textInputAction,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF1D2129)),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F8FA), // 浅灰背景
                                    hintText: widget.inputHintText ?? "请输入...",
                                    hintStyle: const TextStyle(
                                        color: Color(0xFFC9CDD4)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey[900]!,
                                          width: 1), // 聚焦时的高亮
                                    ),
                                  ),
                                  onSubmitted: (v) {
                                    // 键盘上的“完成”键也可以触发确认
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
                                    text: widget.confirmText,
                                    isPrimary: true,
                                    isDestructive: widget.isDestructive,
                                    onTap: () {
                                      if (isInputMode) {
                                        // 输入模式：将文本传出去，不自动关闭弹窗
                                        // 由外部逻辑（比如你的校验逻辑）决定是否关闭
                                        widget.onConfirmWithInput
                                            ?.call(_textController.text);
                                      } else {
                                        // 普通模式：自动关闭
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
    BuildContext context, {
    required String text,
    required bool isPrimary,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final Color backgroundColor = isPrimary
        ? (isDestructive ? const Color(0xFFFFECE8) : const Color(0xFF1D2129))
        : const Color(0xFFF2F3F5);

    final Color textColor = isPrimary
        ? (isDestructive ? const Color(0xFFD32F2F) : Colors.white)
        : const Color(0xFF4E5969);

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
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
