// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      openid: json['openid'] as String?,
      vip: json['vip'] as bool,
      telephone: json['telephone'] as String?,
      avatarUrl: json['avatarUrl'] as String,
      createTime: json['createTime'] as String,
      openingStatement: json['openingStatement'] as String?,
      salutation: json['salutation'] as String?,
      relationship: json['relationship'] as String?,
      personality: json['personality'] as String?,
      aiAvatarUrl: json['aiAvatarUrl'] as String?,
      currentActivityId: json['currentActivityId'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'openid': instance.openid,
      'vip': instance.vip,
      'telephone': instance.telephone,
      'avatarUrl': instance.avatarUrl,
      "createTime": instance.createTime,
      'openingStatement': instance.openingStatement,
      'salutation': instance.salutation,
      'relationship': instance.relationship,
      'personality': instance.personality,
      'aiAvatarUrl': instance.aiAvatarUrl,
      'currentActivityId': instance.currentActivityId,
    };
