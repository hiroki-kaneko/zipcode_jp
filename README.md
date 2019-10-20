zipcode_jp
====

## Description
zipcode_jp is a Japanese zip code library for Dart.

Created from templates made available by Stagehand under a The MIT License
[license](https://opensource.org/licenses/mit-license.php).

Copyright 2019 Hiroki Kaneko

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Usage

A simple usage example:

```dart
import 'package:zipcode_jp/zipcode_jp.dart';

main() {
  var zipJp = new ConvToAddressByJpZip();
  var result = zipJp.getAddressByZipCode("0200802"); // 7 digits
  print(result); // => "岩手県盛岡市つつじが丘"
}
```

## Using Libraries and Data
```
dependencies:
  csv: ^4.0.3
  archive: ^2.0.10
```

The postal code data saved by this project uses a database published by Japan Post.

[Japan Post]: https://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/hiroki-kaneko/zipcode_jp/issues

## License
MIT

## Author
Hiroki Kaneko <kaneko.hiroki@gmail.com>

## Homepage
https://github.com/hiroki-kaneko/zipcode_jp

## Version
0.1