import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Lightweight PDF text extractor.
///
/// Parses PDF content streams to extract selectable text.
/// This works for most text-based PDFs without requiring
/// a heavy native PDF parsing library.
class PdfTextParser {
  /// Extracts text from a PDF file.
  ///
  /// Returns a map of page number (1-based) to extracted text.
  /// Pages with no selectable text are omitted.
  Future<Map<int, String>> extractText(String filePath) async {
    final File file = File(filePath);
    if (!file.existsSync()) {
      return <int, String>{};
    }

    final Uint8List bytes = await file.readAsBytes();
    return _parsePdf(bytes);
  }

  /// Parses PDF bytes and extracts text per page.
  Map<int, String> _parsePdf(Uint8List bytes) {
    final String content = latin1.decode(bytes);
    final Map<int, String> pageTexts = <int, String>{};

    // Find all page objects and their content stream references.
    final List<_PdfPage> pages = _findPages(content);

    for (final _PdfPage page in pages) {
      final String? stream = _extractContentStream(content, page.contentRef);
      if (stream != null) {
        final String text = _extractTextFromStream(stream);
        if (text.trim().isNotEmpty) {
          pageTexts[page.number] = text;
        }
      }
    }

    return pageTexts;
  }

  /// Finds page objects in the PDF.
  List<_PdfPage> _findPages(String content) {
    final List<_PdfPage> pages = <_PdfPage>[];
    final RegExp pageRegex = RegExp(
      r'(\d+)\s+(\d+)\s+obj\s*<<([^>]*)>>\s*stream',
      caseSensitive: false,
    );

    int pageNumber = 0;
    for (final RegExpMatch match in pageRegex.allMatches(content)) {
      final String dict = match.group(3) ?? '';
      if (dict.contains('/Type') && dict.contains('/Page')) {
        pageNumber++;
        // Find the /Contents reference.
        final RegExp contentsRegex = RegExp(
          r'/Contents\s+(\d+)\s+(\d+)\s+R',
          caseSensitive: false,
        );
        final RegExpMatch? contentsMatch = contentsRegex.firstMatch(dict);
        if (contentsMatch != null) {
          final int objNum = int.parse(contentsMatch.group(1)!);
          pages.add(_PdfPage(number: pageNumber, contentRef: objNum));
        }
      }
    }

    return pages;
  }

  /// Extracts a content stream by object number.
  String? _extractContentStream(String content, int objNum) {
    final RegExp streamRegex = RegExp(
      '$objNum\\s+\\d+\\s+obj\\s*<<([^>]*)>>\\s*stream\\r?\\n(.*?)\\r?\\nendstream',
      caseSensitive: false,
      dotAll: true,
    );
    final RegExpMatch? match = streamRegex.firstMatch(content);
    if (match == null) {
      return null;
    }
    return match.group(2);
  }

  /// Extracts text from a PDF content stream.
  String _extractTextFromStream(String stream) {
    final StringBuffer result = StringBuffer();

    // Handle FlateDecode compressed streams.
    String decoded = stream;
    if (stream.contains('FlateDecode')) {
      decoded = _tryInflate(stream);
    }

    // Extract text from Tj, TJ, and ' operators.
    final RegExp textRegex = RegExp(
      r"\(((?:[^()\\]|\\.)*)\)\s*(?:Tj|')",
      caseSensitive: false,
    );
    final RegExp arrayRegex = RegExp(
      r'\[((?:[^\[\]]|\\[\[\]])*)\]\s*TJ',
      caseSensitive: false,
    );

    // Process TJ arrays first (they contain multiple text segments).
    for (final RegExpMatch match in arrayRegex.allMatches(decoded)) {
      final String arrayContent = match.group(1) ?? '';
      final RegExp segmentRegex = RegExp(r'\(((?:[^()\\]|\\.)*)\)');
      for (final RegExpMatch seg in segmentRegex.allMatches(arrayContent)) {
        result.write(_unescape(seg.group(1) ?? ''));
      }
      result.write('\n');
    }

    // Process individual Tj operators.
    for (final RegExpMatch match in textRegex.allMatches(decoded)) {
      result.write(_unescape(match.group(1) ?? ''));
      result.write('\n');
    }

    return result.toString();
  }

  /// Attempts to inflate a FlateDecode stream.
  String _tryInflate(String stream) {
    try {
      // Find the raw compressed data after the stream marker.
      final int streamStart = stream.indexOf('stream');
      if (streamStart < 0) {
        return stream;
      }
      final int dataStart = stream.indexOf('\n', streamStart) + 1;
      final int dataEnd = stream.lastIndexOf('endstream');
      if (dataStart < 0 || dataEnd < 0 || dataEnd <= dataStart) {
        return stream;
      }
      final String rawData = stream.substring(dataStart, dataEnd).trim();
      final Uint8List compressed = base64Decode(
        base64Encode(latin1.encode(rawData)),
      );
      // Use zlib to decompress.
      final List<int> decompressed = _zlibDecompress(compressed);
      return latin1.decode(decompressed);
    } catch (_) {
      return stream;
    }
  }

  /// Simple zlib decompression using dart:io.
  List<int> _zlibDecompress(Uint8List data) {
    // Use dart:io's ZLibCodec for decompression.
    final ZLibCodec codec = ZLibCodec();
    return codec.decode(data);
  }

  /// Unescapes PDF string escapes.
  String _unescape(String input) {
    return input
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t');
  }
}

/// Internal model for a PDF page.
class _PdfPage {
  const _PdfPage({required this.number, required this.contentRef});

  /// 1-based page number.
  final int number;

  /// Object number of the content stream.
  final int contentRef;
}
