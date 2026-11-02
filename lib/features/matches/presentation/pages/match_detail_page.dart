import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/matches/presentation/detail/match_detail_cubit.dart";

class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({super.key});

  static Route<void> route(Match match) {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) =>
            MatchDetailCubit(context.read<MatchRepository>(), match)..load(),
        child: const MatchDetailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchDetailCubit, MatchDetailState>(
      builder: (context, state) {
        final match = state.scoreboard;
        final insight = state.insight;
        return Scaffold(
          appBar: AppBar(title: Text(match.competitionName)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _Scoreboard(match: match),
              if (state.loading) const LinearProgressIndicator(minHeight: 2),
              if (state.failure != null && insight == null)
                ErrorView(
                  message: state.failure!.message,
                  onRetry: () => context.read<MatchDetailCubit>().load(force: true),
                ),
              if (insight != null) ...[
                _Facts(match: match, insight: insight),
                if (insight.events.isNotEmpty) _Events(events: insight.events),
                if (insight.stats.isNotEmpty) _Stats(stats: insight.stats),
                for (final lineup in insight.lineups) _LineupBlock(lineup: lineup),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final live = match.state == MatchState.live;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.line),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            children: [
              Text(
                live ? "LIVE  ${matchLeading(match)}" : matchLeading(match),
                style: TextStyle(
                  color: live ? palette.live : palette.muted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Team(team: match.home)),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      match.hasScore ? match.scoreLabel : kickoffTime(match.kickoff),
                      style: TextStyle(
                        fontSize: match.hasScore ? 34 : 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Expanded(child: _Team(team: match.away)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.team});

  final TeamSide team;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Crest(name: team.shortName, url: team.logoUrl, size: 52),
        const SizedBox(height: 8),
        Text(
          team.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (team.form != null && team.form!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              team.form!,
              style: TextStyle(
                color: palette.muted,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.match, required this.insight});

  final Match match;
  final MatchInsight insight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rows = <(String, String)>[
      ("Kickoff", "${shortDate(match.kickoff)}  ${kickoffTime(match.kickoff)}"),
      if (insight.venue != null)
        (
          "Venue",
          [
            insight.venue,
            if (insight.venueCity != null) insight.venueCity,
          ].join(", "),
        ),
      if (insight.referee != null) ("Referee", insight.referee!),
      if (insight.attendance != null) ("Attendance", "${insight.attendance}"),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(row.$1, style: TextStyle(color: palette.muted)),
                  ),
                  Expanded(child: Text(row.$2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Events extends StatelessWidget {
  const _Events({required this.events});

  final List<MatchEvent> events;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BlockTitle("Match events"),
        for (final event in events)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    event.clock == null || event.clock!.isEmpty ? "–" : event.clock!,
                    style: TextStyle(
                      color: palette.muted,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.type.isNotEmpty &&
                          !event.text.toLowerCase().startsWith(event.type.toLowerCase()))
                        Text(
                          event.type,
                          style: TextStyle(
                            color: palette.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(event.text, style: const TextStyle(height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});

  final List<StatLine> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BlockTitle("Team statistics"),
        for (final stat in stats) _StatRow(stat: stat),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final StatLine stat;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final home = _number(stat.home);
    final away = _number(stat.away);
    final total = (home ?? 0) + (away ?? 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  stat.home ?? "–",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  stat.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  stat.away ?? "–",
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (home != null && away != null && total > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: (home / total * 1000).round().clamp(1, 999),
                      child: ColoredBox(color: palette.ink),
                    ),
                    Expanded(
                      flex: (away / total * 1000).round().clamp(1, 999),
                      child: ColoredBox(color: palette.line),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double? _number(String? value) {
    if (value == null) return null;
    return double.tryParse(value.replaceAll("%", "").trim());
  }
}

class _LineupBlock extends StatelessWidget {
  const _LineupBlock({required this.lineup});

  final Lineup lineup;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final title = lineup.formation == null
        ? lineup.teamName
        : "${lineup.teamName}  ${lineup.formation}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(title),
        for (final player in lineup.starters) _PlayerRow(player: player),
        if (lineup.bench.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              "Bench",
              style: TextStyle(
                color: palette.muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ),
          for (final player in lineup.bench) _PlayerRow(player: player),
        ],
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final LineupPlayer player;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              player.number ?? "",
              style: TextStyle(
                color: palette.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(child: Text(player.name)),
          if (player.position != null)
            Text(player.position!, style: TextStyle(color: palette.muted)),
        ],
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  const _BlockTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
