import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';
import '../../../../home/presentation/widgets/business_card_item.dart';

class EditBusinessInfoBottomSheet extends StatefulWidget {
  final BusinessModel business;
  final VoidCallback onUpdated;

  const EditBusinessInfoBottomSheet({
    super.key,
    required this.business,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required BusinessModel business,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditBusinessInfoBottomSheet(
        business: business,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<EditBusinessInfoBottomSheet> createState() => _EditBusinessInfoBottomSheetState();
}

class _EditBusinessInfoBottomSheetState extends State<EditBusinessInfoBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _addressController;
  late final TextEditingController _imageController;

  late String _selectedCategory;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'comida', 'label': 'Comida y Restaurantes', 'icon': Icons.restaurant_rounded},
    {'id': 'belleza', 'label': 'Belleza y Spa', 'icon': Icons.spa_rounded},
    {'id': 'servicios', 'label': 'Servicios Profesionales', 'icon': Icons.build_rounded},
    {'id': 'deporte', 'label': 'Deportes y Gym', 'icon': Icons.fitness_center_rounded},
    {'id': 'salud', 'label': 'Salud y Farmacia', 'icon': Icons.medical_services_rounded},
    {'id': 'tecnologia', 'label': 'Tecnología', 'icon': Icons.devices_rounded},
    {'id': 'ropa', 'label': 'Moda y Ropa', 'icon': Icons.checkroom_rounded},
    {'id': 'hogar', 'label': 'Hogar y Muebles', 'icon': Icons.home_rounded},
    {'id': 'otros', 'label': 'Otros Comercios', 'icon': Icons.storefront_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _descController = TextEditingController(text: widget.business.description);
    _addressController = TextEditingController(text: widget.business.address);
    _imageController = TextEditingController(text: widget.business.imageUrl);

    // Identificar categoría inicial
    final catLower = widget.business.category.toLowerCase();
    final match = _categories.firstWhere(
      (c) => catLower.contains(c['id'] as String) || c['label'].toString().toLowerCase().contains(catLower),
      orElse: () => _categories.first,
    );
    _selectedCategory = match['id'] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre del negocio es obligatorio', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await BusinessService.instance.updateBusinessInfo(
        widget.business.id,
        name: name,
        description: _descController.text.trim(),
        address: _addressController.text.trim(),
        categoryId: _selectedCategory,
        coverImageUrl: _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
      );

      if (!mounted) return;
      widget.onUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Información del negocio actualizada con éxito',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12141C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Color(0xFF6366F1), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Datos del Negocio',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Modifica el nombre, categoría, dirección y portada',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                // Nombre
                _buildInputLabel('Nombre del Negocio *', isDark),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Ej: Burger King Cobija',
                  icon: Icons.store_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Categoría
                _buildInputLabel('Categoría Principal', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D27) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E2230) : Colors.white,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Row(
                            children: [
                              Icon(cat['icon'] as IconData, size: 18, color: const Color(0xFF6366F1)),
                              const SizedBox(width: 10),
                              Text(
                                cat['label'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dirección
                _buildInputLabel('Dirección / Ubicación Física', isDark),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _addressController,
                  hint: 'Ej: Av. 9 de Febrero esq. Calle 1',
                  icon: Icons.location_on_outlined,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Descripción
                _buildInputLabel('Breve Descripción del Negocio', isDark),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _descController,
                  hint: 'Describe brevemente lo que ofreces, especialidades, etc.',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Imagen de Portada URL
                _buildInputLabel('URL Foto de Portada', isDark),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _imageController,
                  hint: 'https://...',
                  icon: Icons.image_rounded,
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Previsualización de la foto de portada
                if (_imageController.text.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.network(
                        _imageController.text.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 140,
                          color: isDark ? Colors.white10 : Colors.grey[200],
                          alignment: Alignment.center,
                          child: Text(
                            'Enlace de imagen inválido',
                            style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),

          // Botón Guardar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161822) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  _isSaving ? 'Guardando...' : 'Guardar Cambios',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : const Color(0xFF475569),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          fontSize: 13,
          color: isDark ? Colors.white30 : Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.grey[400], size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1D27) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
    );
  }
}
