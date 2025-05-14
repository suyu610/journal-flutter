// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      expenseId: json['expenseId'] as String,
      type: json['type'] as String,
      price: json['price'] as num,
      label: json['label'] as String,
      userId: json['userId'] as String,
      activityId: json['activityId'] as String,
      userNickname: json['userNickname'] as String,
      userAvatar: json['userAvatar'] as String,
      expenseTime: json['expenseTime'] as String,
      createTime: json['createTime'] as String,
      updateTime: json['updateTime'] as String?,
      positive: json['positive'] as int,
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'expenseId': instance.expenseId,
      'type': instance.type,
      'price': instance.price,
      'label': instance.label,
      'userId': instance.userId,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      "activityId": instance.activityId,
      "positive": instance.positive,
      "expenseTime": instance.expenseTime,
    };
