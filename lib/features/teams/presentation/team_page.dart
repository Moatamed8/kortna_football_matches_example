import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/core/widgets/section_header.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/matches/presentation/pages/match_detail_page.dart";
import "package:soccer/features/matches/presentation/widgets/match_tile.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/players/presentation/player_page.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";
import "package:soccer/features/teams/presentation/team_detail_cubit.dart";

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  static Route<void> route(TeamSummary team) {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) =>
            TeamDetailCubit(context.read<TeamRepository>(), team)..load(),
        child: const TeamPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamDetailCubit, TeamDetailState>(
      builder: (context, state) {
        final palette = context.palette;
        final record = state.facts?.record?.label;
        return Scaffold(
          appBar: AppBar(title: Text(state.team.shortName)),
          body: RefreshIndicator(
            onRefresh: () => context.read<TeamDetailCubit>().load(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (state.loading) const LinearProgressIndicator(minHeight: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Crest(name: state.team.shortName, url: state.team.logoUrl, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.team.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${state.team.competitionName}  ·  ${state.team.country}",
                              style: TextStyle(color: palette.muted),
                            ),
                            if (state.facts?.standing != null) ...[
                              const SizedBox(height: 4),
                              Text(state.facts!.standing!),
                            ],
                            if (record != null) ...[
                              const SizedBox(height: 2),
                              Text(record, style: TextStyle(color: palette.muted)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.failure != null && state.players.isEmpty && state.fixtures.isEmpty)
                  ErrorView(
                    message: state.failure!.message,
                    onRetry: () => context.read<TeamDetailCubit>().load(force: true),
                  ),
                if (state.upcoming.isNotEmpty) ...[
                  const SectionHeader(title: "UPCOMING"),
                  for (final match in state.upcoming)
                    MatchTile(
                      match: match,
                      onTap: () => Navigator.of(context).push(MatchDetailPage.route(match)),
                    ),
                ],
                if (state.recent.isNotEmpty) ...[
                  const SectionHeader(title: "RECENT"),
                  for (final match in state.recent)
                    MatchTile(
                      match: match,
                      onTap: () => Navigator.of(context).push(MatchDetailPage.route(match)),
                    ),
                ],
                if (state.players.isNotEmpty) ...[
                  const SectionHeader(title: "SQUAD"),
                  for (final group in _groups(state.players)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        group.$1,
                        style: TextStyle(
                          color: palette.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    for (final player in group.$2)
                      ListTile(
                        leading: Crest(name: player.name, url: player.photoUrl, size: 36),
                        title: Text(player.name),
                        subtitle: Text(
                          [
                            if (player.number != null) "#${player.number}",
                            if (player.nationality != null) player.nationality,
                          ].join("  ·  "),
                        ),
                        onTap: () => Navigator.of(context).push(PlayerPage.route(player)),
                      ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

List<(String, List<SquadPlayer>)> _groups(List<SquadPlayer> players) {
  const order = ["Goalkeeper", "Defender", "Midfielder", "Forward"];
  final buckets = <String, List<SquadPlayer>>{};
  for (final player in players) {
    final label = player.position ?? "Squad";
    buckets.putIfAbsent(label, () => []).add(player);
  }
  final names = buckets.keys.toList()
    ..sort((a, b) {
      final ai = order.indexOf(a);
      final bi = order.indexOf(b);
      if (ai == -1 && bi == -1) return a.compareTo(b);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
  return [for (final name in names) (name, buckets[name]!)];
}
