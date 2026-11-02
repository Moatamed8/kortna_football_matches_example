import "package:flutter_test/flutter_test.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/espn_parser.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

void main() {
  test("assigns home and away from homeAway, not list order", () {
    final matches = parseScoreboard({
      "events": [
        {
          "id": "401879246",
          "date": "2026-11-01T16:30Z",
          "competitions": [
            {
              "id": "401879246",
              "date": "2026-11-01T16:30Z",
              "status": {
                "displayClock": "90'+7'",
                "type": {
                  "state": "post",
                  "shortDetail": "FT",
                  "description": "Full Time",
                },
              },
              "venue": {
                "fullName": "Anfield",
                "address": {"city": "Liverpool"},
              },
              "competitors": [
                {
                  "homeAway": "away",
                  "score": "1",
                  "team": {
                    "id": "359",
                    "displayName": "Arsenal",
                    "shortDisplayName": "Arsenal",
                  },
                },
                {
                  "homeAway": "home",
                  "score": "0",
                  "form": "LWWWW",
                  "team": {
                    "id": "364",
                    "displayName": "Liverpool",
                    "shortDisplayName": "Liverpool",
                    "logo": "https://example.com/liv.png",
                  },
                },
              ],
              "details": [
                {
                  "type": {"text": "Goal"},
                  "clock": {"displayValue": "16'"},
                  "team": {"id": "359"},
                  "scoringPlay": true,
                  "ownGoal": false,
                  "penaltyKick": false,
                  "athletesInvolved": [
                    {"displayName": "Kai Havertz"},
                    {"displayName": "Declan Rice"},
                  ],
                },
              ],
            },
          ],
        },
      ],
    }, fallback: Competition.premierLeague);

    expect(matches, hasLength(1));
    final match = matches.single;
    expect(match.home.name, "Liverpool");
    expect(match.home.score, 0);
    expect(match.away.name, "Arsenal");
    expect(match.away.score, 1);
    expect(match.state, MatchState.finished);
    expect(match.venue, "Anfield");
    expect(match.events.single.playerName, "Kai Havertz");
    expect(match.events.single.assistName, "Declan Rice");
    expect(match.home.logoUrl, "https://example.com/liv.png");
  });

  test("scheduled matches do not surface a 0-0 score", () {
    final match = parseEvent({
      "id": "10",
      "date": "2026-11-02T20:00Z",
      "competitions": [
        {
          "status": {
            "displayClock": "0'",
            "type": {"state": "pre", "shortDetail": "Scheduled"},
          },
          "competitors": [
            {
              "homeAway": "home",
              "score": "0",
              "team": {"id": "1", "displayName": "Newcastle United"},
            },
            {
              "homeAway": "away",
              "score": "0",
              "team": {"id": "2", "displayName": "Everton"},
            },
          ],
        },
      ],
    }, fallback: Competition.premierLeague);

    expect(match, isNotNull);
    expect(match!.state, MatchState.upcoming);
    expect(match.hasScore, isFalse);
    expect(match.home.score, isNull);
    expect(match.clock, isNull);
  });

  test("summary keeps real statistics, lineups and referee only", () {
    final fallback = Match(
      id: "9",
      competitionSlug: "eng.1",
      competitionName: "Premier League",
      kickoff: DateTime.utc(2026, 11, 1, 16, 30),
      state: MatchState.finished,
      statusLabel: "FT",
      home: const TeamSide(id: "364", name: "Liverpool", shortName: "Liverpool"),
      away: const TeamSide(id: "359", name: "Arsenal", shortName: "Arsenal"),
    );
    final insight = parseSummary({
      "boxscore": {
        "teams": [
          {
            "statistics": [
              {"name": "possessionPct", "displayName": "Possession", "displayValue": "56.4"},
              {"name": "totalShots", "displayName": "Shots", "displayValue": "17"},
            ],
          },
          {
            "statistics": [
              {"name": "possessionPct", "displayName": "Possession", "displayValue": "43.6"},
              {"name": "totalShots", "displayName": "Shots", "displayValue": "8"},
            ],
          },
        ],
      },
      "rosters": [
        {
          "formation": "4-2-3-1",
          "team": {"id": "364", "displayName": "Liverpool"},
          "roster": [
            {
              "starter": true,
              "jersey": "1",
              "position": {"abbreviation": "G", "displayName": "Goalkeeper"},
              "athlete": {"id": "196876", "displayName": "Alisson Becker"},
            },
          ],
        },
      ],
      "gameInfo": {
        "venue": {"fullName": "Anfield", "address": {"city": "Liverpool"}},
        "attendance": 0,
        "officials": [
          {
            "displayName": "Michael Oliver",
            "position": {"displayName": "Referee"},
          },
          {
            "displayName": "Assistant One",
            "position": {"displayName": "Assistant Referee"},
          },
        ],
      },
      "keyEvents": [
        {
          "id": "1",
          "type": {"text": "Goal"},
          "text": "Goal! Liverpool 0, Arsenal 1. Kai Havertz.",
          "clock": {"displayValue": "16'"},
          "scoringPlay": true,
          "team": {"id": "359", "displayName": "Arsenal"},
          "participants": [
            {"athlete": {"displayName": "Kai Havertz"}},
          ],
        },
      ],
    }, fallback: fallback);

    expect(insight.stats.map((stat) => stat.id), ["possessionPct", "totalShots"]);
    expect(insight.stats.first.home, "56.4");
    expect(insight.stats.first.away, "43.6");
    expect(insight.lineups.single.formation, "4-2-3-1");
    expect(insight.lineups.single.starters.single.name, "Alisson Becker");
    expect(insight.referee, "Michael Oliver");
    expect(insight.attendance, isNull);
    expect(insight.venue, "Anfield");
    expect(insight.events.single.playerName, "Kai Havertz");
  });

  test("injuries are grouped by club and omit invented return dates", () {
    final reports = parseInjuries({
      "injuries": [
        {
          "id": "1",
          "displayName": "Arsenal",
          "injuries": [
            {
              "id": "99",
              "status": "Out",
              "shortComment": "Saka is out with a hamstring injury.",
              "date": "2026-11-01T12:00Z",
              "athlete": {
                "id": "7",
                "displayName": "Bukayo Saka",
                "position": {"displayName": "Forward"},
                "headshot": {"href": "https://example.com/saka.png"},
              },
              "details": {"type": "Hamstring", "side": "Left"},
            },
          ],
        },
      ],
    });

    expect(reports, hasLength(1));
    final report = reports.single;
    expect(report.playerName, "Bukayo Saka");
    expect(report.teamName, "Arsenal");
    expect(report.status, "Out");
    expect(report.reason, "Left Hamstring");
    expect(report.expectedReturn, isNull);
    expect(report.photoUrl, "https://example.com/saka.png");
    expect(report.position, "Forward");
  });

  test("season record uses published wins, draws and points only", () {
    final facts = parseTeamFacts({
      "team": {
        "standingSummary": "5th in English Premier League",
        "record": {
          "items": [
            {
              "description": "Overall Record",
              "stats": [
                {"name": "wins", "value": 4},
                {"name": "ties", "value": 1},
                {"name": "losses", "value": 2},
                {"name": "points", "value": 13},
              ],
            },
          ],
        },
      },
    }, competition: Competition.premierLeague);

    expect(facts.standing, "5th in English Premier League");
    expect(facts.record?.label, "4 W · 1 D · 2 L · 13 pts");
  });

  const team = TeamSummary(
    id: "364",
    name: "Liverpool",
    shortName: "Liverpool",
    competitionSlug: "eng.1",
    competitionName: "Premier League",
    country: "England",
  );

  test("squad parsing reads players and ignores the historical coach list", () {
    final squad = parseSquad({
      "coach": [
        {"id": "182", "firstName": "Kenny", "lastName": "Dalglish"},
      ],
      "athletes": [
        {
          "id": "1",
          "displayName": "Alisson Becker",
          "jersey": "1",
          "age": 33,
          "citizenship": "Brazil",
          "position": {"displayName": "Goalkeeper"},
          "flag": {"href": "https://example.com/bra.png"},
        },
      ],
    }, team: team);

    expect(squad.players, hasLength(1));
    expect(squad.players.single.position, "Goalkeeper");
    expect(squad.players.single.nationality, "Brazil");
    expect(squad.players.single.photoUrl, isNull);
    expect(squad.players.single.flagUrl, "https://example.com/bra.png");
  });
}
