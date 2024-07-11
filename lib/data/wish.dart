import 'user.dart';

enum Occasion {
  birthday,
  christmas,
  wedding,
  graduation,
  none,
}

enum Status {
  open,
  selected,
  fulfilled,
  deleted,
}

enum WishVisibility {
  private,
  public,
  group,
}

// User class using enums with lowercase values
class Wish {
  String id;
  User createdBy;
  Occasion occasion;
  Status status;
  WishVisibility visibility;
  String? imageUrl;
  String? description;

  Wish(
      {required this.id,
      required this.createdBy,
      required this.occasion,
      required this.status,
      required this.visibility,
      this.imageUrl,
      this.description});

  factory Wish.fromJson(Map<String, dynamic> json, User createdBy) {
    return Wish(
      id: json['id'],
      createdBy: createdBy,
      imageUrl: json['img'],
      description: json['description'],
      occasion: Occasion.values.firstWhere(
        (e) => e.name == json['occasion'].toLowerCase(),
        orElse: () => Occasion.none,
      ),
      status: Status.values.firstWhere(
        (e) => e.name == json['status'].toLowerCase(),
        orElse: () => Status.open,
      ),
      visibility: WishVisibility.values.firstWhere(
        (e) => e.name == json['visibility'].toLowerCase(),
        orElse: () => WishVisibility.private,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': createdBy.toJson(),
      'occasion': occasion.name,
      'status': status.name,
      'visibility': visibility.name,
      'imageUrl': imageUrl,
      'description': description
    };
  }
}
