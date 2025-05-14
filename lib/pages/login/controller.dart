
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  var agreeLisence = false.obs;
  LoginController();

  _initData() async {
    update(["login"]);

  }

  RxString telephone = "".obs;
  void onLogin() {
    if (!agreeLisence.value) {
      ToastUtil.showSnackBar("错误", "请先同意用户协议");
      return;
    }
    if (telephone.value == "") {
      ToastUtil.showSnackBar("错误", "手机号不能为空");
      return;
    }
    // 检查手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(telephone.value)) {
      ToastUtil.showSnackBar("错误", "手机号格式不正确");
      return;
    }

    HttpRequest.request(
      Method.post,
      "/user/login?telephone=${telephone.value}",
      success: (data) {
        Log().d("登陆成功:$data");
        SpUtil.setToken(data.toString());

        Get.offAllNamed(Routers.LayoutPageUrl);
      },
      fail: (code, msg) {},
    );
  }

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void alipay() async {
    String url =
        'alipays://platformapi/startapp?appId=2021001104615521&page=pages/orderDetail/orderDetail&thirdPartSchema=journal%3A%2F%2Fgoods%2F&query=payinfo%3D%257B%2522appid%2522%253A%252200324623%2522%252C%2522body%2522%253A%2522%25E6%25B5%258B%25E8%25AF%2595%25E5%258D%2595%25E8%25A7%2584%25E6%25A0%25BC%25E5%2595%2586%25E5%2593%25810009%25EF%25BC%2588%25E8%25BF%259B%25E5%25BA%25A6%25E9%2580%259A%25E7%259F%25A5%25EF%25BC%2589%25E6%2594%25AF%25E4%25BB%2598%2522%252C%2522cusid%2522%253A%252256345807392LAS3%2522%252C%2522expiretime%2522%253A%252220241016095006%2522%252C%2522notify_url%2522%253A%2522https%253A%252F%252Fzgj.zgxiaochengxu.com%252Faddons%252Fshopro%252Fpay%252FnotifyTongLian%253Fpay_type%253Dalipay%2522%252C%2522paytype%2522%253A%2522A02%2522%252C%2522randomstr%2522%253A%252212345678910%2522%252C%2522reqsn%2522%253A%2522202405365798686273098900%2522%252C%2522signtype%2522%253A%2522RSA%2522%252C%2522trxamt%2522%253A%25221%2522%252C%2522validtime%2522%253A%252260%2522%252C%2522version%2522%253A%252212%2522%252C%2522sign%2522%253A%2522uPOty%252FQJLGaNhfgtU05P20%252BTY9RMCBTK72O5QLNMKlf4y%252BIZVIWLQ0PRe2U2AFGRTE3G%252BAwcqxGjgczzw0Bmem37LFsNCgaMnuCywHRtZJim%252BdGstcJoWP%252B%252BCzOO4XHoUJ3jRqaVwuQx0SfH1DGuginSFK6o4UED6fqqpY7NDikgHuz8nTsV%252Fg5Xkc3N%252FqqG6ssM9ip4j1r3TOkR100jvVNdKrPNv32qIdiuM2EkWtn3pBXmb9RvV8BbNjmjXFRDjZ%252FozAT7i35JsVVPbd48pMmdCEeZDquEBBZDtvL91Xly72HK%252B0EEjCUIDxy0Z6XA7xBKyxUVH9%252F4jYciT2Fx5A%253D%253D%2522%257D';

    // url = "journal://goods";
    await launch(url);

    if (await canLaunch(url)) {
    } else {
      print('Could not launch $url');
    }
  }

  void switchAgreeLisence() {
    agreeLisence.value = !agreeLisence.value;
    update(["login"]);
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
