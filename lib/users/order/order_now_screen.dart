// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:convert';

import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/controller/order_now_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// import 'order_confirm.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../model/order.dart';
import '../userPreferences/current_user.dart';

class OrderNowScreen extends StatelessWidget {
  var log = Logger();
  final List<Map<String, dynamic>> selectedCartListItemsInfo;
  final double totalAmount;
  final List<int> selectedCartId;

  OrderNowController orderNowController = Get.put(OrderNowController());
  List<String> deliverySystemNamesList = ["Ems", "Flash", "Kerry"];
  List<String> paymentSystemNamesList = ["PrompPay", "SCB", "KBank"];

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController shipmentAddressController = TextEditingController();
  TextEditingController noteToSellerController = TextEditingController();

  CurrentUser currentUser = Get.put(CurrentUser());

  OrderNowScreen({
    super.key,
    required this.selectedCartListItemsInfo,
    required this.totalAmount,
    required this.selectedCartId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Order Now"),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          //display selected items from cart list
          displaySelectedItemsFromUserCart(),

          const SizedBox(height: 30),

          //delivery system
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Delivery System:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: deliverySystemNamesList.map((deliverySystemName) {
                return Obx(() => RadioListTile<String>(
                      tileColor: Colors.white24,
                      dense: true,
                      activeColor: Colors.purpleAccent,
                      title: Text(
                        deliverySystemName,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white38),
                      ),
                      value: deliverySystemName,
                      groupValue: orderNowController.deliverySys,
                      onChanged: (newDeliverySystemValue) {
                        orderNowController
                            .setDeliverySystem(newDeliverySystemValue!);
                      },
                    ));
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          //phone number
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Phone Number:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white54),
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: 'any Contact Number..',
                hintStyle: const TextStyle(
                  color: Colors.white24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white24,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          //shipment address
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Shipment Address:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white54),
              controller: shipmentAddressController,
              decoration: InputDecoration(
                hintText: 'your Shipment Address..',
                hintStyle: const TextStyle(
                  color: Colors.white24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white24,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          //note to seller
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Note to Seller:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white54),
              controller: noteToSellerController,
              decoration: InputDecoration(
                hintText: 'Any note you want to write to seller..',
                hintStyle: const TextStyle(
                  color: Colors.white24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white24,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          //pay amount now btn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.purpleAccent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () async {
                  if (phoneNumberController.text.isNotEmpty &&
                      shipmentAddressController.text.isNotEmpty) {
                    String url =
                        "http://192.168.1.178/api_clothes_store/chill_pay/payment.php";
                    var urllaunchable = await canLaunch(url);
                    if (urllaunchable) {
                      await launch(url);
                    } else {
                      log.d("URL can't be launched.");
                    }
                  } else {
                    Fluttertoast.showToast(msg: "Please complete the form.");
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${totalAmount.toStringAsFixed(2)} THB",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Pay Amount Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  displaySelectedItemsFromUserCart() {
    return Column(
      children: List.generate(selectedCartListItemsInfo.length, (index) {
        Map<String, dynamic> eachSelectedItem =
            selectedCartListItemsInfo[index];

        return Container(
          margin: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 16 : 8,
            16,
            index == selectedCartListItemsInfo.length - 1 ? 16 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white24,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 6,
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            children: [
              //image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: FadeInImage(
                  height: 150,
                  width: 130,
                  fit: BoxFit.cover,
                  placeholder: const AssetImage("images/placeholder.png"),
                  image: NetworkImage(
                    eachSelectedItem["image"].toString(),
                  ),
                  imageErrorBuilder: (context, error, stackTraceError) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                      ),
                    );
                  },
                ),
              ),

              //name
              //size
              //price
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //name
                      Text(
                        eachSelectedItem["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //size + color
                      Text(
                        eachSelectedItem["size"]
                                .replaceAll("[", "")
                                .replaceAll("]", "") +
                            "\n" +
                            eachSelectedItem["color"]
                                .replaceAll("[", "")
                                .replaceAll("]", ""),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //price
                      Text(
                        "${eachSelectedItem["totalAmount"]} THB",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${eachSelectedItem["price"]} x ${eachSelectedItem["quantity"]} = ${eachSelectedItem["totalAmount"]}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //quantity
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Q: ${eachSelectedItem["quantity"]}",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  deleteSelectedItemsFromUserCartList(int cartID) async {
    try {
      var res = await http.post(Uri.parse(API.deleteCart), body: {
        "cart_id": cartID.toString(),
      });

      if (res.statusCode == 200) {
        var responseBodyFromDeleteCart = jsonDecode(res.body);

        if (responseBodyFromDeleteCart["success"] == true) {
          // Fluttertoast.showToast(
          //         msg: "your new order has been placed Successfully.")
          //     .then((value) {
          //   Future.delayed(const Duration(seconds: 2), () {
          //     Get.to(() => DashboardOfFragments());
          //   });
          // });
        }
      } else {
        Fluttertoast.showToast(msg: "Error, Status Code is not 200");
      }
    } catch (errorMessage) {
      log.d(errorMessage);

      Fluttertoast.showToast(msg: "Error: $errorMessage");
    }
  }

  saveNewOrderInfo() async {
    String selectedItemsString = selectedCartListItemsInfo
        .map((eachSelectedItem) => jsonEncode(eachSelectedItem))
        .toList()
        .join("||");

    Order order = Order(
      order_id: 1,
      user_id: currentUser.user.user_id,
      selectedItems: selectedItemsString,
      deliverySystem: orderNowController.deliverySys,
      note: noteToSellerController.value.toString(),
      totalAmount: totalAmount,
      status: "new",
      dateTime: DateTime.now(),
      shipmentAddress: shipmentAddressController.value.toString(),
      phoneNumber: phoneNumberController.value.toString(),
    );

    try {
      var res = await http.post(
        Uri.parse(API.addOrder),
        body: order,
      );

      if (res.statusCode == 200) {
        log.d(res.statusCode);
        var responseBodyOfAddNewOrder = jsonDecode(res.body);

        if (responseBodyOfAddNewOrder["success"] == true) {
          //delete selected items from user cart
          for (var eachSelectedItemCartID in selectedCartId) {
            deleteSelectedItemsFromUserCartList(eachSelectedItemCartID);
          }
        } else {
          Fluttertoast.showToast(
              msg: "Error:: \nyour new order do not placed.");
        }
      } else {
        log.d(res.statusCode);
      }
    } catch (erroeMsg) {
      log.d(erroeMsg);
      Fluttertoast.showToast(msg: "Error: $erroeMsg");
    }
  }
}
