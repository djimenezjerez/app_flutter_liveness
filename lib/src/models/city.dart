import 'package:meta/meta.dart';
import 'dart:convert';

City cityFromJson(String str) =>
    City.fromJson(json.decode(str)['data']['city']);

String cityToJson(City data) => json.encode(data.toJson());

List<City> citiesFromJson(String str) => List<City>.from(
    json.decode(str)['data']['cities'].map((x) => City.fromJson(x)));

String citiesToJson(List<City> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class City {
  City({
    @required this.id,
    @required this.name,
    @required this.latitude,
    @required this.longitude,
    @required this.companyAddress,
    @required this.phonePrefix,
    @required this.companyPhones,
    @required this.companyCellphones,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String companyAddress;
  final int phonePrefix;
  final List<int> companyPhones;
  final List<int> companyCellphones;

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        companyAddress: json["company_address"],
        phonePrefix: json["phone_prefix"],
        companyPhones: List<int>.from(json["company_phones"].map((x) => x)),
        companyCellphones:
            List<int>.from(json["company_cellphones"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "company_address": companyAddress,
        "phone_prefix": phonePrefix,
        "company_phones": List<dynamic>.from(companyPhones.map((x) => x)),
        "company_cellphones":
            List<dynamic>.from(companyCellphones.map((x) => x)),
      };
}
