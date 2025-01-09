import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:volume_controller/volume_controller.dart';

class QuickActionsPage extends StatefulWidget {
  @override
  _QuickActionsPageState createState() => _QuickActionsPageState();
}

class _QuickActionsPageState extends State<QuickActionsPage>
    with WidgetsBindingObserver {
  // Do Not Disturb State
  bool isDndEnabled = false;
  bool isNotificationPolicyAccessGranted = false;

  // Volume Controller State
  final VolumeController _volumeController = VolumeController.instance;
  late final StreamSubscription<double> volumeSubscription;
  double _volumeValue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    updateDndUI();

    // Initialize Volume Controller
    volumeSubscription = _volumeController.addListener((volume) {
      setState(() {
        _volumeValue = volume;
      });
    }, fetchInitialVolume: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      updateDndUI();
    }
  }

  void updateDndUI() async {
    bool isAccessGranted =
        await FlutterDnd.isNotificationPolicyAccessGranted ?? false;

    if (isAccessGranted) {
      int? filter = await FlutterDnd.getCurrentInterruptionFilter();
      setState(() {
        isNotificationPolicyAccessGranted = true;
        isDndEnabled = filter == FlutterDnd.INTERRUPTION_FILTER_NONE;
      });
    } else {
      setState(() {
        isNotificationPolicyAccessGranted = false;
        isDndEnabled = false;
      });
    }
  }

  void toggleDnd(bool enable) async {
    if (isNotificationPolicyAccessGranted) {
      if (enable) {
        await FlutterDnd.setInterruptionFilter(
            FlutterDnd.INTERRUPTION_FILTER_NONE);
      } else {
        await FlutterDnd.setInterruptionFilter(
            FlutterDnd.INTERRUPTION_FILTER_ALL);
      }
      setState(() {
        isDndEnabled = enable;
      });
    } else {
      FlutterDnd.gotoPolicySettings();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    volumeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Quick Actions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DND Status Card
            buildDndStatusCard(),
            SizedBox(height: 16.0),
            // Volume Control Card
            buildVolumeControlCard(),
          ],
        ),
      ),
    );
  }

  // DND Status Card with Switch
  Widget buildDndStatusCard() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Do Not Disturb",
                style: TextStyle(
                  color: Colors.yellow.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                isNotificationPolicyAccessGranted
                    ? (isDndEnabled ? "Enabled" : "Disabled")
                    : "Permission Required",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          Switch(
            value: isDndEnabled,
            onChanged: (value) {
              toggleDnd(value);
            },
            activeColor: Colors.red,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  // Volume Control Card
  Widget buildVolumeControlCard() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notification Volume",
            style: TextStyle(
              color: Colors.yellow.shade300,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Icon(Icons.volume_up, color: Colors.white),
              Expanded(
                child: Slider(
                  value: _volumeValue,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey.shade700,
                  onChanged: (value) {
                    setState(() {
                      _volumeValue = value;
                    });
                    _volumeController.setVolume(value);
                  },
                ),
              ),
              Text(
                "${(_volumeValue * 100).toInt()}%",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
