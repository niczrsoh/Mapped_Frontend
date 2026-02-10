import 'package:flutter/material.dart';
import 'belt_definitions.dart';

enum RequirementType {
  session,
  activeDay,
  resource,
  recommendation,
  reflection,
  forumPost,
  shareTip,
}

class BeltTaskDef {
  final RequirementType type;
  final int target;
  final String dashboardLabel;
  final String progressLabel;
  final String homeLabel;
  final IconData icon;

  const BeltTaskDef({
    required this.type,
    required this.target,
    required this.dashboardLabel,
    required this.progressLabel,
    required this.homeLabel,
    required this.icon,
  });
}

class BeltRequirement {
  final String beltId;
  final int cumulativeSessionOffset;
  final int cumulativeDayOffset;
  final int cumulativePostOffset;

  final List<BeltTaskDef> tasks;

  const BeltRequirement({
    required this.beltId,
    required this.cumulativeSessionOffset,
    required this.cumulativeDayOffset,
    required this.cumulativePostOffset,
    required this.tasks,
  });
}

class BeltRequirementsData {
  static const Map<String, BeltRequirement> requirements = {
    BeltDefinitions.white: BeltRequirement(
      beltId: BeltDefinitions.white,
      cumulativeSessionOffset: 0,
      cumulativeDayOffset: 0,
      cumulativePostOffset: 0,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 3,
          dashboardLabel: 'Plan',
          progressLabel: 'Plan Session',
          homeLabel: 'Plan Sessions',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.resource,
          target: 3,
          dashboardLabel: 'Open',
          progressLabel: 'Open Resources',
          homeLabel: 'Open Resources',
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 3,
          dashboardLabel: 'Be active in the app for',
          progressLabel: 'Be active in the app',
          homeLabel: 'Be active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    // --- YELLOW BELT ---
    BeltDefinitions.yellow: BeltRequirement(
      beltId: BeltDefinitions.yellow,
      cumulativeSessionOffset: 3,
      cumulativeDayOffset: 3,
      cumulativePostOffset: 0,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 5,
          dashboardLabel: 'Plan',
          progressLabel: 'Plan Session',
          homeLabel: 'Plan Sessions',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 3,
          dashboardLabel: "Use Today's Recommendations",
          progressLabel: "Use Today's Recommendation",
          homeLabel: "Use Today's Recommendations",
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 5,
          dashboardLabel: 'Be active in the app for',
          progressLabel: 'Be active in the app',
          homeLabel: 'Be active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    // --- GREEN BELT ---
    BeltDefinitions.green: BeltRequirement(
      beltId: BeltDefinitions.green,
      cumulativeSessionOffset: 8,
      cumulativeDayOffset: 8,
      cumulativePostOffset: 0,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 8,
          dashboardLabel: 'Plan',
          progressLabel: 'Plan Session',
          homeLabel: 'Plan Sessions',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 5,
          dashboardLabel: "Use Today's Recommendations",
          progressLabel: "Use Today's Recommendation",
          homeLabel: "Use Today's Recommendations",
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.reflection,
          target: 1,
          dashboardLabel: 'Write',
          progressLabel: 'Write Short Reflection',
          homeLabel: 'Write Reflection',
          icon: Icons.edit_note,
        ),
        BeltTaskDef(
          type: RequirementType.forumPost,
          target: 1,
          dashboardLabel: 'Reply in the forum',
          progressLabel: 'Reply in the forum',
          homeLabel: 'Reply to Coach in Forum',
          icon: Icons.forum,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 14,
          dashboardLabel: 'Be active in the app for',
          progressLabel: 'Be active in the app',
          homeLabel: 'Be active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    // --- BLUE BELT ---
    BeltDefinitions.blue: BeltRequirement(
      beltId: BeltDefinitions.blue,
      cumulativeSessionOffset: 16,
      cumulativeDayOffset: 22,
      cumulativePostOffset: 1,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 20,
          dashboardLabel: 'Plan',
          progressLabel: 'Plan Session',
          homeLabel: 'Plan Sessions',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.shareTip,
          target: 1,
          dashboardLabel: 'Share in the Forum',
          progressLabel: 'Share Tip or Resource in the forum',
          homeLabel: 'Share Tip or Resources',
          icon: Icons.lightbulb,
        ),
        BeltTaskDef(
          type: RequirementType.forumPost,
          target: 1,
          dashboardLabel: 'Reply in the Forum',
          progressLabel: 'Reply in the forum',
          homeLabel: 'Reply to Coach in Forum',
          icon: Icons.forum,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 30,
          dashboardLabel: 'Be active in the app for',
          progressLabel: 'Be active in the app',
          homeLabel: 'Be active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    // --- BROWN BELT ---
    BeltDefinitions.brown: BeltRequirement(
      beltId: BeltDefinitions.brown,
      cumulativeSessionOffset: 36,
      cumulativeDayOffset: 52,
      cumulativePostOffset: 2,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 20,
          dashboardLabel: 'Plan',
          progressLabel: 'Plan Session',
          homeLabel: 'Plan Sessions',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 10,
          dashboardLabel: "Us Today's Recommendation",
          progressLabel: "Use Today's Recommendation",
          homeLabel: "Use Today's Recommendations",
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.shareTip,
          target: 3,
          dashboardLabel: "Share in the forum",
          progressLabel: "Share Tips or Resources in the Forum",
          homeLabel: 'Share Tip or Resources',
          icon: Icons.lightbulb,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 60,
          dashboardLabel: 'Be active in the app for',
          progressLabel: 'Be active in the app',
          homeLabel: 'Be active',
          icon: Icons.directions_run,
        ),
      ],
    ),

  //   // --- BLACK BELT ---
  //   BeltDefinitions.black: BeltRequirement(
  //     beltId: BeltDefinitions.black,
  //     cumulativeSessionOffset: 56,
  //     cumulativeDayOffset: 112,
  //     cumulativePostOffset: 2,
  //     tasks: [
  //       BeltTaskDef(
  //         type: RequirementType.activeDay,
  //         target: 15,
  //         dashboardLabel: 'Be active in the app for',
  //         progressLabel: 'Be active in the app',
  //         homeLabel: 'Be active',
  //         icon: Icons.directions_run,
  //       ),
  //     ],
  //   ),
  // };
  BeltDefinitions.black: BeltRequirement(
      beltId: BeltDefinitions.black,
      cumulativeSessionOffset: 56, // Irrelevant based on tasks
      cumulativeDayOffset: 112,    // Irrelevant based on tasks
      cumulativePostOffset: 2,     // Irrelevant based on tasks
      tasks: [
        // FIX: Set target to 0 so it's always complete immediately
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 0, 
          dashboardLabel: 'Mastery Achieved',
          progressLabel: 'Mastery Achieved',
          homeLabel: 'Mastery',
          icon: Icons.star, // Changed icon to Star for mastery
        ),
      ],
    ),
  };

  static BeltRequirement getFor(String beltCode) {
    if (requirements.containsKey(beltCode)) {
      return requirements[beltCode]!;
    }

    try {
      String simpleName = beltCode.split(' - ')[0];

      final def = BeltDefinitions.getByName(simpleName);
      if (requirements.containsKey(def.id)) {
        return requirements[def.id]!;
      }
    } catch (e) {
      print("Error resolving belt requirement for $beltCode: $e");
    }

    print(
      "Warning: Belt Requirements not found for $beltCode, falling back to White.",
    );
    return requirements[BeltDefinitions.white]!;
  }
}
