import 'package:flutter/material.dart';

/// Modelo de horario para cada día de la semana
class DaySchedule {
  final String dayName;
  bool isOpen;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  DaySchedule({
    required this.dayName,
    this.isOpen = true,
    this.openTime = const TimeOfDay(hour: 8, minute: 0),
    this.closeTime = const TimeOfDay(hour: 19, minute: 0),
  });

  String get formattedOpenTime =>
      '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';

  String get formattedCloseTime =>
      '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';

  /// Rango de horario formateado (ej. "08:00 - 19:00" o "Cerrado")
  String get formattedSchedule =>
      isOpen ? '$formattedOpenTime - $formattedCloseTime' : 'Cerrado';

  /// Determina si el negocio está abierto en un momento específico
  bool isCurrentlyOpen([DateTime? now]) {
    if (!isOpen) return false;
    final current = now ?? DateTime.now();
    final currentMinutes = current.hour * 60 + current.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    // Manejo de horario estándar (ej. 08:00 a 20:00)
    if (closeMinutes >= openMinutes) {
      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    } else {
      // Manejo de horario nocturno que cruza la medianoche (ej. 19:00 a 02:00)
      return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
    }
  }

  DaySchedule copyWith({
    String? dayName,
    bool? isOpen,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return DaySchedule(
      dayName: dayName ?? this.dayName,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}

/// Modelo para productos añadidos al negocio
class BusinessProductItem {
  String name;
  double? normalPrice;
  bool isFlashOffer;
  double? flashPrice;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<String> repeatDays;
  int? availableQuantity;
  String? description;
  String? imagePath;

  BusinessProductItem({
    required this.name,
    this.normalPrice,
    this.isFlashOffer = false,
    this.flashPrice,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.repeatDays = const [],
    this.availableQuantity,
    this.description,
    this.imagePath,
  });
}

/// Modelo para servicios añadidos al negocio
class BusinessServiceItem {
  String name;
  double? normalPrice;
  bool isFlashOffer;
  double? flashPrice;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<String> repeatDays;
  int? availableQuantity;
  String? description;
  String? imagePath;

  BusinessServiceItem({
    required this.name,
    this.normalPrice,
    this.isFlashOffer = false,
    this.flashPrice,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.repeatDays = const [],
    this.availableQuantity,
    this.description,
    this.imagePath,
  });
}

/// Modelo general que persiste todo el estado del registro a través de los 11 pasos
class BusinessRegistrationData {
  // Paso 2: Nombre y Descripción
  String name;
  String description;

  // Paso 3: Categoría
  String category;

  // Paso 4 & 5: Ubicación
  String address;
  double latitude;
  double longitude;
  bool isLocationConfirmed;

  // Paso 6: Contacto
  String phoneCountryCode;
  String phoneNumber;
  String tiktok;
  String facebook;
  String instagram;
  String website;

  // Paso 7: Horario de atención
  Map<String, DaySchedule> schedules;

  // Paso 8: Fotos del negocio
  List<String> photoUrls;

  // Paso 10: Productos
  List<BusinessProductItem> products;

  // Paso 11: Servicios
  List<BusinessServiceItem> services;

  BusinessRegistrationData({
    this.name = '',
    this.description = '',
    this.category = 'Restaurantes y comida',
    this.address = 'Av. Pando, La Paz',
    this.latitude = -16.5050,
    this.longitude = -68.1290,
    this.isLocationConfirmed = false,
    this.phoneCountryCode = '+591',
    this.phoneNumber = '',
    this.tiktok = '',
    this.facebook = '',
    this.instagram = '',
    this.website = '',
    Map<String, DaySchedule>? schedules,
    List<String>? photoUrls,
    List<BusinessProductItem>? products,
    List<BusinessServiceItem>? services,
  })  : schedules = schedules ??
            {
              'Lunes': DaySchedule(dayName: 'Lunes'),
              'Martes': DaySchedule(dayName: 'Martes'),
              'Miercoles': DaySchedule(dayName: 'Miercoles'),
              'Jueves': DaySchedule(dayName: 'Jueves'),
              'Viernes': DaySchedule(dayName: 'Viernes'),
              'Sabado': DaySchedule(dayName: 'Sabado'),
              'Domingo': DaySchedule(dayName: 'Domingo'),
            },
        photoUrls = photoUrls ?? [],
        products = products ?? [],
        services = services ?? [];
}
