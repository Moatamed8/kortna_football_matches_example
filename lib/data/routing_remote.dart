import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/espn_remote.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/data/fotmob/fotmob_remote.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

/// ESPN for the European competitions, FotMob for the Egyptian Premier League.
class RoutingRemote
    implements MatchRemote, TeamRemote, PlayerRemote, InjuryRemote, StoryRemote {
  RoutingRemote({required this.espn, required this.egypt});

  final EspnRemote espn;
  final FotmobEgyptianRemote egypt;

  @override
  Future<List<Match>> scoreboard({
    required Competition competition,
    required DateTime day,
  }) {
    if (_isEgypt(competition.slug)) {
      return egypt.scoreboard(competition: competition, day: day);
    }
    return espn.scoreboard(competition: competition, day: day);
  }

  @override
  Future<MatchInsight> summary({required Match match}) {
    if (_isEgypt(match.competitionSlug)) return egypt.summary(match: match);
    return espn.summary(match: match);
  }

  @override
  Future<List<TeamSummary>> teams(Competition competition) {
    if (_isEgypt(competition.slug)) return egypt.teams(competition);
    return espn.teams(competition);
  }

  @override
  Future<TeamFacts> facts({
    required TeamSummary team,
    required Competition competition,
  }) {
    if (_isEgypt(team.competitionSlug)) {
      return egypt.facts(team: team, competition: competition);
    }
    return espn.facts(team: team, competition: competition);
  }

  @override
  Future<Squad> squad(TeamSummary team) {
    if (_isEgypt(team.competitionSlug)) return egypt.squad(team);
    return espn.squad(team);
  }

  @override
  Future<List<Match>> schedule({
    required TeamSummary team,
    required Competition competition,
  }) {
    if (_isEgypt(team.competitionSlug)) {
      return egypt.schedule(team: team, competition: competition);
    }
    return espn.schedule(team: team, competition: competition);
  }

  @override
  Future<PlayerProfile> player(SquadPlayer player) {
    if (_isEgypt(player.competitionSlug)) return egypt.player(player);
    return espn.player(player);
  }

  @override
  Future<List<InjuryReport>> injuries(Competition competition) {
    if (_isEgypt(competition.slug)) return egypt.injuries(competition);
    return espn.injuries(competition);
  }

  @override
  Future<List<Story>> stories(Competition competition) {
    if (_isEgypt(competition.slug)) return egypt.stories(competition);
    return espn.stories(competition);
  }

  bool _isEgypt(String slug) => slug == Competition.egyptianPremierLeague.slug;
}
