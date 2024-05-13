import 'package:choice/choice.dart';
import 'package:fl_lib/src/core/ext/ctx/common.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:fl_lib/src/res/ui.dart';
import 'package:fl_lib/src/view/choice.dart';
import 'package:fl_lib/src/view/input.dart';
import 'package:fl_lib/src/view/tag.dart';
import 'package:flutter/material.dart';

extension DialogX on BuildContext {
  Future<T?> showRoundDialog<T>({
    Widget? child,
    List<Widget>? actions,
    String? title,
    bool barrierDismiss = true,
    void Function(BuildContext)? onContext,
  }) async {
    return await showDialog<T>(
      context: this,
      barrierDismissible: barrierDismiss,
      builder: (ctx) {
        onContext?.call(ctx);
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: child,
          actions: actions,
          actionsPadding: const EdgeInsets.all(17),
        );
      },
    );
  }

  Future<T> showLoadingDialog<T>({
    required Future<T> Function() fn,
    bool barrierDismiss = false,
  }) async {
    BuildContext? ctx;
    showRoundDialog(
      child: UIs.centerSizedLoading,
      barrierDismiss: barrierDismiss,
      onContext: (c) => ctx = c,
    );

    try {
      return await fn();
    } catch (e) {
      rethrow;
    } finally {
      /// Wait for context to be unmounted
      await Future.delayed(const Duration(milliseconds: 100));
      if (ctx?.mounted == true) {
        ctx?.pop();
      }
    }
  }

  static final _recoredPwd = <String, String>{};

  Future<String?> showPwdDialog({
    String? title,
    String? label,
    required String id,
    bool remember = true,
  }) async {
    if (!mounted) return null;
    return await showRoundDialog<String>(
      title: title ?? l10n.pwd,
      child: Input(
        controller: TextEditingController(text: _recoredPwd[id]),
        autoFocus: true,
        type: TextInputType.visiblePassword,
        obscureText: true,
        onSubmitted: (val) {
          pop(val);
          if (remember) {
            _recoredPwd[id] = val;
          }
        },
        label: label ?? l10n.pwd,
      ),
    );
  }

  Future<List<T>?> showPickDialog<T>({
    required List<T?> items,
    String Function(T)? name,
    bool multi = true,
    List<T>? initial,
    bool clearable = false,
    List<Widget>? actions,
  }) async {
    var vals = initial ?? <T>[];
    final sure = await showRoundDialog<bool>(
      title: l10n.select,
      child: SingleChildScrollView(
        child: Choice<T>(
          onChanged: (value) => vals = value,
          multiple: multi,
          clearable: clearable,
          value: vals,
          builder: (state, _) {
            return Wrap(
              children: List<Widget>.generate(
                items.length,
                (index) {
                  final item = items[index];
                  if (item == null) return UIs.placeholder;
                  return ChoiceChipX<T>(
                    label: name?.call(item) ?? item.toString(),
                    state: state,
                    value: item,
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        if (actions != null) ...actions,
        TextButton(
          onPressed: () => pop(true),
          child: Text(l10n.ok),
        ),
      ],
    );
    if (sure == true && vals.isNotEmpty) {
      return vals;
    }
    return null;
  }

  Future<T?> showPickSingleDialog<T>({
    required List<T?> items,
    String Function(T)? name,
    T? initial,
    bool clearable = false,
    List<Widget>? actions,
  }) async {
    final vals = await showPickDialog<T>(
      items: items,
      name: name,
      multi: false,
      initial: initial == null ? null : [initial],
      actions: actions,
    );
    if (vals != null && vals.isNotEmpty) {
      return vals.first;
    }
    return null;
  }

  Future<List<T>?> showPickWithTagDialog<T>({
    required List<T?> Function(String? tag) itemsBuilder,
    required ValueNotifier<List<String>> tags,
    String Function(T)? name,
    List<T>? initial,
    bool clearable = false,
    bool multi = false,
    List<Widget>? actions,
  }) async {
    var vals = initial ?? <T>[];
    final tag = ValueNotifier<String?>(null);
    final sure = await showRoundDialog<bool>(
      title: l10n.select,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: tag,
            builder: (_, __) => TagSwitcher(
              tags: tags,
              width: 300,
              initTag: tag.value,
              onTagChanged: (e) => tag.value = e,
            ),
          ),
          const Divider(),
          SingleChildScrollView(
            child: ValueListenableBuilder(
              valueListenable: tag,
              builder: (_, val, __) {
                final items = itemsBuilder(val);
                return Choice<T>(
                  onChanged: (value) => vals = value,
                  multiple: multi,
                  clearable: clearable,
                  value: vals,
                  builder: (state, _) {
                    return Wrap(
                      children: List<Widget>.generate(
                        items.length,
                        (index) {
                          final item = items[index];
                          if (item == null) return UIs.placeholder;
                          return ChoiceChipX<T>(
                            label: name?.call(item) ?? item.toString(),
                            state: state,
                            value: item,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      actions: [
        if (actions != null) ...actions,
        TextButton(
          onPressed: () => pop(true),
          child: Text(l10n.ok),
        ),
      ],
    );
    if (sure == true && vals.isNotEmpty) {
      return vals;
    }
    return null;
  }
}
