import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/players/domain/player_repository.dart";

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl(this._remote, {TtlCache? cache})
    : _cache = cache ?? TtlCache();

  final PlayerRemote _remote;
  final TtlCache _cache;

  @override
  Future<PlayerProfile> profile(SquadPlayer player, {bool force = false}) {
    return remember(
      cache: _cache,
      key: "player:${player.competitionSlug}:${player.id}",
      ttl: const Duration(hours: 6),
      force: force,
      load: () => _remote.player(player),
    );
  }
}
