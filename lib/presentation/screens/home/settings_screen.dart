import 'package:flutter/material.dart';
import 'package:testapp/setting/profile_edit_screen.dart';
import 'package:testapp/setting/chance_password_screen.dart';
import 'package:testapp/setting/security_questions_screen.dart';
import 'package:testapp/setting/terms_conditions_screen.dart';
import 'package:testapp/setting/privacy_policy.dart';
import 'package:testapp/setting/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Configuraciones'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Perfil
                _buildSectionTitle('Perfil'),
                _buildProfileCard(),
                const SizedBox(height: 25),

                _buildSectionTitle('General'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Notificaciones',
                    'Recibir alertas y notificaciones',
                    Icons.notifications_outlined,
                    _notificationsEnabled,
                    (value) {
                      setState(() {
                        _notificationsEnabled = value;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notificaciones activadas'
                                  : 'Notificaciones desactivadas',
                            ),
                            backgroundColor: const Color(0xFF05CEA8),
                          ),
                        );
                      });
                    },
                  ),
                  const Divider(),
                  _buildSwitchTile(
                    'Modo oscuro',
                    'Cambiar apariencia de la aplicación',
                    Icons.dark_mode_outlined,
                    _darkModeEnabled,
                    (value) {
                      setState(() {
                        _darkModeEnabled = value;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Modo oscuro activado'
                                  : 'Modo oscuro desactivado',
                            ),
                            backgroundColor: const Color(0xFF05CEA8),
                          ),
                        );

                        // Aquí se implementaría la lógica para cambiar el tema
                      });
                    },
                  ),
                  const Divider(),
                  _buildSwitchTile(
                    'Autenticación biométrica',
                    'Usar huella digital para iniciar sesión',
                    Icons.fingerprint,
                    _biometricEnabled,
                    (value) {
                      setState(() {
                        _biometricEnabled = value;

                        // Mostrar mensaje de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Autenticación biométrica activada'
                                  : 'Autenticación biométrica desactivada',
                            ),
                            backgroundColor: const Color(0xFF05CEA8),
                          ),
                        );
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 25),

                // Seguridad
                _buildSectionTitle('Seguridad'),
                _buildSettingsCard([
                  _buildNavigationTile(
                    'Cambiar contraseña',
                    'Actualiza tu contraseña periódicamente',
                    Icons.lock_outline,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildNavigationTile(
                    'Preguntas de seguridad',
                    'Configura preguntas para recuperar tu cuenta',
                    Icons.help_outline,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecurityQuestionsScreen(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 25),

                _buildSectionTitle('Información'),
                _buildSettingsCard([
                  _buildNavigationTile(
                    'Términos y condiciones',
                    'Revisa nuestros términos de uso',
                    Icons.description_outlined,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildNavigationTile(
                    'Política de privacidad',
                    'Cómo protegemos tus datos',
                    Icons.privacy_tip_outlined,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildNavigationTile(
                    'Acerca de',
                    'Información sobre la aplicación',
                    Icons.info_outline,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLogoutConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF293431),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF293431),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF45AA96),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario',
                  style: TextStyle(
                    color: const Color(0xFF151616),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'usuario@ejemplo.com',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF45AA96)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF05CEA8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF05CEA8)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF151616),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF05CEA8),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF05CEA8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF05CEA8)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF151616),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: const Color(0xFF45AA96),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05CEA8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
