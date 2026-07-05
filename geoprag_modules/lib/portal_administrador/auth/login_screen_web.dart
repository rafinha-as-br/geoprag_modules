import 'package:flutter/material.dart';

class LoginScreenWeb extends StatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  State<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends State<LoginScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Branding / Landing Area
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E20), // Dark green
                    Color(0xFF4CAF50), // Light green
                  ],
                ),
              ),
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 120,
                        color: Colors.white,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'GeoPrag\nPortal do Servidor',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Plataforma integrada de georreferenciamento e gestão operacional destinada ao apoio do programa municipal de controle do borrachudo no município de Gaspar.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right side: Login Form Area
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(64.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Acesso Restrito',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Entre com suas credenciais de servidor da prefeitura',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'CPF ou E-mail Institucional',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(color: Color(0xFF1B5E20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Entrar no Portal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
