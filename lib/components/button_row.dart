import 'package:flutter/material.dart';
import 'package:student_app/components/custom_button.dart';

class ButtonRow extends StatelessWidget {
  final String leftButtonTitle;
  final IconData leftButtonIcon;
  final VoidCallback leftButtonOnTap;
  final String rightButtonTitle;
  final IconData rightButtonIcon;
  final VoidCallback rightButtonOnTap;
  final bool isDarkMode;

  const ButtonRow({
    super.key,
    required this.leftButtonTitle,
    required this.leftButtonIcon,
    required this.leftButtonOnTap,
    required this.rightButtonTitle,
    required this.rightButtonIcon,
    required this.rightButtonOnTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomButton(
            title: leftButtonTitle,
            icon: leftButtonIcon,
            onTap: leftButtonOnTap,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: CustomButton(
            title: rightButtonTitle,
            icon: rightButtonIcon,
            onTap: rightButtonOnTap,
          ),
        ),
      ],
    );
  }
}
