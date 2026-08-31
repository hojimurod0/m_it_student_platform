import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';

/// Clean, beautiful, syntax-colored code viewer box for lesson materials and chat snippets.
class CodeViewerBox extends StatelessWidget {
  const CodeViewerBox({
    super.key,
    required this.code,
    this.language = 'Dart',
    this.title,
  });

  final String code;
  final String language;
  final String? title;

  void _copyToClipboard(BuildContext context) {
    AppHaptics.selection();
    Clipboard.setData(ClipboardData(text: code));
    MitToast.success(context, context.tr('codeCopied'));
  }

  @override
  Widget build(BuildContext context) {
    final lines = code.trim().split('\n');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                // Terminal window buttons
                Row(
                  children: [
                    Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title ?? language,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => _copyToClipboard(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 12, color: AppColors.accentLime),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('copyCode'),
                          style: const TextStyle(
                            color: AppColors.accentLime,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Body with Line Numbers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Numbers Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lines.length,
                    (i) => Text(
                      '${i + 1} ',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Code content Column with syntax highlighting
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) => _HighlightedLine(line: line)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedLine extends StatelessWidget {
  const _HighlightedLine({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    // Simple fast keyword coloring
    final isComment = line.trimLeft().startsWith('//') || line.trimLeft().startsWith('#');
    if (isComment) {
      return Text(
        line,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          color: Color(0xFF64748B),
          fontStyle: FontStyle.italic,
          height: 1.45,
        ),
      );
    }

    final spans = <TextSpan>[];

    final keywords = {
      'class', 'void', 'final', 'const', 'import', 'return', 'if', 'else', 'async',
      'await', 'extends', 'with', 'static', 'def', 'print', 'int', 'String', 'bool',
      'double', 'List', 'Map', 'Set', 'SELECT', 'FROM', 'WHERE', 'INSERT', 'UPDATE'
    };

    final colors = {
      'keywords': const Color(0xFFF43F5E),
      'types': const Color(0xFF38BDF8),
      'strings': const Color(0xFFA3E635),
      'numbers': const Color(0xFFF59E0B),
      'normal': const Color(0xFFF1F5F9),
    };

    int currentIndex = 0;
    while (currentIndex < line.length) {
      // Find strings
      if (line[currentIndex] == "'" || line[currentIndex] == '"') {
        final quote = line[currentIndex];
        final nextQuote = line.indexOf(quote, currentIndex + 1);
        if (nextQuote != -1) {
          spans.add(TextSpan(
            text: line.substring(currentIndex, nextQuote + 1),
            style: TextStyle(color: colors['strings']),
          ));
          currentIndex = nextQuote + 1;
          continue;
        }
      }

      // Check words
      final match = RegExp(r'[a-zA-Z0-9_]+').matchAsPrefix(line, currentIndex);
      if (match != null) {
        final word = match.group(0)!;
        Color wordColor = colors['normal']!;
        if (keywords.contains(word)) {
          wordColor = colors['keywords']!;
        } else if (word[0].toUpperCase() == word[0] && !RegExp(r'^[0-9]').hasMatch(word)) {
          wordColor = colors['types']!;
        } else if (RegExp(r'^\d+$').hasMatch(word)) {
          wordColor = colors['numbers']!;
        }

        spans.add(TextSpan(
          text: word,
          style: TextStyle(color: wordColor),
        ));
        currentIndex += word.length;
      } else {
        spans.add(TextSpan(
          text: line[currentIndex],
          style: TextStyle(color: colors['normal']),
        ));
        currentIndex++;
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        height: 1.45,
      ),
    );
  }
}
