// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      activityName: json['activityName'] as String,
      userId: json['userId'] as String,
      activityId: json['activityId'] as String,
      budget: json['budget'] as num?,
      remainingBudget: json['remainingBudget'] as num?,
      activated: json['activated'] as bool,
      createTime: json['createTime'] as String,
      creatorName: json['creatorName'] as String,
      updateTime: json['updateTime'] as String?,
      totalExpense: json['totalExpense'] as num?,
      totalIncome: json['totalIncome'] as num?,
      expenseList: (json['expenseList'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      userList: (json['userList'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'activityName': instance.activityName,
      'userId': instance.userId,
      'activityId': instance.activityId,
      'budget': instance.budget,
      'remainingBudget': instance.remainingBudget,
      "totalExpense": instance.totalExpense,
      'activated': instance.activated,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'expenseList': instance.expenseList,
      'userList': instance.userList,
      'creatorName': instance.creatorName,
    };
