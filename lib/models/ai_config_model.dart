class UserAIConfig {
  String characterCode; // "Hiyori", "Haru"
  String userAppellation; // "哥哥"
  String openingStatement; // "今天也要加油"
  String relationship;
  String personality;
  String? themeColorHex;
  String customName;
  String specialConfig;
  UserAIConfig({
    this.characterCode = "Hiyori",
    this.userAppellation = "主人",
    this.openingStatement = "你好呀",
    this.relationship = "助理",
    this.personality = "温柔",
    this.customName = "",
    this.themeColorHex,
    this.specialConfig = "",
  });

  factory UserAIConfig.fromJson(Map<String, dynamic> json) {
    return UserAIConfig(
      characterCode: json['characterCode'] ?? "Hiyori",
      userAppellation: json['userAppellation'] ?? "主人",
      openingStatement: json['openingStatement'] ?? "你好呀",
      relationship: json['relationship'] ?? "助理",
      personality: json['personality'] ?? "温柔",
      customName: json['customName'] ?? "",
      themeColorHex: json['themeColorHex'],
      specialConfig: json['specialConfig'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'characterCode': characterCode,
      'userAppellation': userAppellation,
      'openingStatement': openingStatement,
      'relationship': relationship,
      'personality': personality,
      'customName': customName,
      'themeColorHex': themeColorHex,
      'specialConfig': specialConfig,
    };
  }
}
