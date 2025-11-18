import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? AppTheme.primaryColor;
    final textColor = this.textColor ?? Colors.white;

    Widget buttonContent = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? backgroundColor : textColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isOutlined ? backgroundColor : textColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? backgroundColor : textColor,
                ),
              ),
            ],
          );

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: height ?? 16,
              ),
              side: BorderSide(color: backgroundColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: width != null
                  ? Size(width!, height ?? 48)
                  : null,
            ),
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: 2,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: height ?? 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: width != null
                  ? Size(width!, height ?? 48)
                  : null,
            ),
            child: buttonContent,
          );

    return button;
  }
}
