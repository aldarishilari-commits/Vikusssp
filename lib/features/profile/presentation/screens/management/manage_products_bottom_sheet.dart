import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_notification.dart';
import 'add_product_bottom_sheet.dart';

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

  /// Muestra el listado de gestión de productos
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

  /// Atajo para abrir directamente el formulario de creación de producto
  static Future<bool?> showAddProduct(
    BuildContext context, {
    required String businessId,
    required VoidCallback onUpdated,
    BusinessItemModel? existing,
  }) {
    return AddProductBottomSheet.show(
      context,
      businessId: businessId,
      existing: existing,
      onSaved: onUpdated,
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
    final result = await AddProductBottomSheet.show(
      context,
      businessId: widget.businessId,
      existing: existing,
      onSaved: () {
        widget.onUpdated();
      },
    );

    if (result == true) {
      setState(() => _isLoading = true);
      await _reloadProducts(force: true);
      widget.onUpdated();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(BusinessItemModel item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar producto',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
        ),
        content: Text(
          '¿Deseas eliminar "${item.name}" del catálogo?',
          style: GoogleFonts.inter(
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
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
          AppNotification.showSuccess(context, 'Producto eliminado exitosamente');
        }
      } catch (e) {
        if (mounted) {
          AppNotification.showError(context, 'Error al eliminar: $e');
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
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
          const SizedBox(height: 14),

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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
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
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Aún no tienes productos registrados',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Agrega artículos a tu menú o catálogo para que los clientes puedan verlos y comprarlos.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () => _openCreateOrEditProductDialog(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Agregar Primer Producto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = _products[i];
                          final hasDiscount = item.flashPrice != null &&
                              item.flashPrice! > 0 &&
                              item.flashPrice! < item.price;
                          final discountPct = hasDiscount
                              ? (((item.price - item.flashPrice!) / item.price) * 100).round()
                              : 0;

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
                                  child: item.imageUrl.isNotEmpty
                                      ? Image.network(
                                          item.imageUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 64,
                                            height: 64,
                                            color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                                            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
                                          ),
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                                          child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
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
                                          fontSize: 14.5,
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
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          if (hasDiscount) ...[
                                            Text(
                                              'Bs ${item.flashPrice!.toStringAsFixed(0)}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF22C55E),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Bs ${item.price.toStringAsFixed(0)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF9CA3AF),
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '-$discountPct%',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF22C55E),
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              'Bs ${item.price.toStringAsFixed(0)}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        size: 19,
                                        color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                                      ),
                                      onPressed: () => _openCreateOrEditProductDialog(item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFEF4444)),
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
