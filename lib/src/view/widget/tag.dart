import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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

class TagSwitcher extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<Set<String>> tags;
  final double width;
  final void Function(String?) onTagChanged;
  final String? initTag;

  const TagSwitcher({
    super.key,
    required this.tags,
    required this.width,
    required this.onTagChanged,
    this.initTag,
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
                content: item == null ? l10n.all : '#$item',
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
  final Color? color;

  const _Wrap({
    required this.child,
    this.onTap,
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

final class TagTile extends StatelessWidget {
  final ValueNotifier<Set<String>> tags;

  const TagTile({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return tags.listenVal(
      (vals) {
        return ListTile(
          leading: const Icon(MingCute.hashtag_line),
          title: Text(l10n.tag),
          subtitle:
              vals.isEmpty ? null : Text(vals.join(', '), style: UIs.textGrey),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final allTags = (tags.value..addAll(vals)).toList();
            final res = await context.showPickDialog(
              items: allTags.toList(),
              initial: vals.toList(),
              clearable: true,
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    tags.value = {};
                  },
                  child: Text(l10n.clear),
                ),
                TextButton(
                  onPressed: () async {
                    context.pop();
                    final ctrl = TextEditingController();
                    void onSave() {
                      final s = ctrl.text.trim();
                      if (s.isEmpty) return;
                      tags.value = tags.value..add(s);
                      context.pop();
                    }

                    context.showRoundDialog(
                      title: l10n.add,
                      child: Input(
                        controller: ctrl,
                        type: TextInputType.text,
                        label: l10n.tag,
                        icon: MingCute.hashtag_line,
                        hint: l10n.name,
                        suggestion: true,
                        autoCorrect: true,
                        autoFocus: true,
                        onSubmitted: (_) => onSave(),
                      ),
                      actions: [Btn.ok(onTap: (_) => onSave())],
                    );
                  },
                  child: Text(l10n.add),
                ),
              ],
            );

            if (res == null) return;
            tags.value = res.toSet();
          },
        ).cardx;
      },
    );
  }
}
