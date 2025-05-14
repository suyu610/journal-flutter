import 'package:flutter/material.dart';

IconData getIconByType(String type) {
  switch (type) {
    case "工资":
      return Icons.emoji_nature_outlined;
    case "生活费":
      return Icons.attach_money_outlined;
    case "奖金":
      return Icons.emoji_events_outlined;

    case "副业":
    case "兼职":
      return Icons.work_outline;
    case "报销":
      return Icons.money_off_outlined;
    case "理财":
    case "投资收益":
      return Icons.show_chart;
    case "红包":
      return Icons.savings_outlined;
    case "退款":
      return Icons.money_off_outlined;
    case "意外所得":
      return Icons.money_off_outlined;
    case "其他收入":
      return Icons.money_off_outlined;
    case "交通罚款":
      return Icons.directions_car_outlined;

    case '餐饮':
    case '美食':
      return Icons.fastfood_outlined;
    case '交通':
      return Icons.directions_car_outlined;
    case "燃料":
      return Icons.local_gas_station_outlined;
    case "社交":
      return Icons.people_outline;
    case '购物':
      return Icons.shopping_cart_outlined;
    case '娱乐':
      return Icons.snowboarding_outlined;
    case "旅游":
      return Icons.airplanemode_active;
    case '日用品':
      return Icons.local_grocery_store_outlined;
    case "宠物":
      return Icons.pets_outlined;
    case '零食':
      return Icons.fastfood_outlined;
    case "化妆品":
      return Icons.face_outlined;
    case '电话费':
    case '通讯':
      return Icons.phone;
    case "药品":
    case '医疗':
      return Icons.local_hospital_outlined;
    case '烟酒':
      return Icons.smoking_rooms_outlined;
    case "美容美发":
      return Icons.face;
    case "生活缴费":
      return Icons.payment;
    case "房租":
    case "住房":
      return Icons.house_outlined;
    case "运动":
      return Icons.directions_run;
    case "学习":
      return Icons.school;
    case "旅行":
      return Icons.airplanemode_active;
    case "数码":
      return Icons.computer;
    case "办公":
      return Icons.work;
    case "投资":
      return Icons.attach_money;
    case "还款":
      return Icons.payment;

    case "保险":
      return Icons.security;
    case "其他":
      return Icons.category;
    case "服装":
      return Icons.cruelty_free_outlined;
    case "捐赠":
      return Icons.favorite_border;
  }

  return Icons.category;
}
