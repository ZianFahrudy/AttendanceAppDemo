import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  const LabelText({
    Key? key,
    required this.text,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(label),
        const SizedBox(
          width: 20,
        ),
        const Text(':'),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ))
      ],
    );
  }
}
