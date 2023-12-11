import 'package:flutter/material.dart';

class CustomRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String text;

  const CustomRadioListTile({super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
        decoration: BoxDecoration(
          color: groupValue == value ? Colors.white : Colors.white38,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: groupValue == value ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
