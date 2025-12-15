import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDarkMode;

  const CustomButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
