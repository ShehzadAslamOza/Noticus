import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noticus/features/auth/presentation/login_page.dart';
import 'package:noticus/features/notification_listner/bloc/notification_listner_bloc.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    final userEmail = user?.email ?? "Unknown User"; // Get user's email

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 50.0),

          // User Info Section
          Center(
            child: Column(
              children: [
                SizedBox(height: 16.0),
                // Logout Section
                Icon(Icons.person, color: Colors.yellow.shade300, size: 50.0),
                SizedBox(height: 8.0),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),

          SizedBox(height: 16.0),

          buildListTile(
            title: "Logout",
            onTap: () async {
              // Dispatch StopListeningEvent to cancel the subscription
              context
                  .read<NotificationListenerBloc>()
                  .add(StopListeningEvent());

              // Log out the user
              await FirebaseAuth.instance.signOut();

              // Navigate to Login Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),

          buildListTile(
            title: "Guide and FAQs",
            onTap: () {
              // Handle guide and FAQ action
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Text(
              "You may need to allow Noticus to run in the background if it isn't working. ",
              style: TextStyle(color: Colors.grey, fontSize: 14.0),
            ),
          ),
          Spacer(),
          Divider(color: Colors.grey.shade700),

          // App Info Section
          Center(
            child: Column(
              children: [
                Text(
                  "App Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "Created by Muhammad Shehzad",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade700),
        ],
      ),
    );
  }

  // Widget for section headers
  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.yellow.shade300,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  // Widget for list items
  Widget buildListTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
