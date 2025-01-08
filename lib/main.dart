import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
      home: DiceGame(),
    ));

class DiceGame extends StatefulWidget {
  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<int> dicenumber = [1, 1, 1, 1];
  int balance = 10;
  String? gameType;
  final TextEditingController _wagerController = TextEditingController();
  String result = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dicenumber = List.generate(4, (_) => Random().nextInt(6) + 1);
          });
          _controller.reset();
          _checkWin();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _wagerController.dispose();
    super.dispose();
  }

  void _rollDice() {
    final wagerAmount = int.tryParse(_wagerController.text);

    if (gameType == null) {
      setState(() {
        result = 'Please select a game type.';
      });
      return;
    }

    if (wagerAmount == null || wagerAmount <= 0) {
      setState(() {
        result = 'Please enter a valid wager amount.';
      });
      return;
    }

    // Calculate the multiplier based on the game type
    int multiplier = 0;
    if (gameType == '2 Alike') {
      multiplier = 2;
    } else if (gameType == '3 Alike') {
      multiplier = 3;
    } else if (gameType == '4 Alike') {
      multiplier = 4;
    }

    // Check if the player has enough balance
    if (balance < wagerAmount * multiplier) {
      setState(() {
        result =
            'Insufficient balance! You need at least ${wagerAmount * multiplier} coins.';
      });
      return;
    }

    setState(() {});

    _controller.forward();
  }

  void _checkWin() {
    final wagerAmount = int.tryParse(_wagerController.text) ?? 0;

    // Create a frequency map of the dice numbers
    Map<int, int> frequency = {};
    for (int dice in dicenumber) {
      frequency[dice] = (frequency[dice] ?? 0) + 1;
    }

    bool isWin = false;
    int multiplier = 0;

    if (gameType == '2 Alike') {
      isWin = frequency.values.any((count) => count >= 2);
      multiplier = 2;
    } else if (gameType == '3 Alike') {
      isWin = frequency.values.any((count) => count >= 3);
      multiplier = 3;
    } else if (gameType == '4 Alike') {
      isWin = frequency.values.any((count) => count == 4);
      multiplier = 4;
    }

    setState(() {
      if (isWin) {
        balance += wagerAmount *
            multiplier; // Add the winning amount (multiplied by 2, 3, or 4)
        result = 'You Win!';
      } else {
        balance -= wagerAmount * multiplier;
        result = 'You lose!';
      }
    });
  }

  void _resetBalance() {
    setState(() {
      balance = 10; // Reset wallet balance to 10
      result = ''; // Clear the result message
      _wagerController.clear(); // Clear the wager input field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Dice Game',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26.0,
              fontFamily: 'Montserrat',
            )),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.grey[350],
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Wallet balance: $balance coins',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Reset Button below Wallet balance
              ElevatedButton(
                onPressed: _resetBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Reset Balance',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              DropdownButton<String>(
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
                dropdownColor: Colors.grey[300],
                value: gameType,
                hint: Text('Select Game type'),
                items: ['2 Alike', '3 Alike', '4 Alike'].map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    gameType = value;
                  });
                },
              ),
              SizedBox(height: 30.0),
              TextField(
                controller: _wagerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter wager amount',
                ),
              ),
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dicenumber.map((diceNumber) {
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/dice$diceNumber.jpg',
                      height: 77,
                      width: 77,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _rollDice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Roll Dice',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display the game result message below the button
              if (result.isNotEmpty)
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
