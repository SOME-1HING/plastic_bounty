import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:plastic_bounty/Model/reporter.dart';

Future<bool> getUser(Future<Box<dynamic>>? userbox) async {
  final user = FirebaseAuth.instance.currentUser;
  dynamic result;

  if (user != null) {
    final Uri url = Uri.parse(
        'https://plastic-bounty-api.vercel.app/users/getUser?uid=${user.uid}');
    final http.Response response = await http.get(url);
    final body = json.decode(response.body);
    result = body['data'];
  } else {
    result = [];
  }
  await (await userbox)?.put('user', result);

  return true;
}

Future<Reporter> getUserByID(String id) async {
  Reporter result;

  try {
    if (id != "-1") {
      final Uri url = Uri.parse(
          'https://plastic-bounty-api.vercel.app/users/getUser?uid=${id}');
      final http.Response response = await http.get(url);
      final body = json.decode(response.body);
      result = Reporter(
          reporterFirstName: body['data']['first_name'],
          reporterProfilePic: body['data']['profile_pic']);
    } else {
      result = Reporter(
          reporterFirstName: "Tara",
          reporterProfilePic: "https://picsum.photos/id/12/200/300.jpg");
    }
  } catch (e) {
    result = Reporter(
        reporterFirstName: "Tara",
        reporterProfilePic: "https://picsum.photos/id/12/200/300.jpg");
  }
  return result;
}

Future<String> getProfilePic(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty) {
    throw ArgumentError('User data cannot be null or empty');
  }
  return user['profile_pic'] ?? "https://picsum.photos/id/266/200/300.jpg";
}

Future<String> getFirstName(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty) {
    throw ArgumentError('User data cannot be null or empty');
  }

  return user['first_name'] ?? "First";
}

Future<String> getLastName(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty) {
    throw ArgumentError('User data cannot be null or empty');
  }

  return user['last_name'] ?? "Last";
}

Future<String> getFullName(Future<Box<dynamic>> userbox) async {
  return ("${await getFirstName(userbox)} ${await getLastName(userbox)}");
}

Future<String> getEmail(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty) {
    throw ArgumentError('User data cannot be null or empty');
  }

  return user['email'] ?? "email@email.com";
}

Future<int> getPoints(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty) {
    throw ArgumentError('User data cannot be null or empty');
  }

  return user['points'] ?? 0;
}

Future<String> getBadges(Future<Box<dynamic>> userbox) async {
  final dynamic user = await (await userbox).get('user');
  if (user == null || user.isEmpty || user == '') {
    return "null";
  }

  print(user);

  return user['badges'] ?? "null";
}
