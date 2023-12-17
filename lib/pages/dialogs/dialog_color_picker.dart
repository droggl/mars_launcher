import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mars_launcher/theme/theme_manager.dart';
import 'package:mars_launcher/services/service_locator.dart';
import 'package:mars_launcher/theme/theme_constants.dart';

const BUTTON_BACKGROUND_COLOR_DIALOG = Colors.black;
const BUTTON_TEXT_COLOR_DIALOG = Colors.white;

class ColorPickerDialog extends StatelessWidget {
  final bool changeDarkModeColor;
  final themeManager = getIt<ThemeManager>();

  ColorPickerDialog({Key? key, required this.changeDarkModeColor}): super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Pick a background color';
    const textButton = 'APPLY';

    final buttonStyle = getDialogButtonStyle(themeManager.isDarkMode);

    var selectedColor = changeDarkModeColor ? themeManager.darkBackground : themeManager.lightBackground;

    return AlertDialog(
      title: const Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              labelTypes: [],
              pickerAreaHeightPercent: 0.8,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text(textButton),
                onPressed: () {
                  print(selectedColor);

                  themeManager.setBackgroundColor(changeDarkModeColor, selectedColor);
                  Navigator.of(context).pop();
                },
                style: buttonStyle
              ),
            ),
          ],
        ),
      ),
    );
  }
}
