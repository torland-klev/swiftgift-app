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
  String title;
  Status status;
  WishVisibility visibility;
  String? url;
  String? description;
  String? img;

  Wish(
      {required this.id,
      required this.createdBy,
      required this.occasion,
      required this.title,
      required this.status,
      required this.visibility,
      this.url,
      this.description,
      this.img});

  factory Wish.fromJson(Map<String, dynamic> json, User createdBy) {
    return Wish(
      id: json['id'],
      createdBy: createdBy,
      url: json['url'],
      img: json['img'],
      title: json['title'],
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
      'url': url,
      'img': img,
      'description': description
    };
  }
}
