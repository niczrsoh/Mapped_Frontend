class SessionModel {
  String? id;
  String? trainerId;
  String? trainer;
  String? date;
  String? uiDate;
  String? duration;
  String? venue;
  String? totalTrainees;
  String? sessionNo;
  String? ageRange;
  String? level;
  String? riskAssessment;
  String? resources;
  String? othersInvolved;
  String? goals;
  Map<String, dynamic>? warmup;
  Map<String, dynamic>? activity;
  Map<String, dynamic>? cooldown;
  String? contingencies;
  Map<String, dynamic>? reflection;

  SessionModel({
    this.id,
    this.trainerId,
    this.trainer,
    this.date,
    this.uiDate,
    this.duration,
    this.venue,
    this.totalTrainees,
    this.sessionNo,
    this.ageRange,
    this.level,
    this.riskAssessment,
    this.resources,
    this.othersInvolved,
    this.goals,
    this.warmup,
    this.activity,
    this.cooldown,
    this.contingencies,
    this.reflection,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      trainerId: json['trainerId']?.toString(),
      trainer: json['trainer']?.toString(),
      date: json['date']?.toString(),
      uiDate: json['uiDate']?.toString(),
      duration: json['duration']?.toString(),
      venue: json['venue']?.toString(),
      totalTrainees: (json['totalTrainees'] ?? json['pax'])?.toString(),
      sessionNo: json['sessionNo']?.toString(),
      ageRange: json['ageRange']?.toString(),
      level: json['level']?.toString(),
      riskAssessment: json['riskAssessment']?.toString(),
      resources: json['resources']?.toString(),
      othersInvolved: json['othersInvolved']?.toString(),
      goals: json['goals']?.toString(),
      warmup: json['warmup'] != null
          ? Map<String, dynamic>.from(json['warmup'])
          : null,
      activity: json['activity'] != null
          ? Map<String, dynamic>.from(json['activity'])
          : null,
      cooldown: json['cooldown'] != null
          ? Map<String, dynamic>.from(json['cooldown'])
          : null,
      contingencies: json['contingencies']?.toString(),
      reflection: json['reflection'] != null
          ? Map<String, dynamic>.from(json['reflection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trainerId': trainerId,
      'trainer': trainer,
      'date': date,
      if (uiDate != null) 'uiDate': uiDate,
      'duration': duration,
      'venue': venue,
      'totalTrainees': totalTrainees,
      'pax': totalTrainees,
      'sessionNo': sessionNo,
      'ageRange': ageRange,
      'level': level,
      'riskAssessment': riskAssessment,
      'resources': resources,
      'othersInvolved': othersInvolved,
      'goals': goals,
      'warmup': warmup,
      'activity': activity,
      'cooldown': cooldown,
      'contingencies': contingencies,
      'reflection': reflection,
    };
  }
}
