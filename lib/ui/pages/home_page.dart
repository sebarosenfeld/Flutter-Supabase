/* import 'package:flutter/material.dart';
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
        .from('Books')
        .select('*, usuarios(nombre)')  // trae datos del dueño
        .order('id', ascending: false)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return response.data as List<dynamic>;
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
            return Center(child: Text('Error al cargar libros: ${snapshot.error}'));
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
                  leading: libro['Image_url'] != null
                      ? Image.network(libro['Image_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(libro['Title']),
                  subtitle: Text('Autor: ${libro['Author']}\nDueño: ${libro['usuarios']['nombre']}'),
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

extension on PostgrestResponse {
  get error => null;
}
 */