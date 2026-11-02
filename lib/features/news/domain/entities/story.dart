import "package:equatable/equatable.dart";

class Story extends Equatable {
  const Story({
    required this.id,
    required this.headline,
    required this.source,
    required this.competitionName,
    this.summary,
    this.imageUrl,
    this.publishedAt,
    this.url,
  });

  final String id;
  final String headline;
  final String? summary;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String source;
  final String? url;
  final String competitionName;

  @override
  List<Object?> get props => [
    id,
    headline,
    summary,
    imageUrl,
    publishedAt,
    source,
    url,
    competitionName,
  ];
}
