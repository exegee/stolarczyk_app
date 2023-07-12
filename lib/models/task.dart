class Task {
  String? uid;
  String name;
  String description;
  bool status; // 0 - not completed, 1 - completed

  Task(
      {this.uid,
      required this.name,
      required this.description,
      required this.status});

  Map<String, dynamic> toMap() =>
      {'name': name, 'description': description, 'status': status};

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
        uid: data['uid'],
        name: data['name'],
        description: data['description'],
        status: data['status']);
  }
}
