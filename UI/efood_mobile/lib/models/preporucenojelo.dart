import 'jelo.dart';

class PreporucenoJeloDto {
  final Jelo jelo;
  final String reasonCategory;   
  final double similarity;      

  PreporucenoJeloDto({
    required this.jelo,
    required this.reasonCategory,
    required this.similarity,
  });

  factory PreporucenoJeloDto.fromJson(Map<String, dynamic> json) {
    return PreporucenoJeloDto(
      jelo: Jelo.fromJson(json['jelo']),
      reasonCategory: (json['reasonCategory'] ?? '').toString(),
      similarity: (json['similarity'] ?? 0).toDouble(),
    );
  }
}
