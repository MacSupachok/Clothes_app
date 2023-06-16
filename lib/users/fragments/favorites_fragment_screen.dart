// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/model/clothes.dart';
import 'package:clothes_app/users/model/favorite.dart';
import 'package:clothes_app/users/userPreferences/current_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

import '../../item/item_detail_screen.dart';

class FavoritesFragmentScreen extends StatelessWidget {
  FavoritesFragmentScreen({super.key});

  var log = Logger();

  final currentOnlineuser = Get.put(CurrentUser());

  Future<List<Favorite>> getFavoriteList() async {
    List<Favorite> favoriteList = [];

    try {
      var res = await http.post(
        Uri.parse(API.readFavorite),
        body: {"user_id": currentOnlineuser.user.user_id.toString()},
      );

      if (res.statusCode == 200) {
        var responseBodyFavorite = res.body;

        if (responseBodyFavorite.isNotEmpty) {
          var json = jsonDecode(responseBodyFavorite);

          if (json['success'] == true) {
            for (var eachFavoriteItemData in (json['favoritetData'] as List)) {
              favoriteList.add(Favorite.fromJson(eachFavoriteItemData));
            }
          } else {
            Fluttertoast.showToast(
                msg: "Error Occurred while executing query.");
          }
        } else {
          Fluttertoast.showToast(msg: "There are no item in your favorite");
        }
      } else {
        Fluttertoast.showToast(msg: "Status code not 200");
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log.d(e);
    }

    return favoriteList;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 8, 8),
            child: Text(
              "My Favorite List",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 8, 8),
            child: Text(
              "Order these best clothes for yourself now.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          const SizedBox(height: 24),
          //display

          favoriteItemWidget(context),
        ],
      ),
    );
  }

  favoriteItemWidget(context) {
    return FutureBuilder(
      future: getFavoriteList(),
      builder: (context, AsyncSnapshot<List<Favorite>> dataSnapShot) {
        if (dataSnapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (dataSnapShot.data == null) {
          return const Center(
            child: Text(
              "No favorite item found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        if (dataSnapShot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: dataSnapShot.data!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              Favorite eachFavoriteItemRecord = dataSnapShot.data![index];
              Clothes clickClothesItem = Clothes(
                item_id: eachFavoriteItemRecord.item_id,
                item_color: eachFavoriteItemRecord.colors,
                item_image: eachFavoriteItemRecord.image,
                item_name: eachFavoriteItemRecord.name,
                item_price: eachFavoriteItemRecord.price,
                item_rating: eachFavoriteItemRecord.rating,
                item_size: eachFavoriteItemRecord.sizes,
                item_desc: eachFavoriteItemRecord.description,
                item_tags: eachFavoriteItemRecord.tags,
              );
              return GestureDetector(
                onTap: () {
                  Get.to(() => ItemDetailScreen(itemInfo: clickClothesItem));
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    16,
                    index == 0 ? 16 : 8,
                    16,
                    index == dataSnapShot.data!.length - 1 ? 16 : 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color.fromARGB(255, 51, 51, 51),
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
                      //name price tags
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //name and price
                              Row(
                                children: [
                                  //name
                                  Expanded(
                                    child: Text(
                                      eachFavoriteItemRecord.name!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  //price
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12),
                                    child: Text(
                                      "${NumberFormat('#,##0').format(eachFavoriteItemRecord.price)} THB ",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              //tags
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "Tags: \n ${eachFavoriteItemRecord.tags.toString().replaceAll("[", "").replaceAll("]", "")}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      //item image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: FadeInImage(
                          height: 130,
                          width: 130,
                          fit: BoxFit.cover,
                          placeholder: const AssetImage("images/loading.gif"),
                          image: NetworkImage(
                            eachFavoriteItemRecord.image!,
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
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text("Empty, No Data."),
          );
        }
      },
    );
  }
}
