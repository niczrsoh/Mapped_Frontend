class SampleModel {
  final String message;

  SampleModel({required this.message});

  factory SampleModel.fromJson(dynamic json) {
    return SampleModel(message: json['message']?.toString() ?? '');
  }
}