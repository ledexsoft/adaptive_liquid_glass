# adaptive_liquid_glass

[![CI](https://github.com/ledexsoft/adaptive_liquid_glass/workflows/CI/badge.svg)](https://github.com/ledexsoft/adaptive_liquid_glass/actions)
[![Release](https://github.com/ledexsoft/adaptive_liquid_glass/workflows/Release/badge.svg)](https://github.com/ledexsoft/adaptive_liquid_glass/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

Paquete de Flutter con widgets adaptativos por plataforma: **diseños nativos de iOS 26+ con Liquid Glass**, widgets Cupertino tradicionales para versiones anteriores de iOS y Material Design para Android.

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/highlight-img.png?raw=true" alt="Toolbar nativa de iOS 26">

## Toolbar y Tab Bar nativas de iOS 26+

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/appbar.gif" alt="Toolbar nativa iOS 26" width="300"/>
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/bottombar.gif" alt="Tab bar nativa iOS 26" width="300"/>
</p>

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/bottom_nav2_p.png?raw=true" alt="Tab bar nativa iOS 26">

  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/toolbar2_p.png?raw=true" alt="Toolbar nativa iOS 26">

![native_search](https://github.com/user-attachments/assets/da33cb62-94d7-47da-8f0c-327bbd6ee04e)

UIToolbar y UITabBar nativas de iOS 26 con efectos de blur Liquid Glass, comportamiento *minimize* y manejo nativo de gestos.

## Características

**AdaptiveApp** — Configuración unificada de la app para todas las plataformas:
- Temas separados para Material (Android) y Cupertino (iOS)
- Soporte completo de modos de tema (claro, oscuro, sistema)
- Soporte de routers vía `AdaptiveApp.router()`
- Cero configuración requerida

**Diseños nativos de iOS 26+** — Componentes modernos con:
- **UIToolbar nativa** — Efectos de blur Liquid Glass con diseño nativo de iOS 26
- **UITabBar nativa** — Tab bar con *minimize behavior* y animaciones suaves
- **UIButton nativo** — Estilos de botón con animaciones de resorte y haptics
- **UISegmentedControl nativo** — Controles segmentados con soporte de SF Symbols
- **UISwitch y UISlider nativos** — Con animaciones nativas
- Radio de esquina y sombras nativas
- Animaciones spring suaves
- Sistema de colores dinámico (modo claro/oscuro)
- Múltiples estilos por componente

**Soporte iOS legacy** — Widgets Cupertino tradicionales para iOS 18 o inferior

**Material Design** — Soporte completo de Material 3 para Android

**Detección automática de plataforma** — Cero configuración requerida

**Renderizado consciente de versión** — Selecciona automáticamente el widget según la versión de iOS

## Galería de widgets

### Importante: configuración de localización

⚠️ **Para que la localización funcione correctamente (traducciones automáticas en date/time pickers, botones, etc.), debes agregar los delegates de localización a tu `AdaptiveApp`:**

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

AdaptiveApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate, // ¡Importante!
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''), // Inglés
    Locale('de', ''), // Alemán
    Locale('tr', ''), // Turco
    // Agrega más locales según necesites
  ],
  // ... resto de la configuración de tu app
)
```

Sin estos delegates, los date/time pickers y otros widgets mostrarán texto en inglés sin importar el idioma del sistema.

### AdaptiveScaffold con AdaptiveAppBar

<img src="https://github.com/ledexsoft/adaptive_liquid_glass/blob/main/img/toolbar_p.png?raw=true" alt="Toolbar nativa iOS 26">

**Uso básico:**
```dart
AdaptiveScaffold(
  appBar: AdaptiveAppBar(
    title: 'My App',
    actions: [
      AdaptiveAppBarAction(
        onPressed: () {},
        iosSymbol: 'gear',
        icon: Icons.settings,
      ),
    ],
  ),
  bottomNavigationBar: AdaptiveBottomNavigationBar(
    items: [
      AdaptiveNavigationDestination(
        icon: 'house.fill',
        label: 'Home',
      ),
      AdaptiveNavigationDestination(
        icon: 'person.fill',
        label: 'Profile',
      ),
    ],
    selectedIndex: 0,
    onTap: (index) {},
  ),
  body: YourContent(),
)
```

**Toolbar nativa de iOS 26:**
```dart
AdaptiveScaffold(
  appBar: AdaptiveAppBar(
    title: 'My App',
    useNativeToolbar: true, // Activa la UIToolbar nativa de iOS 26 con Liquid Glass
    actions: [...],
  ),
  body: YourContent(),
)
```

**Barra inferior nativa de iOS 26:**
```dart
AdaptiveScaffold(
  bottomNavigationBar: AdaptiveBottomNavigationBar(
    useNativeBottomBar: true, // UITabBar nativa de iOS 26 con Liquid Glass (por defecto)
    items: [...],
    selectedIndex: 0,
    onTap: (index) {},
  ),
  body: YourContent(),
)
```
**Sin AppBar ni navegación inferior:**
```dart
// Si appBar y bottomNavigationBar son null, no se muestra ninguna
AdaptiveScaffold(
  body: YourContent(),
)
```

**Características clave:**
- 🎨 **AdaptiveAppBar**: configuración centralizada de la app bar
- 📱 **AdaptiveBottomNavigationBar**: configuración centralizada de la navegación inferior
- 🔧 **Barras de navegación propias**: usa tus propios componentes
- 🌟 **Componentes nativos de iOS 26**: efectos Liquid Glass opcionales con UIKit nativo
- 🎯 **Sistema de prioridades**: las barras personalizadas tienen prioridad sobre las automáticas
- 🔄 **Flexible**: parámetros en null ocultan componentes

Bottom Navigation Bar adaptativa (destinos):
<p align="center">
  <img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/bottom_nav_p.png" alt="Toolbar nativa"/>
</p>


### AdaptiveButton

<img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/buttons_p.png" alt="Botones iOS 26">


```dart
// Botón básico con label
AdaptiveButton(
  onPressed: () {},
  label: 'Click Me',
)

// Botón con child personalizado
AdaptiveButton.child(
  onPressed: () {},
  child: Row(
    children: [
      Icon(Icons.add),
      Text('Add Item'),
    ],
  ),
)

// Botón de icono
AdaptiveButton.icon(
  onPressed: () {},
  icon: Icons.favorite,
)
```

> **Nota iOS 26+:** en iOS 26 o superior los botones usan el estilo nativo de Liquid Glass por defecto (`filled`/`tinted` → cápsula prominente; `bordered`/`gray` → vidrio discreto; `plain` sin fondo), cada uno con su propio color de tinte.

### AdaptiveAlertDialog
<img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/alert_p.png" alt="Alerta nativa iOS 26">


```dart
// Diálogo de alerta básico
AdaptiveAlertDialog.show(
  context: context,
  title: 'Confirm',
  message: 'Are you sure?',
  icon: 'checkmark.circle.fill',
  actions: [
    AlertAction(
      title: 'Cancel',
      style: AlertActionStyle.cancel,
      onPressed: () {},
    ),
    AlertAction(
      title: 'Confirm',
      style: AlertActionStyle.primary,
      onPressed: () {
        // Hacer algo
      },
    ),
  ],
);

// Diálogo con campo de texto
final result = await AdaptiveAlertDialog.show(
  context: context,
  title: 'Enter Your Name',
  message: 'Please provide your name',
  icon: 'person.fill',
  input: AdaptiveAlertDialogInput(
    placeholder: 'Your name',
    initialValue: '',
    keyboardType: TextInputType.text,
  ),
  actions: [
    AlertAction(
      title: 'Cancel',
      style: AlertActionStyle.cancel,
      onPressed: () {},
    ),
    AlertAction(
      title: 'Submit',
      style: AlertActionStyle.primary,
      onPressed: () {},
    ),
  ],
);

// result contiene el texto ingresado por el usuario
if (result != null) {
  print('User entered: $result');
}
```

### AdaptiveContextMenu

```dart
AdaptiveContextMenu(
  actions: [
    AdaptiveContextMenuAction(
      title: 'Edit',
      icon: PlatformInfo.isIOS ? CupertinoIcons.pencil : Icons.edit,
      onPressed: () {
        print('Edit pressed');
      },
    ),
    AdaptiveContextMenuAction(
      title: 'Share',
      icon: PlatformInfo.isIOS ? CupertinoIcons.share : Icons.share,
      onPressed: () {
        print('Share pressed');
      },
    ),
    AdaptiveContextMenuAction(
      title: 'Delete',
      icon: PlatformInfo.isIOS ? CupertinoIcons.trash : Icons.delete,
      isDestructive: true,
      onPressed: () {
        print('Delete pressed');
      },
    ),
  ],
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Mantén presionado'),
  ),
)
```

**iOS**: usa `CupertinoContextMenu` con preview y animaciones nativas.
**Android**: usa `PopupMenuButton` con estilo Material Design.

### AdaptivePopupMenuButton

<p align="center">
<img src="https://raw.githubusercontent.com/ledexsoft/adaptive_liquid_glass/refs/heads/main/img/popup_p.png" alt="Popup nativo iOS 26">
</p>

```dart
// Botón de texto con menú popup
AdaptivePopupMenuButton.text<String>(
  label: 'Options',
  items: [
    AdaptivePopupMenuItem(
        label: 'Edit',
        icon:  PlatformInfo.isIOS26OrHigher() ?  'pencil' : Icons.edit,
        value: 'edit',
      ),
      AdaptivePopupMenuItem(
        label: 'Delete',
        icon: PlatformInfo.isIOS26OrHigher() ?  'trash' : Icons.delete,
        value: 'delete',
      ),
      AdaptivePopupMenuDivider(),
      AdaptivePopupMenuItem(
        label: 'Share',
        icon: PlatformInfo.isIOS26OrHigher() ? 'square.and.arrow.up' : Icons.share,
        value: 'share',
      ),
  ],
  onSelected: (index, item) {
    print('Selected: ${item.value}');
  },
)

// Botón de icono con menú popup
AdaptivePopupMenuButton.icon<String>(
  icon: 'ellipsis.circle',
  items: [...],
  onSelected: (index, item) { },
  buttonStyle: PopupButtonStyle.glass,
)

// Widget personalizado con menú popup
AdaptivePopupMenuButton.widget<String>(
  items: [
    AdaptivePopupMenuItem(label: 'Option 1', value: 'opt1'),
    AdaptivePopupMenuItem(label: 'Option 2', value: 'opt2'),
  ],
  onSelected: (index, item) {
    print('Selected: ${item.value}');
  },
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.menu),
        SizedBox(width: 8),
        Text('Custom Button'),
      ],
    ),
  ),
)
```

### AdaptiveSegmentedControl

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/segmented_control.gif" alt="Segmented Control" width="300"/>
</p>

```dart
AdaptiveSegmentedControl(
  labels: ['Uno', 'Dos', 'Tres'],
  selectedIndex: 0,
  onValueChanged: (index) {
    print('Selected: $index');
  },
)

