import 'package:clothes_app/admin/admin_upload_items.dart';
import 'package:clothes_app/users/authentication/login_screen.dart';
import 'package:clothes_app/users/authentication/signup_screen.dart';
// import 'package:clothes_app/users/authentication/signup_screen.dart';
// import 'package:clothes_app/users/fragments/dashboard_of_fragments.dart';
// import 'package:clothes_app/users/userPreferences/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:clothes_app/users/model/user.dart';
import 'package:logger/logger.dart';

import 'dart:convert';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  var log = Logger();
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var obscureText = true;

  loginAdminNow() async {
    try {
      var res = await http.post(
        Uri.parse(API.adminLogIn),
        body: {
          "admin_email": emailController.text.trim(),
          "admin_password": passwordController.text.trim(),
        },
      );
      if (res.statusCode == 200) {
        var resBodyOfLogin = jsonDecode(res.body);
        if (resBodyOfLogin['success'] == true) {
          //User userInfo = resBodyOfLogin["userData"];
          // var adminData = resBodyOfLogin["adminData"];
          // User userInfo = User(
          //   int.parse(adminData['admin_id']),
          //   adminData['admin_code'],
          //   adminData['admin_name'],
          //   adminData['admin_password'],
          // );

          Fluttertoast.showToast(msg: "Welcome Admin Login Successfully.")
              .then((value) {
            Future.delayed(const Duration(seconds: 2), () {
              Get.to(() => const AdminUploadItemsScreen());
            });
          });
        } else {
          Fluttertoast.showToast(msg: "Something went wrong. Try again.");
        }
      }
    } catch (e) {
      log.d("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 40, right: 40, bottom: 40),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Image(
                      width: 120,
                      height: 120,
                      image: AssetImage('images/monitor.png')),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'ADMIN',
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff404040)),
                  ),

                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      } else if (!value.contains(new RegExp(r'[!@#$&*]'))) {
                        return 'นี้ไม่ใช่รูปแบบของอีเมล';
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                      hintText: "Email",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      } else if (value.contains(new RegExp(r'[!@#$&*]'))) {
                        return 'รหัสผ่านต้องไม่มีอักขระพิเศษ';
                      } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])')
                          .hasMatch(value)) {
                        return 'รหัสผ่านต้องประกอบด้วยตัวเลขและตัวอักษร';
                      }
                      return null;
                    },
                    controller: passwordController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                      hintText: "Password",
                      suffixIcon: IconButton(
                          icon: Icon(obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                              // print(obscureText);
                            });
                          }),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        loginAdminNow();
                      }
                      ;
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(255, 255, 178, 63),
                      ),
                      child: Text(
                        'Admin login',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Lost password?',
                  //   style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w600,
                  //       color: Color(0xff000000)),
                  // ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.to(() => const SignUpScreen());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(colors: [
                                Color(0xff3ab4b3),
                                Color(0xff2544ee),
                                Color(0xffeb45fc),
                              ])),
                          child: Container(
                            alignment: Alignment.center,
                            width: 95,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xff000000)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.to(() => const LoginScreen());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(colors: [
                                Color(0xff3ab4b3),
                                Color(0xff2544ee),
                                Color(0xffeb45fc),
                              ])),
                          child: Container(
                            alignment: Alignment.center,
                            width: 95,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                            child: Text(
                              'Not Admin',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xff000000)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: 100,
                    child: Divider(
                      color: Color(0xff000000),
                      thickness: 1.0,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Don't have an account?",
                  //       style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w400,
                  //           color: Color(0xff404040)),
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     MaterialButton(
                  //       onPressed: () {
                  //         Get.to(() => const SignUpScreen());
                  //       },
                  //       child: Text(
                  //         'Register',
                  //         style: TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.w600,
                  //             color: Color(0xff404040)),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
