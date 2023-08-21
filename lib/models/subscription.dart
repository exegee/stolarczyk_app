class Subscription {
  String? id;
  String userId;
  String topicId;

  Subscription({
    this.id,
    required this.userId,
    required this.topicId,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'topicId': topicId,
      };

  factory Subscription.fromMap(Map<String, dynamic> data) {
    return Subscription(
      //id: data['id'],
      userId: data['userId'],
      topicId: data['topicId'],
    );
  }
}
