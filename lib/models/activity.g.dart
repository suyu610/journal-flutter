// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      userId: json['userId'] as String,
      creatorName: json['creatorName'] as String,
      activityName: json['activityName'] as String,
      activityId: json['activityId'] as String,
      budget: json['budget'] as num?,
      budgetType: json['budgetType'] as String?,
      remainingBudget: json['remainingBudget'] as num?,
      todayExpense: json['todayExpense'] as num?,
      weekExpense: json['weekExpense'] as num?,
      monthExpense: json['monthExpense'] as num?,
      activated: json['activated'] as bool,
      createTime: json['createTime'] as String,
      totalExpense: json['totalExpense'] as num?,
      totalIncome: json['totalIncome'] as num?,
      updateTime: json['updateTime'] as String?,
      expenseList: (json['expenseList'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      userList: (json['userList'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'activityName': instance.activityName,
      'activityId': instance.activityId,
      'userId': instance.userId,
      'budget': instance.budget,
      'budgetType': instance.budgetType,
      'remainingBudget': instance.remainingBudget,
      'todayExpense': instance.todayExpense,
      'weekExpense': instance.weekExpense,
      'monthExpense': instance.monthExpense,
      'totalExpense': instance.totalExpense,
      'totalIncome': instance.totalIncome,
      'activated': instance.activated,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'creatorName': instance.creatorName,
      'expenseList': instance.expenseList,
      'userList': instance.userList,
    };
