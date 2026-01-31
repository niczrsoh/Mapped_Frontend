import 'package:flutter/material.dart';

class HashtagEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];

    // Split the text to find hashtags
    text.splitMapJoin(
      RegExp(r"#[a-zA-Z0-9_]+"), // Regex to find #example
      onMatch: (Match match) {
        children.add(
          TextSpan(
            text: match[0],
            style: style?.copyWith(
              color: Colors.blueAccent, // BLUE COLOR
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
