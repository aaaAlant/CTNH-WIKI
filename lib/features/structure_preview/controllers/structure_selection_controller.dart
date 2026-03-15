import 'package:flutter/foundation.dart';

class StructureSelectionController extends ChangeNotifier {
  StructureSelectionController({String? initialPartId})
    : _selectedPartId = initialPartId;

  String? _selectedPartId;

  String? get selectedPartId => _selectedPartId;

  void selectPart(String? partId) {
    if (_selectedPartId == partId) {
      return;
    }
    _selectedPartId = partId;
    notifyListeners();
  }
}
