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
          'name': 'Alice Johnson',
          'email': 'alice@example.com',
          'role': 'professional',
          'professionalTitle': 'Senior UI/UX Designer',
          'skills': ['Figma', 'Adobe XD', 'User Research', 'Prototyping', 'Design Systems'],
          'experience': '5-10 years',
          'hourlyRate': 55.0,
          'bio': 'Award-winning designer with 8+ years experience creating intuitive interfaces.',
          'profilePicUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
          'profileCompleted': true,
          'createdAt': Timestamp.now(),
          'walletBalance': 0.0,
        },
        {
          'uid': 'demo_pro_2',
          'name': 'Marcus Chen',
          'email': 'marcus@example.com',
          'role': 'professional',
          'professionalTitle': 'Full Stack Developer',
          'skills': ['React', 'Node.js', 'Flutter', 'Firebase', 'AWS'],
          'experience': '3-5 years',
          'hourlyRate': 75.0,
          'bio': 'Full stack engineer passionate about building scalable applications.',
          'profilePicUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
          'profileCompleted': true,
          'createdAt': Timestamp.now(),
          'walletBalance': 0.0,
        },
      ];

      for (var pro in demoPros) {
        await _db.collection('users').doc(pro['uid']).set(pro);
      }
    }
  }
}
