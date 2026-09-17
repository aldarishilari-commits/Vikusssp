import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget de mapa real de Google Maps para el registro de negocio de VikusApp
class RegistrationMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool showPin;
  final bool isInteractive;
  final double height;
  final ValueChanged<LatLng>? onLocationChanged;
  final String? locationName;

  const RegistrationMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.showPin = true,
    this.isInteractive = true,
    this.height = 280,
    this.onLocationChanged,
    this.locationName,
  });

  @override
  State<RegistrationMapView> createState() => RegistrationMapViewState();
}

class RegistrationMapViewState extends State<RegistrationMapView> {
  GoogleMapController? _mapController;
  late LatLng _currentLatLng;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _currentLatLng = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void didUpdateWidget(covariant RegistrationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _currentLatLng = LatLng(widget.latitude, widget.longitude);
      animateToLocation(_currentLatLng);
    }
  }

  /// Mueve la cámara suavemente a una nueva posición
  Future<void> animateToLocation(LatLng target, {double zoom = 16.0}) async {
    _currentLatLng = target;
    if (_mapController != null) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: zoom),
          ),
        );
      } catch (_) {}
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onMapTapped(LatLng position) {
    if (!widget.isInteractive) return;
    setState(() {
      _currentLatLng = position;
    });
    animateToLocation(position);
    widget.onLocationChanged?.call(position);
  }

  Set<Marker> _buildMarkers() {
    if (!widget.showPin) return {};

    return {
      Marker(
        markerId: const MarkerId('business_location_marker'),
        position: _currentLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: widget.locationName != null
            ? InfoWindow(title: widget.locationName)
            : const InfoWindow(title: 'Ubicación seleccionada'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E0EA),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 15.5,
              ),
              markers: _buildMarkers(),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() {
                  _isMapReady = true;
                });
              },
              onTap: _onMapTapped,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: widget.isInteractive,
              scrollGesturesEnabled: widget.isInteractive,
              zoomGesturesEnabled: widget.isInteractive,
              tiltGesturesEnabled: widget.isInteractive,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),

            // Subtle map overlay hint on bottom
            if (widget.isInteractive)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Toca el mapa para reubicar el pin',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Zoom buttons overlay (Top right)
            if (widget.isInteractive && _isMapReady)
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add,
                      onTap: () async {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      icon: Icons.remove,
                      onTap: () async {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}
