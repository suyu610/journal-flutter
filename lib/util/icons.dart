import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class CategoryIconMap {
  // 定义静态 Map，包含市面上绝大多数分类场景
  // 全部使用 Remix Icon 的 Line 风格
  static final Map<String, IconData> _categoryIcons = {
    // ================== 餐饮美食 ==================
    '餐饮': Remix.restaurant_2_line,
    '美食': Remix.restaurant_2_line,
    '吃饭': Remix.knife_blood_line, // 或者 restaurant_line
    '早餐': Remix.bread_line, // 面包代表早餐
    '早点': Remix.bread_line,
    '午餐': Remix.sun_line, // 中午
    '晚餐': Remix.moon_line, // 晚上
    '夜宵': Remix.goblet_line, // 此时通常伴随酒水
    '外卖': Remix.takeaway_line,
    '零食': Remix.cake_3_line,
    '小吃': Remix.cake_3_line,
    '饮料': Remix.cup_line,
    '奶茶': Remix.cup_fill, // 奶茶通常是实心的感觉，或者用 cup_line
    '咖啡': Remix.cup_line,
    '酒水': Remix.goblet_line,
    '酒吧': Remix.goblet_line,
    '烟酒': Remix.fire_line, // 烟火
    '买菜': Remix.shopping_basket_2_line,
    '食材': Remix.knife_line,
    '蔬菜': Remix.leaf_line, // 叶子代表蔬菜
    '水果': Remix.apple_line, // 苹果代表水果

    // ================== 购物消费 ==================
    '购物': Remix.shopping_bag_3_line,
    '超市': Remix.shopping_cart_2_line,
    '便利店': Remix.store_2_line,
    '日用品': Remix.store_3_line, // 或者 store_line
    '杂货': Remix.function_line,
    '衣服': Remix.t_shirt_line,
    '服饰': Remix.t_shirt_line,
    '服装': Remix.t_shirt_line,
    '鞋帽': Remix.shirt_line, // Remix 没鞋子，用衬衫泛指，或者 footprints
    '鞋子': Remix.footprint_line,
    '包包': Remix.handbag_line,
    '化妆品': Remix.brush_line, // 化妆刷
    '护肤': Remix.drop_line, // 精华液水滴
    '美妆': Remix.magic_line, // 变美魔法棒
    '珠宝': Remix.vip_diamond_line,
    '首饰': Remix.vip_diamond_line,
    '数码': Remix.macbook_line,
    '电子': Remix.cpu_line,
    '手机': Remix.smartphone_line,
    '电脑': Remix.computer_line,
    '相机': Remix.camera_3_line,
    '摄影': Remix.camera_lens_line,
    '家电': Remix.tv_2_line,
    '家具': Remix.armchair_line, // 沙发
    '家居': Remix.home_5_line,
    '玩具': Remix.bear_smile_line, // 小熊
    '鲜花': Remix.plant_line,
    '母婴': Remix.parent_line,

    // ================== 交通出行 ==================
    '交通': Remix.steering_2_line,
    '打车': Remix.taxi_line,
    '出租车': Remix.taxi_line,
    '网约车': Remix.taxi_wifi_line,
    '公交': Remix.bus_2_line,
    '地铁': Remix.subway_line,
    '火车': Remix.train_line,
    '高铁': Remix.train_line,
    '飞机': Remix.plane_line,
    '机票': Remix.flight_takeoff_line,
    '加油': Remix.gas_station_line,
    '油费': Remix.gas_station_line,
    '充电': Remix.charging_pile_2_line, // 充电桩
    '停车': Remix.parking_box_line,
    '停车费': Remix.parking_box_line,
    '修车': Remix.tools_line, // 扳手
    '保养': Remix.tools_line,
    '过路费': Remix.road_map_line,
    '高速费': Remix.road_map_line,
    '单车': Remix.riding_line, // 骑行
    '买车': Remix.car_line,

    // ================== 居家物业 ==================
    '房租': Remix.home_heart_line,
    '租房': Remix.key_2_line,
    '房贷': Remix.bank_card_line,
    '买房': Remix.building_4_line,
    '水电': Remix.water_flash_line,
    '电费': Remix.lightbulb_line,
    '水费': Remix.drop_line,
    '燃气': Remix.fire_line,
    '煤气': Remix.fire_line,
    '暖气': Remix.temp_hot_line,
    '物业': Remix.community_line,
    '物业费': Remix.community_line,
    '宽带': Remix.router_line,
    '网费': Remix.wifi_line,
    '话费': Remix.phone_line,
    '维修': Remix.hammer_line,
    '装修': Remix.paint_brush_line,

    // ================== 娱乐休闲 ==================
    '娱乐': Remix.gamepad_line,
    '玩乐': Remix.mickey_line, // 迪士尼风格
    '游戏': Remix.gamepad_line,
    '充值': Remix.coin_line,
    '电影': Remix.movie_2_line,
    '追剧': Remix.film_line,
    '会员': Remix.vip_crown_2_line,
    '订阅': Remix.calendar_check_line,
    'KTV': Remix.mic_line,
    '唱歌': Remix.mic_2_line,
    '演出': Remix.mv_line,
    '展览': Remix.gallery_line,
    '旅游': Remix.suitcase_line,
    '度假': Remix.landscape_line,
    '住宿': Remix.hotel_bed_line,
    '酒店': Remix.building_2_line,
    '门票': Remix.ticket_2_line,
    '景点': Remix.camera_3_line,

    // ================== 医疗健康 ==================
    '医疗': Remix.health_book_line,
    '看病': Remix.stethoscope_line, // 听诊器
    '医院': Remix.hospital_line,
    '药品': Remix.medicine_bottle_line,
    '买药': Remix.capsule_line,
    '体检': Remix.pulse_line,
    '牙科': Remix.open_arm_line, // 其实 Remix 没牙齿，可以用 smile 代替
    '运动': Remix.run_line,
    '健身': Remix.dribbble_line, // 篮球
    '瑜伽': Remix.women_line,
    '美容': Remix.magic_line,
    '美发': Remix.scissors_cut_line,
    '理发': Remix.scissors_line,

    // ================== 教育学习 ==================
    '学习': Remix.book_read_line,
    '教育': Remix.graduation_cap_line,
    '学费': Remix.bank_card_2_line,
    '书籍': Remix.book_2_line,
    '买书': Remix.book_3_line,
    '培训': Remix.presentation_line,
    '课程': Remix.graduation_cap_line,
    '考试': Remix.file_paper_2_line,
    '文具': Remix.pencil_ruler_2_line,

    // ================== 人情社交 ==================
    '社交': Remix.chat_3_line,
    '请客': Remix.goblet_line,
    '聚餐': Remix.team_line,
    '红包': Remix.red_packet_line,
    '送礼': Remix.gift_2_line,
    '礼物': Remix.gift_line,
    '孝敬': Remix.emotion_happy_line,
    '长辈': Remix.user_heart_line,
    '恋爱': Remix.heart_3_line,
    '约会': Remix.hearts_line,

    // ================== 家庭宠物 ==================
    '宠物': Remix.bear_smile_line, // 泛指动物
    '猫粮': Remix.github_line, // Remix 的 github 图标是猫猫头，借用一下
    '宠物医院': Remix.first_aid_kit_line,
    '孩子': Remix.user_smile_line,
    '小孩': Remix.mickey_line,
    '奶粉': Remix.cup_line,
    '尿布': Remix.delete_bin_line, // 有点奇怪，可以用 baby_carriage 如果有

    // ================== 金融保险 ==================
    '保险': Remix.shield_check_line,
    '理财': Remix.funds_line,
    '基金': Remix.line_chart_line,
    '股票': Remix.stock_line,
    '手续费': Remix.percent_line,
    '还款': Remix.hand_coin_line,
    '信用卡': Remix.bank_card_line,
    '捐赠': Remix.heart_add_line,
    '公益': Remix.hand_heart_line,
    '罚款': Remix.alarm_warning_line,
    '丢钱': Remix.emotion_unhappy_line,
    '燃料': Remix.fire_line,

    // ================== 快递通讯 ==================
    '通讯': Remix.phone_line,
    '快递': Remix.truck_line,
    '邮费': Remix.mail_send_line,

    // ================== 收入来源 ==================
    '工资': Remix.wallet_2_line,
    '薪水': Remix.money_cny_box_line,
    '奖金': Remix.trophy_line,
    '年终奖': Remix.medal_line,
    '兼职': Remix.briefcase_line,
    '副业': Remix.computer_line,
    '外快': Remix.coin_line,
    '分红': Remix.pie_chart_line,
    '利息': Remix.percent_line,
    '投资收益': Remix.funds_box_line,
    '生活费': Remix.hand_coin_line,
    '退款': Remix.refund_2_line,
    '中奖': Remix.gift_2_line,
    '意外所得': Remix.treasure_map_line,
    '报销': Remix.file_list_3_line,
    '借入': Remix.login_box_line,
    '回收': Remix.recycle_line,
    '二手': Remix.exchange_line,
    '编程': Remix.code_s_slash_line,
  };

  /// 根据类型名称获取图标
  /// 优化了匹配逻辑，增加 "最长匹配原则"
  static IconData getIcon(String type) {
    if (type.isEmpty) return Remix.function_line; // 默认图标

    // 1. 精确匹配 (最快)
    if (_categoryIcons.containsKey(type)) {
      return _categoryIcons[type]!;
    }

    // 2. 模糊匹配 (包含关键词)
    // 策略：按 Key 的长度降序排列。
    // 目的：防止 "宠物医院" 匹配到 "宠物" 而不是 "宠物医院" (如果有这个key的话)
    // 虽然目前 Map 里 key 大多是双字，但这个逻辑更健壮
    var keys = _categoryIcons.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (var key in keys) {
      if (type.contains(key)) {
        return _categoryIcons[key]!;
      }
    }

    // 3. 兜底逻辑：反向包含 (处理用户输入极短的情况)
    // 比如用户输入 "猫"，Map里有 "猫粮"，这时候给它一个相关图标总比没有好
    for (var entry in _categoryIcons.entries) {
      if (entry.key.contains(type)) {
        return entry.value;
      }
    }

    // 4. 实在找不到，返回一个通用的标签图标
    return Remix.price_tag_3_line;
  }
}
