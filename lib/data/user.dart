class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;

  User(this.id, this.firstName, this.lastName, this.email);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  String displayName() {
    return "${firstName ?? ""} ${lastName ?? ""}";
  }
}
