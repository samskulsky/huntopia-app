import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scavhuntapp/models/app_user.dart';

import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import '../../widgets/gradient_background.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Permissions',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Almost there!',
                style: baseTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              Text(
                'We need a few permissions to make the app work properly. We\'ll never share your data with anyone.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildPermissionTile(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      permissionGranted: cameraPermission,
                      requestPermission: () =>
                          _requestPermission(Permission.camera),
                      isFirst: true,
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildPermissionTile(
                      icon: Icons.location_on,
                      title: 'Location',
                      permissionGranted: locationPermission,
                      requestPermission: () =>
                          _requestPermission(Permission.location),
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildPermissionTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      permissionGranted: notificationPermission,
                      requestPermission: () =>
                          _requestPermission(Permission.notification),
                      isLast: true,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: !_allPermissionsGranted()
                      ? null
                      : () => _createUserAndContinue(),
                  child: Text(
                    'Continue',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
              if (!_allPermissionsGranted())
                TextButton(
                  onPressed: () => _createUserAndContinue(),
                  child: Text(
                    'Grant Permissions Later',
                    style: baseTextStyle.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required bool permissionGranted,
    required Function requestPermission,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Container(
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: permissionGranted
                ? Colors.green.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            border: Border.all(
              color: permissionGranted
                  ? Colors.green
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: permissionGranted
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: permissionGranted
                        ? Colors.green
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
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
