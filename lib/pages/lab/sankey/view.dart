import 'package:flutter/material.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/expense.dart';
import 'package:sankey_flutter/sankey_helpers.dart'; // 必须引用这个！
import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_node.dart';

// ---------------------------------------------------------------------------
// 1. 数据模型
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// 2. 主页面 Widget
// ---------------------------------------------------------------------------
class SankeyChartView extends StatefulWidget {
  final List<Expense> expenses;

  const SankeyChartView({super.key, required this.expenses});

  @override
  State<SankeyChartView> createState() => _SankeyChartViewState();
}

class _SankeyChartViewState extends State<SankeyChartView> {
  // 数据源
  List<SankeyNode> nodes = [];
  List<SankeyLink> links = [];
  Map<String, Color> nodeColors = {};

  // 布局缓存 (官方 Demo 的写法)
  Size? _lastLayoutSize;
  SankeyDataSet? _sankeyDataSet;
  SankeyNode? selectedNode;

// ---------------------------------------------------------------------------
  // 3. 升级版配色方案：高对比现代撞色 (Vibrant & Clean)
  // ---------------------------------------------------------------------------

  // 🟢 收入：翡翠绿 (Emerald) —— 代表资金流入，健康积极
  final Color cIncome = const Color(0xFF10B981);

  // ⚫️ 枢纽：深岩灰 (Dark Slate) —— 中性核心，连接一切
  final Color cTotalIncome = const Color(0xFF334155);

  // 🟡 结余：琥珀金 (Amber) —— 像金币一样，高亮显示存下来的钱
  final Color cSavings = const Color(0xFFF59E0B);

