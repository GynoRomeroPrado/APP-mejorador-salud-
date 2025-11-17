import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    @JsonKey(name: 'body_part') required String bodyPart,
    required String equipment,
    @JsonKey(name: 'gif_url') required String gifUrl,
    required String target,
    @JsonKey(name: 'secondary_muscles') required List<String> secondaryMuscles,
    required List<String> instructions,
    @Default(false) bool isFavorite,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

extension ExerciseExtension on Exercise {
  /// Retorna el nivel de dificultad estimado basado en el equipamiento
  String get estimatedDifficulty {
    if (equipment.toLowerCase() == 'body weight') {
      return 'beginner';
    } else if (equipment.toLowerCase().contains('barbell') ||
        equipment.toLowerCase().contains('olympic')) {
      return 'advanced';
    }
    return 'intermediate';
  }

  /// Retorna el tipo de ejercicio (compound vs isolation)
  String get exerciseType {
    if (secondaryMuscles.length >= 2) {
      return 'compound';
    }
    return 'isolation';
  }

  /// Retorna el grupo muscular principal en español
  String get bodyPartSpanish {
    final translations = {
      'back': 'Espalda',
      'cardio': 'Cardio',
      'chest': 'Pecho',
      'lower arms': 'Antebrazos',
      'lower legs': 'Piernas inferiores',
      'neck': 'Cuello',
      'shoulders': 'Hombros',
      'upper arms': 'Brazos',
      'upper legs': 'Piernas',
      'waist': 'Abdomen',
    };
    return translations[bodyPart.toLowerCase()] ?? bodyPart;
  }

  /// Retorna el equipamiento en español
  String get equipmentSpanish {
    final translations = {
      'body weight': 'Peso corporal',
      'barbell': 'Barra',
      'dumbbell': 'Mancuernas',
      'cable': 'Polea',
      'machine': 'Máquina',
      'kettlebell': 'Pesa rusa',
      'resistance band': 'Banda elástica',
      'stability ball': 'Balón suizo',
      'ez barbell': 'Barra Z',
      'assisted': 'Asistido',
      'leverage machine': 'Máquina de palanca',
      'olympic barbell': 'Barra olímpica',
      'roller': 'Rodillo',
      'rope': 'Cuerda',
      'skierg machine': 'Máquina de esquí',
      'sled machine': 'Trineo',
      'smith machine': 'Máquina Smith',
      'tire': 'Neumático',
      'trap bar': 'Barra hexagonal',
      'weighted': 'Con peso',
      'wheel roller': 'Rueda abdominal',
    };
    return translations[equipment.toLowerCase()] ?? equipment;
  }

  /// Retorna el músculo objetivo en español
  String get targetSpanish {
    final translations = {
      'abs': 'Abdominales',
      'quads': 'Cuádriceps',
      'lats': 'Dorsales',
      'calves': 'Gemelos',
      'pectorals': 'Pectorales',
      'glutes': 'Glúteos',
      'hamstrings': 'Isquiotibiales',
      'adductors': 'Aductores',
      'triceps': 'Tríceps',
      'biceps': 'Bíceps',
      'delts': 'Deltoides',
      'traps': 'Trapecios',
      'forearms': 'Antebrazos',
      'levator scapulae': 'Elevador de la escápula',
      'serratus anterior': 'Serrato anterior',
      'spine': 'Columna vertebral',
      'upper back': 'Espalda alta',
      'cardiovascular system': 'Sistema cardiovascular',
    };
    return translations[target.toLowerCase()] ?? target;
  }

  /// Verifica si el ejercicio puede hacerse en casa
  bool get canDoAtHome {
    final homeEquipment = [
      'body weight',
      'dumbbell',
      'resistance band',
      'stability ball',
      'wheel roller',
    ];
    return homeEquipment.contains(equipment.toLowerCase());
  }

  /// Estima las calorías quemadas por minuto (aproximado)
  double get estimatedCaloriesPerMinute {
    if (bodyPart.toLowerCase() == 'cardio') {
      return 8.0;
    } else if (exerciseType == 'compound') {
      return 5.0;
    }
    return 3.5;
  }
}
