import "package:soccer/features/players/domain/entities/player.dart";

abstract class PlayerRepository {
  Future<PlayerProfile> profile(SquadPlayer player, {bool force = false});
}
