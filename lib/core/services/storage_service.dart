import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio para gestionar la subida y almacenamiento de imágenes en Supabase Storage
/// utilizando estrictamente el bucket 'business-photos'.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static StorageService get instance => _instance;

  SupabaseClient get _client => SupabaseConfig.client;

  /// Nombre del bucket oficial en Supabase Storage
  static const String businessPhotosBucket = 'business-photos';

  /// Sube una foto de negocio al bucket 'business-photos' en la ruta:
  /// `<business_id>/<timestamp>_<clean_filename>`
  /// y retorna su URL pública accesible.
  Future<String> uploadBusinessPhoto({
    required XFile file,
    required String businessId,
  }) async {
    try {
      final Uint8List fileBytes = await file.readAsBytes();
      final String extension = file.name.split('.').last.toLowerCase();
      final String mimeType = _resolveMimeType(extension);
      final String cleanFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      
      final String sanitizedBusinessId = businessId.trim().isNotEmpty
          ? businessId.trim()
          : 'general';

      final String path = '$sanitizedBusinessId/$cleanFileName';

      // Subir archivo a Supabase Storage
      await _client.storage.from(businessPhotosBucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final String publicUrl = _client.storage.from(businessPhotosBucket).getPublicUrl(path);
      debugPrint('✅ [StorageService] Foto subida exitosamente a "$businessPhotosBucket": $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ [StorageService] Error al subir foto a Supabase Storage: $e');
      rethrow;
    }
  }

  /// Sube múltiples fotos secuencialmente con callback de progreso
  Future<List<String>> uploadMultipleBusinessPhotos({
    required List<XFile> files,
    required String businessId,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<String> resultUrls = [];
    for (int i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, files.length);
      final url = await uploadBusinessPhoto(
        file: files[i],
        businessId: businessId,
      );
      resultUrls.add(url);
    }
    return resultUrls;
  }

  /// Elimina una foto de Supabase Storage a partir de su URL pública o path
  Future<void> deleteBusinessPhotoByUrl(String photoUrl) async {
    try {
      final uri = Uri.tryParse(photoUrl);
      if (uri == null) return;

      // Extraer la ruta dentro del bucket (después de /business-photos/)
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(businessPhotosBucket);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(businessPhotosBucket).remove([storagePath]);
        debugPrint('🗑️ [StorageService] Foto eliminada de storage: $storagePath');
      }
    } catch (e) {
      debugPrint('⚠️ [StorageService] No se pudo eliminar foto de storage: $e');
    }
  }

  /// Determina el tipo MIME adecuado según la extensión del archivo
  String _resolveMimeType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
