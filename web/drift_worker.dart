// Drift web worker entrypoint. Compiled to web/drift_worker.js with:
//   dart compile js -O4 web/drift_worker.dart -o web/drift_worker.js
// Used by WasmDatabase for off-main-thread, persistent storage on web.
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
