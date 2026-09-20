import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';
import '../../../../business/domain/models/business_registration_model.dart';

class ManageScheduleBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final Map<String, DaySchedule>? initialSchedules;
  final VoidCallback onUpdated;

  const ManageScheduleBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.initialSchedules,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    required Map<String, DaySchedule>? initialSchedules,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageScheduleBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialSchedules: initialSchedules,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageScheduleBottomSheet> createState() => _ManageScheduleBottomSheetState();
}

class _ManageScheduleBottomSheetState extends State<ManageScheduleBottomSheet> {
  late Map<String, DaySchedule> _schedules;
  bool _isSaving = false;

  final List<String> _daysOfWeek = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _schedules = {};

    for (final day in _daysOfWeek) {
      if (widget.initialSchedules != null && widget.initialSchedules!.containsKey(day)) {
        final orig = widget.initialSchedules![day]!;
        _schedules[day] = DaySchedule(
          dayName: day,
          isOpen: orig.isOpen,
          openTime: orig.openTime,
          closeTime: orig.closeTime,
        );
      } else {
        _schedules[day] = DaySchedule(
          dayName: day,
          isOpen: day != 'Domingo',
          openTime: const TimeOfDay(hour: 8, minute: 0),
          closeTime: const TimeOfDay(hour: 20, minute: 0),
        );
      }
    }
  }

  Future<void> _pickTime(String day, bool isOpenTime) async {
    final sched = _schedules[day]!;
    final initial = isOpenTime ? sched.openTime : sched.closeTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpenTime ? 'Hora de Apertura ($day)' : 'Hora de Cierre ($day)',
    );

    if (picked != null) {
      setState(() {
        _schedules[day] = DaySchedule(
          dayName: day,
          isOpen: sched.isOpen,
          openTime: isOpenTime ? picked : sched.openTime,
          closeTime: isOpenTime ? sched.closeTime : picked,
        );
      });
    }
  }

  Future<void> _saveSchedules() async {
    setState(() => _isSaving = true);
    try {
      await BusinessService.instance.updateBusinessSchedules(widget.businessId, _schedules);
      widget.onUpdated();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Horarios actualizados con éxito en Supabase'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar horarios: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
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

          // Header
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
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_filled_rounded, color: Color(0xFF22C55E), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horarios de Atención',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                        ),
                        Text(
                          widget.businessName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveSchedules,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6)),

          // List of days
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _daysOfWeek.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final day = _daysOfWeek[i];
                final sched = _schedules[day]!;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sched.isOpen
                          ? (isDark ? const Color(0xFF15803D).withValues(alpha: 0.5) : const Color(0xFFBBF7D0))
                          : (isDark ? const Color(0xFF3F2B5C) : const Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Day name + Toggle
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Switch(
                              value: sched.isOpen,
                              activeThumbColor: const Color(0xFF22C55E),
                              onChanged: (val) {
                                setState(() {
                                  _schedules[day] = DaySchedule(
                                    dayName: day,
                                    isOpen: val,
                                    openTime: sched.openTime,
                                    closeTime: sched.closeTime,
                                  );
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              day,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: sched.isOpen
                                    ? (isDark ? Colors.white : const Color(0xFF1B1C1C))
                                    : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time range pickers
                      if (sched.isOpen)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _pickTime(day, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  sched.formattedOpenTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('–'),
                            ),
                            GestureDetector(
                              onTap: () => _pickTime(day, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  sched.formattedCloseTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cerrado',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
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
