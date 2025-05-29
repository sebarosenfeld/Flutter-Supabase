import 'libro.dart';

sealed class LibrosResponse {
  final List<Libro> libros;

  LibrosResponse({required this.libros});

  factory LibrosResponse.fromJson(List<dynamic> json) {
    return LibrosResponseSuccess(
      json.map((item) => Libro.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return libros.map((libro) => libro.toJson()).toList();
  }
}

class LibrosResponseEmpty extends LibrosResponse {
  LibrosResponseEmpty() : super(libros: []);
}

class LibrosResponseError extends LibrosResponse {
  final String message;

  LibrosResponseError(this.message) : super(libros: []);
}

class LibrosResponseSuccess extends LibrosResponse {
  final List<Libro> libros;

  LibrosResponseSuccess(this.libros) : super(libros: libros);
}