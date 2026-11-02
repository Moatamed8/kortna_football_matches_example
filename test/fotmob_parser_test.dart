import "package:flutter_test/flutter_test.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/fotmob/fotmob_parser.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

void main() {
  const competition = Competition.egyptianPremierLeague;

  test("reads home and away scores only after kickoff", () {
    final kickoff = DateTime.parse("2026-08-21T17:00:00Z");
    final day = DateTime(kickoff.toLocal().year, kickoff.toLocal().month, kickoff.toLocal().day);
    final matches = parseFotmobScoreboard(
      {
        "fixtures": {
          "allMatches": [
            {
              "id": "5995571",
              "home": {"id": "316504", "name": "Abo Qir Semad", "shortName": "Abo Qir"},
              "away": {"id": "1", "name": "National Bank", "shortName": "Bank"},
              "status": {
                "utcTime": "2026-08-21T17:00:00Z",
                "started": true,
                "finished": true,
                "cancelled": false,
                "scoreStr": "1 - 0",
                "reason": {"short": "FT", "long": "Full-Time", "longKey": "finished"},
              },
            },
            {
              "id": "6000001",
              "home": {"id": "2", "name": "Pyramids FC", "shortName": "Pyramids"},
              "away": {"id": "3", "name": "Al Ahly", "shortName": "Ahly"},
              "status": {
                "utcTime": "2026-11-23T15:00:00Z",
                "started": false,
                "finished": false,
                "cancelled": false,
              },
            },
          ],
        },
      },
      competition: competition,
      day: day,
    );

    expect(matches, hasLength(1));
    expect(matches.single.home.name, "Abo Qir Semad");
    expect(matches.single.away.name, "National Bank");
    expect(matches.single.scoreLabel, "1 – 0");
    expect(matches.single.state, MatchState.finished);
    expect(matches.single.competitionName, "Egyptian Premier League");
  });

  test("leaves scheduled matches without a score", () {
    final kickoff = DateTime.parse("2026-11-23T15:00:00Z");
    final matches = parseFotmobScoreboard(
      {
        "fixtures": {
          "allMatches": [
            {
              "id": "6000001",
              "home": {"id": "2", "name": "Pyramids FC"},
              "away": {"id": "3", "name": "Al Ahly"},
              "status": {
                "utcTime": "2026-11-23T15:00:00Z",
                "started": false,
                "finished": false,
              },
            },
          ],
        },
      },
      competition: competition,
      day: DateTime(kickoff.toLocal().year, kickoff.toLocal().month, kickoff.toLocal().day),
    );

    expect(matches.single.hasScore, isFalse);
    expect(matches.single.state, MatchState.upcoming);
    expect(matches.single.statusLabel, isEmpty);
  });

  test("maps goals, cards, lineups, and stats without using stadium capacity", () {
    final fallback = Match(
      id: "5995571",
      competitionSlug: competition.slug,
      competitionName: competition.name,
      kickoff: DateTime.parse("2026-08-21T17:00:00Z"),
      state: MatchState.finished,
      statusLabel: "FT",
      home: const TeamSide(id: "316504", name: "Abo Qir Semad", shortName: "Abo Qir"),
      away: const TeamSide(id: "1", name: "National Bank", shortName: "Bank"),
    );
    final insight = parseFotmobSummary(
      {
        "general": {"matchId": 5995571, "matchTimeUTCDate": "2026-08-21T17:00:00.000Z"},
        "header": {
          "teams": [
            {"id": 316504, "name": "Abo Qir Semad", "score": 1},
            {"id": 1, "name": "National Bank", "score": 0},
          ],
          "status": {
            "utcTime": "2026-08-21T17:00:00.000Z",
            "started": true,
            "finished": true,
            "scoreStr": "1 - 0",
            "reason": {"short": "FT"},
          },
        },
        "content": {
          "matchFacts": {
            "events": {
              "events": [
                {
                  "reactKey": "goal-1",
                  "type": "Goal",
                  "time": 59,
                  "isHome": true,
                  "nameStr": "Ali Hussein",
                  "assistStr": "Favour Akem",
                  "ownGoal": null,
                  "suffix": "(pen)",
                },
                {
                  "reactKey": "card-1",
                  "type": "Card",
                  "time": 78,
                  "overloadTime": 0,
                  "isHome": false,
                  "nameStr": "Islam Ashraf",
                  "card": "Yellow",
                  "cardReason": {"defaultText": "Foul"},
                },
                {"type": "AddedTime", "time": 45, "minutesAddedInput": 3},
              ],
            },
            "infoBox": {
              "Stadium": {
                "name": "Alexandria Stadium",
                "city": "Alexandria",
                "capacity": 19676,
              },
              "Referee": {"text": "Mohamed Abassa Kabeel"},
            },
          },
          "stats": {
            "Periods": {
              "All": {
                "stats": [
                  {
                    "title": "Top stats",
                    "stats": [
                      {
                        "title": "Ball possession",
                        "key": "BallPossesion",
                        "stats": [18, 82],
                      },
                    ],
                  },
                ],
              },
            },
          },
          "lineup": {
            "homeTeam": {
              "id": 316504,
              "name": "Abo Qir Semad",
              "formation": "4-1-4-1",
              "starters": [
                {"id": 962082, "name": "Mahmoud Gennesh", "shirtNumber": "1"},
              ],
              "subs": [
                {"id": 2146388, "name": "Ayman El Gazar", "shirtNumber": "24"},
              ],
            },
          },
        },
      },
      fallback: fallback,
    );

    expect(insight.scoreboard?.scoreLabel, "1 – 0");
    expect(insight.venue, "Alexandria Stadium");
    expect(insight.attendance, isNull);
    expect(insight.referee, "Mohamed Abassa Kabeel");
    expect(insight.events, hasLength(2));
    expect(insight.events.first.playerName, "Ali Hussein");
    expect(insight.events.first.penalty, isTrue);
    expect(insight.events.first.clock, "59'");
    expect(insight.events.last.type, "Yellow card");
    expect(insight.events.last.text, "Islam Ashraf · Foul");
    expect(insight.stats.single.home, "18");
    expect(insight.stats.single.away, "82");
    expect(insight.lineups.single.formation, "4-1-4-1");
    expect(insight.lineups.single.bench.single.name, "Ayman El Gazar");
  });

  test("squad skips coaches and injuries keep only the published return date", () {
    const team = TeamSummary(
      id: "517894",
      name: "Pyramids FC",
      shortName: "Pyramids",
      competitionSlug: "egy.1",
      competitionName: "Egyptian Premier League",
      country: "Egypt",
    );
    final json = {
      "squad": {
        "squad": [
          {
            "title": "coach",
            "members": [
              {"id": 1, "name": "Mostafa Shebeita", "role": {"key": "coach"}},
            ],
          },
          {
            "title": "defenders",
            "members": [
              {
                "id": 1227663,
                "name": "Osama Galal",
                "cname": "Egypt",
                "age": 30,
                "shirtNumber": 4,
                "injury": {"id": "8", "expectedReturn": "Late December 2026"},
              },
              {
                "id": 2,
                "name": "Fit Player",
                "injury": null,
              },
            ],
          },
        ],
      },
    };

    final squad = parseFotmobSquad(json, team: team);
    expect(squad.players.map((player) => player.name), ["Osama Galal", "Fit Player"]);
    expect(squad.players.first.position, "Defender");

    final reports = parseFotmobInjuries(json, team: team);
    expect(reports, hasLength(1));
    expect(reports.single.expectedReturn, "Late December 2026");
    expect(reports.single.reason, isNull);
    expect(reports.single.status, isEmpty);
  });

  test("player profile uses season stats and the injury name from the feed", () {
    final profile = parseFotmobPlayer(
      {
        "id": 1797082,
        "name": "Ali Hussein",
        "primaryTeam": {"teamName": "Abo Qir Semad"},
        "positionDescription": {
          "primaryPosition": {"label": "Forward"},
        },
        "playerInformation": [
          {
            "translationKey": "shirt",
            "value": {"numberValue": 29},
          },
          {
            "translationKey": "age_sentencecase",
            "value": {"numberValue": 33},
          },
          {
            "translationKey": "country_sentencecase",
            "value": {"fallback": "Egypt"},
          },
        ],
        "mainLeague": {
          "leagueName": "Premier League",
          "season": "2026/2027",
          "stats": [
            {"title": "Goals", "value": 2},
          ],
        },
        "injuryInformation": {
          "name": "Broken foot",
          "expectedReturn": {"expectedReturnFallback": "Late December 2026"},
        },
      },
      fallback: const SquadPlayer(
        id: "1797082",
        name: "Ali Hussein",
        teamId: "1",
        teamName: "Abo Qir Semad",
        competitionSlug: "egy.1",
      ),
    );

    expect(profile.position, "Forward");
    expect(profile.number, "29");
    expect(profile.nationality, "Egypt");
    expect(profile.statsTitle, "Premier League 2026/2027");
    expect(profile.stats.single.value, "2");
    expect(profile.injuryReason, "Broken foot");
    expect(profile.injuryNote, "Late December 2026");
  });
}
