import "package:equatable/equatable.dart";

class SquadPlayer extends Equatable {
  const SquadPlayer({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    required this.competitionSlug,
    this.number,
    this.position,
    this.nationality,
    this.flagUrl,
    this.age,
    this.photoUrl,
    this.teamLogoUrl,
  });

  final String id;
  final String name;
  final String? number;
  final String? position;
  final String? nationality;
  final String? flagUrl;
  final int? age;
  final String? photoUrl;
  final String teamId;
  final String teamName;
  final String? teamLogoUrl;
  final String competitionSlug;

  @override
  List<Object?> get props => [
    id,
    name,
    number,
    position,
    nationality,
    flagUrl,
    age,
    photoUrl,
    teamId,
    teamName,
    teamLogoUrl,
    competitionSlug,
  ];
}

class PlayerStat extends Equatable {
  const PlayerStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}

class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.teamName,
    this.number,
    this.position,
    this.nationality,
    this.flagUrl,
    this.age,
    this.height,
    this.weight,
    this.photoUrl,
    this.teamLogoUrl,
    this.statsTitle,
    this.stats = const [],
    this.injuryStatus,
    this.injuryReason,
    this.injuryNote,
  });

  final String id;
  final String name;
  final String? number;
  final String? position;
  final String? nationality;
  final String? flagUrl;
  final int? age;
  final String? height;
  final String? weight;
  final String? photoUrl;
  final String teamName;
  final String? teamLogoUrl;
  final String? statsTitle;
  final List<PlayerStat> stats;
  final String? injuryStatus;
  final String? injuryReason;
  final String? injuryNote;

  bool get hasInjury =>
      (injuryStatus != null && injuryStatus!.isNotEmpty) ||
      (injuryReason != null && injuryReason!.isNotEmpty) ||
      (injuryNote != null && injuryNote!.isNotEmpty);

  @override
  List<Object?> get props => [
    id,
    name,
    number,
    position,
    nationality,
    flagUrl,
    age,
    height,
    weight,
    photoUrl,
    teamName,
    teamLogoUrl,
    statsTitle,
    stats,
    injuryStatus,
    injuryReason,
    injuryNote,
  ];
}
