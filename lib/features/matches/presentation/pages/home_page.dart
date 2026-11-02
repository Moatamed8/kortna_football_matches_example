import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/core/widgets/section_header.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/matches/presentation/board/competition_day_cubit.dart";
import "package:soccer/features/matches/presentation/live/live_matches_bloc.dart";
import "package:soccer/features/matches/presentation/pages/match_detail_page.dart";
import "package:soccer/features/matches/presentation/widgets/match_list.dart";
import "package:soccer/features/matches/presentation/widgets/match_tile.dart";
import "package:soccer/features/news/domain/story_repository.dart";
import "package:soccer/features/news/presentation/news_cubit.dart";
import "package:soccer/features/news/presentation/story_page.dart";
import "package:soccer/features/news/presentation/widgets/story_views.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CompetitionDayCubit(
            context.read<MatchRepository>(),
            lookAhead: true,
          )..open(),
        ),
        BlocProvider(
          create: (context) =>
              NewsCubit(context.read<StoryRepository>())..load(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return RefreshIndicator(
      onRefresh: () => _reload(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 16,
                16,
                4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "KORTNA",
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullDate(DateTime.now()),
                    style: TextStyle(color: palette.muted),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _LiveBlock()),
          const SliverToBoxAdapter(child: _DayBlock()),
          const SliverToBoxAdapter(child: _StoriesBlock()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Future<void> _reload(BuildContext context) {
    return Future.wait([
      context.read<LiveMatchesBloc>().refresh(),
      context.read<CompetitionDayCubit>().open(force: true),
      context.read<NewsCubit>().load(force: true),
    ]);
  }
}

class _LiveBlock extends StatelessWidget {
  const _LiveBlock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveMatchesBloc, LiveMatchesState>(
      builder: (context, state) {
        final matches = switch (state) {
          LiveReady(:final matches) => matches,
          LiveFailure(:final matches) => matches,
          _ => null,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: "LIVE",
              live: true,
              trailing: state is LiveReady ? "Updated ${clockTime(state.updatedAt)}" : null,
            ),
            if (state is LiveLoading || state is LiveInitial)
              const MatchSkeleton()
            else if (state is LiveFailure && matches == null)
              ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<LiveMatchesBloc>().refresh(),
              )
            else if (matches == null || matches.isEmpty)
              const EmptyView(
                title: "No matches are live",
                message: "Kickoffs from the major leagues will show up here.",
              )
            else ...[
              if (state is LiveFailure)
                InlineNotice(
                  message: state.failure.message,
                  onRetry: () => context.read<LiveMatchesBloc>().refresh(),
                ),
              LiveHero(match: matches.first, onTap: () => _open(context, matches.first)),
              if (matches.length > 1)
                GroupedMatchList(
                  matches: matches.skip(1).toList(),
                  onTap: (match) => _open(context, match),
                ),
            ],
          ],
        );
      },
    );
  }

  void _open(BuildContext context, Match match) {
    Navigator.of(context).push(MatchDetailPage.route(match));
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionDayCubit, DayState>(
      builder: (context, state) {
        final board = state.board;
        final title = board == null
            ? Competition.premierLeague.name.toUpperCase()
            : "${board.competition.name}  ·  ${shortDate(board.day)}".toUpperCase();
        final quiet = board?.matches
                .where((match) => match.state != MatchState.live)
                .toList() ??
            const <Match>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title),
            if (state is DayLoading && board == null)
              const MatchSkeleton()
            else if (state is DayFailure && board == null)
              ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<CompetitionDayCubit>().open(force: true),
              )
            else if (quiet.isEmpty)
              const EmptyView(
                title: "Nothing on the slate",
                message: "There are no Premier League fixtures for this day.",
              )
            else
              MatchDayList(
                matches: quiet,
                includeLive: false,
                onTap: (match) => Navigator.of(context).push(MatchDetailPage.route(match)),
              ),
          ],
        );
      },
    );
  }
}

class _StoriesBlock extends StatelessWidget {
  const _StoriesBlock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        final stories = state.stories;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: "STORIES", trailing: "ESPN"),
            if (state is NewsLoading && stories == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(height: 180),
              )
            else if (state is NewsFailure && stories == null)
              ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<NewsCubit>().load(force: true),
              )
            else if (stories == null || stories.isEmpty)
              const EmptyView(
                title: "No stories yet",
                message: "Football stories will appear here when the feed has them.",
                icon: Icons.article_outlined,
              )
            else
              StoryStack(
                stories: stories.take(5).toList(),
                onTap: (story) => Navigator.of(context).push(StoryPage.route(story)),
              ),
          ],
        );
      },
    );
  }
}
