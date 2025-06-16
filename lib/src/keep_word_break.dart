/// Extension providing Korean text wrapping improvements for Flutter applications.
///
/// Addresses Flutter's text wrapping limitations with Korean (Hangul) characters
/// by strategically inserting zero-width joiners (U+200D) between characters.
///
/// ## Behavior
///
/// - **No Korean content**: Returns the original string unchanged
/// - **Korean content detected**: Processes each word individually:
///   - Words containing emojis are preserved as-is
///   - Other words have zero-width joiners inserted between consecutive non-space characters
/// - **Formatting preservation**: Maintains original line breaks and word spacing
///
/// ## Implementation Details
///
/// Text processing follows this hierarchy:
/// 1. Lines (separated by `\n`)
/// 2. Words within lines (separated by spaces)
/// 3. Characters within words (modified with zero-width joiners)
///
/// Korean character detection uses the Unicode ranges:
/// - `ㄱ-ㅎ`: Hangul consonants
/// - `ㅏ-ㅣ`: Hangul vowels
/// - `가-힣`: Complete Hangul syllables
///
/// ## Related Issues
///
/// - [Flutter Korean text wrapping issue](https://github.com/flutter/flutter/issues/59284)
/// - [No word-breaks for CJK locales](https://github.com/flutter/flutter/issues/19584)
///
/// ## Example
///
/// ```dart
/// final koreanText = "안녕하세요 world!";
/// final wrappedText = koreanText.wrapped;
/// // Result: "안\u200D녕\u200D하\u200D세\u200D요 world!"
/// ```
extension WordWrapBreakWord on String {
  // cspell:ignore udfff
  /// Applies zero-width joiners to improve Korean text wrapping in Flutter.
  ///
  /// Transforms Korean text by inserting U+200D characters between consecutive
  /// non-space characters, which helps Flutter's text rendering engine handle
  /// line breaks more appropriately for Korean content.
  ///
  /// Returns the original string if no Korean characters are detected,
  /// otherwise returns the processed string with zero-width joiners applied.
  String get wrapped {
    // Early return if no Korean characters are present
    if (!contains(RegExp('[ㄱ-ㅎㅏ-ㅣ가-힣]'))) {
      return this;
    }

    // Emoji detection pattern covering common Unicode ranges
    final emoji = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    );

    final fullText = StringBuffer();
    final lines = split('\n');

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final words = lines[lineIndex].split(' ');

      for (var i = 0; i < words.length; i++) {
        // Preserve emoji-containing words, process others with zero-width joiners
        fullText.write(emoji.hasMatch(words[i]) ? words[i] : _zwj(words[i]));

        // Preserve inter-word spacing
        if (i < words.length - 1) {
          fullText.write(' ');
        }
      }

      // Preserve line breaks
      if (lineIndex < lines.length - 1) {
        fullText.write('\n');
      }
    }

    return fullText.toString();
  }
}

/// Inserts zero-width joiners between consecutive non-space characters.
///
/// Uses a positive lookahead regex pattern `(\S)(?=\S)` to match positions
/// between two consecutive non-whitespace characters, then inserts U+200D
/// at those positions.
///
/// ## Example
///
/// ```dart
/// final result = _zwj('안녕하세요');
/// // Returns: '안\u200D녕\u200D하\u200D세\u200D요'
/// ```
///
/// ## Technical Reference
///
/// - [Zero-width joiner (Wikipedia)](https://en.wikipedia.org/wiki/Zero-width_joiner)
/// - [Unicode Standard - Zero Width Joiner](https://www.unicode.org/charts/PDF/U2000.pdf)
String _zwj(String word) {
  return word.replaceAllMapped(
    RegExp(r'(\S)(?=\S)'), // Matches consecutive non-space character pairs
    (match) => '${match[1]}\u200D',
  );
}
