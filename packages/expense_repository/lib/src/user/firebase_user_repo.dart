import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_repository/src/user/user_model.dart';

class FirebaseUserRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria usuário com e-mail/senha e salva no Firestore
  Future<void> createUser({
    required String name,
    required String email,
    required String telefone,
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
        telefone: telefone,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
    }
  }

  /// Busca usuário no Firestore pelo UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Verifica se o usuário Google já está salvo. Se não estiver, salva.
  Future<void> saveGoogleUserIfNeeded(User firebaseUser) async {
    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        telefone: '', // pode ser preenchido depois
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());
    }
  }
}
