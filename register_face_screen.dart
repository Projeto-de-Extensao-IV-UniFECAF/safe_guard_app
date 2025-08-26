import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterFaceScreen extends StatefulWidget {
  @override
  _RegisterFaceScreenState createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final imagePath = prefs.getString('user_image');

    if (name != null) _nameController.text = name;
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage =
          await File(pickedFile.path).copy('${directory.path}/face_image.png');

      setState(() {
        _image = savedImage;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha seu nome e tire uma foto.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_image', _image!.path);

    Navigator.pushNamed(context, '/responsible');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Rosto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Seu nome'),
            ),
            const SizedBox(height: 20),
            _image == null
    ? Container(
        height: 200,
        color: Colors.grey[300],
        child: Icon(Icons.person, size: 100, color: Colors.grey),
      )
    : Image.file(
        _image!,
        height: 200,
        key: ValueKey(DateTime.now().millisecondsSinceEpoch), // <-- força rebuild
      ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tirar Foto'),
              onPressed: _takePicture,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndContinue,
              child: Text('Salvar e Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
