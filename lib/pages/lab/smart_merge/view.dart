import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于 HapticFeedback
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/merge_candidate.dart'; // 确保你的模型类路径正确
import 'package:journal/request/request.dart';

class SmartMergePage extends StatefulWidget {
  const SmartMergePage({super.key});

  @override
  State<SmartMergePage> createState() => _SmartMergePageState();
}

class _SmartMergePageState extends State<SmartMergePage> {
  // 全局列表 Key，用于控制动画
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool _isLoading = true;
  List<MergeSuggestion> suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res =
          await HttpRequest.request(Method.get, "/expense/merge/suggest");

      if (res["code"] == 0 && res["data"] != null) {
        final dataList = res["data"] as List;
        final list = dataList
            .map<MergeSuggestion>((e) => MergeSuggestion.fromJson(e))
            .toList();

        if (mounted) {
          setState(() {
            suggestions = list;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔥 核心逻辑：处理合并请求 + 动画 + 震动
  void _handleMerge(
      String suggestionId, String targetName, List<String> sourceNames) async {
    // 1. 触感反馈 (震动)
    HapticFeedback.mediumImpact();

    // 2. 发送网络请求
    try {
      final res = await HttpRequest.request(
        Method.post,
        "/expense/merge",
        params: {
          "targetType": targetName,
          "sourceTypes": sourceNames,
        },
      );

      if (res["code"] == 0) {
        // 3. 成功后执行动画移除
        final index = suggestions.indexWhere((e) => e.id == suggestionId);

        if (index != -1) {
          final removedItem = suggestions[index];

          // A. 从数据源移除
          suggestions.removeAt(index);

          // B. 通知 AnimatedList 执行移除动画
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => _buildRemovedItem(removedItem, animation),
            duration: const Duration(milliseconds: 500), // 动画时长
          );

          // C. 如果删完变空了，延迟刷新以显示空状态
          if (suggestions.isEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() {});
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✨ 分类合并成功"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        throw res["msg"] ?? "未知错误";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("合并失败: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 构建移除时的动画组件 (收缩 + 淡出)
  Widget _buildRemovedItem(MergeSuggestion item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          // 这里传入空回调即可，因为组件即将消失
          child: MergeGroupCard(
            suggestion: item,
            onMerge: (_, __, ___) async {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 处理 ThemeExtension 可能为空的情况
    final appColors = Theme.of(context).extension<AppThemeColors>();
    final bgColor = appColors?.backgroundColor ?? const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const JournalNavBar(title: "智能整理"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestions.isEmpty
              ? _buildEmptyState(appColors) // 全部完成后显示庆祝页
              : AnimatedList(
                  key: _listKey,
                  padding: const EdgeInsets.all(16),
                  initialItemCount: suggestions.length,
                  itemBuilder: (context, index, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MergeGroupCard(
                          suggestion: suggestions[index],
                          onMerge: _handleMerge,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // 🎉 庆祝空状态
  Widget _buildEmptyState(AppThemeColors? appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 64, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            "太棒了！",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "所有分类都已整理完毕",
            style: TextStyle(color: appColors?.secondaryText ?? Colors.grey),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("返回账本"),
          )
        ],
      ),
    );
  }
}

// ==============================================================================
// 3. 核心卡片组件 (包含局部 Loading)
// ==============================================================================

class MergeGroupCard extends StatefulWidget {
  final MergeSuggestion suggestion;
  final Function(String id, String targetName, List<String> sourceNames)
      onMerge;

  const MergeGroupCard({
    super.key,
    required this.suggestion,
    required this.onMerge,
  });

  @override
  State<MergeGroupCard> createState() => _MergeGroupCardState();
}

class _MergeGroupCardState extends State<MergeGroupCard> {
  late TextEditingController _targetCtrl;
  bool _isSubmitting = false; // 局部 Loading 状态

  @override
  void initState() {
    super.initState();
    _targetCtrl = TextEditingController(text: widget.suggestion.targetName);
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final targetName = _targetCtrl.text.trim();
    if (targetName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("分类名称不能为空")),
      );
      return;
    }

    final selectedSources = widget.suggestion.candidates
        .where((c) => c.isSelected)
        .map((c) => c.sourceName)
        .toList();

    if (selectedSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请至少选择一项进行合并")),
      );
      return;
    }

    // 开启 Loading
    setState(() => _isSubmitting = true);

    // 调用父组件逻辑 (父组件负责发请求和移除动画)
    // 注意：这里我们不需要 await，因为父组件移除动画后，这个组件会被销毁
    widget.onMerge(widget.suggestion.id ?? "", targetName, selectedSources);

    // 如果失败了父组件没有移除这个卡片，我们可能需要重置 loading，
    // 但在这个简单的交互中，我们可以假设父组件会处理 Snack bar，
    // 这里为了保险起见，可以延迟几秒重置（如果还在树上的话）
    if (mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isSubmitting = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 推荐理由
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 16, color: Color(0xFFFAAD14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.suggestion.reason,
                  style: const TextStyle(
                    color: Color(0xFFFAAD14),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. 目标分类输入框
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text("分类为：",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Expanded(
                  child: TextField(
                    controller: _targetCtrl,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. 候选列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.suggestion.candidates.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(left: 44, top: 8, bottom: 8),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),
            itemBuilder: (context, index) {
              return _buildCandidateRow(widget.suggestion.candidates[index]);
            },
          ),

          const SizedBox(height: 24),

          // 4. 确认按钮 (带 Loading 状态)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "确认修改分类",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateRow(MergeCandidate candidate) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              candidate.isSelected = !candidate.isSelected;
            });
          },
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: candidate.isSelected
                      ? const Color(0xFF222222)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: candidate.isSelected
                        ? const Color(0xFF222222)
                        : const Color(0xFFDDDDDD),
                    width: 2,
                  ),
                ),
                child: candidate.isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.sourceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${candidate.count} 笔交易",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 预览流水 (如果有)
        if (candidate.previewItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: candidate.previewItems.take(3).map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (expense.label.isNotEmpty) ? expense.label : "无描述",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          "-${expense.price}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
      ],
    );
  }
}
