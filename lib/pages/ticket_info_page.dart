import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/ticket.dart';

class TicketInfoPage extends StatefulWidget {
  final Ticket ticket;

  const TicketInfoPage({super.key, required this.ticket});

  @override
  State<TicketInfoPage> createState() => _TicketInfoPageState();
}

class _TicketInfoPageState extends State<TicketInfoPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket Info',
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ticket.title,
                                softWrap: true,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5,
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(64)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(64),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          widget.ticket.reporterProfilePic,
                                      placeholder:
                                          (BuildContext context, String url) =>
                                              const CircularProgressIndicator(),
                                      errorWidget: (BuildContext context,
                                              String url, dynamic error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.ticket.reporterFirstName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("@${widget.ticket.reporterUsername}")
                                  ],
                                ),
                              ])
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: MediaQuery.of(context).size.height / 3 - 32,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.ticket.incidentPic,
                        placeholder: (BuildContext context, String url) =>
                            const CircularProgressIndicator(),
                        errorWidget:
                            (BuildContext context, String url, dynamic error) =>
                                const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
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
                    const Text(
                      "Complaint Description :",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(fontSize: 16),
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
}
