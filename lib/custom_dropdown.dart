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

/// A Custom implementation of a dropdown with unique style.
///
/// The [onChanged] callback should update a state variable that defines the
/// dropdown's value. It should also call [State.setState] to rebuild the
/// dropdown with the new value.
///
/// If the [onChanged] callback is null or the list of [items] is null
/// then the dropdown will be disabled, i.e. it will not respond to input.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [CustomDropdownItem], the class used to represent the [items].
class CustomDropdown extends StatefulWidget {
  /// Called when the user selects an item.
  ///
  /// When the user selects an item this callback is fired with the index
  /// of that item.
  /// If the [onChanged] callback is null or the list of [items] is null
  /// then the dropdown button will be disabled.
  final ValueChanged<int> onChanged;

  /// The list of items the user can select
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the dropdown button will be disabled.
  final List<CustomDropdownItem> items;

  /// Index of the current selected value
  ///
  /// If the [valueIndex] is null, the [hint] is displayed.
  final int valueIndex;

  /// A placeholder text that is displayed by the dropdown
  ///
  /// If the dropdown is disabled or the [valueIndex] is null
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

  /// Text [Color] of the value
  final Color enableTextColor;

  /// Text [Color] of the value when the dropdown is disabled
  final Color disabledTextColor;

  /// Text [Color] of each dropdown item
  final Color elementTextColor;

  /// Border radius of the dropdown
  final double borderRadius;

  /// Creates a custom dropdown.
  ///
  /// If [valueIndex] isn't null then it must be the index
  /// of one [CustomDropdownItem]. If [items] or [onChanged] is
  /// null the button will be disabled.
  CustomDropdown({
    Key key,
    @required this.onChanged,
    @required this.hint,
    @required this.items,
    this.valueIndex,
    this.enabledColor = Colors.white,
    this.disabledColor = const Color(0xFFE0E0E0),
    this.openColor = const Color(0xFFF2F2F2),
    this.openIcon = const Icon(Icons.keyboard_arrow_up),
    this.closedIcon = const Icon(Icons.keyboard_arrow_down),
    this.enabledIconColor = const Color(0xFF6200EE),
    this.disabledIconColor = const Color(0xFF757575),
    this.enableTextColor = const Color(0xFF757575),
    this.disabledTextColor = const Color(0xFF757575),
    this.elementTextColor = const Color(0xFF272727),
    this.borderRadius = _kBorderRadius,
  })  : assert(hint != null, "The hint text must be non-null!"),
        assert(items == null || items.length > 0,
            "You must specify at least one item!"),
        assert(
            valueIndex == null ||
                (items != null && valueIndex >= 0 && valueIndex < items.length),
            'The given value index: $valueIndex is outside the items list range.'),
        super(key: key);

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

/// Constant elevation value for closed dropdown
const double _kClosedElevation = 4;

/// Constant elevation value for open dropdown
const double _kOpenElevation = 8;

/// Constant height of each item
const double _kItemHeight = 42;

/// Constant border radius
const double _kBorderRadius = 9;

class CustomDropdownState extends State<CustomDropdown> {
  FocusNode _focusNode = FocusNode();
  LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  OverlayEntry _dropdownOverlay;
  DropdownPosition _dropdownPosition;

  // The dropdown is enabled if onChanged and the list of items are non-null
  bool get _isEnabled => (widget.onChanged != null && widget.items != null);

