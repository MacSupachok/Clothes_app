// ignore_for_file: non_constant_identifier_names

class Clothes {
  late int? item_id;
  late String? item_name;
  late double? item_rating;
  late List<String>? item_tags;
  late double? item_price;
  late List<String>? item_size;
  late List<String>? item_color;
  late String? item_desc;
  late String? item_image;

  Clothes({
    this.item_id,
    this.item_name,
    this.item_rating,
    this.item_tags,
    this.item_price,
    this.item_size,
    this.item_color,
    this.item_desc,
    this.item_image,
  });

  factory Clothes.fromJson(Map<String, dynamic> json) => Clothes(
        item_id: int.parse(json['item_id']),
        item_name: json['item_name'],
        item_rating: double.parse(json['item_rating']),
        item_tags: json['item_tags'].toString().split(", "),
        item_price: double.parse(json['item_price']),
        item_size: json['item_size'].toString().split(", "),
        item_color: json['item_color'].toString().split(", "),
        item_desc: json['item_desc'],
        item_image: json['item_image'],
      );
}
