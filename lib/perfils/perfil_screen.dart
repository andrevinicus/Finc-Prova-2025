import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _nomeFocus = FocusNode();
  final _telefoneFocus = FocusNode();

  String? photoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  bool _isNomeEditable = false;
  bool _isTelefoneEditable = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _nomeFocus.dispose();
    _telefoneFocus.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nomeController.text = data['name'] ?? user.displayName ?? '';
      _emailController.text = data['email'] ?? user.email ?? '';
      _telefoneController.text = data['telefone'] ?? '';
      photoUrl = data['photoUrl'] ?? user.photoURL;
    } else {
      _nomeController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      photoUrl = user.photoURL;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _salvarAlteracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': _nomeController.text,
      'telefone': _telefoneController.text,
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));

    setState(() {
      _isSaving = false;
      _isNomeEditable = false;
      _isTelefoneEditable = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informações atualizadas com sucesso')),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _editarCampo(FocusNode focusNode, Function setEditable) {
    setState(() => setEditable());
    // Abre o teclado após reconstrução do widget
    Future.delayed(const Duration(milliseconds: 50), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false, // evita que teclado empurre os botões
      body: SafeArea(
        child: Column(
          children: [
            // Conteúdo rolável
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl!)
                            : const AssetImage('assets/icon/iconedoapp.png')
                                as ImageProvider,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _nomeController.text,
                        style: const TextStyle(
                            fontSize: 25,
                            color: Color.fromARGB(255, 44, 43, 43)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 50),

                    _buildTextField(
                      controller: _nomeController,
                      label: 'Nome',
                      icon: Icons.person,
                      readOnly: !_isNomeEditable,
                      focusNode: _nomeFocus,
                      onEditPressed: () =>
                          _editarCampo(_nomeFocus, () => _isNomeEditable = true),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _telefoneController,
                      label: 'Telefone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      readOnly: !_isTelefoneEditable,
                      focusNode: _telefoneFocus,
                      onEditPressed: () => _editarCampo(
                          _telefoneFocus, () => _isTelefoneEditable = true),
                    ),
                  ],
                ),
              ),
            ),

            // Botões fixos sempre visíveis
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _salvarAlteracoes,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Salvar Alterações'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onEditPressed,
    FocusNode? focusNode,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AbsorbPointer(
          absorbing: readOnly,
          child: TextField(
            controller: controller,
            readOnly: false,
            keyboardType: keyboardType,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[200] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        if (onEditPressed != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEditPressed,
          ),
      ],
    );
  }
}
