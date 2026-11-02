import "package:equatable/equatable.dart";

class Competition extends Equatable {
  const Competition({
    required this.slug,
    required this.name,
    required this.country,
  });

  final String slug;
  final String name;
  final String country;

  static const premierLeague = Competition(
    slug: "eng.1",
    name: "Premier League",
    country: "England",
  );
  static const championsLeague = Competition(
    slug: "uefa.champions",
    name: "Champions League",
    country: "Europe",
  );
  static const laLiga = Competition(
    slug: "esp.1",
    name: "La Liga",
    country: "Spain",
  );
  static const serieA = Competition(
    slug: "ita.1",
    name: "Serie A",
    country: "Italy",
  );
  static const bundesliga = Competition(
    slug: "ger.1",
    name: "Bundesliga",
    country: "Germany",
  );
  static const ligue1 = Competition(
    slug: "fra.1",
    name: "Ligue 1",
    country: "France",
  );

  /// Egyptian Premier League. ESPN does not publish this competition;
  /// the FotMob feed (league 519) is the source.
  static const egyptianPremierLeague = Competition(
    slug: "egy.1",
    name: "Egyptian Premier League",
    country: "Egypt",
  );

  /// Competitions refreshed while the user is watching live scores.
  static const liveSweep = <Competition>[
    premierLeague,
    championsLeague,
    laLiga,
    serieA,
    bundesliga,
    egyptianPremierLeague,
  ];

  static const browsable = <Competition>[
    premierLeague,
    championsLeague,
    laLiga,
    serieA,
    bundesliga,
    ligue1,
    egyptianPremierLeague,
  ];

  @override
  List<Object?> get props => [slug];
}
