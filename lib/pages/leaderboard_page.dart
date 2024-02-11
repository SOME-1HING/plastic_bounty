import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import '../Model/leaderboard.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Leaderboard> leaderboard = [];
  bool isLoading = true;

  Future<http.Response> getLeaderboard() async {
    return await http
        .get(Uri.parse('https://plastic-bounty-api.vercel.app/getLeaderboard'));
  }

  Future _parseLeaderboard() async {
    List<dynamic> rawData = json.decode((await getLeaderboard()).body)['data'];

    setState(() {
      for (int i = 0; i < rawData.length; i++) {
        dynamic user = rawData[i];
        leaderboard.add(Leaderboard(
            firstName: user['first_name'],
            points: user['points'],
            profilePic: user['profile_pic']));
      }
      isLoading = false; // Set loading to false after data is fetched
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _parseLeaderboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
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
      body: isLoading
          ? _buildLoadingWidget()
          : Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 40, bottom: 10),
                                height: 150,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 20,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFDCF2F1),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        topLeft: Radius.circular(16))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          (leaderboard[1].firstName.length > 18)
                                              ? "${leaderboard[1].firstName.substring(0, 18)}..."
                                              : leaderboard[1].firstName,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${leaderboard[1].points}",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xFF009BD6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "2",
                                      style: GoogleFonts.inter(
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -30,
                                left: 25,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF009BD6),
                                        width: 3),
                                    borderRadius: BorderRadius.circular(64),
                                    color: Colors.grey,
                                  ),
                                  child: CachedNetworkImage(
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(64),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    imageUrl: leaderboard[1].profilePic,
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const CircularProgressIndicator(),
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ]),
                        Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 40, bottom: 10),
                                height: 200,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 20,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFA7E3DC),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(32),
                                        topLeft: Radius.circular(32))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          (leaderboard[0].firstName.length > 18)
                                              ? "${leaderboard[0].firstName.substring(0, 18)}..."
                                              : leaderboard[0].firstName,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${leaderboard[0].points}",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xFFFB9639),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "1",
                                      style: GoogleFonts.inter(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -30,
                                left: 31,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFFB9639),
                                        width: 3),
                                    borderRadius: BorderRadius.circular(64),
                                    color: Colors.grey,
                                  ),
                                  child: CachedNetworkImage(
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(64),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    imageUrl: leaderboard[0].profilePic,
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const CircularProgressIndicator(),
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -60,
                                  left: (MediaQuery.of(context).size.width / 3 -
                                              50) /
                                          2 -
                                      2,
                                  child: const Image(
                                    image:
                                        AssetImage('assets/images/crown.png'),
                                  ))
                            ]),
                        Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 40, bottom: 10),
                                height: 150,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 20,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFDCF2F1),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(16),
                                        topRight: Radius.circular(16))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          (leaderboard[2].firstName.length > 18)
                                              ? "${leaderboard[2].firstName.substring(0, 18)}..."
                                              : leaderboard[2].firstName,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${leaderboard[2].points}",
                                      style: GoogleFonts.inter(
                                          color: const Color(0xFF00D95F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "3",
                                      style: GoogleFonts.inter(
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -30,
                                left: 25,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF00D95F),
                                        width: 3),
                                    borderRadius: BorderRadius.circular(64),
                                    color: Colors.grey,
                                  ),
                                  child: CachedNetworkImage(
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(64),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    imageUrl: leaderboard[2].profilePic,
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const CircularProgressIndicator(),
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: const Color(0xFFDCF2F1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: leaderboard.length - 3,
                        itemBuilder: (context, index) {
                          Leaderboard user = leaderboard[index + 3];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 3),
                                            borderRadius:
                                                BorderRadius.circular(64),
                                            color: Colors.grey,
                                          ),
                                          child: CachedNetworkImage(
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(64),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            imageUrl: user.profilePic,
                                            placeholder: (BuildContext context,
                                                    String url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (BuildContext context,
                                                    String url,
                                                    dynamic error) =>
                                                const Icon(Icons.error),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                (user.firstName.length > 18)
                                                    ? "${user.firstName.substring(0, 18)}..."
                                                    : user.firstName,
                                                style: GoogleFonts.inter(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${user.points}",
                                      style: GoogleFonts.inter(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Color(0xFF5F5959),
                                thickness: 1,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        // Your existing UI for the header section
        // ...

        // Shimmer loading effect for the leaderboard
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 10, // Placeholder for shimmer effect
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(),
                  title: Container(
                    height: 16,
                    width: 100,
                    color: Colors.white,
                  ),
                  trailing: Container(
                    height: 16,
                    width: 40,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/*

*/
