// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      expenseTime: json['expenseTime'] as String,
      expenseId: json['expenseId'] as String,
      type: json['type'] as String,
      price: json['price'] as num,
      originalPrice: json['originalPrice'] as num?,
      label: json['label'] as String,
      userId: json['userId'] as String,
      createTime: json['createTime'] as String,
      userNickname: json['userNickname'] as String?,
      userAvatar: json['userAvatar'] as String?,
      activityId: json['activityId'] as String,
      positive: (json['positive'] as num).toInt(),
      updateTime: json['updateTime'] as String?,
      fileList: (json['fileList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'expenseId': instance.expenseId,
      'type': instance.type,
      'price': instance.price,
      'label': instance.label,
      'originalPrice': instance.originalPrice,
      'userId': instance.userId,
      'expenseTime': instance.expenseTime,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'userNickname': instance.userNickname,
      'userAvatar': instance.userAvatar,
      'activityId': instance.activityId,
      'positive': instance.positive,
      'fileList': instance.fileList,
    };
