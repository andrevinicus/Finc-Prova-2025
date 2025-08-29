import 'dart:io';
import 'package:flutter/material.dart';

class ExpenseImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? selectedImageName;
  final Future<File?> Function(BuildContext context) showImagePickerModal;
  final Function(File) onImageSelected;

  const ExpenseImagePicker({
    super.key,
    required this.selectedImage,
    required this.selectedImageName,
    required this.showImagePickerModal,
    required this.onImageSelected,
  });

  String truncatedName(String? name) {
    if (name == null) return 'Selecionar Imagem';
    if (name.length <= 25) return name;

    final ext = name.contains('.') ? name.split('.').last : '';
    final baseName = name.substring(0, 22 - (ext.length + 1));
    return '$baseName...${ext.isNotEmpty ? '.$ext' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedFile = await showImagePickerModal(context);
        if (pickedFile != null) {
          onImageSelected(pickedFile);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            const Icon(Icons.image, color: Colors.grey),
            const SizedBox(width: 16),
            if (selectedImage != null)
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (selectedImage != null) const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  truncatedName(selectedImageName),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
