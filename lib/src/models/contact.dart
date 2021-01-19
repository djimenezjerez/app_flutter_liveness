import 'package:meta/meta.dart';
import 'dart:convert';

class Contact {
  Contact({
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

  factory Contact.fromJson(String str) => Contact.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Contact.fromMap(Map<String, dynamic> json) => Contact(
        id: json['id'],
        name: json['name'],
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
        companyAddress: json['company_address'],
        phonePrefix: json['phone_prefix'],
        companyPhones:
            List<int>.from(jsonDecode(json['company_phones']).map((x) => x)),
        companyCellphones: List<int>.from(
            jsonDecode(json['company_cellphones']).map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'company_address': companyAddress,
        'phone_prefix': phonePrefix,
        'company_phones': List<dynamic>.from(companyPhones.map((x) => x)),
        'company_cellphones':
            List<dynamic>.from(companyCellphones.map((x) => x)),
      };
}
