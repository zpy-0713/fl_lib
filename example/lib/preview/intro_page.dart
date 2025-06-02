import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

class PreviewIntroPage extends StatelessWidget {
  const PreviewIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroPage(args: IntroPageArgs(pages: [const Center(child: Text('Intro Page'))], onDone: (_) {}));
  }
}
