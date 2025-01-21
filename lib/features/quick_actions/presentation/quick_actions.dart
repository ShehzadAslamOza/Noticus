import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noticus/features/quick_actions/bloc/quick_actions_bloc.dart';

class QuickActionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuickActionsBloc()..add(FetchInitialDataEvent()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Quick Actions"),
        ),
        body: BlocBuilder<QuickActionsBloc, QuickActionsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DND Status Card
                  buildDndStatusCard(context, state),
                  SizedBox(height: 16.0),
                  // Volume Control Card
                  buildVolumeControlCard(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildDndStatusCard(BuildContext context, QuickActionsState state) {
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
                state.isNotificationPolicyAccessGranted
                    ? (state.isDndEnabled ? "Enabled" : "Disabled")
                    : "Permission Required",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          Switch(
            value: state.isDndEnabled,
            onChanged: (value) {
              context.read<QuickActionsBloc>().add(ToggleDndEvent(value));
            },
            activeColor: Colors.red,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget buildVolumeControlCard(BuildContext context, QuickActionsState state) {
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
                  value: state.volumeValue,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey.shade700,
                  onChanged: (value) {
                    context
                        .read<QuickActionsBloc>()
                        .add(UpdateVolumeEvent(value));
                  },
                ),
              ),
              Text(
                "${(state.volumeValue * 100).toInt()}%",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
