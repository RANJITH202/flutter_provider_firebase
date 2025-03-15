import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_provider_firebase/main.dart';
import 'package:flutter_provider_firebase/pages/sign_in_page.widget.dart';
import 'package:flutter_provider_firebase/pages/splash_screen.widget.dart';
import 'package:flutter_provider_firebase/providers/main_app_state.provider.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

const kTransitionInfoKey = '__transition_info__';

const List<String> unAuthWidgets = [
  '/',
  '/setMpinPage',
  '/userSigninPage',
  '/getPermissionsPage',
  '/landingPage',
  '/splashScreen',
  '/getStartedPage',
  '/tooManyAttempts',
  '/welcomeToOneAbcPage',
  '/repeatUserLoginPage',
  '/otpVerificationPage',
  '/userDetailsPage',
  '/setupBiometricPage',
  '/changeMPIN',
  '/setupPaymentPageWidgetNav',
  '/receivenamefromuser'
];

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;

  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

String extractDeepLinkValue(String url) {
  // Find the start index of 'deep_link_value='
  final String deepLinkKey = "deep_link_value=";
  final int startIndex = url.indexOf(deepLinkKey);
  if (startIndex == -1) {
    return ""; // 'deep_link_value=' not found
  }

  // Find the end index of the value (up to the next '&')
  final int endIndex = url.indexOf("&", startIndex);
  final int endPosition = endIndex != -1 ? endIndex : url.length;

  // Extract the encoded deep link value
  final String encodedDeepLinkValue =
      url.substring(startIndex + deepLinkKey.length, endPosition);

  // Decode the extracted deep link value to handle any encoded characters within it
  final String firstDecodedDeepLinkValue = Uri.decodeFull(encodedDeepLinkValue);
  final String finalDecodedDeepLinkValue =
      Uri.decodeFull(firstDecodedDeepLinkValue);

  return finalDecodedDeepLinkValue;
}

({String path, Map<String, String> queryParams}) extractPathFromUrl(
    String url) {
  Uri uri = Uri.parse(
    url,
  );
  final queryParameters = uri.queryParameters;
  return (path: uri.path, queryParams: queryParameters);
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      navigatorKey: NavigatorKey,
      redirect: (context, state) {},
      initialLocation: '/',
      debugLogDiagnostics: true,
      observers: [GoRouterObserver()],
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => const UserSigninPageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => const UserSigninPageWidget(),
        ),

        FFRoute(
          name: 'splashScreen',
          path: '/splashScreen',
          builder: (context, params) =>
              const SplashScreenWidget(), //SplashScreenWidget
        ),

        // FFRoute(
        //   name: 'getStartedPage',
        //   path: '/getStartedPage',
        //   builder: (context, params) => GetStartedPageWidget(),
        // ),

        // FFRoute(
        //   name: 'somethingWentWrongPage',
        //   path: '/somethingWentWrongPage',
        //   builder: (context, params) => SomethingWentWrongPageWidget(),
        // ),

        FFRoute(
          name: 'userSigninPage',
          path: '/userSigninPage',
          builder: (context, params) => const UserSigninPageWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};

  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    // ..addAll(queryParameters)
    ..addAll(extraMap);

  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.extraMap.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));

  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;

  bool get hasFutures => state.allParams.entries.any(isAsyncParam);

  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder: PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).transitionsBuilder,
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class GoRouterObserver extends NavigatorObserver {

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    String? routeName = route.settings.name;
    String? previousRouteName = previousRoute?.settings.name;

    if (routeName != null) {
      MainAppState().tempCurrentScreen = (routeName.isEmpty &&
                  (!MainAppState().tempCurrentScreen.contains('_bottomsheet'))
              ? "${MainAppState().tempCurrentScreen}_bottomsheet"
              : routeName)
          .replaceAll('_initialize', 'splashScreen');

      if (previousRouteName != null && previousRouteName.isNotEmpty )  {
        MainAppState().tempPreviousScreen =
            previousRouteName.replaceAll('_initialize', 'splashScreen');
      }
    } else if (!MainAppState().tempCurrentScreen.contains('_bottomsheet')) {
      MainAppState().tempPreviousScreen = MainAppState().tempCurrentScreen;
      MainAppState().tempCurrentScreen =
          "${MainAppState().tempCurrentScreen}_bottomsheet";
    }
    debugPrint(
        "CP Screens Test CS:${MainAppState().tempCurrentScreen} PS: ${MainAppState().tempPreviousScreen}");
    // if (MainAppState().currrentUser.mobileNumber.isNotEmpty) {
    //   MainAppState().currentScreen = route.settings.name ?? '';
    //   MainAppState().previousScreen = previousRoute?.settings.name ?? "";

    //   if (MainAppState().currrentUser.customerId != 0 &&
    //       MainAppState().currrentUser.authToken != '') {
    //     sendPageNavigationData(route);
    //   }
    // } else {
    //   String nowTime = DateFormat('HH:mm:ss').format(DateTime.now());
    //   List pages = [];
    //   if ('${route.settings.name}' != 'null') {
    //     pages.add('${route.settings.name}($nowTime)');
    //     String strPages = pages.join(' --> ');
    //     // API Call for page navigation
    //   }
    // }
  }

  // void sendPageNavigationData(Route<dynamic> route) async {
  //   String data = '';
  //   String nowTime = DateFormat('HH:mm:ss').format(DateTime.now());

  //   ApiCallResponse? apiResult = await OneAbcApiGroup.getPageNavigationCall
  //       .call(mdn: MainAppState().currrentUser.mobileNumber);
  //   if (apiResult.succeeded &&
  //       jsonDecode(apiResult.response!.body)['data'] != null) {
  //     data = jsonDecode(apiResult.response!.body)['data']['pageDetails'] ?? '';
  //   }

  //   List pages = data.split(' --> ');
  //   if ('${route.settings.name}' != 'null') {
  //     pages.add('${route.settings.name}($nowTime)');
  //     String strPages = pages.join(' --> ');
  //     await OneAbcApiGroup.pageNavigationCall.call(
  //       mdn: MainAppState().currrentUser.mobileNumber,
  //       pageDetails: strPages,
  //     );

  //     if (_sessionTimer != null) {
  //       _sessionTimer!.cancel();
  //     }

  //     // <save last interaction time here>
  //     _sessionTimer = Timer(Duration(seconds: 200), () {
  //       _sessionTimer?.cancel();
  //       _sessionTimer = null;
  //       sendPageNavigationData(route);
  //     });
  //   }
  // }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    MainAppState().previousScreen = MainAppState().currentScreen;
    debugPrint(
        'FFAppState().previousScreen:::: ${MainAppState().previousScreen}');
    BuildContext? currentContext = NavigatorKey.currentContext;
    String currentRouteName = GoRouter.of(currentContext!).state?.name ?? "";

    MainAppState().currentScreen = currentRouteName;

    if (previousRoute != null && previousRoute.settings.name != null) {
      if (previousRoute.settings.name!.isEmpty) {
      } else {
        MainAppState().tempPreviousScreen = MainAppState().tempCurrentScreen;
        MainAppState().tempCurrentScreen = previousRoute.settings.name
            ?.replaceAll('_initialize', 'splashScreen');
      }
    }

    debugPrint(
        "Plugin CP Screens Test CS:${MainAppState().tempCurrentScreen} PS: ${MainAppState().tempPreviousScreen}");
    debugPrint('FFAppState().currentScreen:::: ${MainAppState().currentScreen}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('MyTest didRemove: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('MyTest didReplace: ${newRoute?.settings.name}');
  }
}
