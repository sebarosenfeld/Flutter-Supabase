import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  // Función de validación para el email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  // Función de validación para la contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      // Registrar el usuario
      final result = await _auth.signUp(email: email, password: password);

      final user = result.user;

      if (user != null) {
        // Insertar en la tabla 'usuarios' usando el mismo ID
        await Supabase.instance.client.from('usuarios').insert({
          'id': user.id,
          'nombre': 'Nuevo usuario', // O podés pedir el nombre en otro campo
        });

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error al registrarse: $e');
      setState(() {
        _error = 'Error al registrarse: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrarse")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController, // Usar el controller
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail, // Validación personalizada
              ),
              TextFormField(
                controller: _passwordController, // Usar el controller
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: validatePassword, // Validación personalizada
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text("Crear Cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
