import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:plastic_bounty/pages/current_ticket_page.dart';
import 'package:plastic_bounty/pages/old_ticket_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../Model/reporter.dart';
import '../Model/ticket.dart';
import '../utils/fetch_tickets.dart';
import '../utils/get_user.dart';

class TicketInfoPage extends StatefulWidget {
  final Ticket ticket;
  final Map<String, Future<Box<dynamic>>> boxes;

  const TicketInfoPage({Key? key, required this.ticket, required this.boxes})
      : super(key: key);

  @override
  State<TicketInfoPage> createState() => _TicketInfoPageState();
}

class _TicketInfoPageState extends State<TicketInfoPage> {
  final ScrollController _scrollController = ScrollController();
  late Reporter reporter = Reporter(
      reporterFirstName: "Tara",
      reporterProfilePic: "https://picsum.photos/id/12/200/300.jpg");
  bool isLoading = true;
  bool closing = false;

  Future _closeTicket() async {
    await http.get(Uri.parse(
        "https://plastic-bounty-api.vercel.app/tickets/closeTicket?id=${widget.ticket.id}"));
  }

  @override
  void initState() {
    getUserByID(widget.ticket.uid).then((value) {
      setState(() {
        reporter = value;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (isLoading ||
              closing ||
              widget.ticket.status == 'closed' ||
              widget.ticket.uid != FirebaseAuth.instance.currentUser?.uid)
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await _closeTicket();
                await fetchTickets(widget.boxes['tickets']!);
                setState(() {
                  closing = true;
                });
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CurrTicketPage(
                              boxes: widget.boxes,
                            )));
              },
              backgroundColor: const Color(0xFF365486),
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
      appBar: AppBar(
        title: Text(
          (widget.ticket.status == 'active' && !closing)
              ? 'Ticket Info'
              : 'Closed Ticket Info',
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
          ? _buildShimmerEffect()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4.5,
                    width: MediaQuery.of(context).size.width,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ticket.title,
                                  softWrap: true,
                                  style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(64)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(64),
                                          child: isLoading
                                              ? _buildShimmerCircularProgress()
                                              : CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: reporter
                                                      .reporterProfilePic,
                                                  placeholder: (BuildContext
                                                              context,
                                                          String url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (BuildContext
                                                              context,
                                                          String url,
                                                          dynamic error) =>
                                                      const Icon(Icons.error),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reporter.reporterFirstName,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ]),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  widget.ticket.incidentDate,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await launchUrl(
                                        Uri.parse(widget.ticket.locationLink));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.ticket.location,
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const Icon(Icons.location_on)
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3.5,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 7, // Blur radius
                        offset: Offset(0, 3), // Offset
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.fitHeight,
                    imageUrl: widget.ticket.incidentPic,
                    placeholder: (BuildContext context, String url) =>
                        const CircularProgressIndicator(),
                    errorWidget:
                        (BuildContext context, String url, dynamic error) =>
                            const Icon(Icons.error),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32)),
                      color: Color(0xFFDCF2F1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Complaint Description :",
                            style: GoogleFonts.inter(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          // Add some spacing between text and SingleChildScrollView
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              child: Text(
                                widget.ticket.desc,
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildShimmerEffect() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 3,
                    color: Colors.white,
                  ),
                  Container(
                    width: 160,
                    height: MediaQuery.of(context).size.height / 3 - 32,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              color: Color(0xFFDCF2F1),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width / 2,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildShimmerCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
