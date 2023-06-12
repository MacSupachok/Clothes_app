// ignore_for_file: prefer_null_aware_operators, non_constant_identifier_names

class Cart {
  int? cart_id;
  int? user_id;
  int? item_id;
  int? quantity;
  String? color;
  String? size;
  String? name;
  double? rating;
  List<String>? tags;
  double? price;
  List<String>? sizes;
  List<String>? colors;
  String? description;
  String? image;

  Cart({
    this.cart_id,
    this.user_id,
    this.item_id,
    this.quantity,
    this.color,
    this.size,
    this.name,
    this.rating,
    this.tags,
    this.price,
    this.sizes,
    this.colors,
    this.description,
    this.image,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        user_id: int.parse(json['user_id']),
        cart_id: int.parse(json['cart_id']),
        item_id: int.parse(json['item_id']),
        quantity: int.parse(json['quantity']),
        color: json['color'],
        size: json['size'],
        name: json['item_name'],
        rating: double.parse(json['item_rating']),
        tags: json['item_tags'].toString().split(', '),
        price: double.parse(json['item_price']),
        sizes: json['item_size'].toString().split(', '),
        colors: json['item_color'].toString().split(', '),
        description: json['item_desc'],
        image: json['item_image'],
      );
}
