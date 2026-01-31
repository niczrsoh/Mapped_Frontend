class BeltProgressModelV2 {
  final String beltColor; 
  final int planSessionCount; 
  final int reqSessionCount; 
  final ProgressCounters progress;
  final bool isCompleted;
  final String? assignedTrainerId;
  final double? progressPercentage; 

  BeltProgressModelV2({
    required this.beltColor,
    required this.planSessionCount,
    required this.reqSessionCount,
    required this.progress,
    required this.isCompleted,
    required this.assignedTrainerId,
    this.progressPercentage,
  });

  factory BeltProgressModelV2.fromJson(Map<String, dynamic> json) {
    return BeltProgressModelV2(
      beltColor: json['beltColor'],
      planSessionCount: json['planSessionCount'] ?? 0,
      reqSessionCount: json['reqSessionCount'] ?? 0,
      progress: ProgressCounters.fromJson(
        json,
      ), // Use json directly as fields are there
      isCompleted: json['isCompleted'] ?? false,
      assignedTrainerId: json['assignedTrainerId'],
      progressPercentage: (json['progressPercentage'] is num)
          ? (json['progressPercentage'] as num).toDouble()
          : 0.0,
    );
  }
}

class ProgressCounters {
  final int recommendationCount;
  final int sessionPhotoCount;
  final int activeDayCount;
  final int postCount;
  final int writeShortDescriptionCount;
  final int shareTipCount;
  final int resourceCount;
  final int openResourceCount;

  ProgressCounters({
    this.recommendationCount = 0,
    this.sessionPhotoCount = 0,
    this.activeDayCount = 0,
    this.postCount = 0,
    this.writeShortDescriptionCount = 0,
    this.shareTipCount = 0,
    this.resourceCount = 0,
    this.openResourceCount = 0,
  });

  factory ProgressCounters.fromJson(Map<String, dynamic> json) {
    return ProgressCounters(
      recommendationCount: json['recommendationCount'] ?? 0,
      sessionPhotoCount: json['sessionPhotoCount'] ?? 0,
      activeDayCount: json['activeDayCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      writeShortDescriptionCount: json['writeShortDescriptionCount'] ?? 0,
      shareTipCount: json['shareTipCount'] ?? 0,
      resourceCount: json['resourceCount'] ?? 0,
      openResourceCount: json['openResourceCount'] ?? 0,
    );
  }
}
