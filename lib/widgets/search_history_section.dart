import 'package:flutter/material.dart';

import '../services/search_history_service.dart';
import '../theme/app_theme.dart';

class SearchHistorySection extends StatelessWidget {
  final SearchHistoryKind kind;
  final ValueChanged<String> onSelect;
  final VoidCallback? onClear;

  const SearchHistorySection({
    super.key,
    required this.kind,
    required this.onSelect,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SearchHistoryService.instance,
      builder: (context, _) {
        final items = SearchHistoryService.instance.forKind(kind);
        if (items.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('最近搜索',
                      style: AppTheme.label(size: 11, color: AppTheme.textSecondary)),
                  const Spacer(),
                  if (onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: Text('清除',
                          style: AppTheme.label(size: 11, color: AppTheme.primary)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((query) {
                  return ActionChip(
                    label: Text(query, style: AppTheme.label(size: 12)),
                    onPressed: () => onSelect(query),
                    backgroundColor: AppTheme.card,
                    side: const BorderSide(color: AppTheme.divider),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
