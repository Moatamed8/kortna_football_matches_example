import "package:soccer/core/competitions/competition.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";

abstract class MatchRepository {
  Future<List<Match>> liveMatches({bool force = false});

  Future<List<Match>> matchesOn({
    required Competition competition,
    required DateTime day,
    bool force = false,
  });

  Future<MatchInsight> insight(Match match, {bool force = false});
}
