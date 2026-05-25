import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../../constant.dart";
import "../theme/colors.dart";
import "platform_utils.dart";

void showMessage(String msg, {bool? isError, bool isPersistent = false}) {
  debugPrint(msg);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    bool isBottomSheetOpen = false;
    final bgColor = isError == true
        ? AppColors.error
        : isError == false
        ? AppColors.success
        : AppColors.backgroundDark;

    kNavigatorKey.currentState?.popUntil((route) {
      if (route is PopupRoute) isBottomSheetOpen = true;
      return true;
    });

    if (isBottomSheetOpen && !PlatformUtils.isDesktop) {
      ToastHelper.showToast(msg, bgColor);
    } else {
      messengerKey.currentState?.clearSnackBars();
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: SelectableText(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.foregroundLight),
          ),
          duration: isPersistent
              ? const Duration(days: 365)
              : const Duration(seconds: 3),
          margin: const EdgeInsets.all(kMediumPadding),
          padding: const EdgeInsets.all(kMediumPadding),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bgColor,
        ),
      );
    }
  });
}

class ToastHelper {
  static void showToast(String message, Color bgColor) {
    if (!PlatformUtils.isWeb) closeToast();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: AppColors.foregroundLight,
      fontSize: kMediumFont,
    );
  }

  static void closeToast() => Fluttertoast.cancel();
}

void hideMessage() {
  if (!PlatformUtils.isDesktop) ToastHelper.closeToast();
  messengerKey.currentState?.clearSnackBars();
}
