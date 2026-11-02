import "package:equatable/equatable.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/players/domain/entities/player.dart";

class TeamSummary extends Equatable {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.shortName,
    required this.competitionSlug,
    required this.competitionName,
    required this.country,
    this.abbreviation,
    this.logoUrl,
    this.colorHex,
  });

  final String id;
  final String name;
  final String shortName;
  final String? abbreviation;
  final String? logoUrl;
  final String? colorHex;
  final String competitionSlug;
  final String competitionName;
  final String country;

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    abbreviation,
    logoUrl,
    colorHex,
    competitionSlug,
    competitionName,
    country,
  ];
}

class SeasonRecord extends Equatable {
  const SeasonRecord({this.wins, this.draws, this.losses, this.points});

  final int? wins;
  final int? draws;
  final int? losses;
  final int? points;

  bool get isEmpty =>
      wins == null && draws == null && losses == null && points == null;

  String? get label {
    final parts = <String>[
      if (wins != null) "$wins W",
      if (draws != null) "$draws D",
      if (losses != null) "$losses L",
      if (points != null) "$points pts",
    ];
    if (parts.isEmpty) return null;
    return parts.join(" · ");
  }

  @override
  List<Object?> get props => [wins, draws, losses, points];
}

class TeamFacts extends Equatable {
  const TeamFacts({this.standing, this.record, this.nextMatch, this.colorHex});

  final String? standing;
  final SeasonRecord? record;
  final Match? nextMatch;
  final String? colorHex;

  @override
  List<Object?> get props => [standing, record, nextMatch, colorHex];
}

class Squad extends Equatable {
  const Squad({required this.players});

  final List<SquadPlayer> players;

  @override
  List<Object?> get props => [players];
}