// Con iconos (SF Symbols en iOS)
AdaptiveSegmentedControl(
  labels: [],
  sfSymbols: [
    'house.fill',
    'person.fill',
    'gear',
  ],
  selectedIndex: 0,
  onValueChanged: (index) {},
  iconColor: CupertinoColors.systemBlue,
)
```

### AdaptiveSwitch

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/switch.gif" alt="Adaptive Switch" width="300"/>
</p>

```dart
AdaptiveSwitch(
  value: true,
  onChanged: (value) {
    print('Switch: $value');
  },
)
```

### AdaptiveSlider

<p align="center">
  <img src="https://github.com/ledexsoft/adaptive_liquid_glass/raw/main/img/slider.gif" alt="Adaptive Slider" width="300"/>
</p>

```dart
AdaptiveSlider(
  value: 0.5,
  onChanged: (value) {
    print('Slider: $value');
  },
  min: 0.0,
  max: 1.0,
)
```

### AdaptiveCheckbox

```dart
AdaptiveCheckbox(
  value: true,
  onChanged: (value) {
    print('Checkbox: $value');
  },
)

// Checkbox tristate
AdaptiveCheckbox(
  value: null, // Puede ser true, false o null
  tristate: true,
  onChanged: (value) {
    print('Checkbox: $value');
  },
)
```

### AdaptiveRadio

```dart
enum Options { option1, option2, option3 }
Options? _selectedOption = Options.option1;

