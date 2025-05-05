import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'subir_libro_page.dart';
import 'detalles_libro_page.dart';

class ListaLibrosPage extends StatefulWidget {
  const ListaLibrosPage({super.key});

  @override
  State<ListaLibrosPage> createState() => _ListaLibrosPageState();
}

class _ListaLibrosPageState extends State<ListaLibrosPage> {
  late Future<List<dynamic>> _librosFuture;

  @override
  void initState() {
    super.initState();
    _librosFuture = cargarLibros();
  }

  Future<List<dynamic>> cargarLibros() async {
    final response = await Supabase.instance.client
        .from('libros')
        .select('*')
        .order('created_at', ascending: false);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BookSwap')),
      body: FutureBuilder<List<dynamic>>(
        future: _librosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay libros disponibles.'));
          }

          final libros = snapshot.data!;

          return ListView.builder(
            itemCount: libros.length,
            itemBuilder: (context, index) {
              final libro = libros[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: libro['imagen_url'] != null
                      ? Image.network(libro['imagen_url'], width: 50, height: 70, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(libro['titulo']),
                  subtitle: Text(libro['autor']),
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
