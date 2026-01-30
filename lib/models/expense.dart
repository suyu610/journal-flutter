import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  String expenseId;
  String type;
  num price;
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
