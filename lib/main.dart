import 'package:flutter/material.dart';
import 'package:flutter_application_2/ui/pages/login_page.dart';
import 'package:flutter_application_2/ui/pages/perfil_page.dart';
import 'package:flutter_application_2/ui/pages/register_page.dart';
import 'package:flutter_application_2/ui/pages/subir_libro_page.dart';
import 'package:flutter_application_2/ui/pages/lista_libros_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "../.env");

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? "";
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? "";

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2), // Azul moderno
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Fondo claro
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A90E2)),
          ),
          labelStyle: TextStyle(color: Colors.black87),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/perfil': (context) => const PerfilPage(),
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegisterPage(),
        '/subirLibro' : (context) => const SubirLibroPage(),
        '/listalibros' : (context) => const ListaLibrosPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener sesión actual
    final session = Supabase.instance.client.auth.currentSession;

    // Si no hay sesión, redirige al login
    if (session == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              '¡Bienvenido a BookSwap!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Intercambia libros con otras personas 📚',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Ir al perfil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Ver libros disponibles'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/listalibros');
              },
            ),
          ],
        ),
      ),
    );
  }
}
