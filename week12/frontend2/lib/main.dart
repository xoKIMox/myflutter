import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend 2 - OpenID Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const OidcHomePage(),
    );
  }
}

class OidcHomePage extends StatefulWidget {
  const OidcHomePage({super.key});

  @override
  State<OidcHomePage> createState() => _OidcHomePageState();
}

class _OidcHomePageState extends State<OidcHomePage> {
  final TextEditingController _issuerUrlController =
      TextEditingController(text: 'http://localhost:8001');
  final TextEditingController _clientIdController =
      TextEditingController(text: 'flutter-web-app');

  String _logOutput = 'พร้อมทดสอบการยืนยันตัวตนผ่าน OpenID Connect';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingCredential();
  }

  Future<void> _checkExistingCredential() async {
    try {
      final issuer =
          await Issuer.discover(Uri.parse(_issuerUrlController.text));
      final client = Client(issuer, _clientIdController.text);
      final auth = Authenticator(
        client,
        scopes: ['openid', 'profile', 'email'],
      );

      final c = await auth.credential;
      if (c != null) {
        final info = await c.getUserInfo();
        setState(() {
          _logOutput =
              '✅ ยืนยันตัวตนสำเร็จ (OIDC Credential Restored)\n\nName: ${info.name}\nEmail: ${info.email}\nSubject (sub): ${info.subject}';
        });
      }
    } catch (e) {
      // Ignore initial discovery check if server is not reachable yet
    }
  }

  Future<void> _loginWithOidc() async {
    setState(() {
      _isLoading = true;
      _logOutput = 'กำลังติดต่อ OIDC Server (${_issuerUrlController.text})...';
    });

    try {
      final issuer =
          await Issuer.discover(Uri.parse(_issuerUrlController.text));
      final client = Client(issuer, _clientIdController.text);
      final auth = Authenticator(
        client,
        scopes: ['openid', 'profile', 'email'],
      );

      final c = await auth.credential;
      if (c == null) {
        auth.authorize();
      } else {
        final info = await c.getUserInfo();
        setState(() {
          _logOutput =
              '✅ ล็อกอินสำเร็จผ่าน OIDC Server\n\nName: ${info.name}\nEmail: ${info.email}\nSubject (sub): ${info.subject}';
        });
      }
    } catch (e) {
      setState(() {
        _logOutput = '⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ OIDC Server: $e';
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
        title: const Text('Frontend 2 • OpenID Connect (OIDC) Demo'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade900,
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
                          '🔑 OIDC Authorization Provider Settings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _issuerUrlController,
                          decoration: const InputDecoration(
                            labelText: 'OIDC Provider Issuer URL',
                            prefixIcon: Icon(Icons.dns),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _clientIdController,
                          decoration: const InputDecoration(
                            labelText: 'OIDC Client ID',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loginWithOidc,
                            icon: const Icon(Icons.login),
                            label: const Text('Sign in with OpenID Connect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
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
                              '👤 User Info & Token Claims Log',
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
