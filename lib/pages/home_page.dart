import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plastic_bounty/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final FirebaseAuth auth;
  const HomePage({super.key, required this.auth});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(

        title: const Text("Home"),
        actions: [
          ElevatedButton(onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(auth: widget.auth,)));
          }, child: const Icon(Icons.account_circle))
        ],
      ),
      body: const Text("Home"),);
  }
}
