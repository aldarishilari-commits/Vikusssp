import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Widget de mapa interactivo para el registro de negocios en VikusApp.
/// Utiliza OpenStreetMap (OSM) oficial con soporte para reubicar el pin al tocar,
/// arrastrar el mapa, zoom y animaciones suaves.
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

class RegistrationMapViewState extends State<RegistrationMapView>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late double _currentLat;
  late double _currentLng;
  double _currentZoom = 15.5;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLat = widget.latitude;
    _currentLng = widget.longitude;
  }

  @override
  void dispose() {
    _animController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RegistrationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _currentLat = widget.latitude;
      _currentLng = widget.longitude;
      animateToLocation(LatLng(_currentLat, _currentLng));
    }
  }

  /// Mueve la cámara suavemente a una nueva posición
  void animateToLocation(LatLng target, {double? zoom}) {
    final endZoom = zoom ?? _currentZoom;
    setState(() {
      _currentLat = target.latitude;
      _currentLng = target.longitude;
      _currentZoom = endZoom;
    });

    try {
      final camera = _mapController.camera;
      final startCenter = camera.center;
      final startZoom = camera.zoom;

      _animController?.dispose();
      final controller = AnimationController(
        duration: const Duration(milliseconds: 450),
        vsync: this,
      );
      _animController = controller;

      final latTween =
          Tween<double>(begin: startCenter.latitude, end: target.latitude);
      final lngTween =
          Tween<double>(begin: startCenter.longitude, end: target.longitude);
      final zoomTween = Tween<double>(begin: startZoom, end: endZoom);

      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      );

      controller.addListener(() {
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      });

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
          if (_animController == controller) {
            _animController = null;
          }
        }
      });

      controller.forward();
    } catch (_) {
      _mapController.move(target, endZoom);
    }
  }

  void _handleTap(LatLng position) {
    if (!widget.isInteractive) return;

    setState(() {
      _currentLat = position.latitude;
      _currentLng = position.longitude;
    });

    animateToLocation(position);
    widget.onLocationChanged?.call(position);
  }

  void _recenterOnPin() {
    animateToLocation(LatLng(_currentLat, _currentLng));
  }

  @override
  Widget build(BuildContext context) {
    final LatLng pinPosition = LatLng(_currentLat, _currentLng);

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
            // 1. OpenStreetMap nativo con flutter_map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pinPosition,
                initialZoom: _currentZoom,
                minZoom: 3.0,
                maxZoom: 19.0,
                interactionOptions: InteractionOptions(
                  flags: widget.isInteractive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
                onTap: widget.isInteractive
                    ? (tapPosition, point) => _handleTap(point)
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aeronpulse.app',
                  maxZoom: 19,
                ),
                if (widget.showPin)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pinPosition,
                        width: 48,
                        height: 55,
                        alignment: Alignment.topCenter,
                        child: _buildPin(),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
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
                      color: Color(0xFF7C3AED),
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

            // 3. Cartel flotante interactivo: "📍 Toca el mapa para reubicar el pin"
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

            // 4. Botones de Zoom (+ / -) y Recentrado
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
                        final newZoom =
                            (_mapController.camera.zoom + 1).clamp(3.0, 19.0);
                        animateToLocation(_mapController.camera.center,
                            zoom: newZoom);
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildControlButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Alejar',
                      onTap: () {
                        final newZoom =
                            (_mapController.camera.zoom - 1).clamp(3.0, 19.0);
                        animateToLocation(_mapController.camera.center,
                            zoom: newZoom);
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

  Widget _buildPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: const Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 7),
          painter: _TrianglePainter(color: const Color(0xFF6D28D9)),
        ),
        const SizedBox(height: 1),
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
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

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
