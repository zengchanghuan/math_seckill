import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// 数学公式渲染组件
class MathText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final double? mathFontSize;

  const MathText(
    this.text, {
    super.key,
    this.textStyle,
    this.mathFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final style = textStyle ?? defaultTextStyle;
    final fontSize = mathFontSize ?? style.fontSize ?? 16;

    // 解析文本中的LaTeX公式
    final List<InlineSpan> spans = [];
    final RegExp mathRegExp = RegExp(r'\$([^\$]+)\$');
    int lastMatchEnd = 0;

    for (final match in mathRegExp.allMatches(text)) {
      // 添加普通文本
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }

      // 添加数学公式
      final latex = match.group(1)!;
      try {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: style.copyWith(fontSize: fontSize),
            mathStyle: MathStyle.text,
          ),
        ));
      } catch (e) {
        // 如果解析失败，显示原文
        spans.add(TextSpan(
          text: '\$${latex}\$',
          style: style.copyWith(color: Colors.red),
        ));
      }

      lastMatchEnd = match.end;
    }

    // 添加剩余的普通文本
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

