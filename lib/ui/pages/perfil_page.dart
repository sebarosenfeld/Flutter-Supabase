import 'package:flutter/material.dart';
import 'package:flutter_application_2/ui/pages/detalles_libro_page.dart';
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
    if (userId == null) return [];

    final data = await supabase
        .from('Books')
        .select()
        .eq('usuario_id', userId)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email del usuario
            Text('Email: $_email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // Campo para editar nombre
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),

            // Botón para guardar el nombre
            ElevatedButton.icon(
              onPressed: _guardarNombre,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nombre'),
            ),

            const Divider(height: 40),

            // Título de sección "Mis libros"
            const Text('Mis libros', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            // Botón para agregar un nuevo libro
            ElevatedButton.icon(
              onPressed: () async {
                final user = Supabase.instance.client.auth.currentUser;

                final response =
                    await Supabase.instance.client
                        .from('usuarios')
                        .select('nombre')
                        .eq('id', user?.id)
                        .single();

                if (response == null ||
                    response['nombre'] == null ||
                    response['nombre'].toString().trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Debés completar tu perfil antes de subir un libro.',
                      ),
                    ),
                  );
                  return;
                }

                final resultado = await Navigator.pushNamed(
                  context,
                  '/subirLibro',
                );

                if (resultado == true) {
                  setState(() {}); // Vuelve y refresca la lista
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar un libro'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: const Color(0xFF4A90E2),
              ),
            ),

            const SizedBox(height: 10),

            // Lista de libros
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _traerMisLibros(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading:
                              libro['Image_url'] != null
                                  ? Image.network(
                                    libro['Image_url'],
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  )
                                  : const Icon(Icons.book),
                          title: Text(libro['Title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(libro['Author']),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final resultado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                DetallesLibroPage(libro: libro),
                                      ),
                                    );

                                    if (resultado == true) {
                                      setState(
                                        () {},
                                      ); // Refresca la lista de libros
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Ver más'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Botón para cerrar sesión
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
