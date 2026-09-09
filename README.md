# 🇨🇺 adaptive_liquid_glass

[![CI](https://github.com/ledexsoft/adaptive_liquid_glass/workflows/CI/badge.svg)](https://github.com/ledexsoft/adaptive_liquid_glass/actions)
[![Release](https://github.com/ledexsoft/adaptive_liquid_glass/workflows/Release/badge.svg)](https://github.com/ledexsoft/adaptive_liquid_glass/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

**Widgets adaptativos por plataforma para Flutter, listos para usar.**

Escribe tu app **una sola vez** y los componentes (botones, menús, alertas, barras de navegación…) se ven y se sienten **nativos** en cada sistema:

| Plataforma | Qué usan tus widgets |
|---|---|
| 📱 **iOS 26 o superior** | Componentes **nativos de UIKit** con el nuevo diseño **Liquid Glass** (el vidrio translúcido de Apple) |
| 🍎 **iOS 25 o anterior** | Widgets **Cupertino** tradicionales de Flutter |
| 🤖 **Android** | Widgets **Material 3** |

**Sin configurar nada.** El paquete detecta el dispositivo solito y elige el estilo correcto.

---

## 📖 Antes de empezar: 3 conceptos en 1 minuto

1. **Widget** = cada pieza visual de tu app (un botón, un switch, una tarjeta).
2. **Nativo** = el elemento lo dibuja el propio sistema operativo (UIKit en iOS), no Flutter. Por eso se ve y se siente idéntico a las apps de Apple: mismos efectos, mismos haptics, misma tipografía.
3. **Liquid Glass** = el nuevo lenguaje visual de iOS 26: superficies de vidrio translúcido que refractan y difuminan lo que hay detrás. Este paquete lo activa con las APIs públicas de UIKit (`UIButton.Configuration.prominentGlass()`, `UIGlassContainerEffect`, etc.).

> 💡 **La idea del paquete en una frase:** tú escribes `AdaptiveButton`, y en iOS 26 aparece un UIButton real de Apple con vidrio, en Android aparece un botón Material, y en iOS viejo un botón Cupertino. Siempre el correcto, nunca lo piensas.

---

## 📸 Así se ve

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/appbar.gif" alt="Toolbar nativa iOS 26" width="300"/>
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/bottombar.gif" alt="Tab bar nativa iOS 26" width="300"/>
</p>

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/highlight-img.png?raw=true" alt="Toolbar nativa de iOS 26">

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/bottom_nav2_p.png?raw=true" alt="Tab bar nativa iOS 26">

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/toolbar2_p.png?raw=true" alt="Toolbar nativa iOS 26">

![native_search](https://github.com/user-attachments/assets/da33cb62-94d7-47da-8f0c-327bbd6ee04e)

---

## ✅ Requisitos

- Tener **Flutter** instalado (`flutter --version` en una terminal debe responder).
- Saber crear un proyecto (`flutter create mi_app`).
- Nada más. No necesitas saber nada de Swift, Kotlin ni UIKit.

---

## 📦 Paso 1: Instalar el paquete

El paquete se instala **directamente desde este repositorio de GitHub**:

1. Abre el archivo `pubspec.yaml` de tu proyecto.
2. Debajo de `dependencies:` agrega:

```yaml
dependencies:
  adaptive_liquid_glass:
    git:
      url: https://github.com/ledexsoft/adaptive_liquid_glass.git
      ref: v0.1.125
```

3. En la terminal, dentro de la carpeta de tu proyecto:

```bash
flutter pub get
```

> 💡 **¿Qué es el `ref`?** Apunta a un **tag** del repositorio (versión congelada). Cada versión nueva del paquete publica su tag (`v0.1.121`, `v0.1.125`…). Así tu app nunca cambia sin que tú lo decidas: actualizas solo cuando cambias ese número.
>
> 🔎 Puedes ver todas las versiones disponibles en: https://github.com/ledexsoft/adaptive_liquid_glass/tags

---

## 🚀 Paso 2: Tu primera app en 5 minutos

1. Crea el proyecto:

```bash
flutter create mi_app
cd mi_app
flutter pub add adaptive_liquid_glass
```

2. Reemplaza todo el contenido de `lib/main.dart` con esto:

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AdaptiveApp = el "andamio" que configura temas nativos por plataforma.
    return AdaptiveApp(
      title: 'Mi App',
      themeMode: ThemeMode.system,
      materialLightTheme: ThemeData.light(),
      materialDarkTheme: ThemeData.dark(),
      cupertinoLightTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      cupertinoDarkTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: const Inicio(),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    // AdaptiveScaffold = la estructura de la pantalla (barra superior + cuerpo).
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Mi App',
        useNativeToolbar: true, // Barra nativa de iOS 26 con Liquid Glass
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Un botón: nativo en cada plataforma, sin configurar nada.
            AdaptiveButton(
              onPressed: () {},
              label: 'Mi primer botón',
            ),
            const SizedBox(height: 16),
            AdaptiveSwitch(
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
```

3. Ejecuta:

```bash
flutter run
```

🎉 Listo. En un iPhone con iOS 26 verás la barra y el botón con Liquid Glass reales; en Android, Material 3; en iOS viejo, Cupertino. **El mismo código.**

### ¿Y si uso un router (GoRouter)?

```dart
AdaptiveApp.router(
  routerConfig: router,
  title: 'Mi App',
  themeMode: ThemeMode.system,
  materialLightTheme: ThemeData.light(),
  materialDarkTheme: ThemeData.dark(),
  cupertinoLightTheme: const CupertinoThemeData(
    brightness: Brightness.light,
  ),
  cupertinoDarkTheme: const CupertinoThemeData(
    brightness: Brightness.dark,
  ),
)
```

---

## 🔘 Los botones en iOS 26: cómo se comportan

En iOS 26+ los botones usan **Liquid Glass nativo**. Cada estilo conserva su **jerarquía** y **su propio color** (el vidrio se tiñe con el `color:` que le pases; si no le pasas color, usa el color primario de tu tema):

| Estilo | Para qué sirve | En iOS 26+ se ve como |
|---|---|---|
| `filled` | **Acción primaria** (lo más importante de la pantalla) | Cápsula de vidrio **prominente** |
| `tinted` | **Acción secundaria** común | Cápsula de vidrio **prominente** con su color |
| `bordered` | Botón con borde | Cápsula de vidrio **prominente** con su color |
| `gray` | Acción neutra | Vidrio **discreto** (más sutil) |
| `glass` | Vidrio explícito | Vidrio discreto |
| `plain` | Solo texto, sin fondo | Texto sin fondo |

**En iOS 25 o anterior** los mismos estilos caen automáticamente a sus equivalentes Cupertino. **En Android** son botones Material normales.

```dart
// Acción primaria — glass prominente en iOS 26+
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.filled,
  label: 'Guardar',
)

// Secundaria — glass prominente con SU color (no el primario)
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.tinted,
  color: Colors.green, // verde, no azul
  label: 'Confirmar',
)

// Sin fondo (texto)
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.plain,
  label: 'Cancelar',
)
```

### Tamaños

```dart
AdaptiveButton(onPressed: () {}, size: AdaptiveButtonSize.small, label: 'Small');  // 28pt
AdaptiveButton(onPressed: () {}, size: AdaptiveButtonSize.medium, label: 'Medium'); // 36pt (default)
AdaptiveButton(onPressed: () {}, size: AdaptiveButtonSize.large, label: 'Large');   // 44pt
```

### Estilos personalizados y deshabilitado

```dart
AdaptiveButton(
  onPressed: () {},
  label: 'Personalizado',
  color: Colors.red,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  borderRadius: BorderRadius.circular(16),
  minSize: Size(200, 50),
)

AdaptiveButton(
  onPressed: () {},
  label: 'Deshabilitado',
  enabled: false,
)
```

---

## 🧰 Galería de widgets

Todos los widgets siguen el mismo patrón: **un solo nombre, tres aspectos nativos**.

### Importante: localización

⚠️ Para que los date/time pickers y diálogos salgan en el idioma del usuario, agrega los delegates a tu `AdaptiveApp`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

AdaptiveApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate, // ¡Importante!
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('es', ''), // Español
    Locale('en', ''),
    // Agrega los que necesites
  ],
)
```

### AdaptiveScaffold + AdaptiveAppBar (la estructura de cada pantalla)

<img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/toolbar_p.png?raw=true" alt="Toolbar nativa iOS 26">

```dart
AdaptiveScaffold(
  appBar: AdaptiveAppBar(
    title: 'Mi App',
    useNativeToolbar: true, // UIToolbar nativa de iOS 26 con Liquid Glass
    actions: [
      AdaptiveAppBarAction(
        onPressed: () {},
        iosSymbol: 'gear', // SF Symbol en iOS 26+
        icon: Icons.settings, // Fallback para otras plataformas
      ),
    ],
  ),
  bottomNavigationBar: AdaptiveBottomNavigationBar(
    useNativeBottomBar: true, // UITabBar nativa de iOS 26 (default)
    items: [
      AdaptiveNavigationDestination(icon: 'house.fill', label: 'Inicio'),
      AdaptiveNavigationDestination(icon: 'person.fill', label: 'Perfil'),
    ],
    selectedIndex: 0,
    onTap: (index) {},
  ),
  body: TuContenido(),
)
```

**Características clave:**
- 🎨 **AdaptiveAppBar**: configuración centralizada de la barra superior
- 📱 **AdaptiveBottomNavigationBar**: navegación inferior centralizada
- 🌟 **Componentes nativos de iOS 26**: Liquid Glass con UIKit real
- 🔄 **Flexible**: si pasas algo en null, simplemente no se muestra

Bottom Navigation Bar adaptativa:
<p align="center">
  <img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/bottom_nav_p.png" alt="Toolbar nativa"/>
</p>

### AdaptiveAlertDialog (diálogos de alerta)

<img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/alert_p.png" alt="Alerta nativa iOS 26">

```dart
AdaptiveAlertDialog.show(
  context: context,
  title: 'Confirmar',
  message: '¿Seguro que quieres continuar?',
  icon: 'checkmark.circle.fill',
  actions: [
    AlertAction(
      title: 'Cancelar',
      style: AlertActionStyle.cancel,
      onPressed: () {},
    ),
    AlertAction(
      title: 'Confirmar',
      style: AlertActionStyle.primary,
      onPressed: () {},
    ),
  ],
);

// Con campo de texto: el resultado es lo que escribió el usuario
final result = await AdaptiveAlertDialog.show(
  context: context,
  title: 'Tu nombre',
  message: 'Escríbelo aquí',
  icon: 'person.fill',
  input: AdaptiveAlertDialogInput(
    placeholder: 'Nombre',
    keyboardType: TextInputType.text,
  ),
  actions: [
    AlertAction(title: 'Cancelar', style: AlertActionStyle.cancel, onPressed: () {}),
    AlertAction(title: 'Enviar', style: AlertActionStyle.primary, onPressed: () {}),
  ],
);
if (result != null) {
  print('Escribió: $result');
}
```

### AdaptiveContextMenu (menú de presión larga)

```dart
AdaptiveContextMenu(
  actions: [
    AdaptiveContextMenuAction(
      title: 'Editar',
      icon: PlatformInfo.isIOS ? CupertinoIcons.pencil : Icons.edit,
      onPressed: () {},
    ),
    AdaptiveContextMenuAction(
      title: 'Eliminar',
      icon: PlatformInfo.isIOS ? CupertinoIcons.trash : Icons.delete,
      isDestructive: true,
      onPressed: () {},
    ),
  ],
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Mantén presionado'),
  ),
)
```

**iOS**: `CupertinoContextMenu` con preview y animaciones nativas. **Android**: `PopupMenuButton` de Material.

### AdaptivePopupMenuButton (menú popup)

<p align="center">
<img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/popup_p.png" alt="Popup nativo iOS 26">
</p>

```dart
AdaptivePopupMenuButton.text<String>(
  label: 'Opciones',
  items: [
    AdaptivePopupMenuItem(
      label: 'Editar',
      icon: PlatformInfo.isIOS26OrHigher() ? 'pencil' : Icons.edit,
      value: 'edit',
    ),
    AdaptivePopupMenuItem(
      label: 'Eliminar',
      icon: PlatformInfo.isIOS26OrHigher() ? 'trash' : Icons.delete,
      value: 'delete',
    ),
  ],
  onSelected: (index, item) {
    print('Seleccionó: ${item.value}');
  },
)
```

### AdaptiveSegmentedControl (control segmentado)

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/segmented_control.gif" alt="Segmented Control" width="300"/>
</p>

```dart
AdaptiveSegmentedControl(
  labels: ['Uno', 'Dos', 'Tres'],
  selectedIndex: 0,
  onValueChanged: (index) {
    print('Seleccionó: $index');
  },
)

// Con SF Symbols en iOS
AdaptiveSegmentedControl(
  labels: [],
  sfSymbols: ['house.fill', 'person.fill', 'gear'],
  selectedIndex: 0,
  onValueChanged: (index) {},
)
```

### AdaptiveSwitch y AdaptiveSlider

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/switch.gif" alt="Adaptive Switch" width="300"/>
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/slider.gif" alt="Adaptive Slider" width="300"/>
</p>

```dart
AdaptiveSwitch(
  value: true,
  onChanged: (value) {
    print('Switch: $value');
  },
)

AdaptiveSlider(
  value: 0.5,
  onChanged: (value) {
    print('Slider: $value');
  },
  min: 0.0,
  max: 1.0,
)
```

### AdaptiveCheckbox y AdaptiveRadio

```dart
AdaptiveCheckbox(
  value: true,
  onChanged: (value) {
    print('Checkbox: $value');
  },
)

// Tristate: true, false o null
AdaptiveCheckbox(
  value: null,
  tristate: true,
  onChanged: (value) {},
)

// Radio buttons
enum Options { opcion1, opcion2, opcion3 }
Options? _seleccion = Options.opcion1;

AdaptiveRadio<Options>(
  value: Options.opcion1,
  groupValue: _seleccion,
  onChanged: (Options? value) {
    setState(() {
      _seleccion = value;
    });
  },
)
```

### AdaptiveCard (tarjetas)

```dart
AdaptiveCard(
  padding: EdgeInsets.all(16),
  child: Text('Contenido de la tarjeta'),
)

// Con estilo personalizado
AdaptiveCard(
  padding: EdgeInsets.all(16),
  color: Colors.blue.withValues(alpha: 0.1),
  borderRadius: BorderRadius.circular(20),
  elevation: 8, // Solo Android
  child: Column(
    children: [
      Text('Tarjeta personalizada'),
      Text('Con varios elementos'),
    ],
  ),
)
```

### AdaptiveBadge (insignias de notificación)

```dart
AdaptiveBadge(
  count: 5,
  child: Icon(Icons.notifications),
)

AdaptiveBadge(
  label: 'NUEVO',
  backgroundColor: Colors.red,
  child: Icon(Icons.mail),
)
```

### AdaptiveTooltip

```dart
AdaptiveTooltip(
  message: 'Este es un tooltip',
  child: Icon(Icons.info),
)

// Que aparezca arriba en vez de abajo
AdaptiveTooltip(
  message: 'Tooltip arriba',
  preferBelow: false,
  child: Icon(Icons.help),
)
```

### AdaptiveSnackBar (mensajes tipo notificación)

```dart
// Básico
AdaptiveSnackBar.show(
  context,
  message: '¡Operación completada!',
  type: AdaptiveSnackBarType.success,
)

// Con botón de acción
AdaptiveSnackBar.show(
  context,
  message: 'Archivo eliminado',
  type: AdaptiveSnackBarType.info,
  action: 'Deshacer',
  onActionPressed: () {
    // Deshacer
  },
)

// Tipos disponibles
AdaptiveSnackBar.show(context, message: 'Info', type: AdaptiveSnackBarType.info);
AdaptiveSnackBar.show(context, message: 'Éxito', type: AdaptiveSnackBarType.success);
AdaptiveSnackBar.show(context, message: 'Advertencia', type: AdaptiveSnackBarType.warning);
AdaptiveSnackBar.show(context, message: 'Error', type: AdaptiveSnackBarType.error);
```

**iOS**: banner arriba con animaciones y descarte al tocar. **Android**: Material SnackBar abajo.

### AdaptiveDatePicker y AdaptiveTimePicker (fechas y horas)

```dart
// Fecha
final fecha = await AdaptiveDatePicker.show(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

// Hora (formato 24h)
final hora = await AdaptiveTimePicker.show(
  context: context,
  initialTime: TimeOfDay.now(),
  use24HourFormat: true,
);

if (fecha != null) {
  print('Fecha: $fecha');
}
```

**iOS**: `CupertinoDatePicker` en un bottom sheet con Cancelar/Listo. **Android**: diálogos de Material.

### AdaptiveListTile (filas de lista)

```dart
AdaptiveListTile(
  leading: Icon(Icons.person),
  title: Text('Perfil'),
  subtitle: Text('Ver tu perfil'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    // Manejar tap
  },
)

// Con switch integrado
AdaptiveListTile(
  title: Text('Activar función'),
  trailing: AdaptiveSwitch(
    value: switchValue,
    onChanged: (value) {},
  ),
)
```

### AdaptiveTextField y AdaptiveTextFormField (texto y formularios)

```dart
// Campo de texto básico
AdaptiveTextField(
  placeholder: 'Ingresa tu nombre',
  onChanged: (value) {
    print('Texto: $value');
  },
)

// Contraseña
AdaptiveTextField(
  placeholder: 'Contraseña',
  obscureText: true,
  prefixIcon: Icon(
    PlatformInfo.isIOS ? CupertinoIcons.lock : Icons.lock,
  ),
)

// Campo de formulario con validación
AdaptiveTextFormField(
  placeholder: 'Email',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu email';
    }
    if (!value.contains('@')) {
      return 'Email no válido';
    }
    return null;
  },
  onSaved: (value) => _email = value,
)
```

### AdaptiveFloatingActionButton (botón flotante)

```dart
AdaptiveFloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)

AdaptiveFloatingActionButton(
  onPressed: () {},
  mini: true,
  child: Icon(Icons.edit),
)
```

### AdaptiveFormSection y AdaptiveExpansionTile (formularios agrupados y acordeones)

```dart
// Sección agrupada (estilo Ajustes de iOS)
AdaptiveFormSection.insetGrouped(
  header: Text('Ajustes'),
  children: [
    CupertinoFormRow(
      prefix: Text('Notificaciones'),
      child: AdaptiveSwitch(value: true, onChanged: (v) {}),
    ),
  ],
)

// Acordeón expandible
AdaptiveExpansionTile(
  leading: Icon(Icons.settings),
  title: Text('Ajustes avanzados'),
  subtitle: Text('Toca para expandir'),
  children: [
    ListTile(title: Text('Opción 1')),
    ListTile(title: Text('Opción 2')),
  ],
)
```

### AdaptiveTabBarView (tabs deslizables)

```dart
AdaptiveTabBarView(
  tabs: ['Recientes', 'Populares', 'Tendencias'],
  children: [
    RecientesPage(),
    PopularesPage(),
    TendenciasPage(),
  ],
  onTabChanged: (index) {
    print('Tab: $index');
  },
)
```

---

## 🔍 Detectar plataforma y versión de iOS

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

if (PlatformInfo.isIOS) {
  print('Estamos en iOS');
}

if (PlatformInfo.isAndroid) {
  print('Estamos en Android');
}

// ¿iOS 26 o superior? (Liquid Glass disponible)
if (PlatformInfo.isIOS26OrHigher()) {
  print('Usando funciones de iOS 26+');
}

// ¿Versión vieja? (widgets Cupertino)
if (PlatformInfo.isIOS18OrLower()) {
  print('Usando widgets legacy');
}

// Número de versión y rangos
int version = PlatformInfo.iOSVersion; // ej. 26
if (PlatformInfo.isIOSVersionInRange(24, 26)) {
  print('Entre iOS 24 y 26');
}

String descripcion = PlatformInfo.platformDescription; // ej. "iOS 26"
```

---

## 🛠️ Cómo funciona por dentro (para los curiosos)

- En **iOS 26+**, los widgets se renderizan con **platform views nativas** (`UiKitView`): son componentes reales de UIKit incrustados en Flutter, comunicados por platform channels. El Liquid Glass lo dibuja UIKit, no Flutter.
- En **iOS 25-**, se usan widgets Cupertino tradicionales (el paquete **no obliga** a subir el deployment target de tu app a iOS 26).
- En **Android**, Material 3 puro.
- **Agrupación de vidrio**: superficies nativas cercanas pueden fundirse en sus bordes con `UIGlassContainerEffect`, pero solo si viven dentro de la misma platform view; UIKit no puede fusionar platform views separadas de Flutter.

---

## ⚠️ IOS26NativeSearchTabBar (EXPERIMENTAL — no la uses en producción)

(No confundir con `AdaptiveBottomNavigationBar`.)

Search tab bar nativa de iOS 26+ con UITabBarController que transforma la tab en una barra de búsqueda al seleccionarla:

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

await IOS26NativeSearchTabBar.enable(
  tabs: [
    const NativeTabConfig(title: 'Home', sfSymbol: 'house.fill'),
    const NativeTabConfig(
      title: 'Search',
      sfSymbol: 'magnifyingglass',
      isSearchTab: true, // Esta tab se transforma en búsqueda
    ),
    const NativeTabConfig(title: 'Profile', sfSymbol: 'person.fill'),
  ],
  selectedIndex: 0,
  onTabSelected: (index) {},
  onSearchQueryChanged: (query) {},
  onSearchSubmitted: (query) {},
  onSearchCancelled: () {},
);

// Desactivar al terminar
await IOS26NativeSearchTabBar.disable();
```

**¿Por qué es experimental?** Reemplaza el root view controller de Flutter por una UITabBarController nativa, y eso choca con la arquitectura de Flutter: el ciclo de vida de los widgets puede fallar, `Navigator.pop()` se vuelve poco confiable, el estado (Provider/Riverpod/Bloc) puede perderse, el hot reload no funciona y puede haber fugas de memoria.

**En resumen:** ✅ para prototipos y demos. ❌ para producción.

---

## 📋 Catálogo completo

- ✅ **AdaptiveApp** — Configuración de la app por plataforma (temas + router)
- ✅ **AdaptiveAppBar** — Barra superior centralizada
- ✅ **AdaptiveBottomNavigationBar** — Navegación inferior centralizada
- ✅ **AdaptiveScaffold** — Estructura de pantalla con toolbar/tab bar nativas opcionales
- ✅ **AdaptiveButton** — Botones nativos de iOS 26+
- ✅ **AdaptiveSegmentedControl** — Controles segmentados nativos
- ✅ **AdaptiveSwitch** — Switches nativos
- ✅ **AdaptiveSlider** — Sliders nativos
- ✅ **AdaptiveCheckbox** — Checkboxes adaptativos
- ✅ **AdaptiveRadio** — Radio buttons adaptativos
- ✅ **AdaptiveCard** — Tarjetas por plataforma
- ✅ **AdaptiveBadge** — Insignias de notificación
- ✅ **AdaptiveTooltip** — Tooltips por plataforma
- ✅ **AdaptiveSnackBar** — Notificaciones por plataforma
- ✅ **AdaptiveAlertDialog** — Alertas nativas con campo de texto
- ✅ **AdaptiveContextMenu** — Menús contextuales de presión larga
- ✅ **AdaptivePopupMenuButton** — Menús popup nativos
- ✅ **AdaptiveDatePicker** — Selector de fechas por plataforma
- ✅ **AdaptiveTimePicker** — Selector de horas por plataforma
- ✅ **AdaptiveListTile** — Tiles de lista por plataforma
- ✅ **AdaptiveTextField** — Campos de texto por plataforma
- ✅ **AdaptiveTextFormField** — Campos de formulario con validación
- ✅ **AdaptiveFloatingActionButton** — Botones flotantes por plataforma
- ✅ **AdaptiveFormSection** — Secciones de formulario agrupadas
- ✅ **AdaptiveExpansionTile** — Acordeones modernos
- ✅ **AdaptiveTabBarView** — Tabs deslizables horizontales
- ⚠️ **IOS26NativeSearchTabBar** — EXPERIMENTAL (solo iOS 26+)

---

## 📱 Descarga la app de ejemplo (APK)

No hace falta compilar nada: descarga el APK listo para instalar en cualquier Android 6.0+:

- 📲 **[Descargar APK (última versión)](https://github.com/ledexsoft/adaptive_liquid_glass/releases/latest)** — siempre apunta al build más reciente
- 📦 [Ver todas las versiones del APK](https://github.com/ledexsoft/adaptive_liquid_glass/releases)

> El APK se recompila automáticamente con GitHub Actions cada vez que se actualiza el paquete.

---

## 🧪 App de ejemplo (compilar tú mismo)

Para ver todo en vivo desde el código:

```bash
git clone https://github.com/ledexsoft/adaptive_liquid_glass.git
cd adaptive_liquid_glass/example
flutter run
```

Incluye muestra de todos los widgets, demos interactivos, comparaciones de estilos y modo oscuro.

---

## 💡 Filosofía del paquete

1. **Look & feel nativo**: que cada widget se sienta de la casa en su plataforma.
2. **Cero configuración**: detección automática de plataforma y versión.
3. **Conciencia de versión**: aprovechar lo nuevo (Liquid Glass) sin romper lo viejo.
4. **Consistencia**: una sola API para todas las plataformas.
5. **Personalización**: overrides cuando los necesites.

## 📱 Soporte de versiones

- **iOS 26+**: diseños nativos con Liquid Glass
- **iOS 18 o inferior**: widgets Cupertino tradicionales
- **Fallback automático**: degradación transparente

## 🤝 Contribuir

¡Contribuciones bienvenidas! Abre un [Issue](https://github.com/ledexsoft/adaptive_liquid_glass/issues) o envía un Pull Request.

## 📄 Licencia

Licencia MIT — consulta el archivo [LICENSE](LICENSE).

## ❤️ Créditos

- Inspirado en cupertino_native
- Human Interface Guidelines de Apple
- Material Design de Google

<a href="https://github.com/ledexsoft/adaptive_liquid_glass/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ledexsoft/adaptive_liquid_glass" />
</a>

## 💬 Soporte

- 💬 **[Discussions](https://github.com/ledexsoft/adaptive_liquid_glass/discussions)** — Preguntas, ideas y proyectos
- 🐛 **[Issues](https://github.com/ledexsoft/adaptive_liquid_glass/issues)** — Bugs y solicitudes
- 📖 **[Guía de contribución](.github/CONTRIBUTING.md)** — Cómo contribuir
