import "package:flutter/material.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:url_launcher/url_launcher.dart";

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const AboutPage());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text("Developer")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(
                      "assets/icons/developer.JPG",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Text(
              "Moatamed Wageh Nashat",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              "Flutter and native Android",
              style: TextStyle(
                color: palette.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              "I build mobile apps in Flutter and native Android. Kortna is the live football client in this portfolio: public scores, fixtures, squads, and stories, mapped in a data layer and shown with BLoC.",
              style: TextStyle(color: palette.ink, fontSize: 16, height: 1.45),
            ),
          ),
          const _SectionLabel("Contact"),
          const _ContactCard(
            rows: [
              _Contact(
                icon: Icons.mail_outline,
                label: "Email",
                value: "metmedelbana@gmail.com",
                uri: "mailto:metmedelbana@gmail.com",
              ),
              _Contact(
                icon: Icons.phone_outlined,
                label: "Phone",
                value: "+20 128 858 4664",
                uri: "tel:+201288584664",
              ),
              _Contact(
                icon: Icons.code,
                label: "GitHub",
                value: "github.com/moatamed8",
                uri: "https://github.com/moatamed8",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.palette.muted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Contact {
  const _Contact({
    required this.icon,
    required this.label,
    required this.value,
    required this.uri,
  });

  final IconData icon;
  final String label;
  final String value;
  final String uri;
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.rows});

  final List<_Contact> rows;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.line),
        ),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              if (index > 0) Divider(height: 1, color: palette.line),
              _ContactRow(contact: rows[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact});

  final _Contact contact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => _open(context, contact.uri),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(contact.icon, size: 20, color: palette.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.label,
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: palette.muted),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String uri) async {
    final parsed = Uri.tryParse(uri);
    if (parsed == null) return;
    try {
      final opened = await launchUrl(parsed, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) _failed(context);
    } catch (_) {
      if (context.mounted) _failed(context);
    }
  }

  void _failed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't open that link.")),
    );
  }
}