AdaptiveRadio<Options>(
  value: Options.option1,
  groupValue: _selectedOption,
  onChanged: (Options? value) {
    setState(() {
      _selectedOption = value;
    });
  },
)
```

### AdaptiveCard

```dart
AdaptiveCard(
  padding: EdgeInsets.all(16),
  child: Text('Contenido de la tarjeta'),
)

// Tarjeta con estilo personalizado
AdaptiveCard(
  padding: EdgeInsets.all(16),
  color: Colors.blue.withValues(alpha: 0.1),
  borderRadius: BorderRadius.circular(20),
  elevation: 8, // Solo Android
  child: Column(
    children: [
      Text('Tarjeta personalizada'),
      Text('Con múltiples elementos'),
    ],
  ),
)
```

### AdaptiveBadge

```dart
AdaptiveBadge(
  count: 5,
  child: Icon(Icons.notifications),
)

// Badge con texto
AdaptiveBadge(
  label: 'NEW',
  backgroundColor: Colors.red,
  child: Icon(Icons.mail),
)

// Badge grande
AdaptiveBadge(
  count: 99,
  isLarge: true,
  child: Icon(Icons.message),
)
```

### AdaptiveTooltip

```dart
AdaptiveTooltip(
  message: 'Este es un tooltip',
  child: Icon(Icons.info),
)

// Tooltip arriba
AdaptiveTooltip(
  message: 'El tooltip aparece arriba',
  preferBelow: false,
  child: Icon(Icons.help),
)
```

### AdaptiveSnackBar

```dart
// Snackbar básico
AdaptiveSnackBar.show(
  context,
  message: '¡Operación completada!',
  type: AdaptiveSnackBarType.success,
)

