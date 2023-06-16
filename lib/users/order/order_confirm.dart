// ignore_for_file: depend_on_referenced_packages, must_be_immutable, deprecated_member_use, unused_element

import 'dart:convert';
import 'dart:typed_data';

import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/model/order.dart';
import 'package:clothes_app/users/userPreferences/current_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../fragments/dashboard_of_fragments.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<int>? selectedCartIDs;
  final List<Map<String, dynamic>>? selectedCartListItemsInfo;
  final double? totalAmount;
  final String? deliverySystem;
  final String? paymentSystem;
  final String? phoneNumber;
  final String? shipmentAddress;
  final String? note;

  OrderConfirmationScreen({
    super.key,
    this.selectedCartIDs,
    this.selectedCartListItemsInfo,
    this.totalAmount,
    this.deliverySystem,
    this.paymentSystem,
    this.phoneNumber,
    this.shipmentAddress,
    this.note,
  });

  final RxList<int> _imageSelectedByte = <int>[].obs;
  Uint8List get imageSelectedByte => Uint8List.fromList(_imageSelectedByte);

  final RxString _imageSelectedName = "".obs;
  String get imageSelectedName => _imageSelectedName.value;

  final ImagePicker _picker = ImagePicker();

  var log = Logger();

  CurrentUser currentUser = Get.put(CurrentUser());

  setSelectedImage(Uint8List selectedImage) {
    _imageSelectedByte.value = selectedImage;
  }

  setSelectedImageName(String selectedImageName) {
    _imageSelectedName.value = selectedImageName;
  }

  chooseImageFromGallery() async {
    final pickedImageXFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImageXFile != null) {
      final bytesOfImage = await pickedImageXFile.readAsBytes();

      setSelectedImage(bytesOfImage);
      setSelectedImageName(path.basename(pickedImageXFile.path));
    }
  }

  saveNewOrderInfo() async {
    String selectedItemsString = selectedCartListItemsInfo!
        .map((eachSelectedItem) => jsonEncode(eachSelectedItem))
        .toList()
        .join("||");

    Order order = Order(
      order_id: 1,
      user_id: currentUser.user.user_id,
      selectedItems: selectedItemsString,
      deliverySystem: deliverySystem,
      paymentSystem: paymentSystem,
      note: note,
      totalAmount: totalAmount,
      image: "${DateTime.now().millisecondsSinceEpoch}-$imageSelectedName",
      status: "new",
      dateTime: DateTime.now(),
      shipmentAddress: shipmentAddress,
      phoneNumber: phoneNumber,
    );

    try {
      var res = await http.post(
        Uri.parse(API.addOrder),
        body: order.toJson(base64Encode(imageSelectedByte)),
      );

      if (res.statusCode == 200) {
        log.d(res.statusCode);
        var responseBodyOfAddNewOrder = jsonDecode(res.body);

        if (responseBodyOfAddNewOrder["success"] == true) {
          //delete selected items from user cart
          for (var eachSelectedItemCartID in selectedCartIDs!) {
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

  deleteSelectedItemsFromUserCartList(int cartID) async {
    try {
      var res = await http.post(Uri.parse(API.deleteCart), body: {
        "cart_id": cartID.toString(),
      });

      if (res.statusCode == 200) {
        var responseBodyFromDeleteCart = jsonDecode(res.body);

        if (responseBodyFromDeleteCart["success"] == true) {
          Fluttertoast.showToast(
                  msg: "your new order has been placed Successfully.")
              .then((value) {
            Future.delayed(const Duration(seconds: 2), () {
              Get.to(() => DashboardOfFragments());
            });
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Error, Status Code is not 200");
      }
    } catch (errorMessage) {
      log.d(errorMessage);

      Fluttertoast.showToast(msg: "Error: $errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //image
            Image.asset(
              "images/payment.png",
              width: 250,
            ),
            const SizedBox(height: 4),

            //title
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Please Attach Transaction \nProof / Screenshot",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            //selection image btn
            Material(
              elevation: 8,
              color: Colors.purpleAccent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  chooseImageFromGallery();
                },
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: Text(
                    "Select Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Obx(
              () => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: imageSelectedByte.isNotEmpty
                    ? Image.memory(imageSelectedByte, fit: BoxFit.contain)
                    : const Placeholder(color: Colors.white60),
              ),
            ),

            const SizedBox(height: 16),

            //confirm and proced
            Obx(
              () => Material(
                elevation: 8,
                color: imageSelectedByte.isNotEmpty
                    ? Colors.purpleAccent
                    : Colors.grey,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    if (imageSelectedByte.isNotEmpty) {
                      //save order info
                      saveNewOrderInfo();
                      //saveNewOrderInfo();
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Please attach the transaction proof / screenshot.");
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    child: Text(
                      "Confirmed & Proceed",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
