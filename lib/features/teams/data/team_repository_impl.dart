import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this._remote, {TtlCache? cache})
    : _cache = cache ?? TtlCache();

  final TeamRemote _remote;
  final TtlCache _cache;

  @override
  Future<List<TeamSummary>> teams(
    Competition competition, {
    bool force = false,
  }) {
    return remember(
      cache: _cache,
      key: "teams:${competition.slug}",
      ttl: const Duration(hours: 6),
      force: force,
      load: () => _remote.teams(competition),
    );
  }

  @override
  Future<TeamFacts> facts(TeamSummary team, {bool force = false}) {
    final competition = Competition(
      slug: team.competitionSlug,
      name: team.competitionName,
      country: team.country,
    );
    return remember(
      cache: _cache,
      key: "team:${team.competitionSlug}:${team.id}",
      ttl: const Duration(minutes: 30),
      force: force,
      load: () => _remote.facts(team: team, competition: competition),
    );
  }

  @override
  Future<Squad> squad(TeamSummary team, {bool force = false}) {
    return remember(
      cache: _cache,
      key: "squad:${team.competitionSlug}:${team.id}",
      ttl: const Duration(hours: 6),
      force: force,
      load: () => _remote.squad(team),
    );
  }

  @override
  Future<List<Match>> fixtures(TeamSummary team, {bool force = false}) {
    final competition = Competition(
      slug: team.competitionSlug,
      name: team.competitionName,
      country: team.country,
    );
    return remember(
      cache: _cache,
      key: "fixtures:${team.competitionSlug}:${team.id}",
      ttl: const Duration(minutes: 15),
      force: force,
      load: () => _remote.schedule(team: team, competition: competition),
    );
  }
}
