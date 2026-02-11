// models/merge_candidate.dart
import 'package:journal/models/expense.dart';

class MergeCandidate {
  final String sourceName;
  final int count;
  final List<Expense> previewItems;
  bool isSelected; // 可变状态
  // toString
  @override
  String toString() {
    return 'MergeCandidate{sourceName: $sourceName, count: $count, previewItems: $previewItems, isSelected: $isSelected}';
  }

  MergeCandidate({
    required this.sourceName,
    required this.count,
    required this.previewItems,
    this.isSelected = true,
  });

  factory MergeCandidate.fromJson(Map<String, dynamic> json) {
    return MergeCandidate(
      sourceName: json['sourceName'] ?? '',
      count: json['count'] ?? 0,
      previewItems: (json['previewItems'] as List?) // 增加空安全判断
              ?.map((e) => Expense.fromJson(e))
              .toList() ??
          [],
      isSelected: true,
    );
  }
}

class MergeSuggestion {
  String? id;
  String targetName;
  final String reason;
  final List<MergeCandidate> candidates;
  // toString
  @override
  String toString() {
    return 'MergeSuggestion{id: $id, targetName: $targetName, reason: $reason, candidates: $candidates}';
  }

  MergeSuggestion({
    this.id,
    required this.targetName,
    required this.reason,
    required this.candidates,
  });

  factory MergeSuggestion.fromJson(Map<String, dynamic> json) {
    return MergeSuggestion(
      id: json['id'],
      targetName: json['targetName'] ?? '',
      reason: json['reason'] ?? '',
      candidates: (json['candidates'] as List?)
              ?.map((e) => MergeCandidate.fromJson(e))
              .toList() ??
          [],
    );
  }
}
