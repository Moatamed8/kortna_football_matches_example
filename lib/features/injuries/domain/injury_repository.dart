import "package:soccer/core/competitions/competition.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";

abstract class InjuryRepository {
  Future<List<InjuryReport>> reports(
    Competition competition, {
    bool force = false,
  });
}
