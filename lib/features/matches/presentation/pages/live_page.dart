import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/widgets/section_header.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/presentation/live/live_matches_bloc.dart";
import "package:soccer/features/matches/presentation/pages/match_detail_page.dart";
import "package:soccer/features/matches/presentation/widgets/match_list.dart";

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<LiveMatchesBloc>().refresh(),
      child: BlocBuilder<LiveMatchesBloc, LiveMatchesState>(
        builder: (context, state) {
          final matches = switch (state) {
            LiveReady(:final matches) => matches,
            LiveFailure(:final matches) => matches,
            _ => null,
          };
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.paddingOf(context).top + 16,
                    16,
                    0,
                  ),
                  child: const Text(
                    "Live",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (state is LiveReady)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: "${matches!.length} IN PLAY",
                    live: matches.isNotEmpty,
                    trailing: "Updated ${clockTime(state.updatedAt)}",
                  ),
                ),
              if (state is LiveFailure && matches != null)
                SliverToBoxAdapter(
                  child: InlineNotice(
                    message: state.failure.message,
                    onRetry: () => context.read<LiveMatchesBloc>().refresh(),
                  ),
                ),
              if (state is LiveLoading || state is LiveInitial)
                const SliverToBoxAdapter(child: MatchSkeleton())
              else if (state is LiveFailure && matches == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: state.failure.message,
                    onRetry: () => context.read<LiveMatchesBloc>().refresh(),
                  ),
                )
              else if (matches == null || matches.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    title: "No matches are live",
                    message:
                        "Premier League, Champions League, La Liga, Serie A and the Bundesliga are being watched.",
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: GroupedMatchList(
                    matches: matches,
                    onTap: (match) => _open(context, match),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Match match) {
    Navigator.of(context).push(MatchDetailPage.route(match));
  }
}
