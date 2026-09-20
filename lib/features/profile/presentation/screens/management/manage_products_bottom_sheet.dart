import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/business_service.dart';
import '../../../../../core/services/storage_service.dart';

class ManageProductsBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final List<BusinessItemModel> initialProducts;
  final VoidCallback onUpdated;

  const ManageProductsBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.initialProducts,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    required List<BusinessItemModel> initialProducts,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageProductsBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialProducts: initialProducts,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageProductsBottomSheet> createState() => _ManageProductsBottomSheetState();
}

class _ManageProductsBottomSheetState extends State<ManageProductsBottomSheet> {
  late List<BusinessItemModel> _products;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _products = List.from(widget.initialProducts);
    _reloadProducts();
  }

  Future<void> _reloadProducts({bool force = false}) async {
    try {
      final items = await BusinessService.instance.getBusinessItems(widget.businessId);
      if (mounted && (items.isNotEmpty || force)) {
        setState(() {
          _products = items.where((it) => it.itemType == 'product' && !it.isFlashOffer).toList();
        });
      }
    } catch (e) {
      debugPrint('Error al recargar productos: $e');
    }
  }

  Future<void> _openCreateOrEditProductDialog([BusinessItemModel? existing]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductFormSheet(
        businessId: widget.businessId,
        existing: existing,
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      await _reloadProducts(force: true);
      widget.onUpdated();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(BusinessItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Deseas eliminar "${item.name}" del catálogo?'),
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
        await BusinessService.instance.deleteBusinessItem(item.id);
        if (item.imageUrl.isNotEmpty && item.imageUrl.contains('business-photos')) {
          await StorageService.instance.deleteBusinessPhotoByUrl(item.imageUrl);
        }
        await _reloadProducts(force: true);
        widget.onUpdated();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado exitosamente')),
          );
        }
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
              color: isDark ? const Color(0xFF3F3D47) : const Color(0xFFE5E0EA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Add Product Button
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
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Productos',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          '${_products.length} ${_products.length == 1 ? "producto registrado" : "productos registrados"}',
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
                  onPressed: () => _openCreateOrEditProductDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
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

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD97706)))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFD97706), size: 30),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes productos registrados',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Agrega artículos a tu menú o catálogo para vender más.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openCreateOrEditProductDialog(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Agregar Primer Producto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = _products[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFE5E0EA),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.imageUrl.isNotEmpty ? item.imageUrl : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 60,
                                      height: 60,
                                      color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFD97706)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.description.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Bs ${item.price.toStringAsFixed(0)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFFD97706),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (item.availableQuantity > 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Stock: ${item.availableQuantity}',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: item.availableQuantity > 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6B7280)),
                                      onPressed: () => _openCreateOrEditProductDialog(item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(height: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                      onPressed: () => _deleteProduct(item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Formulario Modal para Crear o Editar un Producto con selector de foto (Cámara / Galería)
class _ProductFormSheet extends StatefulWidget {
  final String businessId;
  final BusinessItemModel? existing;

  const _ProductFormSheet({
    required this.businessId,
    this.existing,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  final ImagePicker _picker = ImagePicker();

  String? _imageUrl;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existing != null ? widget.existing!.price.toStringAsFixed(0) : '',
    );
    _qtyCtrl = TextEditingController(
      text: widget.existing != null ? widget.existing!.availableQuantity.toString() : '20',
    );
    _imageUrl = widget.existing?.imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _showImageSourceModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
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
                      color: isDark ? const Color(0xFF3F3D47) : const Color(0xFFE5E0EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Foto del producto',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona una foto atractiva para tu producto en el catálogo.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFFD97706),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Seleccionar de la galería',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
                  ),
                  subtitle: Text(
                    'Elige una imagen de tu galería de fotos',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.12),
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
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
                  ),
                  subtitle: Text(
                    'Captura una foto ahora mismo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickAndUploadPhoto(ImageSource.camera);
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

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (file == null) return;

      setState(() => _isUploadingPhoto = true);

      final uploadedUrl = await StorageService.instance.uploadBusinessPhoto(
        file: file,
        businessId: widget.businessId,
      );

      if (mounted) {
        setState(() {
          _imageUrl = uploadedUrl;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto del producto subida con éxito a Supabase'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al subir foto de producto: $e');
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo subir la foto: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameCtrl.text.trim();
    final priceStr = _priceCtrl.text.trim();
    final qtyStr = _qtyCtrl.text.trim();

    if (name.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa nombre y precio del producto.')),
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 0.0;
    final qty = int.tryParse(qtyStr) ?? 10;
    final img = (_imageUrl != null && _imageUrl!.trim().isNotEmpty)
        ? _imageUrl!.trim()
        : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80';

    setState(() => _isSaving = true);

    try {
      if (widget.existing == null) {
        final newItem = BusinessItemModel(
          id: '',
          businessId: widget.businessId,
          itemType: 'product',
          name: name,
          description: _descCtrl.text.trim(),
          price: price,
          isFlashOffer: false,
          availableQuantity: qty,
          imageUrl: img,
          isAvailable: true,
        );
        await BusinessService.instance.addBusinessItem(newItem);
      } else {
        final updated = widget.existing!.copyWith(
          name: name,
          description: _descCtrl.text.trim(),
          price: price,
          availableQuantity: qty,
          imageUrl: img,
        );
        await BusinessService.instance.updateBusinessItem(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existing == null ? 'Producto agregado con éxito' : 'Producto actualizado'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar producto: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existing != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3D47) : const Color(0xFFE5E0EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFD97706), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar Producto' : 'Nuevo Producto',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          'Configura los datos y foto de tu producto',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Nombre del producto
              Text(
                'Nombre del producto *',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4E4356),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA),
                  ),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. Pizza Familiar Hawaiana',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFFA09FA1),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Descripción / Ingredientes
              Text(
                'Descripción / Ingredientes (opcional)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4E4356),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA),
                  ),
                ),
                child: TextField(
                  controller: _descCtrl,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. Masa artesanal, jamón, piña y queso mozzarella',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFFA09FA1),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Precio y Stock Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio (Bs) *',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4E4356),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA),
                            ),
                          ),
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 14, right: 8),
                                child: Text(
                                  'Bs',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: '65',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF6B7280) : const Color(0xFFA09FA1),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock disponible',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4E4356),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA),
                            ),
                          ),
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                            ),
                            decoration: InputDecoration(
                              hintText: '20',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF6B7280) : const Color(0xFFA09FA1),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Foto del producto (Cámara / Galería Modal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foto del producto',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4E4356),
                    ),
                  ),
                  if (_imageUrl != null && _imageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: _showImageSourceModal,
                      child: Text(
                        'Cambiar foto',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isUploadingPhoto ? null : _showImageSourceModal,
                child: Container(
                  height: (_imageUrl != null && _imageUrl!.isNotEmpty) ? 140 : 88,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_imageUrl != null && _imageUrl!.isNotEmpty)
                          ? const Color(0xFFD97706)
                          : (isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA)),
                      width: (_imageUrl != null && _imageUrl!.isNotEmpty) ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isUploadingPhoto)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD97706),
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subiendo foto a Supabase...',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: 32,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Botón de eliminar foto arriba a la derecha
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageUrl = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        // Chip de "Toca para cambiar" abajo a la izquierda
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Toca para cambiar',
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
                      ] else ...[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 22,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Toca para agregar foto',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                    ),
                                  ),
                                  Text(
                                    'Galería o Cámara',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E0EA),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF4E4356),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (_isSaving || _isUploadingPhoto) ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEditing ? 'Guardar Cambios' : 'Agregar Producto',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
