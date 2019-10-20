import 'package:zipcode_jp/zipcode_jp.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    ConvToAddressByJpZip awesome;

    setUp(() {
      awesome = ConvToAddressByJpZip();
    });

    test('that it returnes 7 digits address', () async {
      var value = await awesome.getAddressByZipCode("2510015");
      expect(value, equals("神奈川県藤沢市川名"));
    });

    test('87で始まる郵便番号は福岡県と大分県のCSVを読むcase1', () async {
      var value = await awesome.getAddressByZipCode("8710822");
      expect(value, equals("福岡県築上郡吉富町今吉"));
    });

    test('87で始まる郵便番号は福岡県と大分県のCSVを読むcase2', () async {
      var value = await awesome.getAddressByZipCode("8701115");
      expect(value, equals("大分県大分市ひばりケ丘"));
    });

    test('福岡県のみ存在する郵便番号で福岡県と大分県のCSVを読む', () async {
      var value = await awesome.getAddressByZipCode("8391402");
      expect(value, equals("福岡県うきは市浮羽町浮羽"));
    });

    test('isInHokkaido?', () {
      var value = awesome.getPrefCode("0000000");
      expect(value, equals(1));
    });

    test('isChiba?', () {
      var value = awesome.getPrefCode("2900000");
      expect(value, equals(12));
    });

    test('are Niigata, Gunma, and Saitama?', () {
      var value = awesome.getDuplicatePrefCodes("3800000");
      expect(value, equals([15, 10, 11]));
    });
  });
}
