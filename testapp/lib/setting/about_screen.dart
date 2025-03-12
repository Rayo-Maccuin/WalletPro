import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Acerca de'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF293431),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF05CEA8),
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre de la app
                const Text(
                  'WalletPro',
                  style: TextStyle(
                    color: Color(0xFF293431),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // Versión
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Información
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Descripción'),
                      _buildParagraph(
                        'WalletPro es una aplicación bancaria móvil diseñada para proporcionar una experiencia financiera completa y segura. Nuestra misión es simplificar la gestión de sus finanzas personales y brindarle herramientas útiles para tomar decisiones financieras informadas.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Características'),
                      _buildFeatureItem(
                        Icons.account_balance_wallet_outlined,
                        'Gestión de cuentas',
                        'Administre sus cuentas bancarias, vea saldos y movimientos.',
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureItem(
                        Icons.swap_horiz,
                        'Transferencias',
                        'Realice transferencias entre cuentas propias y a terceros.',
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureItem(
                        Icons.calculate_outlined,
                        'Calculadoras financieras',
                        'Herramientas para calcular préstamos, inversiones y más.',
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureItem(
                        Icons.security,
                        'Seguridad avanzada',
                        'Protección de datos y autenticación biométrica.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Desarrollado por'),
                      _buildParagraph('WalletPro Inc.'),
                      _buildParagraph(
                        'Dirección: 123 Financial Street, Banking City, BC 12345',
                      ),
                      _buildParagraph('Correo electrónico: info@WalletPro.com'),
                      _buildParagraph('Sitio web: www.WalletPro.com'),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Agradecimientos'),
                      _buildParagraph(
                        'Agradecemos a todos nuestros usuarios por su confianza y apoyo continuo. Su retroalimentación es fundamental para mejorar constantemente nuestra aplicación.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Redes sociales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.facebook, () {}),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.telegram, () {}),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.email_outlined, () {}),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.language, () {}),
                  ],
                ),
                const SizedBox(height: 20),

                // Copyright
                Text(
                  '© 2025 WalletPro. Todos los derechos reservados.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF293431),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF05CEA8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF05CEA8), size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF293431),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF05CEA8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF05CEA8).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
