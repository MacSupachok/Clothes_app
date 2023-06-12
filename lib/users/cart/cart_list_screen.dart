import 'dart:convert';
// import 'dart:ffi';

import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/cart/cart_list_controller.dart';
import 'package:clothes_app/users/model/cart.dart';
import 'package:clothes_app/users/model/clothes.dart';
import 'package:clothes_app/users/userPreferences/current_user.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../../item/item_detail_screen.dart';

class CartListScreen extends StatefulWidget {
  const CartListScreen({super.key});

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  var log = Logger();
  final currentOnlineUser = Get.put(CurrentUser());
  final cartListController = Get.put(CartListController());

  getCurrentCartList() async {
    List<Cart> cartListcurrentUser = [];

    try {
      var res = await http.post(
        Uri.parse(API.getCartList),
        body: {
          "currentOnlineUserID": currentOnlineUser.user.user_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var responseBodyCartItems = res.body;

        if (responseBodyCartItems.isNotEmpty) {
          var json = jsonDecode(responseBodyCartItems);

          if (json['success'] == true) {
            for (var eachCartItemData
                in (json['currentUserCartData'] as List)) {
              cartListcurrentUser.add(Cart.fromJson(eachCartItemData));
            }
          } else {
            Fluttertoast.showToast(
                msg: "Error Occurred while executing query.");
          }
        } else {
          Fluttertoast.showToast(msg: "Empty items in your cart.");
        }
      } else {
        Fluttertoast.showToast(msg: "Status code not 200");
      }
      cartListController.setList(cartListcurrentUser);
    } catch (e) {
      //Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log.d(e);
    }

    calculateTotalAmount();
  }

  calculateTotalAmount() {
    cartListController.setTotal(0);

    if (cartListController.selectedItemList.isNotEmpty) {
      for (var itemInCart in cartListController.cartList) {
        if (cartListController.selectedItemList.contains(itemInCart.item_id)) {
          double eachItemTotalAmount = (itemInCart.price!) *
              (double.parse(itemInCart.quantity.toString()));

          cartListController
              .setTotal(cartListController.total + eachItemTotalAmount);
        }
      }
    }
  }

  deleteSelectedItemsFromUserCartList(int cartID) async {
    try {
      var res = await http.post(
        Uri.parse(API.deleteCart),
        body: {
          "cart_id": cartID.toString(),
        },
      );
      if (res.statusCode == 200) {
        var resFromDeleteCart = jsonDecode(res.body);
        if (resFromDeleteCart['success'] == true) {
          getCurrentCartList();
        }
      } else {
        Fluttertoast.showToast(msg: "Error, Status is not 200");
      }
    } catch (e) {
      log.d(e);
    }
  }

  updateQuantityCart(int cartId, int newQuantity) async {
    try {
      var res = await http.post(
        Uri.parse(API.updateCart),
        body: {
          "cart_id": cartId.toString(),
          "quantity": newQuantity.toString(),
        },
      );
      if (res.statusCode == 200) {
        var resUpdateCart = jsonDecode(res.body);
        if (resUpdateCart['success'] == true) {
          Fluttertoast.showToast(msg: "Quantity is updated.");
          getCurrentCartList();
        }
      } else {
        Fluttertoast.showToast(msg: "Error, Status is not 200");
      }
    } catch (e) {
      log.d(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentCartList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "My Cart",
        ),
        actions: [
          //select all items
          Obx(
            () => IconButton(
              onPressed: () {
                cartListController.setIsSelectedAllItem();
                cartListController.clearAllSelectedItem();

                if (cartListController.isSelectedAll) {
                  for (var eachItem in cartListController.cartList) {
                    cartListController.addSelectedItem(eachItem.cart_id!);
                  }
                }
                calculateTotalAmount();
              },
              icon: Icon(
                cartListController.isSelectedAll
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: cartListController.isSelectedAll
                    ? Colors.white
                    : Colors.grey,
              ),
            ),
          ),

          //delete all select all items
          GetBuilder(
              init: CartListController(),
              builder: (c) {
                if (cartListController.selectedItemList.isNotEmpty) {
                  return IconButton(
                    onPressed: () async {
                      var responseFromDialogBox = await Get.dialog(
                        AlertDialog(
                          backgroundColor: Colors.grey,
                          title: const Text("Delete"),
                          content:
                              const Text("Are you sure for delete this item?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text(
                                "No",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back(result: "OKdel");
                              },
                              child: const Text(
                                "Yes",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (responseFromDialogBox == "OKdel") {
                        for (var selectedItemUserCartId
                            in cartListController.selectedItemList) {
                          deleteSelectedItemsFromUserCartList(
                              selectedItemUserCartId);
                        }
                      }
                      calculateTotalAmount();
                    },
                    icon: const Icon(
                      Icons.delete_sweep,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                  );
                } else {
                  return Container();
                }
              }),
        ],
      ),
      body: Obx(
        () => cartListController.cartList.isNotEmpty
            ? ListView.builder(
                itemCount: cartListController.cartList.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  Cart cartModel = cartListController.cartList[index];

                  Clothes clothesModel = Clothes(
                      item_id: cartModel.item_id,
                      item_color: cartModel.colors,
                      item_image: cartModel.image,
                      item_name: cartModel.name,
                      item_price: cartModel.price,
                      item_rating: cartModel.rating,
                      item_size: cartModel.sizes,
                      item_desc: cartModel.description,
                      item_tags: cartModel.tags);

                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        //check box
                        GetBuilder(
                          init: CartListController(),
                          builder: (c) {
                            return IconButton(
                              onPressed: () {
                                if (cartListController.selectedItemList
                                    .contains(cartModel.cart_id)) {
                                  cartListController
                                      .deleteSelectedItem(cartModel.cart_id!);
                                } else {
                                  cartListController
                                      .addSelectedItem(cartModel.cart_id!);
                                }

                                calculateTotalAmount();
                              },
                              icon: Icon(
                                  cartListController.selectedItemList
                                          .contains(cartModel.cart_id)
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: cartListController.isSelectedAll
                                      ? Colors.white
                                      : Colors.grey),
                            );
                          },
                        ),
                        //name
                        //color size + price
                        //+ -
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() =>
                                  ItemDetailScreen(itemInfo: clothesModel));
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                0,
                                index == 0 ? 16 : 8,
                                16,
                                index == cartListController.cartList.length - 1
                                    ? 16
                                    : 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black,
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 6,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //name
                                          Text(
                                            clothesModel.item_name.toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          //color size + price
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Color: ${cartModel.color!.replaceAll("[", "").replaceAll("]", "")}"
                                                  "\n"
                                                  "Size: ${cartModel.size!.replaceAll("[", "").replaceAll("]", "")}",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                  ),
                                                ),
                                              ),

                                              //price
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12, right: 12.0),
                                                child: Text(
                                                  "${clothesModel.item_price.toString()} THB",
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.purpleAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          //+ -
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              //icon -
                                              IconButton(
                                                onPressed: () {
                                                  if (cartModel.quantity! - 1 >=
                                                      1) {
                                                    updateQuantityCart(
                                                      cartModel.cart_id!,
                                                      cartModel.quantity! - 1,
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.grey,
                                                  size: 30,
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              Text(
                                                cartModel.quantity.toString(),
                                                style: const TextStyle(
                                                    color: Colors.purpleAccent,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              const SizedBox(width: 10),
                                              //icon +
                                              IconButton(
                                                onPressed: () {
                                                  updateQuantityCart(
                                                    cartModel.cart_id!,
                                                    cartModel.quantity! + 1,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.grey,
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  //image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(22),
                                      bottomRight: Radius.circular(22),
                                    ),
                                    child: FadeInImage(
                                      height: 185,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      placeholder: const AssetImage(
                                          "images/loading.gif"),
                                      image: NetworkImage(
                                        cartModel.image!,
                                      ),
                                      imageErrorBuilder:
                                          (context, error, stackTraceError) {
                                        return const Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Center(
                child: Text("cart is empty."),
              ),
      ),
      bottomNavigationBar: GetBuilder(
          init: CartListController(),
          builder: (c) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -3),
                    color: Colors.white24,
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  //total amount
                  const Text(
                    "Total Amount : ",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 4),

                  Obx(
                    () => Text(
                      "${cartListController.total.toStringAsFixed(2)} THB",
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  //ordernow btn
                  Material(
                    color: cartListController.selectedItemList.isNotEmpty
                        ? Colors.purpleAccent
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          "Order Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
