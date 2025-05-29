import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registrarse = false;
  bool _cargando = false;

  Future<void> _autenticar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final auth = Supabase.instance.client.auth;

      if (_registrarse) {
        final response = await auth.signUp(email: email, password: password);
        if (response.user == null) {
          throw AuthException('Fallo al registrarse');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisá tu email para confirmar tu cuenta.')),
        );
      } else {
        final response = await auth.signInWithPassword(email: email, password: password);

        if (response.user?.emailConfirmedAt == null) {
          throw AuthException('Email no confirmado. Revisá tu bandeja de entrada.');
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      print('Error inesperado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado.')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_registrarse ? 'Registrarse' : 'Iniciar sesión'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || !value.contains('@') ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _autenticar,
                      icon: Icon(_registrarse ? Icons.person_add : Icons.login),
                      label: Text(_registrarse ? 'Crear cuenta' : 'Ingresar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _registrarse = !_registrarse);
                      },
                      child: Text(_registrarse
                          ? '¿Ya tenés cuenta? Iniciar sesión'
                          : '¿No tenés cuenta? Registrate'),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
