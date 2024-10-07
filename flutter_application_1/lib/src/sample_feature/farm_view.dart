import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/src/repositories/farm_repo.dart';
import 'package:flutter_application_1/src/sample_feature/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif/gif.dart';

class FarmScreen extends StatefulWidget {
  static const routeName = '/farm';

  const FarmScreen({super.key});

  @override
  _FarmScreenState createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> with TickerProviderStateMixin {
  final List<Animal> animals = [];
  late Ticker _ticker;

  final double farmSize = 400;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((Duration elapsed) {
      setState(() {
        for (var animal in animals) {
          animal.move(Size(farmSize, farmSize));
        }
      });
    });

    _ticker.start();
  }

  @override
  void dispose() {
    for (var animal in animals) {
      animal.gifController.dispose();
    }
    _ticker.dispose();
    super.dispose();
  }

  void _initializeAnimals(FarmState state) {
    int numberOfAnimals = int.parse(state.animalCount) ?? 0;

    for (int i = 0; i < numberOfAnimals; i++) {
      AnimalType type = _getRandomAnimalType();

      Animal animal = Animal(
        position: Offset(
            Random().nextDouble() * (farmSize - 110),
            Random().nextDouble() * (farmSize - 110)),
        velocity: Offset((Random().nextDouble() * 2 - 1) * 1.5,
            (Random().nextDouble() * 2 - 1) * 1.5),
        size:   100,
        animalType: type,
        gifController: GifController(vsync: this),
      );

      animal.gifController.repeat(period: const Duration(seconds: 2));

      animals.add(animal);
    }
  }

  void _updateAnimals(FarmState state) {
    for (var animal in animals) {
      animal.gifController.dispose();
    }
    animals.clear();

    _initializeAnimals(state);
  }

  AnimalType _getRandomAnimalType() {
    return AnimalType.values[Random().nextInt(AnimalType.values.length)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FarmCubit(ApiRepositoryImpl())..loadFarmData(),
      child: Scaffold(
        body: BlocConsumer<FarmCubit, FarmState>(
          listener: (context, state) {
            if (
                int.parse(state.animalCount) != animals.length) {
              _updateAnimals(state);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (animals.isEmpty) {
              _initializeAnimals(state);
            }

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                     Text("Satisfaction level : ${state.satisfaction}"),
                    Container(
                      width: farmSize,
                      height: farmSize,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        border: Border.all(color: Colors.brown, width: 5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: animals
                            .map((animal) => _buildAnimal(animal))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
    
                    Text(
                        'Last fed: ${state.lastFed.isNotEmpty ? state.lastFed : "Loading..."}'),
                    const SizedBox(height: 10),
                    Text(
                        'Last watered: ${state.lastWatered.isNotEmpty ? state.lastWatered : "Loading..."}'),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: state.isUpdating
                          ? null
                          : () {
                              context.read<FarmCubit>().feedOrWater('feed');
                            },
                      child: state.isUpdating
                          ? const CircularProgressIndicator() 
                          : const Text('Feed Animal'),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: state.isUpdating
                          ? null
                          : () {
                              context.read<FarmCubit>().feedOrWater('water');
                            },
                      child: state.isUpdating
                          ? const CircularProgressIndicator() 
                          : const Text('Water Animal'),
                    ),
                    const SizedBox(height: 20),

           
                    if (state.message != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(state.message!),
                      ),
                    if (state.error != null &&
                        state.error!
                            .isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Error: ${state.error}',
                            style: const TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 20),
                    const FeedingWidget(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimal(Animal animal) {

    double size = animal.animalType == AnimalType.cat ? 50 : 100;
    return Positioned(
      left: animal.position.dx,
      top: animal.position.dy,
      child: Gif(
        height: size,
        width: size,
        image: AssetImage(animal.getGifAsset()),
        controller: animal.gifController,
        autostart: Autostart.no, 
        onFetchCompleted: () {
          animal.gifController.repeat(period: const Duration(seconds: 2));
        },
        placeholder: (context) => Container(
          height: 100,
          width: 100,
          color: Colors.grey,
        ),
      ),
    );
  }
}

enum AnimalType {horse, cat, dog }

class Animal {
  Offset position;
  Offset velocity;
  double size;
  AnimalType animalType;
  GifController gifController;

  Animal({
    required this.position,
    required this.velocity,
    required this.size,
    required this.animalType,
    required this.gifController,
  });

  void move(Size boundary) {
    position += velocity;

    // Left boundary
    if (position.dx < 0) {
      position = Offset(0, position.dy);
      velocity = Offset(-velocity.dx, velocity.dy);
    }

    // Right boundary considering the size of the animal
    if (position.dx + 10 > boundary.width - size) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }

    // Top boundary
    if (position.dy < 0) {
      position = Offset(position.dx, 0);
      velocity = Offset(velocity.dx, -velocity.dy);
    }

    // Bottom boundary considering the size of the animal
    if (position.dy + 10 > boundary.height - size) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }

  String getGifAsset() {
    switch (animalType) {
      case AnimalType.dog:
        return 'assets/images/dog.gif';
      case AnimalType.cat:
        return 'assets/images/cat.gif';
      case AnimalType.horse:
        return 'assets/images/horse.gif';
    
    }
  }
}

class FeedingWidget extends StatefulWidget {
  const FeedingWidget({super.key});

  @override
  _FeedingWidgetState createState() => _FeedingWidgetState();
}

class _FeedingWidgetState extends State<FeedingWidget> {
  bool foodInBowl = false;
  bool waterInBowl = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Bowl(
                  isFull: foodInBowl,
                  label: 'Food',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                );
              },
              onAccept: (data) {
                if (data == 'food') {
                  setState(() {
                    foodInBowl = true;
                  });
                }
              },
            ),
            SizedBox(
              width: 50,
            ),
            DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Bowl(
                  isFull: waterInBowl,
                  label: 'Water',
                  icon: Icons.local_drink,
                  color: Colors.blue,
                );
              },
              onAccept: (data) {
                if (data == 'water') {
                  setState(() {
                    waterInBowl = true;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 50),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Draggable<String>(
              data: 'food',
              feedback: Material(
                elevation: 5.0,
                child: Icon(Icons.local_pizza, size: 50, color: Colors.orange),
              ),
              child: Icon(Icons.local_pizza, size: 50, color: Colors.orange),
            ),
            Draggable<String>(
              data: 'water',
              feedback: Material(
                elevation: 5.0,
                child: Icon(Icons.local_drink, size: 50, color: Colors.blue),
              ),
              child: Icon(Icons.local_drink, size: 50, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}

class Bowl extends StatelessWidget {
  final bool isFull;
  final String label;
  final IconData icon;
  final Color color;

  Bowl(
      {super.key,
      required this.isFull,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFull
                  ? [color.withOpacity(0.6), color]
                  : [Colors.grey[300]!, Colors.grey[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: 60, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
