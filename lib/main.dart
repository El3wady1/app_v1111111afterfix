import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory/UpdateScreenView.dart';
import 'package:inventory/core/app_router.dart';
import 'package:inventory/core/utils/Strings.dart';
import 'package:inventory/core/utils/apiEndpoints.dart';
import 'package:inventory/features/autoLogeddOut.dart';
import 'package:inventory/features/login/presentation/controller/logincubit.dart';
import 'package:inventory/features/login/presentation/view/loginView.dart';
import 'package:inventory/features/splash/presentation/view/widgets/animated_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

void main() async {
  flutter.WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  tz.initializeTimeZones();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lastActivity = prefs.getInt('lastActivity');
  bool shouldLogout = false;

  if (lastActivity != null) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = Duration(milliseconds: now - lastActivity);

    if (diff.inSeconds >  Strings.logoutTime) {
      shouldLogout = true;
      await prefs.clear();
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: [flutter.Locale('en'), flutter.Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: flutter.Locale('en'),
      child: App(shouldLogout: shouldLogout),
    ),
  );
}

class App extends flutter.StatefulWidget {
  final bool shouldLogout;

  App({required this.shouldLogout});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends flutter.State<App> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Timer? updateCheckerTimer;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    // تايمر الجلسة القديمة
    SessionManager.startTimer(() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      navigatorKey.currentState?.pushAndRemoveUntil(
        flutter.MaterialPageRoute(
          builder: (_) => LoginviewSesss(showSessionExpired: true),
        ),
        (route) => false,
      );
    });

    // إضافة التشييك على حالة التطبيق
    _startUpdateChecker();
  }

  void _startUpdateChecker() {
    updateCheckerTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final response = await http.get(
          Uri.parse(Apiendpoints.baseUrl + Apiendpoints.settings.appstate),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          bool updating = !(data["data"]["open"] ?? true);

          if (updating != isUpdating) {
            setState(() {
              isUpdating = updating;
            });
          }
        }
      } catch (e) {
        print("خطأ أثناء التحقق من حالة التطبيق: $e");
      }
    });
  }

  @override
  void dispose() {
    updateCheckerTimer?.cancel();
    super.dispose();
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: flutter.MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'سلطة فاكتوري',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (context, child) {
          return flutter.Directionality(
            textDirection: context.locale.languageCode == 'ar'
                ? flutter.TextDirection.rtl
                : flutter.TextDirection.ltr,
            child: isUpdating
                ? const UpdatingScreen() // ✅ لو السيرفر قال التطبيق واقف
                : Listener(
                    onPointerDown: (_) => SessionManager.resetTimer(),
                    child: child!,
                  ),
          );
        },
        home: widget.shouldLogout
            ? LoginviewSesss(showSessionExpired: true)
            : Animated_SplashView(),
      ),
    );
  }
}

// ---------------- Login View ----------------
class LoginviewSesss extends flutter.StatefulWidget {
  final bool showSessionExpired;

  const LoginviewSesss({this.showSessionExpired = false, Key? key})
      : super(key: key);

  @override
  _LoginviewSesssState createState() => _LoginviewSesssState();
}

class _LoginviewSesssState extends flutter.State<LoginviewSesss> {
  @override
  void initState() {
    super.initState();

    if (widget.showSessionExpired) {
      flutter.WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return flutter.AlertDialog(
              title: flutter.Text("تنبيه".tr()),
              content: flutter.Text("تم انتهاء الجلسة، أعد تسجيل الدخول".tr()),
              actions: [
                flutter.TextButton(
                  onPressed: () => flutter.Navigator.of(context).pop(),
                  child: flutter.Text("موافق".tr()),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(body: Loginview());
  }
}


// import 'package:flutter/material.dart' as flutter;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:easy_localization/easy_localization.dart';
// // import 'package:inventory/features/DashBoard/loginDash/loginDashView.dart';
// import 'package:inventory/features/login/presentation/controller/logincubit.dart';
// import 'package:inventory/features/splash/presentation/view/widgets/animated_splash.dart';

// void main() async {
//   flutter.WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//   runApp(
//     EasyLocalization(
//       supportedLocales: [ flutter.Locale('en'),  flutter.Locale('ar')],
//       path: 'assets/lang',
//       fallbackLocale:  flutter.Locale('en'),
//       child: App(),
//     ),
//   );
// }

// class App extends flutter.StatelessWidget {
//   @override
//   flutter.Widget build(flutter.BuildContext context) {
//     return BlocProvider(
//       create: (_) => LoginCubit(),
//       child: flutter.MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'سلطة فاكتوري',
//         localizationsDelegates: context.localizationDelegates,
//         supportedLocales: context.supportedLocales,
//         locale: context.locale,
//         builder: (context, child) {
//           return flutter.Directionality(
//             textDirection: context.locale.languageCode == 'ar'
//                 ? flutter.TextDirection.rtl
//                 : flutter.TextDirection.ltr,
//             child: child!,
//           );
//         },
//         // home: Logindashview(),
//       home: Animated_SplashView(),
//       ),
//       );
//   }
// }