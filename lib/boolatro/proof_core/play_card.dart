/// Lightweight data object representing a card used to compose proof sentences.
class PlayCard {
  /// The raw symbol/content (e.g., "A", "~", "&").
  final String content;

  /// Whether this card is an atom or a connective.
  final CardType type;

  /// Creates a PlayCard with content and type.
  const PlayCard({required this.content, required this.type});
}

/// Type tags for [PlayCard].
enum CardType {
  atom,
  connective,
  complexExpression,
}
