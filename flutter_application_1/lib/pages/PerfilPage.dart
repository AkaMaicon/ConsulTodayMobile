// lib/pages/perfil_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const _prefsKey = 'profile_image';
  File? _imageFile;        // usado no mobile
  Uint8List? _imageBytes;  // usado no web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final saved = prefs.getString(_prefsKey);
      if (saved != null) {
        setState(() => _imageBytes = Uint8List.fromList(saved.codeUnits));
      }
    } else {
      final savedPath = prefs.getString(_prefsKey);
      if (savedPath != null) {
        final f = File(savedPath);
        final exists = await f.exists();
        if (!mounted) return;
        if (exists) {
          setState(() => _imageFile = f);
        } else {
          await prefs.remove(_prefsKey);
          setState(() => _imageFile = null);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result != null && result.files.single.bytes != null) {
          setState(() => _imageBytes = result.files.single.bytes);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _prefsKey,
            String.fromCharCodes(_imageBytes!),
          );
        }
      } else {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (picked == null) return;

        final File saved = await _saveFilePermanently(picked);

        final prefs = await SharedPreferences.getInstance();
        final oldPath = prefs.getString(_prefsKey);
        if (oldPath != null && oldPath != saved.path) {
          try {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) await oldFile.delete();
          } catch (_) {}
        }

        await prefs.setString(_prefsKey, saved.path);
        if (!mounted) return;
        setState(() => _imageFile = saved);
      }
    } catch (e, st) {
      debugPrint('Erro ao selecionar imagem: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar imagem')),
      );
    }
  }

  Future<File> _saveFilePermanently(XFile xfile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(xfile.path);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedPath = p.join(appDir.path, filename);
    try {
      await xfile.saveTo(savedPath);
      return File(savedPath);
    } catch (_) {
      final tmp = File(xfile.path);
      return await tmp.copy(savedPath);
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      await prefs.remove(_prefsKey);
      setState(() => _imageBytes = null);
    } else {
      final savedPath = prefs.getString(_prefsKey);
      if (savedPath != null) {
        try {
          final f = File(savedPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
        await prefs.remove(_prefsKey);
      }
      if (!mounted) return;
      setState(() => _imageFile = null);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // avatar com botão de alterar
            Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: kIsWeb
                      ? (_imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : const AssetImage('assets/images/placeholder_profile.png') as ImageProvider)
                      : (_imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/images/placeholder_profile.png')),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _pickImage,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botões e placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover foto'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Placeholders de info — use o tema para ícones/cores
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: const Text('Nome do Usuário'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: const Text('email@exemplo.com'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: const Text('(00) 00000-0000'),
            ),
          ],
        ),
      ),
    );
  }
}
