import 'dart:async';

import 'package:attendance_demo/app/presentation/widgets/confirmation_address.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({
    Key? key,
    required this.addressLine,
    required this.attendanceLocation,
    required this.pinLocation,
    required this.distance,
    required this.presenceSuccess,
  }) : super(key: key);

  final ValueNotifier<String?> addressLine;
  final ValueNotifier<LatLng?> attendanceLocation;
  final ValueNotifier<LatLng?> pinLocation;
  final ValueNotifier<double> distance;
  final ValueNotifier<bool> presenceSuccess;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng _currentPositioned;
  String addressLine = '';

  @override
  void initState() {
    super.initState();

    _currentPositioned = const LatLng(-7.766354706341709, 110.33551839537);

    getCurrentLocation();
  }

  /// Get current location from gps
  Future<void> getCurrentLocation() async {
    setState(() {
      addressLine = '';
    });
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future<void>.error('PERMISSION DENIED');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future<void>.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        _currentPositioned = LatLng(value.latitude, value.longitude);
        _updateCamera();
      });
      getAddress(LatLng(value.latitude, value.longitude));
    });
  }

  /// Get address text
  Future<void> getAddress(LatLng position) async {
    await placemarkFromCoordinates(position.latitude, position.longitude).then(
      (value) {
        setState(() {
          final administrativeArea = value.first.administrativeArea ?? '';
          final locality = value.first.locality ?? '';
          final street = value.first.street ?? '';
          final subAdministrativeArea = value.first.subAdministrativeArea ?? '';
          final subLocality = value.first.subLocality ?? '';

          addressLine =
              '''$street, $subLocality, $locality, $subAdministrativeArea, $administrativeArea''';
        });
      },
    );
  }

  void onGetDistance(BuildContext context) {
    widget.distance.value = Geolocator.distanceBetween(
        widget.pinLocation.value!.latitude,
        widget.pinLocation.value!.longitude,
        widget.attendanceLocation.value!.latitude,
        widget.attendanceLocation.value!.longitude);

    if (widget.distance.value > 50) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Presensi Gagal',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
                'Lokasi presensi anda berjarak ${widget.distance.value.toInt()} meter dari pin lokasi'),
          ],
        ),
      ));
    } else {
      widget.presenceSuccess.value = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Presensi Berhasil',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
                'Lokasi presensi anda berjarak ${widget.distance.value.toInt()} meter dari pin lokasi'),
          ],
        ),
      ));
    }
  }

  /// Update pisition when drag map
  // void _onCameraMove(CameraPosition position) {
  //   setState(() {
  //     _currentPositioned = position.target;
  //   });
  //   getAddress(LatLng(position.target.latitude, position.target.longitude));
  // }

  Future<void> _updateCamera() async {
    final controller = await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPositioned,
          zoom: 18,
        ),
      ),
    );
  }

  Marker _createMarker() {
    return Marker(
      markerId: const MarkerId('MarkerId'),
      position: _currentPositioned,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPositioned,
              zoom: 18,
            ),
            onMapCreated: _controller.complete,
            zoomControlsEnabled: false,
            // onCameraMove: _onCameraMove,
            markers: <Marker>{_createMarker()},
          ),
          Positioned(
            bottom: 244,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: getCurrentLocation,
              child: Icon(
                Icons.my_location,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ConfirmationAddress(
            addressLine: addressLine,
            onConfirmation: () {
              setState(() {
                widget.addressLine.value = addressLine;
                widget.attendanceLocation.value = _currentPositioned;
              });
              onGetDistance(context);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
