import 'package:flutter/foundation.dart';
import '../models/child.dart';

/// Manages the application-level state for the currently active child.
///
/// ## Why Provider owns state but Child model does not
/// The [Child] model represents the pure data concept of a registered child
/// (identity, name, birth date, etc). It is stateless and immutable.
/// [ChildProvider] represents the *application's active session state* —
/// "Which child is the user currently looking at or assessing?"
/// By separating the two, we keep UI session logic completely out of our
/// domain data models.
///
/// ## Responsibilities
/// - Hold the currently selected [Child].
/// - Expose methods to update or clear the active child.
/// - Notify the UI whenever the child context changes.
///
/// ## Future scope (Phase 4+)
/// - Integration with a database/repository to fetch or persist the child.
/// - For Phase 3, this remains an in-memory session wrapper.
class ChildProvider extends ChangeNotifier {
  Child? _currentChild;

  /// The currently active child, or null if none is selected.
  Child? get currentChild => _currentChild;

  /// True if a child is currently selected.
  bool get hasChild => _currentChild != null;

  /// Sets the active child and notifies listeners to rebuild dependent UI.
  void setChild(Child child) {
    if (_currentChild != child) {
      _currentChild = child;
      notifyListeners();
    }
  }

  /// Updates the currently active child, typically used when editing details
  /// (e.g., updating weight/height via [Child.copyWith]).
  void updateChild(Child updatedChild) {
    if (_currentChild?.id == updatedChild.id) {
      _currentChild = updatedChild;
      notifyListeners();
    }
  }

  /// Clears the active child context, returning the app to a "no child selected" state.
  void clearChild() {
    if (_currentChild != null) {
      _currentChild = null;
      notifyListeners();
    }
  }
}
