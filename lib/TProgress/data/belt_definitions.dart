import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BeltDefinition {
  final String id;
  final String name;
  final Color color;
  final int order;
  final String? nextBeltId;
  final String assetName;

  const BeltDefinition({
    required this.id,
    required this.name,
    required this.color,
    required this.order,
    this.nextBeltId,
    required this.assetName,
  });

  String get assetPath => 'assets/images/progress/$assetName';
}

class BeltDefinitions {
  static const String white = 'W';
  static const String yellow = 'Y';
  static const String green = 'G';
  static const String blue = 'B';
  static const String brown = 'R';
  static const String black = 'L';

  static const List<BeltDefinition> belts = [
    BeltDefinition(
      id: white,
      name: 'belt_white',
      color: Colors.white,
      order: 1,
      nextBeltId: yellow,
      assetName: 'white 1.png',
    ),
    BeltDefinition(
      id: yellow,
      name: 'belt_yellow',
      color: Color(0xFFFFD700),
      order: 2,
      nextBeltId: green,
      assetName: 'yellow 3.png',
    ),
    BeltDefinition(
      id: green,
      name: 'belt_green',
      color: Color(0xFF4CAF50),
      order: 3,
      nextBeltId: blue,
      assetName: 'green 2.png',
    ),
    BeltDefinition(
      id: blue,
      name: 'belt_blue', // Blue 500
      color: Color(0xFF2196F3),
      order: 4,
      nextBeltId: brown,
      assetName: 'blue 2.png',
    ),
    BeltDefinition(
      id: brown,
      name: 'belt_brown',
      color: Color(0xFFA52A2A),
      order: 5,
      nextBeltId: black,
      assetName: 'brown 2.png',
    ),
    BeltDefinition(
      id: black,
      name: 'belt_black',
      color: Color(0xFF000000),
      order: 6,
      nextBeltId: null, // Last belt
      assetName: 'black 2.png',
    ),
  ];

  static BeltDefinition getByCode(String code) {
    return belts.firstWhere((b) => b.id == code, orElse: () => belts.first);
  }

  static BeltDefinition getByName(String name) {
    final cleanName = name.replaceAll(' Belt', '');
    return belts.firstWhere(
      (b) => b.name.toLowerCase() == cleanName.toLowerCase(),
      orElse: () => belts.first,
    );
  }

  static BeltDefinition? getNext(String currentCode) {
    final current = getByCode(currentCode);
    if (current.nextBeltId == null) return null;
    return getByCode(current.nextBeltId!);
  }
}
