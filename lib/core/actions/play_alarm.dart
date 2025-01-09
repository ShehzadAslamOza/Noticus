// import 'package:flutter/material.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// class AlarmMessageScreen extends StatelessWidget {
//   const AlarmMessageScreen({Key? key}) : super(key: key);

//   void playAlarmAndShowMessage(BuildContext context, String message) {
//     // Play the alarm sound
//     FlutterRingtonePlayer.playAlarm();

//     // Show a dialog with the message
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Alert"),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Stop the alarm when the dialog is dismissed
//                 FlutterRingtonePlayer.stop();
//                 Navigator.of(context).pop();
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Alarm Message Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             playAlarmAndShowMessage(context, "This is your alarm message!");
//           },
//           child: const Text('Trigger Alarm'),
//         ),
//       ),
//     );
//   }
// }