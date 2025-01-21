import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noticus/features/rules/bloc/rules_bloc.dart';
import 'package:noticus/features/rules/presentation/select_app_screen.dart';

class RulesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RulesBloc(FirebaseAuth.instance)..add(LoadUserId()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<RulesBloc, RulesState>(
            builder: (context, state) {
              if (state is RulesLoaded) {
                return state.searchMode
                    ? buildSearchAppBar(context)
                    : buildDefaultAppBar(context);
              }
              return AppBar(); // Placeholder for initial state
            },
          ),
        ),
        body: BlocBuilder<RulesBloc, RulesState>(
          builder: (context, state) {
            if (state is RulesLoaded) {
              return buildBody(
                context,
                state.userId,
                state.searchMode,
                state.searchQuery,
              );
            }
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            ); // Placeholder for loading/initial state
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.yellow.shade300,
          icon: Icon(Icons.add, color: Colors.black),
          label: Text(
            "Create rule",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
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
      ),
    );
  }

  AppBar buildDefaultAppBar(BuildContext context) {
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
            context.read<RulesBloc>().add(ToggleSearchMode());
          },
        ),
      ],
    );
  }

  AppBar buildSearchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.read<RulesBloc>().add(ExitSearchMode());
        },
      ),
      title: TextField(
        onChanged: (value) {
          context.read<RulesBloc>().add(UpdateSearchQuery(value));
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

  Widget buildBody(
    BuildContext context,
    String userId,
    bool searchMode,
    String searchQuery,
  ) {
    return Padding(
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
              searchMode ? "Search Results" : "Notifications Rules",
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
                  .where('userId', isEqualTo: userId)
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
                  final description = rule['description']?.toLowerCase() ?? '';
                  return searchMode ? description.contains(searchQuery) : true;
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
                      context: context,
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
    );
  }

  Widget buildRuleCard({
    required BuildContext context,
    required String ruleId,
    required String title,
    required bool isActive,
  }) {
    return GestureDetector(
      onLongPress: () {
        showDeleteConfirmationDialog(context, ruleId);
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
                          updateRuleStatus(context, ruleId, value);
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

  void updateRuleStatus(BuildContext context, String ruleId, bool isActive) {
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

  void showDeleteConfirmationDialog(BuildContext context, String ruleId) {
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
                deleteRule(context, ruleId);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteRule(BuildContext context, String ruleId) {
    Navigator.pop(context);
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
