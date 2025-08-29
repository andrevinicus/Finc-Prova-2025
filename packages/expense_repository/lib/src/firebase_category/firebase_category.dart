import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');

  @override
  Future<void> createCategory(Category category) async {
    try {
      print('Criando categoria: ${category.name}, ID: ${category.categoryId}');
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
      print('✅ Categoria criada com sucesso: ${category.categoryId}');
    } catch (e, st) {
      print('❌ Erro ao criar categoria: $e\n$st');
      throw Exception('Erro ao criar categoria');
    }
  }

  @override
  Future<List<Category>> getCategories(String userId) async {
    try {
      print('Buscando categorias para userId=$userId');
      final snapshot = await categoryCollection
          .where('userId', isEqualTo: userId)
          .get();

      print('📄 Documentos encontrados: ${snapshot.docs.length}');
      if (snapshot.docs.isEmpty) return [];

      final categories = <Category>[];
      for (var doc in snapshot.docs) {
        try {
          final entity = CategoryEntity.fromDocument(doc.data());
          final category = Category.fromEntity(entity);
          categories.add(category);
          print(
              '✅ Categoria carregada Firebase: ${category.name}, ID: ${category.categoryId}, Icon: ${category.icon}, Color: ${category.color}');
        } catch (e, st) {
          print('❌ Falha ao parsear documento ${doc.id}: $e\n$st');
        }
      }

      print('Total de categorias válidas carregadas: ${categories.length}');
      return categories;
    } catch (e, st) {
      print('❌ Erro ao buscar categorias: $e\n$st');
      throw Exception('Erro ao buscar categorias');
    }
  }
}
