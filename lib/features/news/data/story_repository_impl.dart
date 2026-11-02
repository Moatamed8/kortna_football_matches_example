import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/news/domain/story_repository.dart";

class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._remote, {TtlCache? cache})
    : _cache = cache ?? TtlCache();

  final StoryRemote _remote;
  final TtlCache _cache;

  @override
  Future<List<Story>> stories(Competition competition, {bool force = false}) {
    return remember(
      cache: _cache,
      key: "stories:${competition.slug}",
      ttl: const Duration(minutes: 10),
      force: force,
      load: () => _remote.stories(competition),
    );
  }
}
