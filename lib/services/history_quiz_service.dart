import 'dart:math';

import '../data/countries_data.dart';
import '../models/country.dart';
import 'favorites_service.dart';

enum QuizQuestionType { figureForEvent, eventCountry, figureRole }

class QuizQuestion {
  final QuizQuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class _EventContext {
  final Country country;
  final HistoryPeriod period;
  final HistoryEvent event;

  const _EventContext({
    required this.country,
    required this.period,
    required this.event,
  });
}

class _FigureContext {
  final Country country;
  final HistoryPeriod period;
  final KeyFigure figure;

  const _FigureContext({
    required this.country,
    required this.period,
    required this.figure,
  });
}

/// 从百科数据生成历史小测验
class HistoryQuizService {
  HistoryQuizService._();

  static List<QuizQuestion> generate({int count = 5, DateTime? seedDate}) {
    final now = seedDate ?? DateTime.now();
    final random = Random(now.year * 10000 + now.month * 100 + now.day + 42);

    final events = <_EventContext>[];
    final figures = <_FigureContext>[];

    for (final country in allCountries) {
      for (final period in country.periods) {
        for (final event in period.events) {
          if (event.title.length >= 2) {
            events.add(_EventContext(country: country, period: period, event: event));
          }
        }
        for (final figure in period.keyFigures) {
          if (figure.name.length >= 2 && figure.role.length >= 2) {
            figures.add(_FigureContext(country: country, period: period, figure: figure));
          }
        }
      }
    }

    if (events.isEmpty || figures.isEmpty) return [];

    final questions = <QuizQuestion>[];
    final usedPrompts = <String>{};

    while (questions.length < count) {
      final typeIndex = random.nextInt(3);
      QuizQuestion? question;

      switch (typeIndex) {
        case 0:
          question = _figureForEventQuestion(events, figures, random, usedPrompts);
        case 1:
          question = _eventCountryQuestion(events, random, usedPrompts);
        case 2:
          question = _figureRoleQuestion(figures, random, usedPrompts);
      }

      if (question != null) {
        questions.add(question);
        usedPrompts.add(question.prompt);
      } else if (usedPrompts.length > count * 3) {
        break;
      }
    }

    return questions;
  }

  /// 基于收藏内容生成测验
  static List<QuizQuestion> generateFromFavorites({int count = 5}) {
    final favorites = FavoritesService.instance.items;
    if (favorites.isEmpty) return [];

    final events = <_EventContext>[];
    final figures = <_FigureContext>[];
    final random = Random(DateTime.now().millisecondsSinceEpoch);

    for (final item in favorites) {
      final country = item.country;
      final period = item.period;
      if (country == null || period == null) continue;

      if (item.kind == FavoriteKind.event) {
        final event = item.event;
        if (event != null && event.title.length >= 2) {
          events.add(_EventContext(country: country, period: period, event: event));
        }
      } else {
        final figure = item.figure;
        if (figure != null && figure.name.length >= 2 && figure.role.length >= 2) {
          figures.add(_FigureContext(country: country, period: period, figure: figure));
        }
      }
    }

    if (events.isEmpty && figures.isEmpty) return [];

    final questions = <QuizQuestion>[];
    final usedPrompts = <String>{};
    final poolSize = events.length + figures.length;
    final maxTypes = poolSize == 1 ? 1 : 3;

    while (questions.length < count) {
      final typeIndex = maxTypes == 1
          ? (figures.isNotEmpty ? 2 : 0)
          : random.nextInt(maxTypes);
      QuizQuestion? question;

      if (typeIndex == 0 && events.isNotEmpty) {
        question = _figureForEventQuestion(events, figures.isNotEmpty ? figures : _allFigures(), random, usedPrompts);
      } else if (typeIndex == 1 && events.isNotEmpty) {
        question = _eventCountryQuestion(events, random, usedPrompts);
      } else if (figures.isNotEmpty) {
        question = _figureRoleQuestion(figures, random, usedPrompts);
      }

      if (question != null) {
        questions.add(question);
        usedPrompts.add(question.prompt);
      } else if (usedPrompts.length > count * 3) {
        break;
      }
    }

    return questions;
  }

