class Comment {
  final String id;
  final String name;
  final String text;
  final String timeAgo;

  Comment({
    required this.id,
    required this.name,
    required this.text,
    required this.timeAgo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final diff = DateTime.now().difference(date);
    String timeAgo = '${diff.inMinutes}m';
    if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d';

    return Comment(
      id: json['_id'],
      name: json['name'] ?? 'Unknown',
      text: json['text'],
      timeAgo: timeAgo,
    );
  }
}
