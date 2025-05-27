import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/add_income/blocs/create_expense_bloc/create_income_bloc.dart';
import 'package:finc/screens/add_income/views/teclado_numerico.dart';
import 'package:finc/screens/add_income/views/upload_dir.dart';
import 'package:finc/screens/category/modal%20category/option_category.dart';
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
    const Color topContainerColor = Colors.black; // Cor do container superior (valor)
    const Color bottomContainerColor = Color.fromARGB(255, 37, 37, 37); // Cor do container inferior (formulário)

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // tira o foco de qualquer campo de texto
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black, // Fundo do Scaffold preto
          appBar: AppBar(
            backgroundColor: Colors.black, // Cor do AppBar preta
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 26),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  "Nova Despesa",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
          children: [
            // Parte superior com valor
            GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: bottomContainerColor, // Fundo do teclado numérico
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
                color: topContainerColor, // Cor da parte superior
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Valor da despesa",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Parte inferior com formulário
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: bottomContainerColor, // Cor da parte inferior
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
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
                              const Icon(Icons.calendar_today, color: Colors.white54),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20), // ajuste conforme desejar
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                              TextButton(
                              child: const Text("Alterar", style: TextStyle(color: Colors.white54)),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: Colors.teal,
                                          onPrimary: Colors.white,
                                          surface: bottomContainerColor, // Fundo do DatePicker
                                          onSurface: Colors.white70,
                                        ),
                                        dialogBackgroundColor: bottomContainerColor, // Fundo do DatePicker
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
                          margin: const EdgeInsets.symmetric(horizontal: 10,),
                          child: const Divider(
                            color: Colors.white24,
                            height: 10,
                            thickness: 1.5,
                            ),
                        ),
                        Padding(
                        padding: const EdgeInsets.only(top: 1, right: 1),
                        child: ListTile(
                          leading: const Icon(Icons.flag, color: Colors.white54, size: 24),
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
                                          style: const TextStyle(color: Colors.white70),
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
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                          onTap: () async {
                            final resultado = await showModalBottomSheet<Category>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: bottomContainerColor, // Fundo do ModalBottomSheet da Categoria
                              builder: (BuildContext context) {
                                return CategoryOptionsModal(userId: userId);
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
                              color: Colors.white24,
                              height: 10,
                              thickness: 1.5,
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, right: 9),
                            child: TextFormField(
                              controller: _descricaoController,
                              style: const TextStyle(color: Colors.white),
                              textCapitalization: TextCapitalization.words, // para capitalizar a primeira letra de cada palavra
                              cursorColor: Colors.white, // cursor branco
                              selectionControls: MaterialTextSelectionControls(), // mantém comportamento padrão de seleção
                              selectionHeightStyle: BoxHeightStyle.tight,
                              selectionWidthStyle: BoxWidthStyle.tight,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                                labelStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 15, right: 23),
                                  child: Icon(Icons.description, color: Colors.white54),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // padding mais equilibrado
                                border: InputBorder.none,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: const Divider(
                              color: Colors.white24,
                              height: 10,
                              thickness: 1.5,
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              leading: const Icon(Icons.account_balance, color: Colors.white54, size: 22),
                              title: _selectedBank != null
                                  ? Row(
                                        children: [
                                          Image.network(
                                            _selectedBank!.logo!,
                                            width: 25,
                                            height: 25,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _selectedBank!.bankName,
                                              style: const TextStyle(color: Colors.white70),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                  : Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Selecione um banco',
                                              style: TextStyle(color: Colors.white70),
                                            ),
                                        ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: 12), // Aumente esse valor se quiser mais à direita
                                child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                              ),
                              onTap: () async {
                                  final resultado = await showModalBottomSheet<BankAccountEntity>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: bottomContainerColor, // Fundo do ModalBottomSheet do Banco
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
                              color: Colors.white24,
                              height: 6,
                              thickness: 1.5,
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
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.image, color: Colors.white54),
                                    SizedBox(width: 16),

                                    if (_selectedImage != null) 
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white54),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (_selectedImage != null) SizedBox(width: 16),

                                    Expanded(
                                      child: Text(
                                        truncatedName(_selectedImageName),
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Icon(Icons.cloud_upload_outlined, color: Colors.white54),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: const Divider(
                              color: Colors.white24,
                              height: 6,
                              thickness: 1.5,
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
                            category: _selectedCategory!,
                            amount: double.parse(_amountController.text),
                            description: _descricaoController.text,
                            date: _selectedDate,
                            userId: userId,
                            type: 'income',
                            bankId: _selectedBank?.id,
                            imageId: imageId,
                          );

                          // Aqui dispara o evento de submissão, que já emite loading dentro do BLoC
                          context.read<CreateIncomeBloc>().add(CreateIncomeSubmitted(income));
                        }
                      },



                backgroundColor: Colors.blueAccent,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.check, size: 30), // ícone do "V"
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      );
    }
  }