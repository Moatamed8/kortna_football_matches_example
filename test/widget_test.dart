import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:soccer/app/app.dart";
import "package:soccer/app/dependencies.dart";
import "package:soccer/core/theme/theme_store.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/settings/settings_cubit.dart";

import "support/fakes.dart";

void main() {
  testWidgets("home shows live and upcoming matches and opens details", (tester) async {
    final live = sampleMatch(
      events: const [
        MatchEvent(
          id: "g",
          type: "Goal",
          text: "Goal! Arsenal. Kai Havertz.",
          clock: "12'",
          playerName: "Kai Havertz",
          scoringPlay: true,
        ),
      ],
    );
    final upcoming = sampleMatch(
      id: "2",
      state: MatchState.upcoming,
      homeScore: null,
      awayScore: null,
      home: "Everton",
      away: "Newcastle United",
    );
    final dependencies = _dependencies(
      matches: FakeMatchRepository(live: [live], day: [live, upcoming]),
    );
    addTearDown(dependencies.settings.close);

    await tester.pumpWidget(KortnaApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text("KORTNA"), findsOneWidget);
    expect(find.text("Arsenal"), findsWidgets);
    expect(find.text("2 – 1"), findsOneWidget);
    expect(find.text("12' Kai Havertz"), findsOneWidget);
    expect(find.text("Everton"), findsOneWidget);
    expect(find.text("Title race tightens"), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey("match-401")));
    await tester.pumpAndSettle();

    expect(find.text("Possession"), findsOneWidget);
    expect(find.text("56.4"), findsOneWidget);
    expect(find.text("43.6"), findsOneWidget);
    expect(find.text("Referee"), findsNothing);
  });

  testWidgets("appearance switches the app to dark mode", (tester) async {
    final dependencies = _dependencies();
    addTearDown(dependencies.settings.close);

    await tester.pumpWidget(KortnaApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.text("More"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Dark"));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme?.brightness, Brightness.dark);
  });

  testWidgets("developer profile shows the name and contact details", (tester) async {
    final dependencies = _dependencies();
    addTearDown(dependencies.settings.close);

    await tester.pumpWidget(KortnaApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.text("More"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Developer"));
    await tester.pumpAndSettle();

    expect(find.text("Moatamed Wageh Nashat"), findsWidgets);
    expect(find.text("Flutter and native Android"), findsOneWidget);
    await tester.scrollUntilVisible(find.text("github.com/moatamed8"), 200);
    expect(find.text("metmedelbana@gmail.com"), findsOneWidget);
    expect(find.text("+20 128 858 4664"), findsOneWidget);
    expect(find.text("github.com/moatamed8"), findsOneWidget);
  });
}

AppDependencies _dependencies({FakeMatchRepository? matches}) {
  return AppDependencies(
    matches: matches ?? FakeMatchRepository(day: [sampleMatch(id: "quiet", state: MatchState.upcoming, homeScore: null, awayScore: null, home: "Everton", away: "Newcastle United")]),
    teams: FakeTeamRepository(),
    players: FakePlayerRepository(),
    injuries: FakeInjuryRepository(),
    stories: FakeStoryRepository(const [
      Story(
        id: "s",
        headline: "Title race tightens",
        source: "ESPN",
        competitionName: "Premier League",
      ),
    ]),
    settings: SettingsCubit(MemoryThemeStore()),
    ticker: ManualTicker(),
  );
}
