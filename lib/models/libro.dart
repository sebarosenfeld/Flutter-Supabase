import 'usuario.dart';

class Libro {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String usuarioId;
  final String? imageUrl;
  final Usuario? usuario;

  Libro({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.usuarioId,
    this.imageUrl,
    this.usuario,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as String,
      title: json['Title'] as String,
      author: json['Author'] as String,
      description: json['Description'] as String,
      category: json['Category'] as String,
      usuarioId: json['usuario_id'] as String,
      imageUrl: json['Image_url'] as String?,
      usuario: json['usuarios'] != null 
          ? Usuario.fromJson(json['usuarios'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Title': title,
      'Author': author,
      'Description': description,
      'Category': category,
      'usuario_id': usuarioId,
      'Image_url': imageUrl,
      'usuarios': usuario?.toJson(),
    };
  }
}
