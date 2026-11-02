import "package:soccer/core/competitions/competition.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

abstract class TeamRepository {
  Future<List<TeamSummary>> teams(
    Competition competition, {
    bool force = false,
  });

  Future<TeamFacts> facts(TeamSummary team, {bool force = false});

  Future<Squad> squad(TeamSummary team, {bool force = false});

  Future<List<Match>> fixtures(TeamSummary team, {bool force = false});
}
