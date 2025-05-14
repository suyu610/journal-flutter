import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String userId;
  String nickname;
  String? openid;
  bool vip;
  String? telephone;
  String avatarUrl;
  String createTime;
  // 开场白
  String? openingStatement;

  // 称呼
  String? salutation;

  // 关系
  String? relationship;

  // 性格
  String? personality;

  String? aiAvatarUrl;

  String? currentActivityId;


  User(
      {required this.userId,
      required this.nickname,
      required this.createTime,
      this.openid,
      required this.vip,
      this.openingStatement,
      this.salutation,
      this.relationship,
      this.personality,
      this.telephone,
      this.currentActivityId,
      this.aiAvatarUrl,
      required this.avatarUrl});

  // JSON serialization logic
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
