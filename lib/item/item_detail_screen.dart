import 'dart:convert';

import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/controller/item_details_controller.dart';
import 'package:clothes_app/users/cart/cart_list_screen.dart';
import 'package:clothes_app/users/model/clothes.dart';
import 'package:clothes_app/users/userPreferences/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class ItemDetailScreen extends StatefulWidget {
  // const ItemDetailScreen({super.key});

  final Clothes? itemInfo;

  const ItemDetailScreen({super.key, this.itemInfo});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final itemDetailsController = Get.put(ItemDetailController());

  final currentOnlineuser = Get.put(CurrentUser());

  var log = Logger();

  addItemToCart() async {
    try {
      var res = await http.post(
        Uri.parse(API.addToCart),
        body: {
          "user_id": currentOnlineuser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),
          "quantity": itemDetailsController.quantity.toString(),
          "color": widget.itemInfo!.item_color![itemDetailsController.color],
          "size": widget.itemInfo!.item_size![itemDetailsController.size],
        },
      );

      if (res.statusCode == 200) {
        var resBodyOfAddCart = jsonDecode(res.body);
        if (resBodyOfAddCart['success'] == true) {
          Fluttertoast.showToast(msg: "Add to cart successfully.");
        } else {
          Fluttertoast.showToast(msg: "Something went wrong. Try again.");
        }
      }
    } catch (e) {
      log.d(e);
    }
  }

  checkFavoriteList() async {
    try {
      var res = await http.post(
        Uri.parse(API.checkFavorite),
        body: {
          "user_id": currentOnlineuser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var resBodyOfValidateFavorite = jsonDecode(res.body);
        if (resBodyOfValidateFavorite['favoriteFound'] == true) {
          itemDetailsController.setIsFavorite(true);
        } else {
          itemDetailsController.setIsFavorite(false);
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      log.d(e);
    }
  }

  addItemToFavoriteList() async {
    try {
      var res = await http.post(
        Uri.parse(API.addFavorite),
        body: {
          "user_id": currentOnlineuser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),
        },
      );

      if (res.statusCode ==
          200) //from flutter app the connection with api to server - success
      {
        var resBodyOfAddFavorite = jsonDecode(res.body);
        if (resBodyOfAddFavorite['success'] == true) {
          Fluttertoast.showToast(
              msg: "item saved to your Favorite List Successfully.");

          checkFavoriteList();
        } else {
          Fluttertoast.showToast(msg: "Item not saved to your Favorite List.");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      log.d(e);
    }
  }

  deleteItemFromFavoriteList() async {
    try {
      var res = await http.post(
        Uri.parse(API.deleteFavorite),
        body: {
          "user_id": currentOnlineuser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),
        },
      );

      if (res.statusCode ==
          200) //from flutter app the connection with api to server - success
      {
        var resBodyOfDeleteFavorite = jsonDecode(res.body);
        if (resBodyOfDeleteFavorite['success'] == true) {
          Fluttertoast.showToast(msg: "item Deleted from your Favorite List.");

          checkFavoriteList();
        } else {
          Fluttertoast.showToast(
              msg: "item NOT Deleted from your Favorite List.");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      log.d(e);
    }
  }

  @override
  void initState() {
    super.initState();

    checkFavoriteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            //item image
            FadeInImage(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              placeholder: const AssetImage("images/loading.gif"),
              image: NetworkImage(
                widget.itemInfo!.item_image!,
              ),
              imageErrorBuilder: (context, error, stackTraceError) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                  ),
                );
              },
            ),

            //item information
            Align(
              alignment: Alignment.bottomCenter,
              child: itemInfoWidget(),
            ),

            //3 btn -favorite -shoppingcart -back
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    //back
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 255, 178, 63),
                      ),
                    ),

                    const Spacer(),
                    //favorite
                    Obx(
                      () => IconButton(
                        onPressed: () {
                          if (itemDetailsController.isFavorite) {
                            //delete item from favorite
                            deleteItemFromFavoriteList();
                          } else {
                            //save item to user favorite
                            addItemToFavoriteList();
                          }
                        },
                        icon: Icon(
                          itemDetailsController.isFavorite
                              ? Icons.bookmark
                              : Icons.bookmark_border_outlined,
                          color: Color.fromARGB(255, 255, 178, 63),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Go to cart', // used by assistive technologies
          onPressed: () {
            Get.to(() => const CartListScreen());
          },
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ));
  }

  itemInfoWidget() {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.6,
      width: MediaQuery.of(Get.context!).size.width,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -3),
            blurRadius: 6,
            color: Color.fromARGB(255, 179, 179, 179),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Center(
              child: Container(
                height: 8,
                width: 140,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 178, 63),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),

            //name
            Text(
              widget.itemInfo!.item_name!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            //rating + rating num
            //tags
            //price
            //item counter
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //rating + rating num
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: widget.itemInfo!.item_rating!,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, c) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (updateRating) {},
                            ignoreGestures: true,
                            unratedColor: Colors.grey,
                            itemSize: 20,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "   (${widget.itemInfo!.item_rating!})",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      //tags

                      Text(
                        widget.itemInfo!.item_tags!
                            .toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ""),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      //price
                      Text(
                        "${NumberFormat('#,##0').format(widget.itemInfo!.item_price)} THB",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                //item counter
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // + btn
                      IconButton(
                        onPressed: () {
                          itemDetailsController.setQuantityItem(
                              itemDetailsController.quantity + 1);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        itemDetailsController.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // - btn
                      IconButton(
                        onPressed: () {
                          if (itemDetailsController.quantity - 1 >= 1) {
                            itemDetailsController.setQuantityItem(
                                itemDetailsController.quantity - 1);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Quantity must be 1 or greater than 1");
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //size
            const Text(
              "Size:",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              runSpacing: 8,
              spacing: 8,
              children:
                  List.generate(widget.itemInfo!.item_size!.length, (index) {
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      itemDetailsController.setSizeItem(index);
                    },
                    child: Container(
                      height: 35,
                      width: 60,
                      decoration: BoxDecoration(
                        color: itemDetailsController.size == index
                            ? Color.fromARGB(255, 255, 178, 63).withOpacity(1)
                            : Colors.black,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.itemInfo!.item_size![index]
                            .replaceAll("[", "")
                            .replaceAll("]", ""),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            //colors
            const Text(
              "Colors:",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children:
                  List.generate(widget.itemInfo!.item_color!.length, (index) {
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      itemDetailsController.setColorItem(index);
                    },
                    child: Container(
                      height: 35,
                      width: 60,
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //   width: 2,
                        //   color: itemDetailsController.color == index
                        //       ? Colors.transparent
                        //       : Colors.grey,
                        // ),
                        color: itemDetailsController.color == index
                            ? Color.fromARGB(255, 255, 178, 63).withOpacity(1)
                            : Colors.black,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.itemInfo!.item_color![index]
                            .replaceAll("[", "")
                            .replaceAll("]", ""),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            //description
            const Text(
              "Description:",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.itemInfo!.item_desc!,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            //add to cart
            Material(
              elevation: 4,
              color: Color.fromARGB(255, 255, 178, 63),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () {
                  addItemToCart();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
