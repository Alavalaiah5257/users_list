import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../provider/location_service.dart';

class LocationMapWidget extends StatefulWidget {
  const LocationMapWidget({super.key});

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  LatLng? currentLatLng;
  bool _isLoading = true; // Added to manage loading state
  String? _errorMessage; // Added to manage error messages

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'Location services are disabled. Please enable them.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permission is denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'Location permission is permanently denied. Please enable it in app settings.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
        _isLoading = false; // Set loading to false after successful location fetch
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching location: ${e.toString()}';
      });
    }
  }
  final _locationService = LocationService();
  double? latitude;
  double? longitude;
  String location = 'Fetching location...';

  Future<void> fetchLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      final address = await _locationService.getAddressFromLatLng(position);
      location = 'Lat: $latitude, Lng: $longitude\n$address';
    } catch (e) {
      location = 'Failed to get location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40),
      width: 300,
      height: 200,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!)) // show error message
          : (currentLatLng == null)
          ? const Center(child: Text("Failed to get location")) // safety check
          : FlutterMap(
        options: MapOptions(
            center: LatLng(main.lat, main.long),
            zoom: 14,
            maxZoom: 18,
            minZoom: 10,
            onPositionChanged: (mapPosition, boolValue){
              _lastposition = mapPosition.center;
            }),
        children: [
          TileLayer(
            urlTemplate:
            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentLatLng!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
