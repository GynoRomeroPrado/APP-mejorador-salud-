import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_quote.freezed.dart';
part 'daily_quote.g.dart';

@freezed
class DailyQuote with _$DailyQuote {
  const factory DailyQuote({
    required String text,
    required String author,
    String? category,
  }) = _DailyQuote;

  factory DailyQuote.fromJson(Map<String, dynamic> json) =>
      _$DailyQuoteFromJson(json);
}

/// Quotes motivacionales predefinidas
class DailyQuotes {
  static final List<DailyQuote> quotes = [
    const DailyQuote(
      text: 'El único mal entrenamiento es el que no se hizo.',
      author: 'Anónimo',
      category: 'motivación',
    ),
    const DailyQuote(
      text: 'Tu cuerpo puede soportar casi cualquier cosa. Es tu mente la que debes convencer.',
      author: 'Anónimo',
      category: 'mentalidad',
    ),
    const DailyQuote(
      text: 'El dolor que sientes hoy, será la fuerza que sientas mañana.',
      author: 'Arnold Schwarzenegger',
      category: 'perseverancia',
    ),
    const DailyQuote(
      text: 'No cuentes los días, haz que los días cuenten.',
      author: 'Muhammad Ali',
      category: 'acción',
    ),
    const DailyQuote(
      text: 'La única forma de hacer un gran trabajo es amar lo que haces.',
      author: 'Steve Jobs',
      category: 'pasión',
    ),
    const DailyQuote(
      text: 'El éxito no es definitivo, el fracaso no es fatal: es el coraje para continuar lo que cuenta.',
      author: 'Winston Churchill',
      category: 'resiliencia',
    ),
    const DailyQuote(
      text: 'La disciplina es hacer lo que tienes que hacer, cuando tienes que hacerlo, aunque no quieras.',
      author: 'Anónimo',
      category: 'disciplina',
    ),
    const DailyQuote(
      text: 'Roma no se construyó en un día, pero trabajaron en ella todos los días.',
      author: 'Proverbio',
      category: 'consistencia',
    ),
    const DailyQuote(
      text: 'Tu salud es una inversión, no un gasto.',
      author: 'Anónimo',
      category: 'salud',
    ),
    const DailyQuote(
      text: 'El mejor momento para plantar un árbol fue hace 20 años. El segundo mejor momento es ahora.',
      author: 'Proverbio Chino',
      category: 'inicio',
    ),
    const DailyQuote(
      text: 'No importa lo lento que vayas, siempre y cuando no te detengas.',
      author: 'Confucio',
      category: 'progreso',
    ),
    const DailyQuote(
      text: 'La diferencia entre quien eres y quien quieres ser, es lo que haces.',
      author: 'Anónimo',
      category: 'acción',
    ),
    const DailyQuote(
      text: 'Cuida tu cuerpo. Es el único lugar que tienes para vivir.',
      author: 'Jim Rohn',
      category: 'salud',
    ),
    const DailyQuote(
      text: 'El fitness no es un destino, es una forma de vida.',
      author: 'Anónimo',
      category: 'estilo de vida',
    ),
    const DailyQuote(
      text: 'La única competencia que importa es la que tienes contigo mismo ayer.',
      author: 'Anónimo',
      category: 'superación',
    ),
  ];

  /// Obtiene la quote del día basada en la fecha
  static DailyQuote getQuoteOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % quotes.length;
    return quotes[index];
  }

  /// Obtiene una quote aleatoria
  static DailyQuote getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch % quotes.length;
    return quotes[random];
  }
}
