import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/features/injuries/presentation/injuries_page.dart";
import "package:soccer/features/more/about_page.dart";
import "package:soccer/features/news/presentation/news_page.dart";
import "package:soccer/features/settings/settings_cubit.dart";

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 16, 16, 24),
      children: [
        const Text(
          "More",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Text("APPEARANCE", style: TextStyle(color: palette.muted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        const SizedBox(height: 10),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text("System")),
                ButtonSegment(value: ThemeMode.light, label: Text("Light")),
                ButtonSegment(value: ThemeMode.dark, label: Text("Dark")),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (modes) {
                context.read<SettingsCubit>().setTheme(modes.first);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        _Link(
          title: "Stories",
          subtitle: "Latest football stories",
          onTap: () => Navigator.of(context).push(NewsPage.route()),
        ),
        _Link(
          title: "Injuries",
          subtitle: "Published availability reports",
          onTap: () => Navigator.of(context).push(InjuriesPage.route()),
        ),
        _Link(
          title: "Developer",
          subtitle: "Moatamed Wageh Nashat",
          onTap: () => Navigator.of(context).push(AboutPage.route()),
        ),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: palette.muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: palette.muted),
          ],
        ),
      ),
    );
  }
}
