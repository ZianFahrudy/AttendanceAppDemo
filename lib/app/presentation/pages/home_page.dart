import 'package:attendance_demo/app/presentation/pages/attendance_page.dart';
import 'package:attendance_demo/app/presentation/pages/pin_location_page.dart';
import 'package:attendance_demo/app/presentation/widgets/presence_card.dart';
import 'package:attendance_demo/app/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final addressLine = ValueNotifier<String?>(null);
  final attendanceAddressLine = ValueNotifier<String?>(null);
  final pinLocationLatLng = ValueNotifier<LatLng?>(null);
  final attendanceLocationLatLng = ValueNotifier<LatLng?>(null);
  final distance = ValueNotifier<double>(0);
  final presenceSuccess = ValueNotifier<bool>(false);

  String date = DateFormat("hh:mm").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance App Demo'),
        elevation: 0,
        actions: [
          MenuButton(
              pinLocationLatLng: pinLocationLatLng, addressLine: addressLine)
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
          ),
          PresenceCard(
              presenceSuccess: presenceSuccess,
              date: date,
              addressLine: addressLine),
          const ProfileCard()
        ],
      ),
      floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: onPresence,
          child: const Text('Presensi')),
    );
  }

  void onPresence() {
    if (pinLocationLatLng.value != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AttendancePage(
                presenceSuccess: presenceSuccess,
                distance: distance,
                pinLocation: pinLocationLatLng,
                attendanceLocation: attendanceLocationLatLng,
                addressLine: attendanceAddressLine,
              )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Tentukan pin lokasi terlebih dahulu'),
      ));
    }
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key? key,
    required this.pinLocationLatLng,
    required this.addressLine,
  }) : super(key: key);

  final ValueNotifier<LatLng?> pinLocationLatLng;
  final ValueNotifier<String?> addressLine;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        onSelected: (v) {
          if (v == 1) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PinLocationPage(
                      pinLocation: pinLocationLatLng,
                      addressLine: addressLine,
                    )));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Tutorial'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                              '1. Tentukan pin lokasi terlebih dahulu, lalu tekan button konfirmasi address'),
                          SizedBox(height: 10),
                          Text(
                              '2. Klik button presensi pojok kanan bawah untuk mengambil lokasi kehadiran, lalu tekan button konfirmasi address'),
                        ],
                      ),
                    ));
          }
        },
        itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('Set Pin Lokasi'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Tutorial'),
              ),
            ]);
  }
}
