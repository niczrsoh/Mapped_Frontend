class SessionRecommendation {
  final String id;
  final String userId;
  final DateTime recommendationDate;
  final DateTime expiresAt;
  final AnalysisContext analysisContext;
  final Patterns patterns;
  final Recommendation recommendation;
  final Insights insights;
  final AIMetadata aiMetadata;
  final String status;
  final bool? cached;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SessionRecommendation({
    required this.id,
    required this.userId,
    required this.recommendationDate,
    required this.expiresAt,
    required this.analysisContext,
    required this.patterns,
    required this.recommendation,
    required this.insights,
    required this.aiMetadata,
    required this.status,
    this.cached,
    this.createdAt,
    this.updatedAt,
  });

  factory SessionRecommendation.fromJson(Map<String, dynamic> json) {
    return SessionRecommendation(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      recommendationDate: DateTime.parse(json['recommendationDate']),
      expiresAt: DateTime.parse(json['expiresAt']),
      analysisContext: AnalysisContext.fromJson(json['analysisContext'] ?? {}),
      patterns: Patterns.fromJson(json['patterns'] ?? {}),
      recommendation: Recommendation.fromJson(json['recommendation'] ?? {}),
      insights: Insights.fromJson(json['insights'] ?? {}),
      aiMetadata: AIMetadata.fromJson(json['aiMetadata'] ?? {}),
      status: json['status'] ?? 'active',
      cached: json['cached'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'recommendationDate': recommendationDate.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'analysisContext': analysisContext.toJson(),
      'patterns': patterns.toJson(),
      'recommendation': recommendation.toJson(),
      'insights': insights.toJson(),
      'aiMetadata': aiMetadata.toJson(),
      'status': status,
      'cached': cached,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SessionRecommendation copyWith({
    String? status,
  }) {
    return SessionRecommendation(
      id: id,
      userId: userId,
      recommendationDate: recommendationDate,
      expiresAt: expiresAt,
      analysisContext: analysisContext,
      patterns: patterns,
      recommendation: recommendation,
      insights: insights,
      aiMetadata: aiMetadata,
      status: status ?? this.status,
      cached: cached,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AnalysisContext {
  final int totalSessionsAnalyzed;
  final int recentSessionsCount;
  final String userBeltLevel;
  final String userRole;
  final DateTime? lastSessionDate;
  final int daysSinceLastSession;
  final int averageSessionDuration;
  final List<String> commonVenues;
  final int? typicalTraineeCount;

  AnalysisContext({
    required this.totalSessionsAnalyzed,
    required this.recentSessionsCount,
    required this.userBeltLevel,
    required this.userRole,
    this.lastSessionDate,
    required this.daysSinceLastSession,
    required this.averageSessionDuration,
    required this.commonVenues,
    this.typicalTraineeCount,
  });

  factory AnalysisContext.fromJson(Map<String, dynamic> json) {
    return AnalysisContext(
      totalSessionsAnalyzed: json['totalSessionsAnalyzed'] ?? 0,
      recentSessionsCount: json['recentSessionsCount'] ?? 0,
      userBeltLevel: json['userBeltLevel'] ?? 'White',
      userRole: json['userRole'] ?? 'trainee',
      lastSessionDate: json['lastSessionDate'] != null 
          ? DateTime.parse(json['lastSessionDate']) 
          : null,
      daysSinceLastSession: json['daysSinceLastSession'] ?? 0,
      averageSessionDuration: json['averageSessionDuration'] ?? 60,
      commonVenues: List<String>.from(json['commonVenues'] ?? []),
      typicalTraineeCount: json['typicalTraineeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessionsAnalyzed': totalSessionsAnalyzed,
      'recentSessionsCount': recentSessionsCount,
      'userBeltLevel': userBeltLevel,
      'userRole': userRole,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'daysSinceLastSession': daysSinceLastSession,
      'averageSessionDuration': averageSessionDuration,
      'commonVenues': commonVenues,
      'typicalTraineeCount': typicalTraineeCount,
    };
  }
}

class Patterns {
  final String? preferredLevel;
  final String? commonAgeRange;
  final List<String> frequentGoals;
  final int? consistencyScore;

  Patterns({
    this.preferredLevel,
    this.commonAgeRange,
    required this.frequentGoals,
    this.consistencyScore,
  });

  factory Patterns.fromJson(Map<String, dynamic> json) {
    return Patterns(
      preferredLevel: json['preferredLevel'],
      commonAgeRange: json['commonAgeRange'],
      frequentGoals: List<String>.from(json['frequentGoals'] ?? []),
      consistencyScore: json['consistencyScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredLevel': preferredLevel,
      'commonAgeRange': commonAgeRange,
      'frequentGoals': frequentGoals,
      'consistencyScore': consistencyScore,
    };
  }
}

class Recommendation {
  final String suggestedLevel;
  final int suggestedDuration;
  final String recommendedVenue;
  final String suggestedAgeRange;
  final int suggestedTraineeCount;
  final Goals goals;
  final SessionPhase warmup;
  final Activity activity;
  final SessionPhase cooldown;
  final Contingencies contingencies;
  final RiskAssessment riskAssessment;
  final Resources resources;

  Recommendation({
    required this.suggestedLevel,
    required this.suggestedDuration,
    required this.recommendedVenue,
    required this.suggestedAgeRange,
    required this.suggestedTraineeCount,
    required this.goals,
    required this.warmup,
    required this.activity,
    required this.cooldown,
    required this.contingencies,
    required this.riskAssessment,
    required this.resources,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      suggestedLevel: json['suggestedLevel'] ?? 'Beginner',
      suggestedDuration: json['suggestedDuration'] ?? 60,
      recommendedVenue: json['recommendedVenue'] ?? '',
      suggestedAgeRange: json['suggestedAgeRange'] ?? '',
      suggestedTraineeCount: json['suggestedTraineeCount'] ?? 1,
      goals: Goals.fromJson(json['goals'] ?? {}),
      warmup: SessionPhase.fromJson(json['warmup'] ?? {}),
      activity: Activity.fromJson(json['activity'] ?? {}),
      cooldown: SessionPhase.fromJson(json['cooldown'] ?? {}),
      contingencies: Contingencies.fromJson(json['contingencies'] ?? {}),
      riskAssessment: RiskAssessment.fromJson(json['riskAssessment'] ?? {}),
      resources: Resources.fromJson(json['resources'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestedLevel': suggestedLevel,
      'suggestedDuration': suggestedDuration,
      'recommendedVenue': recommendedVenue,
      'suggestedAgeRange': suggestedAgeRange,
      'suggestedTraineeCount': suggestedTraineeCount,
      'goals': goals.toJson(),
      'warmup': warmup.toJson(),
      'activity': activity.toJson(),
      'cooldown': cooldown.toJson(),
      'contingencies': contingencies.toJson(),
      'riskAssessment': riskAssessment.toJson(),
      'resources': resources.toJson(),
    };
  }
}

class Goals {
  final String primary;
  final List<String> secondary;
  final String reasoning;

  Goals({
    required this.primary,
    required this.secondary,
    required this.reasoning,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      primary: json['primary'] ?? '',
      secondary: List<String>.from(json['secondary'] ?? []),
      reasoning: json['reasoning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'reasoning': reasoning,
    };
  }
}

class SessionPhase {
  final String description;
  final int suggestedTime;
  final List<String> keyExercises;

  SessionPhase({
    required this.description,
    required this.suggestedTime,
    required this.keyExercises,
  });

  factory SessionPhase.fromJson(Map<String, dynamic> json) {
    return SessionPhase(
      description: json['description'] ?? '',
      suggestedTime: json['suggestedTime'] ?? 10,
      keyExercises: List<String>.from(json['keyExercises'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'suggestedTime': suggestedTime,
      'keyExercises': keyExercises,
    };
  }
}

class Activity {
  final String description;
  final int suggestedTime;
  final List<String> focusAreas;
  final List<String> drills;
  final List<String> progressionTips;

  Activity({
    required this.description,
    required this.suggestedTime,
    required this.focusAreas,
    required this.drills,
    required this.progressionTips,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      description: json['description'] ?? '',
      suggestedTime: json['suggestedTime'] ?? 40,
      focusAreas: List<String>.from(json['focusAreas'] ?? []),
      drills: List<String>.from(json['drills'] ?? []),
      progressionTips: List<String>.from(json['progressionTips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'suggestedTime': suggestedTime,
      'focusAreas': focusAreas,
      'drills': drills,
      'progressionTips': progressionTips,
    };
  }
}

class Contingencies {
  final String description;
  final List<Scenario> scenarios;

  Contingencies({
    required this.description,
    required this.scenarios,
  });

  factory Contingencies.fromJson(Map<String, dynamic> json) {
    return Contingencies(
      description: json['description'] ?? '',
      scenarios: (json['scenarios'] as List<dynamic>?)
              ?.map((s) => Scenario.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'scenarios': scenarios.map((s) => s.toJson()).toList(),
    };
  }
}

class Scenario {
  final String situation;
  final String solution;

  Scenario({
    required this.situation,
    required this.solution,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      situation: json['situation'] ?? '',
      solution: json['solution'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'situation': situation,
      'solution': solution,
    };
  }
}

class RiskAssessment {
  final String description;
  final List<String> keyRisks;
  final List<String> mitigationStrategies;

  RiskAssessment({
    required this.description,
    required this.keyRisks,
    required this.mitigationStrategies,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      description: json['description'] ?? '',
      keyRisks: List<String>.from(json['keyRisks'] ?? []),
      mitigationStrategies: List<String>.from(json['mitigationStrategies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'keyRisks': keyRisks,
      'mitigationStrategies': mitigationStrategies,
    };
  }
}

class Resources {
  final String description;
  final List<String> required;
  final List<String> optional;

  Resources({
    required this.description,
    required this.required,
    required this.optional,
  });

  factory Resources.fromJson(Map<String, dynamic> json) {
    return Resources(
      description: json['description'] ?? '',
      required: List<String>.from(json['required'] ?? []),
      optional: List<String>.from(json['optional'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'required': required,
      'optional': optional,
    };
  }
}

class Insights {
  final List<String> strengthAreas;
  final List<String> improvementAreas;
  final String motivationalMessage;
  final String progressionPath;
  final List<String> tipsForToday;

  Insights({
    required this.strengthAreas,
    required this.improvementAreas,
    required this.motivationalMessage,
    required this.progressionPath,
    required this.tipsForToday,
  });

  factory Insights.fromJson(Map<String, dynamic> json) {
    return Insights(
      strengthAreas: List<String>.from(json['strengthAreas'] ?? []),
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      motivationalMessage: json['motivationalMessage'] ?? '',
      progressionPath: json['progressionPath'] ?? '',
      tipsForToday: List<String>.from(json['tipsForToday'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strengthAreas': strengthAreas,
      'improvementAreas': improvementAreas,
      'motivationalMessage': motivationalMessage,
      'progressionPath': progressionPath,
      'tipsForToday': tipsForToday,
    };
  }
}

class AIMetadata {
  final String model;
  final TokensUsed tokensUsed;
  final int generationTime;
  final bool cached;

  AIMetadata({
    required this.model,
    required this.tokensUsed,
    required this.generationTime,
    required this.cached,
  });

  factory AIMetadata.fromJson(Map<String, dynamic> json) {
    return AIMetadata(
      model: json['model'] ?? '',
      tokensUsed: TokensUsed.fromJson(json['tokensUsed'] ?? {}),
      generationTime: json['generationTime'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'tokensUsed': tokensUsed.toJson(),
      'generationTime': generationTime,
      'cached': cached,
    };
  }
}

class TokensUsed {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  TokensUsed({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokensUsed.fromJson(Map<String, dynamic> json) {
    return TokensUsed(
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }
}