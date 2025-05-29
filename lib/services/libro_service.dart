import 'package:flutter_application_2/models/libros_response.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibroService {
  static LibroService? _instance;

  LibroService._();

  static LibroService getInstance() {
    _instance ??= LibroService._();
    return _instance!;
  }

  /// Metodo para buscar libros.
  ///
  /// [strategy] es la estrategia de busqueda de libros.
  ///
  /// [strategy] puede ser FetchAllBooks() o FetchUserBooks().
  ///
  Future<LibrosResponse> fetchBooks(FetchBookStrategy strategy) async {
    try {
      if (AuthService().currentUser == null) {
        return LibrosResponseError('No hay usuario autenticado.');
      }

      switch (strategy) {
        case FetchAllBooks():
          // Aca sabemos que la estrategia es la de buscar todos los libros
          return strategy.fetchAllBooks();

        case FetchUserBooks():
          // Aca sabemos que la estrategia es la de buscar los libros del usuario actual
          return strategy.fetchMyBooks();
      }
    } catch (e) {
      return LibrosResponseError('Error al cargar libros.');
    }
  }
}

/// Implementacion de la estrategia de busqueda de libros

sealed class FetchBookStrategy {
  const FetchBookStrategy();

  Future<LibrosResponse> parseResponse(dynamic response) async {
    if (response.isEmpty) {
      return LibrosResponseEmpty();
    }
    return LibrosResponse.fromJson(response as List<dynamic>);
  }
}

// Estrategia de busqueda de todos los libros. con esta estrategia, se buscan todos los libros
// de todos los usuarios de la base de datos.
class FetchAllBooks extends FetchBookStrategy {
  const FetchAllBooks();

  Future<LibrosResponse> fetchAllBooks() async {
    final response = await Supabase.instance.client
      .from('Books')
      .select('*,usuarios(*)')
      .order('id', ascending: false)
      .limit(1000);
    return parseResponse(response);
  }
}

// Estrategia de busqueda de libros del usuario actual. con esta estrategia, se buscan todos los libros
// del usuario actual de la base de datos.
class FetchUserBooks extends FetchBookStrategy {
  FetchUserBooks();

  Future<LibrosResponse> fetchMyBooks() async {
    final userId = AuthService().currentUser?.id;

    final response = await Supabase.instance.client
      .from('Books')
      .select()
      .eq('usuario_id', userId)
      .order('id', ascending: false)
      .limit(1000);
    return parseResponse(response);
  }
}