  // If the value is not-null and the dropdown is enabled display the
  // selected value, otherwise display the hint
  String get _valueText => (widget.valueIndex != null && _isEnabled)
      ? widget.items[widget.valueIndex].text
      : widget.hint;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isOpen = !_isOpen);
    if (_focusNode.hasPrimaryFocus) {
      _dropdownOverlay = _createDropdownOverlay();
      Overlay.of(context).insert(_dropdownOverlay);
    } else {
      _dropdownOverlay?.remove();
    }
  }

  /// Create the floating dropdown overlay
  OverlayEntry _createDropdownOverlay() {
    final RenderBox renderBox = context.findRenderObject();
    final double width = renderBox.size.width;
    final double height = renderBox.size.height;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double yPosition = offset.dy;

    /*
     * Find the dropdown position based on the space left in the screen.
     * If at the bottom there is no more space, and there is some left
     * at the top, set top as position, else set bottom.
     */
    final screenHeight = MediaQuery.of(context).size.height;
    final overlayHeight = (widget.items.length * _kItemHeight) + height;
    _dropdownPosition =
        (screenHeight - (yPosition + height + overlayHeight) <= 0 &&
                yPosition - overlayHeight > 0)
            ? DropdownPosition.top
            : DropdownPosition.bottom;

    // Create the dropdown overlay
    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
              0.0,
              (_dropdownPosition == DropdownPosition.bottom)
                  ? 0.0
                  : -overlayHeight + height),
          child: DropdownData(
            items: widget.items,
            position: _dropdownPosition,
            openColor: widget.openColor,
            enabledColor: widget.enabledColor,
            enableTextColor: widget.enableTextColor,
            elementTextColor: widget.elementTextColor,
            openIcon: widget.openIcon,
            enabledIconColor: widget.enabledIconColor,
            borderRadius: widget.borderRadius,
            child: _DropdownOverlay(
              valueText: _valueText,
              height: overlayHeight,
              onClose: () => _focusNode.unfocus(),
              onValueSelected: (newValue) {
                // Close the dropdown overlay by un-focusing
                _focusNode.unfocus();
                widget?.onChanged(newValue);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: _isEnabled,
      focusNode: _focusNode,
      autofocus: false,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: () {
            // If the dropdown is disabled don't do anything
            if (!_isEnabled) return;
            // request the focus/un-focus if is open
            if (_isOpen)
              _focusNode.unfocus();
            else
              _focusNode.requestFocus();
          },
          child: Material(
            elevation: (!_isEnabled || _isOpen) ? 0.0 : _kClosedElevation,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: _isEnabled ? widget.enabledColor : widget.disabledColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    _valueText,
                    style: TextStyle(
                        color: _isEnabled
                            ? widget.enableTextColor
                            : widget.disabledTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: _isEnabled
                          ? widget.enabledIconColor
                          : widget.disabledIconColor,
                    ),
                    child: widget.closedIcon,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Provider of dropdown data.
///
/// This class implements an [InheritedWidget]
/// to pass to his child some data of the dropdown.
class DropdownData extends InheritedWidget {
  final List<CustomDropdownItem> items;
  final Color enabledColor;
  final Color openColor;
  final Icon openIcon;
  final Color enabledIconColor;
  final Color enableTextColor;
  final Color elementTextColor;
  final DropdownPosition position;
  final double borderRadius;

  DropdownData({
    Key key,
    Widget child,
    this.items,
    this.enabledColor,
    this.openColor,
    this.openIcon,
    this.enabledIconColor,
    this.enableTextColor,
    this.elementTextColor,
    this.position,
    this.borderRadius,
  }) : super(key: key, child: child);

  static DropdownData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DropdownData>();
  }

  @override
  bool updateShouldNotify(DropdownData oldWidget) {
    return items != oldWidget.items ||
        enabledColor != oldWidget.enabledColor ||
        openColor != oldWidget.openColor ||
        openIcon != oldWidget.openIcon ||
        enabledIconColor != oldWidget.enabledIconColor ||
        enableTextColor != oldWidget.enableTextColor ||
        elementTextColor != oldWidget.elementTextColor ||
        position != oldWidget.position ||
        borderRadius != oldWidget.borderRadius;
  }
}

/// Widget that builds the dropdown overlay.
///
/// This Widget is responsible to create the dropdown
/// overlay menu every time is open.
/// This menu has a [onValueSelected] callback, used to
/// pass upwards the on value changed event, from his children
/// to the [CustomDropdown].
class _DropdownOverlay extends StatelessWidget {
  final String valueText;
  final double height;
  final ValueChanged<int> onValueSelected;
  final VoidCallback onClose;

  _DropdownOverlay({
    this.valueText,
    this.height,
    this.onValueSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownData = DropdownData.of(context);
    return Container(
      height: height,
      child: Material(
        // If the overlay is on bottom display an elevation
        elevation: _kOpenElevation,
        color: dropdownData.openColor,
        borderRadius: BorderRadius.circular(dropdownData.borderRadius),
        child: Column(
            children: dropdownData.position == DropdownPosition.top
                ? [_getDropdownItems(context), _getDropdownBody(context)]
                : [_getDropdownBody(context), _getDropdownItems(context)]),
      ),
    );
  }

  /// Create the overlay-ed body of the dropdown.
  Widget _getDropdownBody(BuildContext context) {
    final dropdownData = DropdownData.of(context);
    return GestureDetector(
      onTap: onClose,
      child: Container(
        decoration: BoxDecoration(
          color: dropdownData.enabledColor,
          borderRadius: dropdownData.position == DropdownPosition.top
              ? BorderRadius.vertical(
                  bottom: Radius.circular(dropdownData.borderRadius))
              : BorderRadius.vertical(
                  top: Radius.circular(dropdownData.borderRadius)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Text(
              valueText,
              style: TextStyle(
                  color: dropdownData.enableTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            Spacer(),
            IconTheme(
              data: IconThemeData(
                size: 24,
                color: dropdownData.enabledIconColor,
              ),
              child: dropdownData.openIcon,
            ),
          ],
        ),
      ),
    );
  }

  /// Create the dropdown items
  Widget _getDropdownItems(BuildContext context) {
    final dropdownData = DropdownData.of(context);
    return ColumnBuilder(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        itemCount: dropdownData.items.length,
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: (dropdownData.position == DropdownPosition.top)
                ? BorderRadius.vertical(
                    top: (index == 0)
                        ? Radius.circular(dropdownData.borderRadius)
                        : Radius.zero)
                : BorderRadius.vertical(
                    bottom: (index == dropdownData.items.length - 1)
                        ? Radius.circular(dropdownData.borderRadius)
                        : Radius.zero),
            onTap: () => onValueSelected(index),
            child: _DropdownItemWidget(dropdownData.items[index]),
          );
        });
  }
}

/// Build each single dropdown element.
///
/// This Widget is responsible of the creation of
/// a single dropdown menu element.
class _DropdownItemWidget extends StatelessWidget {
  final CustomDropdownItem item;

  _DropdownItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kItemHeight,
      padding: const EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          item.text,
          style: TextStyle(
            color: DropdownData.of(context).elementTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// A single item in [CustomDropdown].
///
/// The item has a [String] text field which will be used
/// as value by the dropdown.
///
/// See also:
///
/// * [CustomDropdown]
class CustomDropdownItem {
  final String text;

  CustomDropdownItem({@required this.text});
}

/// A convenience widget that wraps a [CustomDropdown] in a [FormField].
class CustomDropdownFormField extends FormField<int> {
  CustomDropdownFormField({
    Key key,
    int value,
    @required List<CustomDropdownItem> items,
    String hint,
    @required this.onChanged,
    FormFieldSetter<int> onSaved,
    FormFieldValidator<int> validator,
    bool autovalidate = false,
    Icon openIcon,
    Icon closedIcon,
    Color enabledColor,
    Color openColor,
    Color disabledColor,
    Color enabledIconColor,
    Color disabledIconColor,
    Color elementTextColor,
    Color enableTextColor,
    Color disabledTextColor,
    double borderRadius,
  }) : super(
          key: key,
          onSaved: onSaved,
          initialValue: value,
          validator: validator,
          autovalidate: autovalidate,
          builder: (FormFieldState<int> field) {
            final _CustomDropdownFormFieldState state =
                field as _CustomDropdownFormFieldState;
            return CustomDropdown(
              onChanged: onChanged == null ? null : state.didChange,
              hint: hint,
              items: items,
              valueIndex: state.value,
              openIcon: openIcon ?? const Icon(Icons.keyboard_arrow_up),
              closedIcon: closedIcon ?? const Icon(Icons.keyboard_arrow_down),
              enabledColor: enabledColor ?? Colors.white,
              openColor: openColor ?? const Color(0xFFF2F2F2),
              disabledColor: disabledColor ?? const Color(0xFFE0E0E0),
              enabledIconColor: enabledIconColor ?? const Color(0xFF6200EE),
              disabledIconColor: disabledIconColor ?? const Color(0xFF757575),
              elementTextColor: elementTextColor ?? const Color(0xFF272727),
              enableTextColor: enableTextColor ?? const Color(0xFF757575),
              disabledTextColor: disabledTextColor ?? const Color(0xFF757575),
              borderRadius: borderRadius ?? 9,
            );
          },
        );

  final ValueChanged<int> onChanged;

  @override
  FormFieldState<int> createState() => _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends FormFieldState<int> {
  @override
  CustomDropdownFormField get widget => super.widget as CustomDropdownFormField;

  @override
  void didChange(int value) {
    super.didChange(value);
    assert(widget.onChanged != null);
    widget.onChanged(value);
  }
}
