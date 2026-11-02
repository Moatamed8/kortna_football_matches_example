import "package:soccer/core/competitions/competition.dart";
import "package:soccer/features/news/domain/entities/story.dart";

abstract class StoryRepository {
  Future<List<Story>> stories(Competition competition, {bool force = false});
}
