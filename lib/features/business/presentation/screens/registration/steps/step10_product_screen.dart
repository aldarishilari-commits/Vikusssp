import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/core/widgets/app_notification.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 10: Producto ("Registro del negocio_producto-10.png")
class Step10ProductScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onBack;
  final ValueChanged<BusinessProductItem> onProductAdded;

  const Step10ProductScreen({
    super.key,
    required this.data,
    required this.onBack,
    required this.onProductAdded,
  });

  @override
  State<Step10ProductScreen> createState() => _Step10ProductScreenState();
}

class _Step10ProductScreenState extends State<Step10ProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _normalPriceController = TextEditingController();
  final TextEditingController _flashPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _isFlashOffer = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  List<String> _repeatDays = ['Lun'];
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _normalPriceController.dispose();
    _flashPriceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryAlt,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryAlt,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveProduct() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppNotification.showInfo(
        context,
        'Por favor ingresa el nombre del producto',
      );
      return;
    }

    final product = BusinessProductItem(
      name: name,
      normalPrice: double.tryParse(_normalPriceController.text),
      isFlashOffer: _isFlashOffer,
      flashPrice: double.tryParse(_flashPriceController.text),
      startDate: _startDate,
      endDate: _endDate,
      startTime: _startTime,
      endTime: _endTime,
      repeatDays: _repeatDays,
      availableQuantity: int.tryParse(_quantityController.text),
      description: _descController.text,
      imagePath: _imagePath,
    );

    widget.data.products.add(product);
    widget.onProductAdded(product);
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header with Back Button and Title "Producto"
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Producto',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Nombre
                      Text(
                        'Nombre',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4E4356),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5E0EA),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: GoogleFonts.inter(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Ej: Hamburguesa clásica',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFFA09FA1),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Precio normal
                      Text(
                        'Precio normal',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4E4356),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 140,
                        child: NumberStepperField(
                          controller: _normalPriceController,
                          hintText: '0.0',
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 3. Tipo de Oferta
                      Text(
                        'Tipo de Oferta',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4E4356),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OfferTypeSelector(
                        isFlashOffer: _isFlashOffer,
                        onChanged: (val) {
                          setState(() => _isFlashOffer = val);
                        },
                      ),

                      if (_isFlashOffer) ...[
                        const SizedBox(height: 18),

                        // 4. Configuración de Oferta Flash
                        Text(
                          'Configuración de Oferta Flash',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryAlt,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Precio flash (con descuento)
                        Text(
                          'Precio flash (con descuento)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF4E4356),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 140,
                          child: NumberStepperField(
                            controller: _flashPriceController,
                            prefixText: 'Bs',
                            hintText: '0.0',
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Vigencia de la Oferta
                        Text(
                          'Vigencia de la Oferta',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Fechas Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha de inicio',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickDate(true),
                                    child: _buildDateBox(_formatDate(_startDate)),
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
                                    'Fecha de finalización',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickDate(false),
                                    child: _buildDateBox(_formatDate(_endDate)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Horas Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hora de inicio',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickTime(true),
                                    child: _buildDateBox(_formatTime(_startTime)),
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
                                    'Hora de finalización',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickTime(false),
                                    child: _buildDateBox(_formatTime(_endTime)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Repetir la Oferta (opcional)
                        Text(
                          'Repetir la Oferta (opcional)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DaysOfWeekSelector(
                          selectedDays: _repeatDays,
                          onChanged: (days) {
                            setState(() => _repeatDays = days);
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Cantidad disponible
                      Text(
                        'Cantidad disponible',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4E4356),
                        ),
                      ),
                      const SizedBox(height: 6),
                      NumberStepperField(
                        controller: _quantityController,
                        hintText: '',
                        isInteger: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dejalo vacio si no deseas establecer una cantidad',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descripción (opcional)
                      Row(
                        children: [
                          Text(
                            'Descripción ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF4E4356),
                            ),
                          ),
                          Text(
                            '(opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5E0EA),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _descController,
                          style: GoogleFonts.inter(fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Añadir foto (opcional)
                      Row(
                        children: [
                          Text(
                            'Añadir foto ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF4E4356),
                            ),
                          ),
                          Text(
                            '(opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _imagePath =
                                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80';
                          });
                        },
                        child: Container(
                          height: 76,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E0EA),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: _imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imagePath!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 60,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 34,
                                    color: Color(0xFF1B1C1C),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón "Agregar producto"
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAlt,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Agregar producto',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildDateBox(String text) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E0EA),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1B1C1C),
        ),
      ),
    );
  }
}
