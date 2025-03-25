/// File view page / card
///
/// - Preview text/image file content
/// - Open other file types with system app
library;

import 'dart:convert';
import 'dart:io';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

/// File view page arguments
final class FileViewPageArgs {
  final String? path;
  final String? name;
  final Uint8List? content;
  final Set<String> supportedMimes;

  const FileViewPageArgs({
    this.path,
    this.name,
    this.content,
    this.supportedMimes = const {},
  }) : assert(path != null || content != null, 'path or content must be provided');
}

/// File view page
final class FileViewPage extends StatefulWidget {
  final FileViewPageArgs args;

  const FileViewPage({
    super.key,
    required this.args,
  });

  @override
  _FileViewPageState createState() => _FileViewPageState();

  static final route = AppRouteArg<void, FileViewPageArgs>(
    page: FileViewPage.new,
    path: '/file_view',
  );
}

final class _FileViewPageState extends State<FileViewPage> {
  (String mime, Uint8List content)? _content;

  @override
  void initState() {
    super.initState();
    if (widget.args.content != null) {
      _content = (widget.args.supportedMimes.firstOrNull ?? 'text/plain', widget.args.content!);
    } else {
      _fetchContent().then((value) => setState(() => _content = value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.args.name ?? libL10n.file),
      ),
      body: _buildBody(context),
    );
  }

  Future<(String mime, Uint8List content)?> _fetchContent() async {
    final file = File(widget.args.path!);
    final mime = await file.mimeType;
    if (mime != null && !widget.args.supportedMimes.contains(mime)) {
      return null;
    }
    return (mime ?? 'text/plain', await file.readAsBytes());
  }

  Widget _buildBody(BuildContext context) {
    if (_content == null) return _buildUnsupport();

    final mime = _content!.$1;
    return switch (mime) {
      _ when mime.startsWith('image/') => _buildImage(_content!.$2),
      _ => _buildText(_content!.$2),
    };
  }

  Widget _buildText(Uint8List content) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureWidget(
          future: compute(utf8.decode, content),
          success: (content) {
            return SizedBox(
              width: double.infinity,
              child: Text(content ?? ''),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(Uint8List content) {
    return InteractiveViewer(
      constrained: false,
      child: Image.memory(content, fit: BoxFit.contain),
    );
  }

  Widget _buildUnsupport() {
    return Center(
      child: Text(libL10n.unsupported),
    );
  }
}

/// File card view;
///
/// [Card] + [ListTile]
final class FileCardView extends StatefulWidget {
  /// File path.
  final String path;

  /// Use this to override the file name.
  final String? name;

  /// For smooth UI, set a delay to load file stat.
  final Duration loadDelay;

  const FileCardView({
    super.key,
    required this.path,
    this.name,
    this.loadDelay = const Duration(milliseconds: 1100),
  });

  @override
  _FileCardViewState createState() => _FileCardViewState();
}

final class _FileCardViewState extends State<FileCardView> with AutomaticKeepAliveClientMixin {
  FileStat? _stat;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.loadDelay).then(
      (_) => File(widget.path).stat().then(
            (value) => setState(() => _stat = value),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: ListTile(
        leading: const Icon(MingCute.file_fill),
        title: Text(widget.name ?? widget.path.split('/').lastOrNull ?? ''),
        subtitle: _buildSubtitle(context),
        onTap: () {
          FileViewPage.route.go(context, FileViewPageArgs(path: widget.path, name: widget.name));
        },
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final size = _stat?.size.bytes2Str;
    final date = _stat?.modified.toLocal().ymdhms();
    return Text('$size, $date');
  }

  @override
  bool get wantKeepAlive => true;
}
