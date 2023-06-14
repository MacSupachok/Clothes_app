// ignore_for_file: non_constant_identifier_names

class Order {
  int? order_id;
  int? user_id;
  String? selectedItems;
  String? deliverySystem;
  String? paymentSystem;
  String? note;
  double? totalAmount;
  String? image;
  String? status;
  DateTime? dateTime;
  String? shipmentAddress;
  String? phoneNumber;

  Order({
    this.order_id,
    this.user_id,
    this.selectedItems,
    this.deliverySystem,
    this.paymentSystem,
    this.note,
    this.totalAmount,
    this.image,
    this.status,
    this.dateTime,
    this.shipmentAddress,
    this.phoneNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        order_id: int.parse(json["order_id"]),
        user_id: int.parse(json["user_id"]),
        selectedItems: json["selected_item"],
        deliverySystem: json["delivery_system"],
        paymentSystem: json["payment_system"],
        note: json["note"],
        totalAmount: double.parse(json["total_amount"]),
        image: json["image"],
        status: json["status"],
        dateTime: DateTime.parse(json["date_time"]),
        shipmentAddress: json["ship_add"],
        phoneNumber: json["phone_number"],
      );

  Map<String, dynamic> toJson(String imageSelectedBase64) => {
        "order_id": order_id.toString(),
        "user_id": user_id.toString(),
        "selectedItems": selectedItems,
        "deliverySystem": deliverySystem,
        "paymentSystem": paymentSystem,
        "note": note,
        "totalAmount": totalAmount!.toStringAsFixed(2),
        "image": image,
        "status": status,
        "shipmentAddress": shipmentAddress,
        "phoneNumber": phoneNumber,
        "imageFile": imageSelectedBase64,
      };
}
