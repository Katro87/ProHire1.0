import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_fiverr/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<List<UserModel>> getProfessionals() {
    return _db.collection('users')
      .where('role', isEqualTo: 'professional')
      .where('profileCompleted', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> seedDemoProfessionals() async {
    final professionals = await _db.collection('users')
      .where('role', isEqualTo: 'professional')
      .limit(1)
      .get();
    
    if (professionals.docs.isEmpty) {
      final List<Map<String, dynamic>> demoPros = [
        {
          'uid': 'demo_pro_1',
          'name': 'Alexandra Mitchell',
          'email': 'alex.demo@minihire.com',
          'role': 'professional',
          'profileCompleted': true,
          'hasSecurityQuestions': true,
          'profilePicUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
          'title': '🏆 Senior UI/UX Designer',
          'professionalTitle': 'Senior UI/UX Designer',
          'skills': ['Figma', 'Adobe XD', 'Prototyping', 'User Research', 'Design Systems', 'Mobile Design', 'Web Design'],
          'experience': '8+ years',
          'hourlyRate': 65.0,
          'bio': 'Award-winning designer specializing in creating beautiful, intuitive interfaces. I have worked with Fortune 500 companies and startups alike. My designs focus on user psychology and conversion optimization.',
          'isAvailable': true,
          'isDemo': true,
          'rating': 4.9,
          'reviewCount': 342,
          'completedProjects': 187,
          'portfolioLinks': ['https://dribbble.com/alexm', 'https://behance.net/alexm'],
          'walletBalance': 12500.0,
          'createdAt': Timestamp.now(),
        },
        {
          'uid': 'demo_pro_2',
          'name': 'Marcus Rodriguez',
          'email': 'marcus.demo@minihire.com',
          'role': 'professional',
          'profileCompleted': true,
          'hasSecurityQuestions': true,
          'profilePicUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
          'title': '⚡ Full Stack Developer',
          'professionalTitle': 'Full Stack Developer',
          'skills': ['Flutter', 'React', 'Node.js', 'Firebase', 'AWS', 'TypeScript', 'PostgreSQL', 'Docker'],
          'experience': '6+ years',
          'hourlyRate': 85.0,
          'bio': 'Full stack engineer passionate about building scalable, high-performance applications. I specialize in Flutter for cross-platform mobile development and cloud architecture on AWS.',
          'isAvailable': true,
          'isDemo': true,
          'rating': 4.8,
          'reviewCount': 256,
          'completedProjects': 134,
          'portfolioLinks': ['https://github.com/marcusdev', 'https://marcusdev.com'],
          'walletBalance': 18750.0,
          'createdAt': Timestamp.now(),
        },
        {
          'uid': 'demo_pro_3',
          'name': 'Sarah Chen',
          'email': 'sarah.demo@minihire.com',
          'role': 'professional',
          'profileCompleted': true,
          'hasSecurityQuestions': true,
          'profilePicUrl': 'https://randomuser.me/api/portraits/women/68.jpg',
          'title': '✍️ Content Strategist & SEO Expert',
          'professionalTitle': 'Content Strategist & SEO Expert',
          'skills': ['Content Writing', 'SEO', 'Copywriting', 'Blog Writing', 'Technical Writing', 'Email Marketing', 'Social Media'],
          'experience': '4+ years',
          'hourlyRate': 45.0,
          'bio': 'I help businesses grow organic traffic through strategic content that converts. My expertise spans technical writing, copywriting, and comprehensive SEO strategies.',
          'isAvailable': true,
          'isDemo': true,
          'rating': 4.7,
          'reviewCount': 189,
          'completedProjects': 98,
          'portfolioLinks': ['https://sarahwrites.com', 'https://medium.com/@sarahchen'],
          'walletBalance': 8750.0,
          'createdAt': Timestamp.now(),
        },
        {
          'uid': 'demo_pro_4',
          'name': 'David Park',
          'email': 'david.demo@minihire.com',
          'role': 'professional',
          'profileCompleted': true,
          'hasSecurityQuestions': true,
          'profilePicUrl': 'https://randomuser.me/api/portraits/men/75.jpg',
          'title': '🎨 Brand Identity Designer',
          'professionalTitle': 'Brand Identity Designer',
          'skills': ['Logo Design', 'Brand Strategy', 'Illustration', 'Typography', 'Packaging Design', 'Adobe Illustrator', 'Photoshop'],
          'experience': '10+ years',
          'hourlyRate': 95.0,
          'bio': 'I create iconic brand identities that stand the test of time. With over a decade of experience, I have helped 200+ businesses establish memorable brands.',
          'isAvailable': true,
          'isDemo': true,
          'rating': 5.0,
          'reviewCount': 412,
          'completedProjects': 230,
          'portfolioLinks': ['https://davidpark.design', 'https://instagram.com/davidparkdesign'],
          'walletBalance': 22300.0,
          'createdAt': Timestamp.now(),
        },
        {
          'uid': 'demo_pro_5',
          'name': 'Emily Watson',
          'email': 'emily.demo@minihire.com',
          'role': 'professional',
          'profileCompleted': true,
          'hasSecurityQuestions': true,
          'profilePicUrl': 'https://randomuser.me/api/portraits/women/22.jpg',
          'title': '📱 Mobile App Developer',
          'professionalTitle': 'Mobile App Developer',
          'skills': ['Flutter', 'Swift', 'Kotlin', 'Firebase', 'UI/UX', 'API Integration', 'App Store Deployment'],
          'experience': '5+ years',
          'hourlyRate': 75.0,
          'bio': 'I turn ideas into stunning mobile applications. Specialized in Flutter for cross-platform development and native iOS/Android.',
          'isAvailable': true,
          'isDemo': true,
          'rating': 4.6,
          'reviewCount': 178,
          'completedProjects': 89,
          'portfolioLinks': ['https://emilyapps.dev', 'https://github.com/emilydev'],
          'walletBalance': 15600.0,
          'createdAt': Timestamp.now(),
        },
      ];

      for (var pro in demoPros) {
        await _db.collection('users').doc(pro['uid']).set(pro);
      }
    }
  }
}
