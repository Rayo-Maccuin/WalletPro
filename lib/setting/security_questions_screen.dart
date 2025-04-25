import 'package:flutter/material.dart';

class SecurityQuestionsScreen extends StatefulWidget {
  const SecurityQuestionsScreen({super.key});

  @override
  State<SecurityQuestionsScreen> createState() =>
      _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState extends State<SecurityQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _questions = [
    '¿Cuál es el nombre de tu primera mascota?',
    '¿En qué ciudad naciste?',
    '¿Cuál es el nombre de tu escuela primaria?',
    '¿Cuál es tu comida favorita?',
    '¿Cuál es el segundo nombre de tu madre?',
  ];

  String? _selectedQuestion1;
  String? _selectedQuestion2;
  String? _selectedQuestion3;

  final _answer1Controller = TextEditingController();
  final _answer2Controller = TextEditingController();
  final _answer3Controller = TextEditingController();

  @override
  void dispose() {
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    _answer3Controller.dispose();
    super.dispose();
  }

  void _saveSecurityQuestions() {
    if (_formKey.currentState!.validate()) {
      // Validar que se hayan seleccionado preguntas diferentes
      if (_selectedQuestion1 == _selectedQuestion2 ||
          _selectedQuestion1 == _selectedQuestion3 ||
          _selectedQuestion2 == _selectedQuestion3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona preguntas diferentes'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Aquí iría la lógica para guardar las preguntas de seguridad
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preguntas de seguridad guardadas correctamente'),
          backgroundColor: Color(0xFF05CEA8),
        ),
      );

      // Volver a la pantalla anterior
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Preguntas de Seguridad'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de seguridad
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF05CEA8).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF05CEA8),
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Center(
                    child: Text(
                      'Configura tus preguntas de seguridad',
                      style: TextStyle(
                        color: Color(0xFF293431),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Estas preguntas te ayudarán a recuperar tu cuenta en caso de que olvides tu contraseña',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Formulario
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
                      children: [
                        // Primera pregunta
                        DropdownButtonFormField<String>(
                          value: _selectedQuestion1,
                          decoration: InputDecoration(
                            labelText: 'Pregunta 1',
                            prefixIcon: const Icon(
                              Icons.question_answer_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          items:
                              _questions.map((String question) {
                                return DropdownMenuItem<String>(
                                  value: question,
                                  child: Text(
                                    question,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedQuestion1 = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor selecciona una pregunta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Respuesta 1
                        TextFormField(
                          controller: _answer1Controller,
                          decoration: InputDecoration(
                            labelText: 'Respuesta 1',
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una respuesta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Segunda pregunta
                        DropdownButtonFormField<String>(
                          value: _selectedQuestion2,
                          decoration: InputDecoration(
                            labelText: 'Pregunta 2',
                            prefixIcon: const Icon(
                              Icons.question_answer_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          items:
                              _questions.map((String question) {
                                return DropdownMenuItem<String>(
                                  value: question,
                                  child: Text(
                                    question,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedQuestion2 = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor selecciona una pregunta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Respuesta 2
                        TextFormField(
                          controller: _answer2Controller,
                          decoration: InputDecoration(
                            labelText: 'Respuesta 2',
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una respuesta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Tercera pregunta
                        DropdownButtonFormField<String>(
                          value: _selectedQuestion3,
                          decoration: InputDecoration(
                            labelText: 'Pregunta 3',
                            prefixIcon: const Icon(
                              Icons.question_answer_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          items:
                              _questions.map((String question) {
                                return DropdownMenuItem<String>(
                                  value: question,
                                  child: Text(
                                    question,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedQuestion3 = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor selecciona una pregunta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Respuesta 3
                        TextFormField(
                          controller: _answer3Controller,
                          decoration: InputDecoration(
                            labelText: 'Respuesta 3',
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF45AA96),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF05CEA8),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una respuesta';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSecurityQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05CEA8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Guardar Preguntas',
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
      ),
    );
  }
}
