import "package:flutter/material.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/section_header.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/presentation/widgets/match_tile.dart";

class MatchDayList extends StatelessWidget {
  const MatchDayList({
    required this.matches,
    required this.onTap,
    this.includeLive = true,
    super.key,
  });

  final List<Match> matches;
  final ValueChanged<Match> onTap;
  final bool includeLive;

  @override
  Widget build(BuildContext context) {
    final live = matches.where((match) => match.state == MatchState.live).toList();
    final upcoming = matches.where((match) => match.state == MatchState.upcoming).toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    final finished = matches.where((match) => match.state == MatchState.finished).toList()
      ..sort((a, b) => b.kickoff.compareTo(a.kickoff));
    final other = matches.where((match) => match.state == MatchState.other).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeLive && live.isNotEmpty) ...[
          SectionHeader(title: "LIVE", live: true, trailing: "${live.length}"),
          for (final match in live) _entry(context, match),
        ],
        if (upcoming.isNotEmpty) ...[
          const SectionHeader(title: "UPCOMING"),
          for (final match in upcoming) _entry(context, match),
        ],
        if (finished.isNotEmpty) ...[
          const SectionHeader(title: "RESULTS"),
          for (final match in finished) _entry(context, match),
        ],
        if (other.isNotEmpty) ...[
          const SectionHeader(title: "OTHER"),
          for (final match in other) _entry(context, match),
        ],
      ],
    );
  }

  Widget _entry(BuildContext context, Match match) {
    return Column(
      children: [
        MatchTile(
          key: ValueKey("match-${match.id}"),
          match: match,
          onTap: () => onTap(match),
        ),
        Divider(height: 1, indent: 68, color: context.palette.line),
      ],
    );
  }
}

class GroupedMatchList extends StatelessWidget {
  const GroupedMatchList({
    required this.matches,
    required this.onTap,
    super.key,
  });

  final List<Match> matches;
  final ValueChanged<Match> onTap;

  @override
  Widget build(BuildContext context) {
    final order = <String>[];
    final groups = <String, List<Match>>{};
    for (final match in matches) {
      groups.putIfAbsent(match.competitionName, () {
        order.add(match.competitionName);
        return [];
      }).add(match);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final name in order) ...[
          SectionHeader(title: name.toUpperCase()),
          for (final match in groups[name]!)
            Column(
              children: [
                MatchTile(
                  key: ValueKey("match-${match.id}"),
                  match: match,
                  onTap: () => onTap(match),
                ),
                Divider(height: 1, indent: 68, color: context.palette.line),
              ],
            ),
        ],
      ],
    );
  }
}
