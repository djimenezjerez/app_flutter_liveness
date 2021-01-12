import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.name,
    this.rank,
    this.ci,
  });

  String name;
  String rank;
  String ci;

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        rank: json["rank"],
        ci: json["ci"],
      );

  Map<String, dynamic> toJson() => {
        "user": name,
        "rank": rank,
        "ci": ci,
      };
}
