# Tests - Health & Fitness App

Este directorio contiene todos los tests unitarios y de integración para la aplicación móvil.

## Estructura de Tests

```
test/
├── features/
│   ├── auth/
│   │   ├── models/         # Tests de modelos de autenticación
│   │   └── repositories/   # Tests de repositorios de autenticación
│   ├── exercises/
│   │   ├── models/         # Tests de modelos de ejercicios
│   │   └── repositories/   # Tests de repositorios de ejercicios
│   ├── workouts/
│   │   └── models/         # Tests de modelos de entrenamientos
│   └── gamification/
│       └── models/         # Tests de modelos de gamificación
└── README.md
```

## Ejecutar Tests

### Todos los tests
```bash
flutter test
```

### Tests específicos por feature
```bash
# Tests de autenticación
flutter test test/features/auth/

# Tests de ejercicios
flutter test test/features/exercises/

# Tests de entrenamientos
flutter test test/features/workouts/

# Tests de gamificación
flutter test test/features/gamification/
```

### Test de un archivo específico
```bash
flutter test test/features/auth/models/user_test.dart
```

### Con cobertura
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Generar Mocks

Los tests de repositorios usan mockito para generar mocks. Para regenerar los mocks:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Tests Implementados

### Models (8 archivos)
- ✅ `auth/models/user_test.dart` - Tests del modelo User
- ✅ `auth/models/auth_tokens_test.dart` - Tests del modelo AuthTokens
- ✅ `exercises/models/exercise_test.dart` - Tests del modelo Exercise
- ✅ `workouts/models/workout_test.dart` - Tests de Workout y WorkoutExercise
- ✅ `workouts/models/workout_session_test.dart` - Tests de WorkoutSession y ExerciseSet
- ✅ `gamification/models/user_stats_test.dart` - Tests del modelo UserStats
- ✅ `gamification/models/achievement_test.dart` - Tests de Achievement y UserAchievement
- ✅ `gamification/models/daily_quote_test.dart` - Tests del modelo DailyQuote

### Repositories (2 archivos)
- ✅ `auth/repositories/auth_repository_test.dart` - Tests del repositorio de autenticación
- ✅ `exercises/repositories/exercise_repository_test.dart` - Tests del repositorio de ejercicios

## Cobertura de Tests

### Modelos (100%)
Todos los modelos principales tienen tests completos que cubren:
- Serialización/deserialización JSON
- Extensiones y métodos calculados
- Validaciones
- copyWith
- Igualdad

### Repositorios (40%)
Tests de repositorios con mocks que cubren:
- Operaciones CRUD
- Manejo de caché
- Manejo de errores
- Integración con datasources

## Próximos Tests a Implementar

### Providers
- [ ] `auth/providers/auth_provider_test.dart`
- [ ] `exercises/providers/exercises_provider_test.dart`
- [ ] `workouts/providers/workout_providers_test.dart`
- [ ] `gamification/providers/gamification_providers_test.dart`

### Widget Tests
- [ ] `auth/presentation/pages/login_page_test.dart`
- [ ] `auth/presentation/pages/register_page_test.dart`
- [ ] `exercises/presentation/pages/exercises_list_page_test.dart`
- [ ] `gamification/presentation/widgets/level_progress_card_test.dart`

### Integration Tests
- [ ] `integration/auth_flow_test.dart`
- [ ] `integration/workout_flow_test.dart`
- [ ] `integration/exercise_search_test.dart`

## Buenas Prácticas

1. **Nombrado**: Los archivos de test deben terminar en `_test.dart`
2. **Estructura**: Usar `group()` para organizar tests relacionados
3. **Mocks**: Usar mockito para dependencias externas
4. **Arrange-Act-Assert**: Seguir el patrón AAA en cada test
5. **Descriptivos**: Nombres de tests claros que describan el comportamiento esperado

## Dependencias de Testing

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.6
  patrol: ^3.0.0  # Para integration tests
```

## Comandos Útiles

```bash
# Limpiar y regenerar mocks
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar tests en modo watch
flutter test --watch

# Ejecutar tests con output verbose
flutter test --verbose

# Ejecutar solo tests que fallaron
flutter test --test-randomize-ordering-seed random
```

## CI/CD

Los tests se ejecutan automáticamente en cada push y pull request a través de GitHub Actions.
Ver `.github/workflows/test.yml` para más detalles.
