import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/app/dependencies.dart";
import "package:soccer/core/theme/app_theme.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/matches/presentation/live/live_matches_bloc.dart";
import "package:soccer/features/news/domain/story_repository.dart";
import "package:soccer/features/players/domain/player_repository.dart";
import "package:soccer/features/settings/settings_cubit.dart";
import "package:soccer/features/shell/shell_page.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

class KortnaApp extends StatelessWidget {
  const KortnaApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MatchRepository>.value(value: dependencies.matches),
        RepositoryProvider<TeamRepository>.value(value: dependencies.teams),
        RepositoryProvider<PlayerRepository>.value(value: dependencies.players),
        RepositoryProvider<InjuryRepository>.value(value: dependencies.injuries),
        RepositoryProvider<StoryRepository>.value(value: dependencies.stories),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: dependencies.settings),
          BlocProvider(
            create: (_) => LiveMatchesBloc(
              dependencies.matches,
              ticker: dependencies.ticker,
            ),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp(
              title: "Kortna",
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: settings.themeMode,
              home: const ShellPage(),
            );
          },
        ),
      ),
    );
  }
}
