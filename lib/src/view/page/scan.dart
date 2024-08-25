import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

final class BarcodeScannerPageArgs {
  final List<BarcodeFormat> formats;

  const BarcodeScannerPageArgs({
    this.formats = QRCodeDartScanDecoder.acceptedFormats,
  });
}

class BarcodeScannerPage extends StatefulWidget {
  final BarcodeScannerPageArgs args;

  const BarcodeScannerPage({
    super.key,
    this.args = const BarcodeScannerPageArgs(),
  });

  static const route = AppRoute<Result, BarcodeScannerPageArgs>(
    page: BarcodeScannerPage.new,
    path: '/barcode_scan',
  );

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerWithOverlayState();
}

class _BarcodeScannerWithOverlayState extends State<BarcodeScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRCodeDartScanView(
        scanInvertedQRCode: true,
        typeScan: TypeScan.live,
        formats: widget.args.formats,
        onCapture: (e) => context.pop(e),
      ),
    );
  }
}
