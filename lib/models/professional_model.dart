class ProfessionalModel {
  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.title,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.bio,
    required this.photoUrl,
    required this.availability,
    required this.experience,
    required this.previousCompany,
    required this.lookingFor,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final String title;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final List<String> skills;
  final String bio;
  final String photoUrl;
  final String availability;
  final String experience;
  final String previousCompany;
  final List<String> lookingFor;
  final bool isOnline;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'title': title,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'reviewCount': reviewCount,
      'skills': skills,
      'bio': bio,
      'photoUrl': photoUrl,
      'availability': availability,
      'experience': experience,
      'previousCompany': previousCompany,
      'lookingFor': lookingFor,
      'isOnline': isOnline,
    };
  }

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      skills: List<String>.from(json['skills'] ?? const <String>[]),
      bio: json['bio'] as String,
      photoUrl: json['photoUrl'] as String,
      availability: json['availability'] as String,
      experience: json['experience'] as String,
      previousCompany: json['previousCompany'] as String,
      lookingFor: List<String>.from(json['lookingFor'] ?? const <String>[]),
      isOnline: (json['isOnline'] ?? false) as bool,
    );
  }
}
