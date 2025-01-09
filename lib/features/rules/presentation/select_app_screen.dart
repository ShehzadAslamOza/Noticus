import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:noticus/features/rules/presentation/select_action_screen.dart';

class SelectAppScreen extends StatefulWidget {
  @override
  _SelectAppScreenState createState() => _SelectAppScreenState();
}

class _SelectAppScreenState extends State<SelectAppScreen> {
  String _searchQuery = "";
  late Future<List<AppInfo>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = InstalledApps.getInstalledApps(true, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("When notification is from",
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.grey.shade900,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase(); // Update the search query
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AppInfo>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text("No apps found",
                          style: TextStyle(color: Colors.white)));
                }

                // Filter apps based on the search query
                final apps = snapshot.data!
                    .where(
                        (app) => app.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (apps.isEmpty) {
                  return Center(
                    child: Text("No matching apps found.",
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectActionScreen(
                              appName: app.name,
                              packageName: app.packageName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.memory(
                              app.icon!,
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              app.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
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
}
