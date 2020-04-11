import 'package:flutter/material.dart';

/// Widgets that builds a [Column] with dynamic children
///
/// This Widgets creates a [Column] delegating the
/// building of his children's to a builder callback,
/// like [ListView.builder] is doing.
///
/// This class is inspired by this gits:
/// https://gist.github.com/slightfoot/a75d6c368f1b823b594d9f04bf667231
class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection textDirection;
  final TextBaseline textBaseline;
  final VerticalDirection verticalDirection;

  const ColumnBuilder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.textDirection,
    this.textBaseline,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      textBaseline: textBaseline,
      verticalDirection: verticalDirection,
      children: new List.generate(
          this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}
