class SupportTicket {
  final String? id;
  final String title;
  final String description;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupportTicket({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    this.status = 'pending',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    String userIdValue;
    if (json['userId'] is String) {
      userIdValue = json['userId'];
    } else if (json['userId'] is Map) {
      userIdValue = json['userId']['_id'] ?? json['userId']['id'] ?? '';
    } else {
      userIdValue = '';
    }

    return SupportTicket(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: userIdValue,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'resolved':
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }
}