// Snackbar con botón de acción
AdaptiveSnackBar.show(
  context,
  message: 'Archivo eliminado',
  type: AdaptiveSnackBarType.info,
  action: 'Deshacer',
  onActionPressed: () {
    // Acción de deshacer
  },
)

// Duración personalizada
AdaptiveSnackBar.show(
  context,
  message: 'Esto durará más tiempo',
  duration: Duration(seconds: 8),
)

// Diferentes tipos
AdaptiveSnackBar.show(context, message: 'Info', type: AdaptiveSnackBarType.info);
AdaptiveSnackBar.show(context, message: 'Éxito', type: AdaptiveSnackBarType.success);
AdaptiveSnackBar.show(context, message: 'Advertencia', type: AdaptiveSnackBarType.warning);
AdaptiveSnackBar.show(context, message: 'Error', type: AdaptiveSnackBarType.error);
```

**iOS**: notificación tipo banner arriba con animaciones slide/fade, se descarta al tocar, con indicadores de icono.
**Android**: Material SnackBar abajo con apariencia estándar de Material Design.

### AdaptiveDatePicker

```dart
// Selector de fecha básico
final selectedDate = await AdaptiveDatePicker.show(
  context: context,
  initialDate: DateTime.now(),
);

// Selector con rango
final selectedDate = await AdaptiveDatePicker.show(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2025),
);

// Fecha y hora (iOS)
final selectedDateTime = await AdaptiveDatePicker.show(
  context: context,
  initialDate: DateTime.now(),
  mode: CupertinoDatePickerMode.dateAndTime,
);

if (selectedDate != null) {
  print('Selected: ${selectedDate.toString()}');
}
```

**iOS**: usa `CupertinoDatePicker` en un bottom sheet modal con botones Cancelar/Listo.
**Android**: usa `DatePickerDialog` de Material.

### AdaptiveTimePicker

```dart
// Formato de 12 horas
final selectedTime = await AdaptiveTimePicker.show(
  context: context,
  initialTime: TimeOfDay.now(),
  use24HourFormat: false,
);

// Formato de 24 horas
final selectedTime = await AdaptiveTimePicker.show(
  context: context,
  initialTime: TimeOfDay.now(),
  use24HourFormat: true,
);

if (selectedTime != null) {
  print('Selected: ${selectedTime.format(context)}');
}
```

**iOS**: usa `CupertinoDatePicker` en modo hora en un bottom sheet modal.
**Android**: usa `TimePickerDialog` de Material.

### AdaptiveListTile

```dart
// List tile básico
AdaptiveListTile(
  title: Text('Perfil'),
  subtitle: Text('Ver tu perfil'),
  hideBottomDivider: false, // Oculta el borde inferior, útil para el último item (solo iOS)
  onTap: () {
    // Manejar tap
  },
)

// List tile con leading y trailing
AdaptiveListTile(
  leading: Icon(Icons.person),
  title: Text('Perfil'),
  subtitle: Text('Ver tu perfil'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    // Manejar tap
  },
)

// List tile seleccionable
AdaptiveListTile(
  leading: Icon(Icons.star),
  title: Text('Favorito'),
  selected: true,
  trailing: Icon(Icons.check_circle),
  onTap: () {
    // Manejar tap
  },
)

// List tile con trailing personalizado
AdaptiveListTile(
  title: Text('Activar función'),
  subtitle: Text('Actívalo aquí'),
  trailing: AdaptiveSwitch(
    value: switchValue,
    onChanged: (value) {
      // Manejar cambio
    },
  ),
)
```

**iOS**: estilo tipo CupertinoListTile con separador inferior.
**Android**: usa `ListTile` de Material.

### AdaptiveTextField

```dart
// Campo de texto básico
AdaptiveTextField(
  placeholder: 'Ingresa tu nombre',
  onChanged: (value) {
    print('Text: $value');
  },
)

// Campo con iconos
AdaptiveTextField(
  placeholder: 'Buscar',
  prefixIcon: Icon(
    PlatformInfo.isIOS ? CupertinoIcons.search : Icons.search,
  ),
  suffixIcon: IconButton(
    icon: Icon(
      PlatformInfo.isIOS ? CupertinoIcons.clear : Icons.clear,
    ),
    onPressed: () {
      // Limpiar texto
    },
  ),
)

// Campo de contraseña
AdaptiveTextField(
  placeholder: 'Ingresa tu contraseña',
  obscureText: true,
  prefixIcon: Icon(
    PlatformInfo.isIOS ? CupertinoIcons.lock : Icons.lock,
  ),
)

