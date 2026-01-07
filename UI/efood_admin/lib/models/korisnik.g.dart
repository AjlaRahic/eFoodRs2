// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
      id: (json['id'] as num?)?.toInt(),
      ime: json['ime'] as String?,
      prezime: json['prezime'] as String?,
      korisnickoIme: json['korisnickoIme'] as String?,
      email: json['email'] as String?,
      telefon: json['telefon'] as String?,
      korisniciUloges: (json['korisniciUloges'] as List<dynamic>?)
              ?.map((e) => KorisnikUloga.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
      'id': instance.id,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'korisnickoIme': instance.korisnickoIme,
      'telefon': instance.telefon,
      'email': instance.email,
      'korisniciUloges':
          instance.korisniciUloges.map((e) => e.toJson()).toList(),
    };
