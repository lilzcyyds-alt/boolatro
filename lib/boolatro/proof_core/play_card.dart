/// Lightweight data object representing a card used to compose proof sentences.
class PlayCard {
  /// Unique identifier for this card instance.
  final int id;

  /// The raw symbol/content (e.g., "A", "~", "&").
  final String content;

  /// Whether this card is an atom or a connective.
  final CardType type;

  /// Path to the card's sprite image.
  final String? imagePath;

  /// Creates a PlayCard with id, content and type.
  PlayCard({
    required this.id,
    required this.content,
    required this.type,
    this.imagePath,
  });
}

/// Type tags for [PlayCard].
enum CardType {
  atom,
  connective,
  complexExpression,
}
