import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noticus/features/rules/presentation/select_app_screen.dart';

class RulesPage extends StatefulWidget {
  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = "";
  bool _isSearching = false;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isSearching ? buildSearchAppBar() : buildDefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.rule, color: Colors.white, size: 50.0),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Text(
                "Notifications Rules",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "When you get a notification, if it matches any of the following rules it will perform the chosen action.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('rules')
                    .where('userId', isEqualTo: _userId) // Filter by userId
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No rules found.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final rules = snapshot.data!.docs.where((rule) {
                    // Filter rules by search query
                    final description =
                        rule['description']?.toLowerCase() ?? '';
                    return description.contains(_searchQuery);
                  }).toList();

                  if (rules.isEmpty) {
                    return Center(
                      child: Text(
                        "No matching rules found.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return buildRuleCard(
                        ruleId: rule.id,
                        title: rule['description'],
                        isActive: rule['isActive'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.yellow.shade300,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text(
          "Create rule",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectAppScreen()),
          );
        },
      ),
    );
  }

  AppBar buildDefaultAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
        "Rules",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ],
    );
  }

  AppBar buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchQuery = "";
          });
        },
      ),
      title: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "Search rules...",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildRuleCard({
    required String ruleId,
    required String title,
    required bool isActive,
  }) {
    return GestureDetector(
      onLongPress: () {
        showDeleteConfirmationDialog(ruleId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.red.shade300 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isActive ? Colors.red.shade300 : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.more_horiz,
                      color: isActive ? Colors.black : Colors.white),
                  Row(
                    children: [
                      Text(
                        isActive ? "Active" : "Disabled",
                        style: TextStyle(
                          color: isActive ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Switch(
                        value: isActive,
                        onChanged: (bool value) {
                          updateRuleStatus(ruleId, value);
                        },
                        activeColor: Colors.red.shade300,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  decoration: isActive
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateRuleStatus(String ruleId, bool isActive) {
    _firestore.collection('rules').doc(ruleId).update({
      'isActive': isActive,
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update rule: $error"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void showDeleteConfirmationDialog(String ruleId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Rule"),
          content: Text("Are you sure you want to delete this rule?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteRule(ruleId);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteRule(String ruleId) {
    Navigator.pop(context); // Close the dialog
    _firestore.collection('rules').doc(ruleId).delete().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete rule: $error"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
