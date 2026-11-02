import "package:flutter/material.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/features/matches/domain/entities/match.dart";

class MatchTile extends StatelessWidget {
  const MatchTile({required this.match, required this.onTap, super.key});

  final Match match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final live = match.state == MatchState.live;
    final chips = [
      for (final event in match.events) goalChip(event),
    ].where((chip) => chip.isNotEmpty).take(4).toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    matchLeading(match),
                    style: TextStyle(
                      color: live ? palette.live : palette.muted,
                      fontWeight: live ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _Side(team: match.home, score: match.home.score, showScore: match.hasScore),
                      const SizedBox(height: 6),
                      _Side(team: match.away, score: match.away.score, showScore: match.hasScore),
                    ],
                  ),
                ),
              ],
            ),
            if (chips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    chips.join("   "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.team,
    required this.score,
    required this.showScore,
  });

  final TeamSide team;
  final int? score;
  final bool showScore;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Crest(name: team.shortName, url: team.logoUrl, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        if (showScore)
          SizedBox(
            width: 28,
            child: Text(
              "$score",
              textAlign: TextAlign.end,
              style: TextStyle(
                color: palette.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class LiveHero extends StatelessWidget {
  const LiveHero({required this.match, required this.onTap, super.key});

  final Match match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chips = [
      for (final event in match.events) goalChip(event),
    ].where((chip) => chip.isNotEmpty).take(4);
    return Padding(
      key: ValueKey("match-${match.id}"),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: palette.live,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        color: palette.live,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.competitionName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.muted, fontSize: 12),
                      ),
                    ),
                    Text(
                      matchLeading(match),
                      style: TextStyle(
                        color: palette.live,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _HeroTeam(team: match.home)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        match.hasScore ? match.scoreLabel : "–",
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Expanded(child: _HeroTeam(team: match.away)),
                  ],
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    chips.join("   "),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTeam extends StatelessWidget {
  const _HeroTeam({required this.team});

  final TeamSide team;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Crest(name: team.shortName, url: team.logoUrl, size: 48),
        const SizedBox(height: 8),
        Text(
          team.shortName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
