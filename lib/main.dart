import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plastic_bounty/Model/ticket.dart';
import 'package:plastic_bounty/pages/home_page.dart';
import 'package:plastic_bounty/pages/login_page.dart';
import 'package:plastic_bounty/utils/fetch_tickets.dart';
import 'package:plastic_bounty/utils/get_user.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'provider/google_sign_in.dart';

Future<void> requestPermissions() async {
  await Permission.storage.request();

  await Permission.camera.request();
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  await FMTC.instance('mapStore').manage.createAsync();
  final directory = await getApplicationDocumentsDirectory();
  Hive.initFlutter(directory.path);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Plastic Bounty',
        home: Scaffold(
          body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                final boxes = {
                  'userbox': Hive.openBox('userbox'),
                  'tickets': Hive.openBox('tickets'),
                };
                getUser(boxes['userbox']);
                fetchTickets(boxes['tickets']);

                return HomePage(boxes: boxes);
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went wrong."),
                );
              } else {
                return const LoginPage();
              }
            },
          ),
        ),
      ));
}
