# shared_preferences_explorer

On-screen viewing and editing of shared_preferences

![](https://github.com/skw398/shared_preferences_explorer/blob/main/assets/screenshots.png?raw=true)

## Usage

Wrap your root widget with `SharedPreferencesExplorer`.

Then tap the button, set by default to the `Alignment.bottomLeft`, to open.

```dart
void main() {
  runApp(
    SharedPreferencesExplorer(
      // anchorAlignment: Alignment.bottomLeft,
      // colorSchemeSeed: Colors.lightGreen,
      child: YourApp(),
    ),
  );
}
```

Or, directly displays if `child` is null.

```dart
void main() {
  runApp(
    const SharedPreferencesExplorer(),
    // YourApp(),
  );
}
```

## Note

* The timing of updates on your app's display after editing still depends on the implementation of your code.
* Make sure not to set `double` for keys treated as `int` in your code, because this package does not distinguish between `int` and `double`.
  * *Under the shared_preferences specification, it is not possible to distinguish whether an integer values were saved as `int` or `double`. Iinteger values can be retrieved using any of `get`, `getInt` or `getDouble`, no matter which method was used to save them.*
* Throws an exception if `SharedPreferencesExplorer` is included in release mode.
