import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class DebugPageArgs {
  final ValueListenable<List<Widget>?> notifier;
  final void Function() onClear;
  final String? title;

  const DebugPageArgs({
    required this.notifier,
    required this.onClear,
    this.title,
  });
}

class DebugPage extends StatelessWidget {
  final DebugPageArgs args;

  const DebugPage({super.key, required this.args});

  static const route = AppRoute<void, DebugPageArgs>(
    page: DebugPage.new,
    path: '/debug',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          args.title ?? 'Logs',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: args.onClear,
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: _buildTerminal(context),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildTerminal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
        ),
        child: ValBuilder(
          listenable: args.notifier,
          builder: (widgets) {
            if (widgets == null || widgets.isEmpty) return UIs.placeholder;
            return ListView.builder(
              itemCount: widgets.length,
              itemBuilder: (context, index) {
                return widgets[index];
              },
            );
          },
        ),
      ),
    );
  }
}
