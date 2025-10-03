import 'package:inventory/core/utils/localls.dart';
import 'package:inventory/features/profile/data/services/getUserProfileService.dart';

class Getuserprofilerepo {
  static Future<Map<String, dynamic>> featchData() async {
    var token = await Localls.getToken();

    print("Localls Token : $token");

    final userData = await GetUserProfileService(token: "$token");

    return userData;
  }
}
