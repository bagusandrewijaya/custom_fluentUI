import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//
// Flutter has a color profile issue so colors will look different
// on Apple devices.
// https://github.com/flutter/flutter/issues/55092
// https://github.com/flutter/flutter/issues/39113
//

extension LKColors on Colors {
  static const lkBlue = Color.fromARGB(0, 160, 160, 160);
  static const lkDarkBlue = Color.fromARGB(255, 0, 0, 0);
}

class LiveKitTheme {
  //
  final bgColor = Colors.black;
  final textColor = Colors.white;
  final cardColor = LKColors.lkDarkBlue;
  final accentColor = Color.fromARGB(0, 160, 160, 160);

  ThemeData buildThemeData(BuildContext ctx) => ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: cardColor,
        ),
        cardColor: cardColor,
        scaffoldBackgroundColor: bgColor,
        canvasColor: bgColor,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle:
                MaterialStateProperty.all<TextStyle>(GoogleFonts.montserrat(
              fontSize: 15,
            )),
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 20, horizontal: 25)),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            // backgroundColor: MaterialStateProperty.all<Color>(accentColor),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return accentColor.withOpacity(0.5);
              }
              return accentColor;
            }),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(accentColor),
        ),
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return accentColor;
            }
            return accentColor.withOpacity(0.3);
          }),
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.black;
            }
            return Colors.black.withOpacity(0.3);
          }),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(ctx).textTheme,
        ).apply(
          displayColor: textColor,
          bodyColor: textColor,
          decorationColor: textColor,
        ),
        hintColor: Colors.red,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: LKColors.lkBlue,
          ),
          hintStyle: TextStyle(
            color: LKColors.lkBlue.withOpacity(.5),
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          background: bgColor,
        ),
      );
}
