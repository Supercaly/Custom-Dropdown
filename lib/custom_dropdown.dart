library custom_dropdown;

import 'package:flutter/material.dart';
import 'column_builder.dart';

/// Position of the floating dropdown's overlay.
///
/// This enum tells the position of the dropdown
/// overlay relative to the dropdown's body.
/// The default value is bottom, so if there's space
/// the overlay will be always displayed below the body.
enum DropdownPosition {
  /// Display the overlay above the dropdown's body
  top,

  /// Display the overlay below the dropdown's body
  bottom,
}

class CustomDropdown extends StatefulWidget {

  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [items] is null
  /// then the dropdown button will be disabled.
  final ValueChanged<String> onChanged;

  /// The list of items the user can select
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the dropdown button will be disabled.
  final List<DropdownItem> items;

  /// Current selected value
  ///
  /// If the [value] is null, the [hint] is displayed.
  final String value;

  /// A placeholder text that is displayed by the dropdown
  ///
  /// If the dropdown is disabled or the [value] is null
  /// this text will be displayed as a placeholder
  final String hint;

  /// [Color] of the main dropdown element when its enabled.
  final Color enabledColor;
  /// [Color] of the floating dropdown element,
  final Color openColor;
  /// [Color] of the main dropdown element when its disabled.
  final Color disabledColor;

  /// [Icon] to display when the dropdown is open
  final Icon openIcon;
  /// [Icon] to display when the dropdown is closed
  final Icon closedIcon;

  /// [Color] of the [Icon] when the dropdown is enabled
  final Color enabledIconColor;
  /// [Color] of the [Icon] when the dropdown is disabled
  final Color disabledIconColor;

  /// Height of each items
  final double itemHeight;

  /// Text [Color] of the value
  final Color valueTextColor;
  /// Text [Color] of the value when the dropdown is disabled
  final Color disabledTextColor;
  /// Text [Color] of each dropdown item
  final Color elementTextColor;

  ///
  CustomDropdown({
    Key key,
    @required this.onChanged,
    @required this.hint,
    @required this.items,
    this.value,
    this.enabledColor = Colors.red,
    this.disabledColor = Colors.brown,
    this.openColor = Colors.lightGreen,
    this.openIcon = const Icon(Icons.keyboard_arrow_up),
    this.closedIcon = const Icon(Icons.keyboard_arrow_down),
    this.enabledIconColor = Colors.black,
    this.disabledIconColor = Colors.grey,
    this.itemHeight = 42,
    this.valueTextColor = const Color(0xFFBFBFBF),
    this.disabledTextColor = Colors.grey,
    this.elementTextColor = const Color(0xFF666666),
  }): assert(items == null ||
    items.length > 0, "Items length must be greater than 0"),
      super(key: key);

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry _dropdownOverlay;
  bool _isOpen = false;
  bool _isEnabled;
  // Size of the dropdown
  double _width, _height;
  // Absolute position of the dropdown
  double _xPosition, _yPosition;
  DropdownPosition _dropdownPosition;

  @override
  void initState() {
    super.initState();
    /*
     * If the onChanged is null or the list of items
     * is null the dropdown is disabled
     */
    (widget.onChanged == null || widget.items == null)
      ? _isEnabled = false
      : _isEnabled = true;
  }

  // Find the absolute dropdown's position and dimensions
  void _findDropdownPosition() {
    RenderBox renderBox = _dropdownKey.currentContext.findRenderObject();
    _width = renderBox.size.width;
    _height = renderBox.size.height;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    _xPosition = offset.dx;
    _yPosition = offset.dy;

    /*
     * Find the dropdown position based on the space left in the screen.
     * If at the bottom there is no more space, and there is some left
     * at the top, set top as position, else set bottom.
     */
    final screenHeight = MediaQuery.of(context).size.height;
    final overlayHeight = widget.items.length * widget.itemHeight;
    _dropdownPosition =
      (screenHeight - (_yPosition + _height + overlayHeight) <= 0 &&
        _yPosition - overlayHeight > 0)
      ? DropdownPosition.top
      : DropdownPosition.bottom;

    print("$_width, $_height, $_xPosition, $_yPosition, $_dropdownPosition");
  }

