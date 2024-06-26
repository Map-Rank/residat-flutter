import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_constants.dart';
import '../../common/ui.dart';
import '../models/setting_model.dart';

class SettingsService extends GetxService {

  late GetStorage _box;
  final setting = Setting(accentColor: '0xFF6B00FE',accentDarkColor: '#808080', mainColor: '0xFF6B00FE',
    secondColor: '#808080', appName: 'Residat', mainDarkColor: '0xFF6B00FE', scaffoldColor: '0xFF6B00FE',
    scaffoldDarkColor: '0xFF6B00FE', secondDarkColor: '0xFF6B00FE', defaultTheme: 'light'
       ).obs;

  SettingsService() {
    _box = GetStorage();
  }

  Future<SettingsService> init() async {

    return this;
  }

  ThemeData getLightTheme() {
    return ThemeData(
        primaryColor: Colors.white,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(elevation: 0, foregroundColor: Colors.white),
        brightness: Brightness.light,
        dividerColor: Ui.parseColor(setting.value.accentColor, opacity: 0.1),
        focusColor: inactive,
        //Ui.parseColor(setting.value.accentColor),
        hintColor: Ui.parseColor(setting.value.secondColor, opacity: 0.8),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: Ui.parseColor(setting.value.mainColor, opacity: 0.8)),
        ),
        colorScheme: const ColorScheme.light(
          primary: pink,
          secondary: interfaceColor,
        ),
        textTheme: GoogleFonts.getTextTheme(
          'Poppins',
          TextTheme(
            headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: hinTextColor, height: 1.3),
            headline5: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: interfaceColor, height: 1.3),
            headline4: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: interfaceColor, height: 1.3),
            headline3: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: interfaceColor, height: 1.3),
            headline2: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: pink, height: 1.4),
            headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300, color: interfaceColor, height: 1.4),
            subtitle2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: interfaceColor, height: 1.2),
            subtitle1: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400, color: pink, height: 1.2),
            bodyText2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: labelColor, height: 1.2),
            bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: interfaceColor, height: 1.2),
            caption: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: Ui.parseColor(setting.value.accentColor, opacity: 0.8), height: 1.2),
          ),

        ));
  }

  ThemeData getDarkTheme() {
    return ThemeData(
        primaryColor: Color(0xFF252525),
        floatingActionButtonTheme: FloatingActionButtonThemeData(elevation: 0),
        scaffoldBackgroundColor: Color(0xFF2C2C2C),
        brightness: Brightness.dark,
        // dividerColor: Ui.parseColor(setting.value.accentDarkColor, opacity: 0.1),
        // focusColor: Ui.parseColor(setting.value.accentDarkColor, opacity: null),
        // hintColor: Ui.parseColor(setting.value.secondDarkColor),
        // toggleableActiveColor: Ui.parseColor(setting.value.mainDarkColor),
        // textButtonTheme: TextButtonThemeData(
        //   style: TextButton.styleFrom(primary: Ui.parseColor(setting.value.mainColor)),
        // ),
        colorScheme: ColorScheme.dark(
          primary: pink,
          secondary: interfaceColor,
        ),
        textTheme: GoogleFonts.getTextTheme(
            'Poppins',
            TextTheme(
              headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: interfaceColor, height: 1.3),
              headline5: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: interfaceColor, height: 1.3),
              headline4: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: interfaceColor, height: 1.3),
              headline3: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: interfaceColor, height: 1.3),
              headline2: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: pink, height: 1.4),
              headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300, color: interfaceColor, height: 1.4),
              subtitle2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: interfaceColor, height: 1.2),
              subtitle1: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400, color: pink, height: 1.2),
              bodyText2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: interfaceColor, height: 1.2),
              bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: interfaceColor, height: 1.2),
              caption: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: Ui.parseColor(setting.value.accentDarkColor, opacity: 0.8), height: 1.2),
            )));
  }

  ThemeMode getThemeMode() {
    String? _themeMode = GetStorage().read<String>('theme_mode');
    switch (_themeMode) {
      case 'ThemeMode.light':
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white),
        );
        return ThemeMode.light;
      case 'ThemeMode.dark':
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.black87),
        );
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        if (setting.value.defaultTheme == "dark") {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.black87),
          );
          return ThemeMode.dark;
        } else {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white),
          );
          return ThemeMode.light;
        }
    }
  }

}
