import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

    // Initialize each animal with its own GifController and random positions
    for (int i = 0; i < 10; i++) {
      animals.add(Animal(
        position: Offset(
            Random().nextDouble() * (farmSize - 110), // Ensure random start within bounds
            Random().nextDouble() * (farmSize - 110)),
        velocity: Offset(
            (Random().nextDouble() * 2 - 1) * 1.5,
            (Random().nextDouble() * 2 - 1) * 1.5),
        size: 100,
        animalType: AnimalType.values[Random().nextInt(AnimalType.values.length)],
        gifController: GifController(vsync: this),
      ));
    }

    for (var animal in animals) {
      animal.gifController.repeat(period: const Duration(seconds: 2));
    }

    // Initialize Ticker to update positions continuously
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text("Satisfaction level : 100"),
              Container(
                width: farmSize,
                height: farmSize,
                decoration: BoxDecoration(
                  color: Colors.green[100],  
                  border: Border.all(color: Colors.brown, width: 5),  
                  borderRadius: BorderRadius.circular(10),  
                ),
                child: Stack(
                  children: animals.map((animal) => _buildAnimal(animal)).toList(),
                ),
              ),
              SizedBox(height: 20,),
              Text('Last fed: ${DateTime.now()}'),
                            SizedBox(height: 10,),

              Text('Last watered : ${DateTime.now()}'),
              SizedBox(height: 20,),

              FeedingWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimal(Animal animal) {
    return
     Positioned(
      left: animal.position.dx,
      top: animal.position.dy,
      child:
      // Container(height: 100, width: 100, color: Colors.grey,child: Text('${animal.position.dy}'),)
       Gif(
        height: 100,
        width: 100,
        image: AssetImage(animal.getGifAsset()),
        controller: animal.gifController,
        autostart: Autostart.no,  // Control GIF manually
        onFetchCompleted: () {
          animal.gifController.repeat(period: const Duration(seconds: 2));
        },
        placeholder: (context) => Container(height: 100, width: 100, color: Colors.grey,),
      ),
    );
  }
}

enum AnimalType { cow, pig, cat, dog }

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
  if (position.dx +10  > boundary.width - size) {
    velocity = Offset(-velocity.dx, velocity.dy);
  }

  // Top boundary
  if (position.dy < 0) {
    position = Offset(position.dx, 0);
    velocity = Offset(velocity.dx, -velocity.dy);
  }

  // Bottom boundary considering the size of the animal
  if (position.dy +10  > boundary.height - size) {
    velocity = Offset(velocity.dx, -velocity.dy);
  }
}







  String getGifAsset() {
    switch (animalType) {
      case AnimalType.cow:
        return 'assets/images/dog.gif';
      case AnimalType.pig:
        return 'assets/images/dog.gif';
      case AnimalType.cat:
        return 'assets/images/horse.gif';
      case AnimalType.dog:
        return 'assets/images/dog.gif';
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
            SizedBox(width: 50,),
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
                child: Icon(Icons.local_pizza, size: 50, color: Colors.orange),
                elevation: 5.0,
              ),
              child: Icon(Icons.local_pizza, size: 50, color: Colors.orange),
            ),
            Draggable<String>(
              data: 'water',
              feedback: Material(
                child: Icon(Icons.local_drink, size: 50, color: Colors.blue),
                elevation: 5.0,
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

  Bowl({super.key, required this.isFull, required this.label, required this.icon, required this.color});

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
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}