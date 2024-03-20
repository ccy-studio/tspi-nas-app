import 'package:flutter/material.dart';

class TextHedaerWidget extends StatelessWidget {
  final String title;

  const TextHedaerWidget({super.key, required this.title});

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
          )
        ],
      ),
    );
  }
}
