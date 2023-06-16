// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:clothes_app/users/model/order.dart';
import 'package:clothes_app/users/order/history_screen.dart';
import 'package:clothes_app/users/userPreferences/current_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../order/order_details.dart';

class OrderFragmentScreen extends StatelessWidget {
  final currentOnlineUser = Get.put(CurrentUser());

  var log = Logger();

  OrderFragmentScreen({super.key});

  Future<List<Order>> getCurrentUserOrdersList() async {
    List<Order> ordersListOfCurrentUser = [];

    try {
      var res = await http.post(Uri.parse(API.readOrder), body: {
        "user_id": currentOnlineUser.user.user_id.toString(),
      });

      if (res.statusCode == 200) {
        var responseBodyOfCurrentUserOrdersList = jsonDecode(res.body);

        if (responseBodyOfCurrentUserOrdersList['success'] == true) {
          for (var eachCurrentUserOrderData
              in (responseBodyOfCurrentUserOrdersList['orderData'] as List)) {
            ordersListOfCurrentUser
                .add(Order.fromJson(eachCurrentUserOrderData));
          }
        }
      } else {
        Fluttertoast.showToast(msg: "Status Code is not 200");
      }
    } catch (errorMsg) {
      log.d(errorMsg);
      Fluttertoast.showToast(msg: "Error:: $errorMsg");
    }

    return ordersListOfCurrentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Order image       //history image
          //myOrder title     //history title
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //order icon image
                // my orders
                Column(
                  children: [
                    Image.asset(
                      "images/orders_icon.png",
                      width: 140,
                    ),
                    Text(
                      "My Orders",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                //history icon image
                // history
                GestureDetector(
                  onTap: () {
                    //send user to orders history screen
                    Get.to(() => HistoryScreen());
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "images/history_icon.png",
                          width: 45,
                        ),
                        Text(
                          "History",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 10, 10, 10),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          //some info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Here are your successfully placed orders.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          //displaying the user orderList
          Expanded(
            child: displayOrdersList(context),
          ),
        ],
      ),
    );
  }

  Widget displayOrdersList(context) {
    return FutureBuilder(
      future: getCurrentUserOrdersList(),
      builder: (context, AsyncSnapshot<List<Order>> dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Connection Waiting...",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if (dataSnapshot.data == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "No orders found yet...",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if (dataSnapshot.data!.isNotEmpty) {
          List<Order> orderList = dataSnapshot.data!;

          return ListView.separated(
            padding: EdgeInsets.all(16),
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                thickness: 1,
              );
            },
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              Order eachOrderData = orderList[index];

              return Card(
                color: Colors.white24,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: ListTile(
                    onTap: () {
                      Get.to(() => OrderDetailsScreen(
                            clickedOrderInfo: eachOrderData,
                          ));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID # ${eachOrderData.order_id}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Amount: ${eachOrderData.totalAmount} THB",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //date
                        //time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //date
                            Text(
                              DateFormat("dd MMMM, yyyy")
                                  .format(eachOrderData.dateTime!),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 4),

                            //time
                            Text(
                              DateFormat("hh:mm a")
                                  .format(eachOrderData.dateTime!),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 6),

                        Icon(
                          Icons.navigate_next,
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Nothing to show...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Center(
                //   child: CircularProgressIndicator(),
                // ),
              ],
            ),
          );
        }
      },
    );
  }
}
