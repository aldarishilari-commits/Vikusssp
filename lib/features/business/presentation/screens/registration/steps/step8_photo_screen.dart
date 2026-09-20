import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/core/widgets/app_notification.dart';
import 'package:aeronpulse/core/services/storage_service.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 8: Foto del negocio ("Registro del negocio_foto-8.png")
class Step8PhotoScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step8PhotoScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step8PhotoScreen> createState() => _Step8PhotoScreenState();
}

class _Step8PhotoScreenState extends State<Step8PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _uploadStatus = 'Subiendo foto...';

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E0EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Agregar fotos del negocio',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona fotos de la fachada, interior o productos para tu local.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAlt.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryAlt,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Seleccionar de la galería',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  subtitle: Text(
                    'Elige una o varias fotos guardadas',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickMultipleFromGallery();
                  },
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF22C55E),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Tomar foto con la cámara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  subtitle: Text(
                    'Captura una foto ahora mismo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickFromCamera();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (picked == null) return;

      setState(() {
        _isUploading = true;
        _uploadStatus = 'Subiendo foto a Supabase...';
      });

      final uploadedUrl = await StorageService.instance.uploadBusinessPhoto(
        file: picked,
        businessId: widget.data.id,
      );

      if (mounted) {
        setState(() {
          widget.data.photoUrls.add(uploadedUrl);
          _isUploading = false;
        });
        AppNotification.showSuccess(context, 'Foto subida y guardada');
      }
    } catch (e) {
      debugPrint('Error al capturar foto con cámara: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        AppNotification.showError(
          context,
          'No se pudo subir la foto: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _pickMultipleFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFiles.isEmpty) return;

      setState(() {
        _isUploading = true;
        _uploadStatus = 'Subiendo 1 de ${pickedFiles.length}...';
      });

      final uploadedUrls = await StorageService.instance.uploadMultipleBusinessPhotos(
        files: pickedFiles,
        businessId: widget.data.id,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _uploadStatus = 'Subiendo $current de $total...';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          widget.data.photoUrls.addAll(uploadedUrls);
          _isUploading = false;
        });
        AppNotification.showSuccess(
          context,
          '${uploadedUrls.length} ${uploadedUrls.length == 1 ? "foto subida" : "fotos subidas"}',
        );
      }
    } catch (e) {
      debugPrint('Error al seleccionar fotos de galería: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        AppNotification.showError(
          context,
          'Error al subir fotos: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < widget.data.photoUrls.length) {
      final removedUrl = widget.data.photoUrls[index];
      setState(() {
        widget.data.photoUrls.removeAt(index);
      });
      StorageService.instance.deleteBusinessPhotoByUrl(removedUrl);
      AppNotification.showInfo(context, 'Foto eliminada');
    }
  }

  Widget _buildPhotoWidget(String pathOrUrl, {BoxFit fit = BoxFit.cover}) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryAlt,
              strokeWidth: 2.5,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 36,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    } else {
      if (!kIsWeb) {
        return Image.file(
          File(pathOrUrl),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 36,
              color: Color(0xFF9CA3AF),
            ),
          ),
        );
      } else {
        return const Center(
          child: Icon(
            Icons.photo_rounded,
            size: 36,
            color: Color(0xFF9CA3AF),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = widget.data.photoUrls.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RegistrationHeader(
            buttonText: 'Guardar y salir',
            onExit: widget.onExit,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            '¿Quieres agregar fotos de tu\nnegocio?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 24),

          // Main Photo Upload Box / Cover Preview
          GestureDetector(
            onTap: _isUploading ? null : _showImageSourceModal,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E0EA),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhotos) ...[
                    // Primary cover photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _buildPhotoWidget(widget.data.photoUrls.first),
                    ),
                    // Badge "Foto de portada"
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFEB700),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Portada principal',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Delete button for cover photo
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _removePhoto(0),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Placeholder when no photos yet (Exact original visual layout)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF1B1C1C),
                                    width: 2.5,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1B1C1C),
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Color(0xFF1B1C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Toca para agregar fotos',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B1C1C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Galería o Cámara',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Loading overlay during upload
                  if (_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _uploadStatus,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

          // Additional Photos Horizontal List (if photos exist)
          if (hasPhotos) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotos agregadas (${widget.data.photoUrls.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                if (!_isUploading)
                  GestureDetector(
                    onTap: _showImageSourceModal,
                    child: Text(
                      '+ Agregar más',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryAlt,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.data.photoUrls.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  // Last item is "+ Agregar" button
                  if (index == widget.data.photoUrls.length) {
                    return GestureDetector(
                      onTap: _isUploading ? null : _showImageSourceModal,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E0EA),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.primaryAlt,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }

                  final photoUrl = widget.data.photoUrls[index];
                  final isCover = index == 0;

                  return Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCover ? AppColors.primaryAlt : const Color(0xFFE5E0EA),
                            width: isCover ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildPhotoWidget(photoUrl),
                        ),
                      ),
                      // Small delete badge
                      Positioned(
                        top: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          const Spacer(),

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
