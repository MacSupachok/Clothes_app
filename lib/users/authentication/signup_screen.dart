import 'dart:async';
import 'dart:convert';

import 'package:clothes_app/admin/admin_login.dart';
import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/authentication/login_screen.dart';
import 'package:clothes_app/users/model/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var log = Logger();
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var obscureText = true;

  validateUserEmail() async {
    try {
      var res = await http.post(
        Uri.parse(API.validateEmail),
        body: {
          'user_email': emailController.text.trim(),
        },
      );
      // log.d(Uri.parse(API.validateEmail));
      if (res.statusCode == 200) {
        var resBodyOfValidateEmail = jsonDecode(res.body);
        if (resBodyOfValidateEmail['emailFound'] == true) {
          Fluttertoast.showToast(
              msg: "Email already exist. Try another email.");
        } else {
          //register and save to database
          registerAndSaveUserReccord();
        }
      } else {
        Fluttertoast.showToast(msg: res.statusCode.toString());
      }
    } catch (e) {
      log.d(e);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveUserReccord() async {
    User userModel = User(
      1,
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    try {
      var res = await http.post(
        Uri.parse(API.signUp),
        body: userModel.toJson(),
      );
      if (res.statusCode == 200) {
        var resBodyOfSignUp = jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(
            msg: "Congratulations, you have signed up successfully.",
          ).then((value) {
            Future.delayed(const Duration(seconds: 2), () {
              Get.to(() => const LoginScreen());
            });
          });
        } else {
          Fluttertoast.showToast(msg: "Something went wrong. Try again.");
        }
      }
    } catch (e) {
      log.d(e);
      Fluttertoast.showToast(msg: e.toString());
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
                  Image(
                      width: 140,
                      height: 140,
                      image: AssetImage('images/register.png')),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff404040)),
                  ),
                  Text(
                    'TO CONTINUE',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff404040)),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      } else if (value.contains(new RegExp(r'[!@#$&*]'))) {
                        return 'รหัสผ่านต้องไม่มีอักขระพิเศษ';
                      }
                      return null;
                    },
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                      hintText: "Username",
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
                      hintText: "email",
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
                              print(obscureText);
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
                        validateUserEmail();
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 70),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(255, 255, 85, 63),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              'Login',
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
                          Get.to(() => const AdminLoginScreen());
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
                              'Admin',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
