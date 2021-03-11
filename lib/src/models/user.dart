import 'dart:convert';

User userFromJson(String str) =>
    User.fromJson(json.decode(str)['data']['user']);

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
    this.fullName,
    this.degree,
    this.identityCard,
    this.enrolled,
  });

  final int id;
  final String fullName;
  final String degree;
  final String identityCard;
  final bool enrolled;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullName: json["full_name"],
        degree: json["degree"],
        identityCard: json["identity_card"],
        enrolled: json["enrolled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "degree": degree,
        "identity_card": identityCard,
        "enrolled": enrolled,
      };
}
