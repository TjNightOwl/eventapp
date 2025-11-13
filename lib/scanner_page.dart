import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'db/db_helper.dart';
import 'models/attendee.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool processing = false;

  @override
  void reassemble() {
    super.reassemble();
    // On Android hot reload, pause/resume camera
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) async {
      if (processing) return;
      processing = true;
      final raw = scanData.code ?? '';
      // Example: we assume raw is the attendee id or JSON. For simplicity treat as id.
      final id = raw.trim();
      final db = DBHelper();

      final existing = await db.getAttendeeById(id);
      final nowIso = DateTime.now().toIso8601String();

      Attendee attendee;
      if (existing != null) {
        // If already checked in, still update timestamp / keep status
        attendee = existing.copyWith(checkedIn: true, checkedInAt: nowIso);
      } else {
        // Create a new record. You could decode name if QR contains name+id.
        attendee = Attendee(id: id, name: null, checkedIn: true, checkedInAt: nowIso);
      }

      await db.insertOrUpdateAttendee(attendee);

      // Show confirmation
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Checked In'),
          content: Text('Attendee ID: $id\nTime: $nowIso'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                processing = false;
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR for Check-in'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Point camera at attendee QR code'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await controller?.toggleFlash();
                    },
                    child: const Text('Toggle Flash'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
