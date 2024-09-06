import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastificationHelper {
  static void showSuccessToast(BuildContext context, String message) {
    toastification.show(
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      context: context,
      type: ToastificationType.success,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    toastification.show(
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      context: context,
      type: ToastificationType.error,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
