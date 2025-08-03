class Courses {
  final int id;
  final String name;
  final int members;
  final String img;
  final int qty;
  final String category;
  final String desc;
  final int exp;
  final double price;

  Courses({
    required this.id,
    required this.name,
    required this.members,
    required this.img,
    required this.qty,
    required this.category,
    required this.desc,
    required this.exp,
    required this.price,
  });

  factory Courses.fromJson(Map<String, dynamic> json) {
    return Courses(
      id: (json['id'] ?? 0),
      name: json['name'].toString() ?? '',
      members: json['members'] ?? 0,
      img: json['img'] ?? '',
      qty: json['qty'] ?? 0,
      category: json['category'] ?? '',
      desc: json['desc'] ?? '',
      exp: json['exp'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      "img": img,
      "qty": qty,
      'category': category,
      "desc": desc,
      "exp": exp,
      "price": price,
    };
  }
}
