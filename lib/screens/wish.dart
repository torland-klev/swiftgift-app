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
  String name;
  Occasion occasion;
  Status status;
  WishVisibility visibility;

  Wish({
    required this.id,
    required this.name,
    required this.occasion,
    required this.status,
    required this.visibility,
  });

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['id'],
      name: json['name'],
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
      'name': name,
      'occasion': occasion.name,
      'status': status.name,
      'visibility': visibility.name,
    };
  }
}
