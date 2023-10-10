import 'dart:io';
import 'package:chat_app/add_image/add_image.dart';
import 'package:chat_app/config/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _authentication = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isSignupScreen = true;
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  File? userPickedImage;

  void pickedImage(File image) {
    userPickedImage = image;
  }

  void _tryValidation() {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      _formKey.currentState?.save();
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: AddImage(pickedImage),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              //배경
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/back.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 90,
                      left: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Welcome',
                            style: const TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: isSignupScreen ? ' to Our Chat!' : ' back',
                                style: const TextStyle(
                                  letterSpacing: 1.0,
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          isSignupScreen ? 'Signup to continue' : 'Signin to continue',
                          style: const TextStyle(
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //텍스트 폼 필드
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: 180,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  padding: const EdgeInsets.all(20.0),
                  height: isSignupScreen ? 280.0 : 250.0,
                  width: MediaQuery.of(context).size.width - 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSignupScreen
                                          ? Palette.textColor1
                                          : Palette.activeColor,
                                    ),
                                  ),
                                  if (isSignupScreen == false)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 55,
                                      color: Palette.primaryColor,
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = true;
                                });
                              },
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text(
                                      'SIGNUP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSignupScreen
                                            ? Palette.activeColor
                                            : Palette.textColor1,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    if (isSignupScreen)
                                      GestureDetector(
                                        onTap: () {
                                          showAlert(context);
                                        },
                                        child: Icon(
                                          Icons.image,
                                          color: isSignupScreen
                                              ? Colors.cyan
                                              : Colors.grey[300],
                                        ),
                                      )
                                  ]),
                                  if (isSignupScreen)
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 3, 40, 0),
                                      height: 2,
                                      width: 55,
                                      color: Palette.primaryColor,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSignupScreen)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: const ValueKey(1),
                                    validator: (value) {
                                      if (value != null &&
                                          (value.isEmpty || value.length < 4)) {
                                        return 'Please enter at least 4 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) {
                                        userName = value;
                                      }
                                    },
                                    onChanged: (value) {
                                      userName = value;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                        color: Palette.iconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: 'User name',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: const ValueKey(2),
                                    validator: (value) {
                                      if (value != null &&
                                          (value.isEmpty || !value.contains('@'))) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) {
                                        userEmail = value;
                                      }
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Palette.iconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: 'email',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    key: const ValueKey(3),
                                    validator: (value) {
                                      if (value != null &&
                                          (value.isEmpty || value.length < 6)) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) {
                                        userPassword = value;
                                      }
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Palette.iconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: 'password',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!isSignupScreen)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: const ValueKey(4),
                                    validator: (value) {
                                      if (value != null &&
                                          (value.isEmpty || !value.contains('@'))) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) {
                                        userEmail = value;
                                      }
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Palette.iconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: 'email',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    key: const ValueKey(5),
                                    validator: (value) {
                                      if (value != null &&
                                          (value.isEmpty || value.length < 6)) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) {
                                        userPassword = value;
                                      }
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Palette.iconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: 'password',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),

              //전송버튼
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSignupScreen ? 430 : 400,
                right: 0,
                left: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        _tryValidation();

                        try {
                          if (isSignupScreen) {
                            if (userPickedImage == null) {
                              setState(() {
                                showSpinner = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please pick your image'),
                                  backgroundColor: Colors.blue,
                                ),
                              );

                              return;
                            }

                            final newUser =
                                await _authentication.createUserWithEmailAndPassword(
                                    email: userEmail, password: userPassword);

                            final refImage = FirebaseStorage.instance
                                .ref()
                                .child('picked_image')
                                .child('${newUser.user!.uid}.png');

                            await refImage.putFile(userPickedImage!);

                            final url = await refImage.getDownloadURL();

                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(newUser.user!.uid)
                                .set({
                              'userName': userName,
                              'email': userEmail,
                              'picked_image': url,
                            });

                            //비동기 방식 메서드에서 context를 쓰기 위해서 추가한다.
                            if (!mounted) return;
                          } else {
                            await _authentication.signInWithEmailAndPassword(
                                email: userEmail, password: userPassword);

                            //비동기 방식 메서드에서 context를 쓰기 위해서 추가한다.
                            if (!mounted) return;
                          }

                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          debugPrint(e.toString());

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please check your email and password'),
                                backgroundColor: Colors.blue,
                              ),
                            );

                            setState(() {
                              showSpinner = false;
                            });
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Palette.primaryColor,
                            ],
                            stops: [
                              0,
                              0.5,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //구글로그인버튼
              if (!isSignupScreen)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  top: isSignupScreen
                      ? MediaQuery.of(context).size.height - 125
                      : MediaQuery.of(context).size.height - 155,
                  right: 0,
                  left: 0,
                  child: Column(
                    children: [
                      Text(isSignupScreen ? 'or Signup with' : 'or Signin with'),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          if (isSignupScreen) {
                          } else {
                            final GoogleSignInAccount? googleUser =
                                await GoogleSignIn().signIn();

                            final GoogleSignInAuthentication? googleAuth =
                                await googleUser?.authentication;

                            final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth?.accessToken,
                              idToken: googleAuth?.idToken,
                            );

                            final userCredential =
                                await _authentication.signInWithCredential(credential);

                            final url = userCredential.user!.photoURL;

                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(userCredential.user!.uid)
                                .set({
                              'userName': userCredential.user!.displayName,
                              'email': userCredential.user!.email,
                              'picked_image': url,
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(155, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Palette.googleColor,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Google'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
