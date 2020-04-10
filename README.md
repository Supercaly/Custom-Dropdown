# Custom Dropdown

A simple dropdown library with custom style for Flutter.

## Quick Start

Add `CustomDropdown` to the widget tree

```dart
class TestWidgetState extends State<TestWidget> {
  int _checkboxValue;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomDropdown(
        valueIndex: _checkboxValue,
        hint: "Hint",
        items: [
          DropdownItem(text: "first"),
          DropdownItem(text: "second"),
          DropdownItem(text: "third"),
          DropdownItem(text: "fourth"),
        ],
        onChanged: (newValue) {
          setState(() => _checkboxValue = newValue);
        },
      ),
    );
  }
}
```