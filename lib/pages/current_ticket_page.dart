import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plastic_bounty/Model/ticket.dart';
import 'package:plastic_bounty/pages/old_ticket_page.dart';
import 'package:plastic_bounty/pages/ticket_info_page.dart';

class CurrTicketPage extends StatefulWidget {
  const CurrTicketPage({super.key});

  @override
  State<CurrTicketPage> createState() => _CurrTicketPageState();
}

class _CurrTicketPageState extends State<CurrTicketPage> {
  final List<Ticket> tickets = [
    Ticket(
        title: "Complaint category",
        desc:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Proin sed libero enim sed faucibus turpis in. Feugiat sed lectus vestibulum mattis ullamcorper velit. Enim sed faucibus turpis in eu mi. Senectus et netus et malesuada fames ac. Volutpat diam ut venenatis tellus. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor sit. Habitasse platea dictumst vestibulum rhoncus est. A arcu cursus vitae congue mauris. In ornare quam viverra orci sagittis eu. Mauris nunc congue nisi vitae suscipit tellus mauris a diam. Lectus sit amet est placerat in. Consectetur adipiscing elit pellentesque habitant. Proin nibh nisl condimentum id venenatis a condimentum vitae. Adipiscing tristique risus nec feugiat in fermentum posuere.",
        incidentDate: "19/01/2024",
        location: "near to beach fruit stall",
        locationLink:
            "https://www.google.com/maps/place/Yauatcha+Bengaluru/@12.97296,77.6279344,15z/data=!3m1!5s0x3bae169ca4bae32b:0xb825fcec7e76bb19!4m6!3m5!1s0x3bae169ca3a64bc9:0x72f562a5936ab01c!8m2!3d12.9732218!4d77.620367!16s%2Fg%2F1pzv40bw3?entry=ttu",
        reporterFirstName: "Tara",
        reporterUsername: "username",
        reporterProfilePic: "https://picsum.photos/id/12/200/300.jpg",
        incidentPic: "https://picsum.photos/id/237/200/300.jpg"),
    Ticket(
        title: "Complaint categorybkjbjbk",
        desc: "fer ervf efdr",
        incidentDate: "19/01/2024",
        location: "near to beach fruit stall",
        locationLink: "ef",
        reporterFirstName: "Tara",
        reporterProfilePic: "https://picsum.photos/id/12/200/300.jpg",
        reporterUsername: "username",
        incidentPic: "https://picsum.photos/id/237/200/300.jpg"),
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Current Tickets',
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
      body: tickets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.offline_share),
                  Text(
                    "No Ticket here to show.",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    Ticket ticket = tickets[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TicketInfoPage(
                                  ticket: ticket,
                                )));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                    imageUrl: (ticket.incidentPic),
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
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (ticket.title.length > 18)
                                        ? "${ticket.title.substring(0, 18)}..."
                                        : ticket.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (ticket.desc.length > 24)
                                        ? "${ticket.desc.substring(0, 23)}..."
                                        : ticket.desc,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(ticket.incidentDate,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    const Text("More Info...")
                                  ],
                                ),
                              )
                            ],
                          ),
                          const Divider(
                            color: Color(0xFF5F5959),
                            thickness: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OldTicketPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F5959),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Old/closed Tickets",
              style: TextStyle(color: Color(0xFFDCF2F1), fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
