import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Política de Privacidad'),
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
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF05CEA8),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Center(
                  child: Text(
                    'Política de Privacidad',
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
                        'En WalletPro, valoramos y respetamos su privacidad. Esta Política de Privacidad describe cómo recopilamos, usamos, divulgamos y protegemos su información cuando utiliza nuestra aplicación móvil y servicios relacionados.',
                      ),
                      _buildParagraph(
                        'Al utilizar nuestra aplicación, usted acepta las prácticas descritas en esta política.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('2. Información que Recopilamos'),
                      _buildParagraph(
                        'Podemos recopilar varios tipos de información, incluyendo:',
                      ),
                      _buildListItem(
                        'Información personal: nombre, dirección de correo electrónico, número de teléfono, dirección postal, fecha de nacimiento, etc.',
                      ),
                      _buildListItem(
                        'Información financiera: números de cuenta bancaria, historial de transacciones, saldos de cuentas, etc.',
                      ),
                      _buildListItem(
                        'Información del dispositivo: tipo de dispositivo, sistema operativo, identificadores únicos de dispositivo, etc.',
                      ),
                      _buildListItem(
                        'Información de uso: cómo utiliza nuestra aplicación, qué funciones utiliza con más frecuencia, etc.',
                      ),
                      _buildListItem(
                        'Información de ubicación: con su consentimiento, podemos recopilar y procesar información sobre su ubicación.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('3. Cómo Utilizamos su Información'),
                      _buildParagraph(
                        'Utilizamos la información recopilada para:',
                      ),
                      _buildListItem(
                        'Proporcionar, mantener y mejorar nuestros servicios.',
                      ),
                      _buildListItem(
                        'Procesar transacciones y enviar notificaciones relacionadas.',
                      ),
                      _buildListItem(
                        'Personalizar su experiencia y proporcionar contenido y ofertas adaptadas a sus intereses.',
                      ),
                      _buildListItem(
                        'Comunicarnos con usted, incluyendo responder a sus consultas y proporcionar soporte al cliente.',
                      ),
                      _buildListItem(
                        'Proteger contra actividades fraudulentas, no autorizadas o ilegales.',
                      ),
                      _buildListItem(
                        'Cumplir con obligaciones legales y regulatorias.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('4. Divulgación de su Información'),
                      _buildParagraph('Podemos compartir su información con:'),
                      _buildListItem(
                        'Proveedores de servicios que nos ayudan a proporcionar nuestros servicios.',
                      ),
                      _buildListItem(
                        'Socios comerciales con los que ofrecemos productos o servicios conjuntos.',
                      ),
                      _buildListItem(
                        'Autoridades legales cuando sea requerido por ley o para proteger nuestros derechos.',
                      ),
                      _buildListItem(
                        'Terceros en caso de una fusión, adquisición o venta de activos.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('5. Seguridad de la Información'),
                      _buildParagraph(
                        'Implementamos medidas de seguridad técnicas, administrativas y físicas diseñadas para proteger su información contra acceso no autorizado, divulgación, alteración y destrucción.',
                      ),
                      _buildParagraph(
                        'Sin embargo, ningún método de transmisión por Internet o método de almacenamiento electrónico es 100% seguro, por lo que no podemos garantizar su seguridad absoluta.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('6. Sus Derechos'),
                      _buildParagraph(
                        'Dependiendo de su ubicación, puede tener ciertos derechos con respecto a su información personal, incluyendo:',
                      ),
                      _buildListItem('Acceder a su información personal.'),
                      _buildListItem(
                        'Corregir información inexacta o incompleta.',
                      ),
                      _buildListItem('Eliminar su información personal.'),
                      _buildListItem(
                        'Restringir u oponerse al procesamiento de su información.',
                      ),
                      _buildListItem(
                        'Recibir su información en un formato estructurado y transferirla a otro controlador.',
                      ),
                      _buildListItem(
                        'Retirar su consentimiento en cualquier momento.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('7. Cambios a esta Política'),
                      _buildParagraph(
                        'Podemos actualizar esta Política de Privacidad periódicamente. Le notificaremos cualquier cambio material publicando la nueva Política de Privacidad en nuestra aplicación y, cuando sea apropiado, a través de correo electrónico.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('8. Contacto'),
                      _buildParagraph(
                        'Si tiene alguna pregunta sobre esta Política de Privacidad, comuníquese con nosotros a través de:',
                      ),
                      _buildParagraph(
                        'Correo electrónico: privacidad@WalletPro.com',
                      ),
                      _buildParagraph('Teléfono: +57 3133567891'),
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
