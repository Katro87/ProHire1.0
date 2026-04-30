enum UserRole { client, professional }

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.bio = '',
    this.avatarPath = '',
    this.companyName = '',
    this.lookingForTalent = '',
    this.title = '',
    this.skills = const <String>[],
    this.experienceYears = 0,
    this.previousCompany = '',
    this.workPreferences = const <String>[],
    this.hourlyRate = 5,
    this.walletBalance = 10000,
    this.earnings = 0,
    this.favoriteProfessionalIds = const <String>[],
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String bio;
  final String avatarPath;
  final String companyName;
  final String lookingForTalent;
  final String title;
  final List<String> skills;
  final int experienceYears;
  final String previousCompany;
  final List<String> workPreferences;
  final double hourlyRate;
  final double walletBalance;
  final double earnings;
  final List<String> favoriteProfessionalIds;

  String get name => fullName;

  String get profilePicUrl => avatarPath;

  String? get professionalTitle => title.isEmpty ? null : title;

  String? get experience => experienceYears > 0 ? '$experienceYears years' : null;

  String? get industry => lookingForTalent.isEmpty ? null : lookingForTalent;

  double? get rating => null;

  int? get reviewCount => null;

  UserModel copyWith({
    String? fullName,
    UserRole? role,
    String? bio,
    String? avatarPath,
    String? companyName,
    String? lookingForTalent,
    String? title,
    List<String>? skills,
    int? experienceYears,
    String? previousCompany,
    List<String>? workPreferences,
    double? hourlyRate,
    double? walletBalance,
    double? earnings,
    List<String>? favoriteProfessionalIds,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      companyName: companyName ?? this.companyName,
      lookingForTalent: lookingForTalent ?? this.lookingForTalent,
      title: title ?? this.title,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      previousCompany: previousCompany ?? this.previousCompany,
      workPreferences: workPreferences ?? this.workPreferences,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      walletBalance: walletBalance ?? this.walletBalance,
      earnings: earnings ?? this.earnings,
      favoriteProfessionalIds: favoriteProfessionalIds ?? this.favoriteProfessionalIds,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'bio': bio,
      'avatarPath': avatarPath,
      'companyName': companyName,
      'lookingForTalent': lookingForTalent,
      'title': title,
      'skills': skills,
      'experienceYears': experienceYears,
      'previousCompany': previousCompany,
      'workPreferences': workPreferences,
      'hourlyRate': hourlyRate,
      'walletBalance': walletBalance,
      'earnings': earnings,
      'favoriteProfessionalIds': favoriteProfessionalIds,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: UserRole.values.firstWhere(
        (UserRole role) => role.name == json['role'],
        orElse: () => UserRole.client,
      ),
      bio: (json['bio'] ?? '') as String,
      avatarPath: (json['avatarPath'] ?? '') as String,
      companyName: (json['companyName'] ?? '') as String,
      lookingForTalent: (json['lookingForTalent'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      skills: List<String>.from(json['skills'] ?? const <String>[]),
      experienceYears: (json['experienceYears'] ?? 0) as int,
      previousCompany: (json['previousCompany'] ?? '') as String,
      workPreferences: List<String>.from(json['workPreferences'] ?? const <String>[]),
      hourlyRate: ((json['hourlyRate'] ?? 5) as num).toDouble(),
      walletBalance: ((json['walletBalance'] ?? 10000) as num).toDouble(),
      earnings: ((json['earnings'] ?? 0) as num).toDouble(),
      favoriteProfessionalIds: List<String>.from(
        json['favoriteProfessionalIds'] ?? const <String>[],
      ),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);
}
