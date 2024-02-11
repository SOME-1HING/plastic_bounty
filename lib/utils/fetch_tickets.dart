import 'dart:convert';

import 'package:http/http.dart' as http;

Future _fetchTickets() async {
  http.Response res = await http.get(
      Uri.parse("https://plastic-bounty-api.vercel.app/tickets/getTickets"));

  dynamic data = jsonDecode(res.body);
}
