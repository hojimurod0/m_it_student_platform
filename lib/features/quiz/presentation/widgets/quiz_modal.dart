import 'dart:async';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/features/quiz/data/repositories/quiz_repository.dart';
import 'package:m_it_student_platform/features/quiz/domain/models/quiz_model.dart';

class QuizModal extends StatefulWidget {
  const QuizModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuizModal(),
    );
  }

  @override
  State<QuizModal> createState() => _QuizModalState();
}

class _QuizModalState extends State<QuizModal> {
  QuizCategory _selectedCategory = QuizCategory.flutter;
  QuizDifficulty? _selectedDifficulty;
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;
  int _earnedXp = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _isFinished = false;
  int _timerSeconds = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadQuestions() {
    _questions = QuizRepository.getQuestionsByDifficulty(_selectedCategory, _selectedDifficulty);
    if (_questions.isEmpty) {
      _questions = QuizRepository.getQuestionsByCategory(_selectedCategory);
    }
    _currentIndex = 0;
    _selectedOptionIndex = null;
    _answered = false;
    _score = 0;
    _earnedXp = 0;
    _streak = 0;
    _maxStreak = 0;
    _isFinished = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timerSeconds > 0 && !_answered) {
        setState(() => _timerSeconds--);
      } else if (_timerSeconds == 0 && !_answered) {
        _onSelectOption(-1); // Timeout
      }
    });
  }

  void _onSelectOption(int index) {
    if (_answered || _isFinished || _questions.isEmpty) return;
    _timer?.cancel();
    final currentQ = _questions[_currentIndex];
    final isCorrect = index == currentQ.correctIndex;

    if (isCorrect) {
      AppHaptics.success();
    } else {
      AppHaptics.error();
    }

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (isCorrect) {
        _score++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        _earnedXp += currentQ.xpReward + (_streak > 1 ? (_streak * 5) : 0);
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    AppHaptics.light();
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
      _startTimer();
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Top Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedCategory.color.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_selectedCategory.icon, color: _selectedCategory.color, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IT Kviz & Bilimni Sinash',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Amaliy dasturlash testlari',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Categories Horizontal Scroll Tabs
          if (!_isFinished) ...[
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: QuizCategory.values.map((cat) {
                  final active = _selectedCategory == cat;
                  final count = QuizRepository.getQuestionsByCategory(cat).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        _loadQuestions();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: active
                              ? cat.color
                              : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? cat.color
                                : theme.colorScheme.outline,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 14,
                              color: active ? Colors.white : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                                color: active ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : (isDark ? Colors.black26 : Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Main Interactive Body
          Expanded(
            child: _isFinished ? _buildResultView(isDark, theme) : _buildQuizView(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(ThemeData theme, bool isDark) {
    if (_questions.isEmpty) return const SizedBox();
    final q = _questions[_currentIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        // Live Game Stats Bar (Progress, Streak, XP, Timer)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: q.difficulty.color.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          q.difficulty.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: q.difficulty.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFF59E0B)),
                            Text(
                              '+${q.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_streak > 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: isDark ? 0.25 : 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                '${_streak}x Streak',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Countdown Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: _timerSeconds <= 5
                          ? AppColors.danger.withValues(alpha: isDark ? 0.3 : 0.15)
                          : (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primarySurface),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: _timerSeconds <= 5
                              ? AppColors.danger
                              : (isDark ? AppColors.primaryAccent : AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_timerSeconds s',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _timerSeconds <= 5
                                ? AppColors.danger
                                : (isDark ? AppColors.primaryAccent : AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Linear Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.black26 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primaryAccent : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Question Number & Text
        Text(
          'Savol ${_currentIndex + 1}/${_questions.length}:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.primaryAccent : AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          q.question,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            height: 1.35,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Code Snippet Box (if available)
        if (q.codeSnippet != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      ],
                    ),
                    Text(
                      _selectedCategory.label.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    color: Color(0xFF38BDF8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Options List
        ...List.generate(q.options.length, (i) {
          final isCorrect = i == q.correctIndex;
          final isSelected = i == _selectedOptionIndex;
          final letters = ['A', 'B', 'C', 'D', 'E'];

          Color bgColor = isDark ? theme.colorScheme.surface : Colors.white;
          Color borderColor = theme.colorScheme.outline;
          Color textColor = theme.colorScheme.onSurface;
          IconData? trailingIcon;
          Color? trailingIconColor;

          if (_answered) {
            if (isCorrect) {
              bgColor = const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.12);
              borderColor = const Color(0xFF10B981);
              textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
              trailingIcon = Icons.check_circle_rounded;
              trailingIconColor = const Color(0xFF10B981);
            } else if (isSelected) {
              bgColor = AppColors.danger.withValues(alpha: isDark ? 0.25 : 0.12);
              borderColor = AppColors.danger;
              textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
              trailingIcon = Icons.cancel_rounded;
              trailingIconColor = AppColors.danger;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _answered ? null : () => _onSelectOption(i),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: (isCorrect || isSelected) && _answered ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: (isCorrect && _answered)
                              ? const Color(0xFF10B981)
                              : (isSelected && _answered)
                                  ? AppColors.danger
                                  : (isDark ? Colors.white12 : Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            letters[i % letters.length],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: (_answered && (isCorrect || isSelected))
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: (_answered && isCorrect) ? FontWeight.w800 : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(trailingIcon, color: trailingIconColor, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Explanation & Next Button
        if (_answered) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Mentor Izohi & Tushuntirish:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.explanation,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              _currentIndex + 1 < _questions.length ? 'Keyingi Savol ➜' : 'Natijalarni Ko\'rish 🏆',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultView(bool isDark, ThemeData theme) {
    final percentage = _questions.isEmpty ? 0 : ((_score / _questions.length) * 100).toInt();
    final isPass = percentage >= 60;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        // Trophy Banner Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isPass ? AppColors.heroGradient : AppColors.cardDarkGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                isPass ? '🏆' : '📚',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 6),
              Text(
                isPass ? 'Ajoyib Natija!' : 'Yana bir bor urinib ko\'ring!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedCategory.label} kvizini yakunladingiz',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ResultPill(label: 'To\'g\'ri javob', value: '$_score/${_questions.length}'),
                  const SizedBox(width: 8),
                  _ResultPill(label: 'Aniqlik', value: '$percentage%'),
                  const SizedBox(width: 8),
                  _ResultPill(label: 'To\'plangan XP', value: '+$_earnedXp XP'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons: Retake & Change category
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loadQuestions,
                icon: const Icon(Icons.replay_rounded, size: 16),
                label: const Text('Qayta Topshirish'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isFinished = false;
                    _selectedCategory = QuizCategory.values[(_selectedCategory.index + 1) % QuizCategory.values.length];
                  });
                  _loadQuestions();
                },
                icon: const Icon(Icons.category_rounded, size: 16),
                label: const Text('Boshqa Kategoriya'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
