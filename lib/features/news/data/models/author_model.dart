class Author {
  const Author({this.name});

  final String? name;

  factory Author.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    return Author(name: name is String ? name : null);
  }
}
