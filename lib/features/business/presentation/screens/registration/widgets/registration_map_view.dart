import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget de mapa interactivo para el registro de negocios en VikusApp.
/// Permite arrastrar el mapa, hacer zoom (+ / -) y tocar cualquier punto para reubicar el pin.
/// Funciona de forma 100% garantizada en Web (Vercel), Android, iOS y Desktop.
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
    with SingleTickerProviderStateMixin {
  late double _currentLat;
  late double _currentLng;
  int _zoom = 16;
  late AnimationController _pinAnimController;
  late Animation<double> _pinBounceAnim;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.latitude;
    _currentLng = widget.longitude;

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pinBounceAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RegistrationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      setState(() {
        _currentLat = widget.latitude;
        _currentLng = widget.longitude;
      });
      _triggerPinBounce();
    }
  }

  void _triggerPinBounce() {
    _pinAnimController.forward().then((_) => _pinAnimController.reverse());
  }

  /// Mueve la cámara suavemente a una nueva posición
  void animateToLocation(LatLng target, {int? zoom}) {
    setState(() {
      _currentLat = target.latitude;
      _currentLng = target.longitude;
      if (zoom != null) _zoom = zoom.clamp(12, 19);
    });
    _triggerPinBounce();
  }

  // --- Conversión matemática de coordenadas Web Mercator ---
  double _lngToTileX(double lng, int zoom) {
    final n = math.pow(2.0, zoom);
    return ((lng + 180.0) / 360.0) * n;
  }

  double _latToTileY(double lat, int zoom) {
    final n = math.pow(2.0, zoom);
    final latRad = lat * math.pi / 180.0;
    return (1.0 -
            (math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) / math.pi)) *
        (n / 2.0);
  }

  double _tileXToLng(double tileX, int zoom) {
    final n = math.pow(2.0, zoom);
    return (tileX / n) * 360.0 - 180.0;
  }

  double _tileYToLat(double tileY, int zoom) {
    final n = math.pow(2.0, zoom);
    final sinh = (math.exp(math.pi * (1.0 - (2.0 * tileY / n))) -
            math.exp(-math.pi * (1.0 - (2.0 * tileY / n)))) /
        2.0;
    return math.atan(sinh) * 180.0 / math.pi;
  }

  void _handleTap(Offset localPos, Size size) {
    if (!widget.isInteractive) return;

    final offsetX = localPos.dx - size.width / 2;
    final offsetY = localPos.dy - size.height / 2;

    final centerTileX = _lngToTileX(_currentLng, _zoom);
    final centerTileY = _latToTileY(_currentLat, _zoom);

    final targetTileX = centerTileX + (offsetX / 256.0);
    final targetTileY = centerTileY + (offsetY / 256.0);

    final newLng = _tileXToLng(targetTileX, _zoom);
    final newLat = _tileYToLat(targetTileY, _zoom);

    setState(() {
      _currentLat = newLat;
      _currentLng = newLng;
    });

    _triggerPinBounce();
    widget.onLocationChanged?.call(LatLng(newLat, newLng));
  }

  void _handlePan(DragUpdateDetails details, Size size) {
    if (!widget.isInteractive) return;

    final dxTiles = -details.delta.dx / 256.0;
    final dyTiles = -details.delta.dy / 256.0;

    final centerTileX = _lngToTileX(_currentLng, _zoom) + dxTiles;
    final centerTileY = _latToTileY(_currentLat, _zoom) + dyTiles;

    final newLng = _tileXToLng(centerTileX, _zoom);
    final newLat = _tileYToLat(centerTileY, _zoom);

    setState(() {
      _currentLat = newLat;
      _currentLng = newLng;
    });

    widget.onLocationChanged?.call(LatLng(newLat, newLng));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = widget.height;

        final centerTileXFloat = _lngToTileX(_currentLng, _zoom);
        final centerTileYFloat = _latToTileY(_currentLat, _zoom);

        final centerTileX = centerTileXFloat.floor();
        final centerTileY = centerTileYFloat.floor();

        final maxTile = (math.pow(2, _zoom) - 1).toInt();

        // Calcular tiles visibles alrededor del centro
        final List<Widget> tileWidgets = [];
        for (int dx = -2; dx <= 2; dx++) {
          for (int dy = -2; dy <= 2; dy++) {
            final tX = centerTileX + dx;
            final tY = centerTileY + dy;

            if (tX < 0 || tX > maxTile || tY < 0 || tY > maxTile) continue;

            final tileLeft = (width / 2) + (tX - centerTileXFloat) * 256.0;
            final tileTop = (height / 2) + (tY - centerTileYFloat) * 256.0;

            final sub = ['a', 'b', 'c', 'd'][(tX + tY).abs() % 4];
            final tileUrl =
                'https://$sub.basemaps.cartocdn.com/rastertiles/voyager/$_zoom/$tX/$tY.png';
            final fallbackUrl =
                'https://tile.openstreetmap.org/$_zoom/$tX/$tY.png';

            // Renderizar tile solo si está visible
            if (tileLeft > -256 &&
                tileLeft < width &&
                tileTop > -256 &&
                tileTop < height) {
              tileWidgets.add(
                Positioned(
                  left: tileLeft,
                  top: tileTop,
                  width: 256,
                  height: 256,
                  child: Image.network(
                    tileUrl,
                    fit: BoxFit.cover,
                    headers: const {'User-Agent': 'VikusApp/1.0'},
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      fallbackUrl,
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'VikusApp/1.0'},
                      errorBuilder: (context2, error2, stackTrace2) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.map_outlined,
                              color: Color(0xFFCBD5E1), size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }

        return Container(
          height: height,
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
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Capa interactiva de mapa y tiles
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) => _handleTap(
                          details.localPosition, Size(width, height)),
                      onPanUpdate: (details) =>
                          _handlePan(details, Size(width, height)),
                      onDoubleTap: () {
                        if (_zoom < 19) setState(() => _zoom++);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ...tileWidgets,
                        ],
                      ),
                    ),
                  ),

                  // Pin central con animación y sombra (IgnorePointer para no bloquear toques)
                  if (widget.showPin)
                    Center(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pinAnimController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _pinBounceAnim.value - 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tooltip del nombre del negocio o dirección
                                  if (widget.locationName != null &&
                                      widget.locationName!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      constraints:
                                          BoxConstraints(maxWidth: width * 0.7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black38,
                                              blurRadius: 6,
                                              offset: Offset(0, 2)),
                                        ],
                                      ),
                                      child: Text(
                                        widget.locationName!,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Pin Icon
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 6,
                                        margin: const EdgeInsets.only(top: 36),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 44,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Cartel destacado: "📍 Toca el mapa para reubicar el pin"
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

                  // Botones de Zoom (+ / -)
                  if (widget.isInteractive)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _buildZoomButton(
                            icon: Icons.add_rounded,
                            onTap: () {
                              if (_zoom < 19) {
                                setState(() => _zoom++);
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildZoomButton(
                            icon: Icons.remove_rounded,
                            onTap: () {
                              if (_zoom > 12) {
                                setState(() => _zoom--);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
