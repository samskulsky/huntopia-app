// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner_with_effect/qr_scanner_with_effect.dart';

import '../../models/game.dart';
import 'claim_zone.dart';
import 'purchase_screen.dart';
import 'zone_claimed.dart';

class QRView extends StatefulWidget {
  const QRView({super.key});

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    controller?.scannedDataStream.listen(_onScan);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onScan(Barcode scanData) async {
    result = scanData;
    await controller?.pauseCamera();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final String scannedCode = result?.code?.toString() ?? '';
    if (scannedCode.isNotEmpty) {
      _handleQRCode(scannedCode);
    } else {
      await controller?.resumeCamera();
    }
  }

  Future<void> _handleQRCode(String scannedCode) async {
    if (currentZone?.qrCode == scannedCode) {
      setState(() => isComplete = true);
      await _processClaim();
    } else {
      await controller?.resumeCamera();
    }
  }

  Future<void> _processClaim() async {
    if (await canClaimZone(curGame!.gameId, curPlayer!, currentZone!.zoneId)) {
      _updateGameStatus();
      await _navigateToZoneClaimed();
    }
  }

  void _updateGameStatus() {
    final player =
        cGame!.players.firstWhere((p) => p.playerId == curPlayer!.playerId);
    player.points += currentZone!.points;
    player.coinBalance += currentZone!.coins;
    player.zonesClaimed.add(currentZone!.zoneId);

    cGame!.logMessages.add(
      LogMessage(
        message:
            '${curPlayer!.teamName} has claimed ${currentZone!.zoneName} for ${currentZone!.points} points and ${currentZone!.coins} coins.',
        timestamp: DateTime.now(),
        displayName: 'Zone Claimed!',
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
    updateGame(cGame!);
  }

  Future<void> _navigateToZoneClaimed() async {
    Navigator.of(context).pop();
    await Get.off(() => const ZoneClaimed());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return QrScannerWithEffect(
              isScanComplete: isComplete,
              qrKey: qrKey,
              onQrScannerViewCreated: _onQrScannerViewCreated,
              qrOverlayBorderColor: Colors.redAccent,
              cutOutSize: _getCutOutSize(context),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
              effectGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1],
                colors: [Colors.redAccent, Colors.redAccent],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onQrScannerViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(_onScan);
  }

  double _getCutOutSize(BuildContext context) {
    return (MediaQuery.of(context).size.width < 300 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
  }

  void _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool permissionGranted) {
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission to access the camera')),
      );
    }
  }
}
