import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio para gestionar la subida y eliminación de imágenes en Supabase Storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static StorageService get instance => _instance;

  SupabaseClient get _client => SupabaseConfig.client;

  /// Lista de buckets candidatos para almacenar fotos de negocios
  static const List<String> _candidateBuckets = [
    'business-photos',
    'photos',
    'businesses',
    'public',
  ];

  /// Subir una imagen de negocio a Supabase Storage y retornar su URL pública
  Future<String> uploadBusinessPhoto({
    required XFile file,
    String? folder,
  }) async {
    final Uint8List fileBytes = await file.readAsBytes();
    final String extension = file.name.split('.').last.toLowerCase();
    final String mimeType = _resolveMimeType(extension);
    final String cleanFileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
    final String path = folder != null && folder.isNotEmpty
        ? '$folder/$cleanFileName'
        : 'businesses/$cleanFileName';

    Exception? lastException;

    for (final bucket in _candidateBuckets) {
      try {
        await _client.storage.from(bucket).uploadBinary(
              path,
              fileBytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );

        final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
        debugPrint('✅ Imagen subida con éxito al bucket "$bucket": $publicUrl');
        return publicUrl;
      } catch (e) {
        lastException = Exception(e.toString());
        debugPrint('⚠️ Intento de subida al bucket "$bucket" falló: $e');
        // Continuar intentando con el siguiente bucket si no se encontró
        continue;
      }
    }

    // Si fallan los buckets específicos, lanzar error descriptivo
    throw Exception(
      'No se pudo subir la imagen a Supabase Storage. '
      'Verifica que exista un bucket público (ej. "business-photos" o "photos") en tu proyecto de Supabase. '
      'Detalle: ${lastException?.toString() ?? "Error desconocido"}',
    );
  }

  /// Sube múltiples fotos secuencialmente con callback de progreso
  Future<List<String>> uploadMultipleBusinessPhotos({
    required List<XFile> files,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<String> uploadedUrls = [];
    for (int i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, files.length);
      final url = await uploadBusinessPhoto(file: files[i]);
      uploadedUrls.add(url);
    }
    return uploadedUrls;
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
