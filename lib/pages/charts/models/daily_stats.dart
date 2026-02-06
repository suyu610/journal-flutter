class DailyStats {
  final double expense; // 支出
  final double income; // 收入
  String date;
  DailyStats({required this.date, this.expense = 0, this.income = 0});

  // 是否有数据
  bool get hasData => expense > 0 || income > 0;
  // 简单的工厂方法
  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      expense: double.tryParse(json['expense']?.toString() ?? '0') ?? 0.0,
      income: double.tryParse(json['income']?.toString() ?? '0') ?? 0.0,
    );
  }
}
