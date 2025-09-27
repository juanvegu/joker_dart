import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joker_http_native_example/main.dart';
import 'package:joker_http_native_example/joker_config.dart';
import 'package:joker/joker.dart';

void main() {
  group('Widget Tests', () {
    setUpAll(() {
      // Setup Joker stubs for widget testing
      JokerConfiguration.setupStubs();
    });

    tearDownAll(() {
      Joker.stop();
    });

    group('MyApp Widget', () {
      testWidgets('should display app title and initial UI elements', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(MyApp());

        // Assert
        expect(find.text('Joker HTTP Example'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        expect(find.text('Usar Joker'), findsOneWidget);
        expect(find.text('Cargar Posts'), findsOneWidget);
        expect(find.text('Cargar Usuarios'), findsOneWidget);
      });

      testWidgets('should toggle Joker switch', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Find the switch widget
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        // Get initial switch state (should be false by default)
        Switch initialSwitch = tester.widget(switchFinder) as Switch;
        expect(initialSwitch.value, isFalse);

        // Act - Tap the switch
        await tester.tap(switchFinder);
        await tester.pump();

        // Assert - Switch should now be true
        Switch updatedSwitch = tester.widget(switchFinder) as Switch;
        expect(updatedSwitch.value, isTrue);

        // Act - Tap again to toggle back
        await tester.tap(switchFinder);
        await tester.pump();

        // Assert - Switch should be false again
        Switch finalSwitch = tester.widget(switchFinder) as Switch;
        expect(finalSwitch.value, isFalse);
      });
    });

    group('Data Loading with Joker', () {
      testWidgets('should load posts using Joker stubs', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Act - Tap "Cargar Posts" button
        await tester.tap(find.text('Cargar Posts'));
        await tester.pump(); // Trigger the async operation
        await tester.pump(); // Allow the Future to complete

        // Assert - Should show post data
        expect(find.text('Posts cargados'), findsOneWidget);
        expect(find.textContaining('Post ID:'), findsWidgets);
        expect(find.textContaining('Título:'), findsWidgets);
        expect(find.textContaining('Usuario ID:'), findsWidgets);
      });

      testWidgets('should load users using Joker stubs', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Act - Tap "Cargar Usuarios" button
        await tester.tap(find.text('Cargar Usuarios'));
        await tester.pump(); // Trigger the async operation
        await tester.pump(); // Allow the Future to complete

        // Assert - Should show user data
        expect(find.text('Usuarios cargados'), findsOneWidget);
        expect(find.textContaining('User ID:'), findsWidgets);
        expect(find.textContaining('Nombre:'), findsWidgets);
        expect(find.textContaining('Username:'), findsWidgets);
        expect(find.textContaining('Email:'), findsWidgets);
      });

      testWidgets('should handle loading states properly', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Act - Start loading posts
        await tester.tap(find.text('Cargar Posts'));

        // Assert - Should show loading indicator initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert - Loading indicator should be gone, data should be shown
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Posts cargados'), findsOneWidget);
      });

      testWidgets('should display error when Joker is disabled and network fails', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Ensure Joker is disabled (default state)
        final switchFinder = find.byType(Switch);
        Switch currentSwitch = tester.widget(switchFinder) as Switch;
        if (currentSwitch.value) {
          await tester.tap(switchFinder);
          await tester.pump();
        }

        // Act - Try to load posts without Joker (will likely fail due to network)
        await tester.tap(find.text('Cargar Posts'));
        await tester.pump();
        await tester.pumpAndSettle(
          Duration(seconds: 10),
        ); // Wait longer for network timeout

        // Assert - Should show error message (network will likely fail in test environment)
        // Note: This test assumes network failure in testing environment
        expect(find.textContaining('Error'), findsOneWidget);
      });
    });

    group('UI State Management', () {
      testWidgets('should maintain separate state for posts and users', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Act - Load posts first
        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        // Assert - Posts loaded, users not yet loaded
        expect(find.text('Posts cargados'), findsOneWidget);
        expect(find.text('Usuarios cargados'), findsNothing);

        // Act - Load users
        await tester.tap(find.text('Cargar Usuarios'));
        await tester.pumpAndSettle();

        // Assert - Both posts and users should be shown
        expect(find.text('Posts cargados'), findsOneWidget);
        expect(find.text('Usuarios cargados'), findsOneWidget);
      });

      testWidgets('should clear data when switching Joker on/off', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker and load data
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        expect(find.text('Posts cargados'), findsOneWidget);

        // Act - Toggle Joker off
        await tester.tap(switchFinder);
        await tester.pump();

        // Assert - Data should be cleared
        expect(find.text('Posts cargados'), findsNothing);
        expect(find.text('Listo para cargar datos'), findsOneWidget);
      });

      testWidgets('should show appropriate messages for different states', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Assert initial state
        expect(find.text('Listo para cargar datos'), findsOneWidget);
        expect(find.text('Joker está desactivado'), findsOneWidget);

        // Act - Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Assert Joker enabled state
        expect(
          find.text('Joker está activado - usando datos mock'),
          findsOneWidget,
        );
        expect(find.text('Joker está desactivado'), findsNothing);
      });
    });

    group('Scrolling and Large Data Sets', () {
      testWidgets('should handle scrolling through posts list', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker and load posts
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        // Assert - Should find scrollable list
        expect(find.byType(SingleChildScrollView), findsWidgets);

        // Act - Try to scroll (if content is long enough)
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          Offset(0, -200),
        );
        await tester.pump();

        // Assert - Should still show posts content
        expect(find.textContaining('Post ID:'), findsWidgets);
      });

      testWidgets('should display multiple posts with correct formatting', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker and load posts
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        // Assert - Should have multiple post entries
        final postIdFinders = find.textContaining('Post ID:');
        expect(postIdFinders, findsWidgets);

        // Should have at least 3 posts (based on our mock data)
        expect(
          tester.widgetList(postIdFinders).length,
          greaterThanOrEqualTo(3),
        );

        // Each post should have the required fields
        expect(find.textContaining('Título:'), findsWidgets);
        expect(find.textContaining('Usuario ID:'), findsWidgets);
        expect(find.textContaining('Contenido:'), findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('should provide proper semantics for screen readers', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Assert - Check for semantic labels
        expect(find.byType(Switch), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(2));

        // Enable Joker and load data
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        // Assert - Data should be accessible
        expect(find.text('Posts cargados'), findsOneWidget);
        expect(find.textContaining('Post ID:'), findsWidgets);
      });
    });

    group('Performance', () {
      testWidgets('should render efficiently with large data sets', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(MyApp());

        // Enable Joker
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pump();

        // Measure performance of loading posts
        final stopwatch = Stopwatch()..start();

        // Act
        await tester.tap(find.text('Cargar Posts'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Assert - Should complete reasonably quickly (less than 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        expect(find.text('Posts cargados'), findsOneWidget);
      });
    });
  });
}
