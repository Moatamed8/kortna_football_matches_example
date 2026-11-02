import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/competition_chips.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/matches/presentation/board/competition_day_cubit.dart";
import "package:soccer/features/matches/presentation/pages/match_detail_page.dart";
import "package:soccer/features/matches/presentation/widgets/match_list.dart";

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompetitionDayCubit(context.read<MatchRepository>())..open(),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatefulWidget {
  const _MatchesView();

  @override
  State<_MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<_MatchesView> {
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
      onRefresh: () => context.read<CompetitionDayCubit>().open(force: true),
      child: BlocBuilder<CompetitionDayCubit, DayState>(
        builder: (context, state) {
          final board = state.board;
          final query = _search.text.trim().toLowerCase();
          final matches = (board?.matches ?? const <Match>[]).where((match) {
            if (query.isEmpty) return true;
            return match.home.name.toLowerCase().contains(query) ||
                match.away.name.toLowerCase().contains(query);
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
                    "Matches",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CompetitionChips(
                  selected: state.board?.competition ??
                      context.read<CompetitionDayCubit>().competition,
                  onSelected: (competition) =>
                      context.read<CompetitionDayCubit>().selectCompetition(competition),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.read<CompetitionDayCubit>().shiftDay(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          board == null ? "" : shortDate(board.day),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.read<CompetitionDayCubit>().shiftDay(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search teams",
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
              if (state is DayLoading && board == null)
                const SliverToBoxAdapter(child: MatchSkeleton())
              else if (state is DayFailure && board == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: state.failure.message,
                    onRetry: () => context.read<CompetitionDayCubit>().open(force: true),
                  ),
                )
              else if (matches.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    title: query.isEmpty ? "No fixtures" : "No matching teams",
                    message: query.isEmpty
                        ? "Nothing is scheduled for this competition on this day."
                        : "Try another club name.",
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: MatchDayList(
                    matches: matches,
                    onTap: (match) =>
                        Navigator.of(context).push(MatchDetailPage.route(match)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
