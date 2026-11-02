import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";

class InjuryRepositoryImpl implements InjuryRepository {
  InjuryRepositoryImpl(this._remote, {TtlCache? cache})
    : _cache = cache ?? TtlCache();

  final InjuryRemote _remote;
  final TtlCache _cache;

  @override
  Future<List<InjuryReport>> reports(
    Competition competition, {
    bool force = false,
  }) {
    return remember(
      cache: _cache,
      key: "injuries:${competition.slug}",
      ttl: const Duration(minutes: 30),
      force: force,
      load: () => _remote.injuries(competition),
    );
  }
}
