import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';
import '../models/medicine.dart';
import '../utils/file_downloader.dart';

class QrDisplayScreen extends StatefulWidget {
  final Medicine medicine;

  const QrDisplayScreen({super.key, required this.medicine});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<Uint8List?> _captureQrBytes(String qrUrl) async {
    try {
      // Generate clean high-resolution 800x800 PNG for printing on strips
      final painter = QrPainter(
        data: qrUrl,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF111111),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF111111),
        ),
      );
      final picData = await painter.toImageData(800, format: ui.ImageByteFormat.png);
      return picData?.buffer.asUint8List();
    } catch (e) {
      // Fallback to repaint boundary if painter fails
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
      return null;
    }
  }

  Future<void> _downloadQr(String qrUrl) async {
    setState(() => _isDownloading = true);

    try {
      final bytes = await _captureQrBytes(qrUrl);
      if (bytes == null) throw Exception('Failed to generate image data');

      final cleanName = widget.medicine.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final cleanBatch = widget.medicine.batchNo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final filename = 'QR_${cleanName}_$cleanBatch.png';

      final result = await FileDownloader.downloadPng(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'QR image downloaded ($filename)'
                  : (result != null ? 'Saved: $result' : 'QR image saved!'),
            ),
            backgroundColor: const Color(0xFF1565C0),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareQr(String qrUrl) async {
    setState(() => _isSharing = true);

    try {
      final bytes = await _captureQrBytes(qrUrl);
      if (bytes == null) throw Exception('Failed to generate image data');

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/QR_${widget.medicine.name}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.medicine.name} (${widget.medicine.dosage}) - Internal Strip QR',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;
    final dateFmt = DateFormat('dd MMM yyyy');
    final qrUrl = med.toWebUrl(baseUrl: AppConfig.viewerBaseUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Code Box
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      child: QrImageView(
                        data: qrUrl,
                        version: QrVersions.auto,
                        size: 220,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF111111),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Ready for Aluminium Strip Print',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scannable by any smartphone camera',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons: Download & Share
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : () => _downloadQr(qrUrl),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(_isDownloading ? 'Saving...' : 'Download QR Image'),
                  ),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : () => _shareQr(qrUrl),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Medicine details preview card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (med.genericName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            med.genericName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xBBFFFFFF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _infoRow('Dosage', med.dosage),
                  _infoRow('Manufacturer', med.manufacturer),
                  _infoRow('Batch No.', med.batchNo),
                  _infoRow('Mfg. Date', dateFmt.format(med.mfgDate)),
                  _infoRow('Exp. Date', dateFmt.format(med.expDate)),
                  if (med.description.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Text(
                        med.description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Back Home Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back to Saved Strips'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF777777))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}
