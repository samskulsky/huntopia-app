import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scavhuntapp/models/app_user.dart';

import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import 'setup_2.dart';
import 'setup_5.dart';

class SetupPage4 extends StatefulWidget {
  const SetupPage4({super.key});

  @override
  State<SetupPage4> createState() => _SetupPage4State();
}

class _SetupPage4State extends State<SetupPage4> {
  bool locationPermission = false;
  bool cameraPermission = false;
  bool notificationPermission = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    locationPermission = await Permission.location.isGranted;
    cameraPermission = await Permission.camera.isGranted;
    notificationPermission = await Permission.notification.isGranted;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Permissions & Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permissions & Access',
              style: baseTextStyle.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In order to use the app, we need to request some permissions from you. We will never share your data with anyone.',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refreshPermissions,
              child: const Text('Refresh Permissions'),
            ),
            _buildPermissionTile(
              icon: Icons.camera_alt,
              title: 'Camera',
              permissionGranted: cameraPermission,
              requestPermission: () => _requestPermission(Permission.camera),
            ),
            _buildPermissionTile(
              icon: Icons.location_city,
              title: 'Location',
              permissionGranted: locationPermission,
              requestPermission: () => _requestPermission(Permission.location),
            ),
            _buildPermissionTile(
              icon: Icons.notifications,
              title: 'Notifications',
              permissionGranted: notificationPermission,
              requestPermission: () =>
                  _requestPermission(Permission.notification),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: !_allPermissionsGranted()
                  ? null
                  : () => _createUserAndContinue(),
              child: const Text('Continue'),
            ),
            if (!_allPermissionsGranted())
              TextButton(
                onPressed: () => _createUserAndContinue(),
                child: const Text('Grant Permissions Later'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required bool permissionGranted,
    required Function requestPermission,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        title,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Switch(
        value: permissionGranted,
        activeTrackColor: Colors.blueAccent,
        onChanged: (value) async {
          if (!permissionGranted) {
            await requestPermission();
          }
        },
      ),
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      setState(() {
        if (permission == Permission.camera) cameraPermission = true;
        if (permission == Permission.location) locationPermission = true;
        if (permission == Permission.notification)
          notificationPermission = true;
      });
    } else {
      _showPermissionErrorToast();
    }
  }

  void _showPermissionErrorToast() {
    ToastificationHelper.showErrorToast(
      context,
      'Unable to request permission. Please go to your settings and allow access.',
    );
  }

  bool _allPermissionsGranted() {
    return locationPermission && cameraPermission && notificationPermission;
  }

  void _createUserAndContinue() {
    appUser.tokens = 0;
    createAppUser(appUser).then((value) {
      Get.offAll(() => const SetupPage5());
    }).catchError((e) {
      ToastificationHelper.showErrorToast(
        context,
        'An error occurred while creating your account. Please try again.',
      );
    });
  }
}
