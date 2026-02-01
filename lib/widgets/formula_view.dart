import 'package:flutter/material.dart';
import '../boolatro/proof_core/proof_validator.dart';

class FormulaView extends StatelessWidget {
  const FormulaView({
    super.key,
    required this.sentence,
    this.isClickable = false,
    this.onSegmentPressed,
    this.highlightSubFormulas = false,
    this.ruleContext,
    this.textKey,
  });

  final String sentence;
  final bool isClickable;
  final Function(String)? onSegmentPressed;
  final bool highlightSubFormulas;
  final String? ruleContext;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    if (sentence.isEmpty) {
      return const SizedBox.shrink();
    }

    // Identify segments based on ruleContext
    final List<String> segments = _getSegments();

    if (segments.isEmpty || !highlightSubFormulas) {
      return InkWell(
        onTap: isClickable ? () => onSegmentPressed?.call(sentence) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isClickable ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isClickable ? Colors.blue.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Text(
            key: textKey,
            sentence,
            style: TextStyle(
              color: isClickable ? Colors.blueAccent : Colors.white,
              fontFamily: 'monospace',
              fontWeight: isClickable ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      children: _buildInteractiveSegments(segments),
    );
  }

  List<String> _getSegments() {
    if (ruleContext == '&elim') {
       String s = sentence.trim();
       // Strip outer parentheses if they wrap the entire formula
       if (s.startsWith('(') && s.endsWith(')')) {
         // Check if they are actually a pair
         int d = 0;
         bool isPair = true;
         for (int i = 0; i < s.length - 1; i++) {
           if (s[i] == '(') d++;
           else if (s[i] == ')') d--;
           if (d == 0) {
             isPair = false;
             break;
           }
         }
         if (isPair) {
           s = s.substring(1, s.length - 1);
         }
       }

       // We want to return [Left, &, Right]
       int topLevelAnd = -1;
       int d = 0;
       for(int i=0; i<s.length; i++) {
         if (s[i] == '(') d++;
         else if (s[i] == ')') d--;
         else if (d == 0 && s[i] == '&') {
           topLevelAnd = i;
           break;
         }
       }

       if (topLevelAnd != -1) {
         return [
           s.substring(0, topLevelAnd).trim(),
           '&',
           s.substring(topLevelAnd + 1).trim(),
         ];
       }
    }

    return [sentence];
  }

  int _getDepth(String s) {
    int d = 0;
    for(var c in s.runes) {
      if (c == 40) d++; // (
      if (c == 41) d--; // )
    }
    return d;
  }

  List<Widget> _buildInteractiveSegments(List<String> segments) {
    final List<Widget> widgets = [];
    for (final segment in segments) {
      final isOperator = segment == '&' || segment == 'v' || segment == '~';
      final isSubFormula = !isOperator && segment.trim().isNotEmpty;
      
      final bool interactive = isSubFormula && highlightSubFormulas;

      widgets.add(
        InkWell(
          onTap: interactive ? () => onSegmentPressed?.call(segment.trim()) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: interactive ? Colors.blue.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: interactive ? Colors.blue : Colors.transparent,
              ),
            ),
            child: Text(
              segment,
              style: TextStyle(
                color: interactive ? Colors.blueAccent : Colors.white,
                fontFamily: 'monospace',
                fontWeight: interactive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