  static List<_FigureContext> _allFigures() {
    final figures = <_FigureContext>[];
    for (final country in allCountries) {
      for (final period in country.periods) {
        for (final figure in period.keyFigures) {
          figures.add(_FigureContext(country: country, period: period, figure: figure));
        }
      }
    }
    return figures;
  }

  static QuizQuestion? _figureForEventQuestion(
    List<_EventContext> events,
    List<_FigureContext> figures,
    Random random,
    Set<String> usedPrompts,
  ) {
    for (var attempt = 0; attempt < 12; attempt++) {
      final ctx = events[random.nextInt(events.length)];
      final periodFigures = ctx.period.keyFigures;
      if (periodFigures.isEmpty) continue;

      final correct = periodFigures[random.nextInt(periodFigures.length)];
      final prompt = '「${ctx.event.title}」与哪位人物相关？';
      if (usedPrompts.contains(prompt)) continue;

      final wrongPool = figures
          .where((f) => f.figure.name != correct.name)
          .map((f) => f.figure.name)
          .toSet()
          .toList()
        ..shuffle(random);

      final options = _buildOptions(correct.name, wrongPool, random);
      if (options == null) continue;

      return QuizQuestion(
        type: QuizQuestionType.figureForEvent,
        prompt: prompt,
        options: options.$1,
        correctIndex: options.$2,
        explanation:
            '${correct.name}（${correct.role}）与「${ctx.event.title}」同属 ${ctx.country.name} · ${ctx.period.title}。',
      );
    }
    return null;
  }

  static QuizQuestion? _eventCountryQuestion(
    List<_EventContext> events,
    Random random,
    Set<String> usedPrompts,
  ) {
    for (var attempt = 0; attempt < 12; attempt++) {
      final ctx = events[random.nextInt(events.length)];
      final prompt = '「${ctx.event.title}」发生在哪个国家？';
      if (usedPrompts.contains(prompt)) continue;

      final wrongPool = allCountries
          .where((c) => c.id != ctx.country.id)
          .map((c) => c.name)
          .toList()
        ..shuffle(random);

      final options = _buildOptions(ctx.country.name, wrongPool, random);
      if (options == null) continue;

      return QuizQuestion(
        type: QuizQuestionType.eventCountry,
        prompt: prompt,
        options: options.$1,
        correctIndex: options.$2,
        explanation:
            '「${ctx.event.title}」（${ctx.event.year}）属于 ${ctx.country.name} · ${ctx.period.title}。',
      );
    }
    return null;
  }

  static QuizQuestion? _figureRoleQuestion(
    List<_FigureContext> figures,
    Random random,
    Set<String> usedPrompts,
  ) {
    for (var attempt = 0; attempt < 12; attempt++) {
      final ctx = figures[random.nextInt(figures.length)];
      final prompt = '${ctx.figure.name} 的身份是？';
      if (usedPrompts.contains(prompt)) continue;

      final wrongPool = figures
          .where((f) => f.figure.role != ctx.figure.role)
          .map((f) => f.figure.role)
          .toSet()
          .toList()
        ..shuffle(random);

      final options = _buildOptions(ctx.figure.role, wrongPool, random);
      if (options == null) continue;

      return QuizQuestion(
        type: QuizQuestionType.figureRole,
        prompt: prompt,
        options: options.$1,
        correctIndex: options.$2,
        explanation:
            '${ctx.figure.name}：${ctx.figure.role}（${ctx.country.name} · ${ctx.period.title}）',
      );
    }
    return null;
  }

  static (List<String>, int)? _buildOptions(
    String correct,
    List<String> wrongPool,
    Random random,
  ) {
    final wrong = <String>{};
    for (final item in wrongPool) {
      if (item != correct) wrong.add(item);
      if (wrong.length >= 3) break;
    }
    if (wrong.length < 3) return null;

    final options = [correct, ...wrong.take(3)]..shuffle(random);
    return (options, options.indexOf(correct));
  }
}
