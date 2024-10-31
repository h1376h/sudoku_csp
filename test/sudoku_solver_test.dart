import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_csp/sudoku_solver.dart';

void main() {
  late SudokuSolver solver;

  setUp(() {
    solver = SudokuSolver();
  });

  group('SudokuSolver Initialization', () {
    test('should initialize with empty grid and full domains', () {
      // Check grid dimensions and emptiness
      expect(solver.grid.length, 9);
      expect(solver.grid.every((row) => row.length == 9), true);
      expect(
          solver.grid.every((row) => row.every((cell) => cell == null)), true);

      // Check domain dimensions and completeness
      final fullDomain = {1, 2, 3, 4, 5, 6, 7, 8, 9};
      expect(solver.domains.length, 9);
      expect(solver.domains.every((row) => row.length == 9), true);
      expect(
          solver.domains.every((row) => row.every((domain) =>
              domain.length == 9 && domain.difference(fullDomain).isEmpty)),
          true);
    });

    test('should initialize sample puzzle correctly', () {
      solver.initializeWithSamplePuzzle();

      // Check specific known values from sample puzzle
      expect(solver.grid[0][0], 5);
      expect(solver.grid[0][1], 3);
      expect(solver.grid[0][2], null);

      // Verify domains are updated for initial values
      expect(solver.domains[0][0], {5});
      expect(solver.domains[0][1], {3});

      // Verify affected domains are constrained
      expect(solver.domains[0][2].contains(5), false);
      expect(solver.domains[0][2].contains(3), false);
    });
  });

  group('Cell Updates and Domain Management', () {
    test('should update cell and propagate constraints correctly', () {
      solver.updateCell(0, 0, 5);

      // Check direct cell update
      expect(solver.grid[0][0], 5);
      expect(solver.domains[0][0], {5});
      expect(solver.isInitialValue[0][0], true);

      // Check row constraints
      for (int col = 1; col < 9; col++) {
        expect(solver.domains[0][col].contains(5), false,
            reason: 'Value 5 should be removed from row domains');
      }

      // Check column constraints
      for (int row = 1; row < 9; row++) {
        expect(solver.domains[row][0].contains(5), false,
            reason: 'Value 5 should be removed from column domains');
      }

      // Check 3x3 box constraints
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (row != 0 || col != 0) {
            expect(solver.domains[row][col].contains(5), false,
                reason: 'Value 5 should be removed from box domains');
          }
        }
      }
    });

    test('should handle multiple cell updates and domain interactions', () {
      // Create a specific scenario
      solver.updateCell(0, 0, 5);
      solver.updateCell(0, 1, 3);
      solver.updateCell(1, 0, 6);

      // Check direct updates
      expect(solver.grid[0][0], 5);
      expect(solver.grid[0][1], 3);
      expect(solver.grid[1][0], 6);

      // Check combined domain effects
      final expectedDomain = {1, 2, 4, 7, 8, 9};
      expect(solver.domains[0][2], expectedDomain,
          reason: 'Domain should exclude 3, 5, and 6');
    });

    test('should restore domains correctly when cell is cleared', () {
      // Setup initial state
      solver.updateCell(0, 0, 5);
      solver.updateCell(0, 1, 3);

      // Clear a cell
      solver.updateCell(0, 0, null);

      // Check cell was cleared
      expect(solver.grid[0][0], null);
      expect(solver.isInitialValue[0][0], false);

      // Check domain was properly restored
      final expectedDomain = {1, 2, 4, 6, 7, 8, 9}; // Should exclude 3, 5
      expect(solver.domains[0][0], expectedDomain,
          reason:
              'Domain should be restored but still respect remaining constraints');
    });
  });

  group('Solving Algorithm', () {
    test('should detect unsolvable configurations', () {
      // Create an impossible situation (same value in row)
      solver.updateCell(0, 0, 5);
      solver.updateCell(0, 1, 5);

      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: false,
        useLCV: false,
        useDegree: false,
      );

      expect(result.success, false);
      expect(result.constraintsViolated, isNotNull);
    });

    test('should solve simple configurations', () {
      // Setup a nearly complete puzzle
      solver.initializeWithSamplePuzzle();

      var isComplete = false;
      var steps = 0;
      const maxSteps = 100; // Prevent infinite loops in test

      while (!isComplete && steps < maxSteps) {
        final result = solver.solveStep(
          isForwardChecking: true,
          useMRV: true,
          useLCV: true,
          useDegree: true,
        );

        if (!result.success) {
          solver.backtrack();
        }

        isComplete = solver.isComplete();
        steps++;
      }

      expect(isComplete, true, reason: 'Should solve the sample puzzle');
    });
  });

  group('Heuristics', () {
    test('should apply MRV heuristic correctly', () {
      // Create a scenario where one cell has fewer options
      solver.updateCell(0, 0, 1);
      solver.updateCell(0, 1, 2);
      solver.updateCell(0, 2, 3);
      solver.updateCell(1, 0, 4);
      solver.updateCell(2, 0, 5);

      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: true,
        useLCV: false,
        useDegree: false,
      );

      expect(result.success, true);
      expect(result.variable, contains('(1, 1)'),
          reason: 'Should choose cell with fewest remaining values');
    });

    test('should apply degree heuristic as MRV tiebreaker', () {
      // Create a scenario with equal MRV but different degrees
      solver.updateCell(0, 0, 1);
      solver.updateCell(0, 1, 2);
      solver.updateCell(1, 0, 3);
      solver.updateCell(2, 0, 4);

      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: true,
        useLCV: false,
        useDegree: true,
      );

      expect(result.success, true);
      // Should choose cell with more constraints
      expect(result.variable, contains('(1, 1)'));
    });
  });
}
