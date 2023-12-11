import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final bool value;
  final bool? groupValue;
  final ValueChanged<bool?>? onChanged;
  final String text;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged!(value);
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
          decoration: BoxDecoration(
            color: groupValue == value ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Radio<bool>(
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
      ),
    );
  }
}
