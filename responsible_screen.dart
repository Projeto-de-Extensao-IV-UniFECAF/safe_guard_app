import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ResponsibleScreen extends StatefulWidget {
  const ResponsibleScreen({Key? key}) : super(key: key);

  @override
  _ResponsibleScreenState createState() => _ResponsibleScreenState();
}

class _ResponsibleScreenState extends State<ResponsibleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      await _storage.write(key: 'responsible_name', value: _nameController.text);
      await _storage.write(key: 'responsible_phone', value: _phoneController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos com sucesso!')),
      );

      Navigator.pushNamed(context, '/monitoring'); // Próxima tela
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsável')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do responsável'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                validator: (value) {
                  final raw = _phoneMask.getUnmaskedText();
                  if (raw.length != 11) {
                    return 'Informe um telefone válido com DDD';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Salvar e continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
