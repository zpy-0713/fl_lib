import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class DebugPageArgs {
  final String? title;

  const DebugPageArgs({
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
          Btn.icon(
            icon: const Icon(Icons.copy, color: Colors.white),
            onTap: (_) => DebugProvider.instance.copy(),
          ),
          Btn.icon(
            onTap: (_) => DebugProvider.instance.clear(),
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
          listenable: DebugProvider.widgets,
          builder: (widgets) {
            if (widgets.isEmpty) return UIs.placeholder;
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
