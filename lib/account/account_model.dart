// models/account_model.dart
import 'package:flutter/material.dart';

/// Model for menu items in the account screen
class AccountMenuItem {
  final String iconPath;
  final String text;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  AccountMenuItem({
    required this.iconPath,
    required this.text,
    this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}

/// Model for account section grouping
class AccountSection {
  final List<AccountMenuItem> items;
  final bool isDark;

  AccountSection({
    required this.items,
    this.isDark = true,
  });
}

/// Model for user profile header data
class AccountHeaderData {
  final String name;
  final String email;
  final String avatar;
  final String? createdAt;

  AccountHeaderData({
    required this.name,
    required this.email,
    required this.avatar,
    this.createdAt,
  });

  /// Format the created date for display
  String get formattedCreatedDate {
    if (createdAt == null || createdAt!.isEmpty) return '';
    
    try {
      final date = DateTime.parse(createdAt!).toLocal();
      return 'Member since ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  /// Get full avatar URL
  String get avatarUrl {
    if (avatar.isEmpty) return '';
    return 'https://mapped-backend-node-js.onrender.com/$avatar';
  }
}