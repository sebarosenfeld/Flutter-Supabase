import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubirLibroPage extends StatefulWidget {
  const SubirLibroPage({super.key});

  @override
  State<SubirLibroPage> createState() => _SubirLibroPageState();
}

class _SubirLibroPageState extends State<SubirLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _categoriaSeleccionada;
  Uint8List? _imagenBytes;
  io.File? _imagenFile;
  bool _cargando = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imagenBytes = bytes;

        if (!kIsWeb) {
          _imagenFile = io.File(pickedFile.path);
        }
      });
    }
  }

  Future<void> subirLibro(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá todos los campos y seleccioná una imagen.'),
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    String? imageUrl;

    try {
      final fileName = 'libro_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await Supabase.instance.client.storage
          .from('libros')
          .uploadBinary(
            'imagenes/$fileName',
            _imagenBytes!,
            fileOptions: const FileOptions(upsert: true),
          )
          .timeout(const Duration(seconds: 15));

      imageUrl = Supabase.instance.client.storage
          .from('libros')
          .getPublicUrl('imagenes/$fileName');
    } catch (e) {
      print("Error al subir imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      setState(() => _cargando = false);
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) throw Exception('Usuario no autenticado');

      await Supabase.instance.client.from('Books').insert({
        'Title': _tituloController.text,
        'Author': _autorController.text,
        'Description': _descripcionController.text,
        'Category': _categoriaSeleccionada,
        'Image_url': imageUrl,
        'usuario_id': userId,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Libro subido con éxito.')));
      Navigator.pop(context, true);
    } catch (e) {
      print("Error al guardar libro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el libro.')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir nuevo libro')),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _autorController,
                        decoration: const InputDecoration(labelText: 'Autor'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        maxLines: 3,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                        value: _categoriaSeleccionada,
                        items:
                            ['Ficción', 'Acción', 'Ciencia', 'Romance']
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _categoriaSeleccionada = value);
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Seleccioná una categoría'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _seleccionarImagen,
                        child:
                            _imagenBytes == null
                                ? Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('Seleccionar imagen'),
                                  ),
                                )
                                : Image.memory(
                                  _imagenBytes!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async { await subirLibro(context);},
                        icon: const Icon(Icons.upload),
                        label: const Text('Subir libro'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
