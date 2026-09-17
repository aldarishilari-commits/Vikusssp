import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/business_card_item.dart';
import '../../domain/models/business_registration_model.dart';

/// Modal Bottom Sheet que muestra el horario comercial completo y estado en vivo del negocio
class BusinessScheduleBottomSheet extends StatelessWidget {
  final BusinessModel business;

  const BusinessScheduleBottomSheet({
    super.key,
    required this.business,
  });

  /// Método helper estático para abrir este Bottom Sheet cómodamente
  static Future<void> show(BuildContext context, BusinessModel business) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BusinessScheduleBottomSheet(business: business),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Lunes, ..., 7 = Domingo
    final schedules = business.resolvedSchedules;
    final isCurrentlyOpen = business.isCurrentlyOpenNow;
    final todaySchedule = business.todaySchedule;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysList = [
      {'name': 'Lunes', 'weekday': 1},
      {'name': 'Martes', 'weekday': 2},
      {'name': 'Miercoles', 'display': 'Miércoles', 'weekday': 3},
      {'name': 'Jueves', 'weekday': 4},
      {'name': 'Viernes', 'weekday': 5},
      {'name': 'Sabado', 'display': 'Sábado', 'weekday': 6},
      {'name': 'Domingo', 'weekday': 7},
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55000000) : const Color(0x26000000),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header Row: Icon + Title + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B1D66) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      business.categoryIcon,
                      color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horario de atención',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          business.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF272430) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Status Banner Card
                    _buildLiveStatusHero(
                      isCurrentlyOpen: isCurrentlyOpen,
                      todaySchedule: todaySchedule,
                      statusSubtitle: business.scheduleStatusSubtitle,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // Section Title: Cronograma semanal
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CRONOGRAMA SEMANAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Weekly Schedule List Container
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF272330) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: daysList.map((dayInfo) {
                            final keyName = dayInfo['name'] as String;
                            final displayName = (dayInfo['display'] ?? keyName) as String;
                            final weekdayNumber = dayInfo['weekday'] as int;
                            final isToday = weekdayNumber == todayWeekday;
                            final daySchedule = schedules[keyName] ??
                                schedules[displayName] ??
                                DaySchedule(dayName: displayName);

                            return _buildDayScheduleRow(
                              displayName: displayName,
                              daySchedule: daySchedule,
                              isToday: isToday,
                              isLast: weekdayNumber == 7,
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Holiday / Advisory Notice Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Los horarios pueden estar sujetos a cambios durante feriados nacionales, festividades o fechas cívicas.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner dinámico del estado en tiempo real
  Widget _buildLiveStatusHero({
    required bool isCurrentlyOpen,
    required DaySchedule? todaySchedule,
    required String statusSubtitle,
    required bool isDark,
  }) {
    final bgGradient = isCurrentlyOpen
        ? (isDark
            ? const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
        : (isDark
            ? const LinearGradient(
                colors: [Color(0xFF450A0A), Color(0xFF7F1D1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFEF2F2), Color(0xFFFFF1F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    final borderColor = isCurrentlyOpen
        ? (isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0))
        : (isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA));
    final primaryTextColor = isCurrentlyOpen
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626));
    final dotColor =
        isCurrentlyOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          // Live status pulse indicator
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Status texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentlyOpen ? 'Abierto ahora' : 'Cerrado ahora',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryTextColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'En vivo',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  todaySchedule != null && todaySchedule.isOpen
                      ? 'Hoy: ${todaySchedule.formattedSchedule} · $statusSubtitle'
                      : statusSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de horario por día
  Widget _buildDayScheduleRow({
    required String displayName,
    required DaySchedule daySchedule,
    required bool isToday,
    required bool isLast,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? (isDark ? const Color(0xFF3B1D66) : AppColors.primary.withValues(alpha: 0.08))
            : (isDark ? const Color(0xFF272330) : Colors.white),
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Left indicator bar for today
          if (isToday)
            Container(
              width: 3.5,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Day Name
          Text(
            displayName,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday
                  ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                  : (isDark ? Colors.white : const Color(0xFF1F2937)),
            ),
          ),

          // "HOY" Badge
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'HOY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Hours or Closed status
          if (daySchedule.isOpen) ...[
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 5),
            Text(
              daySchedule.formattedSchedule,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? (isDark ? Colors.white : const Color(0xFF111827))
                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF374151)),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cerrado',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
