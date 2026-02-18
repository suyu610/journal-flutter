import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class TaskIconMapper {
  static IconData getIcon(String? category, String title) {
    // 统一转小写，方便匹配
    final lowerTitle = title.toLowerCase();
    final cat = category?.toUpperCase() ?? '';
    // --- 1. 优先匹配具体的物品名称 ---
    // [证件/文件类]
    if (lowerTitle.contains('护照')) return RemixIcons.passport_line;
    if (lowerTitle.contains('身份证')) return RemixIcons.id_card_line;
    if (lowerTitle.contains('签证')) return RemixIcons.sticky_note_line;
    if (lowerTitle.contains('机票') ||
        lowerTitle.contains('车票') ||
        lowerTitle.contains('门票')) {
      return RemixIcons.ticket_2_line;
    }
    if (lowerTitle.contains('驾照') || lowerTitle.contains('驾驶证')) {
      return RemixIcons.steering_2_line;
    }
    if (lowerTitle.contains('银行卡') || lowerTitle.contains('信用卡')) {
      return RemixIcons.bank_card_line;
    }
    if (lowerTitle.contains('现金') ||
        lowerTitle.contains('money') ||
        lowerTitle.contains('人民币')) {
      return RemixIcons.money_cny_box_fill;
    }
    // [电子产品/数码]
    if (lowerTitle.contains('手机') || lowerTitle.contains('iphone')) {
      return RemixIcons.smartphone_line;
    }
    if (lowerTitle.contains('电脑') ||
        lowerTitle.contains('笔记本') ||
        lowerTitle.contains('macbook')) {
      return RemixIcons.macbook_line;
    }
    if (lowerTitle.contains('平板') || lowerTitle.contains('ipad')) {
      return RemixIcons.tablet_line;
    }
    if (lowerTitle.contains('相机') || lowerTitle.contains('单反')) {
      return RemixIcons.camera_3_line;
    }
    if (lowerTitle.contains('镜头')) return RemixIcons.camera_lens_line;
    if (lowerTitle.contains('无人机')) return RemixIcons.plane_line;
    if (lowerTitle.contains('充电宝') || lowerTitle.contains('电池')) {
      return RemixIcons.battery_2_charge_line;
    }
    if (lowerTitle.contains('充电器') ||
        lowerTitle.contains('插头') ||
        lowerTitle.contains('数据线')) {
      return RemixIcons.plug_line;
    }
    if (lowerTitle.contains('耳机') || lowerTitle.contains('airpods')) {
      return RemixIcons.headphone_line;
    }
    if (lowerTitle.contains('鼠标')) return RemixIcons.mouse_line;
    if (lowerTitle.contains('键盘')) return RemixIcons.keyboard_line;
    if (lowerTitle.contains('u盘') ||
        lowerTitle.contains('硬盘') ||
        lowerTitle.contains('存储')) {
      return RemixIcons.save_3_line;
    }
    // [衣物/穿搭]
    if (lowerTitle.contains('外套') ||
        lowerTitle.contains('大衣') ||
        lowerTitle.contains('羽绒服')) {
      return RemixIcons.shirt_line; // 长袖
    }
    if (lowerTitle.contains('短袖') ||
        lowerTitle.contains('t恤') ||
        lowerTitle.contains('衬衫')) {
      return RemixIcons.t_shirt_line;
    }
    if (lowerTitle.contains('裤子') ||
        lowerTitle.contains('牛仔裤') ||
        lowerTitle.contains('短裤')) {
      return RemixIcons.ancient_gate_line; // 这里用个像裤子的抽象图标，或者用 suitcase_line 代替
    }
    if (lowerTitle.contains('内裤') || lowerTitle.contains('内衣')) {
      return RemixIcons.t_shirt_air_line;
    }
    if (lowerTitle.contains('袜子')) return RemixIcons.footprint_line;
    if (lowerTitle.contains('鞋子') ||
        lowerTitle.contains('运动鞋') ||
        lowerTitle.contains('拖鞋')) {
      return RemixIcons.footprint_line;
    }
    if (lowerTitle.contains('帽子') || lowerTitle.contains('鸭舌帽')) {
      return RemixIcons.user_5_line; // 带帽子的头像
    }
    if (lowerTitle.contains('眼镜') || lowerTitle.contains('墨镜')) {
      return RemixIcons.glasses_line;
    }
    if (lowerTitle.contains('手表')) return RemixIcons.time_line;
    if (lowerTitle.contains('项链') ||
        lowerTitle.contains('首饰') ||
        lowerTitle.contains('戒指')) {
      return RemixIcons.diamond_line;
    }
    // [洗漱/护肤/化妆品]
    if (lowerTitle.contains('牙刷') || lowerTitle.contains('牙膏')) {
      return RemixIcons.brush_line;
    }
    if (lowerTitle.contains('毛巾') || lowerTitle.contains('浴巾')) {
      return RemixIcons.sparkling_2_line; // 干净的感觉
    }
    if (lowerTitle.contains('洗面奶') || lowerTitle.contains('洁面')) {
      return RemixIcons.drop_line;
    }
    if (lowerTitle.contains('洗发水') || lowerTitle.contains('沐浴露')) {
      return RemixIcons.hand_sanitizer_line; // 瓶子形状
    }
    if (lowerTitle.contains('护肤') ||
        lowerTitle.contains('水乳') ||
        lowerTitle.contains('面霜')) {
      return RemixIcons.flower_line;
    }
    if (lowerTitle.contains('化妆品') ||
        lowerTitle.contains('口红') ||
        lowerTitle.contains('化妆包')) {
      return RemixIcons.handbag_line;
    }
    if (lowerTitle.contains('梳子')) return RemixIcons.scissors_2_line;
    if (lowerTitle.contains('剃须刀')) return RemixIcons.ruler_line; // 线条感
    if (lowerTitle.contains('防晒霜') || lowerTitle.contains('防晒')) {
      return RemixIcons.sun_line;
    }
    // [药品/健康]
    if (lowerTitle.contains('药') ||
        lowerTitle.contains('止痛') ||
        lowerTitle.contains('感冒') ||
        lowerTitle.contains('布洛芬')) {
      return RemixIcons.medicine_bottle_line;
    }
    if (lowerTitle.contains('创可贴')) return RemixIcons.medicine_bottle_line;
    if (lowerTitle.contains('维生素') || lowerTitle.contains('保健品')) {
      return RemixIcons.capsule_line;
    }
    if (lowerTitle.contains('口罩')) return RemixIcons.surgical_mask_line;
    // [户外/工具/其他]
    if (lowerTitle.contains('雨伞') || lowerTitle.contains('伞')) {
      return RemixIcons.umbrella_line;
    }
    if (lowerTitle.contains('水杯') ||
        lowerTitle.contains('保温杯') ||
        lowerTitle.contains('水壶')) {
      return RemixIcons.cup_line;
    }
    if (lowerTitle.contains('钥匙')) return RemixIcons.key_2_line;
    if (lowerTitle.contains('书') ||
        lowerTitle.contains('本子') ||
        lowerTitle.contains('笔')) {
      return RemixIcons.book_open_line;
    }
    if (lowerTitle.contains('零食') || lowerTitle.contains('吃的')) {
      return Icons.cookie_outlined;
    }
    if (lowerTitle.contains('扑克') || lowerTitle.contains('娱乐')) {
      return RemixIcons.gamepad_line;
    }
    // --- 2. 其次匹配大类 ---
    switch (cat) {
      case '证件':
      case 'DOCUMENT':
      case 'REQUIRED':
        return RemixIcons.passport_line;
      case '电子产品':
      case 'ELECTRONICS':
        return RemixIcons.smartphone_line;
      case '衣物':
      case 'CLOTHES':
        return RemixIcons.t_shirt_line;
      case '药品':
      case 'MEDS':
        return RemixIcons.capsule_line;
      case '洗漱':
      case 'TOILETRIES':
        return RemixIcons.hand_sanitizer_line;
      case '食物':
      case 'FOOD':
        return RemixIcons.restaurant_line;
      case '工具':
      case 'TOOLS':
        return RemixIcons.tools_line;
    }
    // --- 3. 兜底图标 ---
    return RemixIcons.suitcase_line;
  }
}
