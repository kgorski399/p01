import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gif/gif.dart';



class FarmScreen extends StatefulWidget {
      static const routeName = '/farm';

  @override
  _FarmScreenState createState() => _FarmScreenState();

}

class _FarmScreenState extends State<FarmScreen> with TickerProviderStateMixin {
  final List<Animal> animals = [];
  late Ticker _ticker;

  final double farmSize = 500; 

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
      animal.gifController.repeat(period: Duration(seconds: 2));
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
    return Center(
      child: Container(
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
          animal.gifController.repeat(period: Duration(seconds: 2));
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
