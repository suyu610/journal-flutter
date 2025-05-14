import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/pages/login/sms_code/widget/verification_code.dart';

import 'logic.dart';

class CodePage extends StatelessWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CodeLogic>();
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.close,
              size: 35.r,
            ),
          ),
          SizedBox(height: 20.w),
          Text(
            "输入短信验证码",
            style: TextStyle(
              
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.w),
          Text(
            "已向您的手机 ${logic.phoneNum} 发送验证码",
            style: TextStyle(
              
              fontSize: 15.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 30.h),
          VerificationCode(
            autoFocused: true,
            height: 50,
            style: CodeStyle.rectangle,
            maxLength: 4,
            itemWidth: 50,
            itemSpace: 40,
            borderWidth: 1,
            contentSize: 28.sp,
            contentColor: Colors.black,
            borderSelectColor: Colors.black,
            borderColor: Colors.grey.withAlpha(50),
            onCompleted: (String value) {
              logic.codeInputCompleted(code: value);
            },
            onChanged: (value) {
              logic.state.code.value = value;
            },
          ),
          SizedBox(height: 20.w),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    logic.reSendCode();
                  },
                  child: Text(
                    logic.state.countDownNum.value == -1
                        ? "重新发送"
                        : "重新发送(${logic.state.countDownNum.value})s",
                    style: TextStyle(
                      
                      fontSize: 15.sp,
                      color: logic.state.countDownNum.value == -1
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.w),
          Obx(
            () => InkWell(
              onTap: () {
                logic.next(context);
              },
              child: Container(
                height: 40.h,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 20.w, bottom: 30.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.r)),
                    color: logic.codeIsCompleted
                        ? const Color(0xff0052D9)
                        : const Color(0xff0052D9).withAlpha(50)),
                child: Text(
                  "下一步",
                  style: TextStyle(
                    
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.w),
          Row(
            children: [
              Expanded(child: Container()),

            ],
          )
        ],
      ),
    );
  }
}
