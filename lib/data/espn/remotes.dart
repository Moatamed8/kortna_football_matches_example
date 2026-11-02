import "package:soccer/core/competitions/competition.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

abstract class MatchRemote {
  Future<List<Match>> scoreboard({
    required Competition competition,
    required DateTime day,
  });

  Future<MatchInsight> summary({required Match match});
}

abstract class TeamRemote {
  Future<List<TeamSummary>> teams(Competition competition);

  Future<TeamFacts> facts({
    required TeamSummary team,
    required Competition competition,
  });

  Future<Squad> squad(TeamSummary team);

  Future<List<Match>> schedule({
    required TeamSummary team,
    required Competition competition,
  });
}

abstract class PlayerRemote {
  Future<PlayerProfile> player(SquadPlayer player);
}

abstract class InjuryRemote {
  Future<List<InjuryReport>> injuries(Competition competition);
}

abstract class StoryRemote {
  Future<List<Story>> stories(Competition competition);
}
