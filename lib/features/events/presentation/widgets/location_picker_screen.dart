// lib/features/events/presentation/widgets/location_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // For requesting location permission

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation; // Optional initial location
  final String? initialAddress; // Optional initial address

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  String? _pickedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _pickedAddress = widget.initialAddress;
    _checkAndRequestLocationPermission(); // Request permission when the screen starts
  }

  // Requests location permissions
  Future<void> _checkAndRequestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is needed to show your current location.',
            ),
          ),
        );
      }
      if (status.isPermanentlyDenied) {
        openAppSettings(); // Direct user to settings
      }
    }
  }

  // Moves camera to user's current location
  Future<void> _goToCurrentLocation() async {
    setState(() {
      _isLoading = true; // Show loading indicator while getting location
    });
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        // You'll need a location package like 'geolocator' to get current location
        // For simplicity, let's just center on a default if geolocator is not integrated here
        // If you have geolocator set up globally, you can use it here:
        // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        // LatLng currentLocation = LatLng(position.latitude, position.longitude);

        // For now, let's just animate to initial or default if no geolocator integration
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              _pickedLocation ??
                  const LatLng(47.9189, 106.9172), // Default to Ulaanbaatar
            ),
          );
        }
      }
    } catch (e) {
      print("Could not get current location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onMapTap(LatLng tappedLocation) async {
    setState(() {
      _isLoading = true;
    });
    String? address;
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        tappedLocation.latitude,
        tappedLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = '${p.street}, ${p.subLocality}, ${p.locality}, ${p.country}';
        // Fallback if street is empty
        if (p.street == null || p.street!.isEmpty) {
          address = '${p.name}, ${p.subLocality}, ${p.locality}, ${p.country}';
        }
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
      address = null; // Ensure it's null if geocoding fails
    } finally {
      setState(() {
        _pickedLocation = tappedLocation;
        _pickedAddress = address;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Event Location'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  widget.initialLocation ??
                  const LatLng(47.9189, 106.9172), // Ulaanbaatar
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // If no initial location and map created, try to go to current location
              if (widget.initialLocation == null) {
                _goToCurrentLocation();
              }
            },
            markers:
                _pickedLocation == null
                    ? {}
                    : {
                      Marker(
                        markerId: const MarkerId('picked-location'),
                        position: _pickedLocation!,
                        infoWindow: InfoWindow(
                          title: 'Picked Location',
                          snippet:
                              _pickedAddress ??
                              'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                        ),
                      ),
                    },
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black54,
                  child: Text(
                    _pickedAddress ?? 'Tap on the map to pick a location',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _pickedLocation == null
                          ? null
                          : () {
                            Navigator.pop(context, {
                              'location': _pickedLocation,
                              'address': _pickedAddress,
                            });
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Theme color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Select This Location',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
