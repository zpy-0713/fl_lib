import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

final class QrShareBtn extends StatelessWidget {
  final String data;
  final int size;

  /// Bottom tip
  final String? tip;

  /// Bottom tip (smaller)
  final String? tip2;

  final Key? qrKey;

  final ImageProvider? centerImg;

  const QrShareBtn({
    super.key,
    required this.data,
    this.size = 200,
    this.tip,
    this.tip2,
    this.qrKey,
    this.centerImg,
  });

  @override
  Widget build(BuildContext context) {
    final qrWidget = QrView(
      key: qrKey,
      data: data,
      size: size,
      tip: tip,
      tip2: tip2,
      centerImg: centerImg,
    );

    final shareTextBtn = Btn.text(
      text: libL10n.save,
      onTap: () async {
        final res = await ScreenshotController().captureFromWidget(qrWidget);
        Pfs.share(bytes: res, name: 'qr_code.png', mime: 'image/png');
      },
    );

    return Btn.icon(
      icon: const Icon(Icons.share),
      onTap: () {
        context.showRoundDialog(
          title: libL10n.share,
          child: qrWidget,
          actions: shareTextBtn.toList,
        );
      },
    );
  }
}
