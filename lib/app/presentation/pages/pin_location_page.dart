import 'dart:async';

import 'package:attendance_demo/app/presentation/widgets/confirmation_address.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinLocationPage extends StatefulWidget {
  const PinLocationPage({
    Key? key,
    required this.addressLine,
    required this.pinLocation,
  }) : super(key: key);

  final ValueNotifier<String?> addressLine;
  final ValueNotifier<LatLng?> pinLocation;

  @override
  State<PinLocationPage> createState() => _PinLocationPageState();
}

class _PinLocationPageState extends State<PinLocationPage> {
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

  /// Update pisition when drag map
  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPositioned = position.target;
    });
    getAddress(LatLng(position.target.latitude, position.target.longitude));
  }

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
            onCameraMove: _onCameraMove,
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
                widget.pinLocation.value = _currentPositioned;
              });
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Pin lokasi'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${widget.addressLine.value}'),
                          ],
                        ),
                      ));
            },
          )
        ],
      ),
    );
  }

  // void getDistance() {
  //   final distanceMeter = Geolocator.distanceBetween(
  //       startLatitude, startLongitude, endLatitude, endLongitude);
  // }
}
