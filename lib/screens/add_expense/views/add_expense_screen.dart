import 'dart:io';
// Flutter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Packages externos
import 'package:expense_repository/expense_repository.dart';
// Arquivos internos
import 'package:finc/screens/add_expense/expenses/ExpenseAmountField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseBankField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseCategoryField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseDescriptionField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseSaveButton.dart';
import 'package:finc/screens/add_expense/modals/upload_dir.dart';

class AddExpenseScreen extends StatefulWidget {
  final String userId;
  const AddExpenseScreen({super.key, required this.userId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _selectedImageName;
  final _amountController = TextEditingController();
  final _descricaoController = TextEditingController();
  BankAccountEntity? _selectedBank;
  late final String userId;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String truncatedName(String? name) {
    if (name == null) return 'Selecionar Imagem';
    if (name.length <= 25) return name;

    final ext = name.contains('.') ? name.split('.').last : '';
    final baseName = name.substring(0, 22 - (ext.length + 1));
    return '$baseName...${ext.isNotEmpty ? '.$ext' : ''}';
  }

  Future<String?> uploadImagemComUserIdERetornarId(File imagem) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userId = user.uid;
      final nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      final caminho = "usuarios/$userId/imagens/$nomeArquivo.jpg";

      final ref = FirebaseStorage.instance.ref().child(caminho);
      final snapshot = await ref.putFile(imagem);
      final urlDownload = await snapshot.ref.getDownloadURL();

      final docRef = await FirebaseFirestore.instance.collection("imagens").add(
        {"userId": userId, "url": urlDownload, "criado_em": DateTime.now()},
      );

      print("Path da imagem: ${imagem.path}");
      return docRef.id;
    } catch (e) {
      print("Erro ao enviar imagem: $e");
      return null;
    }
  }

  Widget _buildDateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          TextButton(
            child: const Text("Alterar", style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blueAccent,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: () async {
        final pickedFile = await showImagePickerModal(context);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = pickedFile;
            _selectedImageName = pickedFile.path.split('/').last;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            const Icon(Icons.image, color: Colors.grey),
            const SizedBox(width: 16),
            if (_selectedImage != null)
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
            if (_selectedImage != null) const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  truncatedName(_selectedImageName),
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bottomContainerColor = Color.fromARGB(115, 206, 206, 206);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 2),
              const Text(
                "Nova Despesa",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        body: SafeArea( // <<<<<< aqui corrige a sobreposição
          child: Column(
            children: [
              ExpenseAmountField(
                amount: _amountController.text,
                onAmountChanged: (value) =>
                    setState(() => _amountController.text = value),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: bottomContainerColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildDateRow(context),
                          const Divider(
                              height: 10, thickness: 0.8, color: Colors.grey),
                          ExpenseCategoryField(
                            userId: userId,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (cat) =>
                                setState(() => _selectedCategory = cat),
                          ),
                          const Divider(
                              height: 10, thickness: 0.8, color: Colors.grey),
                          ExpenseDescriptionField(
                              controller: _descricaoController),
                          const Divider(
                              height: 10, thickness: 0.8, color: Colors.grey),
                          ExpenseBankField(
                            userId: userId,
                            selectedBank: _selectedBank,
                            onBankSelected: (bank) =>
                                setState(() => _selectedBank = bank),
                          ),
                          const Divider(
                              height: 6, thickness: 0.8, color: Colors.grey),
                          _buildImagePicker(),
                          const Divider(
                              height: 6, thickness: 0.8, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12), // espaço extra para não grudar no botão Home
          child: ExpenseSaveButton(
            amountText: _amountController.text,
            selectedBankId: _selectedBank?.id,
            selectedCategory: _selectedCategory,
            selectedDate: _selectedDate,
            description: _descricaoController.text,
            selectedImage: _selectedImage,
            uploadImage: uploadImagemComUserIdERetornarId,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
