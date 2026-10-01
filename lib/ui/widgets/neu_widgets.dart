import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/folio_theme.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  Folio "warm glass" widgets
//
//  The class names and parameters are the same as the old neumorphic widgets,
//  so every screen that uses NeuBox / NeuButton / NeuIconButton / NeuTextField
//  / NeuChip picks up the new look automatically.
// ═════════════════════════════════════════════════════════════════════════════

/// Standard glass card decoration used across the app.
BoxDecoration folioGlassDecoration(
  FolioThemeNotifier theme, {
  double radius = 20,
  bool pressed = false,
  bool shadow = true,
  Color? color,
}) {
  final r = BorderRadius.circular(radius);
  if (pressed) {
    return BoxDecoration(
      color: color ?? theme.insetFill,
      borderRadius: r,
      border: Border.all(color: theme.border),
    );
  }
  return BoxDecoration(
    borderRadius: r,
    color: color,
    gradient: color == null
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.glassFill,
          )
        : null,
    border: Border.all(color: theme.border),
    boxShadow: shadow ? theme.raisedShadow : null,
  );
}

// ─── FolioBackdrop ───────────────────────────────────────────────────────────
/// Page background with soft orange glows. Put it behind a screen's content.
class FolioBackdrop extends StatelessWidget {
  final Widget child;
  const FolioBackdrop({super.key, required this.child});

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: theme.bg)),
        Positioned(
          top: -140,
          right: -120,
          child: IgnorePointer(
            child: _blob(
                400, theme.glow.withValues(alpha: theme.isDark ? 0.35 : 0.22)),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -150,
          child: IgnorePointer(
            child: _blob(
                380, theme.glow.withValues(alpha: theme.isDark ? 0.18 : 0.12)),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

// ─── FolioBadge ──────────────────────────────────────────────────────────────
/// Rounded-square icon badge (soft orange, or solid gradient when [filled]).
class FolioBadge extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final double size;

  const FolioBadge(this.icon, {super.key, this.filled = false, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        color: filled ? null : theme.accentSoft,
        gradient: filled ? theme.accentGradient : null,
        boxShadow: filled ? [BoxShadow(color: theme.glow, blurRadius: 16)] : null,
      ),
      child: Icon(icon,
          size: size * 0.5, color: filled ? Colors.white : theme.accent),
    );
  }
}

// ─── FolioTag ────────────────────────────────────────────────────────────────
/// Small rounded pill, e.g. counts and statuses.
class FolioTag extends StatelessWidget {
  final String text;
  final Color? color;

  const FolioTag(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    final c = color ?? theme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: theme.isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── NeuBox ───────────────────────────────────────────────────────────────────
/// A glass card that reads FolioThemeNotifier from context.
class NeuBox extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool pressed; // inset style (text areas, previews)
  final bool flat; // no shadow
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? overrideColor;

  const NeuBox({
    super.key,
    this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.pressed = false,
    this.flat = false,
    this.width,
    this.height,
    this.onTap,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();

    final box = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: folioGlassDecoration(
        theme,
        radius: borderRadius,
        pressed: pressed,
        shadow: !flat,
        color: overrideColor,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: box);
    }
    return box;
  }
}

// ─── NeuButton ────────────────────────────────────────────────────────────────
/// Button with a gentle press-down effect.
/// filled = glowing orange gradient; otherwise a glass button.
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool filled;

  const NeuButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.filled = false,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    final r = BorderRadius.circular(widget.borderRadius);

    final decoration = widget.filled
        ? BoxDecoration(
            borderRadius: r,
            gradient: theme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: theme.glow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : folioGlassDecoration(theme, radius: widget.borderRadius)
            .copyWith(boxShadow: theme.subtleShadow);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding,
          decoration: decoration,
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── NeuIconButton ────────────────────────────────────────────────────────────
/// Round glass icon button. active = highlighted in orange.
class NeuIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool active;
  final String? tooltip;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.active = false,
    this.tooltip,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();

    final btn = GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.active ? theme.accentSoft : null,
            gradient: widget.active
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.glassFill,
                  ),
            border: Border.all(
              color: widget.active
                  ? theme.accent.withValues(alpha: 0.55)
                  : theme.border,
            ),
            boxShadow: widget.active
                ? [BoxShadow(color: theme.glow.withValues(alpha: 0.35), blurRadius: 14)]
                : theme.subtleShadow,
          ),
          child: Icon(
            widget.icon,
            color: widget.active ? theme.accent : theme.text,
            size: widget.size * 0.44,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}

// ─── NeuTextField ─────────────────────────────────────────────────────────────
class NeuTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool autofocus;

  const NeuTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    final r = BorderRadius.circular(16);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      cursorColor: theme.accent,
      style: GoogleFonts.plusJakartaSans(
        color: theme.text,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: theme.textSub,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          color: theme.accent,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: theme.textSub) : null,
        filled: true,
        fillColor: theme.insetFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: r,
          borderSide: BorderSide(color: theme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: r,
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: r,
          borderSide: BorderSide(color: theme.accent, width: 1.4),
        ),
      ),
    );
  }
}

// ─── NeuChip ──────────────────────────────────────────────────────────────────
class NeuChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const NeuChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<FolioThemeNotifier>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: selected ? theme.accentGradient : null,
          color: selected ? null : theme.insetFill,
          border: selected ? null : Border.all(color: theme.border),
          boxShadow:
              selected ? [BoxShadow(color: theme.glow, blurRadius: 14)] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? Colors.white : theme.textSub,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
