class Lokacija {
  int? lokacijaId;
  int? korisnikId;
  double latitude;
  double longitude;
  DateTime? datum;
  dynamic korisnik;

  Lokacija({
    this.lokacijaId,
    this.korisnikId,
    required this.latitude,
    required this.longitude,
    this.datum,
    this.korisnik,
  });

  factory Lokacija.fromJson(Map<String, dynamic> json) => Lokacija(
        lokacijaId: json['lokacijaId'],
        korisnikId: json['korisnikId'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        datum: json['vrijeme'] != null ? DateTime.parse(json['vrijeme']) : null,
        korisnik: json['korisnik'],
      );

  /// Partial JSON (samo latitude/longitude)
  factory Lokacija.fromPartialJson(Map<String, dynamic> json) => Lokacija(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
