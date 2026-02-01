import 'dart:ui';

class AICharacter {
  final String id;
  final String name;
  final String description;
  final List<Color> bgColors; // 背景渐变
  final Color themeColor; // 主题色
  final String defaultSalutation;
  final String defaultRelationship;
  final String defaultPersonality;
  final String defaultOpening;

  const AICharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.bgColors,
    required this.themeColor,
    required this.defaultSalutation,
    required this.defaultRelationship,
    required this.defaultPersonality,
    required this.defaultOpening,
  });
}

// 静态数据源：以后想加角色改这里就行，不用动 Controller
class CharacterPresets {
  static const List<AICharacter> list = [
    AICharacter(
      id: "Hiyori",
      name: "元气管家·小日和",
      description: "充满活力的邻家妹妹，治愈你的每一笔烂账。",
      bgColors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
      themeColor: Color(0xFFFF758C),
      defaultSalutation: "欧尼酱",
      defaultRelationship: "邻家妹妹",
      defaultPersonality: "元气",
      defaultOpening: "今天也要元气满满地记账哦！",
    ),
    AICharacter(
      id: "Haru",
      name: "严谨助教·小春",
      description: "温柔但严格的私人秘书，帮你打理财务细节。",
      bgColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      themeColor: Color(0xFF00C6FB),
      defaultSalutation: "主人",
      defaultRelationship: "私人秘书",
      defaultPersonality: "温柔严谨",
      defaultOpening: "这是今天的账单分析，请过目。",
    ),
    AICharacter(
      id: "Mao",
      name: "毒舌财迷·Mao",
      description: "傲娇的理财专家，看着你的钱包防止你乱花钱。",
      bgColors: [Color(0xFFfa709a), Color(0xFFfee140)],
      themeColor: Color(0xFFFA709A),
      defaultSalutation: "笨蛋",
      defaultRelationship: "欢喜冤家",
      defaultPersonality: "傲娇毒舌",
      defaultOpening: "哈？你又乱花钱了？",
    ),
    AICharacter(
      id: "Natori",
      name: "精英顾问·Natori",
      description: "冷静的数据分析师，用绝对理性帮你规划每一分钱。",
      // 商务蓝绿配色，体现专业与冷静
      bgColors: [Color(0xFF134E5E), Color(0xFF71B280)],
      themeColor: Color(0xFF0F2027),
      defaultSalutation: "BOSS",
      defaultRelationship: "首席财务官",
      defaultPersonality: "高冷理性",
      defaultOpening: "根据报表显示，你最近的恩格尔系数有点高。",
    ),
    AICharacter(
      id: "Wanko",
      name: "护财神犬·Wanko",
      description: "忠诚的看门狗，谁也别想从你口袋里乱掏钱！",
      // 柴犬色，土黄暖色系
      bgColors: [Color(0xFFCAC531), Color(0xFFF3F9A7)],
      themeColor: Color(0xFFD4AC0D),
      defaultSalutation: "汪！",
      defaultRelationship: "金库守卫",
      defaultPersonality: "忠诚",
      defaultOpening: "汪汪！（警告：检测到不必要的消费冲动！）",
    ),
    AICharacter(
      id: "tororo", // 注意：有些资源包里文件名是小写，这里ID保持一致方便加载
      name: "招财白猫·Tororo",
      description: "高贵的招财猫，只有存钱罐满了它才会正眼看你。",
      // 纯净的白色/银灰/淡蓝，体现高冷软萌
      bgColors: [Color(0xFFE6E9F0), Color(0xFFEEF1F5)],
      themeColor: Color(0xFFBDC3C7),
      defaultSalutation: "人类",
      defaultRelationship: "猫主子",
      defaultPersonality: "慵懒",
      defaultOpening: "喵~（把买猫粮剩下的钱都存起来，懂？）",
    )
  ];
}
