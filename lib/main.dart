import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';
import 'package:motu/src/common/database.dart';
import 'package:motu/src/common/service/background_service.dart';
import 'package:motu/src/common/service/notifications.dart';
import 'package:motu/src/features/login/service/auth_service.dart';
import 'package:motu/src/features/login/view/onboarding/onboarding.dart';
import 'package:motu/src/features/profile/service/qna_service.dart';
import 'package:motu/src/features/scenario/model/scenario_status.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:motu/src/common/firebase_options.dart';
import 'package:motu/src/features/learning/term/service/term_quiz_service.dart';
import 'package:motu/src/features/login/view/login.dart';
import 'package:motu/src/common/view/nav_page.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:motu/src/common/service/navigation_service.dart';
import 'package:motu/src/common/service/chat_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toastification/toastification.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void _permissionWithNotification() async {
  if (await Permission.notification.isDenied &&
      !await Permission.notification.isPermanentlyDenied) {
    await [Permission.notification].request();
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Hive 로컬DB 초기화
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  // NOTE : Isolate 토큰 생성 및 초기화
  final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  // 앱 최초 Permission 요청
  _permissionWithNotification();

  // 로컬 푸시 알림 초기화
  await LocalPushNotifications.init();

  // 앱이 종료된 상태에서 푸시 알람을 탭할 때
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    log('🖱️ 노티 탭');

    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => const App()));
    });
  }

  // API 키 로드
  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('ko_KR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeBackgroundService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ScenarioService()),
        ChangeNotifierProvider(create: (context) => ChatService()),
        ChangeNotifierProvider(create: (context) => NavigationService()),
        ChangeNotifierProvider(create: (context) => TermQuizService()),
      ],
      builder: (context, child) => const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static const applicationLifeCycleChannel = BasicMessageChannel<String>(
    'applicationLifeCycle',
    StringCodec(),
  );
  static const kApplicationWillTerminate = 'applicationWillTerminate';

  @override
  void initState() {
    super.initState();
    log("📱 앱 최초 실행");

    applicationLifeCycleChannel.setMessageHandler((message) async {
      switch (message) {
        case kApplicationWillTerminate:
          log('🌟 Application will terminate');
          break;
        default:
          break;
      }
      return message!;
    });

    WidgetsBinding.instance.addObserver(this);
    final service = FlutterBackgroundService();
    service.isRunning().then((isRunning) {
      if (isRunning) {
        log('🌟 백그라운드 서비스 진행 중 -> 서비스를 종료합니다.');
        // service.invoke("stopService");
      } else {
        log('🌟 백그라운드 서비스가 진행되고 있지 않습니다.');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    ScenarioService scenarioService =
        Provider.of<ScenarioService>(context, listen: false);

    switch (state) {
      case AppLifecycleState.resumed:
        log('🌟 App in resumed state');
        bool isScenarioRunning = getScenarioIsRunning();
        if (isScenarioRunning) {
          ScenarioStatus currentStatus = getScenarioStatusData();

          if (currentStatus.endTime.isBefore(DateTime.now())) {
            log('🌟 시나리오 종료 시간이 지났습니다.');
            scenarioService.handleScenarioEnd(true);
          } else {
            log('🌟 시나리오 종료 시간이 지나지 않았습니다. 시나리오 정보를 업데이트합니다.');
            scenarioService.updateCurrentStatusWhenResume(currentStatus);
          }
        }
        clearScenarioStatusData();
        break;
      case AppLifecycleState.inactive:
        log('🌟 App in inactive state');
        break;
      case AppLifecycleState.paused:
        log('🌟 App in paused state');
        bool isScenarioRunning = getScenarioIsRunning();
        if (isScenarioRunning) {
          setScenarioStatusData(scenarioService);
          log(getScenarioStatusData().portfolio.toJson().toString());
        }
        break;
      case AppLifecycleState.detached:
        log('🌟 App in detached state');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'MOTU',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: ColorTheme.Purple1,
          appBarTheme: const AppBarTheme(
            backgroundColor: ColorTheme.White,
            titleTextStyle: TextStyle(
              fontSize: 20,
              color: ColorTheme.Black1,
              fontWeight: FontWeight.bold,
            ),
            scrolledUnderElevation: 0,
          ),
          scaffoldBackgroundColor: ColorTheme.White,
          fontFamily: "Pretendard",
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        // home: const TestPage(),
        home: StreamBuilder<User?>(
          stream: authService.auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              authService.getUserInfo().then((value) {
                log('🔓 사용자 정보 로드 완료');
                authService.getAttendance();
                FlutterNativeSplash.remove();
              });
              return const NavPage();
            } else {
              if (getOnboardingDone() == false) {
                log('⭐️ 온보딩 화면으로 이동');
                FlutterNativeSplash.remove();
                return const OnboardingScreen();
              } else {
                return const LoginPage();
              }
            }
          },
        ),
      ),
    );
  }
}
