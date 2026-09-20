import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget de mapa interactivo para el registro de negocios en VikusApp.
/// Utiliza Google Maps oficial con soporte para reubicar el pin al tocar, arrastrar el mapa y zoom.
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
  late double _currentLat;
  late double _currentLng;
  double _currentZoom = 15.5;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.latitude;
    _currentLng = widget.longitude;
  }

  @override
  void didUpdateWidget(covariant RegistrationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _currentLat = widget.latitude;
      _currentLng = widget.longitude;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_currentLat, _currentLng)),
      );
    }
  }

  /// Mueve la cámara suavemente a una nueva posición
  void animateToLocation(LatLng target, {double? zoom}) {
    setState(() {
      _currentLat = target.latitude;
      _currentLng = target.longitude;
      if (zoom != null) _currentZoom = zoom;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(target.latitude, target.longitude),
        zoom ?? _currentZoom,
      ),
    );
  }

  void _handleTap(LatLng position) {
    if (!widget.isInteractive) return;

    setState(() {
      _currentLat = position.latitude;
      _currentLng = position.longitude;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );

    widget.onLocationChanged?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng pinPosition = LatLng(_currentLat, _currentLng);

    final Set<Marker> markers = widget.showPin
        ? {
            Marker(
              markerId: const MarkerId('business_pin'),
              position: pinPosition,
              draggable: widget.isInteractive,
              onDragEnd: (newPosition) {
                setState(() {
                  _currentLat = newPosition.latitude;
                  _currentLng = newPosition.longitude;
                });
                widget.onLocationChanged?.call(newPosition);
              },
              infoWindow: widget.locationName != null &&
                      widget.locationName!.isNotEmpty
                  ? InfoWindow(title: widget.locationName)
                  : const InfoWindow(title: 'Ubicación de tu negocio'),
            ),
          }
        : {};

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.5),
        child: Stack(
          children: [
            // 1. Google Maps Oficial
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: pinPosition,
                zoom: _currentZoom,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: _handleTap,
              markers: markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: widget.isInteractive,
              zoomGesturesEnabled: widget.isInteractive,
              rotateGesturesEnabled: widget.isInteractive,
              tiltGesturesEnabled: false,
            ),

            // 2. Cartel flotante: "📍 Toca el mapa para reubicar el pin"
            if (widget.isInteractive)
              Positioned(
                bottom: 12,
                left: 12,
                right: 58,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.touch_app_rounded,
                            size: 15,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Toca el mapa para reubicar el pin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Botones de Zoom (+ / -)
            if (widget.isInteractive)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        _currentZoom = (_currentZoom + 1).clamp(10.0, 20.0);
                        _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        _currentZoom = (_currentZoom - 1).clamp(10.0, 20.0);
                        _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
