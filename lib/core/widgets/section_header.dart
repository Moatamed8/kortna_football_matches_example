import "package:flutter/material.dart";
import "package:soccer/core/theme/app_palette.dart";

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.trailing,
    this.live = false,
    super.key,
  });

  final String title;
  final String? trailing;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          if (live) ...[
            const LiveDot(),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: live ? palette.live : palette.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class LiveDot extends StatelessWidget {
  const LiveDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: context.palette.live,
        shape: BoxShape.circle,
      ),
    );
  }
}
