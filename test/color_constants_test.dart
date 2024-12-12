import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapnrank/color_constants.dart';
// Update the import path

void main() {
  group('Color Constants', () {
    test('primaryColor', () {
      expect(primaryColor, const Color(0xff7aa64e));
    });

    test('secondaryColor', () {
      expect(secondaryColor, const Color(0xff021d40));
    });

    test('hinTextColor', () {
      expect(hinTextColor, Colors.grey.shade700);
    });

    test('bgColor', () {
      expect(bgColor, const Color(0xFF212121));
    });

    test('darkgreenColor', () {
      expect(darkgreenColor, const Color(0xFF2c614f));
    });

    test('labelColor', () {
      expect(labelColor, const Color.fromRGBO(33, 47, 61, 1));
    });

    test('greenColor', () {
      expect(greenColor, const Color(0xFF6bab58));
    });

    test('validateColor', () {
      expect(validateColor, const Color.fromRGBO(0, 151, 136, 1));
    });

    test('appColor', () {
      expect(appColor, const Color(0xFF032252));
    });

    test('pink', () {
      expect(pink, const Color.fromRGBO(215, 31, 77, 1.0));
    });

    test('specialColor', () {
      expect(specialColor, const Color(0xFFFC1111));
    });

    test('colorOnSelected', () {
      expect(colorOnSelected, Colors.cyanAccent);
    });

    test('inactive', () {
      expect(inactive, Colors.grey);
    });

    test('pointColor', () {
      expect(pointColor, Colors.orangeAccent);
    });



    test('doneStatus', () {
      expect(doneStatus, const Color(0xFF411DA0));
    });



    test('buttonColor', () {
      expect(buttonColor, const Color.fromRGBO(26, 25, 31, 1));
    });

    test('pendingStatus', () {
      expect(pendingStatus, CupertinoColors.activeOrange);
    });

    test('interfaceColor', () {
      expect(interfaceColor, const Color(0xff7aa64e));
    });

    test('backgroundColor', () {
      expect(backgroundColor, const Color(0xffe6e8ec));
    });

    test('background', () {
      expect(background, const Color(0xfff9f9fb));
    });

    test('textFieldColor', () {
      expect(textFieldColor, const Color(0xF5E5F2FC));
    });

    test('drawerColor', () {
      expect(drawerColor, const Color(0xFF212121));
    });

    test('textColor', () {
      expect(textColor, const Color(0xFFFFFFFF));
    });

      group('Palette', () {
        test('background color is correct', () {
          expect(Palette.background, const Color(0xFFFFFFFF));
        });

        test('Text color is correct', () {
          expect(Palette.Text, const Color(0xF5F5F5F5));
        });

        test('wrapperBg color is correct', () {
          expect(Palette.wrapperBg, const Color(0xFF212121));
        });
      });
    }

    );

}
