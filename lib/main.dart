import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_instance_id/firebase_instance_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_firebase/firebase_options.dart';
import 'package:flutter_provider_firebase/providers/main_app_state.provider.dart';
import 'package:flutter_provider_firebase/utils/constants.dart';
import 'package:flutter_provider_firebase/utils/local_storage.dart';
import 'package:flutter_provider_firebase/utils/nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> NavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final instanceId =
      await FirebaseInstanceId.appInstanceId ?? 'Unknown installation id';
  debugPrint('firebase instance `~ ID ~ $instanceId');

  LocalStorage.saveLocalInstanceId(instranceID: instanceId);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final appState = MainAppState(); // Initialize FFAppState

  // Initialize FFAppState
  // await appState
  //     .initializeForFirstTime(); // JUST LOADING THE NEEDED APP STATE BEFORE LOADING THE 1st SCREEN

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appState),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  bool isConnectedToInternet = true;
  bool isNetworkSourceEnabled = true;
  Timer? _sessionTimer;
  String fcmToken = "";

  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.onMessage.listen(_handleMessage);
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  // This widget is the root of your application.
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Flutter Demo',
  //     theme: ThemeData(
  //       // This is the theme of your application.
  //       //
  //       // TRY THIS: Try running your application with "flutter run". You'll see
  //       // the application has a purple toolbar. Then, without quitting the app,
  //       // try changing the seedColor in the colorScheme below to Colors.green
  //       // and then invoke "hot reload" (save your changes or press the "hot
  //       // reload" button in a Flutter-supported IDE, or press "r" if you used
  //       // the command line to start the app).
  //       //
  //       // Notice that the counter didn't reset back to zero; the application
  //       // state is not lost during the reload. To reset the state, use hot
  //       // restart instead.
  //       //
  //       // This works for code too, not just values: Most code changes can be
  //       // tested with just a hot reload.
  //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  //       useMaterial3: true,
  //     ),
  //     home: const MyHomePage(title: 'Flutter Demo Home Page'),
  //   );
  // }
  void startSessionTimer() async {
    if (_sessionTimer != null) {
      _sessionTimer!.cancel();
    }

    // <save last interaction time here>
    _sessionTimer = Timer(const Duration(seconds: 300), () {
      _sessionTimer?.cancel();
      _sessionTimer = null;
      // if (PortfolioAppState().currrentUser.isMpinSet) {}
    });
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
      });
  // to change have to use this
// void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
//     MyApp.of(context).setThemeMode(themeMode);

  // Things related to internet connectivity
  /*
    void listenInternet() {
    InternetConnectionChecker().onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            setState(() {
              isConnectedToInternet = true;
            });
            break;
          case InternetConnectionStatus.disconnected:
            setState(() {
              isConnectedToInternet = false;
            });
            break;
        }
      },
    );
  }

  void listenConnectivityCheck() {
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        BuildContext? currentContext = sipNavigatorKey.currentContext;
        //there is no any connection
        setState(() {
          isNetworkSourceEnabled = false;
        });
        currentContext!.showAppBottomSheet(child: ConnectionLostPageWidget());
      } else if (result == ConnectivityResult.mobile) {
        //connection is mobile data network
        popIfNetworkIsResumed();
      } else if (result == ConnectivityResult.wifi) {
        //connection is from wifi
        popIfNetworkIsResumed();
      } else if (result == ConnectivityResult.ethernet) {
        //connection is from wired connection
        popIfNetworkIsResumed();
      } else if (result == ConnectivityResult.bluetooth) {
        //connection is from bluetooth threatening
        popIfNetworkIsResumed();
      }
    });
  }

  void popIfNetworkIsResumed() {
    BuildContext? currentContext = sipNavigatorKey.currentContext;
    if (!isNetworkSourceEnabled) {
      currentContext!.pop();
      BuildContext? currentContext1 = sipNavigatorKey.currentContext;
      String currentRouteName = GoRouter.of(currentContext1!).location;
      if (currentRouteName == '/' || currentRouteName == '/splashScreen') {
        currentContext1.goNamed('splashScreen');
      }
    }
    setState(() {
      isNetworkSourceEnabled = true;
    });
  }

   */

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (val) {
          startSessionTimer();
        },
        child: MaterialApp.router(
          title: 'ToDo',
          theme: ThemeData(
            useMaterial3: false,
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
            brightness: Brightness.light,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: kPrimaryColor,
                shape: const StadiumBorder(),
                maximumSize: const Size(double.infinity, 56),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: kPrimaryLightColor,
              iconColor: kPrimaryColor,
              prefixIconColor: kPrimaryColor,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.amberAccent,
              selectionColor: Colors.grey,
              selectionHandleColor: Colors.transparent,
            ),
          ),
          themeMode: _themeMode,
          routerConfig: _router,
          builder: (BuildContext context, Widget? child) {
            // ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            //   return SomethingWentWrongPage(
            //     errorDetails: errorDetails,
            //   );
            // };
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Stack(children: [
                child!,
                //loader can be if needed
                // ValueListenableBuilder(
                //   builder: (BuildContext context, LoadingState value,
                //       Widget? child) {
                //     if (value == LoadingState.loading) {
                //       return Align(
                //         alignment: Alignment.center,
                //         child: BackdropFilter(
                //             filter: ImageFilter.blur(
                //               sigmaX: 10.0,
                //               sigmaY: 10.0,
                //             ),
                //             child: Container(
                //               color: Colors.transparent,
                //               child: Center(
                //                 child: SizedBox(
                //                   height: 50.0,
                //                   width: 50.0,
                //                   child: Center(
                //                       child: Lottie.asset(
                //                     'packages/upi_plugin/assets/lottie_animations/Loader_Dot.json',
                //                     width: 50.0,
                //                     height: 50.0,
                //                     fit: BoxFit.cover,
                //                     animate: true,
                //                   )),
                //                 ),
                //               ),
                //             )),
                //       );
                //     } else {
                //       return SizedBox.shrink();
                //     }
                //   },
                //   valueListenable: HomeNotifierClass.instance.loading,
                // )
              ]),
            );
          },
        ),
      ),
    );
  }
}
