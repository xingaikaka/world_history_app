# 人物与事件绑定说明

## 三层人物数据来源

1. **阶段 keyFigures** — 各 `HistoryPeriod` 内已有的关键人物
2. **supplementary_figures.dart** — 补充人物库（约 50+ 位），键：`countryId|periodId|姓名`
3. **event_figure_bindings.dart** — 事件节点手动绑定（支持**多位人物**），键：`countryId|periodId|事件标题`

## 绑定优先级

```
事件.relatedFigures（内嵌）
  → event_figure_bindings（手动绑定，支持多人）
    → 自动文本匹配（事件标题/描述含人物名）
```

## 如何新增手动绑定

在 `lib/data/event_figure_bindings.dart` 添加：

```dart
'cn|cn_imperial_early|漠北之战': ['卫青', '霍去病', '汉武帝'],
```

若人物不在阶段 keyFigures 中，先在 `lib/data/supplementary_figures.dart` 补充：

```dart
'cn|cn_imperial_early|卫青': KeyFigure(
  name: '卫青',
  role: '西汉大将军',
  description: '...',
),
```

## 已覆盖国家/阶段

| 国家 | 阶段数 | 手动绑定事件数 |
|------|--------|----------------|
| 中国 | 6 | 40+ |
| 日本 | 4 | 12+ |
| 埃及 | 2 | 12 |
| 希腊 | 1 | 6 |
| 美国 | 2 | 8 |
| 法国 | 1 | 6 |
| 英国 | 3 | 13 |
| 印度 | 3 | 10 |
| 意大利 | 1 | 3 |
| 德国 | 5 | 25+ |
| 韩国 | 5 | 30+ |
| 俄罗斯 | 4 | 20+ |
| 墨西哥 | 5 | 20+ |
| 巴西 | 4 | 12+ |
| 土耳其 | 3 | 12+ |
| 伊朗 | 4 | 15+ |
| 西班牙 | 5 | 15+ |
| 澳大利亚 | 4 | 12+ |

## 人物详情页 · 相关事件

人物详情页会自动列出当前阶段内所有绑定了该人物的历史事件，数据来自 `FigureLinkService.eventsForFigure()`。
