import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/document_model.dart';
import '../../core/folio_theme.dart';
import '../widgets/neu_widgets.dart';

class DocumentListTile extends StatelessWidget {
  final Document doc;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DocumentListTile({
    super.key,
    required this.doc,
    required this.onTap,
    required this.onDelete,
  });

  /// "Just now", "5 min ago", "3 hours ago", "Yesterday", or a date.
  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat.yMMMd().format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    final isNew = DateTime.now().difference(doc.createdAt).inHours < 24;

    return Material(
      type: MaterialType.transparency, // needed inside Hero
      child: Dismissible(
        key: Key('doc_${doc.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.redAccent, size: 26),
        ),
        confirmDismiss: (_) => _confirmDelete(context, theme),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: folioGlassDecoration(theme, radius: 22),
            child: Row(
              children: [
                FolioBadge(Icons.description_rounded,
                    filled: isNew, size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _timeAgo(doc.createdAt),
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.textSub,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FolioTag(
                  isNew ? 'New' : 'Saved',
                  color: isNew ? theme.accent : const Color(0xFF34D399),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    color: theme.textSub, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
      BuildContext context, FolioThemeNotifier theme) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.border),
        ),
        title: Text('Delete Document?',
            style: TextStyle(color: theme.text, fontWeight: FontWeight.w800)),
        content: Text(
          'Delete "${doc.name}"? This cannot be undone.',
          style: TextStyle(color: theme.textSub, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: theme.textSub, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
