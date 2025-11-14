// lib/pages/perfil_page.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
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
  String? userName;
  String? userEmail;
  static const _prefsKey = 'profile_image';
  File? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadUserInfo();
  }

  Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

  Future<void> _loadUserInfo() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    userName = prefs.getString('user_name') ?? "Nome não disponível";
    userEmail = prefs.getString('user_email') ?? "Email não disponível";
  });
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
        if (await f.exists()) {
          setState(() => _imageFile = f);
        } else {
          await prefs.remove(_prefsKey);
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
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );

        if (picked == null) return;

        final saved = await _saveFilePermanently(picked);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, saved.path);

        setState(() => _imageFile = saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Erro ao selecionar imagem")));
      }
    }
  }

  Future<File> _saveFilePermanently(XFile xfile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(xfile.path);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedPath = p.join(appDir.path, filename);

    await xfile.saveTo(savedPath);
    return File(savedPath);
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      setState(() => _imageBytes = null);
      await prefs.remove(_prefsKey);
    } else {
      final savedPath = prefs.getString(_prefsKey);

      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) await file.delete();
      }

      setState(() => _imageFile = null);
      await prefs.remove(_prefsKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          'Perfil',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Avatar + botão
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: kIsWeb
                      ? (_imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : const AssetImage('assets/images/placeholder_profile.png')
                              as ImageProvider)
                      : (_imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/images/placeholder_profile.png')),
                ),
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6)
                      ],
                    ),
                    child: InkWell(
                      onTap: _pickImage,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.camera_alt,
                          size: 22,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botão remover foto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text("Remover foto", selectionColor: Colors.white,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _removeImage,
              ),
            ),

            const SizedBox(height: 30),

            // Campos de informações pessoais
            _infoCard(
              icon: Icons.person,
              title: userName ?? "Carregando...",
            ),
            const SizedBox(height: 8),

            _infoCard(
              icon: Icons.email,
              title: userEmail ?? "Carregando...",
            ),
            const SizedBox(height: 8),
            SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Sair"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  /// Card reutilizável no padrão visual
  Widget _infoCard({required IconData icon, required String title}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E88E5)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
