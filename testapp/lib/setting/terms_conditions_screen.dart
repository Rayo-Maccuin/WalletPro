import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Términos y Condiciones'),
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
                // Icono
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF05CEA8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF05CEA8),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Center(
                  child: Text(
                    'Términos y Condiciones',
                    style: TextStyle(
                      color: Color(0xFF293431),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Última actualización: 10 de marzo de 2025',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 30),

                // Contenido
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
                      _buildSectionTitle('1. Introducción'),
                      _buildParagraph(
                        'Bienvenido a WalletPro. Estos Términos y Condiciones rigen el uso de nuestra aplicación móvil y servicios relacionados. Al acceder o utilizar nuestra aplicación, usted acepta estar sujeto a estos términos. Si no está de acuerdo con alguna parte de estos términos, no podrá acceder a la aplicación.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('2. Definiciones'),
                      _buildParagraph(
                        '"Aplicación" se refiere a la aplicación móvil WalletPro.',
                      ),
                      _buildParagraph(
                        '"Usuario" se refiere a cualquier persona que acceda o utilice la Aplicación.',
                      ),
                      _buildParagraph(
                        '"Servicios" se refiere a todas las funcionalidades, herramientas y contenidos disponibles a través de la Aplicación.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('3. Registro y Cuentas'),
                      _buildParagraph(
                        'Para utilizar ciertas funciones de la Aplicación, es posible que deba registrarse y crear una cuenta. Usted es responsable de mantener la confidencialidad de su información de cuenta y contraseña, y de restringir el acceso a su dispositivo móvil.',
                      ),
                      _buildParagraph(
                        'Usted acepta asumir la responsabilidad de todas las actividades que ocurran bajo su cuenta. Debe notificarnos inmediatamente sobre cualquier uso no autorizado de su cuenta o cualquier otra violación de seguridad.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('4. Uso Aceptable'),
                      _buildParagraph(
                        'Usted acepta no utilizar la Aplicación para:',
                      ),
                      _buildListItem(
                        'Violar cualquier ley o regulación aplicable.',
                      ),
                      _buildListItem(
                        'Infringir los derechos de propiedad intelectual o cualquier otro derecho de terceros.',
                      ),
                      _buildListItem(
                        'Transmitir virus, malware o cualquier otro código de naturaleza destructiva.',
                      ),
                      _buildListItem(
                        'Recopilar o rastrear información personal de otros usuarios.',
                      ),
                      _buildListItem(
                        'Interferir con el funcionamiento normal de la Aplicación.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('5. Privacidad'),
                      _buildParagraph(
                        'Su privacidad es importante para nosotros. Consulte nuestra Política de Privacidad para obtener información sobre cómo recopilamos, usamos y divulgamos información sobre usted.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('6. Modificaciones'),
                      _buildParagraph(
                        'Nos reservamos el derecho de modificar estos Términos y Condiciones en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación en la Aplicación. Su uso continuado de la Aplicación después de cualquier modificación constituye su aceptación de los nuevos términos.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('7. Limitación de Responsabilidad'),
                      _buildParagraph(
                        'En ningún caso WalletPro, sus directores, empleados o agentes serán responsables por cualquier daño directo, indirecto, incidental, especial, punitivo o consecuente que surja del uso o la imposibilidad de usar la Aplicación.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('8. Ley Aplicable'),
                      _buildParagraph(
                        'Estos Términos y Condiciones se regirán e interpretarán de acuerdo con las leyes del país donde WalletPro tiene su sede principal, sin tener en cuenta sus disposiciones sobre conflictos de leyes.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('9. Contacto'),
                      _buildParagraph(
                        'Si tiene alguna pregunta sobre estos Términos y Condiciones, comuníquese con nosotros a través de:',
                      ),
                      _buildParagraph(
                        'Correo electrónico: soporte@WalletPro.com',
                      ),
                      _buildParagraph('Teléfono: +57 3133567897'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Botón aceptar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05CEA8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF05CEA8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