  // 🌈 支出轮询色板 (Palette)
  // 逻辑：使用这6种颜色循环，保证相邻的支出分类颜色不同，区分度高
  final List<Color> expensePalette = [
    const Color(0xFFF43F5E), // 1. 玫瑰红 (Rose) - 醒目，适合餐饮/日常
    const Color(0xFF3B82F6), // 2. 皇家蓝 (Blue) - 科技/交通
    const Color(0xFF8B5CF6), // 3. 罗兰紫 (Violet) - 购物/娱乐
    const Color(0xFF14B8A6), // 4. 青绿 (Teal) - 居家/服务
    const Color(0xFFF97316), // 5. 亮橙 (Orange) - 社交/人情
    const Color(0xFF6366F1), // 6. 靛青 (Indigo) - 其他
  ];
  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant SankeyChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses) {
      _processData();
      _sankeyDataSet = null; // 数据变了，清除缓存
    }
  }

  // ---------------------------------------------------------------------------
  // 3. 数据处理 (只生成对象，不计算坐标)
  // ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
  // 3. 数据处理 (已修改：支持金额从大到小排序)
  // ---------------------------------------------------------------------------
  void _processData() {
    if (widget.expenses.isEmpty) {
      setState(() {
        nodes = [];
        links = [];
        nodeColors = {};
      });
      return;
    }

    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};

    try {
      for (var item in widget.expenses) {
        final double amount = item.price.toDouble();
        if (amount <= 0.01) continue;
        if (item.positive == 1) {
          incomeMap[item.type] = (incomeMap[item.type] ?? 0) + amount;
        } else {
          expenseMap[item.type] = (expenseMap[item.type] ?? 0) + amount;
        }
      }
    } catch (e) {
      debugPrint("Data Error: $e");
      return;
    }

    // ---------------------------------------------------------
    // 新增步骤：对 Map 进行降序排序 (Value 大的排前面)
    // ---------------------------------------------------------

    // 1. 收入排序 (左侧：从上往下金额递减)
    var sortedIncomes = incomeMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // 2. 支出排序 (右侧：从上往下金额递减)
    var sortedExpenses = expenseMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // 计算总额
    double totalIncome = incomeMap.values.fold(0, (sum, val) => sum + val);
    double totalExpense = expenseMap.values.fold(0, (sum, val) => sum + val);

    // 修正逻辑：通常桑基图中间节点应该是 收入总和，如果收入<支出(赤字)，逻辑上可能会有问题
    // 这里保持你原有的逻辑
    double centerAmount =
        totalIncome < totalExpense ? totalExpense : totalIncome;
    double savings = centerAmount - totalExpense;

    // ---------------------------------------------------------
    // ID 生成与节点添加
    // ---------------------------------------------------------
    int idCounter = 0;
    Map<String, SankeyNode> keyToNodeMap = {};
    List<SankeyNode> tempNodes = [];
    List<SankeyLink> tempLinks = [];
    Map<String, Color> tempColors = {};

    void addNode(String businessKey, String label, Color color) {
      final int newId = idCounter++;
      // 注意：这里可以根据需要调整 label 显示，比如加上金额 "$label\n¥$amount"
      final node = SankeyNode(id: newId, label: label);
      keyToNodeMap[businessKey] = node;
      tempNodes.add(node);
      tempColors[label] = color; // 使用 Label 作为 Key
    }

    const String keyCenter = "key_total";
    const String keySavings = "key_savings";

    // --- A. 创建节点 (顺序很重要，决定了垂直排列) ---

    // 1. 先加收入节点 (左侧) - 遍历排序后的列表
    for (var entry in sortedIncomes) {
      addNode("in_${entry.key}", entry.key, cIncome);
    }

    // 2. 再加中心节点 (中间)
    addNode(keyCenter, "总收入", cTotalIncome);

    // 3. 再加支出节点 (右侧) - 遍历排序后的列表
    int paletteIndex = 0;
    for (var entry in sortedExpenses) {
      addNode("out_${entry.key}", entry.key,
          expensePalette[paletteIndex % expensePalette.length]);
      paletteIndex++;
    }

    // 4. 最后加结余 (通常放在右侧最底部)
    if (savings > 1.0) {
      addNode(keySavings, "结余", cSavings);
    }

    // --- B. 创建连线 ---

    // 1. 收入 -> 中心
    for (var entry in sortedIncomes) {
      final sourceNode = keyToNodeMap["in_${entry.key}"];
      final targetNode = keyToNodeMap[keyCenter];
      if (sourceNode != null && targetNode != null) {
        tempLinks.add(SankeyLink(
          source: sourceNode,
          target: targetNode,
          value: entry.value, // 使用 entry.value
        ));
      }
    }

    // 2. 中心 -> 支出
    for (var entry in sortedExpenses) {
      final sourceNode = keyToNodeMap[keyCenter];
      final targetNode = keyToNodeMap["out_${entry.key}"];
      if (sourceNode != null && targetNode != null) {
        tempLinks.add(SankeyLink(
          source: sourceNode,
          target: targetNode,
          value: entry.value, // 使用 entry.value
        ));
      }
    }

    // 3. 中心 -> 结余
    if (savings > 1.0) {
      final sourceNode = keyToNodeMap[keyCenter];
      final targetNode = keyToNodeMap[keySavings];
      if (sourceNode != null && targetNode != null) {
        tempLinks.add(SankeyLink(
          source: sourceNode,
          target: targetNode,
          value: savings,
        ));
      }
    }

    setState(() {
      nodes = tempNodes;
      links = tempLinks;
      nodeColors = tempColors;
      _sankeyDataSet = null;
    });
  }

  // ---------------------------------------------------------------------------
  // 4. 核心布局算法 (从官方 Demo 抄来的)
  // ---------------------------------------------------------------------------
  SankeyDataSet _computeLayout(Size size) {
    if (_sankeyDataSet != null && _lastLayoutSize == size) {
      return _sankeyDataSet!;
    }

    // 重要：重置节点状态，防止多次 layout 导致坐标错乱
    for (final node in nodes) {
      node.left = 0;
      node.right = 0;
      node.top = 0;
      node.bottom = 0;
      node.sourceLinks = [];
      node.targetLinks = [];
    }

    final sankeyDataSet = SankeyDataSet(nodes: nodes, links: links);

    // 调用库的算法计算坐标
    final sankey = generateSankeyLayout(
      width: size.width,
      height: size.height,
      nodeWidth: 30, // 节点宽度
      nodePadding: 20, // 节点间距
    );

    sankeyDataSet.layout(sankey); // <--- 这行代码之前漏了！

    _lastLayoutSize = size;
    _sankeyDataSet = sankeyDataSet;
    return sankeyDataSet;
  }

  void _handleNodeSelected(SankeyNode? node) {
    setState(() {
      selectedNode = node;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(child: Text("暂无数据"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 40;
        // 动态计算高度
        double estimatedHeight = (nodes.length * 40.0).clamp(400.0, 800.0);
        final size = Size(width, estimatedHeight);

        // 计算布局数据
        final sankeyDataSet = _computeLayout(size);
        final appColors = Theme.of(context).extension<AppThemeColors>()!;

        return Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: const JournalNavBar(title: "桑基图"),
          body: Center(
            child: SankeyDiagramWidget(
              data: sankeyDataSet, // 传入计算好坐标的数据
              nodeColors: nodeColors, // 传入 label->color 映射
              selectedNodeId: selectedNode?.id,
              onNodeSelected: _handleNodeSelected,
              size: size,
              showLabels: true,
              showTexture: false,
            ),
          ),
        );
      },
    );
  }
}
