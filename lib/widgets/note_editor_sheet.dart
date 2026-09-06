import 'package:flutter/material.dart';

import '../services/notes_service.dart';
import '../theme/app_theme.dart';

Future<void> showNoteEditorSheet({
  required BuildContext context,
  required String storageKey,
  required String title,
  required String subtitle,
}) async {
  final notes = NotesService.instance;
  final controller = TextEditingController(text: notes.getNote(storageKey) ?? '');

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('我的笔记', style: AppTheme.title(size: 18)),
            const SizedBox(height: 4),
            Text('$title · $subtitle',
                style: AppTheme.body(size: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              style: AppTheme.body(size: 14),
              decoration: InputDecoration(
                hintText: '记录你的读史心得…',
                hintStyle: AppTheme.body(size: 14, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (notes.hasNote(storageKey))
                  TextButton(
                    onPressed: () async {
                      await notes.deleteNote(storageKey);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text('删除', style: AppTheme.label(size: 13, color: Colors.red)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await notes.saveNote(storageKey, controller.text);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  controller.dispose();
}

class NoteIconButton extends StatelessWidget {
  final String storageKey;
  final String title;
  final String subtitle;
  final Color? color;

  const NoteIconButton({
    super.key,
    required this.storageKey,
    required this.title,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final notes = NotesService.instance;
    return ListenableBuilder(
      listenable: notes,
      builder: (context, _) {
        final hasNote = notes.hasNote(storageKey);
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            hasNote ? Icons.sticky_note_2_rounded : Icons.sticky_note_2_outlined,
            size: 20,
            color: hasNote ? (color ?? AppTheme.primary) : AppTheme.textSecondary,
          ),
          onPressed: () => showNoteEditorSheet(
            context: context,
            storageKey: storageKey,
            title: title,
            subtitle: subtitle,
          ),
        );
      },
    );
  }
}
