import "package:equatable/equatable.dart";

class InjuryReport extends Equatable {
  const InjuryReport({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.teamId,
    required this.teamName,
    required this.status,
    this.photoUrl,
    this.teamLogoUrl,
    this.position,
    this.reason,
    this.note,
    this.expectedReturn,
    this.updatedAt,
  });

  final String id;
  final String playerId;
  final String playerName;
  final String? photoUrl;
  final String teamId;
  final String teamName;
  final String? teamLogoUrl;
  final String? position;
  final String status;
  final String? reason;
  final String? note;
  final String? expectedReturn;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    playerId,
    playerName,
    photoUrl,
    teamId,
    teamName,
    teamLogoUrl,
    position,
    status,
    reason,
    note,
    expectedReturn,
    updatedAt,
  ];
}
