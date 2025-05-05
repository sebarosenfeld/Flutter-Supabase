import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _nombreController = TextEditingController();
  final supabase = Supabase.instance.client;
  String? _email;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _email = user.email;
    });

    final response =
        await supabase
            .from('usuarios')
            .select('nombre')
            .eq('id', user.id)
            .maybeSingle();

    if (response != null && response['nombre'] != null) {
      _nombreController.text = response['nombre'];
    }
  }

  Future<void> _guardarNombre() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('usuarios').upsert({
      'id': userId,
      'nombre': _nombreController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nombre actualizado.')));
  }

  Future<void> _logout() async {
    print('Cerrando sesión...');
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<List<Map<String, dynamic>>> _traerMisLibros() async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('libros')
        .select()
        .eq('usuario_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $_email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _guardarNombre,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nombre'),
            ),
            const Divider(height: 40),
            const Text('Mis libros', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            // Aquí agregamos el botón debajo de "Mis libros"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/subirLibro');
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar un libro'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  double.infinity,
                  40,
                ), // Hace que el botón ocupe el ancho completo
                backgroundColor: const Color(0xFF4A90E2), // Color de fondo
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _traerMisLibros(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar libros.'));
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No subiste ningún libro.'),
                    );
                  }

                  final libros = snapshot.data!;
                  return ListView.builder(
                    itemCount: libros.length,
                    itemBuilder: (context, index) {
                      final libro = libros[index];
                      return ListTile(
                        leading:
                            libro['imagen_url'] != null
                                ? Image.network(
                                  libro['imagen_url'],
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                )
                                : const Icon(Icons.book),
                        title: Text(libro['titulo']),
                        subtitle: Text(libro['autor']),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
