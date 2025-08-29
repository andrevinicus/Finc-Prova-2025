import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseAmountField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseBankField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseCategoryField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseDescriptionField.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseImagePicker.dart';
import 'package:finc/screens/add_expense/expenses/ExpenseSaveButton.dart';
import 'package:finc/screens/add_expense/modals/upload_dir.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';



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
  void dispose() {
    _amountController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;

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

      // 🔥 Salva a imagem no Firestore e retorna o ID do documento
      final docRef = await FirebaseFirestore.instance.collection("imagens").add({
        "userId": userId,
        "url": urlDownload,
        "criado_em": DateTime.now(),
      });
      print("Path da imagem: ${imagem.path}");
      

      return docRef.id;
    } catch (e) {
      print("Erro ao enviar imagem: $e");
      return null;
    }
  }


@override
Widget build(BuildContext context) {
  // Changed to a very light grey for the bottom container
  final Color bottomContainerColor = const Color.fromARGB(115, 206, 206, 206);

  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus(); // unfocuses any text field
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white, // White Scaffold background
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar color
        foregroundColor: Colors.black, // Black icons and text for AppBar
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              "Nova Despesa", // Changed from "Nova Receita"
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top part with value
          ExpenseAmountField(
            amount: _amountController.text,
            onAmountChanged: (value) {
              setState(() {
                _amountController.text = value;
              });
            },
          ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bottomContainerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25), 
                    topRight: Radius.circular(25), 
                  ),
                ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey), // Grey icon
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                  style: const TextStyle(color: Colors.black87), // Darker text
                                ),
                              ),
                            ),
                            TextButton(
                              child: const Text("Alterar", style: TextStyle(color: Colors.blueAccent)), // Blue text
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blueAccent, // Blue accent for selected date
                                          onPrimary: Colors.white,
                                          surface: Colors.white, // White background for DatePicker
                                          onSurface: Colors.black87, // Darker text for DatePicker
                                        ),
                                        dialogBackgroundColor: Colors.white, // White background for DatePicker dialog
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Divider(
                          color: Colors.grey, // Grey divider
                          height: 10,
                          thickness: 0.8, // Slightly thinner divider
                        ),
                      ),
                      ExpenseCategoryField(
                        userId: userId,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Divider(
                          color: Colors.grey, // Grey divider
                          height: 10,
                          thickness: 0.8,
                        ),
                      ),
                      ExpenseDescriptionField(controller: _descricaoController),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: const Divider(
                          color: Colors.grey, // Grey divider
                          height: 10,
                          thickness: 0.8,
                        ),
                      ),
                      ExpenseBankField(
                        userId: userId,
                        selectedBank: _selectedBank,
                        onBankSelected: (bank) {
                          setState(() {
                            _selectedBank = bank;
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: const Divider(
                          color: Colors.grey, // Grey divider
                          height: 6,
                          thickness: 0.8,
                        ),
                      ),
                      ExpenseImagePicker(
                        selectedImage: _selectedImage,
                        selectedImageName: _selectedImageName,
                        showImagePickerModal: showImagePickerModal,
                        onImageSelected: (file) {
                          setState(() {
                            _selectedImage = file;
                            _selectedImageName = file.path.split('/').last;
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: const Divider(
                          color: Colors.grey, // Grey divider
                          height: 6,
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ExpenseSaveButton(
        amountText: _amountController.text,
        selectedBankId: _selectedBank?.id,
        selectedCategory: _selectedCategory,
        selectedDate: _selectedDate,
        description: _descricaoController.text,
        selectedImage: _selectedImage,
        uploadImage: uploadImagemComUserIdERetornarId,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ),
  );
}
}