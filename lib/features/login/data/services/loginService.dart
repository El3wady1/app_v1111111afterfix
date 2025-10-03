import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory/core/Widgets/showsnackbar.dart';
import 'package:inventory/core/app_router.dart';
import 'package:inventory/core/utils/apiEndpoints.dart';
import 'package:inventory/core/utils/cacheHelper.dart';
import 'package:inventory/core/utils/localls.dart';
import 'package:inventory/features/home/presentation/view/homeView.dart';
import 'package:inventory/features/home/presentation/view/widget/homeBodyView.dart';

Future LoginService(
    {required String password, required BuildContext context}) async {
  final url = Uri.parse(Apiendpoints.baseUrl + Apiendpoints.auth.login);
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({"password": password});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      if (responseData["token"] != null) {
        await Localls.setdepatmentid(
            depatmentid: responseData["data"]["department"][0].toString());
        await Localls.setUserID(userId: responseData["data"]["_id"].toString());
        await Localls.setToken(token: responseData["token"]);

 await Cachehelper().fetchDataandStoreLocaallly();
        
        print('Success: ${responseData["token"]}');
        Routting.pushreplaced(context, Homeview());

        showTrueSnackBar(
            context: context,
            message: "تم تسجيل الدخول بنجاح".tr(),
            icon: Icons.check_circle);
      } else {
        showfalseSnackBar(
            context: context,
            message: "حدث خطأ أثناء تسجيل الدخول".tr(),
            icon: Icons.error);
      }
    } else {
      print('Failed: ${response.statusCode}, ${response.body}');
      if (response.body.contains("This account is not exist")) {
        showfalseSnackBar(
            context: context,
            message: "لايوجد مستخدم بهذا الرقم سري".tr(),
            icon: Icons.person);
      } else if (response.body.contains("your Account is Not Active")) {
        showfalseSnackBar(
            context: context,
            message: "هذا المستخدم موجود بالفعل لكن غير مفعل".tr(),
            icon: Icons.error);
      }else if (response.body.contains("<!DOCTYPE html>")) {
        showfalseSnackBar(
            context: context,
            message: "السرفر لا يعمل".tr(),
            icon: Icons.error);
      }
    }
  } catch (e) {
    showfalseSnackBar(
        context: context,
        message: "تفقد اتصالك بالانترنت".tr(),
        icon: Icons.wifi_off);
    print('LoginService Error: ${e.toString()}');
  }
}
