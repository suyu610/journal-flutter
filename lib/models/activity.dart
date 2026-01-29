import 'package:json_annotation/json_annotation.dart';

import 'expense.dart';
import 'user.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  String activityName;
  String activityId;
  String userId;
  num? budget;
  String? budgetType;
  num? remainingBudget;
  num? todayExpense;
  num? weekExpense;
  num? monthExpense;
  num? totalExpense;
  num? totalIncome;
  bool activated;
  String createTime;
  String? updateTime;
  String creatorName;
  List<Expense>? expenseList;
  List<User> userList;

  @override
  String toString() {
    return 'Activity{activityName: $activityName, activityId: $activityId, budget: $budget, remainingBudget: $remainingBudget, activated: $activated, createTime: $createTime, updateTime: $updateTime, expenseList: $expenseList, userList: $userList}';
  }

  static Activity empty() {
    return Activity(
      userId: '',
      activityName: '',
      activityId: '',
      budget: 0,
      budgetType: '',
      remainingBudget: 0,
      activated: false,
      createTime: '',
      expenseList: [],
      userList: [],
      creatorName: "",
    );
  }

  Activity({
    required this.userId,
    required this.creatorName,
    required this.activityName,
    required this.activityId,
    this.budget,
    this.budgetType,
    this.remainingBudget,
    this.todayExpense,
    this.weekExpense,
    this.monthExpense,
    required this.activated,
    required this.createTime,
    this.totalExpense,
    this.totalIncome,
    this.updateTime,
    this.expenseList,
    required this.userList,
  });

  // JSON serialization logic
  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
