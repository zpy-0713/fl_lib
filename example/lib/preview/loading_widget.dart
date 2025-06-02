import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

class PreviewLoadingWidget extends StatelessWidget {
  const PreviewLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: const Text('Loading Widget Preview')),
      body: Center(child: ListView(children: [UIs.centerLoading, SizedBox(height: 20), UIs.smallLinearLoading])),
    );
  }
}
