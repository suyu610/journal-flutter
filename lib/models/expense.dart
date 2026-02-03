import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  String expenseId;
  String type;
  num price;
  // 划线价
  num? originalPrice; // 新增：划线价（原价）
  String label;
  String userId;
  String expenseTime;
  String createTime;
  String? updateTime;
  String? userNickname;
  String? userAvatar;
  String activityId;
  int positive;

  // === 新增：图片列表 ===
  // 使用 List<String>? 允许为空，或者使用 @JsonKey(defaultValue: [])
  List<String>? fileList;

// 计算属性：是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // 计算属性：省了多少钱
  num get savedAmount => hasDiscount ? (originalPrice! - price) : 0;
  @override
  toString() {
    return 'Expense{expenseId: $expenseId, type: $type, price: $price, label: $label, userId: $userId, createTime: $createTime, updateTime: $updateTime, userNickname: $userNickname, userAvatar: $userAvatar, activityId: $activityId, positive: $positive, fileList: $fileList}';
  }

  Expense({
    required this.expenseTime,
    required this.expenseId,
    required this.type,
    required this.price,
    required this.label,
    required this.userId,
    required this.createTime,
    this.userNickname,
    this.originalPrice,
    this.userAvatar,
    required this.activityId,
    required this.positive,
    this.updateTime,
    // === 新增构造参数 ===
    this.fileList,
  });

  // JSON serialization logic
  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  static Expense empty() {
    return Expense(
        originalPrice: null,
        expenseTime: "",
        activityId: '',
        expenseId: '',
        type: '',
        price: 0,
        label: '',
        userId: '',
        createTime: '',
        userNickname: '',
        userAvatar: '',
        positive: 0,
        // === 新增初始化 ===
        fileList: []);
  }
}
