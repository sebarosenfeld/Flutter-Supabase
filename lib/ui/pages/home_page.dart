import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'subir_libro_page.dart';
import 'detalles_libro_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<dynamic>> obtenerLibros() async {
    final response = await Supabase.instance.client
        .from('libros')
        .select('id, titulo, autor, imagen_url, usuario_id, usuarios:usuario_id(email)')
        .order('created_at', ascending: false);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookSwap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: obtenerLibros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar libros.'));
          }

          final libros = snapshot.data;

          if (libros == null || libros.isEmpty) {
            return const Center(child: Text('No hay libros disponibles.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: libros.length,
            itemBuilder: (context, index) {
              final libro = libros[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: libro['imagen_url'] != null
                      ? Image.network(libro['imagen_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(libro['titulo']),
                  subtitle: Text('Autor: ${libro['autor']}\nDueño: ${libro['usuarios']['email']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetallesLibroPage(libro: libro),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubirLibroPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
