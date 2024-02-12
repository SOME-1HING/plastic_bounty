import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:hive/hive.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:plastic_bounty/Model/ticket.dart';

import 'package:plastic_bounty/pages/current_ticket_page.dart';
import 'package:plastic_bounty/pages/leaderboard_page.dart';
import 'package:plastic_bounty/pages/our_progress_page.dart';
import 'package:plastic_bounty/pages/profile_page.dart';
import 'package:plastic_bounty/pages/ticket_info_page.dart';
import 'package:plastic_bounty/provider/google_sign_in.dart';
import 'package:plastic_bounty/utils/fetch_tickets.dart';
import 'package:plastic_bounty/utils/get_user.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../Model/location.dart';

class HomePage extends StatefulWidget {
  final Map<String, Future<Box<dynamic>>> boxes;

  const HomePage({super.key, required this.boxes});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController descriptionController = TextEditingController();
  late bool isPanelOpen;
  late Position position;
  late final PanelController panelController;
  late MapController mapController;
  late File _imageFile;
  bool imageSelected = false;
  String selectedCategory = "";
  String description = "";
  bool isSubmitting = false;

  final List<Location> dummyLocations = [
    Location(
        id: -1,
        latitude: 13.058327214886928,
        longitude: 77.643205731337,
        iconType: "littering"),
    Location(
        id: -1,
        latitude: 13.057818362103225,
        longitude: 77.64278127176117,
        iconType: "dumping"),
    Location(
        id: -1,
        latitude: 13.057916272947296,
        longitude: 77.64311311185661,
        iconType: "fishing"),
    Location(
        id: -1,
        latitude: 13.060534190988404,
        longitude: 77.6418149308069,
        iconType: "littering"),
    Location(
        id: -1,
        latitude: 13.06029571081583,
        longitude: 77.641978397659877,
        iconType: "dumping"),
    Location(
        id: -1,
        latitude: 13.060479099072053,
        longitude: 77.641566244267,
        iconType: "fishing")
  ];
  late List<Location> locations = dummyLocations;

  Future moveToCurrLocation() async {
    mapController.move(const LatLng(13.0581234, 77.6429414), 19.0);
    mapController.rotate(0);
  }

  AssetImage _getIcon(String condition) {
    switch (condition) {
      case "Industrial Waste":
        return const AssetImage('./assets/images/industrial.png');
      case "Illegal Dumping":
        return const AssetImage('./assets/images/dumping.png');
      case "Littering":
        return const AssetImage('assets/images/littering.png');
      case "Dead Fish":
        return const AssetImage('assets/images/fishing.png');

      default:
        return const AssetImage('assets/images/littering.png');
    }
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? selected = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 50);

