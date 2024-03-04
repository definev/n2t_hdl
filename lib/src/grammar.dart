import 'package:petitparser/petitparser.dart';

class HDLGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(module).end();

  Parser module() => ref0(chipDefinition).star();

  Parser chipToken() => ref1(tokenizer, 'CHIP');
  Parser inToken() => ref1(tokenizer, 'IN');
  Parser outToken() => ref1(tokenizer, 'OUT');
  Parser partToken() => ref1(tokenizer, 'PARTS');
  Parser builtinToken() => ref1(tokenizer, 'BUILTIN');

  Parser chipDefinition() => (ref0(chipToken) & //
          ref0(identifier) &
          ref1(tokenizer, '{') &
          ref0(chipBody) &
          ref1(tokenizer, '}'))
      .permute([0, 1, 3]);

  Parser chipBody() =>
      ref0(inputDeclaration) & //
      ref0(outputDeclaration) &
      (ref0(partDeclaration) | ref0(builtinDeclaration)).optional();

  Parser inputDeclaration() => (ref0(inToken) & ref0(variables) & ref1(tokenizer, ';')).permute([0, 1]);
  Parser outputDeclaration() => (ref0(outToken) & ref0(variables) & ref1(tokenizer, ';')).permute([0, 1]);
  Parser builtinDeclaration() => (ref0(builtinToken) & ref0(identifier) & ref1(tokenizer, ';')).permute([0, 1]);

  Parser partDeclaration() => (ref0(partToken) & ref1(tokenizer, ':') & ref0(chipCallable).star()).permute([0, 2]);
  Parser chipCallable() => (ref0(identifier) &
          (ref1(tokenizer, '(') & ref0(chipVariables) & ref1(tokenizer, ')')).pick(1) &
          ref1(tokenizer, ';'))
      .permute([0, 1]);

  Parser chipVariables() => ref2(separateBy, ref0(chipVariable), ',');
  Parser chipVariable() => ((ref0(arrayRangeAccess) | ref0(arrayAccess) | ref0(identifier)) &
          ref1(tokenizer, '=') &
          (ref0(boolean) | ref0(identifier)))
      .permute([0, 2]);

  Parser variables() => ref2(separateBy, ref0(arrayAccess) | ref0(identifier), ',');
  Parser arrayAccess() =>
      (ref0(identifier) & ref1(tokenizer, '[') & ref0(number) & ref1(tokenizer, ']')).permute([0, 2]);
  Parser arrayRangeAccess() => (ref0(identifier) &
          ref1(tokenizer, '[') &
          ref0(number) &
          ref1(tokenizer, '..') &
          ref0(number) &
          ref1(tokenizer, ']'))
      .permute([0, 2, 4]);

  Parser number() => digit().plus().flatten();
  Parser boolean() => ref1(tokenizer, 'true') | ref1(tokenizer, 'false');

  Parser separateBy(Parser parser, String char) => (parser & ref1(tokenizer, char).optional()).pick(0).star();

  Parser identifier() => (ref0(startIdentifier) & ref0(identifierPart).star()).flatten();
  Parser startIdentifier() => letter() | char('_') | char('\$');
  Parser identifierPart() => ref0(startIdentifier) | digit();

  Parser newLine() => pattern('\n\r');

  Parser hiddens() => ref0(hidden).plus();
  Parser hidden() => ref0(singleLineComment) | ref0(multiLineComment) | ref0(whitespace);
  Parser singleLineComment() => string('//') & ref0(newLine).neg().star() & ref0(newLine).optional();
  Parser multiLineComment() => string('/*') & (ref0(multiLineComment) | string('*/').neg()).star() & string('*/');

  Parser tokenizer(Object source) {
    if (source is String) {
      return tokenizer(string(source).token());
    } else if (source is Parser) {
      return source.trim(ref0(hiddens));
    }

    throw ArgumentError('Unsupported source: $source');
  }
}
