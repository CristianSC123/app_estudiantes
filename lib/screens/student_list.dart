import 'package:flutter/material.dart';
import '../database/database_helper.dart';  
import '../models/student.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DataBaseHelper _databaseHelper = DataBaseHelper();
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _databaseHelper.getAllStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los estudiantes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> add_Student() async {
    final result = await showDialog<Student>(
      context: context,
      builder: (context) => AddStudentDialog(),
    );
    if (result != null) {
      await _databaseHelper.insertStudent(result);
      _loadStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante agregado exitosamente')),
      );
    }
  }

  Future<void> _editStudent(Student student) async {
    final result = await showDialog<Student>(
      context: context,
      builder: (context) => AddStudentDialog(student: student),
    );
    if (result != null) {
      await _databaseHelper.updateStudent(result);
      _loadStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante editado exitosamente')),
      );
    }
  }

  Future<void> _deleteStudent(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar estudiante'),
        content: Text('¿Estás seguro de eliminar este estudiante?'),
        actions: [
          TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context, false)),
          TextButton(
              child: Text('Eliminar'),
              onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _databaseHelper.deleteStudent(id);
      _loadStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante eliminado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Estudiantes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay estudiantes', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(student.name ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Edad: ${student.age}, Grado: ${student.grade}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _editStudent(student),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteStudent(student.id ?? 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: add_Student,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  final Student? student;
  AddStudentDialog({this.student});

  @override
  _AddStudentDialogState createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.name ?? '';
      _ageController.text = widget.student!.age.toString();
      _gradeController.text = widget.student!.grade ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        grade: _gradeController.text,
        createdAt: widget.student?.createdAt ?? DateTime.now(),
      );
      Navigator.of(context).pop(student);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null
          ? 'Agregar estudiante'
          : 'Editar Estudiante'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa un nombre';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Edad'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa una edad';
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0) {
                  return 'Por favor, ingresa una edad válida';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grado'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa un grado';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.student == null ? 'Agregar' : 'Actualizar'),
        ),
      ],
    );
  }
}
