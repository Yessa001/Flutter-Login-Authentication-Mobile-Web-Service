import 'package:flutter/material.dart';
import 'package:flutter_front_end/services/auth.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _fetchDataMap;

  // Login Users
  void handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out the form correctly.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await login(_emailController.text, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch Data
  void handleFetchData() async {
    try {
      final data = await fetchProtectedData();
      print("Fetched Data: $data");
      setState(() {
        _fetchDataMap = data['data'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete Access Token
  void handleHapusToken() async {
    try {
      final isAvailable = await isTokenAvailable();

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access token already deleted!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Hapus token jika masih ada
      await logout();
      setState(() {
        _fetchDataMap = null; // Hapus data yang ditampilkan
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Access token successfully deleted!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete token: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Login User',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            filled: true,
                            fillColor: Colors.green.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            } else if (!value.endsWith('@gmail.com')) {
                              return 'Email must use the domain @gmail.com';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.green.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'The password cannot be empty';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Login Button
                            CustomButton(
                              label: _isLoading ? 'Loading...' : 'Login',
                              onPressed: _isLoading ? () {} : handleLogin,
                              backgroundColor:
                                  _isLoading ? Colors.grey : Colors.green,
                              textColor: Colors.white,
                              borderRadius: 10,
                            ),
                            const SizedBox(width: 10),
                            // Fetch Data Button
                            CustomButton(
                              label: 'Fetch Data',
                              onPressed: handleFetchData,
                              backgroundColor: Colors.blue,
                              textColor: Colors.white,
                              borderRadius: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tampilkan data fetch
              if (_fetchDataMap != null)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.blue[50],
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fetched Data:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('ID: ${_fetchDataMap!['id']}'),
                          Text('Name: ${_fetchDataMap!['name']}'),
                          Text('Email: ${_fetchDataMap!['email']}'),
                          Text('Created At: ${_fetchDataMap!['created_at']}'),
                          Text('Updated At: ${_fetchDataMap!['updated_at']}'),
                          Text('Deleted At: ${_fetchDataMap!['deleted_at']}'),
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete Access Token Button
                  CustomButton(
                    label: 'Delete Access Token',
                    onPressed: handleHapusToken,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
