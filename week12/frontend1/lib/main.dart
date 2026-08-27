import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend 1 - JWT Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const JwtAuthHomePage(),
    );
  }
}

class JwtAuthHomePage extends StatefulWidget {
  const JwtAuthHomePage({super.key});

  @override
  State<JwtAuthHomePage> createState() => _JwtAuthHomePageState();
}

class _JwtAuthHomePageState extends State<JwtAuthHomePage> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'student01');
  final TextEditingController _passwordController =
      TextEditingController(text: 'test1234');
  final TextEditingController _baseUrlController =
      TextEditingController(text: 'http://localhost:8000');

  String _accessToken = '';
  String _refreshToken = '';
  String _logOutput = 'พร้อมทดสอบเรียกใช้งาน API';
  bool _isLoading = false;

  Future<void> _obtainToken() async {
    setState(() {
      _isLoading = true;
      _logOutput = 'กำลังส่งคำขอไปที่ /api/token/...';
    });

    try {
      final response = await http.post(
        Uri.parse('${_baseUrlController.text}/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _accessToken = data['access'] ?? '';
          _refreshToken = data['refresh'] ?? '';
          _logOutput =
              '✅ ล็อกอินสำเร็จ (/api/token/)\nStatus: 200 OK\n\nAccess Token:\n$_accessToken\n\nRefresh Token:\n$_refreshToken';
        });
      } else {
        setState(() {
          _logOutput =
              '❌ ล็อกอินไม่สำเร็จ (${response.statusCode})\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _logOutput = '⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTokenRequest() async {
    if (_refreshToken.isEmpty) {
      setState(() {
        _logOutput = '⚠️ กรุณาขอ Token ก่อนส่งคำขอ Refresh Token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _logOutput = 'กำลังส่งคำขอไปที่ /api/token/refresh/...';
    });

    try {
      final response = await http.post(
        Uri.parse('${_baseUrlController.text}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _accessToken = data['access'] ?? _accessToken;
          _logOutput =
              '🔄 รีเฟรช Token สำเร็จ (/api/token/refresh/)\nStatus: 200 OK\n\nNew Access Token:\n$_accessToken';
        });
      } else {
        setState(() {
          _logOutput =
              '❌ รีเฟรช Token ไม่สำเร็จ (${response.statusCode})\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _logOutput = '⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProtectedData() async {
    if (_accessToken.isEmpty) {
      setState(() {
        _logOutput = '⚠️ กรุณาขอ Token ก่อนเรียก Protected API';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _logOutput = 'กำลังส่งคำขอไปที่ /api/protected/...';
    });

    try {
      final response = await http.get(
        Uri.parse('${_baseUrlController.text}/api/protected/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _logOutput =
              '🔓 เรียกข้อมูล Protected API สำเร็จ (/api/protected/)\nStatus: 200 OK\n\nResponse:\n${const JsonEncoder.withIndent('  ').convert(data)}';
        });
      } else {
        setState(() {
          _logOutput =
              '❌ เรียก Protected API ไม่สำเร็จ (${response.statusCode})\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _logOutput = '⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frontend 1 • DRF Simple JWT Demo'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔐 JWT Authentication Form',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _baseUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Backend URL',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _obtainToken,
                              icon: const Icon(Icons.login),
                              label: const Text('1. Get Token (/api/token/)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _refreshTokenRequest,
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                  '2. Refresh Token (/api/token/refresh/)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _fetchProtectedData,
                              icon: const Icon(Icons.security),
                              label: const Text('3. Call Protected API'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade900,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  color: Colors.black45,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '💻 API Log & Status Output',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const Divider(height: 24),
                        SelectableText(
                          _logOutput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