// Campo multilínea
AdaptiveTextField(
  placeholder: 'Ingresa una descripción',
  maxLines: 5,
  minLines: 3,
  keyboardType: TextInputType.multiline,
)
```

**iOS**: usa `CupertinoTextField` con color tertiarySystemBackground y esquinas redondeadas.
**Android**: usa `TextField` de Material con borde outlined.

### AdaptiveTextFormField

```dart
// Formulario con validación
Form(
  key: _formKey,
  child: Column(
    children: [
      AdaptiveTextFormField(
        placeholder: 'Email',
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa tu email';
          }
          if (!value.contains('@')) {
            return 'Ingresa un email válido';
          }
          return null;
        },
        onSaved: (value) => _email = value,
      ),
      AdaptiveButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Procesar formulario
          }
        },
        label: 'Enviar',
      ),
    ],
  ),
)
```

**iOS**: usa un wrapper `FormField` personalizado con `CupertinoTextField` para validación correcta con muestra de errores.
**Android**: usa `TextFormField` de Material.

### AdaptiveFloatingActionButton

```dart
// FAB básico
AdaptiveFloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)

// Mini FAB
AdaptiveFloatingActionButton(
  onPressed: () {},
  mini: true,
  child: Icon(Icons.edit),
)

// Colores personalizados
AdaptiveFloatingActionButton(
  onPressed: () {},
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
  child: Icon(Icons.favorite),
)
```

**iOS**: botón circular con sombras personalizadas.
**Android**: `FloatingActionButton` de Material con elevación.

### AdaptiveFormSection

```dart
// Sección de formulario básica
AdaptiveFormSection(
  header: Text('Información personal'),
  footer: Text('Provee información correcta'),
  children: [
    CupertinoFormRow(
      prefix: Text('Nombre'),
      child: AdaptiveTextField(placeholder: 'Ingresa tu nombre'),
    ),
    CupertinoFormRow(
      prefix: Text('Email'),
      child: AdaptiveTextField(placeholder: 'Ingresa tu email'),
    ),
  ],
)

// Estilo inset grouped
AdaptiveFormSection.insetGrouped(
  header: Text('Ajustes'),
  children: [
    CupertinoFormRow(
      prefix: Text('Notificaciones'),
      child: AdaptiveSwitch(value: true, onChanged: (v) {}),
    ),
  ],
)
```

**iOS**: usa `CupertinoFormSection` con estilo nativo de iOS.
**Android**: usa `Card` de Material con layout agrupado similar.

### AdaptiveExpansionTile

```dart
// Expansion tile básico
AdaptiveExpansionTile(
  title: Text('Ajustes'),
  children: [
    ListTile(title: Text('Opción 1')),
    ListTile(title: Text('Opción 2')),
  ],
)

// Con leading y subtítulo
AdaptiveExpansionTile(
  leading: Icon(Icons.settings),
  title: Text('Ajustes avanzados'),
  subtitle: Text('Configura opciones avanzadas'),
  initiallyExpanded: true,
  children: [
    ListTile(title: Text('Opción 1')),
    ListTile(title: Text('Opción 2')),
  ],
)

// Con colores personalizados
AdaptiveExpansionTile(
  title: Text('Funciones premium'),
  backgroundColor: Colors.amber.withValues(alpha: 0.1),
  iconColor: Colors.amber,
  onExpansionChanged: (expanded) {
    print('Expanded: $expanded');
  },
  children: [
    ListTile(title: Text('Función 1')),
    ListTile(title: Text('Función 2')),
  ],
)
```

**iOS**: diseño moderno personalizado con esquinas redondeadas, sombras suaves, chevron animado y separador con gradiente.
**Android**: `ExpansionTile` de Material con efectos InkWell.

### AdaptiveTabBarView

Vista de tabs deslizable horizontal con tabs arriba.

```dart
// Tab bar view arriba
AdaptiveTabBarView(
  tabs: ['Recientes', 'Populares', 'Tendencias'],
  children: [
    LatestPage(),
    PopularPage(),
    TrendingPage(),
  ],
  onTabChanged: (index) {
    print('Tab changed to: $index');
  },
)
```

**iOS**: usa `CupertinoSlidingSegmentedControl` para seleccionar tabs.
**Android**: usa `TabBar` + `TabBarView` de Material.

## Uso

### Estilos de botón

```dart
// Botón filled (acción primaria)
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.filled,
  label: 'Filled',
)

// Botón tinted (acción secundaria)
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.tinted,
  label: 'Tinted',
)

// Botón gris (acción neutra)
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.gray,
  label: 'Gray',
)

// Botón con borde
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.bordered,
  label: 'Bordered',
)

