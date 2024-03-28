import 'package:flutter/material.dart';

class TextHedaerWidget extends StatelessWidget {
  final String title;
  final Widget? expand;

  const TextHedaerWidget({super.key, required this.title, this.expand});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 23,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          Expanded(child: expand ?? const SizedBox())
        ],
      ),
    );
  }
}
