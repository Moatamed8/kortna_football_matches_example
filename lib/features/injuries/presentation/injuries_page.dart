import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/competition_chips.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";
import "package:soccer/features/injuries/presentation/injuries_cubit.dart";

class InjuriesPage extends StatelessWidget {
  const InjuriesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) =>
            InjuriesCubit(context.read<InjuryRepository>())..load(),
        child: const InjuriesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Injuries")),
      body: RefreshIndicator(
        onRefresh: () => context.read<InjuriesCubit>().load(force: true),
        child: BlocBuilder<InjuriesCubit, InjuriesState>(
          builder: (context, state) {
            final reports = state.reports;
            final groups = _groups(reports ?? const []);
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CompetitionChips(
                      selected: state.competition,
                      onSelected: (competition) =>
                          context.read<InjuriesCubit>().select(competition),
                    ),
                  ),
                ),
                if (state is InjuriesLoading && reports == null)
                  const SliverToBoxAdapter(child: MatchSkeleton())
                else if (state is InjuriesFailure && reports == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      message: state.failure.message,
                      onRetry: () => context.read<InjuriesCubit>().load(force: true),
                    ),
                  )
                else if (groups.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                      title: "No injury reports",
                      message:
                          "Nothing is published for ${state.competition.name} right now.",
                      icon: Icons.healing_outlined,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildListDelegate([
                      for (final group in groups) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            group.$1.isEmpty ? "Unlisted club" : group.$1,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        for (final report in group.$2) _InjuryTile(report: report),
                      ],
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InjuryTile extends StatelessWidget {
  const _InjuryTile({required this.report});

  final InjuryReport report;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = [
      if (report.position != null) report.position,
      if (report.reason != null) report.reason,
      if (report.expectedReturn != null)
        "Return ${formatReturnDate(report.expectedReturn!)}",
    ].whereType<String>().join("  ·  ");
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Crest(name: report.playerName, url: report.photoUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.playerName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (meta.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(meta, style: TextStyle(color: palette.muted)),
                  ),
                if (report.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(report.note!, style: const TextStyle(height: 1.35)),
                  ),
              ],
            ),
          ),
          if (report.status.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: palette.surfaceHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                report.status,
                style: TextStyle(
                  color: palette.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<(String, List<InjuryReport>)> _groups(List<InjuryReport> reports) {
  final buckets = <String, List<InjuryReport>>{};
  for (final report in reports) {
    buckets.putIfAbsent(report.teamName, () => []).add(report);
  }
  final names = buckets.keys.toList()..sort();
  for (final name in names) {
    buckets[name]!.sort((a, b) => a.playerName.compareTo(b.playerName));
  }
  return [for (final name in names) (name, buckets[name]!)];
}
