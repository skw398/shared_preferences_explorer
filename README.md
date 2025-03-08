# shared_preferences_explorer

A Flutter package for on-screen viewing of shared_preferences.  
Supports `SharedPreferences`, `SharedPreferencesAsync`, and `SharedPreferencesWithCache`.

| <img width="240" src="https://github.com/skw398/shared_preferences_explorer/blob/main/assets/screenshot1.png?raw=true"> | <img width="240" src="https://github.com/skw398/shared_preferences_explorer/blob/main/assets/screenshot2.png?raw=true"> |
| - | - |

## Usage

There are two types of APIs.

### Wrap your app's root widget with `SharedPreferencesExplorer`, and tap the anchor button to open.

If you are using `SharedPreferencesAsync` or `SharedPreferencesWithCache` in your app, use `SharedPreferencesAsyncExplorer` instead.

```dart
void main() {
  runApp(
    SharedPreferencesExplorer(
      // /*Optional*/ instance:
      // /*Optional*/ initialAnchorAlignment: 
      child: YourApp(),
    ),
  );
}
```

- You can optionally provide a `SharedPreferences` instance to the `instance` parameter. If not provided, `SharedPreferences.getInstance()` or `SharedPreferencesAsync()` will be used.

- The anchor button is draggable, and the initial position can be set using `initialAnchorAlignment` parameter.

---

### Or, use `SharedPreferencesExplorerScreen` anywhere in your app.

 Or, use `SharedPreferencesExplorerAsyncScreen` as well.

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (context) =>
        const SharedPreferencesExplorerScreen(
            // /*Optional*/ instance:
            ),
  ),
);
```

## Note
- The cache feature of `SharedPreferencesWithCache` is ignored, and the latest value is always retrieved.
