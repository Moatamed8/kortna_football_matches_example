import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";

class Crest extends StatelessWidget {
  const Crest({
    required this.name,
    this.url,
    this.size = 28,
    super.key,
  });

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Mark(name: name, size: size);
    if (url == null || url!.isEmpty) return placeholder;
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.contain,
        memCacheWidth: (size * 3).round(),
        fadeInDuration: const Duration(milliseconds: 120),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: palette.ink,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
