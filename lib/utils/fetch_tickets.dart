import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:plastic_bounty/Model/location.dart';
import 'package:plastic_bounty/Model/reporter.dart';
import 'package:plastic_bounty/Model/ticket.dart';
import 'package:plastic_bounty/utils/get_user.dart';

Future<List<Ticket>> fetchParseTickets(Future<Box<dynamic>>? userbox) async {
  dynamic data = await (await userbox)?.get('tickets');

  return await parseTickets(data);
}

Future fetchTickets(Future<Box<dynamic>>? userbox) async {
  http.Response res = await http.get(
      Uri.parse("https://plastic-bounty-api.vercel.app/tickets/getTickets"));

  dynamic data = jsonDecode(res.body)['data'];

  await (await userbox)?.put('tickets', data);
}

Future<List<Ticket>> parseTickets(List<dynamic> tickets) async {
  List<Ticket> res = [];
  for (var item in tickets) {
    res.add(await parseTicket(item));
  }
  return List.from(res.reversed);
}

Future<Ticket> parseTicket(dynamic ticket) async {
  Reporter reporter = await getUserByID(ticket['reporter_id']);
  return Ticket(
      id: ticket['id'],
      uid: ticket['reporter_id'],
      title: ticket['problem_category'],
      desc: ticket['problem_description'],
      incidentDate: DateFormat("dd/MM/yyyy")
          .format(DateTime.parse(ticket['report_date'])),
      location: "${ticket['latitude']}, ${ticket['longitude']}",
      locationLink:
          "https://maps.google.com/?q=${ticket['latitude']},${ticket['longitude']}",
      reporterFirstName: reporter.reporterFirstName,
      reporterProfilePic: reporter.reporterProfilePic,
      status: ticket['status'],
      incidentPic: ticket['incident_pic']);
}

Future<List<Location>> parseTicketsToLoc(Future<Box<dynamic>> userbox) async {
  final List<dynamic> tickets = await (await userbox).get('tickets');
  final List<Location> res = [];
  for (int i = 0; i < tickets.length; i++) {
    res.add(Location(
        id: int.parse(tickets[i]["id"].toString()),
        latitude: double.parse(tickets[i]['latitude'].toString()),
        longitude: double.parse(tickets[i]['longitude'].toString()),
        iconType: tickets[i]["problem_category"]));
  }
  return res;
}

Future<dynamic> getTicketByID(Future<Box<dynamic>> userbox, int id) async {
  final List<dynamic> tickets = await (await userbox).get('tickets');
  dynamic ticket =
      tickets.firstWhere((item) => item["id"] == id, orElse: () => {});
  return ticket;
}
