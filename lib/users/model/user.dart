class User {
  // ignore: non_constant_identifier_names
  late int user_id;
  // ignore: non_constant_identifier_names
  late String user_name;
  // ignore: non_constant_identifier_names
  late String user_email;
  // ignore: non_constant_identifier_names
  late String user_password;

  User(
    this.user_id,
    this.user_name,
    this.user_email,
    this.user_password,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        int.parse(json["user_id"]),
        json["user_name"],
        json["user_email"],
        json["user_password"],
      );

  Map<String, dynamic> toJson() => {
        'user_id': user_id.toString(),
        'user_name': user_name,
        'user_email': user_email,
        'user_password': user_password,
      };
}
