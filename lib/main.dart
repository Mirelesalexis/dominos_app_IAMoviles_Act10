import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC2ntwwZnqoFj9yLlJFZlhHWPfnT-HRSJA",
          authDomain: "dominos-app-166b1.firebaseapp.com",
          projectId: "dominos-app-166b1",
          storageBucket: "dominos-app-166b1.firebasestorage.app",
          messagingSenderId: "807409508830",
          appId: "1:807409508830:web:ae9c2aac33662f5de67d4f",
        ),
      );
    }
  } catch (e) {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Domino's Admin Pro",
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}

// --- LOGIN Y REGISTRO ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  bool _esLogin = true;

  Future<void> _autenticar() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    try {
      if (_esLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      } else {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
          'email': email,
          'telefono': _phoneController.text.trim(),
          'edad': _ageController.text.trim(),
          'fecha_registro': Timestamp.now(),
        });
        _msg("Cuenta creada con éxito", Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      _msg("Error: ${e.message}", Colors.red);
    }
  }

  void _msg(String txt, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt), backgroundColor: col));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.local_pizza, size: 80, color: Colors.red),
              const SizedBox(height: 10),
              Text(_esLogin ? "INICIAR SESIÓN - DOMINO'S" : "REGISTRO DE USUARIO", 
                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Correo", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder())),
              if (!_esLogin) ...[
                const SizedBox(height: 15),
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Teléfono", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                TextField(controller: _ageController, decoration: const InputDecoration(labelText: "Edad", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ],
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, minimumSize: const Size.fromHeight(55)),
                onPressed: _autenticar,
                child: Text(_esLogin ? "ENTRAR" : "CREAR CUENTA"),
              ),
              TextButton(
                onPressed: () => setState(() => _esLogin = !_esLogin),
                child: Text(_esLogin ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL (SIN CONTADOR) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Domino's"),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: "Cerrar Sesión",
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text("Bienvenido al Administrador", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("${FirebaseAuth.instance.currentUser?.email}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            _btnMenu(context, "GESTIÓN DE PRODUCTOS", Colors.blue[800]!, Icons.restaurant_menu, "productos"),
            const SizedBox(height: 20),
            _btnMenu(context, "GESTIÓN DE EMPLEADOS", Colors.orange[800]!, Icons.groups, "empleados"),
          ],
        ),
      ),
    );
  }

  Widget _btnMenu(BuildContext context, String txt, Color col, IconData ico, String colName) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: col,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 60),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PantallaCRUD(coleccion: colName))),
      icon: Icon(ico, size: 28),
      label: Text(txt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// --- PANTALLA CRUD ---
class PantallaCRUD extends StatelessWidget {
  final String coleccion;
  const PantallaCRUD({super.key, required this.coleccion});

  void _abrirFormulario(BuildContext context, {DocumentSnapshot? doc}) {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final c3 = TextEditingController();

    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      c1.text = data['nombre'] ?? '';
      c2.text = data['campo2'] ?? '';
      c3.text = data['campo3'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Nuevo Registro" : "Editar Registro"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c1, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: c2, decoration: InputDecoration(labelText: coleccion == 'productos' ? "Precio" : "Puesto")),
              TextField(controller: c3, decoration: InputDecoration(labelText: coleccion == 'productos' ? "Categoría" : "Teléfono")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final datos = {
                'nombre': c1.text.trim(),
                'campo2': c2.text.trim(),
                'campo3': c3.text.trim(),
                'actualizado': Timestamp.now(),
              };
              if (doc == null) {
                await FirebaseFirestore.instance.collection(coleccion).add({...datos, 'creado': Timestamp.now()});
              } else {
                await doc.reference.update(datos);
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Administrar $coleccion")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(coleccion).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: coleccion == 'productos' ? Colors.blue : Colors.orange,
                    child: Icon(coleccion == 'productos' ? Icons.local_pizza : Icons.person, color: Colors.white),
                  ),
                  title: Text(data['nombre'] ?? "Sin nombre", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['campo2']} | ${data['campo3']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _abrirFormulario(context, doc: doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        label: const Text("Añadir"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}