import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 7: Horario de atención ("Registro del negocio_horario-7.png")
class Step7ScheduleScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step7ScheduleScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step7ScheduleScreen> createState() => _Step7ScheduleScreenState();
}

class _Step7ScheduleScreenState extends State<Step7ScheduleScreen> {
  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  Future<void> _pickTime(String day, bool isOpenTime) async {
    final schedule = widget.data.schedules[day];
    if (schedule == null) return;

    final initialTime = isOpenTime ? schedule.openTime : schedule.closeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryAlt,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1B1C1C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          schedule.openTime = picked;
        } else {
          schedule.closeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RegistrationHeader(
            buttonText: 'Guardar y salir',
            onExit: widget.onExit,
            progress: 0.75,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            'Horario de atención',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 20),

          // Schedule List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _days.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final day = _days[index];
                final schedule = widget.data.schedules[day] ??
                    DaySchedule(dayName: day);

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E0EA),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top row: Day name, Status (Abierto/Cerrado), Toggle switch
                      Row(
                        children: [
                          Text(
                            day,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B1C1C),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            schedule.isOpen ? 'Abierto' : 'Cerrado',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: schedule.isOpen
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                schedule.isOpen = !schedule.isOpen;
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 24,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: schedule.isOpen
                                    ? const Color(0xFF3F6212)
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: schedule.isOpen
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (schedule.isOpen) ...[
                        const SizedBox(height: 10),
                        // Bottom row: Time range pickers 8:00 - 19:00
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _pickTime(day, true),
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  schedule.formattedOpenTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _pickTime(day, false),
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  schedule.formattedCloseTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Bar
          RegistrationBottomBar(
            onBack: widget.onBack,
            onNext: widget.onNext,
            nextText: 'Siguiente',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
