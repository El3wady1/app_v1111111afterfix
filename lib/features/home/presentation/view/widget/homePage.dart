import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory/core/Widgets/showsnackbar.dart';
import 'package:inventory/core/app_router.dart';
import 'package:inventory/core/utils/localls.dart';
import 'package:inventory/features/compilations/presentation/view/compilationsView.dart';
import 'package:inventory/features/home/data/repo/ReturnLastloginRepo.dart';
import 'package:inventory/features/home/presentation/view/widget/bannnerHome.dart';
import 'package:inventory/features/home/presentation/view/widget/cardhome.dart';
import 'package:inventory/features/login/presentation/view/loginView.dart';
import 'package:inventory/features/mainProduct/presentation/view/mainProductView.dart';
import 'package:inventory/features/recive/presentation/view/reciveView.dart';
import 'package:inventory/features/scanBarCode/presentation/view/scanbarCodeView.dart';
import 'package:inventory/features/scanBarCode/presentation/view/widget/scanbarCodeOutView.dart';
import 'package:inventory/features/send/presentation/view/sendView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../orderProduction/presentation/view/orderProduction.dart';
import '../../../../orderSupply/presentation/view/orderSupply.dart';
import '../../../../orderSupply/presentation/view/widget/orderSupplyBody.dart';
import '../../../../out/presentation/view/widget/outBodyView.dart';
import '../../../../production/presentation/view/productionView.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;
  final String _userDataKey = 'cached_user_data';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      loadUserData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        final data = await ReturnLastloginRepo.featchData();
        await prefs.setString(_userDataKey, jsonEncode(data));
        if (mounted) {
          setState(() {
            userData = data;
          });
        }
      } catch (e) {
        final cached = prefs.getString(_userDataKey);
        if (cached != null && mounted) {
          setState(() {
            userData = jsonDecode(cached);
          });
        }
      }
    } else {
      final cached = prefs.getString(_userDataKey);
      if (cached != null && mounted) {
        setState(() {
          userData = jsonDecode(cached);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final userName = userData?["name"] ?? "مستخدم";
    final canAddProduct = userData?["canAddProduct"] ?? false;
    final canRemoveProduct = userData?["canRemoveProduct"] ?? false;

    final canProduction = userData?["canProduction"] ?? false;
    final canOrderProduction = userData?["canOrderProduction"] ?? false;
    final canReceive = userData?["canReceive"] ?? false;

    final canSend = userData?["canSend"] ?? false;
    final canSupply = userData?["canSupply"] ?? false;
    final canDamaged = userData?["canDamaged"] ?? false;


    final canEditLastSupply = userData?["canEditLastSupply"] ?? false;
    final canEditLastOrderProduction = userData?["canEditLastOrderProduction"] ?? false;


    const Color primaryDark = Color(0xFF74826A); // Dark green
    const Color accent = Color(0xFFEDBE2C); // Gold/yellow
    const Color neutral = Color(0xFFCDBCA2); // Beige
    const Color background = Color(0xFFF3F4EF); // Light cream

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(
          'الصفحة الرئيسية'.tr(),
          style: GoogleFonts.cairo(),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج'.tr(),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginview()),
                );
                showTrueSnackBar(
                  context: context,
                  message: "تم تسجيل الخروج".tr(),
                  icon: Icons.logout,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bannnerhome(),
            SizedBox(height: height * 0.03),
            Expanded(
              child: GridView.count(
                crossAxisCount: width < 600 ? 2 : 4,
                childAspectRatio: 1.1,
                mainAxisSpacing: width * 0.05,
                crossAxisSpacing: width * 0.05,
                children: [
                  if (canAddProduct)
                    Cardhome(
                      icon: Icons.add_box, // مناسب لإدخال صنف
                      title: 'إدخال صنف'.tr(),
                      color: Colors.green.shade700,
                      onTap: () {
                        Routting.push(
                            context, ScanbarcodeInview(mainProduct: ""));

                        // Routting.push(context, MainCategorySelectionPage());
                      },
                    ),
                  if (canRemoveProduct)
                    Cardhome(
                      icon: Icons.indeterminate_check_box, // مناسب للإخراج
                      title: 'إخراج صنف'.tr(),
                      color: Colors.red.shade700,
                      onTap: () {
                        // Routting.push(context, ScanbarcodeOutbodyview());
                        Routting.push(context, Outbodyview());
                      },
                    ),
                  if (canReceive)
                    Cardhome(
                      icon: Icons.inventory, // استلام
                      title: 'استلام'.tr(),
                      color: Colors.blue.shade700,
                      onTap: () {
                        Routting.push(context, Reciveview());
                      },
                    ),
                  if (canSend)
                    Cardhome(
                      icon: Icons.send_and_archive_outlined, // استلام
                      title: 'ارسال'.tr(),
                      color: Colors.purple.shade700,
                      onTap: () {
                        Routting.push(context, Sendview());
                      },
                    ),
                  if (canSupply)
                    Cardhome(
                      icon: Icons.local_shipping, // أو أيقونة truck
                      title: "توريد".tr(), // المفتاح
                      color: Colors.purple.shade700,
                      onTap: () {
                        Routting.push(context, OrderSupplyBody(canedit: canEditLastSupply,));
                      },
                    ),
                  if (canOrderProduction)
                    Cardhome(
                      icon: Icons.receipt_long, // طلب انتاج
                      title: "طلب إنتاج".tr(),
                      color: Colors.orange.shade700,
                      onTap: () {
                        Routting.push(context, Orderproduction(canedit:canEditLastOrderProduction ,));
                      },
                    ),
                  if (canProduction)
                    Cardhome(
                      icon: Icons.precision_manufacturing, // انتاج
                      title: "إنتاج".tr(),
                      color: Colors.teal.shade700,
                      onTap: () async {
                        var role;
                        await Localls.getrole().then((value) => role = value);
                        print(role);
                        Routting.push(
                            context,
                            Productionview(
                              role: role,
                            ));
                      },
                    ),
                  if (canDamaged)
                    Cardhome(
                      icon: Icons.delete_forever, // التوالف
                      title: "التوالف".tr(),
                      color: Colors.grey.shade800,
                      onTap: () {
                        Routting.push(context, Compilationsview());
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
