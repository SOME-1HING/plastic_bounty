import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plastic_bounty/provider/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/loginBG.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: SmoothBorderRadius.only(
                  bottomLeft: SmoothRadius(
                      cornerRadius: MediaQuery.of(context).size.width / 2,
                      cornerSmoothing: 1))),
        ),
        Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Plastic Bounty",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 42,
                          fontWeight: FontWeight.w500)),
                  InkWell(
                    onTap: () async {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.googleLogin();
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
                              child: Text(
                                "Continue with Google",
                                style: GoogleFonts.poppins(
                                    fontSize: 22, fontWeight: FontWeight.w500),
                              ))
                        ],
                      ),
                    ),
                  ),
                  Text("Cleaner Earth, Brighter Future:\nJoin the Movement",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                      )),
                ])),
      ]),
      backgroundColor: const Color(0xFFD4DBE2),
    );
  }
}
