class TraineeModel {
  String? id;
  final String? trainerId;
  final String name;
  final String belt;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String email;
  final String address;
  final String guardianName;
  final String guardianContact;
  final String guardianAddress;
  final String goals;
  final String conditions;
  final String competency;
  final String? imagePath;

  TraineeModel({
    this.id,
    this.trainerId,
    required this.name,
    required this.belt,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.email,
    required this.address,
    required this.guardianName,
    required this.guardianContact,
    required this.guardianAddress,
    required this.goals,
    required this.conditions,
    required this.competency,
    this.imagePath,
  });

  factory TraineeModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return TraineeModel(
      id: id ?? json['id'],
      trainerId: json['trainerId'],
      name: json['name'] ?? '',
      belt: json['belt'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      guardianName: json['guardianName'] ?? '',
      guardianContact: json['guardianContact'] ?? '',
      guardianAddress: json['guardianAddress'] ?? '',
      goals: json['goals']?.toString() ?? '',
      conditions: json['conditions']?.toString() ?? '',
      competency: json['competency']?.toString() ?? '',
      imagePath: json['image'] ?? json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainerId': trainerId,
      'name': name,
      'belt': belt,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'email': email,
      'address': address,
      'guardianName': guardianName,
      'guardianContact': guardianContact,
      'guardianAddress': guardianAddress,
      'goals': goals,
      'conditions': conditions,
      'competency': competency,
      'image': imagePath,
      'imagePath': imagePath,
    };
  }
}
