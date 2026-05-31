// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import your own files
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/DeviceService.dart';
import 'package:saleem_dry_clean/services/Models/CheckoutModel.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/AddressCategoriesProvider.dart';
import 'package:saleem_dry_clean/services/Providers/AreaProvider.dart';
import 'package:saleem_dry_clean/services/Providers/BannerProvider.dart';
import 'package:saleem_dry_clean/services/Providers/DryCleanProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/ServiceTypeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/ThemeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/TimeSelectionProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/notification_provider.dart';
import 'package:saleem_dry_clean/services/Providers/sign_up_provider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/theme/app_theme.dart';
import 'package:saleem_dry_clean/utils/MyRouteObserver.dart';
import 'package:saleem_dry_clean/utils/OnboardingProvider.dart';
import 'package:saleem_dry_clean/utils/connectivity_service.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_generator.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/services/ContactServices/ContactProvider.dart';
import 'package:saleem_dry_clean/services/FeedbackService/FeedbackProvider.dart';
import 'firebase_options.dart';

// Initialize services
final TokenService tokenService = TokenService();
final DeviceService deviceService = DeviceService(tokenService);

// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run Firebase init and dotenv load in parallel — they are independent,
  // and sequential await was costing ~1-2 s on cold start.
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((_) => print('Firebase initialized successfully.'))
        .catchError((e) => print('Error initializing Firebase: $e')),
    dotenv
        .load(fileName: ".env", isOptional: true)
        .then((_) => print('Environment variables loaded successfully.'))
        .catchError((e) => print('Failed to load .env file: $e')),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Allow FCM to show notification banners while the app is in the foreground (iOS)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Prevent landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('Orientation set to portrait mode');

  // Set transparent status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: AppColors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final http.Client client = ApiClient.createClient(tokenService);
  final LanguageProvider languageProvider = LanguageProvider();
  bool isReportingFatalError = false;

  bool isNavigatorLockError(String error) {
    return error.contains('_debugLocked') ||
        error.contains('navigator._debugLocked');
  }

  void navigateToErrorPage(String errorMessage) {
    if (isReportingFatalError || isNavigatorLockError(errorMessage)) return;

    isReportingFatalError = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigation =
          NavigatorService.navigateTo(RouteNames.error, arguments: {
        'errorMessage': errorMessage,
      });

      if (navigation == null) {
        isReportingFatalError = false;
        return;
      }

      navigation.catchError((error) {
        print('Failed to navigate to error page: $error');
      }).whenComplete(() {
        isReportingFatalError = false;
      });
    });
  }

  // Error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    navigateToErrorPage(details.exceptionAsString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    // Silently ignore image decoding errors — handled by widget errorBuilders
    if (errorStr.contains('Invalid image data') ||
        errorStr.contains('ImageCodecException') ||
        errorStr.contains('Could not instantiate image codec') ||
        errorStr.contains('unimplemented')) {
      return true;
    }
    if (isNavigatorLockError(errorStr)) {
      return true;
    }
    // Silently ignore widget lifecycle errors — async callbacks firing after dispose
    if (errorStr.contains('widget has been unmounted') ||
        errorStr.contains('no longer has a context') ||
        errorStr.contains('deactivated widget')) {
      return true;
    }
    print('Unhandled exception: $error');
    navigateToErrorPage(errorStr);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(deviceService)),
        ChangeNotifierProvider(create: (_) => languageProvider),
        ChangeNotifierProvider(create: (_) => CheckoutModel()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => AddressesProvider()),
        ChangeNotifierProvider(create: (_) => TimeSelectionProvider()),
        ChangeNotifierProvider(create: (_) => AreaProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => DryCleanProvider()),
        // TokenService is a global singleton (top of file); expose the same
        // instance via Provider so widgets can access it without creating new
        // FlutterSecureStorage instances.
        Provider<TokenService>.value(value: tokenService),
        ChangeNotifierProvider(
            create: (_) => NotificationProvider(tokenService)),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider<ServiceTypeProvider>(
          create: (_) => ServiceTypeProvider(client, languageProvider),
          lazy: true,
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                BannerProvider(tokenService)), // Add the BannerProvider here
        ChangeNotifierProvider(
            create: (ctx) =>
                ContactProvider(tokenService, ctx.read<UserProvider>())),
        ChangeNotifierProvider(
            create: (ctx) =>
                FeedbackProvider(tokenService, ctx.read<UserProvider>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926), // Adjust based on your base design
      minTextAdapt: true,
      builder: (context, child) {
        return const MaterialAppWithProviders();
      },
    );
  }
}

class MaterialAppWithProviders extends StatelessWidget {
  const MaterialAppWithProviders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Saleem',
              debugShowCheckedModeBanner: false,

              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              locale: languageProvider.locale,

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              navigatorKey: NavigatorService
                  .navigatorKey, // Use NavigatorService's navigatorKey
              navigatorObservers: [MyRouteObserver()],
              initialRoute: RouteNames.splash,
              onGenerateRoute: RouteGenerator.generateRoute,
              onUnknownRoute: RouteGenerator.generateRoute,
            );
          },
        );
      },
    );
  }
}
