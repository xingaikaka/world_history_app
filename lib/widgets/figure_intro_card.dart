import 'package:flutter/material.dart';
import '../models/country.dart';
import '../theme/app_theme.dart';

class FigureIntroCard extends StatelessWidget {
  final KeyFigure figure;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  const FigureIntroCard({
    super.key,
    required this.figure,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 10),
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: compact ? 16 : 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  figure.name.characters.first,
                  style: AppTheme.title(size: compact ? 12 : 14, color: color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(figure.name, style: AppTheme.title(size: compact ? 14 : 15)),
                    Text(figure.role, style: AppTheme.label(size: 11, color: color)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, size: 18, color: color),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Text(figure.description, style: AppTheme.body(size: 13, height: 1.65)),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              figure.description,
              style: AppTheme.body(size: 12, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}
