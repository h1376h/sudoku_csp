import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_csp/sudoku_solver_screen.dart';

void main() {
  group('SudokuSolverScreen Widget Tests', () {
    testWidgets('should render initial state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SudokuSolverScreen()));

      // Check if the title is present
      expect(find.text('CSP Sudoku Solver'), findsOneWidget);

      // Check if control buttons are present
      expect(find.text('Next Step'), findsOneWidget);
      expect(find.text('Initialize'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Check if algorithm controls are present
      expect(find.text('Algorithm Settings'), findsOneWidget);
      expect(find.text('Backtracking'), findsOneWidget);
      expect(find.text('Forward Checking'), findsOneWidget);
      expect(find.text('MRV'), findsOneWidget);
      expect(find.text('LCV'), findsOneWidget);
    });

    testWidgets('should handle algorithm selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SudokuSolverScreen()));

      // Toggle Forward Checking
      await tester.tap(find.text('Forward Checking'));
      await tester.pump();

      // Toggle MRV
      await tester.tap(find.text('MRV'));
      await tester.pump();

      // Toggle LCV
      await tester.tap(find.text('LCV'));
      await tester.pump();
    });

    testWidgets('should handle grid initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SudokuSolverScreen()));

      // Tap Initialize button
      await tester.tap(find.text('Initialize'));
      await tester.pump();

      // Verify that the explanation text is updated
      expect(find.text('Puzzle initialized with a solvable position'),
          findsOneWidget);
    });

    testWidgets('should handle grid reset', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SudokuSolverScreen()));

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Verify that the explanation text is cleared
      expect(find.text(''), findsOneWidget);
    });
  });
}
