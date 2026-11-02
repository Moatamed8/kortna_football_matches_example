import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/competition_chips.dart";
import "package:soccer/core/widgets/crest.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";
import "package:soccer/features/teams/presentation/team_page.dart";
import "package:soccer/features/teams/presentation/teams_cubit.dart";

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeamsCubit(context.read<TeamRepository>())..load(),
      child: const _TeamsView(),
    );
  }
}

class _TeamsView extends StatefulWidget {
  const _TeamsView();

  @override
  State<_TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<_TeamsView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return RefreshIndicator(
      onRefresh: () => context.read<TeamsCubit>().load(force: true),
      child: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, state) {
          final query = _search.text.trim().toLowerCase();
          final teams = (state.teams ?? const <TeamSummary>[]).where((team) {
            if (query.isEmpty) return true;
            return team.name.toLowerCase().contains(query) ||
                (team.abbreviation?.toLowerCase().contains(query) ?? false);
          }).toList();
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.paddingOf(context).top + 16,
                    16,
                    12,
                  ),
                  child: const Text(
                    "Teams",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CompetitionChips(
                  selected: state.competition,
                  onSelected: (competition) =>
                      context.read<TeamsCubit>().select(competition),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search clubs",
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: palette.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: palette.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: palette.line),
                      ),
                    ),
                  ),
                ),
              ),
              if (state is TeamsLoading && state.teams == null)
                const SliverToBoxAdapter(child: MatchSkeleton())
              else if (state is TeamsFailure && state.teams == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: state.failure.message,
                    onRetry: () => context.read<TeamsCubit>().load(force: true),
                  ),
                )
              else if (teams.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    title: "No clubs found",
                    message: "Try another name or competition.",
                    icon: Icons.shield_outlined,
                  ),
                )
              else
                SliverList.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: Crest(name: team.shortName, url: team.logoUrl, size: 32),
                          title: Text(
                            team.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            team.abbreviation == null
                                ? team.country
                                : "${team.abbreviation}  ·  ${team.country}",
                          ),
                          onTap: () => Navigator.of(context).push(TeamPage.route(team)),
                        ),
                        Divider(height: 1, indent: 72, color: palette.line),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
