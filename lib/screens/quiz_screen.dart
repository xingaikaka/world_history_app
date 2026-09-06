import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../services/history_quiz_service.dart';
import '../theme/app_theme.dart';

enum _QuizMode { daily, favorites }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  _QuizMode _mode = _QuizMode.daily;
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions();
  }

  List<QuizQuestion> _generateQuestions() {
    return _mode == _QuizMode.favorites
        ? HistoryQuizService.generateFromFavorites(count: 5)
        : HistoryQuizService.generate(count: 5);
  }

  void _switchMode(_QuizMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _questions = _generateQuestions();
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _finished = false;
    });
  }

  void _selectOption(int index) {
    if (_answered || _finished) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      _questions = _generateQuestions();
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesEmpty = FavoritesService.instance.items.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.headerDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('历史小测验', style: AppTheme.title(size: 17, color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _QuizModeChip(
                    label: '每日测验',
                    selected: _mode == _QuizMode.daily,
                    onTap: () => _switchMode(_QuizMode.daily),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuizModeChip(
                    label: '收藏测验',
                    selected: _mode == _QuizMode.favorites,
                    onTap: favoritesEmpty ? null : () => _switchMode(_QuizMode.favorites),
                    disabled: favoritesEmpty,
                  ),
                ),
              ],
            ),
          ),
          if (_mode == _QuizMode.favorites && favoritesEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '收藏一些人物或事件后即可使用收藏测验',
                style: AppTheme.body(size: 12, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _questions.isEmpty
                ? _EmptyQuiz(
                    onRetry: _restart,
                    message: _mode == _QuizMode.favorites
                        ? '收藏内容不足以生成题目'
                        : '暂时无法生成题目',
                  )
                : _finished
                    ? _ResultView(
                        score: _score,
                        total: _questions.length,
                        onRestart: _restart,
                      )
                    : _QuestionView(
                        question: _questions[_currentIndex],
                        index: _currentIndex,
                        total: _questions.length,
                        selectedIndex: _selectedIndex,
                        answered: _answered,
                        onSelect: _selectOption,
                        onNext: _next,
                      ),
          ),
        ],
      ),
    );
  }
}

class _QuizModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  const _QuizModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.primary.withValues(alpha: 0.15)
          : AppTheme.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.label(
              size: 12,
              color: disabled
                  ? AppTheme.textSecondary
                  : selected
                      ? AppTheme.primary
                      : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizQuestion question;
  final int index;
  final int total;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('第 ${index + 1} / $total 题',
                  style: AppTheme.label(size: 12, color: AppTheme.textSecondary)),
              const Spacer(),
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: (index + (answered ? 1 : 0)) / total,
                  backgroundColor: AppTheme.divider,
                  color: AppTheme.primary,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(question.prompt, style: AppTheme.title(size: 18)),
          const SizedBox(height: 20),
          ...List.generate(question.options.length, (i) {
            final option = question.options[i];
            final isCorrect = i == question.correctIndex;
            Color borderColor = AppTheme.divider;
            Color bgColor = AppTheme.card;

            if (answered && selectedIndex == i) {
              borderColor = isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
              bgColor = borderColor.withValues(alpha: 0.08);
            } else if (answered && isCorrect) {
              borderColor = const Color(0xFF2E7D32);
              bgColor = borderColor.withValues(alpha: 0.08);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: answered ? null : () => onSelect(i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: AppTheme.label(size: 12, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option, style: AppTheme.body(size: 14))),
                        if (answered && isCorrect)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF2E7D32), size: 20),
                        if (answered && selectedIndex == i && !isCorrect)
                          const Icon(Icons.cancel_rounded,
                              color: Color(0xFFC62828), size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (answered) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(question.explanation,
                  style: AppTheme.body(size: 13, height: 1.6)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  index + 1 >= total ? '查看成绩' : '下一题',
                  style: AppTheme.title(size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _ResultView({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = score / total;
    final message = ratio >= 0.8
        ? '史学达人！'
        : ratio >= 0.6
            ? '不错，继续探索更多历史'
            : '温故知新，再试一次吧';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ratio >= 0.6 ? Icons.emoji_events_rounded : Icons.menu_book_rounded,
              size: 72,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Text('测验完成', style: AppTheme.title(size: 22)),
            const SizedBox(height: 12),
            Text('$score / $total 题正确',
                style: AppTheme.year(size: 32, color: AppTheme.primary)),
            const SizedBox(height: 8),
            Text(message, style: AppTheme.body(size: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('再来一组', style: AppTheme.title(size: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuiz extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const _EmptyQuiz({
    required this.onRetry,
    this.message = '暂时无法生成题目',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_rounded,
                size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(message, style: AppTheme.title(size: 17)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
