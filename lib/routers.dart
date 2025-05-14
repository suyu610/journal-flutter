import 'package:get/get.dart';
import 'package:journal/pages/activity_list/index.dart';
import 'package:journal/pages/ai_config/view.dart';
import 'package:journal/pages/ai_config_v2/index.dart';
import 'package:journal/pages/auto_write_intro/index.dart';
import 'package:journal/pages/chat/view.dart';
import 'package:journal/pages/create_activity/view.dart';
import 'package:journal/pages/expense/view.dart';
import 'package:journal/pages/expense_category/view.dart';
import 'package:journal/pages/expense_list/index.dart';
import 'package:journal/pages/invite/index.dart';
import 'package:journal/pages/join_activity/view.dart';
import 'package:journal/pages/login/binding.dart';
import 'package:journal/pages/login/index.dart';
import 'package:journal/pages/login/sms_code/binding.dart';
import 'package:journal/pages/login/sms_code/view.dart';
import 'package:journal/pages/tabbar_layout/binding.dart';
import 'package:journal/pages/tabbar_layout/view.dart';
import 'package:journal/pages/webview/webview.dart';

abstract class Routers {
  static const String JoinActivityPageUrl = "/join_activity";
  static const String WebViewPageUrl = "/webview";
  // 自动记账说明页
  static const String AutoWriteIntroPageUrl = "/auto_write_intro";
  // AI设置页V2
  static const String AIConfigPageV2Url = "/ai_config_v2";
  // AI设置页
  static const String AIConfigPageUrl = "/ai_config";
  // 账单列表
  static const String ExpenseListPageUrl = "/expense_list";
  static const String ExpenseItemPageUrl = "/expense_item";

  // 邀请页面
  static const String InvitePageUrl = "/invite";
  // 账单分类
  static const String ExpenseCategoryPageUrl = "/expense_category";

  // 聊天详情页
  static const String ChatDetailPageUrl = "/chat_detail";

  static const String ActivityListPageUrl = "/activity_list";

  // 框架
  static const String LayoutPageUrl = "/layout";

  static const String SplashPageUrl = "/splash";

  // 登录页
  static const String LoginPageUrl = "/login";
  static const String CodePageUrl = "/code";

  // 创建活动
  static const String CreateActivityUrl = "/create_activity";

  static final List<GetPage> routePages = [
    GetPage(name: AIConfigPageV2Url, page: () => const AiConfigV2Page()),
    GetPage(
        name: AutoWriteIntroPageUrl, page: () => const AutowriteintroPage()),
    GetPage(name: WebViewPageUrl, page: () => WebviewPage()),
    GetPage(
        name: ExpenseCategoryPageUrl,
        page: () => const ExpenseCategoryPage(),
        binding: CodeBinding()),
    GetPage(
        name: CodePageUrl,
        page: () => const CodePage(),
        binding: CodeBinding()),
    GetPage(name: JoinActivityPageUrl, page: () => const JoinActivityPage()),
    GetPage(name: InvitePageUrl, page: () => const InvitePage()),
    GetPage(name: ExpenseListPageUrl, page: () => const ExpenseListPage()),
    GetPage(
        name: LoginPageUrl,
        page: () => const LoginPage(),
        binding: LoginBinding()),
    GetPage(name: ChatDetailPageUrl, page: () => ChatPage()),
    GetPage(name: AIConfigPageUrl, page: () => AiConfigPage()),
    GetPage(
      name: ActivityListPageUrl,
      page: () => const ActivityListPage(),
    ),
    GetPage(
      name: ExpenseItemPageUrl,
      page: () => const ExpenseItemPage(),
    ),
    GetPage(name: CreateActivityUrl, page: () => const CreateActivityPage()),
    GetPage(
        name: LayoutPageUrl,
        page: () => const LayoutPage(),
        binding: LayoutBinding())
  ];
}
