# shared_preferences_explorer

A Flutter package for on-screen viewing of shared_preferences.  
Supports `SharedPreferences`, `SharedPreferencesAsync`, and `SharedPreferencesWithCache`.

| <img width="240" src="https://github.com/skw398/shared_preferences_explorer/blob/main/assets/screenshot1.png?raw=true"> | <img width="240" src="https://github.com/skw398/shared_preferences_explorer/blob/main/assets/screenshot2.png?raw=true"> |
| - | - |

## Usage

Wrap your app's root widget with `SharedPreferencesExplorer`, and tap the anchor button to open.  
The anchor button is draggable, and the initial position can be set using `initialAnchorAlignment`.

```dart
void main() {
  runApp(
    SharedPreferencesExplorer(
      // initialAnchorAlignment: AnchorAlignment.bottomLeft,
      child: YourApp(),
    ),
  );
}
```

Or, use `SharedPreferencesExplorerScreen` in your app's debug menu, etc.

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (context) => const SharedPreferencesExplorerScreen(),
  ),
);
```
