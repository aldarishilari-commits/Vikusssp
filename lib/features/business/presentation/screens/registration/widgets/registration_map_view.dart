import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as osm;

/// Widget de mapa interactivo para el registro de negocios en VikusApp.
/// Utiliza OpenStreetMap (vía flutter_map) con soporte para reubicar el pin al tocar,
/// controles de zoom y animaciones suaves de cámara sin depender de Google Maps visual.
class RegistrationMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool showPin;
  final bool isInteractive;
  final double height;
  final ValueChanged<gmaps.LatLng>? onLocationChanged;
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

class RegistrationMapViewState extends State<RegistrationMapView>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late double _currentLat;
  late double _currentLng;
  double _currentZoom = 15.5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
      _animatedMapMove(
        osm.LatLng(_currentLat, _currentLng),
        _currentZoom,
      );
    }
  }

  /// Mueve la cámara suavemente a una nueva posición (acepta latlong2.LatLng o google_maps_flutter.LatLng)
  void animateToLocation(dynamic target, {double? zoom}) {
    final double lat;
    final double lng;
    if (target is osm.LatLng) {
      lat = target.latitude;
      lng = target.longitude;
    } else {
      lat = (target.latitude as num).toDouble();
      lng = (target.longitude as num).toDouble();
    }

    setState(() {
      _currentLat = lat;
      _currentLng = lng;
      if (zoom != null) _currentZoom = zoom;
    });

    _animatedMapMove(
      osm.LatLng(lat, lng),
      zoom ?? _currentZoom,
    );
  }

  void _animatedMapMove(osm.LatLng destLocation, double destZoom) {
    try {
      final camera = _mapController.camera;
      final latTween = Tween<double>(
        begin: camera.center.latitude,
        end: destLocation.latitude,
      );
      final lngTween = Tween<double>(
        begin: camera.center.longitude,
        end: destLocation.longitude,
      );
      final zoomTween = Tween<double>(
        begin: camera.zoom,
        end: destZoom,
      );

      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      final Animation<double> animation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      );

      controller.addListener(() {
        _mapController.move(
          osm.LatLng(
            latTween.evaluate(animation),
            lngTween.evaluate(animation),
          ),
          zoomTween.evaluate(animation),
        );
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      });

      controller.forward();
    } catch (_) {
      // Fallback si la cámara aún no está inicializada
      _mapController.move(destLocation, destZoom);
    }
  }

  void _handleTap(osm.LatLng position) {
    if (!widget.isInteractive) return;

    setState(() {
      _currentLat = position.latitude;
      _currentLng = position.longitude;
    });

    _animatedMapMove(position, _currentZoom);
    widget.onLocationChanged?.call(
      gmaps.LatLng(position.latitude, position.longitude),
    );
  }

  void _recenterOnPin() {
    final pinPos = osm.LatLng(_currentLat, _currentLng);
    _animatedMapMove(pinPos, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final osm.LatLng pinPosition = osm.LatLng(_currentLat, _currentLng);

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
            // 1. OpenStreetMap con flutter_map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pinPosition,
                initialZoom: _currentZoom,
                minZoom: 3.0,
                maxZoom: 18.5,
                onTap: (tapPosition, point) => _handleTap(point),
                interactionOptions: InteractionOptions(
                  flags: widget.isInteractive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aeronpulse.app',
                ),
                if (widget.showPin)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pinPosition,
                        width: 44,
                        height: 52,
                        alignment: Alignment.topCenter,
                        child: _buildPinWidget(),
                      ),
                    ],
                  ),
              ],
            ),

            // 2. Etiqueta flotante OpenStreetMap
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      size: 13,
                      color: Color(0xFF0284C7), // Sky blue
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'OpenStreetMap',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Cartel flotante: "📍 Toca el mapa para reubicar el pin"
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

            // 4. Botones de Zoom (+ / -) y Recentrar
            if (widget.isInteractive)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _buildControlButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Acercar',
                      onTap: () {
                        _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
                        _animatedMapMove(
                          osm.LatLng(_currentLat, _currentLng),
                          _currentZoom,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildControlButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Alejar',
                      onTap: () {
                        _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
                        _animatedMapMove(
                          osm.LatLng(_currentLat, _currentLng),
                          _currentZoom,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildControlButton(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Centrar en el pin',
                      iconColor: const Color(0xFF7C3AED),
                      onTap: _recenterOnPin,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(color: const Color(0xFF6D28D9)),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
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
            size: 19,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

