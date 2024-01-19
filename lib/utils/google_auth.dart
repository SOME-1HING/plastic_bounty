import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/login_page.dart';

void navigateToLogin()
{

}
Future<void> logout(BuildContext context, FirebaseAuth auth) async {
  await auth.signOut();
  await GoogleSignIn().signOut();


}