// Botón de texto plano
AdaptiveButton(
  onPressed: () {},
  style: AdaptiveButtonStyle.plain,
  label: 'Plain',
)
```

### Tamaños de botón

```dart
// Pequeño (28pt de alto en iOS)
AdaptiveButton(
  onPressed: () {},
  size: AdaptiveButtonSize.small,
  label: 'Small',
)

// Mediano (36pt de alto en iOS) - por defecto
AdaptiveButton(
  onPressed: () {},
  size: AdaptiveButtonSize.medium,
  label: 'Medium',
)

// Grande (44pt de alto en iOS)
AdaptiveButton(
  onPressed: () {},
  size: AdaptiveButtonSize.large,
  label: 'Large',
)
```

### Estilos personalizados

```dart
AdaptiveButton(
  onPressed: () {},
  label: 'Botón personalizado',
  color: Colors.red,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  borderRadius: BorderRadius.circular(16),
  minSize: Size(200, 50),
)
```

### Estado deshabilitado

```dart
AdaptiveButton(
  onPressed: () {},
  label: 'Deshabilitado',
  enabled: false,
)
```

## Detección de plataforma

Usa la clase `PlatformInfo` para verificar plataforma y versión de iOS:

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

// Verificar plataforma
if (PlatformInfo.isIOS) {
  print('Running on iOS');
}

if (PlatformInfo.isAndroid) {
  print('Running on Android');
}

// Verificar versión de iOS
if (PlatformInfo.isIOS26OrHigher()) {
  print('Using iOS 26+ features');
}

if (PlatformInfo.isIOS18OrLower()) {
  print('Using legacy iOS widgets');
}

// Obtener número de versión de iOS
int version = PlatformInfo.iOSVersion; // ej. 26

// Verificar rango de versiones
if (PlatformInfo.isIOSVersionInRange(24, 26)) {
  print('iOS version is between 24 and 26');
}

// Descripción de la plataforma
String description = PlatformInfo.platformDescription; // ej. "iOS 26"
```

## Instalación

**Desde pub.dev:**

```yaml
dependencies:
  adaptive_liquid_glass: ^0.1.125
```

**Desde GitHub (versión específica):**

```yaml
dependencies:
  adaptive_liquid_glass:
    git:
      url: https://github.com/ledexsoft/adaptive_liquid_glass.git
      ref: v0.1.125
```

Luego ejecuta:

```bash
flutter pub get
```

## Inicio rápido

### AdaptiveApp — Configuración de la app por plataforma

Usa `AdaptiveApp` para configurar tu app automáticamente en cada plataforma:

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'My App',
      themeMode: ThemeMode.system,
      materialLightTheme: ThemeData.light(),
      materialDarkTheme: ThemeData.dark(),
      cupertinoLightTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      cupertinoDarkTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
