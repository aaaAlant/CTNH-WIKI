import 'package:ctnh_wiki/features/structure_preview/models/structure_block_candidate.dart';
import 'package:flutter/foundation.dart';

class StructureBlockCandidateController extends ChangeNotifier {
  StructureBlockCandidateController({
    Iterable<StructureBlockCandidate> candidates = const [],
    String? initialCandidateId,
  }) {
    _candidates = List<StructureBlockCandidate>.unmodifiable(candidates);
    _selectedCandidateId = _normalizeSelection(
      _candidates,
      initialCandidateId,
    );
  }

  late List<StructureBlockCandidate> _candidates;
  late String? _selectedCandidateId;

  List<StructureBlockCandidate> get candidates => _candidates;
  String? get selectedCandidateId => _selectedCandidateId;

  StructureBlockCandidate? get selectedCandidate {
    final selectedId = _selectedCandidateId;
    if (selectedId == null) {
      return null;
    }
    for (final candidate in _candidates) {
      if (candidate.id == selectedId) {
        return candidate;
      }
    }
    return null;
  }

  void setCandidates(
    Iterable<StructureBlockCandidate> candidates, {
    String? selectedCandidateId,
  }) {
    final nextCandidates = List<StructureBlockCandidate>.unmodifiable(candidates);
    final requestedId = selectedCandidateId ?? _selectedCandidateId;
    final nextSelectedId = nextCandidates.any(
      (candidate) => candidate.id == requestedId,
    )
        ? requestedId
        : null;
    if (_sameCandidates(nextCandidates, _candidates) &&
        nextSelectedId == _selectedCandidateId) {
      return;
    }
    _candidates = nextCandidates;
    _selectedCandidateId = nextSelectedId;
    notifyListeners();
  }

  void selectCandidate(String? candidateId) {
    if (candidateId != null &&
        !_candidates.any((candidate) => candidate.id == candidateId)) {
      return;
    }
    if (_selectedCandidateId == candidateId) {
      return;
    }
    _selectedCandidateId = candidateId;
    notifyListeners();
  }

  bool _sameCandidates(
    List<StructureBlockCandidate> left,
    List<StructureBlockCandidate> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      final leftCandidate = left[index];
      final rightCandidate = right[index];
      if (leftCandidate.id != rightCandidate.id ||
          leftCandidate.blockId != rightCandidate.blockId ||
          leftCandidate.displayName != rightCandidate.displayName ||
          leftCandidate.description != rightCandidate.description ||
          leftCandidate.category != rightCandidate.category ||
          leftCandidate.state != rightCandidate.state ||
          !_sameIds(leftCandidate.partIds, rightCandidate.partIds) ||
          !_sameIds(leftCandidate.tags, rightCandidate.tags)) {
        return false;
      }
    }
    return true;
  }

  static String? _normalizeSelection(
    List<StructureBlockCandidate> candidates,
    String? candidateId,
  ) {
    if (candidateId == null) {
      return null;
    }
    return candidates.any((candidate) => candidate.id == candidateId)
        ? candidateId
        : null;
  }

  bool _sameIds(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}
