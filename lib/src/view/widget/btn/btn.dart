import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';

/// The callback when the button is tapped.
typedef BtnOnTap = void Function(BuildContext);

/// {@template btntype}
/// The type of the button.
/// - [BtnType.text] => [TextButton]
/// - [BtnType.icon] => [IconButton]
/// - [BtnType.column] => [Column] wrapped by [InkWell]
/// - [BtnType.row] => [Row] wrapped by [InkWell]
/// {@endtemplate}
///
/// {@template btntype_is_column_or_row}
/// If [type] is [BtnType.column] or [BtnType.row],
/// {@endtemplate}
/// some properties will be ignored.
enum BtnType {
  /// Row( Icon, Text ) or Row( Text, Icon ) based on LTR or RTL
  row,

  /// Text only
  text,

  /// Icon only
  icon,

  /// Column( Icon, Text )
  column,
  ;
}

/// {@template btn_default_on_tap}
/// By default, it will exec `context.pop()`.
/// {@endtemplate}
///
/// Put if here, or the template macro will work incorrectly.
void _defaultOnTap(BuildContext context) => context.pop();

const kGap = 17.0;

const kPadding = EdgeInsets.symmetric(horizontal: 23, vertical: 15);

/// A placeholder icon that can't be displayed.
const unDisplayableIcon = Icon(IconData(0));

final class Btn extends StatelessWidget {
  /// The callback when the button is tapped.
  ///
  /// If it's set to `null` explicitly, the button will be disabled.
  ///
  /// {@macro btn_default_on_tap}
  final BtnOnTap? onTap;

  /// {@template btn_text_icon}
  /// At lease one of [text] and [icon] must be not null.
  /// {@endtemplate}
  ///
  /// The text of the button.
  /// If [Btn.type] is [BtnType.icon], it will be passed to the tooltip.
  final String text;

  /// {@macro btn_text_icon}
  /// The icon of the button.
  final Icon? icon;

  /// The gap between the [icon] and the [text].
  ///
  /// It will be ignored if the [icon] or [text] is null.
  final double? gap;

  /// Style of the [text]
  final TextStyle? textStyle;

  /// {@macro btntype}
  final BtnType type;

  /// The padding of the button.
  ///
  /// {@macro btntype_is_column_or_row}
  /// default is [BtnX.kPadding], or `null`.
  final EdgeInsetsGeometry? padding;

  /// The alignment of the [Column] or [Row].
  ///
  /// {@macro btntype_is_column_or_row}
  /// default is [MainAxisAlignment.spaceBetween], or `null`.
  final MainAxisAlignment? mainAxisAlignment;

  /// The [MainAxisSize] of the [Column] or [Row].
  ///
  /// {@macro btntype_is_column_or_row}
  /// default is [MainAxisSize.max], or `null`.
  /// TODO: Change to [MainAxisSize.min] by default?
  final MainAxisSize? mainAxisSize;

  const Btn.text({
    super.key,
    required this.text,
    this.onTap = _defaultOnTap,
    this.textStyle,
    this.padding,
  })  : type = BtnType.text,
        gap = null,
        mainAxisAlignment = null,
        mainAxisSize = null,
        icon = null;

  const Btn.icon({
    super.key,
    required this.icon,
    this.text = '',
    this.onTap = _defaultOnTap,
    this.padding,
  })  : type = BtnType.icon,
        gap = null,
        mainAxisAlignment = null,
        mainAxisSize = null,
        textStyle = null;

  const Btn.column({
    super.key,
    required this.text,
    required this.icon,
    this.onTap = _defaultOnTap,
    this.gap,
    this.textStyle,
    this.padding = kPadding,
  })  : type = BtnType.column,
        mainAxisAlignment = MainAxisAlignment.spaceBetween,
        mainAxisSize = MainAxisSize.max;

  const Btn.row({
    super.key,
    required this.text,
    required this.icon,
    this.onTap = _defaultOnTap,
    this.gap,
    this.textStyle,
    this.padding = kPadding,
  })  : type = BtnType.row,
        mainAxisAlignment = MainAxisAlignment.spaceBetween,
        mainAxisSize = MainAxisSize.max;

  Btn.ok({
    super.key,
    this.onTap = _defaultOnTap,
    bool red = false,
  })  : text = l10n.ok,
        icon = null,
        type = BtnType.text,
        gap = null,
        padding = null,
        mainAxisAlignment = null,
        mainAxisSize = null,
        textStyle = red ? UIs.textRed : null;

  Btn.cancel({
    super.key,
    this.onTap = _defaultOnTap,
  })  : text = l10n.cancel,
        icon = null,
        type = BtnType.text,
        gap = null,
        padding = null,
        mainAxisAlignment = null,
        mainAxisSize = null,
        textStyle = null;

  @override
  Widget build(BuildContext context) => switch (type) {
        BtnType.text => _text(context),
        BtnType.icon => _icon(context),
        BtnType.column => _column(context),
        BtnType.row => _tile(context),
      };

  Widget _text(BuildContext context) {
    if (icon != null) {
      debugPrint(
        '[icon] should be null if [type] == [BtnType.text].'
        ' The icon will be ignored.',
      );
    }
    return TextButton(
      onPressed: onTap == null ? null : () => onTap?.call(context),
      child: Text(text, style: textStyle),
    );
  }

  Widget _icon(BuildContext context) {
    if (icon == null) {
      debugPrint('[icon] can\'t be null if [type] == [BtnType.icon].');
    }

    return IconButton(
      onPressed: onTap == null ? null : () => onTap?.call(context),
      icon: icon ?? unDisplayableIcon,
      tooltip: text,
    );
  }

  Widget _column(BuildContext context) {
    if (icon == null) {
      debugPrint('[icon] can\'t be null if [type] == [BtnType.column].');
    }

    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap == null ? null : () => onTap?.call(context),
      child: Column(
        children: [
          icon ?? unDisplayableIcon,
          SizedBox(height: gap ?? kGap),
          Text(text, style: textStyle),
        ],
      ).paddingSymmetric(horizontal: 23, vertical: 15),
    );
  }

  Widget _tile(BuildContext context) {
    if (icon == null) {
      debugPrint('[icon] can\'t be null if [type] == [BtnType.tile].');
    }

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final icon_ = icon ?? unDisplayableIcon;
    final gap_ = SizedBox(height: gap ?? kGap);
    final text_ = Text(text, style: textStyle);
    final children = isRTL ? [text_, gap_, icon_] : [icon_, gap_, text_];
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap == null ? null : () => onTap?.call(context),
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: children,
      ),
    );
  }
}
