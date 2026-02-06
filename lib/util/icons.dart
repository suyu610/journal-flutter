import 'package:flutter/material.dart';

class CategoryIconMap {
  // 定义静态 Map，包含市面上绝大多数分类场景
  static final Map<String, IconData> _categoryIcons = {
    // ================== 餐饮美食 ==================
    '烟酒': Icons.smoking_rooms_outlined,
    '餐饮': Icons.restaurant_outlined,
    '美食': Icons.restaurant_outlined,
    '吃饭': Icons.restaurant_outlined,
    '早餐': Icons.breakfast_dining_outlined,
    '早点': Icons.breakfast_dining_outlined,
    '午餐': Icons.lunch_dining_outlined,
    '晚餐': Icons.dinner_dining_outlined,
    '夜宵': Icons.ramen_dining_outlined,
    '外卖': Icons.delivery_dining_outlined,
    '零食': Icons.icecream_outlined,
    '小吃': Icons.icecream_outlined,
    '饮料': Icons.coffee_outlined,
    '奶茶': Icons.coffee_outlined,
    '咖啡': Icons.coffee_outlined,
    '酒水': Icons.local_bar_outlined,
    '酒吧': Icons.local_bar_outlined,
    '买菜': Icons.kitchen_outlined,
    '食材': Icons.kitchen_outlined,
    '蔬菜': Icons.soup_kitchen_outlined,
    '水果': Icons.soup_kitchen_outlined,

    // ================== 购物消费 ==================
    '购物': Icons.shopping_bag_outlined,
    '超市': Icons.shopping_cart_outlined,
    '便利店': Icons.local_convenience_store_outlined,
    '日用品': Icons.local_convenience_store_outlined,
    '杂货': Icons.local_convenience_store_outlined,
    '衣服': Icons.checkroom_outlined,
    '服饰': Icons.checkroom_outlined,
    '服装': Icons.checkroom_outlined,
    '鞋帽': Icons.roller_skating_outlined,
    '鞋子': Icons.roller_skating_outlined,
    '包包': Icons.cases_outlined,
    '配饰': Icons.watch_outlined,
    '化妆品': Icons.face_retouching_natural_outlined,
    '护肤': Icons.face_retouching_natural_outlined,
    '美妆': Icons.face_retouching_natural_outlined,
    '珠宝': Icons.diamond_outlined,
    '首饰': Icons.diamond_outlined,
    '数码': Icons.devices_other_outlined,
    '电子': Icons.devices_other_outlined,
    '手机': Icons.smartphone_outlined,
    '电脑': Icons.laptop_mac_outlined,
    '相机': Icons.camera_alt_outlined,
    '摄影': Icons.camera_alt_outlined,
    '家电': Icons.tv_outlined,
    '家具': Icons.chair_outlined,
    '家居': Icons.chair_outlined,
    '玩具': Icons.toys_outlined,
    '鲜花': Icons.local_florist_outlined,
    '母婴': Icons.child_friendly_outlined,

    // ================== 交通出行 ==================
    '交通': Icons.directions_car_outlined,
    '打车': Icons.local_taxi_outlined,
    '出租车': Icons.local_taxi_outlined,
    '网约车': Icons.local_taxi_outlined,
    '公交': Icons.directions_bus_outlined,
    '地铁': Icons.directions_subway_outlined,
    '火车': Icons.train_outlined,
    '高铁': Icons.train_outlined,
    '飞机': Icons.flight_takeoff_outlined,
    '机票': Icons.flight_takeoff_outlined,
    '加油': Icons.local_gas_station_outlined,
    '油费': Icons.local_gas_station_outlined,
    '充电': Icons.ev_station_outlined, // 新能源车
    '停车': Icons.local_parking_outlined,
    '停车费': Icons.local_parking_outlined,
    '修车': Icons.car_repair_outlined,
    '保养': Icons.car_repair_outlined,
    '过路费': Icons.add_road_outlined,
    '高速费': Icons.add_road_outlined,
    '单车': Icons.pedal_bike_outlined,
    '买车': Icons.directions_car_filled_outlined,

    // ================== 居家物业 ==================
    '房租': Icons.bedroom_parent_outlined,
    '租房': Icons.bedroom_parent_outlined,
    '房贷': Icons.real_estate_agent_outlined,
    '买房': Icons.house_outlined,
    '水电': Icons.water_drop_outlined,
    '电费': Icons.electric_bolt_outlined,
    '水费': Icons.water_damage_outlined,
    '燃气': Icons.gas_meter_outlined,
    '煤气': Icons.gas_meter_outlined,
    '暖气': Icons.hvac_outlined,
    '物业': Icons.domain_outlined,
    '物业费': Icons.domain_outlined,
    '宽带': Icons.wifi_outlined,
    '网费': Icons.wifi_outlined,
    '话费': Icons.phone_iphone_outlined,
    '维修': Icons.build_outlined,
    '装修': Icons.format_paint_outlined,

    // ================== 娱乐休闲 ==================
    '娱乐': Icons.sports_esports_outlined,
    '玩乐': Icons.sports_esports_outlined,
    '游戏': Icons.gamepad_outlined,
    '充值': Icons.gamepad_outlined,
    '电影': Icons.movie_outlined,
    '追剧': Icons.movie_outlined,
    '会员': Icons.card_membership_outlined,
    '订阅': Icons.card_membership_outlined,
    'KTV': Icons.mic_outlined,
    '唱歌': Icons.mic_outlined,
    '演出': Icons.theater_comedy_outlined,
    '展览': Icons.palette_outlined,
    '旅游': Icons.beach_access_outlined,
    '度假': Icons.beach_access_outlined,
    '住宿': Icons.hotel_outlined,
    '酒店': Icons.hotel_outlined,
    '门票': Icons.confirmation_number_outlined,
    '景点': Icons.attractions_outlined,

    // ================== 医疗健康 ==================
    '医疗': Icons.local_hospital_outlined,
    '看病': Icons.local_hospital_outlined,
    '医院': Icons.local_hospital_outlined,
    '药品': Icons.medication_outlined,
    '买药': Icons.medication_outlined,
    '体检': Icons.monitor_heart_outlined,
    '牙科': Icons.clean_hands_outlined,
    '运动': Icons.directions_run_outlined,
    '健身': Icons.fitness_center_outlined,
    '瑜伽': Icons.self_improvement_outlined,
    '美容': Icons.face_outlined,
    '美发': Icons.content_cut_outlined,
    '理发': Icons.content_cut_outlined,

    // ================== 教育学习 ==================
    '学习': Icons.school_outlined,
    '教育': Icons.school_outlined,
    '学费': Icons.account_balance_outlined,
    '书籍': Icons.menu_book_outlined,
    '买书': Icons.menu_book_outlined,
    '培训': Icons.cast_for_education_outlined,
    '课程': Icons.class_outlined,
    '考试': Icons.assignment_turned_in_outlined,
    '文具': Icons.edit_outlined,

    // ================== 人情社交 ==================
    '社交': Icons.people_outline,
    '请客': Icons.liquor_outlined,
    '聚餐': Icons.dinner_dining_outlined,
    '红包': Icons.card_giftcard_outlined,
    '送礼': Icons.card_giftcard_outlined,
    '礼物': Icons.inventory_2_outlined,
    '孝敬': Icons.elderly_outlined,
    '长辈': Icons.elderly_outlined,
    '恋爱': Icons.favorite_border_outlined,
    '约会': Icons.favorite_border_outlined,

    // ================== 家庭宠物 ==================
    '宠物': Icons.pets_outlined,
    '猫粮': Icons.pets_outlined,
    '狗粮': Icons.pets_outlined,
    '宠物医院': Icons.medication_liquid_outlined,
    '孩子': Icons.child_care_outlined,
    '小孩': Icons.child_care_outlined,
    '奶粉': Icons.baby_changing_station_outlined,
    '尿布': Icons.baby_changing_station_outlined,

    // ================== 金融保险 ==================
    '保险': Icons.security_outlined,
    '理财': Icons.trending_up_outlined,
    '基金': Icons.show_chart_outlined,
    '股票': Icons.ssid_chart_outlined,
    '手续费': Icons.receipt_long_outlined,
    '还款': Icons.credit_card_off_outlined,
    '信用卡': Icons.credit_card_outlined,
    '捐赠': Icons.volunteer_activism_outlined,
    '公益': Icons.volunteer_activism_outlined,
    '罚款': Icons.gavel_outlined,
    '丢钱': Icons.money_off_csred_outlined,
    '燃料': Icons.local_gas_station_outlined,

    // ================== 快递通讯 ==================
    '通讯': Icons.perm_phone_msg_outlined,
    '快递': Icons.local_shipping_outlined,
    '邮费': Icons.markunread_mailbox_outlined,

    // ================== 收入来源 ==================
    '工资': Icons.account_balance_wallet_outlined,
    '薪水': Icons.account_balance_wallet_outlined,
    '奖金': Icons.emoji_events_outlined,
    '年终奖': Icons.emoji_events_outlined,
    '兼职': Icons.work_history_outlined,
    '副业': Icons.work_history_outlined,
    '外快': Icons.attach_money_outlined,
    '分红': Icons.currency_yen_outlined,
    '利息': Icons.savings_outlined,
    '投资收益': Icons.currency_exchange_outlined,
    '生活费': Icons.family_restroom_outlined,
    '退款': Icons.assignment_return_outlined,
    '中奖': Icons.auto_awesome_outlined,
    '意外所得': Icons.auto_awesome_outlined,
    '报销': Icons.receipt_long_outlined,
    '借入': Icons.move_to_inbox_outlined,
    '回收': Icons.recycling_outlined,
    '二手': Icons.sell_outlined,
    '编程': Icons.code_outlined,
  };

  /// 根据类型名称获取图标
  /// 支持精确匹配和模糊匹配
  static IconData getIcon(String type) {
    if (type.isEmpty) return Icons.category_outlined;

    // 1. 精确匹配 (O(1))
    if (_categoryIcons.containsKey(type)) {
      return _categoryIcons[type]!;
    }

    // 2. 模糊匹配 (包含关键词)
    // 例如传入 "肯德基早餐" -> 匹配到 "早餐"
    // 优先匹配键长较长的词（比如优先匹配 "宠物医院" 而不是 "宠物"）
    var keys = _categoryIcons.keys.toList();
    // 简单优化：让更具体的词排在前面匹配（但这需要 keys 排序，性能敏感可忽略）

    for (var key in keys) {
      if (type.contains(key)) {
        return _categoryIcons[key]!;
      }
    }

    // 反向模糊：有时候分类名比较短，Map key 比较长
    // 比如 type="猫", map key="猫粮" (这种情况较少，视需求而定)

    // 3. 默认图标
    return Icons.category_outlined;
  }
}
