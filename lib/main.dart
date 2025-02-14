
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/ThemeNotifier.dart';
import 'package:ydental_application/login/UserTypeSelectionScreen.dart';
import 'package:ydental_application/student/View/review_provider.dart';

import 'city_Provider.dart';
import 'patint/View/review_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
        ChangeNotifierProvider(create: (context) => AllReviewForStudentProvider()),
        ChangeNotifierProvider(create: (context) => Patient()), // إضافة Provider<Patient>
        ChangeNotifierProvider(create: (context) => StudentData()), // إضافة Provider<Patient>

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        locale: const Locale('ar'), // Arabic locale
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData.light(),
        // Light theme
        darkTheme: ThemeData.dark(),
        // Dark theme
        themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        title: 'Ydental',
        home: UserTypeSelection(),
      ),
    );
  }
}



