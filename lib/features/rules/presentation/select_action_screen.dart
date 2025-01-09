import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectActionScreen extends StatelessWidget {
  final String appName;
  final String packageName;

  SelectActionScreen({required this.appName, required this.packageName});

  final List<Map<String, String>> actions = [
    {"action": "Pin", "description": "Pin the notification on the screen."},
    {"action": "Ring", "description": "Ring the phone with a message."},
    {"action": "Torch", "description": "Blink the torch 5 times."},
    {"action": "Open", "description": "Open the app."},
  ];

  void createRule(BuildContext context, String action, String description) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to create a rule.")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('rules').add({
      "appName": appName,
      "packageName": packageName,
      "action": action,
      "description":
          "When notification from $appName is received, $description",
      "isActive": true,
      "userId": userId,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rule created successfully.")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create rule: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Pick action", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return GestureDetector(
                  onTap: () => createRule(
                      context, action["action"]!, action["description"]!),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getActionIcon(action["action"]!),
                          color: Colors.white,
                          size: 32.0,
                        ),
                        SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action["action"]!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              action["description"]!,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData getActionIcon(String action) {
    switch (action) {
      case "Pin":
        return Icons.push_pin;
      case "Ring":
        return Icons.ring_volume;
      case "Torch":
        return Icons.flash_on;
      case "Open":
        return Icons.open_in_new;
      default:
        return Icons.settings;
    }
  }
}
