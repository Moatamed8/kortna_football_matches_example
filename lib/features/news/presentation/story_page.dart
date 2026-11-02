import "package:flutter/material.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:url_launcher/url_launcher.dart";

class StoryPage extends StatelessWidget {
  const StoryPage({required this.story, super.key});

  final Story story;

  static Route<void> route(Story story) {
    return MaterialPageRoute<void>(builder: (_) => StoryPage(story: story));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final published = story.publishedAt;
    return Scaffold(
      appBar: AppBar(title: const Text("Story")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (story.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                story.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              story.headline,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              [
                story.source,
                story.competitionName,
                if (published != null) shortDate(published),
                if (published != null) kickoffTime(published),
              ].join("  ·  "),
              style: TextStyle(color: palette.muted),
            ),
          ),
          if (story.summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Text(
                story.summary!,
                style: const TextStyle(fontSize: 16, height: 1.45),
              ),
            ),
          if (story.url != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: FilledButton(
                onPressed: () => _open(context, story.url!),
                child: const Text("Continue on ESPN"),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _failed(context);
      }
    } catch (_) {
      if (context.mounted) _failed(context);
    }
  }

  void _failed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Unable to open this story.")),
    );
  }
}