  // Create the floating dropdown overlay
  OverlayEntry _createFloatingDropdown() => OverlayEntry(
    builder: (context) => Positioned(
      left: _xPosition,
      width: _width,
      top: (_dropdownPosition == DropdownPosition.bottom)? _yPosition + _height: _yPosition - (widget.itemHeight * widget.items.length),
      child: _FloatingDropdown(
        openColor: widget.openColor,
        items: widget.items,
        itemHeight: widget.itemHeight,
        onValueSelected: (newValue) {
          // Close the dropdown overlay
          setState(() => _isOpen = false);
          _dropdownOverlay.remove();
          // Notify that the value is changed
          widget?.onChanged(newValue);
        },
        position: _dropdownPosition,
        openTextColor: widget.elementTextColor,
      ),
    ),
  );

  BorderRadius get _borderRadius {
    if (_isOpen) {
      return _dropdownPosition == DropdownPosition.top
        ? BorderRadius.vertical(bottom: Radius.circular(9))
        : BorderRadius.vertical(top: Radius.circular(9));
    } else
      return BorderRadius.circular(9);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _dropdownKey,
      onTap: () {
        // If the dropdown is disabled don't do anything
        if (!_isEnabled) return;
        if (_isOpen)
          _dropdownOverlay.remove();
        else {
          _findDropdownPosition();
          _dropdownOverlay = _createFloatingDropdown();
          Overlay.of(context).insert(_dropdownOverlay);
        }
        setState(() => _isOpen = !_isOpen);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isEnabled? widget.enabledColor: widget.disabledColor,
          borderRadius: _borderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Text(
              // If the value is not-null and the dropdown is enabled display the
              // selected value, otherwise display the hint
              (widget.value != null && _isEnabled)
                ? widget.value
                : widget.hint,
              style: TextStyle(
                color: _isEnabled? widget.valueTextColor: widget.disabledTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
            Spacer(),
            IconTheme(
              data: IconThemeData(
                size: 24,
                color: _isEnabled? widget.enabledIconColor: widget.disabledIconColor,
              ),
              child: _isOpen? widget.openIcon: widget.closedIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingDropdown extends StatelessWidget {
  final List<DropdownItem> items;
  final double itemHeight;
  final ValueChanged<String> onValueSelected;
  final Color openColor;
  final Color openTextColor;
  final DropdownPosition position;

  _FloatingDropdown({
    @required this.items,
    @required this.itemHeight,
    @required this.onValueSelected,
    @required this.openColor,
    @required this.openTextColor,
    @required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (items.length * itemHeight),
      child: Material(
        elevation: 20,
        color: openColor,
        borderRadius: _bgBorderRadius,
        child: ColumnBuilder(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return InkWell(
              borderRadius: _getInkWellBorderRadius(index),
              onTap: () {
                onValueSelected(items[index].text);
              },
              child: _DropdownItemWidget(
                item: items[index],
                itemHeight: itemHeight,
                openTextColor: openTextColor,
              ),
            );
          }
        ),
      ),
    );
  }

  BorderRadius get _bgBorderRadius =>
    (position == DropdownPosition.top)
      ? BorderRadius.vertical(top: Radius.circular(9))
      : BorderRadius.vertical(bottom: Radius.circular(9));

  BorderRadius _getInkWellBorderRadius(int index) =>
    (position == DropdownPosition.top)
      ? BorderRadius.vertical(
          top: (index == 0)? Radius.circular(9): Radius.zero
        )
      : BorderRadius.vertical(
          bottom: (index == items.length - 1)? Radius.circular(9): Radius.zero
        );
}

class _DropdownItemWidget extends StatelessWidget {
  final DropdownItem item;
  final double itemHeight;
  final Color openTextColor;

  _DropdownItemWidget({
    @required this.item,
    @required this.itemHeight,
    @required this.openTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: itemHeight,
      padding: const EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          item.text,
          style: TextStyle(
            color: openTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// A single dropdown item
class DropdownItem {
  final String text;

  DropdownItem({this.text});
}
