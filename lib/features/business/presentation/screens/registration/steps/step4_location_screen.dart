import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aeronpulse/core/services/google_places_service.dart';
import 'package:aeronpulse/core/services/location_service.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_map_view.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 4: Ubicación ("Registro del negocio_ubicación-4.png")
class Step4LocationScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step4LocationScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step4LocationScreen> createState() => _Step4LocationScreenState();
}

class _Step4LocationScreenState extends State<Step4LocationScreen> {
  late final TextEditingController _searchController;
  final GlobalKey<RegistrationMapViewState> _mapKey = GlobalKey<RegistrationMapViewState>();
  final GooglePlacesService _placesService = GooglePlacesService();

  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.data.address.isNotEmpty && widget.data.address != 'Av. Pando, La Paz'
          ? widget.data.address
          : '',
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _isSearching = true;
      });

      final results = await _placesService.getAutocompletePredictions(query);
      if (mounted) {
        setState(() {
          _predictions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _predictions = [];
      _searchController.text = prediction.mainText;
    });

    final details = await _placesService.getPlaceDetails(prediction.placeId);
    if (details != null && mounted) {
      setState(() {
        widget.data.address = details.address.isNotEmpty ? details.address : prediction.description;
        widget.data.latitude = details.latitude;
        widget.data.longitude = details.longitude;
        widget.data.isLocationConfirmed = true;
        _searchController.text = widget.data.address;
      });

      _mapKey.currentState?.animateToLocation(
        LatLng(details.latitude, details.longitude),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingLocation = true;
      _predictions = [];
    });

    final position = await LocationService.getCurrentPosition();

    if (position != null && mounted) {
      final lat = position.latitude;
      final lng = position.longitude;

      // Reverse geocode to get real street address
      final address = await _placesService.reverseGeocode(lat, lng);
      final finalAddress = address ?? 'Ubicación actual (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

      setState(() {
        widget.data.latitude = lat;
        widget.data.longitude = lng;
        widget.data.address = finalAddress;
        widget.data.isLocationConfirmed = true;
        _searchController.text = finalAddress;
        _isLoadingLocation = false;
      });

      _mapKey.currentState?.animateToLocation(LatLng(lat, lng));
    } else if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación GPS. Verifica los permisos de ubicación.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onMapLocationChanged(LatLng position) async {
    widget.data.latitude = position.latitude;
    widget.data.longitude = position.longitude;
    widget.data.isLocationConfirmed = true;

    final address = await _placesService.reverseGeocode(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        if (address != null && address.isNotEmpty) {
          widget.data.address = address;
          _searchController.text = address;
        }
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
            progress: 0.45,
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

          // Search Bar & Autocomplete suggestions
          Column(
            children: [
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
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF1B1C1C),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar dirección o zona',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFA09FA1),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _predictions = [];
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Suggestions dropdown
              if (_predictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E0EA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _predictions.length,
                    separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final pred = _predictions[index];
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                        title: Text(
                          pred.mainText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        subtitle: pred.secondaryText.isNotEmpty
                            ? Text(
                                pred.secondaryText,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => _selectPrediction(pred),
                      );
                    },
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Map Container & Location Button
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
                    locationName: widget.data.address.isNotEmpty ? widget.data.address : null,
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
                            _isLoadingLocation ? 'Obteniendo GPS...' : 'Usar mi ubicación actual',
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
            onNext: () {
              if (widget.data.address.isEmpty) {
                widget.data.address = 'Av. Pando, La Paz';
              }
              widget.data.isLocationConfirmed = true;
              widget.onNext();
            },
            nextText: 'Siguiente',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
