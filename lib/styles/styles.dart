import 'package:flutter/material.dart';

class SimpleDecoration {
  static BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class AppColors {
  // Primary theme colors - off-black and white
  static const Color background = Color(0xFFFAFAFA); // Off-white background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color primaryDark = Color(0xFF1A1A1A); // Off-black

  // Button colors
  static const Color buttonBackground = Color(0xFF1A1A1A); // Black buttons
  static const Color buttonForeground = Color(
    0xFFFFFFFF,
  ); // White text on buttons

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Black main text
  static const Color textSecondary = Color(0xFF757575); // Grey subtext
  static const Color textLight = Color(0xFF9E9E9E); // Light grey

  // Border and divider colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color shadowLight = Color(0x0A000000);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
}

class AppDecorations {
  static const double cardRadius = 16;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );

  static const double textFieldRadius = 12;
  static const BorderRadius textFieldBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  static const double primaryButtonRadius = 12;
  static const double submitButtonRadius = 12;

  static const LinearGradient pageLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFFAFAFA)],
  );
}

class AppText {
  static const TextStyle base = TextStyle(fontFamily: 'Montserrat');

  static const TextStyle appHeader = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const TextStyle welcomeTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: AppColors.textPrimary,
  );

  static const TextStyle formTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle formDescription = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: AppColors.primaryDark,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  static const TextStyle submitButton = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.buttonForeground,
  );

  static const TextStyle textFieldHint = TextStyle(
    fontFamily: 'Montserrat',
    color: AppColors.textSecondary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonForeground,
  );

  static const TextStyle footer = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle footerLink = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.textSecondary,
    decoration: TextDecoration.underline,
    height: 1.5,
  );
}

class AppButtons {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonBackground,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDecorations.primaryButtonRadius),
    ),
    foregroundColor: AppColors.buttonForeground,
  );

  static final ButtonStyle submit = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonBackground,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDecorations.submitButtonRadius),
    ),
    foregroundColor: AppColors.buttonForeground,
  );

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColors.borderColor, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDecorations.primaryButtonRadius),
    ),
    foregroundColor: AppColors.textPrimary,
  );
}

class AppContainers {
  static const BoxDecoration pageContainer = BoxDecoration(
    gradient: AppDecorations.pageLinearGradient,
  );

  static BoxDecoration get cardContainer => SimpleDecoration.card();
}

class AppTextFields {
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppText.textFieldHint,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppDecorations.textFieldBorderRadius,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
}

class AppSizes {
  static const double primaryButtonHeight = 56;
  static const double submitButtonHeight = 48;
  static const double iconSize = 24;
  static const double primaryIconSize = 26;
}
