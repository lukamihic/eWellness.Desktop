import 'package:flutter/material.dart';

import 'screens/appointments_screen.dart';
import 'screens/service_categories.dart';
import 'screens/special_offers_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/services_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/tips_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eWellness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(), // Set WelcomeScreen as the initial screen
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 76, 175, 142),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'eWellness',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Admin Module',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            // Add username input field
            Container(
              width: MediaQuery.of(context).size.width *
                  0.5, // 50% of screen width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                color: Colors.white,
              ),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Rounded corners for input
                    borderSide: BorderSide.none, // No border line
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add password input field
            Container(
              width: MediaQuery.of(context).size.width *
                  0.5, // 50% of screen width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                color: Colors.white,
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true, // Mask the password input
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Rounded corners for input
                    borderSide: BorderSide.none, // No border line
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Check username and password
                if (usernameController.text == 'desktop' &&
                    passwordController.text == 'test') {
                  // Navigate to HomeScreen if credentials are correct
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                } else {
                  // Show error message if credentials are incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid username or password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 76, 175, 142),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color.fromARGB(255, 76, 175, 142),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    ServicesScreen(),
    ClientsScreen(),
    PaymentsScreen(),
    TipsScreen(),
    ServiceCategoriesScreen(),
    AppointmentScreen(),
    DiscountScreen(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eWellness'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Services',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Clients',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates),
            label: 'Tips',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Service Categories',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.discount),
            label: 'Discounts',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.query_stats),
            label: 'Stats',
            backgroundColor: Color.fromARGB(255, 76, 175, 142),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
