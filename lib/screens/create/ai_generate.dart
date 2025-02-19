import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/utils/toastification_helper.dart';

import '../../utils/theme_data.dart';
import '../../widgets/gradient_background.dart';
import '../home_screen.dart';
import '../../utils/game_utils.dart';

class AIGenerate extends StatefulWidget {
  const AIGenerate({super.key});

  @override
  State<AIGenerate> createState() => _AIGenerateState();
}

class _AIGenerateState extends State<AIGenerate> {
  TextEditingController gameDescriptionController = TextEditingController();
  StreamSubscription<QuerySnapshot>? _requestsSubscription;
  List<DocumentSnapshot> activeRequests = [];

  @override
  void initState() {
    super.initState();
    _listenToRequests();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }

  void _listenToRequests() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _requestsSubscription = FirebaseFirestore.instance
        .collection('aiGameRequests')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'processing'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            activeRequests = snapshot.docs;
          });
        });
  }

  Future<void> _createGameRequest(
      int totalZones, String model, int tokenCost) async {
    if (gameDescriptionController.text.isEmpty) {
      ToastificationHelper.showErrorToast(
          context, 'Please enter a game description.');
      return;
    }

    try {
      currentUser!.tokens -= tokenCost;
      await FirebaseFirestore.instance.collection('aiGameRequests').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'description': gameDescriptionController.text,
        'totalZones': totalZones,
        'status': 'pending',
        'message': 'Request created',
        'createdAt': FieldValue.serverTimestamp(),
        'model': model,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'tokens': currentUser!.tokens});

      gameDescriptionController.clear();
      ToastificationHelper.showSuccessToast(
          context, 'Game generation started! Check back soon.');
    } catch (e) {
      ToastificationHelper.showErrorToast(
          context, 'Error creating game request: $e');
    }
  }

  void _showTokenRequestDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showStandardDialog(
      context: context,
      title: 'Request Tokens',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We will review your request, and if approved, you will receive your tokens within 7 days (usually much faster).',
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'How many tokens do you need?',
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: baseTextStyle.copyWith(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade400),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: baseTextStyle,
          ),
          const SizedBox(height: 16),
          Text(
            'What will you use them for?',
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Briefly describe your planned usage',
              hintStyle: baseTextStyle.copyWith(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade400),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: baseTextStyle,
          ),
        ],
      ),
      actions: [
        buildDialogAction(
          text: 'Request',
          isPrimary: true,
          onPressed: () async {
            if (amountController.text.isEmpty ||
                reasonController.text.isEmpty) {
              ToastificationHelper.showErrorToast(
                  context, 'Please fill in all fields');
              return;
            }

            final amount = int.tryParse(amountController.text);
            if (amount == null || amount <= 0) {
              ToastificationHelper.showErrorToast(
                  context, 'Please enter a valid amount');
              return;
            }

            try {
              await FirebaseFirestore.instance.collection('tokenRequests').add({
                'userId': currentUser!.uid,
                'userName': currentUser!.displayName,
                'amount': amount,
                'reason': reasonController.text,
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ToastificationHelper.showSuccessToast(
                  context, 'Token request submitted');
            } catch (e) {
              ToastificationHelper.showErrorToast(
                  context, 'Error submitting request');
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white70),
          onPressed: () => Get.offAll(() => const HomeScreen()),
        ),
        title: Text(
          'AI Game Creator',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Describe Your Game',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Be specific about locations and game style',
                style: baseTextStyle.copyWith(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: gameDescriptionController,
                decoration: InputDecoration(
                  hintText:
                      'Example: Historical downtown tour with stops at courthouse, town square, and monuments...',
                  hintStyle: baseTextStyle.copyWith(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
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
                ),
                maxLines: 4,
                maxLength: 300,
                style: baseTextStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for Better Results',
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      icon: Icons.tips_and_updates_outlined,
                      text:
                          'The more specific your description, the better your game will be!',
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      icon: Icons.place_outlined,
                      text:
                          'Include specific location names and landmarks you want in your game.',
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      icon: Icons.format_list_bulleted,
                      text:
                          'Add details about difficulty, theme, and any special requirements.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (activeRequests.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Generations',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generation can take up to 10 minutes',
                        style: baseTextStyle.copyWith(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...activeRequests.map((request) {
                        final data = request.data() as Map<String, dynamic>;
                        return _buildRequestTile(
                          status: data['status'] as String,
                          message: data['message'] as String,
                          description: data['description'] as String,
                          isFirst: request == activeRequests.first,
                          isLast: request == activeRequests.last,
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Model',
                            style: baseTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'You have ${currentUser!.tokens} tokens remaining',
                            style: baseTextStyle.copyWith(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          if (currentUser!.tokens < 1) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Request more tokens by clicking the button below.',
                              style: baseTextStyle.copyWith(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (currentUser!.tokens >= 1)
                      _buildModelTile(
                        title: 'Basic Model',
                        subtitle: 'Fewer zones • 1 token',
                        onTap: () => _createGameRequest(40, "gpt-4o-mini", 1),
                        isFirst: true,
                        isLast: currentUser!.tokens < 15,
                      ),
                    if (currentUser!.tokens >= 15) ...[
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      _buildModelTile(
                        title: 'Advanced Model',
                        subtitle: 'More zones • 15 tokens',
                        onTap: () => _createGameRequest(50, "gpt-4o", 15),
                        isLast: currentUser!.tokens < 50,
                      ),
                    ],
                    if (currentUser!.tokens >= 50) ...[
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      _buildModelTile(
                        title: 'Expert Model',
                        subtitle: 'Many zones • 50 tokens',
                        onTap: () => _createGameRequest(165, "gpt-4o", 50),
                        isLast: true,
                      ),
                    ],
                  ],
                ),
              ),
              if (currentUser!.tokens < 1) ...[
                const SizedBox(height: 16),
                _buildTokenRequestButton(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTile({
    required String status,
    required String message,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Extract progress percentage if available
    int? progress;
    if (message.contains('%')) {
      final match = RegExp(r'(\d+)%').firstMatch(message);
      if (match != null) {
        progress = int.tryParse(match.group(1)!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'processing')
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(status),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      status.toUpperCase(),
                      style: baseTextStyle.copyWith(
                        fontSize: 12,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: baseTextStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(status),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            description,
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.white54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildModelTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: Colors.green.shade400,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue.shade300,
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: baseTextStyle.copyWith(
              fontSize: 13,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenRequestButton() {
    return FutureBuilder<int>(
      future: _getPendingRequestsCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: pendingCount > 0 ? null : _showTokenRequestDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(pendingCount > 0 ? 0.1 : 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    color:
                        Colors.purple.withOpacity(pendingCount > 0 ? 0.5 : 1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pendingCount > 0
                        ? '$pendingCount pending request${pendingCount == 1 ? '' : 's'}'
                        : 'Request Tokens',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          Colors.purple.withOpacity(pendingCount > 0 ? 0.5 : 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int> _getPendingRequestsCount() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('tokenRequests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // Standardize text styles across the app
  TextStyle get headerStyle => baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get subheaderStyle => baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get bodyStyle => baseTextStyle.copyWith(
        fontSize: 14,
        color: Colors.white70,
        height: 1.4,
      );

  TextStyle get captionStyle => baseTextStyle.copyWith(
        fontSize: 12,
        color: Colors.white70,
      );
}