    setState(() {
      if (selected != null) {
        _imageFile = File(selected.path);
        imageSelected = true;
      }
    });
  }

  Future<String> uploadImageToFirebase() async {
    final FirebaseStorage _storage =
        FirebaseStorage.instanceFor(bucket: "gs://plastic-bounty.appspot.com");
    final storageRef = FirebaseStorage.instance.ref();

    final UploadTask uploadTask =
        storageRef.child('images/${DateTime.now()}.png').putFile(_imageFile);
    final TaskSnapshot downloadUrl = (await uploadTask.whenComplete(() {}));
    final String url = await downloadUrl.ref.getDownloadURL();

    return url;
  }

  Future<bool> submitTicket() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, String> body = {
        "problem_category": selectedCategory,
        "problem_description": description,
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
        "reporter_id": user.uid,
        "incident_pic": await uploadImageToFirebase(),
      };

      http.Response res = await http.post(
          Uri.parse("https://plastic-bounty-api.vercel.app/tickets/addTicket"),
          body: body);

      if (kDebugMode) {
        print(res.body);
      }
      descriptionController.clear();
      setState(() {
        selectedCategory = "";
        description = "";
        imageSelected = false;
      });

      return true;
    }
    return false;
  }

  @override
  void initState() {
    isPanelOpen = false;
    panelController = PanelController();
    mapController = MapController();

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) => position = value);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light));

    parseTicketsToLoc(widget.boxes['tickets']!).then((x) {
      setState(() {
        if (x != []) locations = x;
      });
    });

    super.initState();
  }

  Future<void> _successDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ticket Raised'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _errorDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Occurred'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                      initialZoom: 19, keepAlive: true, maxZoom: 19),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      maxZoom: 19,
                      // userAgentPackageName: 'com.example.app',
                      tileProvider: FMTC.instance('mapStore').getTileProvider(),
                    ),
                    CurrentLocationLayer(
                      alignPositionOnUpdate: AlignOnUpdate.once,
                      alignDirectionOnUpdate: AlignOnUpdate.never,
                      style: const LocationMarkerStyle(
                        showHeadingSector: false,
                        marker: DefaultLocationMarker(),
                        markerSize: Size(32, 32),
                      ),
                    ),
                    for (Location location in locations)
                      InkWell(
                        onTap: () {
                          getTicketByID(widget.boxes['tickets']!, location.id)
                              .then((value) {
                            parseTicket(value).then((ticket) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CurrTicketPage(
                                            boxes: widget.boxes,
                                          )));

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TicketInfoPage(
                                            boxes: widget.boxes,
                                            ticket: ticket,
                                          )));
                            });
                          });
                        },
                        child: LocationMarkerLayer(
                            style: LocationMarkerStyle(
                                markerSize: const Size.square(64),
                                showAccuracyCircle: false,
                                marker: Image(
                                    height: 64,
                                    width: 64,
                                    image: _getIcon(location.iconType))),
                            position: LocationMarkerPosition(
                                longitude: location.longitude,
                                latitude: location.latitude,
                                accuracy: 3)),
                      ),
                  ],
                ),
              ),
            ),
            PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 140),
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top - 2),
                child: Stack(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 140,
                    child: SvgPicture.asset('assets/images/Wave2.svg',
                        width: MediaQuery.of(context).size.width,
                        height: 140,
                        fit: BoxFit.contain,
                        /* colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.7),
                          BlendMode.srcATop,
                        ),*/
                        color: const Color(0x467FC7D9),
                        semanticsLabel: 'wave1 bg'),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: SvgPicture.asset('assets/images/Wave.svg',
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        fit: BoxFit.fill,
                        semanticsLabel: 'wave front bg'),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: InkWell(
                          onTap: () {
                            _key.currentState!.openDrawer();
                          },
                          child: const Icon(
                            Icons.menu,
                            size: 32,
                          ),
                        ),
                      ),
                      Text("Plastic Bounty",
                          style: GoogleFonts.inter(
                            letterSpacing: 2,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ]),
              ),
            ),
            Positioned(
              top: 160,
              right: 10,
              child: InkWell(
                onTap: () async {
                  await moveToCurrLocation();
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32)),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blueAccent,
                    size: 32,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 236,
              right: 10,
              child: InkWell(
                onTap: () async {
                  await getUser(widget.boxes['userbox']!);
                  await fetchTickets(widget.boxes['tickets']!);
                  dynamic x = await parseTicketsToLoc(widget.boxes['tickets']!);
                  setState(() {
                    if (x != []) locations = x;
                  });
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32)),
                  child: const Icon(
                    Icons.sync,
                    color: Colors.blueAccent,
                    size: 32,
                  ),
                ),
              ),
            ),
            SlidingUpPanel(
                onPanelOpened: () {
                  setState(() {
                    isPanelOpen = true;
                  });
                },
                onPanelClosed: () {
                  setState(() {
                    isPanelOpen = false;
                  });
                },
                minHeight: 75,
                maxHeight: 400,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                    topLeft: Radius.circular(32)),
                controller: panelController,
                header: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ForceDraggableWidget(
                        child: SizedBox(
                          width: 100,
                          height: 40,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 12.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 30,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                panelBuilder: () {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: (isPanelOpen) ? 40 : 60, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Select Location:",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Complaint Category",
                              style: GoogleFonts.dmSans(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              hint: (selectedCategory != "")
                                  ? Text(selectedCategory)
                                  : const Text("Select"),
                              items: <String>[
                                'Littering',
                                'Illegal Dumping',
                                'Industrial Waste',
                                'Dead Fish',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                              },
                            )
                          ],
                        ),
                        Text(
                          "Complaint Description",
                          style: GoogleFonts.dmSans(fontSize: 16),
                        ),
                        TextField(
                          controller: descriptionController,
                          onChanged: (value) {
                            description = value;
                          },
                        ),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              await _pickImage();
                              await uploadImageToFirebase();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  size: 24,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  (imageSelected)
                                      ? "Replace Image"
                                      : "Add Media",
                                  style: const TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              child: ElevatedButton(
                                onPressed:
                                    isSubmitting // Disable button if submitting
                                        ? null
                                        : () async {
                                            if (selectedCategory == "" ||
                                                description == "" ||
                                                !imageSelected) {
                                              String errorMessage;

                                              if (selectedCategory == "" ||
                                                  selectedCategory ==
                                                      "Select") {
                                                errorMessage =
                                                    'Please select a category';
                                              } else if (description == "") {
                                                errorMessage =
                                                    'Please enter a description';
                                              } else {
                                                errorMessage =
                                                    'Please select an image';
                                              }

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  dismissDirection:
                                                      DismissDirection.up,
                                                  content: Text(errorMessage),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                      seconds: 3),
                                                ),
                                              );
                                            } else {
                                              setState(() {
                                                isSubmitting =
                                                    true; // Start submission process
                                              });
                                              bool isRaised = false;
                                              try {
                                                isRaised = await submitTicket();
                                                if (isRaised) {
                                                  await getUser(
                                                      widget.boxes['userbox']!);
                                                  await fetchTickets(
                                                      widget.boxes['tickets']!);
                                                  dynamic x =
                                                      await parseTicketsToLoc(
                                                          widget.boxes[
                                                              'tickets']!);
                                                  setState(() {
                                                    if (x != []) locations = x;
                                                  });
                                                }
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(e);
                                                }
                                              } finally {
                                                setState(() {
                                                  isSubmitting =
                                                      false; // Reset submission status
                                                });
                                              }
                                              if (isRaised) {
                                                _successDialog(context);
                                              } else {
                                                _errorDialog(context);
                                              }
                                            }
                                          },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSubmitting // Change button color based on submission status
                                          ? Colors.grey
                                          : const Color(0xFF365486),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isSubmitting
                                    ? CircularProgressIndicator()
                                    : const Text(
                                        "Raise Ticket",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                color: const Color(0xFFDCF2F1))
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF7FC7D9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 200 + kToolbarHeight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                boxes: widget.boxes,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                          ),
                          child: FutureBuilder<String>(
                            future: getProfilePic(widget.boxes['userbox']!),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(64),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot.data!,
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const CircularProgressIndicator(),
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<String>(
                                future: getFullName(widget.boxes['userbox']!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("...");
                                  } else if (snapshot.hasError) {
                                    return const Text("...");
                                  } else {
                                    return Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                }),
                            FutureBuilder<int>(
                                future: getPoints(widget.boxes['userbox']!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("0");
                                  } else if (snapshot.hasError) {
                                    return const Text("0");
                                  } else {
                                    return Text(
                                      "${snapshot.data!}",
                                    );
                                  }
                                }),
                          ],
                        ),
                      ]),
                ),
              ),
            ),
            Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.leaderboard,
                  ),
                  title: Text(
                    'Leaderboard',
                    style: GoogleFonts.openSans(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeaderboardPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications,
                  ),
                  title: Text(
                    'Current Ticket',
                    style: GoogleFonts.openSans(),
                  ),
                  onTap: () {
                    fetchTickets(widget.boxes['tickets']!);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CurrTicketPage(
                                  boxes: widget.boxes,
                                )));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.pie_chart_rounded,
                  ),
                  title: Text(
                    'Our Progress',
                    style: GoogleFonts.openSans(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProgressPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.openSans(),
                  ),
                  onTap: () {
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
