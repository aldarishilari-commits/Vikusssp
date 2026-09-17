import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/offers/data/models/offer_model.dart';
import 'package:aeronpulse/features/offers/presentation/screens/offers_screen.dart';
import 'package:aeronpulse/features/offers/presentation/widgets/offer_filters_bottom_sheet.dart';

void main() {
  group('OfferModel Tests', () {
    test('Initial offers list contains 9 items across 3 distinct sections', () {
      final offers = OfferModel.getInitialOffers();
      expect(offers.length, 9);

      final expiring = offers.where((o) => o.sectionType == OfferSectionType.expiringSoon).toList();
      final following = offers.where((o) => o.sectionType == OfferSectionType.followingBusinesses).toList();
      final all = offers.where((o) => o.sectionType == OfferSectionType.allOffers).toList();

      expect(expiring.length, 3);
      expect(following.length, 3);
      expect(all.length, 3);

      expect(expiring.first.businessName, 'La Burguesa');
      expect(expiring.first.title, 'Hamburguesa clásica + papas');
      expect(expiring.first.discountedPrice, 40.0);
      expect(expiring.first.originalPrice, 50.0);
      expect(expiring.first.discountBadge, '-20%');
    });
  });

  group('OffersScreen Widget Tests', () {
    testWidgets('OffersScreen renders header, filter bar and all 3 sections matching design', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Header verification
      expect(find.text('Ofertas'), findsOneWidget);
      expect(find.text('Promociones que puedes aprovechar\nantes de que terminen.'), findsOneWidget);

      // Filter pills verification
      expect(find.text('Tipo'), findsNothing);
      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Vencimiento'), findsOneWidget);
      expect(find.text('Descuento'), findsOneWidget);
      expect(find.text('Negocios'), findsOneWidget);

      // Section titles verification
      expect(find.text('Terminan pronto'), findsOneWidget);
      expect(find.text('De los negocios que sigues'), findsOneWidget);
      expect(find.text('Todas las ofertas'), findsOneWidget);

      // Card elements verification
      expect(find.text('La Burguesa'), findsOneWidget);
      expect(find.text('Hamburguesa clásica + papas'), findsOneWidget);
      expect(find.text('Bs 40'), findsOneWidget);
      expect(find.text('800 m'), findsOneWidget);

      expect(find.text('FitLife Gym'), findsOneWidget);
      expect(find.text('Pizzería El Buen Sabor'), findsOneWidget);
    });

    testWidgets('Tapping Filtros opens OfferFiltersBottomSheet and applying filters updates results', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Tap on general "Filtros" chip
      final filtrosChip = find.text('Filtros');
      expect(filtrosChip, findsOneWidget);
      await tester.tap(filtrosChip);
      await tester.pumpAndSettle();

      // Verify modal is open and has content
      expect(find.byType(OfferFiltersBottomSheet), findsOneWidget);
      expect(find.text('Porcentaje de descuento'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OfferFiltersBottomSheet),
          matching: find.text('Vencimiento'),
        ),
        findsOneWidget,
      );
      expect(find.text('Tipo'), findsNothing);

      // Select '40% o más'
      final discount40 = find.text('40% o más');
      expect(discount40, findsOneWidget);
      await tester.tap(discount40);
      await tester.pump();

      // Tap 'Aplicar filtros'
      final applyButton = find.text('Aplicar filtros');
      expect(applyButton, findsOneWidget);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Modal closed and offers filtered
      expect(find.text('Filtros (1)'), findsOneWidget);
      expect(find.text('Ropa casual'), findsOneWidget);
      expect(find.text('La Burguesa'), findsNothing);
    });

    testWidgets('Tapping search icon toggles search bar and filters offers by keyword', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Tap search icon
      final searchButton = find.byIcon(Icons.search_rounded);
      expect(searchButton, findsWidgets);
      await tester.tap(searchButton.first);
      await tester.pumpAndSettle();

      // Search input appears
      expect(find.byType(TextField), findsOneWidget);

      // Enter query 'Pizza'
      await tester.enterText(find.byType(TextField), 'Pizza');
      await tester.pumpAndSettle();

      // Should show only Pizzería El Buen Sabor
      expect(find.text('Pizza familiar'), findsOneWidget);
      expect(find.text('Pizzería El Buen Sabor'), findsOneWidget);
      expect(find.text('La Burguesa'), findsNothing);
    });

    testWidgets('Quick pill filter updates filter criteria and syncing with general modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Tap Vencimiento quick pill
      final vencimientoPill = find.text('Vencimiento');
      expect(vencimientoPill, findsOneWidget);
      await tester.tap(vencimientoPill);
      await tester.pumpAndSettle();

      // Pick 'Menos de 6 horas'
      final option = find.text('Menos de 6 horas');
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();

      // Filtros badge is now Filtros (1)
      expect(find.text('Filtros (1)'), findsOneWidget);

      // Now open Filtros modal
      await tester.tap(find.text('Filtros (1)'));
      await tester.pumpAndSettle();

      // Tap 'Limpiar filtros'
      final clearButton = find.text('Limpiar filtros');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      // Tap 'Aplicar filtros'
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      // All filters are reset back to normal
      expect(find.text('Filtros'), findsOneWidget);
    });

    testWidgets('Tapping Descuento pill opens full options list without overflow and selecting an option filters offers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Tap Descuento pill
      final descuentoPill = find.text('Descuento');
      expect(descuentoPill, findsOneWidget);
      await tester.tap(descuentoPill);
      await tester.pumpAndSettle();

      // Verify all discount options are present
      expect(find.text('Filtrar por Porcentaje de Descuento'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('15% o más'), findsOneWidget);
      expect(find.text('20% o más'), findsOneWidget);
      expect(find.text('25% o más'), findsOneWidget);
      expect(find.text('30% o más'), findsOneWidget);
      expect(find.text('40% o más'), findsOneWidget);

      // Select '30% o más'
      await tester.tap(find.text('30% o más'));
      await tester.pumpAndSettle();

      // Verify screen updated
      expect(find.text('Descuento: 30% o más'), findsOneWidget);
      expect(find.text('Filtros (1)'), findsOneWidget);
    });

    testWidgets('Tapping favorite icon toggles favorite state without displaying SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersScreen(),
        ),
      );
      await tester.pump();

      // Find favorite heart icon on first card
      final favIcons = find.byIcon(Icons.favorite_border_rounded);
      expect(favIcons, findsWidgets);

      // Tap on the first favorite icon
      await tester.tap(favIcons.at(1));
      await tester.pump();

      // Ensure no SnackBar/message is shown
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
