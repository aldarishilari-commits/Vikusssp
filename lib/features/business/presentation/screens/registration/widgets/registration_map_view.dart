import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget de mapa interactivo y resiliente para el registro de negocios en VikusApp.
/// Soporta Google Maps nativo y cuenta con visualizador de mapas interactivo de alta fidelidad.
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
  final bool _isGoogleMapWorking = true;
  double _zoomLevel = 16.0;

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
  Future<void> animateToLocation(LatLng target, {double? zoom}) async {
    setState(() {
      _currentLatLng = target;
      if (zoom != null) _zoomLevel = zoom;
    });

    if (_mapController != null) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: zoom ?? _zoomLevel),
          ),
        );
      } catch (_) {}
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
            // 1. Google Map or Interactive Tile Map
            if (_isGoogleMapWorking)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng,
                  zoom: _zoomLevel,
                ),
                markers: _buildMarkers(),
                onMapCreated: (controller) {
                  _mapController = controller;
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
              )
            else
              _buildInteractiveFallbackMap(),

            // 2. Interactive Fallback Pin if not using Google Markers
            if (!_isGoogleMapWorking && widget.showPin)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          widget.locationName ?? 'Tu Negocio Aquí',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 42,
                        color: Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Prominent Banner Hint: "Toca el mapa para reubicar el pin"
            if (widget.isInteractive)
              Positioned(
                bottom: 12,
                left: 12,
                right: 56,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
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

            // 4. Zoom Controls (+ / -)
            if (widget.isInteractive)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        final newZoom = (_zoomLevel + 1.0).clamp(10.0, 19.0);
                        animateToLocation(_currentLatLng, zoom: newZoom);
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        final newZoom = (_zoomLevel - 1.0).clamp(10.0, 19.0);
                        animateToLocation(_currentLatLng, zoom: newZoom);
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

  Widget _buildInteractiveFallbackMap() {
    final zoom = _zoomLevel.round();
    final n = math.pow(2.0, zoom).toDouble();
    final x = (((_currentLatLng.longitude + 180.0) / 360.0) * n).floor();
    final latRad = _currentLatLng.latitude * math.pi / 180.0;
    final y = (((1.0 - (math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi)) / 2.0) * n).floor();

    final tileUrl = 'https://tile.openstreetmap.org/$zoom/$x/$y.png';

    return GestureDetector(
      onTapDown: (details) {
        if (!widget.isInteractive) return;
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final local = details.localPosition;
          final dx = (local.dx - size.width / 2) / size.width;
          final dy = (local.dy - size.height / 2) / size.height;

          final factor = 0.005 / math.pow(2, _zoomLevel - 14);
          final newLat = _currentLatLng.latitude - (dy * factor);
          final newLng = _currentLatLng.longitude + (dx * factor);
          final newPos = LatLng(newLat, newLng);

          setState(() => _currentLatLng = newPos);
          widget.onLocationChanged?.call(newPos);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic Map Tile
          Image.network(
            tileUrl,
            fit: BoxFit.cover,
            headers: const {'User-Agent': 'VikusApp/1.0'},
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_rounded, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 8),
                      Text(
                        'Vista de Mapa Interactivo',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Map gridlines effect
          CustomPaint(
            painter: _MapGridPainter(),
          ),
        ],
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
