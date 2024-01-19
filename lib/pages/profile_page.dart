import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plastic_bounty/utils/google_auth.dart';

import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth auth;

  const ProfilePage({Key? key, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title:const Text("Profile"),
        actions: [
          ElevatedButton(
            onPressed: ()  {
              logout(context, auth);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(auth: auth)),
              );
            },
            child:const Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}
