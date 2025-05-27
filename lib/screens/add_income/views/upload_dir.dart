import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<File?> showImagePickerModal(BuildContext context) async {
  final picker = ImagePicker();

  Future<File?> _pick(ImageSource source) async {
    if (Platform.isAndroid) {
      final permission = source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();

      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permissão negada'),
            backgroundColor: Colors.red.shade700, // SnackBar vermelho escuro
          ),
        );
        return null;
      }
    }

    final XFile? pickedFile = await picker.pickImage(source: source);
    // Não feche o modal aqui porque fechamos depois do retorno do _pick
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  return showDialog<File?>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[900], // Fundo escuro para o modal
      title: const Text(
        'Selecionar Imagem',
        style: TextStyle(color: Colors.white), // Título branco
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white70),
            title: const Text(
              'Tirar Foto',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final file = await _pick(ImageSource.camera);
              Navigator.of(context).pop(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white70),
            title: const Text(
              'Escolher da Galeria',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final file = await _pick(ImageSource.gallery);
              Navigator.of(context).pop(file);
            },
          ),
        ],
      ),
    ),
  );
}
