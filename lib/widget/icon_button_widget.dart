import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final TextStyle? textStyle;
  final Function() onTap;

  const IconTextButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onTap,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        radius: 10,
        onTap: onTap,
        child: Column(
          children: [
            icon,
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
