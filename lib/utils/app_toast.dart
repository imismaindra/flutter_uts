import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    IconData? icon,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Remove current snackbar to show the new one immediately
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(bottom: 20), // Lift it up a bit
        content: Center( // Center it horizontally
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400), // Limit width for premium look
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isError 
                  ? Colors.white.withOpacity(0.2) 
                  : const Color(0xFFD9FF2E).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Wrap content
              children: [
                Icon(
                  icon ?? (isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded),
                  color: isError ? Colors.white : const Color(0xFFD9FF2E),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, isError: false);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, isError: true);
  }
}
