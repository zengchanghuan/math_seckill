import 'package:flutter/material.dart';

/// Simple LaTeX text display widget for Flutter 3.10 compatibility
/// This is a temporary solution until Flutter SDK is upgraded
class MathText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  const MathText(
    this.text, {
    super.key,
    this.textStyle,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // Simple text display - LaTeX syntax is shown as-is
    // For better rendering, upgrade Flutter SDK and use flutter_math_fork
    return SelectableText(
      _cleanLatex(text),
      style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
      textAlign: textAlign ?? TextAlign.left,
    );
  }

  String _cleanLatex(String latex) {
    // Remove LaTeX delimiters for better readability
    String cleaned = latex
        .replaceAll(r'\$', '') // Remove $ delimiters
        .replaceAll(r'\frac{', '') // Simplify fractions
        .replaceAll(r'}{', '/')
        .replaceAll(r'}', '')
        .replaceAll(r'{', '')
        .replaceAll(r'\sin', 'sin')
        .replaceAll(r'\cos', 'cos')
        .replaceAll(r'\tan', 'tan')
        .replaceAll(r'\ln', 'ln')
        .replaceAll(r'\log', 'log')
        .replaceAll(r'\lim', 'lim')
        .replaceAll(r'\to', '→')
        .replaceAll(r'\infty', '∞')
        .replaceAll(r'\cdot', '·')
        .replaceAll(r'\times', '×')
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\sqrt', '√')
        .replaceAll(r'\sum', 'Σ')
        .replaceAll(r'\int', '∫')
        .replaceAll(r'\partial', '∂')
        .replaceAll(r'\alpha', 'α')
        .replaceAll(r'\beta', 'β')
        .replaceAll(r'\gamma', 'γ')
        .replaceAll(r'\pi', 'π')
        .replaceAll(r'\theta', 'θ')
        .replaceAll(r'\lambda', 'λ')
        .replaceAll(r'\mu', 'μ')
        .replaceAll(r'\sigma', 'σ')
        .replaceAll(r'\Delta', 'Δ')
        .replaceAll(r'\nabla', '∇')
        .replaceAll(r'^', '^') // Keep superscript notation
        .replaceAll(r'_', '_'); // Keep subscript notation

    return cleaned;
  }
}
