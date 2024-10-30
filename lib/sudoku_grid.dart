import 'package:flutter/material.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<int?>> grid;
  final List<List<bool>> isInitialValue;
  final List<List<Set<int>>> domains;
  final Function(int row, int col, int? value) onCellChanged;
  final bool showDomains;

  const SudokuGrid({
    super.key,
    required this.grid,
    required this.isInitialValue,
    required this.domains,
    required this.onCellChanged,
    required this.showDomains,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                return SudokuCell(
                  value: grid[row][col],
                  isInitialValue: isInitialValue[row][col],
                  domain: domains[row][col],
                  showDomain: showDomains,
                  onChanged: (value) => onCellChanged(row, col, value),
                  row: row,
                  col: col,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SudokuCell extends StatelessWidget {
  final int? value;
  final bool isInitialValue;
  final Set<int> domain;
  final bool showDomain;
  final Function(int? value) onChanged;
  final int row;
  final int col;

  const SudokuCell({
    super.key,
    required this.value,
    required this.isInitialValue,
    required this.domain,
    required this.showDomain,
    required this.onChanged,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value != null
            ? (isInitialValue ? Colors.grey[200] : Colors.lightBlue[50])
            : Colors.white,
        border: Border(
          right: BorderSide(
            width: (col + 1) % 3 == 0 ? 2.0 : 0.5,
            color: (col + 1) % 3 == 0 ? Colors.black87 : Colors.grey,
          ),
          bottom: BorderSide(
            width: (row + 1) % 3 == 0 ? 2.0 : 0.5,
            color: (row + 1) % 3 == 0 ? Colors.black87 : Colors.grey,
          ),
          left: BorderSide(
            width: col % 3 == 0 ? 2.0 : 0.5,
            color: col % 3 == 0 ? Colors.black87 : Colors.grey,
          ),
          top: BorderSide(
            width: row % 3 == 0 ? 2.0 : 0.5,
            color: row % 3 == 0 ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: TextField(
              textAlign: TextAlign.center,
              controller: TextEditingController(
                text: value?.toString() ?? '',
              ),
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isInitialValue
                    ? Colors.black87
                    : Theme.of(context).primaryColor,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (text) {
                if (text.isEmpty) {
                  onChanged(null);
                } else {
                  final number = int.tryParse(text);
                  if (number != null && number >= 1 && number <= 9) {
                    onChanged(number);
                  }
                }
              },
            ),
          ),
          if (showDomain && value == null)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9, (index) {
                    final number = index + 1;
                    return Center(
                      child: Text(
                        domain.contains(number) ? number.toString() : '',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