```

**Con soporte de router (GoRouter, etc.):**

```dart
AdaptiveApp.router(
  routerConfig: router,
  title: 'My App',
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

**Características clave:**
- 🎨 Temas separados para Material (Android) y Cupertino (iOS)
- 🌓 Soporte completo de modos de tema (claro, oscuro, sistema)
- 🔄 Detección automática de plataforma
- 🚀 Soporte de routers vía `AdaptiveApp.router()`
- 🛠️ Callbacks específicos por plataforma para configuración avanzada


## Funciones nativas de iOS 26

En iOS 26 o superior, los widgets usan automáticamente **platform views nativas de UIKit** con diseño Liquid Glass:

### Arquitectura de plataforma
- **Vistas UIKit nativas**: usa `UiKitView` para renderizar componentes reales de iOS 26
- **Platform channels**: comunicación bidireccional entre Flutter y el código nativo de iOS
- **Diseño Liquid Glass**: efectos visuales auténticos de iOS 26 renderizados por UIKit
- **Cero overhead**: sin pintura custom ni emulación — renderizado 100% nativo

### Características visuales
- **Radio de esquina moderno**: lenguaje de diseño nativo de iOS 26
- **Sombras dinámicas**: sombras sutiles multicapa
- **Animaciones spring**: amortiguación suave con escala 0.95x al presionar
- **Sistema de colores nativo**: colores del sistema de iOS con soporte correcto de modo claro/oscuro
- **Efectos Liquid Glass**: transparencia y blur nativos de iOS 26
- **SF Symbols**: renderizado nativo de SF Symbols con soporte de color jerárquico

### Interacción
- **Estados de presión**: feedback visual con animación de escala
- **Manejo de gestos**: reconocedores de gestos nativos de UIKit
- **Haptic feedback**: feedback de impacto medio en interacciones
- **Estados deshabilitados**: opacidad correcta y bloqueo de interacción

### Tipografía
- **Fuente SF Pro**: fuente del sistema de iOS con pesos correctos
- **Dynamic Type**: respeta la configuración de tamaño de fuente del sistema
- **Peso**: pesos de fuente apropiados para cada componente

## App de ejemplo

Ejecuta la app de ejemplo para ver todos los widgets en acción:

```bash
cd example
flutter run
```

La app de ejemplo incluye:
- Información de la plataforma
- Muestra de todos los tipos de widgets
- Demos interactivos
- Comparaciones de estilos y tamaños
- Soporte de modo oscuro

### IOS26NativeSearchTabBar (EXPERIMENTAL) (No confundir con AdaptiveBottomNavigationBar.)

⚠️ **ADVERTENCIA: esta es una función altamente experimental con limitaciones importantes. Úsala solo para prototipos y demos.**

Search tab bar nativa de iOS 26+ con UITabBarController que transforma la tab bar en una barra de búsqueda cuando se selecciona la tab de búsqueda.

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

// Activar la search tab bar nativa
await IOS26NativeSearchTabBar.enable(
  tabs: [
    const NativeTabConfig(
      title: 'Home',
      sfSymbol: 'house.fill',
    ),
    const NativeTabConfig(
      title: 'Search',
      sfSymbol: 'magnifyingglass',
      isSearchTab: true, // Esta tab se transforma en búsqueda
    ),
    const NativeTabConfig(
      title: 'Profile',
      sfSymbol: 'person.fill',
    ),
  ],
  selectedIndex: 0,
  onTabSelected: (index) {
    print('Tab selected: $index');
  },
  onSearchQueryChanged: (query) {
    print('Search query: $query');
  },
  onSearchSubmitted: (query) {
    print('Search submitted: $query');
  },
  onSearchCancelled: () {
    print('Search cancelled');
  },
);

// Desactivar al terminar
await IOS26NativeSearchTabBar.disable();

// Mostrar búsqueda programáticamente
await IOS26NativeSearchTabBar.showSearch();
```

**Características:**
- ✨ Integración nativa con UITabBarController
- 🔍 La tab de búsqueda se transforma en UISearchController
- 💎 Efectos Liquid Glass de iOS 26+
- 🎯 Comunicación por method channel
- 📱 Animaciones y gestos nativos

**Problemas y limitaciones conocidos:**

Esta función reemplaza el root view controller de Flutter con una UITabBarController nativa, lo que crea conflictos arquitectónicos fundamentales:

1. **Ciclo de vida de widgets**: `initState`, `dispose` y otros métodos pueden no funcionar correctamente
2. **Stack de navegación**: `Navigator.pop()` y métodos relacionados se vuelven poco confiables
3. **Manejo de estado**: Provider, Riverpod, Bloc, etc. pueden perder estado o comportarse de forma impredecible
4. **Hot reload**: no funciona correctamente — requiere reiniciar la app por completo
5. **Memory leaks**: posibles problemas de manejo de memoria entre Flutter y UIKit
6. **Conflictos de gestos**: los gestos nativos y de Flutter pueden interferir entre sí
7. **Sincronización de frames**: posible stuttering visual durante transiciones

**Por qué ocurren estos problemas:**

La función intenta fusionar dos filosofías arquitectónicas incompatibles:
- **Flutter**: single-threaded, declarativo, espera ser dueño de toda la pantalla
- **UIKit**: multi-threaded, imperativo, basado en view controllers

Cuando UITabBarController se vuelve root, el engine de Flutter sigue creyendo que es dueño de la pantalla, creando una relación padre-hijo que ningún framework fue diseñado para manejar.

**Recomendación:**
- ✅ Úsala para prototipos y validación de conceptos
- ✅ Úsala para demos y presentaciones
- ❌ NO la uses en apps de producción
- ❌ NO dependas de la navegación de Flutter mientras esté activa
- ❌ NO esperes que el hot reload funcione

Para apps de producción, usa el `TabBar` integrado de Flutter o implementa la búsqueda dentro de la estructura de navegación existente.

Mira la página de demo de Native Search Tab en la app de ejemplo para una explicación técnica detallada.

---

## Catálogo de widgets

Widgets adaptativos disponibles actualmente:

- ✅ **AdaptiveApp** — Configuración de la app por plataforma con soporte de temas y router
- ✅ **AdaptiveAppBar** — Configuración centralizada de la app bar con soporte de barras de navegación custom
- ✅ **AdaptiveBottomNavigationBar** — Configuración centralizada de la navegación inferior con soporte de tab bar custom
- ✅ **AdaptiveScaffold** — Scaffold con toolbar y tab bar nativas opcionales de iOS 26
- ✅ **AdaptiveButton** — Botones con diseños nativos de iOS 26+
- ✅ **AdaptiveSegmentedControl** — Controles segmentados nativos
- ✅ **AdaptiveSwitch** — Switches nativos
- ✅ **AdaptiveSlider** — Sliders nativos
- ✅ **AdaptiveCheckbox** — Checkboxes con estilo adaptativo
- ✅ **AdaptiveRadio** — Grupos de radio buttons con estilo adaptativo
- ✅ **AdaptiveCard** — Tarjetas con estilo específico por plataforma
- ✅ **AdaptiveBadge** — Badges de notificación con estilo adaptativo
- ✅ **AdaptiveTooltip** — Tooltips específicos por plataforma
- ✅ **AdaptiveSnackBar** — Snackbars de notificación específicos por plataforma
- ✅ **AdaptiveAlertDialog** — Diálogos de alerta nativos con soporte de campo de texto
- ✅ **AdaptiveContextMenu** — Menús contextuales de presión larga con estilo por plataforma
- ✅ **AdaptivePopupMenuButton** — Menús popup nativos
- ✅ **AdaptiveDatePicker** — Diálogos de selección de fecha por plataforma
- ✅ **AdaptiveTimePicker** — Diálogos de selección de hora por plataforma
- ✅ **AdaptiveListTile** — Tiles de lista específicos por plataforma
- ✅ **AdaptiveTextField** — Campos de texto específicos por plataforma
- ✅ **AdaptiveTextFormField** — Campos de formulario con validación por plataforma
- ✅ **AdaptiveFloatingActionButton** — Botones circulares de acción por plataforma
- ✅ **AdaptiveFormSection** — Secciones de formulario agrupadas con headers y footers
- ✅ **AdaptiveExpansionTile** — Contenido expandible/colapsable moderno
- ✅ **AdaptiveTabBarView** — Vista de tabs deslizable horizontal
- ⚠️ **IOS26NativeSearchTabBar** — Search tab bar nativa EXPERIMENTAL (solo iOS 26+)

## Filosofía de diseño

Este paquete sigue las Human Interface Guidelines de Apple para iOS y las guías de Material Design para Android. El objetivo es proveer:

1. **Look & feel nativo**: widgets que se sienten en casa en cada plataforma
2. **Cero configuración**: detección y adaptación automática de plataforma
3. **Conciencia de versión**: aprovechar las funciones nuevas de cada plataforma manteniendo compatibilidad hacia atrás
4. **Consistencia**: API unificada entre plataformas
5. **Personalización**: permitir overrides cuando se necesiten

## Soporte de versiones de iOS

- **iOS 26+**: diseños nativos modernos de iOS 26
- **iOS 18 o inferior**: widgets Cupertino tradicionales
- **Fallback automático**: degradación transparente para versiones anteriores

## Requisitos

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.9.2

## Contribuir

¡Las contribuciones son bienvenidas! Siéntete libre de enviar un Pull Request.

## Licencia

Este proyecto está bajo la Licencia MIT — consulta el archivo [LICENSE](LICENSE) para más detalles.

## Agradecimientos

- Inspirado en cupertino_native
- Guías de diseño de las Human Interface Guidelines de Apple
- Guías de Material Design de Google

## Contribuidores

Gracias a todos los contribuidores que han ayudado a mejorar este paquete:

<a href="https://github.com/ledexsoft/adaptive_liquid_glass/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ledexsoft/adaptive_liquid_glass" />
</a>

## Soporte

- 💬 **[Discussions](https://github.com/ledexsoft/adaptive_liquid_glass/discussions)** — Haz preguntas, comparte ideas y muestra tus proyectos
- 🐛 **[Issues](https://github.com/ledexsoft/adaptive_liquid_glass/issues)** — Reporta bugs y solicita funciones
- 📖 **[Guía de contribución](.github/CONTRIBUTING.md)** — Aprende cómo contribuir

# Comportamiento nativo de Liquid Glass

En iOS 26 y posteriores, las superficies nativas usan las APIs públicas de UIKit Liquid Glass de Apple. Las superficies de toolbar y blur usan un helper de material compartido. Las superficies nativas agrupadas pueden usar `UIGlassContainerEffect` para que los elementos de vidrio cercanos se fundan en sus bordes, pero requiere múltiples elementos de vidrio anidados; un contenedor con una sola superficie es solo un fondo de vidrio. Las tab bars estándar usan la apariencia propia de UIKit en iOS 26 en lugar de un blur forzado manualmente.

El paquete mantiene un fallback para iOS 15 usando `UIBlurEffect`/materiales de Flutter. El paquete no eleva el deployment target mínimo de la app anfitriona a iOS 26. Para children arbitrarios de Flutter, los elementos adyacentes solo pueden participar en el agrupamiento nativo de vidrio cuando se renderizan dentro de la misma platform view nativa; UIKit no puede fusionar platform views de Flutter separadas.
