import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/players/domain/player_repository.dart";
import "package:soccer/features/players/presentation/player_cubit.dart";

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  static Route<void> route(SquadPlayer player) {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) =>
            PlayerCubit(context.read<PlayerRepository>(), player)..load(),
        child: const PlayerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final palette = context.palette;
        final profile = state.profile;
        final name = profile?.name ?? state.player.name;
        final position = profile?.position ?? state.player.position;
        final number = profile?.number ?? state.player.number;
        final nationality = profile?.nationality ?? state.player.nationality;
        final flag = profile?.flagUrl ?? state.player.flagUrl;
        final age = profile?.age ?? state.player.age;
        final photo = profile?.photoUrl ?? state.player.photoUrl;
        final team = profile?.teamName ?? state.player.teamName;
        final facts = <(String, String)>[
          if (position != null) ("Position", position),
          if (number != null) ("Number", number),
          if (nationality != null) ("Nationality", nationality),
          ("Club", team),
          if (age != null) ("Age", "$age"),
          if (profile?.height != null) ("Height", profile!.height!),
          if (profile?.weight != null) ("Weight", profile!.weight!),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              if (state.loading) const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Crest(name: name, url: photo, size: 72),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(team, style: TextStyle(color: palette.muted)),
                          if (flag != null) ...[
                            const SizedBox(height: 8),
                            Crest(name: nationality ?? "", url: flag, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (profile != null && profile.hasInjury)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.line),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.injuryStatus?.isNotEmpty == true
                                ? profile.injuryStatus!
                                : "Injury",
                            style: TextStyle(
                              color: palette.warning,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (profile.injuryReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(profile.injuryReason!),
                            ),
                          if (profile.injuryNote != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                profile.injuryNote!,
                                style: TextStyle(color: palette.muted, height: 1.35),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final fact in facts)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(fact.$1, style: TextStyle(color: palette.muted)),
                      ),
                      Expanded(child: Text(fact.$2)),
                    ],
                  ),
                ),
              if (state.failure != null && profile == null)
                ErrorView(
                  message: state.failure!.message,
                  onRetry: () => context.read<PlayerCubit>().load(force: true),
                ),
              if (profile != null && profile.stats.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    profile.statsTitle ?? "Season statistics",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                for (final stat in profile.stats)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(stat.label)),
                        Text(
                          stat.value,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
