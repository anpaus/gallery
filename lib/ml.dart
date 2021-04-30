@JS()
library ml.js;

import 'package:js/js.dart';

@JS('console.log') // annotates `log` function to call `console.log`
external void log(dynamic str);

@JS('runPrediction')
external num runPrediction();

@JS('myFunction')
external void myFunction();

@JS('classifyImage')
external List<Object> imageClassifier();

@JS()
@anonymous
class ImageResults {
  external factory ImageResults({
    String className,
    num probability,
  });

  external String get className;
  external num get probability;
}

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('JSON.parse')
external ImageResults jsonObject(String str);