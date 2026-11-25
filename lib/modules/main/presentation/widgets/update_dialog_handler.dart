import 'package:flutter/material.dart';
import 'package:defyx_vpn/modules/main/presentation/widgets/update_dialog.dart';

class UpdateDialogHandler {
  static Future<void> checkAndShowUpdates(
    BuildContext context,
    Future<Map<String, dynamic>> Function() checkForUpdate,
  ) async {
    try {
      if (!context.mounted) return;

      final updateInfo = await checkForUpdate();
      if (!context.mounted || updateInfo['update'] != true) return;

      // Updates are informational only and must never block app usage.
      await CustomUpdateDialog.showUpdateDialog(
        context,
        updateType: UpdateType.optional,
        features: updateInfo['changeLog'] is List
            ? updateInfo['changeLog'] as List<dynamic>
            : const <dynamic>[],
      );
    } catch (error) {
      debugPrint('Error checking for updates: $error');
    }
  }
}
