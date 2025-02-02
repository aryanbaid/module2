import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(MaterialApp(
    home: SignInScreen(), // Default screen is Sign In
  ));
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sign In",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.grey[350],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text("Sign In"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    print("Sign In button pressed");
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Fetch wallet balance from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      int balance = userDoc.exists ? userDoc['wallet_balance'] : 10;

      print("Sign In successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DiceGame(
            initialBalance: balance,
            userEmail: userCredential.user!.email ??
                'No email', // Get the user's email here
          ),
        ),
      );
    } catch (e) {
      print("Sign in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign In Failed: $e")),
      );
    }
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.grey[350],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text("Sign Up"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Goes back to Sign In
              },
              child: Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    print("Sign Up button pressed");
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save wallet balance to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'wallet_balance': 10,
      });

      print("Sign Up successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DiceGame(initialBalance: 10, userEmail: _emailController.text)),
      );
    } catch (e) {
      print("Sign up error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Failed: $e")),
      );
    }
  }
}

class GameHistoryScreen extends StatefulWidget {
  @override
  _GameHistoryScreenState createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  late Stream<QuerySnapshot> _historyStream;

  @override
  void initState() {
    super.initState();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _historyStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('game_history')
          .orderBy('timestamp', descending: true) // Order by timestamp
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "Game History",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat'
          ),
        ),
        backgroundColor: Colors.red[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[350],
      body: StreamBuilder<QuerySnapshot>(
        stream: _historyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var historyData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              var game = historyData[index];
              var wager = game['wager'];
              var diceRolls = game['dice_rolls'];
              var outcome = game['outcome'];
              var updatedBalance = game['updated_balance'];

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  title: Text("Wager: $wager"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dice Rolls: ${diceRolls.join(', ')}"),
                      Text("Outcome: $outcome"),
                      Text("Updated Balance: $updatedBalance coins"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DiceGame extends StatefulWidget {
  final int initialBalance;
  final String userEmail;

  DiceGame({required this.initialBalance, required this.userEmail});

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
    balance = widget.initialBalance;
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

  void _checkWin() async {
    final wagerAmount = int.tryParse(_wagerController.text) ?? 0;

    Map<int, int> frequency = {};
    for (int dice in dicenumber) {
      frequency[dice] = (frequency[dice] ?? 0) + 1;
    }

    bool isWin = false;
    int multiplier = 0;

    if (gameType == '2 Alike') {
      isWin = frequency.values.any((count) => count == 2);
      multiplier = 2;
    } else if (gameType == '3 Alike') {
      isWin = frequency.values.any((count) => count == 3);
      multiplier = 3;
    } else if (gameType == '4 Alike') {
      isWin = frequency.values.any((count) => count == 4);
      multiplier = 4;
    }

    if (isWin) {
      balance += wagerAmount * multiplier;
      result = 'You Win!';
    } else {
      balance -= wagerAmount * multiplier;
      result = 'You lose!';
    }

    _saveGameHistory(wagerAmount, dicenumber, isWin);

    // Update balance in Firestore
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'wallet_balance': balance,
      });
    }

    setState(() {});
  }

  void _saveGameHistory(
      int wagerAmount, List<int> diceRolls, bool isWin) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        // Create a game history entry
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('game_history')
            .add({
          'wager': wagerAmount,
          'dice_rolls': diceRolls,
          'outcome': isWin ? 'Win' : 'Lose',
          'updated_balance': balance,
          'timestamp': FieldValue.serverTimestamp(), // Timestamp of the game
        });
        print("Game history saved successfully.");
      } catch (e) {
        print("Error saving game history: $e");
      }
    } else {
      print("No user ID found, cannot save game history.");
    }
  }

  void _resetBalance() async {
    setState(() {
      balance = 10; // Reset wallet balance to 10
      result = ''; // Clear the result message
      _wagerController.clear(); // Clear the wager input field
    });

    // Update Firestore with the new balance
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'wallet_balance': balance,
        });
        print("Wallet balance reset to 10 in Firestore.");
      } catch (e) {
        print("Error updating Firestore: $e");
      }
    } else {
      print("Error: No user ID found, cannot reset balance.");
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SignInScreen()), // Replace with SignInScreen
    );
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
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
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
                'Welcome, ${widget.userEmail}!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 40),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameHistoryScreen()),
          );
        },
        child: Icon(
          Icons.history,
          size: 30, // Adjust size if needed
          color: Colors.white, // Ensure contrast with the background
        ),
        backgroundColor: Colors.red[400], // Button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Places the button at bottom-right
    );
  }
}
