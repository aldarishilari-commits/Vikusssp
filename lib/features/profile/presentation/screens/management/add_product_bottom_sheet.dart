import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/business_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_notification.dart';

/// Modal para Agregar o Editar un Producto con el diseño pixel-perfect del mockup.
class AddProductBottomSheet extends StatefulWidget {
  final String businessId;
  final BusinessItemModel? existing;
  final VoidCallback? onSaved;

  const AddProductBottomSheet({
    super.key,
    required this.businessId,
    this.existing,
    this.onSaved,
  });

  /// Muestra el modal de Agregar / Editar producto
  static Future<bool?> show(
    BuildContext context, {
    required String businessId,
    BusinessItemModel? existing,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProductBottomSheet(
        businessId: businessId,
        existing: existing,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _normalPriceCtrl;
  late final TextEditingController _discountPriceCtrl;
  late final TextEditingController _descCtrl;
  final ImagePicker _picker = ImagePicker();

  bool _hasDiscount = false;
  String _calculatedDiscountText = '0% (automático)';
  String? _imageUrl;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _descCtrl = TextEditingController(text: existing?.description ?? '');

    final hasExistingDiscount = existing != null &&
        existing.flashPrice != null &&
        existing.flashPrice! > 0 &&
        existing.flashPrice! < existing.price;

    _hasDiscount = hasExistingDiscount;

    _normalPriceCtrl = TextEditingController(
      text: existing != null && existing.price > 0 ? existing.price.toStringAsFixed(0) : '',
    );
    _discountPriceCtrl = TextEditingController(
      text: hasExistingDiscount ? existing.flashPrice!.toStringAsFixed(0) : '',
    );
    _imageUrl = existing?.imageUrl;

    _normalPriceCtrl.addListener(_updateDiscountCalculation);
    _discountPriceCtrl.addListener(_updateDiscountCalculation);
    _updateDiscountCalculation();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _normalPriceCtrl.dispose();
    _discountPriceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _updateDiscountCalculation() {
    final normal = double.tryParse(_normalPriceCtrl.text.replaceAll(',', '.').replaceAll('Bs.', '').replaceAll('Bs', '').trim());
    final discount = double.tryParse(_discountPriceCtrl.text.replaceAll(',', '.').replaceAll('Bs.', '').replaceAll('Bs', '').trim());

    if (normal != null && normal > 0 && discount != null && discount > 0 && discount < normal) {
      final pct = ((normal - discount) / normal * 100).round();
      setState(() {
        _calculatedDiscountText = '$pct% (automático)';
      });
    } else {
      setState(() {
        _calculatedDiscountText = '0% (automático)';
      });
    }
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
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
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
        AppNotification.showSuccess(context, 'Foto del producto subida exitosamente');
      }
    } catch (e) {
      debugPrint('Error al subir foto de producto: $e');
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        AppNotification.showError(context, 'No se pudo subir la foto: $e');
      }
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameCtrl.text.trim();
    final rawNormalPrice = _normalPriceCtrl.text.replaceAll('Bs.', '').replaceAll('Bs', '').replaceAll(',', '.').trim();
    final normalPrice = double.tryParse(rawNormalPrice);

    if (name.isEmpty) {
      AppNotification.showError(context, 'Por favor ingresa el nombre del producto');
      return;
    }

    if (normalPrice == null || normalPrice <= 0) {
      AppNotification.showError(context, 'Por favor ingresa un precio normal válido');
      return;
    }

    double? discountPrice;
    if (_hasDiscount) {
      final rawDiscountPrice = _discountPriceCtrl.text.replaceAll('Bs.', '').replaceAll('Bs', '').replaceAll(',', '.').trim();
      discountPrice = double.tryParse(rawDiscountPrice);

      if (discountPrice == null || discountPrice <= 0) {
        AppNotification.showError(context, 'Por favor ingresa el precio con descuento');
        return;
      }

      if (discountPrice >= normalPrice) {
        AppNotification.showError(context, 'El precio con descuento debe ser menor al precio normal');
        return;
      }
    }

    final img = (_imageUrl != null && _imageUrl!.trim().isNotEmpty)
        ? _imageUrl!.trim()
        : '';

    setState(() => _isSaving = true);

    try {
      if (widget.existing == null) {
        final newItem = BusinessItemModel(
          id: '',
          businessId: widget.businessId,
          itemType: 'product',
          name: name,
          description: _descCtrl.text.trim(),
          price: normalPrice,
          isFlashOffer: false,
          flashPrice: _hasDiscount ? discountPrice : null,
          availableQuantity: 20,
          imageUrl: img,
          isAvailable: true,
        );
        await BusinessService.instance.addBusinessItem(newItem);
      } else {
        final updated = widget.existing!.copyWith(
          name: name,
          description: _descCtrl.text.trim(),
          price: normalPrice,
          flashPrice: _hasDiscount ? discountPrice : null,
          imageUrl: img,
        );
        await BusinessService.instance.updateBusinessItem(updated);
      }

      if (mounted) {
        AppNotification.showSuccess(
          context,
          widget.existing == null ? 'Producto agregado exitosamente' : 'Producto actualizado exitosamente',
        );
        widget.onSaved?.call();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Error al guardar producto: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existing != null;
    final bgCard = isDark ? const Color(0xFF1E1B24) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1C1C);
    final fieldBg = isDark ? const Color(0xFF272330) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E7EB);
    final hintColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFFA0AEC0);
    const purpleBrand = Color(0xFF8E05FF);
    final purpleLight = isDark ? const Color(0xFF2E1B4E) : const Color(0xFFF9F5FF);
    final purpleBorder = isDark ? const Color(0xFF7C3AED) : const Color(0xFFC4B5FD);

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3D47) : const Color(0xFFE5E0EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header: Back button & Title
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: purpleBrand,
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEditing ? 'Editar producto' : 'Agregar producto',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Nombre *
              _buildFieldLabel('Nombre', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _nameCtrl,
                hintText: 'Ej: Pan de Molde',
                prefixIcon: Icons.sell_outlined,
                fieldBg: fieldBg,
                fieldBorder: fieldBorder,
                hintColor: hintColor,
                textColor: textDark,
              ),
              const SizedBox(height: 18),

              // 2. Precio normal *
              _buildFieldLabel('Precio normal', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _normalPriceCtrl,
                hintText: 'Ej: Bs. 50',
                prefixIcon: Icons.monetization_on_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                fieldBg: fieldBg,
                fieldBorder: fieldBorder,
                hintColor: hintColor,
                textColor: textDark,
              ),
              const SizedBox(height: 20),

              // 3. ¿Tiene precio con descuento?
              Text(
                '¿Tiene precio con descuento?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Option: No
                  Expanded(
                    child: _buildDiscountOptionCard(
                      label: 'No',
                      isSelected: !_hasDiscount,
                      onTap: () {
                        setState(() {
                          _hasDiscount = false;
                        });
                      },
                      isDark: isDark,
                      purpleBrand: purpleBrand,
                      purpleLight: purpleLight,
                      purpleBorder: purpleBorder,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Option: Sí
                  Expanded(
                    child: _buildDiscountOptionCard(
                      label: 'Sí',
                      isSelected: _hasDiscount,
                      onTap: () {
                        setState(() {
                          _hasDiscount = true;
                        });
                      },
                      isDark: isDark,
                      purpleBrand: purpleBrand,
                      purpleLight: purpleLight,
                      purpleBorder: purpleBorder,
                    ),
                  ),
                ],
              ),

              // Conditional Discount Fields
              if (_hasDiscount) ...[
                const SizedBox(height: 18),

                // Precio con descuento
                _buildFieldLabel('Precio con descuento', isRequired: false, isDark: isDark),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _discountPriceCtrl,
                  hintText: 'Ej: Bs. 40',
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  fieldBg: fieldBg,
                  fieldBorder: fieldBorder,
                  hintColor: hintColor,
                  textColor: textDark,
                ),
                const SizedBox(height: 18),

                // Descuento (automático)
                _buildFieldLabel('Descuento', isRequired: false, isDark: isDark),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF241F2D) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF373240) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.percent_rounded,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFA0AEC0),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _calculatedDiscountText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 4. Descripción
              _buildFieldLabel('Descripción', isRequired: false, isDark: isDark),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: fieldBorder),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.article_outlined,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFA0AEC0),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descCtrl,
                              minLines: 3,
                              maxLines: 4,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Describe tu producto...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: hintColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Resize corner marker indicator like in mockup
                    Positioned(
                      bottom: 6,
                      right: 8,
                      child: CustomPaint(
                        size: const Size(10, 10),
                        painter: _ResizeHandlePainter(
                          color: isDark ? const Color(0xFF4B4654) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Foto del producto (opcional)
              _buildFieldLabel('Foto del producto', isRequired: false, isOptionalText: true, isDark: isDark),
              const SizedBox(height: 8),
              _buildPhotoPickerContainer(
                isDark: isDark,
                purpleBrand: purpleBrand,
                purpleLight: purpleLight,
                purpleBorder: purpleBorder,
              ),

              const SizedBox(height: 28),

              // Bottom Actions: Cancelar & Guardar
              Row(
                children: [
                  // Cancelar Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF6B46C1) : const Color(0xFFC4B5FD),
                          width: 1.5,
                        ),
                        backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFC084FC) : purpleBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Guardar Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSaving || _isUploadingPhoto) ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleBrand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Guardar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
    String label, {
    bool isRequired = false,
    bool isOptionalText = false,
    required bool isDark,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
        if (isOptionalText) ...[
          const SizedBox(width: 4),
          Text(
            '(opcional)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    required Color fieldBg,
    required Color fieldBorder,
    required Color hintColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fieldBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: hintColor,
            size: 20,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: hintColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  Widget _buildDiscountOptionCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color purpleBrand,
    required Color purpleLight,
    required Color purpleBorder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? purpleLight : (isDark ? const Color(0xFF272330) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? purpleBorder : (isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E7EB)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? purpleBrand : (isDark ? const Color(0xFF6B7280) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: purpleBrand,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? purpleBrand : (isDark ? Colors.white : const Color(0xFF1B1C1C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPickerContainer({
    required bool isDark,
    required Color purpleBrand,
    required Color purpleLight,
    required Color purpleBorder,
  }) {
    final hasPhoto = _imageUrl != null && _imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _showImageSourceModal,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: hasPhoto ? purpleBrand : (isDark ? const Color(0xFF533B76) : const Color(0xFFC4B5FD)),
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          radius: 14,
        ),
        child: Container(
          height: hasPhoto ? 130 : 90,
          width: double.infinity,
          decoration: BoxDecoration(
            color: purpleLight,
            borderRadius: BorderRadius.circular(14),
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
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF8E05FF),
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subiendo foto a Supabase...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: purpleBrand,
                        ),
                      ),
                    ],
                  ),
                )
              else if (hasPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF241F2D) : const Color(0xFFF3F4F6),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 30,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
                // Remove photo button
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
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                // Change photo badge
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
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Cambiar foto',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Photo Icon with plus badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: purpleBrand,
                          ),
                          Positioned(
                            right: -5,
                            bottom: -3,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: purpleBrand,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+ Agregar foto',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: purpleBrand,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter para trazar bordes punteados (dashed) con esquinas redondeadas
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double radius;

  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashPattern = const [6, 4],
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashPattern);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, List<double> pattern) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var patternIndex = 0;
      var draw = true;
      while (distance < metric.length) {
        final len = pattern[patternIndex % pattern.length];
        if (draw) {
          final nextDistance = math.min(distance + len, metric.length);
          dest.addPath(metric.extractPath(distance, nextDistance), Offset.zero);
        }
        distance += len;
        draw = !draw;
        patternIndex++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

/// Marcador visual para la esquina inferior derecha del campo de descripción (resize indicator)
class _ResizeHandlePainter extends CustomPainter {
  final Color color;

  _ResizeHandlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Line 1 (shorter)
    canvas.drawLine(
      Offset(size.width - 2, size.height - 6),
      Offset(size.width - 6, size.height - 2),
      paint,
    );

    // Line 2 (longer)
    canvas.drawLine(
      Offset(size.width, size.height - 3),
      Offset(size.width - 3, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ResizeHandlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
