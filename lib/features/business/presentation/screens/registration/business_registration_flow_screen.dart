import 'package:flutter/material.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/core/widgets/app_notification.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step1_intro_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step2_name_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step3_category_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step4_location_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step5_location_confirmed_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step6_contact_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step7_schedule_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step8_photo_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step9_ready_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step10_product_screen.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step11_service_screen.dart';

/// Orquestador principal del flujo de 11 pantallas para "Registrar negocio"
class BusinessRegistrationFlowScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const BusinessRegistrationFlowScreen({
    super.key,
    this.onCompleted,
  });

  @override
  State<BusinessRegistrationFlowScreen> createState() =>
      _BusinessRegistrationFlowScreenState();
}

class _BusinessRegistrationFlowScreenState
    extends State<BusinessRegistrationFlowScreen> {
  int _currentStep = 1; // 1 to 9, plus 10 (Producto) and 11 (Servicio)
  final BusinessRegistrationData _data = BusinessRegistrationData();

  void _nextStep() {
    if (_currentStep < 9) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep == 10 || _currentStep == 11) {
      // Return to step 9 from products/services
      setState(() {
        _currentStep = 9;
      });
    } else if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleExit() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Deseas salir del registro?'),
        content: const Text(
            'Tu progreso actual se guardará para que puedas continuar más tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar editando'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAlt,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _finishRegistration() {
    AppNotification.showSuccess(
      context,
      '¡Negocio "${_data.name.isNotEmpty ? _data.name : "Mi Negocio"}" registrado con éxito!',
    );

    widget.onCompleted?.call();
    Navigator.of(context).pop(_data);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previousStep();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F8),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentStepScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepScreen() {
    switch (_currentStep) {
      case 1:
        return Step1IntroScreen(
          key: const ValueKey(1),
          onBack: () => Navigator.of(context).pop(),
          onNext: _nextStep,
        );
      case 2:
        return Step2NameScreen(
          key: const ValueKey(2),
          data: _data,
          onExit: _handleExit,
          onNext: _nextStep,
        );
      case 3:
        return Step3CategoryScreen(
          key: const ValueKey(3),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 4:
        return Step4LocationScreen(
          key: const ValueKey(4),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 5:
        return Step5LocationConfirmedScreen(
          key: const ValueKey(5),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 6:
        return Step6ContactScreen(
          key: const ValueKey(6),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 7:
        return Step7ScheduleScreen(
          key: const ValueKey(7),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 8:
        return Step8PhotoScreen(
          key: const ValueKey(8),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onNext: _nextStep,
        );
      case 9:
        return Step9ReadyScreen(
          key: const ValueKey(9),
          data: _data,
          onExit: _handleExit,
          onBack: _previousStep,
          onOpenProducts: () {
            setState(() => _currentStep = 10);
          },
          onOpenServices: () {
            setState(() => _currentStep = 11);
          },
          onFinish: _finishRegistration,
        );
      case 10:
        return Step10ProductScreen(
          key: const ValueKey(10),
          data: _data,
          onBack: () {
            setState(() => _currentStep = 9);
          },
          onProductAdded: (product) {
            AppNotification.showSuccess(
              context,
              'Producto "${product.name}" agregado',
              icon: Icons.inventory_2_rounded,
            );
          },
        );
      case 11:
        return Step11ServiceScreen(
          key: const ValueKey(11),
          data: _data,
          onBack: () {
            setState(() => _currentStep = 9);
          },
          onServiceAdded: (service) {
            AppNotification.showSuccess(
              context,
              'Servicio "${service.name}" agregado',
              icon: Icons.room_service_rounded,
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
