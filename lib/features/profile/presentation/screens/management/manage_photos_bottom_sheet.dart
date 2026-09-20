import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';

class ManagePhotosBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final List<BusinessPhotoModel> initialPhotos;
  final VoidCallback onUpdated;

  const ManagePhotosBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.initialPhotos,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    required List<BusinessPhotoModel> initialPhotos,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManagePhotosBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialPhotos: initialPhotos,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManagePhotosBottomSheet> createState() => _ManagePhotosBottomSheetState();
}

class _ManagePhotosBottomSheetState extends State<ManagePhotosBottomSheet> {
  late List<BusinessPhotoModel> _photos;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.initialPhotos);
    _reloadPhotos();
  }

  Future<void> _reloadPhotos() async {
    final details = await BusinessService.instance.getMyBusiness();
    if (mounted && details != null) {
      setState(() {
        _photos = details.photos;
      });
    }
  }

  void _openAddPhotoDialog() {
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Agregar Foto',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen *',
                  hintText: 'https://images.unsplash.com/...',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Ejemplo Local'),
                    onPressed: () {
                      urlCtrl.text = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80';
                    },
                  ),
                  ActionChip(
                    label: const Text('Ejemplo Comida'),
                    onPressed: () {
                      urlCtrl.text = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80';
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (urlCtrl.text.trim().isEmpty) return;

                Navigator.of(ctx).pop();
                setState(() => _isLoading = true);

                try {
                  await BusinessService.instance.addBusinessPhoto(widget.businessId, urlCtrl.text.trim());
                  await _reloadPhotos();
                  widget.onUpdated();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              child: const Text('Subir Foto'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhoto(BusinessPhotoModel photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Deseas eliminar esta foto de la galería?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await BusinessService.instance.deleteBusinessPhoto(photo.id);
        await _reloadPhotos();
        widget.onUpdated();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3F3D47) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Color(0xFF3B82F6), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fotos del Negocio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          '${_photos.length} ${_photos.length == 1 ? "foto en galería" : "fotos en galería"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openAddPhotoDialog,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6)),

          // Photo Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : _photos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library_outlined, color: Color(0xFF3B82F6), size: 30),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes fotos adicionales',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sube imágenes de tu local para mostrarlo a tus clientes.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _openAddPhotoDialog,
                              icon: const Icon(Icons.add_a_photo_rounded),
                              label: const Text('Subir Primera Foto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, i) {
                          final photo = _photos[i];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  photo.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                                    child: const Icon(Icons.broken_image_rounded, color: Color(0xFF9CA3AF)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () => _deletePhoto(photo),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 16),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Foto ${i + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
