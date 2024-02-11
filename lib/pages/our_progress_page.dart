import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late Future<Map<String, String>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _getStats();
  }

  Future<Map<String, String>> _getStats() async {
    http.Response response = await http.get(
      Uri.parse('https://plastic-bounty-api.vercel.app/getStats'),
    );

    dynamic data = json.decode(response.body);

    return {
      'userCount': (data['data']['userCount'] != null)
          ? (data['data']['userCount']).toString()
          : "0",
      'activeTicketCount': (data['data']['activeTicketCount'] != null)
          ? (data['data']['activeTicketCount']).toString()
          : "0",
      'closedTicketCount': (data['data']['closedTicketCount'] != null)
          ? (data['data']['closedTicketCount']).toString()
          : "0",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Progress',
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
      body: FutureBuilder(
        future: _statsFuture,
        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonScreen();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, String> stats = snapshot.data!;
            return _buildStatsList(stats);
          }
        },
      ),
      backgroundColor: const Color(0xFFEAF1F1),
    );
  }

  Widget _buildSkeletonScreen() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 20,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsList(Map<String, String> stats) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    mathFunc(Match match) => '${match[1]},';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                "Completed Ticket",
                style: GoogleFonts.inter(
                    fontSize: 18, color: const Color(0xFF7A8386)),
              ),
              subtitle: Text(
                stats['closedTicketCount']!.replaceAllMapped(reg, mathFunc),
                style: GoogleFonts.inter(
                    fontSize: 24, color: const Color(0xFF363434)),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(16)),
              minVerticalPadding: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                "Active Ticket",
                style: GoogleFonts.inter(
                    fontSize: 18, color: const Color(0xFF7A8386)),
              ),
              subtitle: Text(
                stats['activeTicketCount']!.replaceAllMapped(reg, mathFunc),
                style: GoogleFonts.inter(
                    fontSize: 24, color: const Color(0xFF363434)),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(16)),
              minVerticalPadding: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                "User Count",
                style: GoogleFonts.inter(
                    fontSize: 18, color: const Color(0xFF7A8386)),
              ),
              subtitle: Text(
                stats['userCount']!.replaceAllMapped(reg, mathFunc),
                style: GoogleFonts.inter(
                    fontSize: 24, color: const Color(0xFF363434)),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(16)),
              minVerticalPadding: 18,
            ),
          ),
        ],
      ),
    );
  }
}
