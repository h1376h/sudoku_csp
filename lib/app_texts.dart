class AppTexts {
  // App-wide
  static const appTitle = 'CSP Sudoku Solver';

  // Algorithm Controls
  static const algorithm = 'Algorithm';
  static const backtracking = 'Backtracking';
  static const forwardChecking = 'Forward Checking';
  static const heuristics = 'Heuristics';
  static const mrvTitle = 'Minimum Remaining Values (MRV)';
  static const mrvSubtitle = 'Choose variables with fewest remaining values';
  static const lcvTitle = 'Least Constraining Value (LCV)';
  static const lcvSubtitle = 'Choose values that rule out the fewest choices';
  static const degreeTitle = 'Degree Heuristic';
  static const degreeSubtitle =
      'Break MRV ties by choosing most constrained variables';

  // Control Buttons
  static const nextStep = 'Next Step';
  static const backtrack = 'Backtrack';
  static const sample = 'Sample';
  static const reset = 'Reset';
  static const cspInfo = 'CSP Info';

  // Explanations
  static const currentStepExplanation = 'Current Step';
  static const welcomeMessage = '''Welcome to the CSP Sudoku Solver!

This tool demonstrates how Constraint Satisfaction Problems (CSP) can solve Sudoku puzzles.

• Start by filling numbers or click "Sample"
• Choose your preferred algorithm and heuristics
• Click "Next Step" to see the solver in action
• Each step will explain the reasoning behind the choices''';

  static const variableLabel = 'Variable:';
  static const domainLabel = 'Domain:';
  static const emptyDomain = '∅ (Empty)';
  static const constraintsViolatedLabel = 'Constraints Violated:';
  static const heuristicsInUse = 'Heuristics in use:';
  static const stepLabel = 'Step:';

  static const forwardCheckingContext =
      'Forward Checking: This algorithm looks ahead to see if assigning a value would create impossible situations for other cells. It maintains arc consistency by updating domains of affected cells.';
  static const backtrackingContext =
      "Backtracking: This simple algorithm tries values and backtracks when it reaches an invalid state. It's less efficient but easier to understand.";
  static const mrvContext =
      '\n• MRV (Minimum Remaining Values): Choosing the cell with fewest legal values first reduces our branching factor and helps find dead ends quickly.';
  static const lcvContext =
      '\n• LCV (Least Constraining Value): By choosing values that restrict neighboring cells the least, we keep more options open for future assignments.';
  static const degreeContext =
      '\n• Degree: When MRV results in ties, choose the variable that constrains the most unassigned neighbors.';

  // Dialog
  static const dialogTitle =
      'Sudoku as a Constraint Satisfaction Problem (CSP)';
  static const formalCspModel = 'Formal CSP Model';
  static const formalCspModelContent =
      '''• Variables (X): Each cell in the 9x9 grid
  X = {x₁₁, x₁₂, ..., x₉₉} where xᵢⱼ represents the cell at row i, column j

• Domains (D): Each variable has a domain of integers 1-9
  D = {1, 2, 3, 4, 5, 6, 7, 8, 9} for each empty cell
  D = {k} for cells with initial value k

• Constraints (C):
  1. Row Constraint (Cʳ):
     ∀i ∈ [1,9], ∀k ∈ [1,9]: exactly one xᵢⱼ = k across j ∈ [1,9]
  
  2. Column Constraint (Cᶜ):
     ∀j ∈ [1,9], ∀k ∈ [1,9]: exactly one xᵢⱼ = k across i ∈ [1,9]
  
  3. Box Constraint (Cᵇ):
     ∀b ∈ [1,9], ∀k ∈ [1,9]: exactly one cell in box b = k
  
  4. Initial Value Constraint (Cᵛ):
     For each cell (i,j) with initial value v: xᵢⱼ = v''';

  static const searchAlgorithms = 'Search Algorithms';
  static const searchAlgorithmsContent = '''• Backtracking Search:
  - Assigns values to variables one at a time
  - Backtracks when a constraint violation is detected
  - Simple but potentially inefficient

• Forward Checking:
  - More sophisticated than basic backtracking
  - After each assignment, updates domains of unassigned variables
  - Detects failures earlier by maintaining arc consistency''';

  static const heuristicsSection = 'Heuristics';
  static const heuristicsContent = '''• Minimum Remaining Values (MRV):
  - Variable ordering heuristic
  - Selects the variable with smallest remaining domain
  - Also known as "fail-first" principle
  - Helps identify dead ends quickly

• Degree Heuristic:
  - Tie-breaker for MRV
  - Selects variable involved in most constraints
  - Focuses on most constrained parts first

• Least Constraining Value (LCV):
  - Value ordering heuristic
  - Tries values that rule out the fewest choices for neighboring variables
  - Maximizes flexibility for subsequent assignments''';

  static const consistencyChecking = 'Consistency Checking';
  static const consistencyCheckingContent = '''• Node Consistency:
  - Ensures all values in domain satisfy unary constraints
  
• Arc Consistency:
  - Ensures every value in domain of Xᵢ has a compatible value in domain of Xⱼ
  - Forward checking maintains a limited form of arc consistency
  
• Path Consistency:
  - Ensures consistency between pairs of variables is supported by intermediate variables''';

  static const close = 'Close';

  // Solver Messages
  static const useBacktrackButton =
      'Please use the Backtrack button to undo the last move.';
  static const puzzleSolved = 'Puzzle solved successfully!';
  static const puzzleUnsolvable =
      'This puzzle cannot be solved! Please try a different configuration.';
  static const noValidCells = 'No valid cells remaining. Need to backtrack.';
  static const noValidValues =
      'No valid values for cell ({0}, {1}). Need to backtrack.';
  static const forwardCheckingViolation =
      'Forward checking detected a violation at ({0}, {1}) with value {2}';
  static const forwardCheckingViolationDetails =
      'Arc consistency violation: assignment creates empty domains in related variables.';
  static const sudokuConstraintViolation =
      'Value {0} at ({1}, {2}) violates Sudoku constraints';
  static const rowConstraint = 'Row';
  static const rowConstraintViolation = 'Value {0} already exists in row {1}\n'
      '∀i ∈ [1,9], ∀k ∈ [1,9]: exactly one xᵢⱼ = k across j ∈ [1,9]';
  static const columnConstraint = 'Column';
  static const columnConstraintViolation =
      'Value {0} already exists in column {1}\n'
      '∀j ∈ [1,9], ∀k ∈ [1,9]: exactly one xᵢⱼ = k across i ∈ [1,9]';
  static const boxConstraint = 'Box';
  static const boxConstraintViolation =
      'Value {0} already exists in in 3x3 box containing cell ({1}, {2})\n'
      '∀b ∈ [1,9], ∀k ∈ [1,9]: exactly one cell in box b = k';
  static const noMovesToBacktrack = 'No moves to backtrack from!';
  static const backtrackMessage =
      'Backtracked: removed value {0} from ({1}, {2})';
  static const puzzleInitialized =
      'Puzzle initialized with a solvable position';
  static const valueViolatesConstraints =
      'Value {0} at ({1}, {2}) violates Sudoku {3} constraints';
  static const placedValue = 'Placed value {0} at cell ({1}, {2})';
  static const backtracked = 'Backtracked: removed value {0} from ({1}, {2})';
  static const showDomains = 'Show domains';
  static const algorithmDescription = 'Algorithm Description';
}
