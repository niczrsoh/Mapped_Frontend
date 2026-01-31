import 'package:flutter/material.dart';

/// Defines the metadata for each belt level.
class BeltDefinition {
  final String id; // Internal code (W, Y, G, B, R, L)
  final String name; // Display name
  final Color color; // Display color
  final int order; // Sequence order (1-based)
  final String? nextBeltId; // ID of the subsequent belt
  final String assetName; // Image asset filename

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

/// Central registry of all Belt Definitions.
class BeltDefinitions {
  // Constant Codes
  static const String white = 'W';
  static const String yellow = 'Y';
  static const String green = 'G';
  static const String blue = 'B';
  static const String brown = 'R'; // 'R' mapped to Brown in legacy logic
  static const String black = 'L'; // 'L' mapped to Black in legacy logic

  static const List<BeltDefinition> belts = [
    BeltDefinition(
      id: white,
      name: 'White',
      color: Colors.white,
      order: 1,
      nextBeltId: yellow,
      assetName: 'white 1.png',
    ),
    BeltDefinition(
      id: yellow,
      name: 'Yellow',
      color: Color(0xFFFFD700),
      order: 2,
      nextBeltId: green,
      assetName: 'yellow 3.png',
    ),
    BeltDefinition(
      id: green,
      name: 'Green',
      color: Color(0xFF4CAF50),
      order: 3,
      nextBeltId: blue,
      assetName: 'green 2.png',
    ),
    BeltDefinition(
      id: blue,
      name: 'Blue', // Blue 500
      color: Color(0xFF2196F3),
      order: 4,
      nextBeltId: brown,
      assetName: 'blue 2.png',
    ),
    BeltDefinition(
      id: brown,
      name: 'Brown',
      color: Color(0xFFA52A2A),
      order: 5,
      nextBeltId: black,
      assetName: 'brown 2.png',
    ),
    BeltDefinition(
      id: black,
      name: 'Black',
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
    // Handle "White Belt" vs "White"
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
