import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';

class ManageOffersBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final List<BusinessItemModel> initialOffers;
  final VoidCallback onUpdated;

  const ManageOffersBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.initialOffers,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    required List<BusinessItemModel> initialOffers,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageOffersBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialOffers: initialOffers,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageOffersBottomSheet> createState() => _ManageOffersBottomSheetState();
}

class _ManageOffersBottomSheetState extends State<ManageOffersBottomSheet> {
  late List<BusinessItemModel> _offers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _offers = List.from(widget.initialOffers);
    _reloadOffers();
  }

  Future<void> _reloadOffers() async {
    final items = await BusinessService.instance.getBusinessItems(widget.businessId);
    if (mounted) {
      setState(() {
        _offers = items.where((it) => it.isFlashOffer).toList();
      });
    }
  }

  void _openCreateOrEditOfferDialog([BusinessItemModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final normalPriceCtrl = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '');
    final flashPriceCtrl = TextEditingController(text: existing != null && existing.flashPrice != null ? existing.flashPrice!.toStringAsFixed(0) : '');
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    final qtyCtrl = TextEditingController(text: existing != null ? existing.availableQuantity.toString() : '10');

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
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                existing == null ? 'Nueva Oferta Flash' : 'Editar Oferta',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Título de la oferta *', hintText: 'Ej. 2x1 en Pizzas Medianas'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción breve', hintText: 'Aplica solo para consumo en salón o delivery'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: normalPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Precio normal (Bs) *', hintText: '80'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: flashPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Precio oferta (Bs) *', hintText: '50'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL de imagen (opcional)', hintText: 'https://...'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock disponible', hintText: '10'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || normalPriceCtrl.text.trim().isEmpty || flashPriceCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor completa el nombre y los precios.')),
                  );
                  return;
                }

                Navigator.of(ctx).pop();
                setState(() => _isLoading = true);

                try {
                  final nPrice = double.tryParse(normalPriceCtrl.text.trim()) ?? 0.0;
                  final fPrice = double.tryParse(flashPriceCtrl.text.trim()) ?? nPrice;
                  final qty = int.tryParse(qtyCtrl.text.trim()) ?? 10;
                  final img = imageCtrl.text.trim().isNotEmpty
                      ? imageCtrl.text.trim()
                      : 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80';

                  if (existing == null) {
                    final newItem = BusinessItemModel(
                      id: '',
                      businessId: widget.businessId,
                      itemType: 'product',
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: nPrice,
                      flashPrice: fPrice,
                      isFlashOffer: true,
                      availableQuantity: qty,
                      imageUrl: img,
                      isAvailable: true,
                    );
                    await BusinessService.instance.addBusinessItem(newItem);
                  } else {
                    final updated = existing.copyWith(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: nPrice,
                      flashPrice: fPrice,
                      availableQuantity: qty,
                      imageUrl: img,
                    );
                    await BusinessService.instance.updateBusinessItem(updated);
                  }

                  await _reloadOffers();
                  widget.onUpdated();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOffer(BusinessItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar oferta'),
        content: Text('¿Deseas eliminar la oferta "${item.name}"?'),
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
        await _reloadOffers();
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
          // Header Drag Handle
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

          // Title & Add Button Row
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
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ofertas Activas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          '${_offers.length} ${_offers.length == 1 ? "oferta activa" : "ofertas activas"} en Vikus',
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
                  onPressed: () => _openCreateOrEditOfferDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Crear Oferta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
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

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
                : _offers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_offer_outlined, color: Color(0xFFF97316), size: 30),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tienes ofertas activas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Crea una oferta flash para atraer clientes.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openCreateOrEditOfferDialog(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Crear Primera Oferta'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        itemCount: _offers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = _offers[i];
                          final discountPercent = item.price > 0 && item.flashPrice != null
                              ? (((item.price - item.flashPrice!) / item.price) * 100).round()
                              : 0;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.imageUrl.isNotEmpty ? item.imageUrl : 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 64,
                                      height: 64,
                                      color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                                      child: const Icon(Icons.local_fire_department, color: Color(0xFFF97316)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (discountPercent > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEF4444),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '-$discountPercent%',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      if (item.description.isNotEmpty)
                                        Text(
                                          item.description,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Bs ${item.flashPrice?.toStringAsFixed(0) ?? item.price.toStringAsFixed(0)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFFF97316),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Bs ${item.price.toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: const Color(0xFF9CA3AF),
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Stock: ${item.availableQuantity}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
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
                                      onPressed: () => _openCreateOrEditOfferDialog(item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(height: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                      onPressed: () => _deleteOffer(item),
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
