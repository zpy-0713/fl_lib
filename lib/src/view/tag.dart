import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

const _kTagBtnHeight = 31.0;

class TagBtn extends StatelessWidget {
  final String content;
  final void Function() onTap;
  final bool isEnable;
  final Color? color;

  const TagBtn({
    super.key,
    required this.onTap,
    required this.isEnable,
    required this.content,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _Wrap(
      onTap: onTap,
      color: color ?? UIs.halfAlpha,
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: isEnable ? UIs.text13 : UIs.text13Grey,
      ),
    );
  }
}

class TagEditor extends StatefulWidget {
  final List<String> tags;
  final void Function(List<String>)? onChanged;
  final void Function(String old, String new_)? onRenameTag;
  final List<String> allTags;
  final Color? color;
  final String renameL10n;
  final String tagL10n;
  final String addL10n;

  const TagEditor({
    super.key,
    required this.tags,
    this.onChanged,
    this.onRenameTag,
    this.allTags = const <String>[],
    this.color,
    required this.renameL10n,
    required this.tagL10n,
    required this.addL10n,
  });

  @override
  State<StatefulWidget> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  @override
  Widget build(BuildContext context) {
    return CardX(
      child: ListTile(
        // Align the place of TextField.prefixIcon
        leading: const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.tag),
        ),
        title: _buildTags(widget.tags),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddTagDialog(),
        ),
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    final suggestions = widget.allTags.where((e) => !tags.contains(e)).toList();
    final suggestionLen = suggestions.length;

    /// Add vertical divider if suggestions.length > 0
    final counts = tags.length + suggestionLen + (suggestionLen == 0 ? 0 : 1);
    if (counts == 0) return Text(widget.tagL10n);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _kTagBtnHeight),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index < tags.length) {
            return _buildTagItem(tags[index]);
          } else if (index > tags.length) {
            return _buildTagItem(
              suggestions[index - tags.length - 1],
              isAdd: true,
            );
          }
          return const VerticalDivider();
        },
        itemCount: counts,
      ),
    );
  }

  Widget _buildTagItem(String tag, {bool isAdd = false}) {
    return _Wrap(
      onTap: () {
        if (isAdd) {
          widget.tags.add(tag);
        } else {
          widget.tags.remove(tag);
        }
        widget.onChanged?.call(widget.tags);
        setState(() {});
      },
      onLongPress: () => _showRenameDialog(tag),
      color: widget.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '#$tag',
            textAlign: TextAlign.center,
            style: isAdd ? UIs.text13Grey : UIs.text13,
          ),
          const SizedBox(width: 4.0),
          Icon(
            isAdd ? Icons.add_circle : Icons.cancel,
            size: 13.7,
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    final textEditingController = TextEditingController();
    context.showRoundDialog(
      title: widget.addL10n,
      child: Input(
        autoFocus: true,
        icon: Icons.tag,
        controller: textEditingController,
        hint: widget.tagL10n,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final tag = textEditingController.text;
            widget.tags.add(tag.trim());
            widget.onChanged?.call(widget.tags);
            context.pop();
          },
          child: Text(widget.addL10n),
        ),
      ],
    );
  }

  void _showRenameDialog(String tag) {
    final textEditingController = TextEditingController(text: tag);
    context.showRoundDialog(
      title: widget.renameL10n,
      child: Input(
        autoFocus: true,
        icon: Icons.abc,
        controller: textEditingController,
        hint: widget.tagL10n,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final newTag = textEditingController.text.trim();
            if (newTag.isEmpty) return;
            widget.onRenameTag?.call(tag, newTag);
            context.pop();
            setState(() {});
          },
          child: Text(widget.renameL10n),
        ),
      ],
    );
  }
}

class TagSwitcher extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<List<String>> tags;
  final double width;
  final void Function(String?) onTagChanged;
  final String? initTag;
  final String allL10n;

  const TagSwitcher({
    super.key,
    required this.tags,
    required this.width,
    required this.onTagChanged,
    this.initTag,
    required this.allL10n,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: tags,
      builder: (_, vals, __) {
        if (vals.isEmpty) return UIs.placeholder;
        final items = <String?>[null, ...vals];
        return Container(
          height: _kTagBtnHeight,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          alignment: Alignment.center,
          color: Colors.transparent,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = items[index];
              return TagBtn(
                content: item == null ? allL10n : '#$item',
                isEnable: initTag == item,
                onTap: () => onTagChanged(item),
              );
            },
            itemCount: items.length,
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kTagBtnHeight);
}

final class _Wrap extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Color? color;

  const _Wrap({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 11),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
