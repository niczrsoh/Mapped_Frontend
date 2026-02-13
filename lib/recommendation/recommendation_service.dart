import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/helper/constants.dart';
import 'recommendation_model.dart';

class RecommendationService {
  
  // Update this to your actual API URL
  static const String baseUrl = '$apiBaseUrl/api/recommendations';
  // For Android emulator: 'https://mapped-backend-node-js-1.onrender.com/api/recommendations'
  // For iOS simulator: 'http://localhost:5000/api/recommendations'
  // For production: 'https://your-domain.com/api/recommendations'
  
  /// Generate a new recommendation
  Future<SessionRecommendation?> generateRecommendation(
    String userId, {
    bool forceNew = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/generate/$userId${forceNew ? '?forceNew=true' : ''}');
      
      print('🔄 Generating recommendation for user: $userId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );
      
      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          print('✅ Recommendation generated successfully');
          return SessionRecommendation.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['error'] ?? 'Server error occurred');
      } else {
        throw Exception('Failed to generate recommendation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generating recommendation: $e');
      rethrow;
    }
  }
  
  /// Get the latest active recommendation
  Future<SessionRecommendation?> getLatestRecommendation(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/latest/$userId');
      
      print('🔄 Fetching latest recommendation for user: $userId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          print('✅ Latest recommendation found');
          return SessionRecommendation.fromJson(jsonData['data']);
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No active recommendation found');
        return null;
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching latest recommendation: $e');
      return null;
    }
  }
  
  /// Get recommendation history
  Future<List<SessionRecommendation>> getHistory(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/history/$userId?limit=$limit');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          return dataList
              .map((item) => SessionRecommendation.fromJson(item))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching history: $e');
      return [];
    }
  }
  
  /// Submit feedback for a recommendation
  Future<bool> submitFeedback({
    required String recommendationId,
    required bool wasUseful,
    required int rating,
    String? comments,
    bool wasImplemented = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/feedback/$recommendationId');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'wasUseful': wasUseful,
          'rating': rating,
          'comments': comments,
          'wasImplemented': wasImplemented,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error submitting feedback: $e');
      return false;
    }
  }
  
  /// Mark recommendation as implemented
  Future<bool> markAsImplemented(String recommendationId) async {
    try {
      final uri = Uri.parse('$baseUrl/implement/$recommendationId');
      
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error marking as implemented: $e');
      return false;
    }
  }
  
  /// Dismiss a recommendation
  Future<bool> dismissRecommendation(String recommendationId) async {
    try {
      final uri = Uri.parse('$baseUrl/$recommendationId');
      
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error dismissing recommendation: $e');
      return false;
    }
  }
  
  /// Get analytics
  Future<Map<String, dynamic>?> getAnalytics(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/analytics/$userId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching analytics: $e');
      return null;
    }
  }
  
  /// Check service health
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == 'healthy';
      }
      
      return false;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }
}