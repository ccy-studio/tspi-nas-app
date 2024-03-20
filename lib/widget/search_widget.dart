import 'package:flutter/material.dart';
import '../utils/color_util.dart';

class SearchWidget extends StatelessWidget {
  final String placehoder;
  final Widget? prefixIcon;
  final Function(String) callback;
  final Function(String)? onChange;

  final TextEditingController _controller = TextEditingController();

  SearchWidget(
      {super.key,
      required this.placehoder,
      this.prefixIcon,
      required this.callback,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: ColorUtil.hexColorString("#f0f0f0f"),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: prefixIcon,
          ),
          Expanded(
              child: TextField(
            controller: _controller,
            autocorrect: false,
            maxLines: 1,
            textAlign: TextAlign.start,
            onEditingComplete: onComplate,
            onSubmitted: callback,
            onChanged: onChange,
            decoration: InputDecoration(
                hintText: placehoder,
                isDense: true,
                iconColor: Theme.of(context).primaryColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                border: InputBorder.none),
          ))
        ],
      ),
    );
  }

  void onComplate() {
    callback(_controller.text);
  }
}
