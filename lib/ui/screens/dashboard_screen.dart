import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../repositories/document_repository.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/folder_list_tile.dart';
import '../widgets/neu_widgets.dart';
import '../../core/folio_theme.dart';
import 'scanner_screen.dart';
import 'document_detail_screen.dart';
import 'documents_by_folder_screen.dart';

TextStyle _jakarta(
  Color color,
  double size,
  FontWeight weight, {
  double spacing = 0,
  double? height,
}) =>
    GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      height: height,
    );

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤';
    if (h < 21) return 'Good Evening 🌙';
    return 'Good Night 🌟';
  }

  // ─── Actions ──────────────────────────────────────────────────────────────
  void _openScanner(BuildContext context) {
    context.read<ScannerBloc>().add(ResetScanner());
    Navigator.push(context, _neuRoute(const ScannerScreen()));
  }

  void _toggleTheme(FolioThemeNotifier t) => t.setDark(!t.isDark);

  void _scrollToTop() => _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final t = context.watch<FolioThemeNotifier>();

    return Scaffold(
      backgroundColor: t.bg,
      extendBody: true,
      body: FolioBackdrop(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: _buildHeader(context, t),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 22)),

                // ─── Body ───────────────────────────────────────────────
                if (state is DashboardInitial || state is DashboardLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: t.accent),
                    ),
                  )
                else if (state is DashboardError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildError(context, state, t),
                  )
                else if (state is DashboardLoaded) ...[
                  SliverToBoxAdapter(child: _buildStats(state)),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildQuickActions(context, t)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  _buildSectionHeader(
                    t,
                    'Folders',
                    subtitle: 'Your collections',
                    count: state.folders.length,
                    onAdd: () => _showAddFolderDialog(context),
                  ),
                  _buildFolderList(context, state, t),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  _buildSectionHeader(
                    t,
                    'Recent Scans',
                    subtitle: 'Latest documents',
                    count: state.recentDocuments.length,
                  ),
                  _buildRecentList(context, state, t),
                ],

                // Space so the floating dock never covers content
                const SliverToBoxAdapter(child: SizedBox(height: 130)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _FloatingDock(
        onHome: _scrollToTop,
        onScan: () => _openScanner(context),
        onAddFolder: () => _showAddFolderDialog(context),
        onToggleTheme: () => _toggleTheme(t),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, FolioThemeNotifier t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: t.accentGradient,
                  boxShadow: [BoxShadow(color: t.glow, blurRadius: 18)],
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Folio', style: _jakarta(t.text, 17, FontWeight.w800)),
                    const SizedBox(height: 1),
                    Text(_greeting(),
                        style: _jakarta(t.textSub, 12.5, FontWeight.w500)),
                  ],
                ),
              ),
              const _ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Your Documents\nOverview',
                  style: _jakarta(t.text, 28, FontWeight.w700,
                      spacing: -0.8, height: 1.15),
                ),
              ),
              NeuButton(
                filled: true,
                borderRadius: 999,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                onTap: () => _openScanner(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text('Scan',
                        style: _jakarta(Colors.white, 14, FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats row ────────────────────────────────────────────────────────────
  Widget _buildStats(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.folder_rounded,
              label: 'Folders',
              value: '${state.folders.length}',
              tag: 'Collections',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.description_rounded,
              label: 'Recent scans',
              value: '${state.recentDocuments.length}',
              tag: 'Documents',
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }

  // ─── "Hi there" quick-actions card ────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, FolioThemeNotifier t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: NeuBox(
        borderRadius: 24,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi there 👋', style: _jakarta(t.textSub, 13, FontWeight.w500)),
            const SizedBox(height: 2),
            Text('What would you like to do?',
                style: _jakarta(t.text, 19, FontWeight.w700, spacing: -0.4)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                  icon: Icons.document_scanner_rounded,
                  label: 'Scan document',
                  primary: true,
                  onTap: () => _openScanner(context),
                ),
                _ActionChip(
                  icon: Icons.create_new_folder_rounded,
                  label: 'New folder',
                  onTap: () => _showAddFolderDialog(context),
                ),
                _ActionChip(
                  icon: t.isDark
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  label: t.isDark ? 'Light mode' : 'Dark mode',
                  onTap: () => _toggleTheme(t),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────
  Widget _buildError(
      BuildContext context, DashboardError state, FolioThemeNotifier t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.accentSoft,
              boxShadow: [BoxShadow(color: t.glow, blurRadius: 30)],
            ),
            child: Icon(Icons.error_outline_rounded, size: 34, color: t.accent),
          ),
          const SizedBox(height: 18),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: _jakarta(t.text, 14, FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 18),
          NeuButton(
            filled: true,
            borderRadius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            onTap: () => context.read<DashboardBloc>().add(LoadDashboard()),
            child: Text('Retry',
                style: _jakarta(Colors.white, 14, FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  SliverToBoxAdapter _buildSectionHeader(
    FolioThemeNotifier t,
    String title, {
    String? subtitle,
    int? count,
    VoidCallback? onAdd,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(subtitle,
                      style: _jakarta(t.textSub, 12, FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(title,
                        style: _jakarta(t.text, 19, FontWeight.w700,
                            spacing: -0.4)),
                    if (count != null) ...[
                      const SizedBox(width: 8),
                      FolioTag('$count'),
                    ],
                  ],
                ),
              ],
            ),
            const Spacer(),
            if (onAdd != null)
              NeuIconButton(
                icon: Icons.create_new_folder_outlined,
                onTap: onAdd,
                size: 40,
                tooltip: 'New Folder',
              ),
          ],
        ),
      ),
    );
  }

  // ─── Folders ──────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildFolderList(
      BuildContext context, DashboardLoaded state, FolioThemeNotifier t) {
    if (state.folders.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: NeuBox(
            borderRadius: 22,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const FolioBadge(Icons.folder_open_rounded, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No folders yet. Tap + to create one.',
                    style: _jakarta(t.textSub, 13.5, FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 136,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          itemCount: state.folders.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final folder = state.folders[index];
            return FolderListTile(
              folder: folder,
              onTap: () => Navigator.push(
                  context, _neuRoute(DocumentsByFolderScreen(folder: folder))),
              onDelete: () =>
                  context.read<DashboardBloc>().add(DeleteFolder(folder.id!)),
            );
          },
        ),
      ),
    );
  }

  // ─── Recent scans ─────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildRecentList(
      BuildContext context, DashboardLoaded state, FolioThemeNotifier t) {
    if (state.recentDocuments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: NeuBox(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accentSoft,
                    boxShadow: [BoxShadow(color: t.glow, blurRadius: 30)],
                  ),
                  child: Icon(Icons.document_scanner_rounded,
                      size: 30, color: t.accent),
                ),
                const SizedBox(height: 16),
                Text('No scans yet',
                    style: _jakarta(t.text, 16, FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Tap Scan to get started',
                    style: _jakarta(t.textSub, 13, FontWeight.w500)),
                const SizedBox(height: 18),
                NeuButton(
                  filled: true,
                  borderRadius: 999,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  onTap: () => _openScanner(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.document_scanner_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('Scan now',
                          style: _jakarta(Colors.white, 14, FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: state.recentDocuments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = state.recentDocuments[index];
          return Hero(
            tag: 'doc_${doc.id}',
            child: DocumentListTile(
              doc: doc,
              onTap: () => Navigator.push(
                context,
                _neuRoute(DocumentDetailScreen(
                  document: doc,
                  repository: context.read<DocumentRepository>(),
                )),
              ),
              onDelete: () =>
                  context.read<DashboardBloc>().add(DeleteDocument(doc.id!)),
            ),
          );
        },
      ),
    );
  }

  // ─── New folder dialog ────────────────────────────────────────────────────
  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final t = context.read<FolioThemeNotifier>();

    void create(BuildContext ctx) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        context.read<DashboardBloc>().add(AddFolder(name));
        Navigator.pop(ctx);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: t.border),
        ),
        title: Row(
          children: [
            const FolioBadge(Icons.create_new_folder_rounded, size: 38),
            const SizedBox(width: 12),
            Text('New Folder', style: _jakarta(t.text, 18, FontWeight.w700)),
          ],
        ),
        content: NeuTextField(
          controller: controller,
          label: 'Folder Name',
          prefixIcon: Icons.folder_outlined,
          autofocus: true,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: _jakarta(t.textSub, 14, FontWeight.w600)),
          ),
          NeuButton(
            filled: true,
            borderRadius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            onTap: () => create(ctx),
            child:
                Text('Create', style: _jakarta(Colors.white, 14, FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Dashboard-only building blocks
// ═════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tag,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String tag;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<FolioThemeNotifier>();
    return NeuBox(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FolioBadge(icon, filled: highlight, size: 38),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.border),
                ),
                child:
                    Icon(Icons.north_east_rounded, size: 15, color: t.textSub),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(label, style: _jakarta(t.textSub, 12.5, FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: _jakarta(t.text, 30, FontWeight.w700, spacing: -1)),
          const SizedBox(height: 8),
          FolioTag(tag),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<FolioThemeNotifier>();
    return NeuButton(
      filled: primary,
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary ? Colors.white : t.textSub),
          const SizedBox(width: 6),
          Text(
            label,
            style: _jakarta(
                primary ? Colors.white : t.text, 13, FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Toggle (tap = switch, long-press = back to auto) ──────────────────
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    return GestureDetector(
      onLongPress: () {
        theme.setAuto();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme set to Auto (time-based)')),
        );
      },
      child: NeuIconButton(
        icon: theme.isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
        active: !theme.isAuto,
        tooltip: theme.isAuto ? 'Auto (long-press to reset)' : 'Manual override',
        onTap: () => theme.setDark(!theme.isDark),
        size: 44,
      ),
    );
  }
}

// ─── Floating bottom dock ─────────────────────────────────────────────────────
class _FloatingDock extends StatelessWidget {
  const _FloatingDock({
    required this.onHome,
    required this.onScan,
    required this.onAddFolder,
    required this.onToggleTheme,
  });

  final VoidCallback onHome;
  final VoidCallback onScan;
  final VoidCallback onAddFolder;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<FolioThemeNotifier>();
    final r = BorderRadius.circular(999);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                boxShadow: t.raisedShadow,
              ),
              child: ClipRRect(
                borderRadius: r,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: r,
                      color: t.isDark
                          ? const Color(0xB31A1210)
                          : const Color(0xD9FFFFFF),
                      border: Border.all(color: t.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DockButton(
                          icon: Icons.home_rounded,
                          tooltip: 'Home',
                          active: true,
                          onTap: onHome,
                        ),
                        _DockButton(
                          icon: Icons.document_scanner_rounded,
                          tooltip: 'Scan',
                          onTap: onScan,
                        ),
                        _DockButton(
                          icon: Icons.create_new_folder_rounded,
                          tooltip: 'New folder',
                          onTap: onAddFolder,
                        ),
                        _DockButton(
                          icon: t.isDark
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          tooltip: 'Theme',
                          onTap: onToggleTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<FolioThemeNotifier>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active ? t.accentGradient : null,
                boxShadow:
                    active ? [BoxShadow(color: t.glow, blurRadius: 18)] : null,
              ),
              child: Icon(icon,
                  size: 22, color: active ? Colors.white : t.textSub),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Page Route Helper ────────────────────────────────────────────────────────
PageRoute _neuRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}
