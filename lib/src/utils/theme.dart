import 'package:flutter/material.dart';
import 'package:pyramid_game/src/utils/widget_theme/elevated_button_theme.dart';
// import 'package:my_textto_app/src/utils/theme/widget_theme/elevated_button_theme.dart';
// import 'package:my_textto_app/src/utils/theme/widget_theme/outlined_button_theme.dart';
// import 'package:my_textto_app/src/utils/theme/widget_theme/text_field_theme.dart';
// import 'package:my_textto_app/src/utils/theme/widget_theme/text_theme.dart';

class AppTheme {
  AppTheme._();
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    // outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    // inputDecorationTheme: TextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    // outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    // inputDecorationTheme: TextFormFieldTheme.darkInputDecorationTheme,
  );
}
