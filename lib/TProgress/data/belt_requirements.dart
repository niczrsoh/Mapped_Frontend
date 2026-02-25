import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'belt_definitions.dart';

enum RequirementType {
  session,
  activeDay,
  resource,
  recommendation,
  reflection,
  forumPost,
  shareTip,
  mastery,
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
    this.cumulativeSessionOffset = 0,
    this.cumulativeDayOffset = 0,
    this.cumulativePostOffset = 0,
    required this.tasks,
  });
}

class BeltRequirementsData {
  static const Map<String, BeltRequirement> requirements = {
    BeltDefinitions.white: BeltRequirement(
      beltId: BeltDefinitions.white,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 3,
          dashboardLabel: 'belt_task_dash_plan',
          progressLabel: 'belt_task_prog_plan',
          homeLabel: 'belt_task_home_plan',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.resource,
          target: 3,
          dashboardLabel: 'belt_task_dash_open',
          progressLabel: 'belt_task_prog_open',
          homeLabel: 'belt_task_home_open',
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 3,
          dashboardLabel: 'belt_task_dash_active',
          progressLabel: 'belt_task_prog_active',
          homeLabel: 'belt_task_home_active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    BeltDefinitions.yellow: BeltRequirement(
      beltId: BeltDefinitions.yellow,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 5,
          dashboardLabel: 'belt_task_dash_plan',
          progressLabel: 'belt_task_prog_plan',
          homeLabel: 'belt_task_home_plan',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 3,
          dashboardLabel: 'belt_task_dash_rec',
          progressLabel: 'belt_task_prog_rec',
          homeLabel: 'belt_task_home_rec',
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 5,
          dashboardLabel: 'belt_task_dash_active',
          progressLabel: 'belt_task_prog_active',
          homeLabel: 'belt_task_home_active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    BeltDefinitions.green: BeltRequirement(
      beltId: BeltDefinitions.green,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 8,
          dashboardLabel: 'belt_task_dash_plan',
          progressLabel: 'belt_task_prog_plan',
          homeLabel: 'belt_task_home_plan',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 5,
          dashboardLabel: 'belt_task_dash_rec',
          progressLabel: 'belt_task_prog_rec',
          homeLabel: 'belt_task_home_rec',
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.reflection,
          target: 1,
          dashboardLabel: 'belt_task_dash_write',
          progressLabel: 'belt_task_prog_write',
          homeLabel: 'belt_task_home_write',
          icon: Icons.edit_note,
        ),
        BeltTaskDef(
          type: RequirementType.forumPost,
          target: 1,
          dashboardLabel: 'dash_reply',
          progressLabel: 'dash_reply',
          homeLabel: 'belt_task_home_reply',
          icon: Icons.forum,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 14,
          dashboardLabel: 'belt_task_dash_active',
          progressLabel: 'belt_task_prog_active',
          homeLabel: 'belt_task_home_active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    BeltDefinitions.blue: BeltRequirement(
      beltId: BeltDefinitions.blue,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 20,
          dashboardLabel: 'belt_task_dash_plan',
          progressLabel: 'belt_task_prog_plan',
          homeLabel: 'belt_task_home_plan',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.shareTip,
          target: 1,
          dashboardLabel: 'belt_task_dash_share',
          progressLabel: 'belt_task_prog_share',
          homeLabel: 'belt_task_home_share',
          icon: Icons.lightbulb,
        ),
        BeltTaskDef(
          type: RequirementType.forumPost,
          target: 1,
          dashboardLabel: 'dash_reply',
          progressLabel: 'dash_reply',
          homeLabel: 'belt_task_home_reply',
          icon: Icons.forum,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 30,
          dashboardLabel: 'belt_task_dash_active',
          progressLabel: 'belt_task_prog_active',
          homeLabel: 'belt_task_home_active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    BeltDefinitions.brown: BeltRequirement(
      beltId: BeltDefinitions.brown,
      tasks: [
        BeltTaskDef(
          type: RequirementType.session,
          target: 20,
          dashboardLabel: 'belt_task_dash_plan',
          progressLabel: 'belt_task_prog_plan',
          homeLabel: 'belt_task_home_plan',
          icon: Icons.directions_run,
        ),
        BeltTaskDef(
          type: RequirementType.recommendation,
          target: 10,
          dashboardLabel: 'belt_task_dash_rec',
          progressLabel: 'belt_task_prog_rec',
          homeLabel: 'belt_task_home_rec',
          icon: Icons.fitness_center,
        ),
        BeltTaskDef(
          type: RequirementType.shareTip,
          target: 3,
          dashboardLabel: 'belt_task_dash_share',
          progressLabel: 'belt_task_prog_share',
          homeLabel: 'belt_task_home_share',
          icon: Icons.lightbulb,
        ),
        BeltTaskDef(
          type: RequirementType.activeDay,
          target: 60,
          dashboardLabel: 'belt_task_dash_active',
          progressLabel: 'belt_task_prog_active',
          homeLabel: 'belt_task_home_active',
          icon: Icons.directions_run,
        ),
      ],
    ),

    BeltDefinitions.black: BeltRequirement(
      beltId: BeltDefinitions.black,
      tasks: [
        BeltTaskDef(
          type: RequirementType.mastery,
          target: 0,
          dashboardLabel: 'dash_mastery',
          progressLabel: 'dash_mastery',
          homeLabel: 'belt_mastery',
          icon: Icons.star,
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
      // Fallback
    }
    return requirements[BeltDefinitions.white]!;
  }
}
