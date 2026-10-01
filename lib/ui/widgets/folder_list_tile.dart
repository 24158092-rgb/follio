import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/folder_model.dart';
import '../../core/folio_theme.dart';
import '../widgets/neu_widgets.dart';

class FolderListTile extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FolderListTile({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    // Guard default folder from deletion
    final canDelete = folder.id != 1;

    return GestureDetector(
      onTap: onTap,
      onLongPress: canDelete ? () => _confirmDelete(context, theme) : null,
      child: Container(
        width: 136,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: folioGlassDecoration(theme, radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FolioBadge(Icons.folder_rounded, size: 36),
                const Spacer(),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.border),
                  ),
                  child: Icon(Icons.north_east_rounded,
                      size: 13, color: theme.textSub),
                ),
              ],
            ),
            const Spacer(),
            Text(
              folder.name,
              style: GoogleFonts.plusJakartaSans(
                color: theme.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.MMMd().format(folder.createdAt),
              style: GoogleFonts.plusJakartaSans(
                color: theme.textSub,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FolioThemeNotifier theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.border),
        ),
        title: Text('Delete Folder?',
            style: TextStyle(color: theme.text, fontWeight: FontWeight.w800)),
        content: Text(
          'This will delete "${folder.name}" and all its contents.',
          style: TextStyle(color: theme.textSub, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: theme.textSub, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
