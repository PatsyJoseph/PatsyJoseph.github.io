import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meals List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Meal>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchMeals();
  }

  Future<List<Meal>> fetchMeals() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));

    if (response.statusCode == 200) {
      final List mealsJson = json.decode(response.body)['meals'];
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals List'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final meals = snapshot.data!;
            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final controller = ExpandedTileController(); 
                return ExpandedTile(
                  controller: controller, 
                  title: Text(meal.name),
                  leading: Image.network(
                    meal.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  content: Text(meal.instructions),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Meal {
  final String name;
  final String imageUrl;
  final String instructions;

  Meal({required this.name, required this.imageUrl, required this.instructions});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['strMeal'] as String,
      imageUrl: json['strMealThumb'] as String,
      instructions: json['strInstructions'] as String,
    );
  }
}
