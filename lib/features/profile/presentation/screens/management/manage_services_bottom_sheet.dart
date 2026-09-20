import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';

class ManageServicesBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final List<BusinessItemModel> initialServices;
  final VoidCallback onUpdated;

  const ManageServicesBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.initialServices,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    required List<BusinessItemModel> initialServices,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageServicesBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialServices: initialServices,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageServicesBottomSheet> createState() => _ManageServicesBottomSheetState();
}

class _ManageServicesBottomSheetState extends State<ManageServicesBottomSheet> {
  late List<BusinessItemModel> _services;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _services = List.from(widget.initialServices);
    _reloadServices();
  }

  Future<void> _reloadServices() async {
    final items = await BusinessService.instance.getBusinessItems(widget.businessId);
    if (mounted) {
      setState(() {
        _services = items.where((it) => it.itemType == 'service' && !it.isFlashOffer).toList();
      });
    }
  }

  void _openCreateOrEditServiceDialog([BusinessItemModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '');
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');

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
                  color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.room_service_rounded, color: Color(0xFFEAB308), size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                existing == null ? 'Nuevo Servicio' : 'Editar Servicio',
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
                  decoration: const InputDecoration(labelText: 'Nombre del servicio *', hintText: 'Ej. Corte de Cabello y Barba'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Detalles / Duración', hintText: 'Sesión de 45 min con lavado y toalla caliente'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio desde (Bs) *', hintText: '40'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL de foto de referencia', hintText: 'https://...'),
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
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa nombre y precio.')),
                  );
                  return;
                }

                Navigator.of(ctx).pop();
                setState(() => _isLoading = true);

                try {
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  final img = imageCtrl.text.trim().isNotEmpty
                      ? imageCtrl.text.trim()
                      : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80';

                  if (existing == null) {
                    final newItem = BusinessItemModel(
                      id: '',
                      businessId: widget.businessId,
                      itemType: 'service',
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: price,
                      isFlashOffer: false,
                      availableQuantity: 99,
                      imageUrl: img,
                      isAvailable: true,
                    );
                    await BusinessService.instance.addBusinessItem(newItem);
                  } else {
                    final updated = existing.copyWith(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: price,
                      imageUrl: img,
                    );
                    await BusinessService.instance.updateBusinessItem(updated);
                  }

                  await _reloadServices();
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

  Future<void> _deleteService(BusinessItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
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
        await _reloadServices();
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

          // Title & Add Service Button
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
                        color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.room_service_rounded, color: Color(0xFFEAB308), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Servicios',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          '${_services.length} ${_services.length == 1 ? "servicio registrado" : "servicios registrados"}',
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
                  onPressed: () => _openCreateOrEditServiceDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
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

          // Service List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFEAB308)))
                : _services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAB308).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.room_service_outlined, color: Color(0xFFEAB308), size: 30),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes servicios registrados',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Publica tus servicios profesionales para recibir consultas.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openCreateOrEditServiceDialog(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Agregar Primer Servicio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEAB308),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        itemCount: _services.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = _services[i];
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
                                    item.imageUrl.isNotEmpty ? item.imageUrl : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 60,
                                      height: 60,
                                      color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                                      child: const Icon(Icons.room_service_rounded, color: Color(0xFFEAB308)),
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
                                      Text(
                                        'Bs ${item.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFEAB308),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6B7280)),
                                      onPressed: () => _openCreateOrEditServiceDialog(item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(height: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                      onPressed: () => _deleteService(item),
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
