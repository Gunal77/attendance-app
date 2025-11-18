import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.cardColor,
      foregroundColor: AppTheme.textColor,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColor,
        ),
      ),
      centerTitle: true,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

