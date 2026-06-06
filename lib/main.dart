import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/safehouse.dart';
import 'services/safehouse_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // Use the project base URL (no /rest/v1) and a trimmed anon key
    url: 'https://dzqyhhlzuiyurbjaaaeg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cXloaGx6dWl5dXJiamFhYWVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNzg4NjgsImV4cCI6MjA5NTY1NDg2OH0.uZGiq1JV4le2iKubzlemzgRZpuF8xJh1_zmvd45pIek',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Aegis Vault,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> checkDistance() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    // Pedir permisos
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // Obtener ubicación actual
    Position position = await Geolocator.getCurrentPosition();

    // Coordenadas Neon-Vault
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      4.7068,
      -74.2210,
    );

    debugPrint("Distancia: $distance");

    // Vibrar si está cerca

    if (distance < 100) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
      }
    }
  }

  final service = SafehouseService();

  List<Safehouse> safehouses = [];
  bool isOffline = false;

  @override
  void initState() {
    super.initState();

    loadData();

    checkDistance();
  }

  Future<void> loadData() async {
    final result = await service.getSafehouses();

    if (!mounted) {
      return;
    }

    setState(() {
      safehouses = result.data.map((e) => Safehouse.fromJson(e)).toList();
      isOffline = result.isOffline;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerText = isOffline
        ? 'Modo Desconectado - Datos Locales Protegidos'
        : safehouses.isEmpty
        ? 'Cargando refugios...'
        : 'Modo conectado';

    final bannerColor = isOffline ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text("Aegis Vault")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: bannerColor,
            padding: const EdgeInsets.all(10),
            child: Text(
              bannerText,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: safehouses.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                final house = safehouses[index];
                final cardColor = house.isCompromised
                    ? Theme.of(context).colorScheme.errorContainer
                    : (house.isSelected
                          ? (isOffline ? Colors.red : Colors.green)
                          : null);

                return Semantics(
                  label:
                      "Refugio ${house.codename}, ubicado en el sector ${house.sector}, capacidad para ${house.capacity} agentes. Estado ${house.isCompromised ? 'comprometido' : 'seguro'}",
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        for (var i = 0; i < safehouses.length; i++) {
                          safehouses[i] = safehouses[i].copyWith(
                            isSelected: i == index,
                          );
                        }
                      });
                    },
                    child: Card(
                      color: cardColor,
                      elevation: house.isSelected ? 12 : 4,
                      shadowColor: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              house.codename,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(house.sector),
                            Text("Capacidad: ${house.capacity}"),
                            Text(
                              house.isCompromised
                                  ? '⚠ COMPROMETIDO'
                                  : '✓ SEGURO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: house.isCompromised
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
