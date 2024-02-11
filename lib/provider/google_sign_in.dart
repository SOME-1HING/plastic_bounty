import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final nameParts = user.displayName?.split(" ") ?? [];

      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';

      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

      final userData = {
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'username': user.email?.split("@")[0],
        'email': user.email,
        'profile_pic': user.photoURL,
        'badges': '',
        'points': '0',
      };

      await http.post(
        Uri.parse('https://plastic-bounty-api.vercel.app/users/addUser'),
        body: userData,
      );
    }
  }

  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
