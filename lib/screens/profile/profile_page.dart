import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:avatar_brick/avatar_brick.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import '../auth/auth_page.dart';
import '../home_screen.dart';
import '../../widgets/gradient_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.text = currentUser?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AvatarBrick(
                    radius: 50,
                    name: '${currentUser?.firstName} ${currentUser?.lastName}',
                    backgroundColor: Colors.green,
                    nameTextColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "${currentUser?.firstName} ${currentUser?.lastName}",
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: 'Username',
                  child: TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade400),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      prefixText: '@',
                      prefixStyle:
                          baseTextStyle.copyWith(color: Colors.white70),
                    ),
                    style: baseTextStyle.copyWith(color: Colors.white),
                    maxLength: 20,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    onChanged: (value) {
                      usernameController.text = usernameController.text
                          .replaceAll(RegExp(r'\s+'), '')
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      usernameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: usernameController.text.length));
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      _updateUsername();
                    },
                  ),
                ),
                if (currentUser?.email != null && currentUser?.email != '') ...[
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Email',
                    child: TextFormField(
                      initialValue: currentUser?.email ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: currentUser?.email ?? ''));
                            ToastificationHelper.showSuccessToast(
                                context, 'Email copied to clipboard');
                          },
                          icon: const FaIcon(FontAwesomeIcons.copy,
                              color: Colors.white70, size: 16),
                        ),
                      ),
                      style: baseTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSection(
                  title: 'User ID',
                  child: TextFormField(
                    initialValue: currentUser?.uid ?? '',
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: currentUser?.uid ?? ''));
                          ToastificationHelper.showSuccessToast(
                              context, 'User ID copied to clipboard');
                        },
                        icon: const FaIcon(FontAwesomeIcons.copy,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Get.offAll(() => const AuthPage());
                    },
                    child: Text(
                      FirebaseAuth.instance.currentUser!.isAnonymous
                          ? 'DELETE ACCOUNT'
                          : 'SIGN OUT',
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: baseTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _updateUsername() {
    if (currentUser != null && usernameController.text.isNotEmpty) {
      currentUser!.displayName = usernameController.text;
      updateAppUser(currentUser!);
      setState(() {});
      ToastificationHelper.showSuccessToast(context, 'Username updated');
    }
  }
}
