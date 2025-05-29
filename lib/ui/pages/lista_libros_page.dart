import 'package:flutter/material.dart';
import 'subir_libro_page.dart';
import 'detalles_libro_page.dart';
import '../../models/libro.dart';
import '../../models/libros_response.dart';
import '../../services/libro_service.dart';

class ListaLibrosPage extends StatefulWidget {
  const ListaLibrosPage({super.key});

  @override
  State<ListaLibrosPage> createState() => _ListaLibrosPageState();
}

class _ListaLibrosPageState extends State<ListaLibrosPage> {
  late Future<LibrosResponse> _librosFuture;

  @override
  void initState() {
    super.initState();
    _librosFuture = LibroService.getInstance().fetchBooks(FetchAllBooks());
  }

Widget _buildSuccessList(LibrosResponseSuccess response) {
  final libros = response.libros;
  return ListView.builder(
      itemCount: libros.length,
      itemBuilder: (context, index) {
        final Libro libro = libros[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: libro.imageUrl != null
                ? Image.network(libro.imageUrl!, width: 50, height: 70, fit: BoxFit.cover)
                : const Icon(Icons.book),
            title: Text(libro.title),
            subtitle: Text('Autor: ${libro.author}\nSubido por: ${libro.usuario?.nombre ?? 'Desconocido'}'),
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
}

Widget _buildErrorList(LibrosResponseError response) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          response.message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildEmptyList(LibrosResponseEmpty response) {
  return const Center(child: Text('No hay libros disponibles.'));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BookSwap')),
      body: FutureBuilder<LibrosResponse>(
        future: _librosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorList(snapshot.error as LibrosResponseError);
          }

          final data = snapshot.data;

          if (data == null) {  
            return _buildErrorList(LibrosResponseError('Error desconocido'));
          }

          switch (data) {
            case LibrosResponseSuccess():
              return _buildSuccessList(data);
            case LibrosResponseEmpty():
              return _buildEmptyList(data);
            case LibrosResponseError():
              return _buildErrorList(data);            
          }
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
