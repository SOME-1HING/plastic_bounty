import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:plastic_bounty/utils/get_user.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, Future<Box<dynamic>>> boxes;

  const EditProfilePage({super.key, required this.boxes});

  @override
  State<EditProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  String badges = "null";

  @override
  void initState() {
    super.initState();
    getBadges(widget.boxes['userbox']!).then((value) {
      setState(() {
        badges = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle statusStyle =
        GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 20);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF365486),
          child: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          leading: SizedBox(
            height: 56.0,
            width: 56,
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios)),
          ),
        ),
        body: Column(
          children: [
            Stack(alignment: AlignmentDirectional.bottomCenter, children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3.5,
                  child: const Image(
                    opacity: AlwaysStoppedAnimation(.73),
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/profileBG.png'),
                  )),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 5),
                    borderRadius: BorderRadius.circular(124),
                  ),
                  child: FutureBuilder<String>(
                    future: getProfilePic(widget.boxes['userbox']!),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error);
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(124),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: snapshot.data!,
                            placeholder: (BuildContext context, String url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (BuildContext context, String url,
                                    dynamic error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 16,
            ),
            FutureBuilder<String>(
                future: getFullName(widget.boxes['userbox']!),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("...");
                  } else if (snapshot.hasError) {
                    return const Text("...");
                  } else {
                    return Text(
                      snapshot.data!,
                      style: GoogleFonts.inter(
                          color: const Color(0xFF242760),
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    );
                  }
                }),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Points",
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      FutureBuilder<int>(
                          future: getPoints(widget.boxes['userbox']!),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else {
                              return Text(
                                "${snapshot.data!}",
                                style: statusStyle,
                              );
                            }
                          }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rank",
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      FutureBuilder<int>(
                          future: getPoints(widget.boxes['userbox']!),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else {
                              return Text(
                                "${snapshot.data!}",
                                style: statusStyle,
                              );
                            }
                          }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Badges",
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      FutureBuilder<String>(
                          future: getBadges(widget.boxes['userbox']!),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "0",
                                style: statusStyle,
                              );
                            } else {
                              if (snapshot.data! == "null" ||
                                  snapshot.data! == "") {
                                return Text(
                                  "0",
                                  style: statusStyle,
                                );
                              } else {
                                return Text(
                                  "${snapshot.data!.split(" ").length}",
                                  style: statusStyle,
                                );
                              }
                            }
                          }),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Column(
              children: [
                Text(
                  "Badges",
                  style: GoogleFonts.inter(
                      color: const Color(0xFF242760),
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 64,
                  height: 2,
                  decoration: const BoxDecoration(
                      color: Color(0xFFCBC4C4),
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
                Container(
                  alignment: (badges == "null" || badges == "")
                      ? Alignment.center
                      : Alignment.topLeft,
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width,
                  child: (badges == "null" || badges == "")
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "You don’t have any badges to display",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF959595)),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Image(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  'assets/images/badges/no_badge.png'),
                            ),
                          ],
                        )
                      : const Row(
                          children: [
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'assets/images/badges/new_badge.png'),
                                ))
                          ],
                        ),
                )
              ],
            )
          ],
        ));
  }
}
