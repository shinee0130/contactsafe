import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:url_launcher/url_launcher.dart';

import 'package:contactsafe/features/events/data/models/event_model.dart';

class EventsDetailScreen extends StatefulWidget {
  final AppEvent event;
  final List<Contact> allDeviceContacts;

  const EventsDetailScreen({
    super.key,
    required this.event,
    required this.allDeviceContacts,
  });

  @override
  State<EventsDetailScreen> createState() => _EventsDetailScreenState();
}

class _EventsDetailScreenState extends State<EventsDetailScreen> {
  GoogleMapController? _mapController;
  LatLng? _eventLatLng;
  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    _geocodeEventLocation();
  }

  // Attempts to geocode the event location string to LatLng for the map
  Future<void> _geocodeEventLocation() async {
    setState(() {
      _isLoadingMap = true;
    });
    try {
      if (widget.event.location != null && widget.event.location!.isNotEmpty) {
        // First, try to parse directly as LatLng if it's in the format "lat,lng"
        final parts = widget.event.location!.split(',');
        if (parts.length == 2) {
          try {
            final lat = double.parse(parts[0].trim());
            final lng = double.parse(parts[1].trim());
            _eventLatLng = LatLng(lat, lng);
            debugPrint('Parsed location directly: $_eventLatLng');
          } catch (_) {
            // Not a direct LatLng, proceed to geocoding
          }
        }

        // If not parsed directly, or parsing failed, try geocoding
        if (_eventLatLng == null) {
          final locations = await geo.locationFromAddress(
            widget.event.location!,
          );
          if (locations.isNotEmpty) {
            _eventLatLng = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
            debugPrint('Geocoded location: $_eventLatLng');
          } else {
            debugPrint('Could not geocode address: ${widget.event.location}');
          }
        }
      } else {
        debugPrint('Event has no location string.');
      }
    } catch (e) {
      debugPrint('Error geocoding event location: $e');
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingMap = false;
      });
      // Animate map camera if controller is ready
      _updateMapCamera();
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _eventLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _eventLatLng!,
          14.0,
        ), // Adjust zoom level as needed
      );
    }
  }

  Future<void> _openGoogleMapsDirections() async {
    Uri? uri;
    if (_eventLatLng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${_eventLatLng!.latitude},${_eventLatLng!.longitude}',
      );
    } else if (widget.event.location != null &&
        widget.event.location!.isNotEmpty) {
      final encoded = Uri.encodeComponent(widget.event.location!);
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$encoded',
      );
    }

    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Contact> eventParticipants = widget.event.getParticipants(
      widget.allDeviceContacts,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat.yMMMd().format(widget.event.date),
            ),
            const SizedBox(height: 10),

            // Location
            if (widget.event.location != null &&
                widget.event.location!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: widget.event.location!,
                    onTap: _openGoogleMapsDirections,
                  ),
                  const SizedBox(height: 10),
                  // Embedded Google Map
                  Container(
                    height: 200, // Fixed height for the map
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child:
                        _isLoadingMap
                            ? const Center(child: CircularProgressIndicator())
                            : (_eventLatLng == null
                                ? const Center(
                                  child: Text(
                                    'Map location unavailable. Could not geocode address.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _eventLatLng!,
                                      zoom: 14.0,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId(
                                          'event-location',
                                        ),
                                        position: _eventLatLng!,
                                        infoWindow: InfoWindow(
                                          title: widget.event.title,
                                          snippet: widget.event.location,
                                        ),
                                      ),
                                    },
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                      _updateMapCamera(); // Ensure camera updates if controller was null before
                                    },
                                    onTap: (_) => _openGoogleMapsDirections(),
                                    zoomControlsEnabled: true,
                                    scrollGesturesEnabled: true,
                                    rotateGesturesEnabled: true,
                                    tiltGesturesEnabled: true,
                                    zoomGesturesEnabled: true,
                                    // Disable interaction to prevent accidental scrolling
                                    // This map is primarily for display
                                    // You can enable some for better user experience if needed
                                  ),
                                )),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Description
            if (widget.event.description != null &&
                widget.event.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: widget.event.description!,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Participants
            Text(
              'Participants:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            eventParticipants.isEmpty
                ? Text(
                  'No participants added.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true, // Important for nested list views
                  physics:
                      const NeverScrollableScrollPhysics(), // Important for nested list views
                  itemCount: eventParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = eventParticipants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            participant.avatar != null
                                ? MemoryImage(participant.avatar!)
                                : null,
                        child:
                            participant.avatar == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(participant.displayName ?? ''),
                      subtitle: Text(
                        (participant.phones?.isNotEmpty ?? false)
                            ? participant.phones!.first.number ?? 'No phone'
                            : 'No phone',
                      ),
                      // You could add onTap to view contact details
                    );
                  },
                ),
            const SizedBox(height: 20),

            // TODO: Add Edit/Delete buttons if desired
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: row);
    }
    return row;
  }
}
