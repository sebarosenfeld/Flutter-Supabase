import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetallesLibroPage extends StatelessWidget {
  final Map<String, dynamic> libro;

  const DetallesLibroPage({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final bool esPropio = libro['usuario_id'] == userId;

    return Scaffold(
      appBar: AppBar(title: Text(libro['titulo'])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      libro['imagen_url'],
                      fit: BoxFit.cover,
                      height: 200,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('No se pudo cargar la imagen')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(libro['titulo'],
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Autor: ${libro['autor']}',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text(libro['descripcion']),
                        const SizedBox(height: 8),
                        Text('Categoría: ${libro['categoria']}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            esPropio
                ? ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Eliminar libro?'),
                          content:
                              const Text('¿Estás seguro de que querés eliminar este libro?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await Supabase.instance.client
                              .from('libros')
                              .delete()
                              .eq('id', libro['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Libro eliminado')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar libro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Función de contacto simulada.')),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Contactar al dueño'),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
