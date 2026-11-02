import "package:flutter/material.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/theme/app_palette.dart";

class CompetitionChips extends StatelessWidget {
  const CompetitionChips({
    required this.selected,
    required this.onSelected,
    this.competitions = Competition.browsable,
    super.key,
  });

  final List<Competition> competitions;
  final Competition selected;
  final ValueChanged<Competition> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: competitions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final competition = competitions[index];
          final isSelected = competition == selected;
          return ChoiceChip(
            label: Text(competition.name),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(competition),
            labelStyle: TextStyle(
              color: isSelected ? palette.onAccent : palette.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            selectedColor: palette.accent,
            backgroundColor: palette.surface,
            side: BorderSide(color: isSelected ? palette.accent : palette.line),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
