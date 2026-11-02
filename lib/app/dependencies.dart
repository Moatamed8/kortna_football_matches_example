import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/network/app_http_client.dart";
import "package:soccer/core/theme/theme_store.dart";
import "package:soccer/core/time/ticker.dart";
import "package:soccer/data/espn/espn_remote.dart";
import "package:soccer/data/fotmob/fotmob_remote.dart";
import "package:soccer/data/routing_remote.dart";
import "package:soccer/features/injuries/data/injury_repository_impl.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";
import "package:soccer/features/matches/data/match_repository_impl.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/news/data/story_repository_impl.dart";
import "package:soccer/features/news/domain/story_repository.dart";
import "package:soccer/features/players/data/player_repository_impl.dart";
import "package:soccer/features/players/domain/player_repository.dart";
import "package:soccer/features/settings/settings_cubit.dart";
import "package:soccer/features/teams/data/team_repository_impl.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

class AppDependencies {
  AppDependencies({
    required this.matches,
    required this.teams,
    required this.players,
    required this.injuries,
    required this.stories,
    required this.settings,
    required this.ticker,
  });

  factory AppDependencies.production(ThemeStore themes) {
    final http = AppHttpClient();
    final remote = RoutingRemote(
      espn: EspnRemote(http),
      egypt: FotmobEgyptianRemote(http),
    );
    final cache = TtlCache();
    return AppDependencies(
      matches: MatchRepositoryImpl(remote, cache: cache),
      teams: TeamRepositoryImpl(remote, cache: cache),
      players: PlayerRepositoryImpl(remote, cache: cache),
      injuries: InjuryRepositoryImpl(remote, cache: cache),
      stories: StoryRepositoryImpl(remote, cache: cache),
      settings: SettingsCubit(themes),
      ticker: TimerTicker(),
    );
  }

  final MatchRepository matches;
  final TeamRepository teams;
  final PlayerRepository players;
  final InjuryRepository injuries;
  final StoryRepository stories;
  final SettingsCubit settings;
  final Ticker ticker;
}
