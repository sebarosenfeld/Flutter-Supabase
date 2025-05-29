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
  late Future<List<Map<String, dynamic>>> _librosFuture;

  @override
  void initState() {
    super.initState();
    _librosFuture = cargarLibros();
  }

  Future<List<Map<String, dynamic>>> cargarLibros() async {
  // 1. Obtener el usuario actualmente autenticado
  final User? currentUser = Supabase.instance.client.auth.currentUser;

  if (currentUser == null) {
    // Manejar el caso en que no haya usuario autenticado (ej. lanzar una excepción, devolver una lista vacía, etc.)
    print('No hay usuario autenticado.');
    return []; // O lanza una excepción, dependiendo de tu lógica de negocio
  }

  final response = await Supabase.instance.client
      .from('Books')
      .select('*,usuarios(*)')
      .eq('usuario_id', currentUser.id) // <--- ¡Aquí está la corrección!
      .order('id', ascending: false)
      .limit(1000); // Es una buena práctica limitar el número de resultados

  // Supabase regresa un objeto PostgrestResponse que tiene la propiedad 'data'
  if (response.error != null) {
    print('Error al cargar libros: ${response.error!.message}');
    throw response.error!; // Lanza el error para que sea manejado externamente
  }

  // Asegúrate de que el tipo de retorno coincida con la data
  // response.data es típicamente List<Map<String, dynamic>>
  return response.data as List<Map<String, dynamic>>;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BookSwap')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
              final Map<String, dynamic> libro = libros[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: libro['Image_url'] != null
                      ? Image.network(libro['Image_url'], width: 50, height: 70, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(libro['Title']),
                  subtitle: Text('Autor: ${libro['Author']}\nSubido por: ${libro['usuarios']?['nombre'] ?? 'Desconocido'}'),
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
