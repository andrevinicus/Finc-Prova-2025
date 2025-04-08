import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_repository/src/models/user_model.dart';

class FirebaseUserRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // Cria o usuário no Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid != null) {
      // Cria um UserModel e salva no Firestore
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        photoUrl: userCredential.user?.photoURL,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
