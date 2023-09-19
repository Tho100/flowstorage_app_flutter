import 'package:flowstorage_fsc/pages/home_page.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_payment_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/authentication/sign_up_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splash_screen.dart';
import 'package:get_it/get_it.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void initializeLocators() {
  final locator = GetIt.instance;
  locator.registerLazySingleton<UserDataProvider>(() => UserDataProvider());
  locator.registerLazySingleton<StorageDataProvider>(() => StorageDataProvider());
  locator.registerLazySingleton<PsUploadDataProvider>(() => PsUploadDataProvider());
  locator.registerLazySingleton<TempDataProvider>(() => TempDataProvider());
  locator.registerLazySingleton<PsStorageDataProvider>(() => PsStorageDataProvider());
  locator.registerLazySingleton<TempPaymentProvider>(() => TempPaymentProvider());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeLocators();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GetIt.instance<UserDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<StorageDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<PsUploadDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<TempDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<PsStorageDataProvider>()),
        ChangeNotifierProvider(create: (context) => GetIt.instance<TempPaymentProvider>())
      ],
      child: const MainRun(),
    ),
  );
}

class MainRun extends StatelessWidget {
  const MainRun({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: ThemeColor.darkBlack,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: ThemeColor.darkPurple,
          ), 
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

void homePage() => runApp(
  const MaterialApp(
  home: CakeSignUpPage(),
));

class Mainboard extends StatefulWidget {
  
  const Mainboard({super.key});
  @override
  State<Mainboard> createState() => CakeHomeState();

}