import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/widgets/competition_chips.dart";
import "package:soccer/core/widgets/views.dart";
import "package:soccer/features/news/domain/story_repository.dart";
import "package:soccer/features/news/presentation/news_cubit.dart";
import "package:soccer/features/news/presentation/story_page.dart";
import "package:soccer/features/news/presentation/widgets/story_views.dart";

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) => NewsCubit(context.read<StoryRepository>())..load(),
        child: const NewsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stories")),
      body: RefreshIndicator(
        onRefresh: () => context.read<NewsCubit>().load(force: true),
        child: BlocBuilder<NewsCubit, NewsState>(
          builder: (context, state) {
            final stories = state.stories;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CompetitionChips(
                      selected: state.competition,
                      onSelected: (competition) =>
                          context.read<NewsCubit>().select(competition),
                    ),
                  ),
                ),
                if (state is NewsLoading && stories == null)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SkeletonBox(height: 180),
                    ),
                  )
                else if (state is NewsFailure && stories == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      message: state.failure.message,
                      onRetry: () => context.read<NewsCubit>().load(force: true),
                    ),
                  )
                else if (stories == null || stories.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                      title: "No stories",
                      message: "This competition has no stories in the feed right now.",
                      icon: Icons.article_outlined,
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: StoryStack(
                      stories: stories,
                      onTap: (story) =>
                          Navigator.of(context).push(StoryPage.route(story)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
