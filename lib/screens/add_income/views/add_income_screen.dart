import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/add_expense/modals/teclado_numerico.dart';
import 'package:finc/screens/add_expense/modals/upload_dir.dart';
import 'package:finc/screens/add_income/blocs/create_expense_bloc/create_income_bloc.dart';
import 'package:finc/screens/category/modal%20category/option_category_income.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:finc/screens/create_banks/modal_banks/created_baks_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';



class AddIncomeScreen extends StatefulWidget {
  final String userId;
  const AddIncomeScreen({super.key, required this.userId});
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // Começa no canto inferior esquerdo
    path.lineTo(size.width, size.height); // Vai para o canto inferior direito
    path.lineTo(size.width, 20); // Vai para um ponto acima no canto superior direito (ajuste 20 para a profundidade da curva)

    // Adiciona uma curva suave para o canto superior esquerdo
    path.quadraticBezierTo(size.width / 2, 0, 0, 20); // Ponto de controle no meio, ponto final no canto superior esquerdo

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // Retorna true se a forma mudar
  }
}
class _AddIncomeScreenState extends State<AddIncomeScreen> {
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
    const Color topContainerColor = Colors.white; // White for the top container
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
                "Nova Receita",
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
            GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey[200], // Lighter background for the numeric keyboard modal
                  builder: (context) => FractionallySizedBox(
                    child: TecladoNumerico(
                      valorInicial: _amountController.text.isEmpty
                          ? '0'
                          : _amountController.text.replaceAll('.', ','),
                    ),
                  ),
                );
                if (result != null &&
                    double.tryParse(result.replaceAll(',', '.')) != null) {
                  _amountController.text = result.replaceAll(',', '.');
                  setState(() {});
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                color: topContainerColor, // White top container
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Valor da Receita",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54, // Darker text
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom part with form
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
                        Padding(
                          padding: const EdgeInsets.only(top: 1, right: 1),
                          child: ListTile(
                            leading: const Icon(Icons.flag, color: Colors.grey, size: 24), // Grey icon
                            title: _selectedCategory != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(_selectedCategory!.color),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/${_selectedCategory!.icon}.png',
                                          width: 20,
                                          height: 20,
                                          color: Color(_selectedCategory!.color),
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            _selectedCategory!.name,
                                            style: const TextStyle(color: Colors.black87), // Darker text
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Opções de Categoria',
                                      style: TextStyle(color: Colors.black54), // Darker text
                                    ),
                                  ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey), // Grey icon
                            onTap: () async {
                              final resultado = await showModalBottomSheet<Category>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent, // MUITO IMPORTANTE: Defina para transparente
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)), // **AQUI DEVE ESTAR A BORDA**
                                ),
                                builder: (BuildContext context) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), // Mesma borda que o shape
                                    child: CategoryOptionsModalIncome(userId: userId),
                                  );
                                },
                              );

                              if (resultado != null) {
                                setState(() {
                                  _selectedCategory = resultado;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Divider(
                            color: Colors.grey, // Grey divider
                            height: 10,
                            thickness: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 9),
                          child: TextFormField(
                            controller: _descricaoController,
                            style: const TextStyle(color: Colors.black87), // Darker text
                            textCapitalization: TextCapitalization.words,
                            cursorColor: Colors.blueAccent, // Blue cursor
                            selectionControls: MaterialTextSelectionControls(),
                            selectionHeightStyle: BoxHeightStyle.tight,
                            selectionWidthStyle: BoxWidthStyle.tight,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: TextStyle(color: Colors.black54), // Darker label
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 15, right: 23),
                                child: Icon(Icons.description, color: Colors.grey), // Grey icon
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Campo obrigatório' : null,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: const Divider(
                            color: Colors.grey, // Grey divider
                            height: 10,
                            thickness: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: const Icon(Icons.account_balance, color: Colors.grey, size: 22), // Grey icon
                            title: _selectedBank != null
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey), // Grey border
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              _selectedBank!.logo!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _selectedBank!.bankName,
                                            style: const TextStyle(color: Colors.black87), // Darker text
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Selecione um banco',
                                      style: TextStyle(color: Colors.black54), // Darker text
                                    ),
                                  ),
                            trailing: const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey), // Grey icon
                            ),
                            onTap: () async {
                              final resultado = await showModalBottomSheet<BankAccountEntity>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.grey[200], // Lighter background for bank options modal
                                builder: (BuildContext context) {
                                  final bankRepository = RepositoryProvider.of<BankRepository>(context);

                                  return BlocProvider<GetBankBloc>(
                                    create: (_) => GetBankBloc(bankRepository)..add(GetLoadBanks(userId)),
                                    child: BankOptionsModal(userId: userId),
                                  );
                                },
                              );

                              if (resultado != null) {
                                setState(() {
                                  _selectedBank = resultado;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: const Divider(
                            color: Colors.grey, // Grey divider
                            height: 6,
                            thickness: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 9),
                          child: InkWell(
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
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.image, color: Colors.grey), // Grey icon
                                  const SizedBox(width: 16),
                                  if (_selectedImage != null)
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey), // Grey border
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (_selectedImage != null) const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        truncatedName(_selectedImageName),
                                        style: const TextStyle(
                                          color: Colors.black54, // Darker text
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.cloud_upload_outlined, color: Colors.grey), // Grey icon
                                ],
                              ),
                            ),
                          ),
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
        floatingActionButton: BlocConsumer<CreateIncomeBloc, CreateIncomeState>(
          listener: (context, state) {
            if (state is CreateIncomeSuccess) {
              Navigator.pop(context);
            } else if (state is CreateIncomeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateIncomeLoading;

            return FloatingActionButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_amountController.text.isEmpty ||
                          double.tryParse(_amountController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Informe um valor válido.')),
                        );
                        return;
                      }

                      if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione uma categoria.')),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        final uuid = Uuid();
                        final userId = FirebaseAuth.instance.currentUser!.uid;

                        String? imageId;

                        if (_selectedImage != null) {
                          imageId = await uploadImagemComUserIdERetornarId(_selectedImage!);
                        }

                        final income = Income(
                          id: uuid.v4(),
                          categoryId: _selectedCategory!.categoryId,
                          amount: double.parse(_amountController.text),
                          description: _descricaoController.text,
                          date: _selectedDate,
                          userId: userId,
                          type: 'income',
                          bankId: _selectedBank?.id,
                          imageId: imageId,
                        );

                        context.read<CreateIncomeBloc>().add(CreateIncomeSubmitted(income));
                      }
                    },
              backgroundColor: Colors.blueAccent, // Blue accent for the FAB
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.check, size: 30, color: Colors.white), // White icon
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}