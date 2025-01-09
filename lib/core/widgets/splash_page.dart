import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noticus/core/navigation/presentation/navigation.dart';
import 'package:noticus/features/auth/presentation/login_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: checkAuthentication(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.data == true) {
                // User is logged in
                return NavigationPage();
              } else {
                // User is not logged in
                return LoginPage();
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> checkAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
