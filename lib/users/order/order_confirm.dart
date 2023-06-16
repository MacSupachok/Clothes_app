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
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';

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

  WebViewController controllerTest = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://www.google.co.th'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Simple Example')),
      body: WebViewWidget(controller: controllerTest),
    );
  }
}
