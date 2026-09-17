import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aeronpulse/core/services/location_service.dart';
import 'package:aeronpulse/core/services/google_places_service.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_map_view.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 5: Ubicación confirmada ("Registro del negocio_ubicación_despues-5.png")
class Step5LocationConfirmedScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step5LocationConfirmedScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step5LocationConfirmedScreen> createState() =>
      _Step5LocationConfirmedScreenState();
}

class _Step5LocationConfirmedScreenState
    extends State<Step5LocationConfirmedScreen> {
  late final TextEditingController _addressController;
  final GlobalKey<RegistrationMapViewState> _mapKey = GlobalKey<RegistrationMapViewState>();
  final GooglePlacesService _placesService = GooglePlacesService();
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.data.address.isEmpty) {
      widget.data.address = 'Av. Pando, La Paz';
    }
    _addressController = TextEditingController(text: widget.data.address);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      _addressController.clear();
      widget.data.address = '';
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final position = await LocationService.getCurrentPosition();
    if (position != null && mounted) {
      final address = await _placesService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      final finalAddress = address ?? 'Ubicación actual';

      setState(() {
        widget.data.latitude = position.latitude;
        widget.data.longitude = position.longitude;
        widget.data.address = finalAddress;
        widget.data.isLocationConfirmed = true;
        _addressController.text = finalAddress;
        _isLoadingLocation = false;
      });

      _mapKey.currentState?.animateToLocation(
        LatLng(position.latitude, position.longitude),
      );
    } else if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _onMapLocationChanged(LatLng position) async {
    widget.data.latitude = position.latitude;
    widget.data.longitude = position.longitude;
    widget.data.isLocationConfirmed = true;

    final address = await _placesService.reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (mounted && address != null && address.isNotEmpty) {
      setState(() {
        widget.data.address = address;
        _addressController.text = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RegistrationHeader(
            buttonText: 'Guardar y salir',
            onExit: widget.onExit,
            progress: 0.50,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            '¿Donde está tu negocio?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 20),

          // Search Bar with Address & (X) Clear Button
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE5E0EA),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B1C1C),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      widget.data.address = val;
                    },
                  ),
                ),
                GestureDetector(
                  onTap: _clearSearch,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 14, left: 6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Map Container with Confirmed Pin
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RegistrationMapView(
                    key: _mapKey,
                    latitude: widget.data.latitude,
                    longitude: widget.data.longitude,
                    showPin: true,
                    isInteractive: true,
                    locationName: widget.data.address,
                    onLocationChanged: _onMapLocationChanged,
                  ),
                  const SizedBox(height: 18),

                  // "Usar mi ubicación actual" button
                  GestureDetector(
                    onTap: _isLoadingLocation ? null : _useCurrentLocation,
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoadingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2563EB),
                              ),
                            )
                          else
                            const Icon(
                              Icons.my_location_rounded,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _isLoadingLocation ? 'Obteniendo GPS...' : 'Usar mi ubicacion actual',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar
          RegistrationBottomBar(
            onBack: widget.onBack,
            onNext: widget.onNext,
            nextText: 'Siguiente',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
