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
  String userNickname;
  String userAvatar;
  String activityId;
  int positive;
  @override
  toString() {
    return 'Expense{expenseId: $expenseId, type: $type, price: $price, label: $label, userId: $userId, createTime: $createTime, updateTime: $updateTime, userNickname: $userNickname, userAvatar: $userAvatar, activityId: $activityId},positive: $positive';
  }

  Expense({
    required this.expenseTime,
    required this.expenseId,
    required this.type,
    required this.price,
    required this.label,
    required this.userId,
    required this.createTime,
    required this.userNickname,
    required this.userAvatar,
    required this.activityId,
    required this.positive,
    this.updateTime,
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
        positive: 0);
  }
}
