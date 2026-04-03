// models/account_model.dart
import 'package:flutter/material.dart';
import 'package:mapped_frontend/services/api_service.dart';

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
  

  AccountSection({required this.items, this.isDark = true});
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

  /// Get full avatar URL with cache-busting parameter
  String get avatarUrl {
    final ApiService _apiService = ApiService();
    if (avatar.isEmpty) return '';

    // Check if avatar is already a full URL (Cloudinary)
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      // Already a full URL, just add cache-busting timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final separator = avatar.contains('?') ? '&' : '?';
      return '$avatar${separator}t=$timestamp';
    }

    // Relative path, prepend backend URL
    final baseUrl = '${_apiService.baseUrl}/$avatar';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl?t=$timestamp';
  }
}
