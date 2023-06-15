import 'dart:convert';
import 'dart:io';

import 'package:clothes_app/admin/admin_get_all_orders.dart';
// import 'package:clothes_app/admin/admin_login.dart';
import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../users/authentication/login_screen.dart';

class AdminUploadItemsScreen extends StatefulWidget {
  const AdminUploadItemsScreen({super.key});

  @override
  State<AdminUploadItemsScreen> createState() => _AdminUploadItemsScreenState();
}

class _AdminUploadItemsScreenState extends State<AdminUploadItemsScreen> {
  var log = Logger();

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImageXFile;

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizesController = TextEditingController();
  var colorsController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageLink = "";

  uploadImageWithCamera() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.camera);
    Get.back();
    setState(
      () => pickedImageXFile,
    );
  }

  uploadImageFromGallery() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.gallery);
    Get.back();
    setState(
      () => pickedImageXFile,
    );
  }

  showDialogBoxForImagePickingAndCapturing() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.black,
            title: const Text(
              "Select Image",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  uploadImageWithCamera();
                },
                child: const Text(
                  "Capture With Phone Camera",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  uploadImageFromGallery();
                },
                child: const Text(
                  "Select Image From Phone Gallery",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  Widget defalutScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black54,
                Colors.deepPurple,
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Get.to(() => AdminGetAllOrdersScreen());
          },
          child: const Text(
            "New Orders",
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const LoginScreen());
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black54,
              Colors.deepPurple,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate,
                color: Colors.white54,
                size: 200,
              ),

              // button
              Material(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    showDialogBoxForImagePickingAndCapturing();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 28),
                    child: Text(
                      "Add New Item",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //uploaditemfromscreen
  uploadItemImage() async {
    var requestImgurApi = http.MultipartRequest(
        "POST", Uri.parse("https://api.imgur.com/3/image"));

    String imageName = DateTime.now().microsecondsSinceEpoch.toString();
    requestImgurApi.fields['title'] = imageName;
    requestImgurApi.headers['Authorization'] = "Client-ID " "2292cb657a56a84";

    var imageFile = await http.MultipartFile.fromPath(
        'image', pickedImageXFile!.path,
        filename: imageName);

    requestImgurApi.files.add(imageFile);
    var responseFromImgurApi = await requestImgurApi.send();

    var responseDataFromImgurApi = await responseFromImgurApi.stream.toBytes();
    var resultFromImgurApi = String.fromCharCodes(responseDataFromImgurApi);

    Map<String, dynamic> jsonRes = json.decode(resultFromImgurApi);
    imageLink = (jsonRes["data"]["link"]).toString();
    // String deleteHash = (jsonRes["data"]["deletehash"]).toString();

    log.d(resultFromImgurApi);

    saveItemInfoToDatabase();
  }

  saveItemInfoToDatabase() async {
    try {
      List<String> tagsList = tagsController.text.split(',');
      List<String> sizesList = sizesController.text.split(',');
      List<String> colorsList = colorsController.text.split(',');

      var response = await http.post(
        Uri.parse(API.uploadNewItem),
        body: {
          'item_id': 1.toString(),
          'item_name': nameController.text.trim().toString(),
          'item_rating': ratingController.text.trim().toString(),
          'item_tags': tagsList.toString(),
          'item_price': priceController.text.trim().toString(),
          'item_size': sizesList.toString(),
          'item_color': colorsList.toString(),
          'item_desc': descriptionController.text.trim().toString(),
          'item_image': imageLink.toString(),
        },
      );
      if (response.statusCode == 200) {
        var resBodyOfUploadItem = jsonDecode(response.body);

        if (resBodyOfUploadItem['success'] == true) {
          Fluttertoast.showToast(msg: "Uploaded Item Successfully.");
          setState(() {
            pickedImageXFile = null;
            nameController.clear();
            ratingController.clear();
            tagsController.clear();
            sizesController.clear();
            colorsController.clear();
            priceController.clear();
            descriptionController.clear();
          });

          Get.to(() => const AdminUploadItemsScreen());
        } else {
          Fluttertoast.showToast(msg: "Item not upload, Error, Try Again.");
        }
      }
    } catch (e) {
      log.d("Something When Wrong :: $e");
    }
  }

  Widget uploadItemFormScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black54,
                Colors.deepPurple,
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text("Upload Form"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            setState(() {
              pickedImageXFile = null;
              nameController.clear();
              ratingController.clear();
              tagsController.clear();
              sizesController.clear();
              colorsController.clear();
              priceController.clear();
              descriptionController.clear();
            });
            Get.to(() => const AdminUploadItemsScreen());
          },
          icon: const Icon(
            Icons.exit_to_app,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(
                    File(pickedImageXFile!.path),
                  ),
                  fit: BoxFit.cover),
            ),
          ),

          //upload items
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(
                  Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, -3)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
                child: Column(
                  children: [
                    // email, password, login btn
                    Form(
                      key: formKey,
                      child: Column(children: [
                        //item name
                        TextFormField(
                          controller: nameController,
                          validator: (value) =>
                              value == "" ? "Enter item name" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.title,
                              color: Colors.black,
                            ),
                            hintText: "Item name...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item rating
                        TextFormField(
                          controller: ratingController,
                          validator: (value) =>
                              value == "" ? "Enter item rating" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.rate_review,
                              color: Colors.black,
                            ),
                            hintText: "item rating...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item tags
                        TextFormField(
                          controller: tagsController,
                          validator: (value) =>
                              value == "" ? "Enter item tags" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.tag,
                              color: Colors.black,
                            ),
                            hintText: "item tags...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item price
                        TextFormField(
                          controller: priceController,
                          validator: (value) =>
                              value == "" ? "Enter item pice" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.price_change_outlined,
                              color: Colors.black,
                            ),
                            hintText: "item price...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item sizes
                        TextFormField(
                          controller: sizesController,
                          validator: (value) =>
                              value == "" ? "Enter item size" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.picture_in_picture,
                              color: Colors.black,
                            ),
                            hintText: "item size...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item colors
                        TextFormField(
                          controller: colorsController,
                          validator: (value) =>
                              value == "" ? "Enter item color" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.color_lens,
                              color: Colors.black,
                            ),
                            hintText: "item color...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //item description
                        TextFormField(
                          controller: descriptionController,
                          validator: (value) =>
                              value == "" ? "Enter item description" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.price_change_outlined,
                              color: Colors.black,
                            ),
                            hintText: "item description...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // button
                        Material(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                Fluttertoast.showToast(msg: "Uploading...");
                                uploadItemImage();
                              }
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 28),
                              child: Text(
                                "Upload Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pickedImageXFile == null ? defalutScreen() : uploadItemFormScreen();
  }
}
