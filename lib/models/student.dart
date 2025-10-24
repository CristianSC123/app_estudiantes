class Student {
  int? id;
  String? name;
  int? age;
  String? grade;
  DateTime? createdAt;

  Student({
    this.id,
    required this.name,
    required this.age,
    required this.grade,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'grade': grade,
      'createdAt':
          createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      grade: map['grade'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  @override //Limpieza de variables (clases ya definidas arriba, las volvemos a definir)
  String toString() {
    return 'Student {id: $id, name: $name, age: $age, grade: $grade}';
  }
}
