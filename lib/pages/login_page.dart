import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:google_sign_in/google_sign_in.dart";
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);

class LoginPage extends StatefulWidget {
  final FirebaseAuth auth;

  const LoginPage({super.key, required this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;

      if (currentUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await currentUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await widget.auth.signInWithCredential(credential);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_page-bg1.jpeg'),
                // Replace with your asset image path
                fit: BoxFit.cover, // Adjust the BoxFit property as needed
              ),
              borderRadius: SmoothBorderRadius.only(
                  bottomLeft:
                      SmoothRadius(cornerRadius: 160, cornerSmoothing: 1))),
        ),
        Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Plastic Bounty",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 42,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      _handleSignIn();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(auth: widget.auth)),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 64,
                      height: 60,
                      decoration: BoxDecoration(
                          color: const Color(0xFF82C1D5),
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 160, cornerSmoothing: 1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: SmoothBorderRadius(
                                      cornerRadius: 160, cornerSmoothing: 1)),
                              child: const Image(
                                image: AssetImage('assets/images/google.png'),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width - 124,
                              padding: const EdgeInsets.only(right: 12),
                              alignment: Alignment.center,
                              child: const Text(
                                "Signup using Google",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const Text(
                      "Cleaner Earth, Brighter Future:\nJoin the Movement",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      )),
                ])),
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_page-bg2.jpeg'),
                // Replace with your asset image path
                fit: BoxFit.cover, // Adjust the BoxFit property as needed
              ),
              borderRadius: SmoothBorderRadius.only(
                  topRight:
                      SmoothRadius(cornerRadius: 160, cornerSmoothing: 1))),
        ),
      ]),
      backgroundColor: Color(0xFFD4DBE2),
    );
  }
}
