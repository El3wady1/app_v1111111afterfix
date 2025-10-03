import 'package:inventory/core/utils/localls.dart';
import 'package:inventory/features/home/data/services/ReturnLastloginService.dart';
import 'package:inventory/features/profile/data/services/getUserProfileService.dart';

class ReturnLastloginRepo {
  static Future featchData() async {
    var token = await Localls.getToken();

    print("Localls Token : $token");

    final userData = await GetReturnLastlogin(token: "$token");

    return userData;
  }
}
