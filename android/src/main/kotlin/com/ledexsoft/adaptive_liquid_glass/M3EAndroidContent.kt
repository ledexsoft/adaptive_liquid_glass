package com.ledexsoft.adaptive_liquid_glass

import android.os.Build
import android.icu.text.BreakIterator
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.AlertDialogDefaults
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.SelectableDates
import androidx.compose.material3.TimePicker
import androidx.compose.material3.TimePickerDefaults
import androidx.compose.material3.TimePickerDialog
import androidx.compose.material3.TimePickerDialogDefaults
import androidx.compose.material3.TimePickerDisplayMode
import androidx.compose.material3.TimeInput
import androidx.compose.material3.TimeInputDefaults
import androidx.compose.material3.VibrantTimePickerDialog
import androidx.compose.material3.isInputValid
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedSecureTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.SecureTextField
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.input.InputTransformation
import androidx.compose.foundation.text.input.TextFieldLineLimits
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.SliderState
import androidx.compose.material3.VerticalSlider
import androidx.compose.material3.rememberSliderState
import androidx.compose.material3.RangeSlider
import androidx.compose.material3.rememberRangeSliderState
import androidx.compose.material3.Label
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialExpressiveTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.Shapes
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MotionScheme
import androidx.compose.material3.LoadingIndicator
import androidx.compose.material3.LoadingIndicatorDefaults
import androidx.compose.material3.ContainedLoadingIndicator
import androidx.compose.material3.pulltorefresh.PullToRefreshDefaults
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.VerticalDivider
import androidx.compose.material3.DividerDefaults
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.FloatingActionButtonDefaults
import androidx.compose.material3.FloatingActionButtonMenu
import androidx.compose.material3.FloatingActionButtonMenuItem
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconToggleButton
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.FilledIconToggleButton
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.FilledTonalIconToggleButton
import androidx.compose.material3.OutlinedIconButton
import androidx.compose.material3.OutlinedIconToggleButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgeDefaults
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.NavigationRailDefaults
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SheetValue
import androidx.compose.material3.rememberBottomSheetState
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.NavigationDrawerItemDefaults
import androidx.compose.material3.DrawerDefaults
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.rememberDrawerState
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.NavigationBarDefaults
import androidx.compose.material3.NavigationItemIconPosition
import androidx.compose.material3.ShortNavigationBar
import androidx.compose.material3.ShortNavigationBarArrangement
import androidx.compose.material3.ShortNavigationBarItem
import androidx.compose.material3.ShortNavigationBarItemDefaults
import androidx.compose.material3.ShortNavigationBarDefaults
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.SegmentedListItem
import androidx.compose.material3.WideNavigationRail
import androidx.compose.material3.WideNavigationRailItem
import androidx.compose.material3.WideNavigationRailDefaults
import androidx.compose.material3.WideNavigationRailValue
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.PrimaryScrollableTabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.SplitButtonLayout
import androidx.compose.material3.SplitButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.CheckableDropdownMenuItem
import androidx.compose.material3.SelectableDropdownMenuItem
import androidx.compose.material3.FilterChip
import androidx.compose.material3.ElevatedFilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.InputChip
import androidx.compose.material3.InputChipDefaults
import androidx.compose.material3.AssistChip
import androidx.compose.material3.ElevatedAssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.ElevatedSuggestionChip
import androidx.compose.material3.SuggestionChipDefaults
import androidx.compose.material3.MenuDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.SearchBar
import androidx.compose.material3.SearchBarDefaults
import androidx.compose.material3.ExpandedDockedSearchBar
import androidx.compose.material3.ExpandedDockedSearchBarWithGap
import androidx.compose.material3.ExpandedFullScreenSearchBar
import androidx.compose.material3.rememberSearchBarState
import androidx.compose.material3.rememberSearchBarWithGapState
import androidx.compose.material3.BottomAppBarDefaults
import androidx.compose.material3.FloatingToolbarExitDirection
import androidx.compose.material3.FlexibleBottomAppBar
import androidx.compose.material3.AppBarRow
import androidx.compose.material3.AppBarColumn
import androidx.compose.material3.AppBarScope
import androidx.compose.material3.AppBarOverflowIndicator
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.MediumFlexibleTopAppBar
import androidx.compose.material3.LargeFlexibleTopAppBar
import androidx.compose.material3.AppBarWithSearch
import androidx.compose.material3.ExpandedFullScreenContainedSearchBar
import androidx.compose.material3.rememberContainedSearchBarState
import androidx.compose.material3.rememberSearchBarScrollState
import androidx.compose.material3.rememberTopAppBarState
import androidx.compose.material3.SearchBarValue
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.foundation.text.input.setTextAndPlaceCursorAtEnd
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.semantics.heading
import androidx.compose.material3.HorizontalFloatingToolbar
import androidx.compose.material3.VerticalFloatingToolbar
import androidx.compose.material3.FloatingToolbarDefaults
import androidx.compose.material3.ButtonGroup
import androidx.compose.material3.ButtonGroupDefaults
import androidx.compose.material3.ToggleButton
import androidx.compose.material3.FilledTonalToggleButton
import androidx.compose.material3.FilledTonalToggleButtonDefaults
import androidx.compose.material3.OutlinedToggleButton
import androidx.compose.material3.OutlinedToggleButtonDefaults
import androidx.compose.material3.ElevatedToggleButton
import androidx.compose.material3.ElevatedToggleButtonDefaults
import androidx.compose.material3.ToggleButtonSize
import androidx.compose.material3.ToggleButtonDefaults
import androidx.compose.material3.rememberWideNavigationRailState
import androidx.compose.material3.Icon
import androidx.compose.material3.LargeFloatingActionButton
import androidx.compose.material3.MediumFloatingActionButton
import androidx.compose.material3.SmallFloatingActionButton
import androidx.compose.material3.ToggleFloatingActionButton
import androidx.compose.material3.ToggleFloatingActionButtonDefaults
import androidx.compose.material3.ToggleFloatingActionButtonDefaults.animateIcon
import androidx.compose.material3.animateFloatingActionButton
import androidx.compose.material3.CircularWavyProgressIndicator
import androidx.compose.material3.LinearWavyProgressIndicator
import androidx.compose.material3.ProgressIndicatorDefaults
import androidx.compose.material3.WavyProgressIndicatorDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.PlainTooltip
import androidx.compose.material3.RichTooltip
import androidx.compose.material3.TooltipAnchorPosition
import androidx.compose.material3.TooltipBox
import androidx.compose.material3.TooltipDefaults
import androidx.compose.material3.TooltipScope
import androidx.compose.material3.rememberTooltipState
import androidx.compose.material3.TriStateCheckbox
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.expressiveLightColorScheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.contentColorFor
import androidx.compose.material3.Surface
import androidx.compose.material3.Snackbar
import androidx.compose.material3.SnackbarDefaults
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.TextButton
import androidx.compose.material3.carousel.HorizontalCenteredHeroCarousel
import androidx.compose.material3.carousel.HorizontalMultiBrowseCarousel
import androidx.compose.material3.carousel.HorizontalUncontainedCarousel
import androidx.compose.material3.carousel.CarouselParallaxScrollEffectState
import androidx.compose.material3.carousel.carouselParallaxScrollEffect
import androidx.compose.material3.carousel.CarouselItemScope
import androidx.compose.material3.carousel.CarouselItemDrawInfo
import androidx.compose.material3.carousel.rememberCarouselState
import androidx.compose.material3.carousel.CarouselDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.key
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.runtime.withFrameNanos
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onPreviewKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.input.key.isShiftPressed
import androidx.compose.ui.autofill.ContentType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.focus.focusProperties
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.shape.AbsoluteRoundedCornerShape
import androidx.compose.foundation.shape.CornerBasedShape
import androidx.compose.foundation.shape.CornerSize
import androidx.compose.foundation.shape.GenericShape
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.RoundRect
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.platform.LocalAccessibilityManager
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.platform.SoundEffectOnInteraction
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.disabled
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.contentType
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.isTraversalGroup
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.maxTextLength
import androidx.compose.ui.semantics.onLongClick
import androidx.compose.ui.semantics.paneTitle
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.semantics.toggleableState
import androidx.compose.ui.semantics.traversalIndex
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.AnimationState
import androidx.compose.animation.core.animateTo
import androidx.compose.animation.core.tween
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.layout.absoluteOffset
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontFamily
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.window.DialogWindowProvider
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.interaction.HoverInteraction
import androidx.compose.foundation.interaction.FocusInteraction
import androidx.compose.ui.focus.focusProperties
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.unit.Velocity
import kotlinx.coroutines.channels.ReceiveChannel
import kotlinx.coroutines.Job
import androidx.compose.foundation.interaction.collectIsDraggedAsState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.Brush
import androidx.compose.foundation.Image
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.LayoutCoordinates
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.automirrored.filled.Message
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward

internal typealias M3EAndroidEvent = (String, Any?) -> Unit

private val LocalM3EFlutterFonts = staticCompositionLocalOf<M3EFlutterFonts> {
  error("Native M3 Expressive text requires its font resolver")
}

@Composable
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
internal fun M3EAndroidTheme(
  properties: Map<String, Any?>,
  flutterFonts: M3EFlutterFonts,
  content: @Composable () -> Unit,
) {
  val dark = properties.boolean("isDark")
  val primary = properties.color("primaryColor") ?: Color(0xFF6750A4)
  val dynamic = properties.boolean("dynamicColoring") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
  val context = LocalContext.current
  // Black and white have equal contrast at luminance ~0.179; choose the
  // higher-contrast foreground when the fallback scheme uses a custom primary.
  val foreground = if (primary.luminance() > 0.179f) Color.Black else Color.White
  val colors = (if (dynamic && dark) {
    dynamicDarkColorScheme(context)
  } else if (dynamic) {
    dynamicLightColorScheme(context)
  } else if (dark) {
    darkColorScheme(primary = primary, onPrimary = foreground)
  } else {
    expressiveLightColorScheme().copy(primary = primary, onPrimary = foreground)
  }).withAppColorScheme(
    properties["colorScheme"] ?: if (dynamic) null else properties["fallbackColorScheme"]
  )
  val typography = remember(properties["typography"], flutterFonts) {
    nativeM3ETypography(properties["typography"], flutterFonts)
  }
  val shapes = remember(properties["shapeRadii"]) {
    nativeM3EShapes(properties["shapeRadii"])
  }
  val layoutDirection = when (properties["layoutDirection"]) {
    "ltr" -> LayoutDirection.Ltr
    "rtl" -> LayoutDirection.Rtl
    else -> LocalLayoutDirection.current
  }
  CompositionLocalProvider(
    LocalLayoutDirection provides layoutDirection,
    LocalM3EFlutterFonts provides flutterFonts,
  ) {
    MaterialExpressiveTheme(
      colorScheme = colors,
      motionScheme = MotionScheme.expressive(),
      typography = typography,
      shapes = shapes,
      content = content,
    )
  }
}

private fun nativeM3EShapes(value: Any?): Shapes? {
  val roles = value as? Map<*, *> ?: return null
  val defaults = Shapes()
  fun overrideShape(name: String, base: CornerBasedShape): CornerBasedShape {
    val radius = (roles[name] as? Number)?.toFloat()?.takeIf { it.isFinite() && it >= 0f }
    return radius?.let { RoundedCornerShape(it.dp) } ?: base
  }
  return defaults.copy(
    extraSmall = overrideShape("extraSmall", defaults.extraSmall),
    small = overrideShape("small", defaults.small),
    medium = overrideShape("medium", defaults.medium),
    large = overrideShape("large", defaults.large),
    extraLarge = overrideShape("extraLarge", defaults.extraLarge),
    largeIncreased = overrideShape("largeIncreased", defaults.largeIncreased),
    extraLargeIncreased = overrideShape("extraLargeIncreased", defaults.extraLargeIncreased),
    extraExtraLarge = overrideShape("extraExtraLarge", defaults.extraExtraLarge),
  )
}

private fun nativeM3ETypography(value: Any?, flutterFonts: M3EFlutterFonts): Typography? {
  val roles = value as? Map<*, *> ?: return null
  val defaults = Typography()
  fun overrideStyle(name: String, base: TextStyle): TextStyle {
    val options = roles[name] as? Map<*, *> ?: return base
    val fontSize = (options["fontSize"] as? Number)?.toFloat()?.takeIf { it.isFinite() && it > 0f }
    val weight = (options["fontWeight"] as? Number)?.toInt()?.takeIf { it in 1..1000 }
    val spacing = (options["letterSpacing"] as? Number)?.toFloat()?.takeIf { it.isFinite() }
    val height = (options["height"] as? Number)?.toFloat()?.takeIf { it.isFinite() && it > 0f }
    val family = flutterFonts.resolve(
      options["fontFamily"] as? String,
      options["fontVariations"],
      requestedWeight = weight ?: base.fontWeight?.weight,
      requestedItalic = when (options["fontStyle"] as? String) {
        "italic" -> true
        "normal" -> false
        else -> base.fontStyle == FontStyle.Italic
      },
    )
      ?: (options["fontFamilyFallback"] as? List<*>)
        ?.firstNotNullOfOrNull {
          flutterFonts.resolve(
            it as? String,
            options["fontVariations"],
            requestedWeight = weight ?: base.fontWeight?.weight,
            requestedItalic = options["fontStyle"] == "italic" ||
              (options["fontStyle"] == null && base.fontStyle == FontStyle.Italic),
          )
        }
    return base.copy(
      fontFamily = family ?: base.fontFamily,
      fontSize = fontSize?.sp ?: base.fontSize,
      fontWeight = weight?.let(::FontWeight) ?: base.fontWeight,
      fontStyle = when (options["fontStyle"] as? String) {
        "italic" -> FontStyle.Italic
        "normal" -> FontStyle.Normal
        else -> base.fontStyle
      },
      fontFeatureSettings = options["fontFeatureSettings"] as? String
        ?: base.fontFeatureSettings,
      letterSpacing = spacing?.sp ?: base.letterSpacing,
      lineHeight = if (options["fontMetricsLineHeight"] == true) TextUnit.Unspecified
        else height?.em ?: base.lineHeight,
    )
  }
  return defaults.copy(
    displayLarge = overrideStyle("displayLarge", defaults.displayLarge),
    displayMedium = overrideStyle("displayMedium", defaults.displayMedium),
    displaySmall = overrideStyle("displaySmall", defaults.displaySmall),
    headlineLarge = overrideStyle("headlineLarge", defaults.headlineLarge),
    headlineMedium = overrideStyle("headlineMedium", defaults.headlineMedium),
    headlineSmall = overrideStyle("headlineSmall", defaults.headlineSmall),
    titleLarge = overrideStyle("titleLarge", defaults.titleLarge),
    titleMedium = overrideStyle("titleMedium", defaults.titleMedium),
    titleSmall = overrideStyle("titleSmall", defaults.titleSmall),
    bodyLarge = overrideStyle("bodyLarge", defaults.bodyLarge),
    bodyMedium = overrideStyle("bodyMedium", defaults.bodyMedium),
    bodySmall = overrideStyle("bodySmall", defaults.bodySmall),
    labelLarge = overrideStyle("labelLarge", defaults.labelLarge),
    labelMedium = overrideStyle("labelMedium", defaults.labelMedium),
    labelSmall = overrideStyle("labelSmall", defaults.labelSmall),
    displayLargeEmphasized = overrideStyle("displayLargeEmphasized", defaults.displayLargeEmphasized),
    displayMediumEmphasized = overrideStyle("displayMediumEmphasized", defaults.displayMediumEmphasized),
    displaySmallEmphasized = overrideStyle("displaySmallEmphasized", defaults.displaySmallEmphasized),
    headlineLargeEmphasized = overrideStyle("headlineLargeEmphasized", defaults.headlineLargeEmphasized),
    headlineMediumEmphasized = overrideStyle("headlineMediumEmphasized", defaults.headlineMediumEmphasized),
    headlineSmallEmphasized = overrideStyle("headlineSmallEmphasized", defaults.headlineSmallEmphasized),
    titleLargeEmphasized = overrideStyle("titleLargeEmphasized", defaults.titleLargeEmphasized),
    titleMediumEmphasized = overrideStyle("titleMediumEmphasized", defaults.titleMediumEmphasized),
    titleSmallEmphasized = overrideStyle("titleSmallEmphasized", defaults.titleSmallEmphasized),
    bodyLargeEmphasized = overrideStyle("bodyLargeEmphasized", defaults.bodyLargeEmphasized),
    bodyMediumEmphasized = overrideStyle("bodyMediumEmphasized", defaults.bodyMediumEmphasized),
    bodySmallEmphasized = overrideStyle("bodySmallEmphasized", defaults.bodySmallEmphasized),
    labelLargeEmphasized = overrideStyle("labelLargeEmphasized", defaults.labelLargeEmphasized),
    labelMediumEmphasized = overrideStyle("labelMediumEmphasized", defaults.labelMediumEmphasized),
    labelSmallEmphasized = overrideStyle("labelSmallEmphasized", defaults.labelSmallEmphasized),
  )
}

private fun ColorScheme.withAppColorScheme(value: Any?): ColorScheme {
  val roles = value as? Map<*, *> ?: return this
  fun role(name: String, fallback: Color): Color {
    val argb = (roles[name] as? Number)?.toInt() ?: return fallback
    return Color(argb)
  }

  return copy(
    primary = role("primary", primary),
    onPrimary = role("onPrimary", onPrimary),
    primaryContainer = role("primaryContainer", primaryContainer),
    onPrimaryContainer = role("onPrimaryContainer", onPrimaryContainer),
    inversePrimary = role("inversePrimary", inversePrimary),
    primaryFixed = role("primaryFixed", primaryFixed),
    primaryFixedDim = role("primaryFixedDim", primaryFixedDim),
    onPrimaryFixed = role("onPrimaryFixed", onPrimaryFixed),
    onPrimaryFixedVariant = role("onPrimaryFixedVariant", onPrimaryFixedVariant),
    secondary = role("secondary", secondary),
    onSecondary = role("onSecondary", onSecondary),
    secondaryContainer = role("secondaryContainer", secondaryContainer),
    onSecondaryContainer = role("onSecondaryContainer", onSecondaryContainer),
    secondaryFixed = role("secondaryFixed", secondaryFixed),
    secondaryFixedDim = role("secondaryFixedDim", secondaryFixedDim),
    onSecondaryFixed = role("onSecondaryFixed", onSecondaryFixed),
    onSecondaryFixedVariant = role("onSecondaryFixedVariant", onSecondaryFixedVariant),
    tertiary = role("tertiary", tertiary),
    onTertiary = role("onTertiary", onTertiary),
    tertiaryContainer = role("tertiaryContainer", tertiaryContainer),
    onTertiaryContainer = role("onTertiaryContainer", onTertiaryContainer),
    tertiaryFixed = role("tertiaryFixed", tertiaryFixed),
    tertiaryFixedDim = role("tertiaryFixedDim", tertiaryFixedDim),
    onTertiaryFixed = role("onTertiaryFixed", onTertiaryFixed),
    onTertiaryFixedVariant = role("onTertiaryFixedVariant", onTertiaryFixedVariant),
    background = role("background", background),
    onBackground = role("onBackground", onBackground),
    surface = role("surface", surface),
    onSurface = role("onSurface", onSurface),
    surfaceVariant = role("surfaceVariant", surfaceVariant),
    onSurfaceVariant = role("onSurfaceVariant", onSurfaceVariant),
    surfaceTint = role("surfaceTint", surfaceTint),
    inverseSurface = role("inverseSurface", inverseSurface),
    inverseOnSurface = role("inverseOnSurface", inverseOnSurface),
    error = role("error", error),
    onError = role("onError", onError),
    errorContainer = role("errorContainer", errorContainer),
    onErrorContainer = role("onErrorContainer", onErrorContainer),
    outline = role("outline", outline),
    outlineVariant = role("outlineVariant", outlineVariant),
    scrim = role("scrim", scrim),
    surfaceBright = role("surfaceBright", surfaceBright),
    surfaceDim = role("surfaceDim", surfaceDim),
    surfaceContainer = role("surfaceContainer", surfaceContainer),
    surfaceContainerHigh = role("surfaceContainerHigh", surfaceContainerHigh),
    surfaceContainerHighest = role("surfaceContainerHighest", surfaceContainerHighest),
    surfaceContainerLow = role("surfaceContainerLow", surfaceContainerLow),
    surfaceContainerLowest = role("surfaceContainerLowest", surfaceContainerLowest),
  )
}

@Composable
internal fun M3EAndroidContent(
  properties: Map<String, Any?>,
  cardPressEvents: ReceiveChannel<M3ECardPressEvent>,
  cardHoverEvents: ReceiveChannel<Boolean>,
  cardFocusEvents: ReceiveChannel<Boolean>,
  toolbarScrollEvents: ReceiveChannel<M3EToolbarScrollEvent>,
  onEvent: M3EAndroidEvent,
) {
  val enabled = properties.boolean("enabled", true)
  val hasCallback = properties.boolean("hasCallback", true)
  val component = properties["component"] as? String

  Box(
    modifier = Modifier.fillMaxSize(),
    contentAlignment = if (component == "navigationRail" && properties["type"] == "expanded" && properties.boolean("autoWidth")) Alignment.TopStart else if (component == "topAppBar" || component == "pullRefreshIndicator" || component == "textField" || component == "switchListTile" || component == "listTile" || component == "expansionTile" || (component == "toolbar" && properties.boolean("docked") && properties["scrollBehavior"] == "exitAlways")) Alignment.TopCenter else Alignment.Center,
  ) {
    when (component) {
      "aiSparkleIcon" -> NativeM3EAiSparkleIcon(
        icon = properties["icon"] as? String,
        size = (properties.number("size") ?: 24.0).dp,
        tint = properties.color("color"),
        sparkleTint = properties.color("sparkleColor") ?: MaterialTheme.colorScheme.primary,
        semanticLabel = properties["semanticLabel"] as? String,
      )
      "expressiveShape" -> NativeM3EExpressiveShape(properties)
      "button" -> NativeM3EButton(properties, enabled && hasCallback, onEvent)
      "filterChip" -> NativeM3EFilterChip(properties, enabled && hasCallback, onEvent)
      "inputChip" -> NativeM3EInputChip(properties, enabled && hasCallback, onEvent)
      "assistChip" -> NativeM3EActionChip(properties, enabled && hasCallback, onEvent, suggestion = false)
      "suggestionChip" -> NativeM3EActionChip(properties, enabled && hasCallback, onEvent, suggestion = true)
      "switch" -> NativeM3ESwitch(properties, enabled && hasCallback, onEvent)
      "checkbox" -> NativeM3ECheckbox(properties, enabled && hasCallback, onEvent)
      "radio" -> NativeM3ERadio(properties, enabled && hasCallback, onEvent)
      "slider" -> NativeM3ESlider(properties, enabled && hasCallback, onEvent)
      "rangeSlider" -> NativeM3ERangeSlider(properties, enabled && hasCallback, onEvent)
      "loadingIndicator" -> NativeM3ELoadingIndicator(properties)
      "pullRefreshIndicator" -> NativeM3EPullRefreshIndicator(properties, onEvent)
      "progressIndicator" -> NativeM3EProgressIndicator(properties)
      "divider" -> NativeM3EDivider(properties)
      "fab" -> NativeM3EFab(properties, enabled && hasCallback, onEvent)
      "extendedFab" -> NativeM3EExtendedFab(properties, enabled && hasCallback, onEvent)
      "fabMenu" -> NativeM3EFabMenu(properties, onEvent)
      "iconButton" -> NativeM3EIconButton(properties, enabled && hasCallback, onEvent)
      "navigationRail" -> NativeM3ENavigationRail(properties, onEvent)
      "navigationDrawer" -> NativeM3ENavigationDrawer(properties, onEvent)
      "navigationDrawerOverlay" -> NativeM3ENavigationDrawerOverlay(properties, onEvent)
      "carousel" -> NativeM3ECarousel(properties, onEvent)
      "segmentedButton" -> NativeM3ESegmentedButton(properties, onEvent)
      "tabs" -> NativeM3ETabs(properties, onEvent)
      "badge" -> NativeM3EBadge(properties, onEvent)
      "splitButton" -> NativeM3ESplitButton(properties, enabled, onEvent)
      "toolbar" -> NativeM3EToolbar(properties, toolbarScrollEvents, onEvent)
      "buttonGroup" -> NativeM3EButtonGroup(properties, onEvent)
      "bottomNavigationBar" -> NativeM3EBottomNavigationBar(properties, onEvent)
      "topAppBar" -> NativeM3ETopAppBar(properties, onEvent)
      "popupMenuButton" -> NativeM3EPopupMenuButton(properties, enabled && hasCallback, onEvent)
      "anchoredPopupMenu" -> NativeM3EAnchoredPopupMenu(properties, onEvent)
      "searchBar" -> NativeM3ESearchBar(properties, enabled, onEvent)
      "switchListTile" -> NativeM3ESwitchListTile(properties, enabled, onEvent)
      "listTile" -> NativeM3EListTile(properties, enabled, onEvent)
      "cardSurface" -> NativeM3ECardSurface(properties, cardPressEvents, cardHoverEvents, cardFocusEvents)
      "alertDialog" -> NativeM3EAlertDialog(properties, onEvent)
      "actionSheet" -> NativeM3EActionSheet(properties, onEvent)
      "contextMenu" -> NativeM3EContextMenu(properties, onEvent)
      "datePicker" -> NativeM3EDatePicker(properties, onEvent)
      "timePicker" -> NativeM3ETimePicker(properties, onEvent)
      "textField" -> NativeM3ETextField(properties, enabled, onEvent)
      "expansionTile" -> NativeM3EExpansionTile(properties, onEvent)
      "snackbar" -> NativeM3ESnackbar(properties, onEvent)
      "tooltip" -> NativeM3ETooltip(properties, onEvent)
    }
  }
}

private fun nativeM3ETextDecoration(value: String?): TextDecoration? = when (value) {
  "none" -> TextDecoration.None
  "underline" -> TextDecoration.Underline
  "lineThrough" -> TextDecoration.LineThrough
  "underlineLineThrough" -> TextDecoration.Underline + TextDecoration.LineThrough
  else -> null
}

@Composable
private fun NativeM3EListText(
  value: String,
  options: Map<*, *>?,
  color: Color,
  maxLinesLimit: Int = Int.MAX_VALUE,
  defaultOverflow: TextOverflow = TextOverflow.Clip,
  modifier: Modifier = Modifier,
  baseStyle: TextStyle? = null,
) {
  val overflow = when (options?.get("overflow") as? String) {
    "ellipsis" -> TextOverflow.Ellipsis
    "visible" -> TextOverflow.Visible
    else -> defaultOverflow
  }
  val textAlign = when (options?.get("textAlign") as? String) {
    "left" -> TextAlign.Left
    "right" -> TextAlign.Right
    "center" -> TextAlign.Center
    "end" -> TextAlign.End
    "justify" -> TextAlign.Justify
    "start" -> TextAlign.Start
    else -> null
  }
  val baseTextStyle = (baseStyle ?: LocalTextStyle.current).let {
    if (options?.get("fontMetricsLineHeight") == true) it.copy(lineHeight = TextUnit.Unspecified)
    else it
  }
  val fontWeight = (options?.get("fontWeight") as? Number)?.toInt()?.let(::FontWeight)
  val fontStyle = when (options?.get("fontStyle") as? String) {
    "italic" -> FontStyle.Italic
    "normal" -> FontStyle.Normal
    else -> null
  }
  val fontFamily = LocalM3EFlutterFonts.current.resolve(
    options?.get("fontFamily") as? String,
    variations = options?.get("fontVariations"),
    requestedWeight = fontWeight?.weight ?: baseTextStyle.fontWeight?.weight,
    requestedItalic = (fontStyle ?: baseTextStyle.fontStyle) == FontStyle.Italic,
    allowDeviceFamily = true,
  )
  val fontFeatureSettings = options?.get("fontFeatureSettings") as? String
  Text(
    text = value,
    modifier = modifier,
    color = color,
    fontSize = (options?.get("fontSize") as? Number)?.toFloat()?.sp ?: TextUnit.Unspecified,
    fontWeight = fontWeight,
    fontStyle = fontStyle,
    fontFamily = fontFamily,
    textDecoration = nativeM3ETextDecoration(options?.get("textDecoration") as? String),
    letterSpacing = (options?.get("letterSpacing") as? Number)?.toFloat()?.sp ?: TextUnit.Unspecified,
    lineHeight = (options?.get("height") as? Number)?.toFloat()?.em ?: TextUnit.Unspecified,
    textAlign = textAlign,
    maxLines = minOf(
      (options?.get("maxLines") as? Number)?.toInt()?.coerceAtLeast(1) ?: Int.MAX_VALUE,
      maxLinesLimit,
    ),
    overflow = overflow,
    softWrap = options?.get("softWrap") as? Boolean ?: true,
    style = if (fontFeatureSettings == null) baseTextStyle
      else baseTextStyle.copy(fontFeatureSettings = fontFeatureSettings),
  )
}

@Composable
private fun NativeM3EExpansionTile(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val density = LocalDensity.current
  val expanded = properties.boolean("expanded")
  val expansionStateDescription = properties["stateDescription"] as? String
  val enabled = properties.boolean("enabled", true)
  val title = properties["title"] as? String ?: ""
  val subtitle = properties["subtitle"] as? String
  val titleTextOptions = properties["titleTextOptions"] as? Map<*, *>
  val subtitleTextOptions = properties["subtitleTextOptions"] as? Map<*, *>
  val leading = properties["leadingIcon"] as? String
  val trailing = properties["trailingIcon"] as? String
  val background = properties.color("backgroundColor")
  val titleColor = properties.color("textColor") ?: Color.Unspecified
  val subtitleColor = properties.color("subtitleColor") ?: Color.Unspecified
  val iconColor = properties.color("iconColor")
  val effectsSpec = MaterialTheme.motionScheme.fastEffectsSpec<Color>()
  val animatedTitleColor = if (titleColor == Color.Unspecified) Color.Unspecified else
    animateColorAsState(titleColor, effectsSpec, label = "expansionTileTitleColor").value
  val animatedSubtitleColor = if (subtitleColor == Color.Unspecified) Color.Unspecified else
    animateColorAsState(subtitleColor, effectsSpec, label = "expansionTileSubtitleColor").value
  val animatedIconColor = iconColor?.let { target ->
    animateColorAsState(target, effectsSpec, label = "expansionTileIconColor").value
  }
  val padding = properties["padding"] as? List<*>
  val contentPadding = if (padding?.size == 4) PaddingValues.Absolute(
    left = ((padding[0] as? Number)?.toDouble() ?: 16.0).dp,
    top = ((padding[1] as? Number)?.toDouble() ?: 10.0).dp,
    right = ((padding[2] as? Number)?.toDouble() ?: 16.0).dp,
    bottom = ((padding[3] as? Number)?.toDouble() ?: 10.0).dp,
  ) else ListItemDefaults.ContentPadding
  val arrowRotation by animateFloatAsState(
    targetValue = if (expanded) 180f else 0f,
    animationSpec = MaterialTheme.motionScheme.fastSpatialSpec(),
    label = "expansionTileArrowRotation",
  )
  ListItem(
    onClick = { onEvent("tapped", null) },
    modifier = Modifier.fillMaxWidth()
      .wrapContentHeight(unbounded = true)
      .then(expansionStateDescription?.let { description ->
        Modifier.semantics { stateDescription = description }
      } ?: Modifier)
      .onSizeChanged { size ->
        onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
      },
    enabled = enabled,
    supportingContent = subtitle?.let { text -> ({ NativeM3EListText(text, subtitleTextOptions, animatedSubtitleColor) }) },
    leadingContent = leading?.let { name -> ({
      Icon(
        nativeM3EIcon(name),
        contentDescription = properties["leadingIconSemanticLabel"] as? String,
        modifier = properties.number("leadingIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
        tint = properties.color("leadingIconColor") ?: animatedIconColor ?: LocalContentColor.current,
      )
    }) },
    trailingContent = {
      Icon(
        trailing?.let(::nativeM3EIcon) ?: Icons.Filled.ExpandMore,
        contentDescription = if (trailing == null) null else properties["trailingIconSemanticLabel"] as? String,
        modifier = if (trailing == null) Modifier.rotate(arrowRotation)
          else properties.number("trailingIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
        tint = properties.color("trailingIconColor") ?: animatedIconColor ?: LocalContentColor.current,
      )
    },
    colors = ListItemDefaults.colors(containerColor = background ?: Color.Unspecified),
    contentPadding = contentPadding,
  ) { NativeM3EListText(title, titleTextOptions, animatedTitleColor) }
}

@Composable
private fun NativeM3ESnackbar(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val message = properties["message"] as? String ?: ""
  val action = properties["action"] as? String
  val duration = (properties.number("durationMs") ?: 4000.0).toLong().coerceAtLeast(0)
  val persistentAction = action != null
  val background = properties.color("backgroundColor") ?: SnackbarDefaults.color
  val content = properties.color("contentColor") ?: SnackbarDefaults.contentColor
  val actionColor = properties.color("actionColor") ?: SnackbarDefaults.actionColor
  val actionContent = properties.color("actionColor") ?: SnackbarDefaults.actionContentColor
  val accessibilityManager = LocalAccessibilityManager.current
  val recommendedDuration = accessibilityManager?.calculateRecommendedTimeoutMillis(
    duration,
    containsIcons = false,
    containsText = true,
    containsControls = action != null,
  ) ?: duration
  val hostState = remember(message, action, duration) { SnackbarHostState() }
  val entered = remember(message, action, duration) { kotlinx.coroutines.CompletableDeferred<Unit>() }
  val exitCompleted = remember(message, action, duration) { kotlinx.coroutines.CompletableDeferred<Unit>() }
  val currentOnEvent by rememberUpdatedState(onEvent)
  val dismissRequested = properties.boolean("dismissRequested")
  val currentSnackbarData = hostState.currentSnackbarData
  LaunchedEffect(dismissRequested, currentSnackbarData) {
    if (dismissRequested) currentSnackbarData?.dismiss()
  }
  val density = LocalDensity.current
  val bottomInset = (properties.number("bottomInset") ?: 0.0).coerceAtLeast(0.0).dp
  val bottomGapPx = with(density) { bottomInset.roundToPx() }
  val snackbarWidth = LocalConfiguration.current.screenWidthDp.dp
    .coerceAtLeast(1.dp)
    .coerceAtMost(624.dp)
  val positionProvider = remember(bottomGapPx) {
    object : PopupPositionProvider {
      override fun calculatePosition(
        anchorBounds: IntRect,
        windowSize: IntSize,
        layoutDirection: LayoutDirection,
        popupContentSize: IntSize,
      ): IntOffset = IntOffset(
        x = (windowSize.width - popupContentSize.width) / 2,
        y = (windowSize.height - popupContentSize.height - bottomGapPx).coerceAtLeast(0),
      )
    }
  }
  // AndroidX also fixes its accessibility-adjusted timeout when the item is
  // shown. Recomposition must not restart the request with old entry signals.
  LaunchedEffect(hostState) {
    val timeoutJob = if (persistentAction) null else launch {
      entered.await()
      kotlinx.coroutines.delay(recommendedDuration)
      hostState.currentSnackbarData?.dismiss()
    }
    val result = hostState.showSnackbar(
      message = message,
      actionLabel = action,
      withDismissAction = persistentAction,
      duration = SnackbarDuration.Indefinite,
    )
    timeoutJob?.cancel()
    // A queued dismissal can arrive before the first native frame. In that
    // case there is no SnackbarHost exit animation to wait for.
    if (entered.isCompleted) exitCompleted.await()
    currentOnEvent(if (result == SnackbarResult.ActionPerformed) "actionPressed" else "dismissed", null)
  }
  Popup(
    popupPositionProvider = positionProvider,
    properties = PopupProperties(
      focusable = false,
      dismissOnClickOutside = false,
    ),
  ) {
    SnackbarHost(
      hostState = hostState,
      modifier = Modifier.width(snackbarWidth),
      snackbar = { data ->
        DisposableEffect(data) {
          if (!entered.isCompleted) entered.complete(Unit)
          onDispose {
            if (!exitCompleted.isCompleted) exitCompleted.complete(Unit)
          }
        }
        Snackbar(
          snackbarData = data,
          containerColor = background,
          contentColor = content,
          actionColor = actionColor,
          actionContentColor = actionContent,
          dismissActionContentColor = content,
        )
      },
    )
  }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun TooltipScope.NativeM3EPlainActionTooltip(label: String) {
  PlainTooltip(modifier = Modifier.semantics {
    paneTitle = label
    liveRegion = LiveRegionMode.Assertive
  }) { Text(label) }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun NativeM3ETooltip(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val message = properties["message"] as? String ?: ""
  val title = (properties["title"] as? String)?.takeIf { it.isNotBlank() }
  val actionLabel = (properties["actionLabel"] as? String)?.takeIf { it.isNotBlank() }
  val preferBelow = properties.boolean("preferBelow", true)
  val anchorLeft = properties.number("left") ?: 0.0
  val anchorTop = properties.number("top") ?: 0.0
  val anchorWidth = properties.number("width") ?: 0.0
  val anchorHeight = properties.number("height") ?: 0.0
  val showDuration = (properties.number("showDurationMs") ?: 1000.0).toLong().coerceAtLeast(0)
  val persistentTrigger = properties.boolean("persistentTrigger")
  val dismissRequested = properties.boolean("dismissRequested")
  val currentDismissRequested by rememberUpdatedState(dismissRequested)
  val padding = properties["padding"] as? List<*>
  val margin = properties["margin"] as? List<*>
  val background = properties.color("backgroundColor") ?: TooltipDefaults.plainTooltipContainerColor
  val foreground = properties.color("textColor") ?: TooltipDefaults.plainTooltipContentColor
  val textOptions = properties["textOptions"] as? Map<*, *>
  val customTooltipShape = (properties["cornerRadii"] as? List<*>)
    ?.takeIf { it.size == 4 }
    ?.mapNotNull { (it as? Number)?.toFloat()?.takeIf { radius -> radius.isFinite() && radius >= 0f } }
    ?.takeIf { it.size == 4 }
    ?.let { AbsoluteRoundedCornerShape(it[0].dp, it[1].dp, it[2].dp, it[3].dp) }
  val tooltipShape = customTooltipShape ?: TooltipDefaults.plainTooltipContainerShape
  val tooltipHeight = properties.number("tooltipHeight")?.dp
  val tooltipState = rememberTooltipState(isPersistent = true)
  var actionSent by remember { mutableStateOf(false) }
  val caretWidth = properties.number("caretWidth")?.takeIf { it.isFinite() && it > 0 }
  val caretHeight = properties.number("caretHeight")?.takeIf { it.isFinite() && it > 0 }
  val caretShape = if (properties.boolean("showCaret")) {
    if (caretWidth != null && caretHeight != null) {
      TooltipDefaults.caretShape(DpSize(caretWidth.dp, caretHeight.dp))
    } else {
      TooltipDefaults.caretShape()
    }
  } else null
  val positioning = when (properties["anchorPosition"] as? String) {
    "above" -> TooltipAnchorPosition.Above
    "below" -> TooltipAnchorPosition.Below
    "start" -> TooltipAnchorPosition.Start
    "end" -> TooltipAnchorPosition.End
    "left" -> TooltipAnchorPosition.Left
    "right" -> TooltipAnchorPosition.Right
    else -> if (preferBelow) TooltipAnchorPosition.Below else TooltipAnchorPosition.Above
  }
  val spacing = properties.number("anchorSpacing")?.dp
    ?: if (positioning == TooltipAnchorPosition.Above || positioning == TooltipAnchorPosition.Below) {
      properties.number("verticalOffset")?.dp
    } else {
      null
    }
  val positionProvider = if (spacing == null) {
    TooltipDefaults.rememberTooltipPositionProvider(positioning)
  } else {
    TooltipDefaults.rememberTooltipPositionProvider(positioning, spacing)
  }
  LaunchedEffect(message, persistentTrigger, showDuration) {
    val showJob = launch { tooltipState.show() }
    val dismissJob = launch {
      if (persistentTrigger) {
        snapshotFlow { currentDismissRequested }.first { it }
      } else {
        kotlinx.coroutines.withTimeoutOrNull(showDuration) {
          snapshotFlow { currentDismissRequested }.first { it }
        }
      }
      tooltipState.dismiss()
    }
    showJob.join()
    dismissJob.cancel()
    snapshotFlow { tooltipState.transition.currentState || tooltipState.transition.targetState }
      .first { !it }
    onEvent("dismissed", null)
  }
  val tooltipModifier = Modifier
    .absolutePadding(
      left = ((margin?.getOrNull(0) as? Number)?.toDouble() ?: 0.0).dp,
      top = ((margin?.getOrNull(1) as? Number)?.toDouble() ?: 0.0).dp,
      right = ((margin?.getOrNull(2) as? Number)?.toDouble() ?: 0.0).dp,
      bottom = ((margin?.getOrNull(3) as? Number)?.toDouble() ?: 0.0).dp,
    )
    .semantics {
      liveRegion = LiveRegionMode.Assertive
      paneTitle = title ?: message
    }
  val bodyModifier = Modifier
    .then(if (tooltipHeight == null) Modifier else Modifier.height(tooltipHeight))
    .then(if (padding == null) Modifier else Modifier.absolutePadding(
      left = ((padding.getOrNull(0) as? Number)?.toDouble() ?: 0.0).dp,
      top = ((padding.getOrNull(1) as? Number)?.toDouble() ?: 0.0).dp,
      right = ((padding.getOrNull(2) as? Number)?.toDouble() ?: 0.0).dp,
      bottom = ((padding.getOrNull(3) as? Number)?.toDouble() ?: 0.0).dp,
    ))
  Layout(
    modifier = Modifier.fillMaxSize(),
    content = {
      TooltipBox(
        positionProvider = positionProvider,
        tooltip = {
          if (title != null || actionLabel != null) {
            RichTooltip(
              modifier = tooltipModifier
                .pointerInput(Unit) {
                  awaitPointerEventScope {
                    while (true) {
                      when (awaitPointerEvent().type) {
                        PointerEventType.Enter -> onEvent("popupHovered", true)
                        PointerEventType.Exit -> onEvent("popupHovered", false)
                      }
                    }
                  }
                },
              caretShape = caretShape,
              title = title?.let { heading -> { Text(heading) } },
              action = actionLabel?.let { label ->
                {
                  TextButton(
                    modifier = Modifier.onFocusChanged { onEvent("actionFocused", it.isFocused) },
                    onClick = {
                      if (!actionSent) {
                        actionSent = true
                        onEvent("actionPressed", null)
                      }
                    },
                  ) { Text(label) }
                }
              },
              shape = customTooltipShape ?: TooltipDefaults.richTooltipContainerShape,
              colors = TooltipDefaults.richTooltipColors(
                containerColor = properties.color("backgroundColor") ?: Color.Unspecified,
                contentColor = properties.color("textColor") ?: Color.Unspecified,
              ),
            ) {
              NativeM3EListText(
                message,
                textOptions,
                properties.color("textColor") ?: LocalContentColor.current,
                modifier = bodyModifier,
              )
            }
          } else {
            PlainTooltip(
              modifier = tooltipModifier,
              caretShape = caretShape,
              containerColor = background,
              contentColor = foreground,
              shape = tooltipShape,
            ) {
              NativeM3EListText(message, textOptions, foreground, modifier = bodyModifier)
            }
          }
        },
        state = tooltipState,
        enableUserInput = false,
        hasAction = actionLabel != null,
      ) {
        Box(Modifier.fillMaxSize())
      }
    },
  ) { measurables, constraints ->
    val width = anchorWidth.dp.roundToPx().coerceAtLeast(1)
    val height = anchorHeight.dp.roundToPx().coerceAtLeast(1)
    val anchor = measurables.single().measure(Constraints.fixed(width, height))
    layout(constraints.maxWidth, constraints.maxHeight) {
      anchor.place(anchorLeft.dp.roundToPx(), anchorTop.dp.roundToPx())
    }
  }
}

private fun nativeIndexedActionEvent(index: Int, action: Map<*, *>): Any {
  val id = action["id"] as? Number ?: return index
  return mapOf("index" to index, "id" to id)
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ETopAppBar(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val title = properties["title"] as? String ?: ""
  val titleTextOptions = properties["titleTextOptions"] as? Map<*, *>
  val titleColor = properties.color("titleColor") ?: Color.Unspecified
  val subtitle = properties["subtitle"] as? String
  val leadingIcon = properties["leadingIcon"] as? String
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val variant = properties["variant"] as? String ?: "small"
  val centerAligned = properties.boolean("centerAligned")
  val transparentWhenScrolled = properties.boolean("transparentWhenScrolled")
  val scrollOffset = (properties.number("scrollOffset") ?: 0.0).toFloat().coerceAtLeast(0f)
  val scrollKind = properties["scrollBehavior"] as? String ?: "pinned"
  val contentColor = properties.color("contentColor") ?: Color.Unspecified
  val surfaceColor = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.surface
  val density = LocalDensity.current
  val heightReporter = Modifier.onSizeChanged { size ->
    onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
  }
  val isFlexible = variant == "mediumFlexible" || variant == "largeFlexible"
  val collapsedHeight = when (variant) {
    "mediumFlexible" -> TopAppBarDefaults.MediumAppBarCollapsedHeight
    "largeFlexible" -> TopAppBarDefaults.LargeAppBarCollapsedHeight
    else -> TopAppBarDefaults.TopAppBarExpandedHeight
  }
  val expandedHeight = when {
    variant == "largeFlexible" && !subtitle.isNullOrBlank() -> TopAppBarDefaults.LargeFlexibleAppBarWithSubtitleExpandedHeight
    variant == "largeFlexible" -> TopAppBarDefaults.LargeFlexibleAppBarWithoutSubtitleExpandedHeight
    variant == "mediumFlexible" && !subtitle.isNullOrBlank() -> TopAppBarDefaults.MediumFlexibleAppBarWithSubtitleExpandedHeight
    variant == "mediumFlexible" -> TopAppBarDefaults.MediumFlexibleAppBarWithoutSubtitleExpandedHeight
    else -> TopAppBarDefaults.TopAppBarExpandedHeight
  }
  val heightOffsetLimit = with(density) {
    if (scrollKind == "enterAlways") -expandedHeight.toPx()
    else -(expandedHeight - collapsedHeight).toPx()
  }
  val appBarState = rememberTopAppBarState(initialHeightOffsetLimit = heightOffsetLimit)
  val scrollBehavior = when (scrollKind) {
    "enterAlways" -> TopAppBarDefaults.enterAlwaysScrollBehavior(appBarState)
    "exitUntilCollapsed" -> TopAppBarDefaults.exitUntilCollapsedScrollBehavior(appBarState)
    else -> TopAppBarDefaults.pinnedScrollBehavior(appBarState)
  }
  val scrollOffsetPx = with(density) { scrollOffset.dp.toPx() }
  val snapAnimationSpec = TopAppBarDefaults.snapAnimationSpec
  val scrolling = properties.boolean("scrolling")
  val scrollAtStart = properties.boolean("scrollAtStart", scrollOffset <= 0f)
  val scrollEndSerial = (properties.number("scrollEndSerial") ?: 0.0).toInt()
  var previousAppBarOffsetPx by remember(variant, scrollKind) { mutableStateOf(0f) }
  var previousScrollEndSerial by remember(variant, scrollKind) { mutableStateOf(scrollEndSerial) }
  LaunchedEffect(scrollOffsetPx, scrolling, scrollAtStart, scrollEndSerial, scrollKind, isFlexible, heightOffsetLimit) {
    val scrollDeltaPx = scrollOffsetPx - previousAppBarOffsetPx
    previousAppBarOffsetPx = scrollOffsetPx
    val shouldSnap = !scrolling && scrollEndSerial != previousScrollEndSerial
    previousScrollEndSerial = scrollEndSerial
    appBarState.contentOffset = -scrollOffsetPx
    appBarState.heightOffset = when (scrollKind) {
      "enterAlways" -> (appBarState.heightOffset - scrollDeltaPx).coerceIn(heightOffsetLimit, 0f)
      "exitUntilCollapsed" -> when {
        !isFlexible -> 0f
        scrollDeltaPx > 0f -> (appBarState.heightOffset - scrollDeltaPx).coerceIn(heightOffsetLimit, 0f)
        scrollAtStart -> 0f
        else -> appBarState.heightOffset
      }
      else -> 0f
    }
    if (shouldSnap && (scrollKind == "enterAlways" || (scrollKind == "exitUntilCollapsed" && isFlexible))) {
      val collapsedFraction = appBarState.collapsedFraction
      if (collapsedFraction >= 0.01f && collapsedFraction < 1f) {
        AnimationState(initialValue = appBarState.heightOffset).animateTo(
          if (collapsedFraction < 0.5f) 0f else heightOffsetLimit,
          animationSpec = snapAnimationSpec,
        ) {
          appBarState.heightOffset = value
        }
      }
    }
  }
  val colors = TopAppBarDefaults.topAppBarColors(
    containerColor = surfaceColor,
    scrolledContainerColor = if (transparentWhenScrolled) Color.Transparent else MaterialTheme.colorScheme.surfaceContainer,
    titleContentColor = contentColor,
    navigationIconContentColor = contentColor,
    actionIconContentColor = contentColor,
    subtitleContentColor = properties.color("contentColor") ?: Color.Unspecified,
  )
  val logoBytes = properties["logoBytes"] as? ByteArray
  val logoSize = if (isFlexible) 36.dp else 32.dp
  val logoTargetPx = with(LocalDensity.current) { logoSize.roundToPx() }
  val logoLoad = rememberM3EImageBitmapResult(logoBytes, logoTargetPx, logoTargetPx)
  val logo = logoLoad.image
  val logoVisible = logo != null || (logoBytes != null && !logoLoad.complete)
  val logoDescription = properties["logoContentDescription"] as? String
  val logoReplacesSmallTitle = properties.boolean("logoReplacesSmallTitle", true)

  @Composable
  fun titleContent(maxLines: Int, includeSubtitle: Boolean = true) {
    Column(
      horizontalAlignment = if (centerAligned) Alignment.CenterHorizontally else Alignment.Start,
    ) {
      if (logoVisible && variant != "search") {
        val logoSemantics = logoDescription ?: if (variant == "small" && logoReplacesSmallTitle) title else null
        if (logo != null) {
          Image(
            bitmap = logo,
            contentDescription = logoSemantics,
            modifier = Modifier.size(logoSize),
            contentScale = ContentScale.Fit,
          )
        } else {
          Box(
            Modifier.size(logoSize).then(logoSemantics?.takeIf { it.isNotBlank() }?.let { description ->
              Modifier.semantics { contentDescription = description }
            } ?: Modifier),
          )
        }
      }
      if (title.isNotEmpty() && !(variant == "small" && logoVisible && logoReplacesSmallTitle)) {
        NativeM3EListText(
          title,
          titleTextOptions,
          titleColor,
          maxLinesLimit = maxLines,
          defaultOverflow = TextOverflow.Ellipsis,
          modifier = Modifier.semantics { heading() },
        )
      }
      if (includeSubtitle && !subtitle.isNullOrBlank()) {
        Text(
          text = subtitle,
          maxLines = if (isFlexible) 2 else 1,
          overflow = TextOverflow.Ellipsis,
          style = when (variant) {
            "largeFlexible" -> MaterialTheme.typography.titleMedium
            "mediumFlexible" -> MaterialTheme.typography.labelLarge
            else -> MaterialTheme.typography.labelMedium
          },
        )
      }
    }
  }

  @Composable
  fun leadingContent() {
    if (leadingIcon == null) return
    val description = properties["leadingDescription"] as? String ?: "Navigate back"
    TooltipBox(
      positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Below),
      tooltip = {
        PlainTooltip(modifier = Modifier.semantics {
          paneTitle = description
          liveRegion = LiveRegionMode.Assertive
        }) { Text(description) }
      },
      state = rememberTooltipState(),
    ) {
      val leadingSize = IconButtonDefaults.smallContainerSize(
        if (transparentWhenScrolled) IconButtonDefaults.IconButtonWidthOption.Narrow
        else IconButtonDefaults.IconButtonWidthOption.Uniform,
      )
      val leadingButtonContent: @Composable () -> Unit = {
        if (logo != null && variant == "search") {
          Image(logo, contentDescription = description, modifier = Modifier.size(24.dp))
        } else {
          val iconSize = properties.number("leadingIconSize")?.dp
          Icon(
            nativeM3EIcon(leadingIcon),
            contentDescription = description,
            modifier = iconSize?.let { Modifier.size(it) } ?: Modifier,
            tint = properties.color("leadingIconColor") ?: LocalContentColor.current,
          )
        }
      }
      if (transparentWhenScrolled) {
        FilledTonalIconButton(
          onClick = { onEvent("leadingPressed", null) },
          enabled = properties.boolean("leadingEnabled", true),
          shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape),
          modifier = Modifier.size(leadingSize),
        ) { leadingButtonContent() }
      } else {
        IconButton(
          onClick = { onEvent("leadingPressed", null) },
          enabled = properties.boolean("leadingEnabled", true),
          shapes = IconButtonDefaults.shapes(),
          modifier = Modifier.size(leadingSize),
        ) { leadingButtonContent() }
      }
    }
  }

  val menuExpanded = remember { mutableStateOf(false) }
  var pendingOverflowAction by remember { mutableStateOf<Any?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  @Composable
  fun actionIcon(icon: String, action: Map<*, *>, description: String?) {
    val iconSize = (action["iconSize"] as? Number)?.toFloat()?.dp
    val iconTint = (action["iconColor"] as? Number)?.toLong()?.toInt()?.let(::Color)
      ?: LocalContentColor.current
    Icon(
      nativeM3EIcon(icon),
      contentDescription = description,
      modifier = iconSize?.let { Modifier.size(it) } ?: Modifier,
      tint = iconTint,
    )
  }
  @Composable
  fun actionButton(index: Int, action: Map<*, *>) {
    val icon = action["icon"] as? String
    val titleLabel = action["title"] as? String
    val label = (action["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
      ?: titleLabel?.takeIf { it.isNotBlank() }
    val style = action["style"] as? String ?: "standard"
    val wide = action["wide"] as? Boolean ?: false
    val enabled = action["enabled"] as? Boolean ?: true
    val widthOption = if (wide) IconButtonDefaults.IconButtonWidthOption.Wide else IconButtonDefaults.IconButtonWidthOption.Uniform
    val buttonSize = IconButtonDefaults.smallContainerSize(widthOption)
    val buttonModifier = Modifier.size(buttonSize)
    if (icon == null) {
      val visibleTitle = titleLabel?.takeIf { it.isNotBlank() } ?: return
      TextButton(
        onClick = { onEvent("actionPressed", nativeIndexedActionEvent(index, action)) },
        enabled = enabled,
        shapes = ButtonDefaults.shapes(),
      ) { Text(visibleTitle, maxLines = 1) }
      return
    }
    @Composable
    fun iconButton() {
      val onClick = { onEvent("actionPressed", nativeIndexedActionEvent(index, action)) }
      when (style) {
        "filled" -> FilledIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
          actionIcon(icon, action, label)
        }
        "filledTonal" -> FilledTonalIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
          actionIcon(icon, action, label)
        }
        else -> if (transparentWhenScrolled) {
          FilledTonalIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
            actionIcon(icon, action, label)
          }
        } else {
          IconButton(onClick, shapes = IconButtonDefaults.shapes(), enabled = enabled, modifier = buttonModifier) {
            actionIcon(icon, action, label)
          }
        }
      }
    }
    if (label == null) {
      iconButton()
    } else {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Below),
        tooltip = {
          PlainTooltip(modifier = Modifier.semantics {
            paneTitle = label
            liveRegion = LiveRegionMode.Assertive
          }) { Text(label) }
        },
        state = rememberTooltipState(),
      ) { iconButton() }
    }
  }

  @Composable
  fun actionContent(search: Boolean = false) {
    val insideSearchIndex = actions.indexOfFirst { raw ->
      (raw as? Map<*, *>)?.get("insideSearchField") == true
    }
    val visibleActions = actions.mapIndexedNotNull { index, raw ->
      val action = raw as? Map<*, *> ?: return@mapIndexedNotNull null
      if (search && index == insideSearchIndex) null else index to action
    }
    val maxTrailingActions = if (LocalConfiguration.current.screenWidthDp >= 600) 4 else 2
    val insideSearchCount = if (search && insideSearchIndex >= 0) 1 else 0
    val maxVisible = (maxTrailingActions - insideSearchCount).coerceAtLeast(0)
    val shown = visibleActions.take(maxVisible)
    shown.forEach { (index, action) ->
      actionButton(index, action)
    }
    if (visibleActions.size > maxVisible) {
      Box {
        val moreButtonSize = IconButtonDefaults.smallContainerSize(
          if (transparentWhenScrolled) IconButtonDefaults.IconButtonWidthOption.Wide
          else IconButtonDefaults.IconButtonWidthOption.Uniform,
        )
        val moreDescription = properties["moreDescription"] as? String ?: "More actions"
        val moreButtonContent: @Composable () -> Unit = {
          Icon(Icons.Filled.MoreVert, contentDescription = moreDescription)
        }
        TooltipBox(
          positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Below),
          tooltip = {
            PlainTooltip(modifier = Modifier.semantics {
              paneTitle = moreDescription
              liveRegion = LiveRegionMode.Assertive
            }) { Text(moreDescription) }
          },
          state = rememberTooltipState(),
        ) {
          if (transparentWhenScrolled) {
            FilledTonalIconButton(
              onClick = { if (pendingOverflowAction == null) menuExpanded.value = true },
              enabled = pendingOverflowAction == null,
              shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape),
              modifier = Modifier.size(moreButtonSize),
            ) { moreButtonContent() }
          } else {
            IconButton(
              onClick = { if (pendingOverflowAction == null) menuExpanded.value = true },
              enabled = pendingOverflowAction == null,
              shapes = IconButtonDefaults.shapes(),
              modifier = Modifier.size(moreButtonSize),
            ) { moreButtonContent() }
          }
        }
        DropdownMenu(expanded = menuExpanded.value, onDismissRequest = { menuExpanded.value = false }) {
          DisposableEffect(Unit) {
            onDispose {
              val action = pendingOverflowAction
              if (action != null) {
                pendingOverflowAction = null
                currentOnEvent("actionPressed", action)
              }
            }
          }
          val overflowActions = visibleActions.drop(maxVisible)
          overflowActions.forEachIndexed { menuIndex, (index, action) ->
            val label = (action["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
              ?: (action["title"] as? String)?.takeIf { it.isNotBlank() }
            DropdownMenuItem(
              text = { Text((action["title"] as? String)?.takeIf { it.isNotBlank() } ?: label.orEmpty()) },
              shape = MenuDefaults.itemShape(menuIndex, overflowActions.size).shape,
              leadingIcon = (action["icon"] as? String)?.let { icon -> ({ actionIcon(icon, action, null) }) },
              enabled = action["enabled"] as? Boolean ?: true,
              onClick = {
                if (pendingOverflowAction == null) {
                  pendingOverflowAction = nativeIndexedActionEvent(index, action)
                  menuExpanded.value = false
                }
              },
            )
          }
        }
      }
    }
  }

  if (variant == "search") {
    val prefersDockedSearch = LocalConfiguration.current.screenWidthDp >= 600
    var useDockedSearch by remember { mutableStateOf(prefersDockedSearch) }
    val searchState = if (useDockedSearch) rememberSearchBarWithGapState()
      else rememberContainedSearchBarState()
    val textFieldState = rememberTextFieldState()
    val scope = rememberCoroutineScope()
    var pendingSearchEvent by remember { mutableStateOf<Pair<String, String>?>(null) }
    val currentSearchOnEvent by rememberUpdatedState(onEvent)
    LaunchedEffect(prefersDockedSearch, useDockedSearch, searchState.currentValue, searchState.isAnimating, pendingSearchEvent) {
      if (prefersDockedSearch != useDockedSearch && pendingSearchEvent == null &&
        searchState.currentValue == SearchBarValue.Collapsed && !searchState.isAnimating
      ) {
        useDockedSearch = prefersDockedSearch
      }
    }
    val searchScrollState = rememberSearchBarScrollState(
      initialScrollOffsetLimit = with(density) { -64.dp.toPx() },
    )
    val searchScrollBehavior = SearchBarDefaults.enterAlwaysSearchBarScrollBehavior(searchScrollState)
    val searchSnapAnimationSpec = MaterialTheme.motionScheme.defaultEffectsSpec<Float>()
    val searchColors = SearchBarDefaults.appBarWithSearchColors(
      appBarContainerColor = surfaceColor,
      scrolledAppBarContainerColor = if (transparentWhenScrolled) Color.Transparent else MaterialTheme.colorScheme.surfaceContainer,
      appBarNavigationIconColor = contentColor,
      appBarActionIconColor = contentColor,
    )
    val searchOffsetPx = with(density) { scrollOffset.dp.toPx() }
    var previousSearchOffsetPx by remember(scrollKind) { mutableStateOf(0f) }
    var previousSearchEndSerial by remember(scrollKind) { mutableStateOf(scrollEndSerial) }
    LaunchedEffect(searchOffsetPx, scrolling, scrollEndSerial, scrollKind, searchState.currentValue) {
      val searchDeltaPx = searchOffsetPx - previousSearchOffsetPx
      previousSearchOffsetPx = searchOffsetPx
      val shouldSnap = !scrolling && scrollEndSerial != previousSearchEndSerial
      previousSearchEndSerial = scrollEndSerial
      searchScrollState.contentOffset = -searchOffsetPx
      searchScrollState.scrollOffset = when (scrollKind) {
        "enterAlways" -> (searchScrollState.scrollOffset - searchDeltaPx)
          .coerceIn(searchScrollState.scrollOffsetLimit, 0f)
        else -> 0f
      }
      if (shouldSnap && scrollKind == "enterAlways" && searchState.currentValue == SearchBarValue.Collapsed) {
        val offsetLimit = searchScrollState.scrollOffsetLimit
        val collapsedFraction = if (offsetLimit < 0f) {
          searchScrollState.scrollOffset / offsetLimit
        } else {
          0f
        }
        if (collapsedFraction >= 0.01f && collapsedFraction < 1f) {
          AnimationState(initialValue = searchScrollState.scrollOffset).animateTo(
            if (collapsedFraction < 0.5f) 0f else offsetLimit,
            animationSpec = searchSnapAnimationSpec,
          ) {
            searchScrollState.scrollOffset = value
          }
        }
      }
    }
    val insideSearchIndex = actions.indexOfFirst { raw ->
      (raw as? Map<*, *>)?.get("insideSearchField") == true
    }
    val inputField: @Composable () -> Unit = {
      SearchBarDefaults.InputField(
        textFieldState = textFieldState,
        searchBarState = searchState,
        colors = searchColors.searchBarColors.inputFieldColors,
        onSearch = { query ->
          if (pendingSearchEvent == null) {
            pendingSearchEvent = "searchSubmitted" to query
            scope.launch { searchState.animateToCollapsed() }
          }
        },
        placeholder = { Text(properties["searchHint"] as? String ?: "Search") },
        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
        trailingIcon = if (insideSearchIndex >= 0) {
          val action = actions[insideSearchIndex] as? Map<*, *>
          val icon = action?.get("icon") as? String
          if (action != null && icon != null) ({
            actionButton(insideSearchIndex, action)
          }) else null
        } else null,
      )
    }
    LaunchedEffect(textFieldState) {
      snapshotFlow { textFieldState.text.toString() }.distinctUntilChanged().collect { query ->
        onEvent("searchQueryChanged", query)
      }
    }
    LaunchedEffect(pendingSearchEvent, searchState) {
      val pending = pendingSearchEvent ?: return@LaunchedEffect
      snapshotFlow {
        searchState.currentValue == SearchBarValue.Collapsed && !searchState.isAnimating
      }.first { it }
      if (pendingSearchEvent == pending) {
        pendingSearchEvent = null
        currentSearchOnEvent(pending.first, pending.second)
      }
    }
    Column(Modifier.fillMaxWidth()) {
      AppBarWithSearch(
        state = searchState,
        inputField = inputField,
        modifier = heightReporter,
        navigationIcon = { leadingContent() },
        actions = { actionContent(search = true) },
        colors = searchColors,
        scrollBehavior = searchScrollBehavior,
      )
      val searchResults: @Composable () -> Unit = {
        val query = textFieldState.text.toString()
        val suggestions = properties["searchSuggestions"] as? List<*> ?: emptyList<Any?>()
        val filteredSuggestions = suggestions.mapNotNull { it as? String }
          .filter { query.isBlank() || it.contains(query, ignoreCase = true) }
        LazyColumn(Modifier.fillMaxSize()) {
          items(count = filteredSuggestions.size) { index ->
            val suggestion = filteredSuggestions[index]
            ListItem(
              onClick = {
                if (pendingSearchEvent == null) {
                  textFieldState.setTextAndPlaceCursorAtEnd(suggestion)
                  pendingSearchEvent = "searchResultSelected" to suggestion
                  scope.launch { searchState.animateToCollapsed() }
                }
              },
              leadingContent = { Icon(Icons.Filled.Search, contentDescription = null) },
            ) { Text(suggestion) }
          }
        }
      }
      if (useDockedSearch) {
        ExpandedDockedSearchBarWithGap(
          state = searchState,
          inputField = inputField,
          colors = searchColors.searchBarColors,
        ) { searchResults() }
      } else {
        ExpandedFullScreenContainedSearchBar(
          state = searchState,
          inputField = inputField,
          colors = searchColors.searchBarColors,
        ) { searchResults() }
      }
    }
    return
  }

  if (variant == "mediumFlexible") {
    MediumFlexibleTopAppBar(
      title = { titleContent(maxLines = 2, includeSubtitle = false) },
      modifier = heightReporter,
      subtitle = if (subtitle.isNullOrBlank()) null else ({ Text(subtitle, maxLines = 2, overflow = TextOverflow.Ellipsis) }),
      titleHorizontalAlignment = if (centerAligned) Alignment.CenterHorizontally else Alignment.Start,
      navigationIcon = { leadingContent() },
      actions = { actionContent() },
      expandedHeight = expandedHeight,
      collapsedHeight = collapsedHeight,
      colors = colors,
      scrollBehavior = scrollBehavior,
    )
  } else if (variant == "largeFlexible") {
    LargeFlexibleTopAppBar(
      title = { titleContent(maxLines = 2, includeSubtitle = false) },
      modifier = heightReporter,
      subtitle = if (subtitle.isNullOrBlank()) null else ({ Text(subtitle, maxLines = 2, overflow = TextOverflow.Ellipsis) }),
      titleHorizontalAlignment = if (centerAligned) Alignment.CenterHorizontally else Alignment.Start,
      navigationIcon = { leadingContent() },
      actions = { actionContent() },
      expandedHeight = expandedHeight,
      collapsedHeight = collapsedHeight,
      colors = colors,
      scrollBehavior = scrollBehavior,
    )
  } else {
    val appBar = @Composable {
      if (!subtitle.isNullOrBlank()) {
        TopAppBar(
          title = { titleContent(maxLines = 1, includeSubtitle = false) },
          subtitle = { Text(subtitle, maxLines = 1, overflow = TextOverflow.Ellipsis) },
          titleHorizontalAlignment = if (centerAligned) Alignment.CenterHorizontally else Alignment.Start,
          modifier = heightReporter,
          navigationIcon = { leadingContent() },
          actions = { actionContent() },
          colors = colors,
          scrollBehavior = scrollBehavior,
        )
      } else if (centerAligned) {
        CenterAlignedTopAppBar(
          title = { titleContent(maxLines = 1) },
          modifier = heightReporter,
          navigationIcon = { leadingContent() },
          actions = { actionContent() },
          colors = colors,
          scrollBehavior = scrollBehavior,
        )
      } else {
        TopAppBar(
          title = { titleContent(maxLines = 1) },
          modifier = heightReporter,
          navigationIcon = { leadingContent() },
          actions = { actionContent() },
          colors = colors,
          scrollBehavior = scrollBehavior,
        )
      }
    }
    appBar()
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EBottomNavigationBar(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val destinations = properties["destinations"] as? List<*> ?: emptyList<Any?>()
  if (destinations.isEmpty()) return
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: -1
  val selectedColor = properties.color("selectedColor")
  val unselectedColor = properties.color("unselectedColor")
  val hideLabels = properties.boolean("hideLabels")
  val interactive = properties.boolean("interactive", true)
  val short = properties["style"] == "short"
  fun selectionEvent(index: Int, destination: Map<*, *>): Any {
    val id = (destination["id"] as? Number)?.toLong()
    return if (id == null) index else mapOf("index" to index, "id" to id)
  }
  if (short) {
    BoxWithConstraints(Modifier.fillMaxWidth()) {
      val mediumWidth = maxWidth >= 600.dp
      ShortNavigationBar(
        modifier = Modifier.fillMaxWidth(),
        containerColor = properties.color("backgroundColor") ?: ShortNavigationBarDefaults.containerColor,
        contentColor = properties.color("contentColor") ?: ShortNavigationBarDefaults.contentColor,
        arrangement = if (mediumWidth) {
          ShortNavigationBarArrangement.Centered
        } else {
          ShortNavigationBarArrangement.EqualWeight
        },
      ) {
        destinations.forEachIndexed { index, rawDestination ->
          val destination = rawDestination as? Map<*, *> ?: return@forEachIndexed
          val label = destination["label"] as? String ?: ""
          val visibleLabel = label.takeIf { it.isNotBlank() && !hideLabels }
          val selected = index == selectedIndex
          val iconName = if (selected) {
            destination["selectedIcon"] as? String ?: destination["icon"] as? String
          } else destination["icon"] as? String
          val iconStyle = if (selected) {
            destination["selectedIconStyle"] as? Map<*, *> ?: destination["iconStyle"] as? Map<*, *>
          } else destination["iconStyle"] as? Map<*, *>
          val badgeCount = (destination["badgeCount"] as? Number)?.toInt() ?: 0
          val badgeSemanticsLabel = destination["badgeSemanticsLabel"] as? String
          ShortNavigationBarItem(
            selected = selected,
            enabled = interactive,
            onClick = { onEvent("destinationSelected", selectionEvent(index, destination)) },
            iconPosition = if (mediumWidth) NavigationItemIconPosition.Start else NavigationItemIconPosition.Top,
            colors = ShortNavigationBarItemDefaults.colors(
              selectedIndicatorColor = selectedColor ?: Color.Unspecified,
              unselectedIconColor = unselectedColor ?: Color.Unspecified,
              unselectedTextColor = unselectedColor ?: Color.Unspecified,
            ),
            icon = { NativeM3ENavigationIcon(iconName, iconStyle, badgeCount, if (visibleLabel == null) label else null, badgeSemanticsLabel) },
            label = visibleLabel?.let { { Text(it) } },
          )
        }
      }
    }
    return
  }
  val containerColor = properties.color("backgroundColor") ?: NavigationBarDefaults.containerColor
  NavigationBar(
    modifier = Modifier.fillMaxWidth(),
    containerColor = containerColor,
    contentColor = properties.color("contentColor") ?: contentColorFor(containerColor),
    tonalElevation = properties.number("tonalElevation")?.dp ?: NavigationBarDefaults.Elevation,
  ) {
    destinations.forEachIndexed { index, rawDestination ->
      val destination = rawDestination as? Map<*, *> ?: return@forEachIndexed
      val label = destination["label"] as? String ?: ""
      val visibleLabel = label.takeIf { it.isNotBlank() && !hideLabels }
      val selected = index == selectedIndex
      val iconName = if (selected) {
        destination["selectedIcon"] as? String ?: destination["icon"] as? String
      } else destination["icon"] as? String
      val iconStyle = if (selected) {
        destination["selectedIconStyle"] as? Map<*, *> ?: destination["iconStyle"] as? Map<*, *>
      } else destination["iconStyle"] as? Map<*, *>
      val badgeCount = (destination["badgeCount"] as? Number)?.toInt() ?: 0
      val badgeSemanticsLabel = destination["badgeSemanticsLabel"] as? String
      NavigationBarItem(
        selected = selected,
        enabled = interactive,
        onClick = { onEvent("destinationSelected", selectionEvent(index, destination)) },
        colors = NavigationBarItemDefaults.colors(
          indicatorColor = selectedColor ?: Color.Unspecified,
          unselectedIconColor = unselectedColor ?: Color.Unspecified,
          unselectedTextColor = unselectedColor ?: Color.Unspecified,
        ),
        icon = { NativeM3ENavigationIcon(iconName, iconStyle, badgeCount, if (visibleLabel == null) label else null, badgeSemanticsLabel) },
        label = visibleLabel?.let { { Text(it) } },
        alwaysShowLabel = visibleLabel != null,
      )
    }
  }
}

@Composable
private fun NativeM3ENavigationIcon(
  iconName: String?,
  iconStyle: Map<*, *>?,
  badgeCount: Int,
  contentDescription: String?,
  badgeSemanticsLabel: String?,
) {
  val nativeIcon = nativeM3EIcon(iconName)
  val iconSize = (iconStyle?.get("size") as? Number)?.toFloat()?.dp
  val iconTint = (iconStyle?.get("color") as? Number)?.toLong()?.toInt()?.let(::Color)
    ?: LocalContentColor.current
  val iconDescription = contentDescription?.let {
    (iconStyle?.get("semanticLabel") as? String)?.takeIf(String::isNotBlank) ?: it
  }
  val iconContent: @Composable () -> Unit = {
    Icon(
      nativeIcon,
      contentDescription = iconDescription,
      modifier = iconSize?.let { Modifier.size(it) } ?: Modifier,
      tint = iconTint,
    )
  }
  if (badgeCount > 0) {
    BadgedBox(badge = {
      Badge {
        Text(
          if (badgeCount > 99) "99+" else badgeCount.toString(),
          modifier = badgeSemanticsLabel?.takeIf { it.isNotBlank() }
            ?.let { description -> Modifier.semantics { this.contentDescription = description } }
            ?: Modifier,
        )
      }
    }) { iconContent() }
  } else {
    iconContent()
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EButtonGroup(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  if (actions.isEmpty()) return
  val hasEnabledAction = actions.any { (it as? Map<*, *>)?.get("enabled") != false }
  var pendingSelection by remember { mutableStateOf<Any?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  val multiSelect = properties.boolean("multiSelect")
  val selectedIndex = properties.number("selectedIndex")?.toInt()
    ?: actions.indexOfFirst { (it as? Map<*, *>)?.get("checked") == true }
  val selectedIndices = (properties["selectedIndices"] as? List<*>)
    ?.mapNotNull { (it as? Number)?.toInt() }
    ?.toSet()
    ?: actions.mapIndexedNotNull { index, item ->
      index.takeIf { (item as? Map<*, *>)?.get("checked") == true }
    }.toSet()
  val size = when (properties["size"] as? String) {
    "extraSmall" -> ToggleButtonSize.ExtraSmall
    "small" -> ToggleButtonSize.Small
    "extraLarge" -> ToggleButtonSize.ExtraLarge
    "large" -> ToggleButtonSize.Large
    else -> ToggleButtonSize.Medium
  }
  val style = properties["style"] as? String ?: "filled"
  val groupType = properties["type"] as? String ?: "standard"
  val connected = groupType == "connected"
  val vertical = properties["direction"] == "vertical"
  val selectionRequired = properties.boolean("selectionRequired")
  val spacing = properties.number("spacing")?.dp ?: when {
    connected && vertical -> (-6).dp
    connected -> ButtonGroupDefaults.ConnectedSpaceBetween
    else -> ButtonGroupDefaults.HorizontalArrangement.spacing
  }
  val layoutDirection = LocalLayoutDirection.current
  val density = LocalDensity.current
  val sizeReporter = Modifier.wrapContentHeight(unbounded = true).onSizeChanged { size ->
    onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
    onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
  }

  fun canChangeSelection(checked: Boolean, next: Boolean): Boolean {
    val selectedCount = if (multiSelect) selectedIndices.size else if (selectedIndex >= 0) 1 else 0
    return !(selectionRequired && checked && !next && selectedCount <= 1)
  }

  fun selectionEvent(index: Int, checked: Boolean, item: Map<*, *>): Any {
    val id = (item["id"] as? Number)?.toLong()
    return if (id == null) listOf(index, checked)
      else mapOf("index" to index, "id" to id, "checked" to checked)
  }

  @Composable
  fun renderButton(
    index: Int,
    item: Map<*, *>,
    modifier: Modifier = Modifier,
    focusModifier: Modifier = Modifier,
    fillTooltipWidth: Boolean = false,
    interactionSource: MutableInteractionSource? = null,
  ) {
    val checked = if (multiSelect) index in selectedIndices else index == selectedIndex
    val enabled = item["enabled"] as? Boolean ?: true
    val label = if (checked) item["checkedLabel"] as? String ?: item["label"] as? String ?: ""
      else item["label"] as? String ?: ""
    val iconName = if (checked) item["checkedIcon"] as? String ?: item["icon"] as? String
      else item["icon"] as? String
    val iconOnly = label.isBlank() && iconName != null
    val explicitSemanticLabel = (item["explicitSemanticLabel"] as? String)?.takeIf { it.isNotBlank() }
    val semanticLabel = explicitSemanticLabel
      ?: if (label.isBlank()) (item["semanticLabel"] as? String)?.takeIf { it.isNotBlank() } else null
    val semanticModifier = semanticLabel?.let { name ->
      Modifier.semantics { contentDescription = name }
    } ?: Modifier
    val itemId = (item["id"] as? Number)?.toLong() ?: index.toLong()
    val itemInteractionSource = interactionSource ?: remember(itemId) { MutableInteractionSource() }
    val click: (Boolean) -> Unit = { next ->
      if (canChangeSelection(checked, next)) {
        onEvent("selectionChanged", selectionEvent(index, next, item))
      }
    }
    val iconSlot: (@Composable () -> Unit)? = iconName?.takeUnless { iconOnly }?.let {
      { Icon(nativeM3EIcon(it), contentDescription = null) }
    }
    @Composable
    fun buttonContent() {
      if (iconOnly) {
        Icon(
          nativeM3EIcon(iconName),
          contentDescription = null,
          modifier = Modifier.size(ButtonDefaults.iconSizeFor(size.height)),
        )
      } else {
        Text(label)
      }
    }
    val shapes = when {
      !connected || actions.size == 1 -> ToggleButtonDefaults.shapesFor(size)
      properties["direction"] == "vertical" -> {
        val middle = ButtonGroupDefaults.connectedMiddleButtonShapes()
        fun withVerticalEnd(shape: Shape): Shape {
          val rounded = shape as? RoundedCornerShape ?: return shape
          return when (index) {
            0 -> rounded.copy(topStart = CornerSize(100), topEnd = CornerSize(100))
            actions.lastIndex -> rounded.copy(
              bottomStart = CornerSize(100),
              bottomEnd = CornerSize(100),
            )
            else -> rounded
          }
        }
        middle.copy(
          shape = withVerticalEnd(middle.shape),
          pressedShape = withVerticalEnd(middle.pressedShape),
        )
      }
      index == 0 -> ButtonGroupDefaults.connectedLeadingButtonShapes()
      index == actions.lastIndex -> ButtonGroupDefaults.connectedTrailingButtonShapes()
      else -> ButtonGroupDefaults.connectedMiddleButtonShapes()
    }
    @Composable
    fun button(buttonModifier: Modifier) {
      when (style) {
      "tonal" -> FilledTonalToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = buttonModifier.then(semanticModifier),
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { buttonContent() }
      "outlined" -> OutlinedToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = buttonModifier.then(semanticModifier),
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { buttonContent() }
      "elevated" -> ElevatedToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = buttonModifier.then(semanticModifier),
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { buttonContent() }
      else -> ToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = buttonModifier.then(semanticModifier),
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { buttonContent() }
      }
    }
    val tooltip = (item["tooltip"] as? String)?.takeIf { it.isNotBlank() }
    if (tooltip == null) {
      button(focusModifier.then(modifier))
    } else {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
        tooltip = { NativeM3EPlainActionTooltip(tooltip) },
        state = rememberTooltipState(),
        modifier = modifier,
      ) {
        button(focusModifier.then(if (fillTooltipWidth) Modifier.fillMaxWidth() else Modifier))
      }
    }
  }

  if (vertical) {
    val actionIds = actions.mapIndexed { index, raw ->
      ((raw as? Map<*, *>)?.get("id") as? Number)?.toLong() ?: index.toLong()
    }
    val focusRequesters = remember(actionIds) { List(actions.size) { FocusRequester() } }
    val focusedIndex = remember(actionIds) { mutableStateOf(-1) }
    val enabledIndices = actions.indices.filter { index ->
      (actions[index] as? Map<*, *>)?.get("enabled") != false
    }
    Column(
      modifier = Modifier
        .wrapContentWidth(unbounded = properties.boolean("allowIntrinsicWidth"))
        .then(sizeReporter)
        .onPreviewKeyEvent { event ->
        if (event.type != KeyEventType.KeyDown) return@onPreviewKeyEvent false
        val position = enabledIndices.indexOf(focusedIndex.value)
        if (position < 0 || enabledIndices.isEmpty()) return@onPreviewKeyEvent false
        val delta = when (event.key) {
          Key.DirectionDown -> 1
          Key.DirectionUp -> -1
          else -> 0
        }
        if (delta == 0) return@onPreviewKeyEvent false
        val nextPosition = (position + delta + enabledIndices.size) % enabledIndices.size
        focusRequesters[enabledIndices[nextPosition]].requestFocus()
      },
      verticalArrangement = Arrangement.spacedBy(spacing),
    ) {
      actions.forEachIndexed { index, raw ->
        val item = raw as? Map<*, *> ?: return@forEachIndexed
        key(actionIds[index]) {
          renderButton(
            index,
            item,
            focusModifier = Modifier
              .focusRequester(focusRequesters[index])
              .onFocusChanged { if (it.isFocused) focusedIndex.value = index },
          )
        }
      }
    }
  } else {
      ButtonGroup(
      overflowIndicator = { menuState ->
        ButtonGroupDefaults.OverflowIndicator(
          menuState = menuState,
          enabled = pendingSelection == null && hasEnabledAction,
        )
      },
      modifier = (if (connected) Modifier.fillMaxWidth()
        else Modifier.wrapContentWidth(unbounded = properties.boolean("allowIntrinsicWidth")))
        .then(sizeReporter),
      expandedRatio = if (!connected && properties.boolean("neighborSquish", true)) {
        ButtonGroupDefaults.ExpandedRatio
      } else 0f,
      horizontalArrangement = Arrangement.spacedBy(
        spacing,
      ),
    ) {
      actions.forEachIndexed { index, raw ->
        val item = raw as? Map<*, *> ?: return@forEachIndexed
        val checked = if (multiSelect) index in selectedIndices else index == selectedIndex
        val enabled = item["enabled"] as? Boolean ?: true
        val label = if (checked) item["checkedLabel"] as? String ?: item["label"] as? String ?: ""
          else item["label"] as? String ?: ""
        val menuLabel = label.takeIf { it.isNotBlank() }
          ?: (item["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
          ?: (item["tooltip"] as? String)?.takeIf { it.isNotBlank() }
          ?: return@forEachIndexed
        val hasIcon = (if (checked) item["checkedIcon"] as? String ?: item["icon"] as? String
          else item["icon"] as? String) != null
        customItem(
          buttonGroupContent = {
            val itemId = (item["id"] as? Number)?.toLong() ?: index.toLong()
            key(itemId) {
              val interactionSource = remember { MutableInteractionSource() }
              val contentPadding = when (style) {
                "tonal" -> FilledTonalToggleButtonDefaults.contentPaddingFor(size, hasStartIcon = hasIcon && label.isNotBlank())
                "outlined" -> OutlinedToggleButtonDefaults.contentPaddingFor(size, hasStartIcon = hasIcon && label.isNotBlank())
                "elevated" -> ElevatedToggleButtonDefaults.contentPaddingFor(size, hasStartIcon = hasIcon && label.isNotBlank())
                else -> ToggleButtonDefaults.contentPaddingFor(size, hasStartIcon = hasIcon && label.isNotBlank())
              }
              val widthModifier = if (connected) Modifier.weight(1f)
                else if (properties.boolean("neighborSquish", true)) Modifier.animateWidth(
                  interactionSource = interactionSource,
                  compressionLimit = contentPadding.calculateEndPadding(layoutDirection),
                )
                else Modifier
              renderButton(
                index,
                item,
                modifier = widthModifier,
                fillTooltipWidth = connected || properties.boolean("neighborSquish", true),
                interactionSource = interactionSource,
              )
            }
          },
          menuContent = { menuState ->
            DisposableEffect(menuState) {
              onDispose {
                val selection = pendingSelection
                if (selection != null && !menuState.isShowing) {
                  pendingSelection = null
                  currentOnEvent("selectionChanged", selection)
                }
              }
            }
            val onSelectionChange: (Boolean) -> Unit = { next ->
                if (pendingSelection == null && canChangeSelection(checked, next)) {
                  pendingSelection = selectionEvent(index, next, item)
                  menuState.dismiss()
                }
            }
            val leadingIcon = (item["icon"] as? String)
              ?.let { name -> @Composable { Icon(nativeM3EIcon(name), contentDescription = null) } }
            val checkedLeadingIcon = (item["checkedIcon"] as? String)
              ?.let { name -> @Composable { Icon(nativeM3EIcon(name), contentDescription = null) } }
            val trailingContent: (@Composable () -> Unit)? = if (checked) {
              { Icon(Icons.Filled.Check, contentDescription = null) }
            } else null
            val itemShapes = MenuDefaults.itemShapes()
            if (multiSelect) {
              CheckableDropdownMenuItem(
                checked = checked,
                onCheckedChange = onSelectionChange,
                text = { Text(menuLabel) },
                shapes = itemShapes,
                enabled = enabled,
                leadingIcon = leadingIcon,
                checkedLeadingIcon = checkedLeadingIcon,
                trailingContent = trailingContent,
              )
            } else {
              SelectableDropdownMenuItem(
                selected = checked,
                onClick = { onSelectionChange(!checked) },
                text = { Text(menuLabel) },
                shapes = itemShapes,
                enabled = enabled,
                leadingIcon = leadingIcon,
                selectedLeadingIcon = checkedLeadingIcon,
                trailingContent = trailingContent,
              )
            }
          },
        )
      }
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EToolbar(
  properties: Map<String, Any?>,
  scrollEvents: ReceiveChannel<M3EToolbarScrollEvent>,
  onEvent: M3EAndroidEvent,
) {
  val title = properties["title"] as? String
  val titleTextOptions = properties["titleTextOptions"] as? Map<*, *>
  val titleColor = properties.color("titleColor")
  val leading = properties["leadingIcon"] as? String
  val trailing = properties["trailingIcon"] as? String
  val leadingDescription = (properties["leadingTooltip"] as? String)?.takeIf { it.isNotBlank() }
  val trailingDescription = (properties["trailingTooltip"] as? String)?.takeIf { it.isNotBlank() }
  val fabIcon = properties["fabIcon"] as? String
  val fabTooltip = (properties["fabTooltip"] as? String)?.takeIf { it.isNotBlank() }
  val fabEnabled = properties.boolean("fabEnabled", true)
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val activeIndex = properties.number("activeIndex")?.toInt() ?: -1
  val supportsSelection = properties["activeIndex"] is Number
  val docked = properties.boolean("docked")
  val floatingExpanded = properties.boolean("expanded", true)
  val context = LocalContext.current
  val accessibilityManager = remember(context) {
    context.getSystemService(android.content.Context.ACCESSIBILITY_SERVICE)
      as android.view.accessibility.AccessibilityManager
  }
  var touchExplorationEnabled by remember(accessibilityManager) {
    mutableStateOf(accessibilityManager.isTouchExplorationEnabled)
  }
  DisposableEffect(accessibilityManager) {
    val listener = android.view.accessibility.AccessibilityManager.TouchExplorationStateChangeListener {
      touchExplorationEnabled = it
    }
    accessibilityManager.addTouchExplorationStateChangeListener(listener)
    onDispose { accessibilityManager.removeTouchExplorationStateChangeListener(listener) }
  }
  val contentFocusable = docked || fabIcon == null || floatingExpanded || touchExplorationEnabled
  val nativeExitAlways = properties["scrollBehavior"] == "exitAlways"
  val dockedScrollBehavior = if (docked && nativeExitAlways) {
    BottomAppBarDefaults.exitAlwaysScrollBehavior()
  } else null
  val floatingScrollBehavior = if (!docked && nativeExitAlways) {
    FloatingToolbarDefaults.exitAlwaysScrollBehavior(
      exitDirection = if (properties["axis"] == "vertical") {
        FloatingToolbarExitDirection.End
      } else FloatingToolbarExitDirection.Bottom,
    )
  } else null
  val scrollConnection: NestedScrollConnection? =
    dockedScrollBehavior?.nestedScrollConnection ?: floatingScrollBehavior
  val toolbarDensity = LocalDensity.current
  val scrollDensity = toolbarDensity.density
  val currentToolbarOnEvent by rememberUpdatedState(onEvent)
  LaunchedEffect(scrollConnection, scrollEvents, scrollDensity) {
    if (scrollConnection != null) {
      var settleJob: Job? = null
      for (event in scrollEvents) {
        settleJob?.cancel()
        when {
          event.reset -> {
            dockedScrollBehavior?.state?.let {
              it.heightOffset = 0f
              it.contentOffset = 0f
            }
            floatingScrollBehavior?.state?.let {
              it.offset = 0f
              it.contentOffset = 0f
            }
            currentToolbarOnEvent("toolbarScrollResetApplied", event.resetToken)
          }
          event.settle -> {
            settleJob = launch {
              scrollConnection.onPostFling(Velocity.Zero, Velocity.Zero)
            }
          }
          else -> {
            scrollConnection.onPostScroll(
              Offset(0f, -event.logicalDelta * scrollDensity),
              Offset.Zero,
              NestedScrollSource.UserInput,
            )
          }
        }
      }
    }
  }
  LaunchedEffect(dockedScrollBehavior, floatingScrollBehavior) {
    if (scrollConnection != null) {
      snapshotFlow {
        dockedScrollBehavior?.let { 1f - it.state.collapsedFraction }
          ?: floatingScrollBehavior?.state?.let { state ->
            if (state.offsetLimit < 0f && state.offsetLimit.isFinite()) {
              1f - state.offset / state.offsetLimit
            } else 1f
          } ?: 1f
      }.distinctUntilChanged().collect { fraction ->
        if (fraction.isFinite()) {
          currentToolbarOnEvent("toolbarVisibleFraction", fraction.coerceIn(0f, 1f))
        }
      }
    }
  }
  val vibrant = properties["colorStyle"] == "vibrant"
  val standardColors = FloatingToolbarDefaults.standardFloatingToolbarColors()
  val vibrantColors = FloatingToolbarDefaults.vibrantFloatingToolbarColors()
  val floatingColors = if (vibrant) vibrantColors else standardColors
  val floatingContainer = properties.color("backgroundColor")
    ?: floatingColors.toolbarContainerColor
  val contentColor = properties.color("foregroundColor") ?: if (docked) {
    if (vibrant) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onSurface
  } else floatingColors.toolbarContentColor
  val disabledFabColors = if (fabEnabled) null else ButtonDefaults.buttonColors()
  val fabContainer = disabledFabColors?.disabledContainerColor
    ?: if (vibrant) vibrantColors.fabContainerColor else standardColors.fabContainerColor
  val fabContent = disabledFabColors?.disabledContentColor
    ?: if (vibrant) vibrantColors.fabContentColor else standardColors.fabContentColor
  val safeBottomInsetPx = with(LocalDensity.current) {
    (properties.number("safeBottomInset") ?: 0.0).dp.roundToPx()
  }
  val safeLeftInsetPx = with(LocalDensity.current) {
    (properties.number("safeLeftInset") ?: 0.0).dp.roundToPx()
  }
  val safeRightInsetPx = with(LocalDensity.current) {
    (properties.number("safeRightInset") ?: 0.0).dp.roundToPx()
  }
  val resolvedFloatingColors = if (properties.color("backgroundColor") != null || properties.color("foregroundColor") != null) {
    if (vibrant) FloatingToolbarDefaults.vibrantFloatingToolbarColors(
      toolbarContainerColor = floatingContainer,
      toolbarContentColor = contentColor,
    ) else FloatingToolbarDefaults.standardFloatingToolbarColors(
      toolbarContainerColor = floatingContainer,
      toolbarContentColor = contentColor,
    )
  } else floatingColors

  fun actionLabel(action: Map<*, *>): String? =
    (action["label"] as? String)?.takeIf { it.isNotBlank() }

  fun actionDescription(action: Map<*, *>): String? =
    (action["tooltip"] as? String)?.takeIf { it.isNotBlank() } ?: actionLabel(action)

  @Composable
  fun actionIcon(action: Map<*, *>) {
    val icon = action["icon"] as? String ?: return
    val label = actionDescription(action) ?: return
    Icon(
      nativeM3EIcon(icon),
      contentDescription = label,
    )
  }

  fun AppBarScope.addActions() {
    actions.forEachIndexed { index, rawAction ->
      val action = rawAction as? Map<*, *> ?: return@forEachIndexed
      val label = actionLabel(action) ?: return@forEachIndexed
      val tooltip = actionDescription(action) ?: label
      val enabled = action["enabled"] as? Boolean ?: true
      val event = nativeIndexedActionEvent(index, action)
      val onCheckedChange: (Boolean) -> Unit = { checked ->
        if (checked) onEvent("activeIndexChanged", event)
        onEvent("actionPressed", event)
      }
      if (tooltip != label) {
        // AppBarScope's regular item uses `label` for both its tooltip and
        // overflow text. Keep those caller-supplied strings independent.
        customItem(
          appbarContent = {
            TooltipBox(
              positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
              tooltip = { NativeM3EPlainActionTooltip(tooltip) },
              state = rememberTooltipState(),
            ) {
              if (supportsSelection) {
                IconToggleButton(
                  checked = index == activeIndex,
                  onCheckedChange = onCheckedChange,
                  enabled = enabled,
                  shapes = IconButtonDefaults.toggleableShapes(),
                ) { actionIcon(action) }
              } else {
                IconButton(
                  onClick = { onEvent("actionPressed", event) },
                  enabled = enabled,
                  shapes = IconButtonDefaults.shapes(),
                ) { actionIcon(action) }
              }
            }
          },
          menuContent = { state ->
            DropdownMenuItem(
              text = { Text(label) },
              enabled = enabled,
              onClick = {
                if (supportsSelection) onCheckedChange(index != activeIndex)
                else onEvent("actionPressed", event)
                state.dismiss()
              },
            )
          },
        )
      } else if (supportsSelection) {
        toggleableItem(
          checked = index == activeIndex,
          onCheckedChange = onCheckedChange,
          icon = { actionIcon(action) },
          label = label,
          enabled = enabled,
        )
      } else {
        clickableItem(
          onClick = { onEvent("actionPressed", event) },
          icon = { actionIcon(action) },
          label = label,
          enabled = enabled,
        )
      }
    }
  }

  @Composable
  fun actionRow(modifier: Modifier = Modifier) {
    AppBarRow(
      modifier = modifier,
      overflowIndicator = { state -> AppBarOverflowIndicator(menuState = state) },
    ) { addActions() }
  }

  @Composable
  fun actionColumn() {
    AppBarColumn(
      overflowIndicator = { state -> AppBarOverflowIndicator(menuState = state) },
    ) { addActions() }
  }

  @Composable
  fun actionWithTooltip(description: String?, content: @Composable () -> Unit) {
    if (description == null) {
      content()
    } else {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
        tooltip = { NativeM3EPlainActionTooltip(description) },
        state = rememberTooltipState(),
      ) { content() }
    }
  }

  @Composable
  fun edgeAction(icon: String, description: String?, enabled: Boolean, event: String) {
    actionWithTooltip(description) {
      IconButton(
        onClick = { onEvent(event, null) },
        enabled = enabled,
        shapes = IconButtonDefaults.shapes(),
      ) {
        Icon(
          nativeM3EIcon(icon),
          contentDescription = description,
        )
      }
    }
  }

  @Composable
  fun horizontalContent() {
    Row(
      modifier = Modifier.focusProperties { canFocus = contentFocusable },
      verticalAlignment = Alignment.CenterVertically,
    ) {
      if (leading != null) {
        edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
      }
      if (!title.isNullOrBlank()) {
        NativeM3EListText(
          title,
          titleTextOptions,
          titleColor ?: contentColor,
          maxLinesLimit = 1,
          defaultOverflow = TextOverflow.Ellipsis,
          modifier = Modifier.widthIn(max = 180.dp),
        )
      }
      actionRow()
      if (trailing != null) {
        edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
      }
    }
  }

  @Composable
  fun verticalContent() {
    Column(
      modifier = Modifier.focusProperties { canFocus = contentFocusable },
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      if (leading != null) {
        edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
      }
      if (!title.isNullOrBlank()) {
        NativeM3EListText(
          title, titleTextOptions, titleColor ?: contentColor,
          maxLinesLimit = 1,
          defaultOverflow = TextOverflow.Ellipsis,
        )
      }
      actionColumn()
      if (trailing != null) {
        edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
      }
    }
  }

  if (docked) {
    val dockedContainer = properties.color("backgroundColor") ?: if (vibrant) {
      MaterialTheme.colorScheme.primaryContainer
    } else MaterialTheme.colorScheme.surfaceContainer
    val dockedContent = properties.color("foregroundColor") ?: if (vibrant) {
      MaterialTheme.colorScheme.onPrimaryContainer
    } else MaterialTheme.colorScheme.onSurface
    FlexibleBottomAppBar(
      expandedHeight = BottomAppBarDefaults.FlexibleBottomAppBarHeight,
      contentPadding = BottomAppBarDefaults.FlexibleContentPadding,
      horizontalArrangement = BottomAppBarDefaults.FlexibleHorizontalArrangement,
      containerColor = dockedContainer,
      contentColor = dockedContent,
      windowInsets = androidx.compose.foundation.layout.WindowInsets(
        left = safeLeftInsetPx,
        right = safeRightInsetPx,
        bottom = safeBottomInsetPx,
      ),
      scrollBehavior = dockedScrollBehavior,
    ) {
      if (leading != null) {
        edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
      }
      if (!title.isNullOrBlank()) {
        NativeM3EListText(
          title, titleTextOptions, titleColor ?: contentColor,
          maxLinesLimit = 1,
          modifier = Modifier.weight(1f),
        )
      }
      Box(modifier = Modifier.weight(1f)) { actionRow(Modifier.fillMaxWidth()) }
      if (trailing != null) {
        edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
      }
    }
  } else {
    val expanded = floatingExpanded
    val shadowElevation = properties.number("elevation")?.dp
    val floating = @Composable {
      if (fabIcon != null) {
        actionWithTooltip(fabTooltip) {
          if (vibrant) {
            FloatingToolbarDefaults.VibrantFloatingActionButton(
              onClick = { if (fabEnabled) onEvent("fabPressed", null) },
              modifier = nativeFabInteractionModifier(fabEnabled, fabTooltip),
              containerColor = fabContainer,
              contentColor = fabContent,
            ) { Icon(nativeM3EIcon(fabIcon), contentDescription = fabTooltip) }
          } else {
            FloatingToolbarDefaults.StandardFloatingActionButton(
              onClick = { if (fabEnabled) onEvent("fabPressed", null) },
              modifier = nativeFabInteractionModifier(fabEnabled, fabTooltip),
              containerColor = fabContainer,
              contentColor = fabContent,
            ) { Icon(nativeM3EIcon(fabIcon), contentDescription = fabTooltip) }
          }
        }
      }
    }
    val floatingSizeReporter = Modifier.onSizeChanged { size ->
        onEvent("measuredWidth", with(toolbarDensity) { size.width.toDp().value.toDouble() })
        onEvent("measuredHeight", with(toolbarDensity) { size.height.toDp().value.toDouble() })
    }
    if (properties["axis"] == "vertical") {
      if (fabIcon == null) {
        val hasActions = actions.isNotEmpty()
        val primaryIsLeading = !hasActions && leading != null
        val primaryIsTrailing = !hasActions && leading == null && trailing != null
        VerticalFloatingToolbar(
          expanded = expanded,
          modifier = floatingSizeReporter,
          colors = resolvedFloatingColors,
          scrollBehavior = floatingScrollBehavior,
          leadingContent = if ((hasActions && leading != null) ||
            ((hasActions || primaryIsTrailing) && !title.isNullOrBlank())) ({
            if (hasActions && leading != null) {
              edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
            }
            if ((hasActions || primaryIsTrailing) && !title.isNullOrBlank()) {
              NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor, maxLinesLimit = 1,
                defaultOverflow = TextOverflow.Ellipsis)
            }
          }) else null,
          trailingContent = if ((primaryIsLeading && !title.isNullOrBlank()) ||
            (!primaryIsTrailing && trailing != null)) ({
            if (primaryIsLeading && !title.isNullOrBlank()) {
              NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor, maxLinesLimit = 1,
                defaultOverflow = TextOverflow.Ellipsis)
            }
            if (!primaryIsTrailing && trailing != null) {
              edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
            }
          }) else null,
          expandedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerExpandedElevation,
          collapsedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerCollapsedElevation,
        ) {
          when {
            hasActions -> actionColumn()
            primaryIsLeading -> edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
            primaryIsTrailing -> edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
            !title.isNullOrBlank() -> NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor,
              maxLinesLimit = 1, defaultOverflow = TextOverflow.Ellipsis)
          }
        }
      } else {
        VerticalFloatingToolbar(
          expanded = expanded,
          modifier = floatingSizeReporter,
          colors = resolvedFloatingColors,
          floatingActionButton = floating,
          scrollBehavior = floatingScrollBehavior,
          expandedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerExpandedElevationWithFab,
          collapsedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerCollapsedElevationWithFab,
        ) { verticalContent() }
      }
    } else {
      if (fabIcon == null) {
        val hasActions = actions.isNotEmpty()
        val primaryIsLeading = !hasActions && leading != null
        val primaryIsTrailing = !hasActions && leading == null && trailing != null
        HorizontalFloatingToolbar(
          expanded = expanded,
          modifier = floatingSizeReporter,
          colors = resolvedFloatingColors,
          scrollBehavior = floatingScrollBehavior,
          leadingContent = if ((hasActions && leading != null) ||
            ((hasActions || primaryIsTrailing) && !title.isNullOrBlank())) ({
            if (hasActions && leading != null) {
              edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
            }
            if ((hasActions || primaryIsTrailing) && !title.isNullOrBlank()) {
              NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor, maxLinesLimit = 1,
                defaultOverflow = TextOverflow.Ellipsis, modifier = Modifier.widthIn(max = 180.dp))
            }
          }) else null,
          trailingContent = if ((primaryIsLeading && !title.isNullOrBlank()) ||
            (!primaryIsTrailing && trailing != null)) ({
            if (primaryIsLeading && !title.isNullOrBlank()) {
              NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor, maxLinesLimit = 1,
                defaultOverflow = TextOverflow.Ellipsis, modifier = Modifier.widthIn(max = 180.dp))
            }
            if (!primaryIsTrailing && trailing != null) {
              edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
            }
          }) else null,
          expandedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerExpandedElevation,
          collapsedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerCollapsedElevation,
        ) {
          when {
            hasActions -> actionRow()
            primaryIsLeading -> edgeAction(leading, leadingDescription, properties.boolean("leadingEnabled"), "leadingPressed")
            primaryIsTrailing -> edgeAction(trailing, trailingDescription, properties.boolean("trailingEnabled"), "trailingPressed")
            !title.isNullOrBlank() -> NativeM3EListText(title, titleTextOptions, titleColor ?: contentColor,
              maxLinesLimit = 1, defaultOverflow = TextOverflow.Ellipsis, modifier = Modifier.widthIn(max = 180.dp))
          }
        }
      } else {
        HorizontalFloatingToolbar(
          expanded = expanded,
          modifier = floatingSizeReporter,
          colors = resolvedFloatingColors,
          floatingActionButton = floating,
          scrollBehavior = floatingScrollBehavior,
          expandedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerExpandedElevationWithFab,
          collapsedShadowElevation = shadowElevation ?: FloatingToolbarDefaults.ContainerCollapsedElevationWithFab,
        ) { horizontalContent() }
      }
    }
  }
}

private data class M3ESplitButtonPendingSelection(val index: Int, val id: Long?)

@OptIn(ExperimentalMaterial3ExpressiveApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ESplitButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  var expanded by remember { mutableStateOf(false) }
  var pendingSelection by remember { mutableStateOf<M3ESplitButtonPendingSelection?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: -1
  val label = properties["label"] as? String ?: ""
  val iconName = properties["leadingIcon"] as? String
  val menuButtonLabel = properties["menuButtonSemanticLabel"] as? String
    ?: "More $label options"
  val expandedStateLabel = properties["expandedStateLabel"] as? String ?: "Expanded"
  val collapsedStateLabel = properties["collapsedStateLabel"] as? String ?: "Collapsed"
  val primaryEnabled = properties.boolean("primaryEnabled")
  val menuEnabled = enabled && properties.boolean("menuEnabled", true)
  LaunchedEffect(menuEnabled) { if (!menuEnabled) expanded = false }
  val buttonHeight = when (properties["size"] as? String) {
    "extraSmall" -> SplitButtonDefaults.ExtraSmallContainerHeight
    "small" -> SplitButtonDefaults.SmallContainerHeight
    "medium" -> SplitButtonDefaults.MediumContainerHeight
    "large" -> SplitButtonDefaults.LargeContainerHeight
    "extraLarge" -> SplitButtonDefaults.ExtraLargeContainerHeight
    else -> SplitButtonDefaults.SmallContainerHeight
  }
  val style = properties["style"] as? String ?: "filled"
  val density = LocalDensity.current
  val arrowRotation by animateFloatAsState(
    targetValue = if (expanded) 180f else 0f,
    animationSpec = MaterialTheme.motionScheme.fastSpatialSpec(),
    label = "splitButtonMenuArrowRotation",
  )

  @Composable
  fun leadingContent() {
    Row(
      horizontalArrangement = Arrangement.spacedBy(ButtonDefaults.iconSpacingFor(buttonHeight)),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      if (iconName != null) Icon(
        nativeM3EIcon(iconName),
        contentDescription = null,
        modifier = Modifier.size(SplitButtonDefaults.leadingButtonIconSizeFor(buttonHeight)),
      )
      Text(label, style = ButtonDefaults.textStyleFor(buttonHeight))
    }
  }

  @Composable
  fun trailingContent() {
    Icon(
      imageVector = Icons.Filled.ArrowDropDown,
      contentDescription = null,
      modifier = Modifier.size(SplitButtonDefaults.trailingButtonIconSizeFor(buttonHeight)).rotate(arrowRotation),
    )
  }

  Box {
    SplitButtonLayout(
      modifier = Modifier
        .wrapContentWidth(unbounded = properties.boolean("allowIntrinsicWidth"))
        .wrapContentHeight(unbounded = true)
        .onSizeChanged { size ->
          onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
          onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
        },
      leadingButton = {
        val shapes = SplitButtonDefaults.leadingButtonShapesFor(buttonHeight)
        val contentPadding = SplitButtonDefaults.leadingButtonContentPaddingFor(buttonHeight)
        when (style) {
          "tonal" -> SplitButtonDefaults.TonalLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            modifier = Modifier.heightIn(min = buttonHeight),
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          "outlined" -> SplitButtonDefaults.OutlinedLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            modifier = Modifier.heightIn(min = buttonHeight),
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          "elevated" -> SplitButtonDefaults.ElevatedLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            modifier = Modifier.heightIn(min = buttonHeight),
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          else -> SplitButtonDefaults.LeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            modifier = Modifier.heightIn(min = buttonHeight),
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
        }
      },
      trailingButton = {
        Box {
          val shapes = SplitButtonDefaults.trailingButtonShapesFor(buttonHeight)
          val contentPadding = SplitButtonDefaults.trailingButtonContentPaddingFor(buttonHeight)
          val onCheckedChange: (Boolean) -> Unit = {
            if (menuEnabled && pendingSelection == null) expanded = it
          }
          val trailingModifier = Modifier.heightIn(min = buttonHeight).semantics {
            contentDescription = menuButtonLabel
            stateDescription = if (expanded) expandedStateLabel else collapsedStateLabel
          }
          TooltipBox(
            positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
            tooltip = {
              PlainTooltip(modifier = Modifier.semantics {
                liveRegion = LiveRegionMode.Assertive
                paneTitle = menuButtonLabel
              }) { Text(menuButtonLabel) }
            },
            state = rememberTooltipState(),
          ) {
            when (style) {
              "tonal" -> SplitButtonDefaults.TonalTrailingButton(
                checked = expanded,
                onCheckedChange = onCheckedChange,
                modifier = trailingModifier,
                enabled = menuEnabled,
                shapes = shapes,
                contentPadding = contentPadding,
              ) { trailingContent() }
              "outlined" -> SplitButtonDefaults.OutlinedTrailingButton(
                checked = expanded,
                onCheckedChange = onCheckedChange,
                modifier = trailingModifier,
                enabled = menuEnabled,
                shapes = shapes,
                contentPadding = contentPadding,
              ) { trailingContent() }
              "elevated" -> SplitButtonDefaults.ElevatedTrailingButton(
                checked = expanded,
                onCheckedChange = onCheckedChange,
                modifier = trailingModifier,
                enabled = menuEnabled,
                shapes = shapes,
                contentPadding = contentPadding,
              ) { trailingContent() }
              else -> SplitButtonDefaults.TrailingButton(
                checked = expanded,
                onCheckedChange = onCheckedChange,
                modifier = trailingModifier,
                enabled = menuEnabled,
                shapes = shapes,
                contentPadding = contentPadding,
              ) { trailingContent() }
            }
          }

          DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
          ) {
            DisposableEffect(Unit) {
              onDispose {
                val selection = pendingSelection
                if (selection != null) {
                  currentOnEvent(
                    "selected",
                    selection.id?.let { mapOf("index" to selection.index, "id" to it) }
                      ?: selection.index,
                  )
                  pendingSelection = null
                }
              }
            }
            items.forEachIndexed { index, rawItem ->
              val item = rawItem as? Map<*, *> ?: return@forEachIndexed
              val itemIcon = item["icon"] as? String
              SelectableDropdownMenuItem(
                selected = index == selectedIndex,
                text = { Text(item["label"] as? String ?: "") },
                shapes = MenuDefaults.itemShape(index, items.size),
                onClick = {
                  if (pendingSelection == null) {
                    pendingSelection = M3ESplitButtonPendingSelection(
                      index,
                      (item["id"] as? Number)?.toLong(),
                    )
                    expanded = false
                  }
                },
                enabled = menuEnabled && (item["enabled"] as? Boolean ?: true),
                leadingIcon = itemIcon?.let { { Icon(nativeM3EIcon(it), contentDescription = null) } },
                trailingContent = if (index == selectedIndex) ({ Icon(Icons.Filled.Check, contentDescription = null) }) else null,
              )
            }
          }
        }
      },
    )
  }
}

@Composable
private fun NativeM3EBadge(properties: Map<String, Any?>, onEvent: M3EAndroidEvent) {
  val label = properties["label"] as? String
  val background = properties.color("backgroundColor") ?: BadgeDefaults.containerColor
  val foreground = properties.color("textColor") ?: contentColorFor(background)
  val isLarge = properties.boolean("isLarge")
  val measurementKey = properties.number("measurementKey")?.toInt() ?: 0
  val semanticsLabel = (properties["semanticsLabel"] as? String)?.takeIf { it.isNotBlank() }
  val sizeModifier = if (isLarge) Modifier.heightIn(min = 24.dp).widthIn(min = 24.dp) else Modifier
  val density = LocalDensity.current
  val modifier = Modifier.wrapContentSize(unbounded = true)
    .then(sizeModifier)
    .onSizeChanged { size ->
      onEvent("measuredSize", mapOf(
        "key" to measurementKey,
        "width" to with(density) { size.width.toDp().value.toDouble() },
        "height" to with(density) { size.height.toDp().value.toDouble() },
      ))
    }
    .then(
    semanticsLabel?.let { label -> Modifier.clearAndSetSemantics { contentDescription = label } }
      ?: Modifier
    )
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    // A new label or font scale needs a fresh size report even if the final
    // Compose dimensions happen to match the previous badge.
    key(measurementKey) {
      if (label.isNullOrEmpty()) {
        Badge(modifier = modifier, containerColor = background, contentColor = foreground)
      } else {
        Badge(modifier = modifier, containerColor = background, contentColor = foreground) {
          Text(label, maxLines = 1)
        }
      }
    }
  }
}

@Composable
private fun NativeM3ESegmentedButton(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val labels = properties["labels"] as? List<*> ?: emptyList<Any?>()
  val icons = properties["icons"] as? List<*>
  val semanticLabels = properties["semanticLabels"] as? List<*>
  val count = maxOf(icons?.size ?: 0, labels.size)
  if (count == 0) return
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val enabled = properties.boolean("enabled", true)
  val selectedContainer = properties.color("selectedColor")
  val iconSize = properties.number("iconSize")?.dp ?: SegmentedButtonDefaults.IconSize
  val iconTint = properties.color("iconColor")
  val colors = SegmentedButtonDefaults.colors(
    activeContainerColor = selectedContainer ?: Color.Unspecified,
    activeContentColor = properties.color("selectedTextColor") ?: Color.Unspecified,
    inactiveContentColor = properties.color("textColor") ?: Color.Unspecified,
  )
  val density = LocalDensity.current
  val shrinkWrap = properties.boolean("shrinkWrap")
  val widthModifier = if (shrinkWrap) {
    Modifier.wrapContentWidth(unbounded = properties.boolean("allowIntrinsicWidth"))
  } else {
    Modifier.fillMaxWidth()
  }
  SingleChoiceSegmentedButtonRow(
    modifier = widthModifier
      .wrapContentHeight(unbounded = true)
      .heightIn(min = (properties.number("height") ?: 40.0).dp)
      .onSizeChanged { size ->
        onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
        if (shrinkWrap) {
          onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
        }
      },
  ) {
    (0 until count).forEach { index ->
      val label = labels.getOrNull(index) as? String ?: ""
      val icon = icons?.getOrNull(index) as? String
      val accessibleLabel = (semanticLabels?.getOrNull(index) as? String)
        ?.takeIf { it.isNotBlank() }
        ?: label.takeIf { it.isNotBlank() }
      val selected = index == selectedIndex
      SegmentedButton(
        selected = selected,
        onClick = { if (enabled) onEvent("selected", index) },
        enabled = enabled,
        shape = SegmentedButtonDefaults.itemShape(index = index, count = count),
        colors = colors,
        icon = {
          if (icon != null && label.isNotBlank()) {
            SegmentedButtonDefaults.Icon(
              active = selected,
              inactiveContent = {
                Icon(
                  nativeM3EIcon(icon),
                  contentDescription = null,
                  tint = iconTint ?: LocalContentColor.current,
                  modifier = Modifier.size(iconSize),
                )
              },
            )
          } else {
            SegmentedButtonDefaults.Icon(active = selected)
          }
        },
        label = {
          if (label.isNotBlank()) {
            Text(label, maxLines = 1)
          } else if (icon != null) {
            Icon(
              nativeM3EIcon(icon),
              contentDescription = accessibleLabel,
              tint = iconTint ?: LocalContentColor.current,
              modifier = Modifier.size(iconSize),
            )
          } else {
            Text(
              (index + 1).toString(),
              modifier = accessibleLabel?.let { name ->
                Modifier.semantics { contentDescription = name }
              } ?: Modifier,
            )
          }
        },
      )
    }
  }
}

@Composable
private fun NativeM3ETabs(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val labels = properties["labels"] as? List<*> ?: emptyList<Any?>()
  if (labels.isEmpty()) return
  val icons = properties["icons"] as? List<*>
  val showLabels = properties.boolean("showLabels", true)
  val secondary = properties["rowStyle"] == "secondary"
  val selectedIndex = (properties.number("selectedIndex") ?: 0.0).toInt().coerceIn(0, labels.lastIndex)
  val selectedColor = properties.color("selectedColor")
  val unselectedColor = properties.color("unselectedColor")
  val containerColor = properties.color("backgroundColor") ?: if (secondary) {
    TabRowDefaults.secondaryContainerColor
  } else TabRowDefaults.primaryContainerColor
  val contentColor = selectedColor ?: if (secondary) {
    TabRowDefaults.secondaryContentColor
  } else TabRowDefaults.primaryContentColor
  val density = LocalDensity.current
  val tabs: @Composable () -> Unit = {
    labels.forEachIndexed { index, rawLabel ->
      val label = rawLabel as? String ?: ""
      val iconName = icons?.getOrNull(index) as? String
      androidx.compose.material3.Tab(
        selected = selectedIndex == index,
        onClick = { onEvent("selected", index) },
        selectedContentColor = contentColor,
        unselectedContentColor = unselectedColor ?: MaterialTheme.colorScheme.onSurfaceVariant,
        text = if (showLabels) ({ Text(label, maxLines = 2, overflow = TextOverflow.Ellipsis) }) else null,
        icon = iconName?.let { name -> ({
          Icon(nativeM3EIcon(name), contentDescription = if (showLabels) null else label.takeIf { it.isNotBlank() })
        }) },
      )
    }
  }
  BoxWithConstraints(
    modifier = Modifier
      .fillMaxWidth()
      .wrapContentHeight(unbounded = true)
      .onSizeChanged { size ->
        onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
      },
  ) {
    val textMeasurer = rememberTextMeasurer()
    val labelStyle = MaterialTheme.typography.titleSmall
    val perTabWidth = maxWidth / labels.size.toFloat()
    val minimumFixedWidth = if (showLabels) TabRowDefaults.ScrollableTabRowMinTabWidth else 48.dp
    val canUseFixedRow = maxWidth.value.isFinite() &&
      perTabWidth >= minimumFixedWidth &&
      (!showLabels || labels.all { rawLabel ->
        val label = rawLabel as? String ?: ""
        val textWidthPx = with(density) { (perTabWidth - 32.dp).coerceAtLeast(1.dp).roundToPx() }
        !textMeasurer.measure(
          text = label,
          style = labelStyle,
          maxLines = 2,
          softWrap = true,
          overflow = TextOverflow.Clip,
          constraints = Constraints(maxWidth = textWidthPx),
        ).hasVisualOverflow
      })
    if (!canUseFixedRow) {
      if (secondary) {
        androidx.compose.material3.SecondaryScrollableTabRow(
          selectedTabIndex = selectedIndex,
          containerColor = containerColor,
          contentColor = contentColor,
          tabs = tabs,
        )
      } else {
        PrimaryScrollableTabRow(
          selectedTabIndex = selectedIndex,
          containerColor = containerColor,
          contentColor = contentColor,
          tabs = tabs,
        )
      }
    } else {
      if (secondary) {
        androidx.compose.material3.SecondaryTabRow(
          selectedTabIndex = selectedIndex,
          containerColor = containerColor,
          contentColor = contentColor,
          tabs = tabs,
        )
      } else {
        androidx.compose.material3.PrimaryTabRow(
          selectedTabIndex = selectedIndex,
          containerColor = containerColor,
          contentColor = contentColor,
          tabs = tabs,
        )
      }
    }
  }
}

private class NativeM3ECarouselGeometry {
  var viewport: LayoutCoordinates? = null
  val items = mutableMapOf<Int, Pair<LayoutCoordinates, CarouselItemDrawInfo>>()

  fun leadingVisibleIndex(itemCount: Int): Int? {
    val viewportBounds = viewport?.takeIf { it.isAttached }?.boundsInRoot() ?: return null
    return items.asSequence()
      .filter { (index, item) -> index in 0 until itemCount && item.first.isAttached }
      .filter { (_, item) ->
        val (coordinates, drawInfo) = item
        val mask = drawInfo.maskRect
        if (mask.width <= 0f || mask.height <= 0f) return@filter false
        val topLeft = coordinates.localToRoot(Offset(mask.left, mask.top))
        val bottomRight = coordinates.localToRoot(Offset(mask.right, mask.bottom))
        val left = minOf(topLeft.x, bottomRight.x)
        val right = maxOf(topLeft.x, bottomRight.x)
        val top = minOf(topLeft.y, bottomRight.y)
        val bottom = maxOf(topLeft.y, bottomRight.y)
        right > viewportBounds.left && left < viewportBounds.right &&
          bottom > viewportBounds.top && top < viewportBounds.bottom
      }
      .map { (index, _) -> index }
      .minOrNull()
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ECarousel(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  if (items.isEmpty()) return
  val type = properties["type"] as? String ?: "hero"
  if (type == "multiAspect") {
    NativeM3EMultiAspectCarousel(properties, items, onEvent)
    return
  }
  val state = rememberCarouselState { items.size }
  val itemIds = items.map { (it as? Map<*, *>)?.get("id") }
  val animationScope = rememberCoroutineScope()
  val geometry = remember { NativeM3ECarouselGeometry() }
  val currentOnEvent by rememberUpdatedState(onEvent)
  LaunchedEffect(state, itemIds) {
    var lastReportedPosition: Pair<Int, Int>? = null
    snapshotFlow { state.isScrollInProgress to state.currentItem }
      .distinctUntilChanged()
      .collect { (scrolling, _) ->
        if (scrolling) return@collect
        // Let the final carousel placement complete before reading item bounds.
        withFrameNanos { }
        withFrameNanos { }
        if (state.isScrollInProgress) return@collect
        val focal = state.currentItem
        if (focal !in items.indices) return@collect
        val leading = geometry.leadingVisibleIndex(items.size) ?: focal
        val position = leading to focal
        if (position != lastReportedPosition) {
          lastReportedPosition = position
          currentOnEvent("positionChanged", mapOf(
            "leadingIndex" to leading,
            "focalIndex" to focal,
            "leadingId" to (items[leading] as? Map<*, *>)?.get("id"),
            "focalId" to (items[focal] as? Map<*, *>)?.get("id"),
          ))
        }
      }
  }
  val itemWidth = properties.number("itemWidth")?.dp
  val viewportWidthDp = properties.number("viewportWidth")?.toFloat()
  val viewportHeightDp = properties.number("viewportHeight")?.toFloat()
  val itemSpacing = properties.number("itemSpacing")?.dp ?: CarouselDefaults.ItemSpacing
  val contentPadding = properties.number("contentPadding")?.dp
    ?.let { PaddingValues(horizontal = it) } ?: CarouselDefaults.ContentPadding
  val cardShape = properties.number("cornerRadius")?.dp
    ?.let { RoundedCornerShape(it) } ?: MaterialTheme.shapes.extraLarge
  val scrollAnimationDuration = properties.number("scrollAnimationDuration")?.toInt()
  val freeScroll = properties["freeScroll"] as? Boolean ?: false
  val userScrollEnabled = properties["userScrollEnabled"] as? Boolean ?: true
  val flingBehavior = if (freeScroll || type == "uncontained") {
    CarouselDefaults.noSnapFlingBehavior()
  } else {
    CarouselDefaults.singleAdvanceFlingBehavior(state)
  }
  val carouselModifier = Modifier.fillMaxWidth().fillMaxHeight()
    .onGloballyPositioned { geometry.viewport = it }
  val content: @Composable CarouselItemScope.(Int) -> Unit = { index ->
    DisposableEffect(index, geometry) {
      onDispose { geometry.items.remove(index) }
    }
    val item = items[index] as? Map<*, *> ?: emptyMap<Any?, Any?>()
    val drawInfo = carouselItemDrawInfo
    NativeM3ECarouselCard(
      item,
      cardShape,
      viewportWidthDp,
      viewportHeightDp,
      modifier = Modifier.fillMaxHeight()
        .onGloballyPositioned { geometry.items[index] = it to drawInfo }
        .maskClip(cardShape),
    ) {
      animationScope.launch {
        when (scrollAnimationDuration) {
          null -> state.animateScrollToItem(index)
          0 -> state.scrollToItem(index)
          else -> state.animateScrollToItem(index, tween(durationMillis = scrollAnimationDuration))
        }
      }
      val id = (item["id"] as? Number)?.toLong()
      onEvent("itemPressed", if (id == null) index else mapOf("index" to index, "id" to id))
    }
  }
  when (type) {
    "contained" -> HorizontalMultiBrowseCarousel(
      state = state,
      preferredItemWidth = itemWidth ?: 186.dp,
      modifier = carouselModifier,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = contentPadding,
      content = content,
    )
    "uncontained" -> HorizontalUncontainedCarousel(
      state = state,
      itemWidth = itemWidth ?: 186.dp,
      modifier = carouselModifier,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = contentPadding,
      content = content,
    )
    else -> HorizontalCenteredHeroCarousel(
      state = state,
      modifier = carouselModifier,
      preferredItemWidth = itemWidth ?: androidx.compose.ui.unit.Dp.Unspecified,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = contentPadding,
      content = content,
    )
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EMultiAspectCarousel(
  properties: Map<String, Any?>,
  items: List<*>,
  onEvent: M3EAndroidEvent,
) {
  val state = rememberLazyListState()
  val effectState = remember(state) { CarouselParallaxScrollEffectState(state) }
  val itemIds = items.map { (it as? Map<*, *>)?.get("id") }
  val currentOnEvent by rememberUpdatedState(onEvent)
  val animationScope = rememberCoroutineScope()
  val vertical = properties["axis"] == "vertical"
  val itemSpacing = properties.number("itemSpacing")?.dp ?: 8.dp
  val contentPadding = properties.number("contentPadding")?.dp
    ?.let { PaddingValues(it) } ?: PaddingValues(16.dp)
  val cardShape = properties.number("cornerRadius")?.dp
    ?.let { RoundedCornerShape(it) } ?: MaterialTheme.shapes.extraLarge
  val viewportWidthDp = properties.number("viewportWidth")?.toFloat()
  val viewportHeightDp = properties.number("viewportHeight")?.toFloat()
  val userScrollEnabled = properties["userScrollEnabled"] as? Boolean ?: true
  val scrollAnimationDuration = properties.number("scrollAnimationDuration")?.toInt()

  LaunchedEffect(state, itemIds) {
    var lastReportedPosition: Pair<Int, Int>? = null
    snapshotFlow { state.isScrollInProgress to state.layoutInfo }
      .collect { (scrolling, _) ->
        if (scrolling) return@collect
        withFrameNanos { }
        if (state.isScrollInProgress) return@collect
        val layout = state.layoutInfo
        val leading = layout.visibleItemsInfo.minOfOrNull { it.index } ?: return@collect
        val centerPx = (layout.viewportStartOffset + layout.viewportEndOffset) / 2
        val focal = layout.visibleItemsInfo.minByOrNull { info ->
          kotlin.math.abs(info.offset + info.size / 2 - centerPx)
        }?.index ?: leading
        if (leading !in items.indices || focal !in items.indices) return@collect
        val position = leading to focal
        if (position != lastReportedPosition) {
          lastReportedPosition = position
          currentOnEvent("positionChanged", mapOf(
            "leadingIndex" to leading,
            "focalIndex" to focal,
            "leadingId" to (items[leading] as? Map<*, *>)?.get("id"),
            "focalId" to (items[focal] as? Map<*, *>)?.get("id"),
          ))
        }
      }
  }

  @Composable
  fun itemContent(index: Int) {
    val item = items[index] as? Map<*, *> ?: emptyMap<Any?, Any?>()
    val extent = (item["mainAxisExtent"] as? Number)?.toFloat()?.dp ?: 186.dp
    val itemModifier = if (vertical) Modifier.height(extent).fillMaxWidth()
      else Modifier.width(extent).fillMaxHeight()
    NativeM3ECarouselCard(
      item,
      cardShape,
      viewportWidthDp,
      viewportHeightDp,
      modifier = itemModifier.carouselParallaxScrollEffect(index, effectState, cardShape),
    ) {
      animationScope.launch {
        if (scrollAnimationDuration == 0) state.scrollToItem(index)
        else state.animateScrollToItem(index)
      }
      val id = (item["id"] as? Number)?.toLong()
      onEvent("itemPressed", if (id == null) index else mapOf("index" to index, "id" to id))
    }
  }

  if (vertical) {
    LazyColumn(
      state = state,
      modifier = Modifier.fillMaxSize().semantics { role = Role.Carousel },
      verticalArrangement = Arrangement.spacedBy(itemSpacing),
      contentPadding = contentPadding,
      userScrollEnabled = userScrollEnabled,
    ) {
      items(count = items.size, key = { index -> itemIds[index] ?: index }) { index ->
        itemContent(index)
      }
    }
  } else {
    LazyRow(
      state = state,
      modifier = Modifier.fillMaxSize().semantics { role = Role.Carousel },
      horizontalArrangement = Arrangement.spacedBy(itemSpacing),
      contentPadding = contentPadding,
      userScrollEnabled = userScrollEnabled,
    ) {
      items(count = items.size, key = { index -> itemIds[index] ?: index }) { index ->
        itemContent(index)
      }
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ECarouselCard(
  item: Map<*, *>,
  cardShape: Shape,
  viewportWidthDp: Float?,
  viewportHeightDp: Float?,
  modifier: Modifier,
  onClick: () -> Unit,
) {
  val containerOverride = (item["containerColor"] as? Number)?.let { Color(it.toLong().toInt()) }
  val contentOverride = (item["contentColor"] as? Number)?.let { Color(it.toLong().toInt()) }
  val colors = when {
    containerOverride != null && contentOverride != null -> CardDefaults.cardColors(
      containerColor = containerOverride,
      contentColor = contentOverride,
    )
    containerOverride != null -> CardDefaults.cardColors(containerColor = containerOverride)
    contentOverride != null -> CardDefaults.cardColors(contentColor = contentOverride)
    else -> CardDefaults.cardColors()
  }
  val content = colors.contentColor
  val imageContent = contentOverride ?: Color.White
  val imageScrim = if (imageContent.luminance() > 0.179f) Color.Black else Color.White
  val title = item["title"] as? String ?: ""
  val supportingText = item["supportingText"] as? String
  val description = (item["semanticDescription"] as? String)?.takeIf { it.isNotBlank() }
  val imageBytes = item["imageBytes"] as? ByteArray
  val hasImage = imageBytes != null
  val configuration = LocalConfiguration.current
  val density = LocalDensity.current
  val targetWidthDp = viewportWidthDp?.takeIf { it.isFinite() && it > 0f }
    ?: configuration.screenWidthDp.toFloat().coerceAtLeast(1f)
  val targetHeightDp = viewportHeightDp?.takeIf { it.isFinite() && it > 0f }
    ?: configuration.screenHeightDp.toFloat().coerceAtLeast(1f)
  val targetWidthPx = with(density) { targetWidthDp.dp.roundToPx() }.coerceAtLeast(1)
  val targetHeightPx = with(density) { targetHeightDp.dp.roundToPx() }.coerceAtLeast(1)
  val image = rememberM3EImageBitmap(imageBytes, targetWidthPx, targetHeightPx)
  Card(
    onClick = onClick,
    modifier = modifier.then(description?.let { label -> Modifier.semantics { contentDescription = label } } ?: Modifier),
    shape = cardShape,
    colors = colors,
  ) {
    Box(modifier = Modifier.fillMaxSize()) {
      if (image != null) {
        Image(
          bitmap = image,
          contentDescription = null,
          contentScale = ContentScale.Crop,
          modifier = Modifier.fillMaxSize(),
        )
      }
      val textModifier = if (hasImage) {
        Modifier.align(Alignment.BottomStart)
          .fillMaxWidth()
          .background(Brush.verticalGradient(listOf(imageScrim.copy(alpha = 0.6f), imageScrim.copy(alpha = 0.78f))))
          .padding(24.dp)
      } else {
        Modifier.fillMaxSize().padding(24.dp)
      }
      Column(
        modifier = textModifier.then(
          if (description == null) Modifier else Modifier.clearAndSetSemantics {},
        ),
        horizontalAlignment = if (hasImage) Alignment.Start else Alignment.CenterHorizontally,
        verticalArrangement = if (hasImage) Arrangement.Bottom else Arrangement.Center,
      ) {
        val icon = item["icon"] as? String
        if (icon != null && !hasImage) {
          Icon(
            nativeM3EIcon(icon),
            contentDescription = null,
            modifier = Modifier.size(48.dp),
            tint = content,
          )
          Spacer(Modifier.size(16.dp))
        }
        Text(
          title,
          color = if (hasImage) imageContent else content,
          style = MaterialTheme.typography.headlineSmall,
          maxLines = 2,
          overflow = TextOverflow.Ellipsis,
        )
        if (!supportingText.isNullOrBlank()) {
          Spacer(Modifier.size(8.dp))
          Text(
            supportingText,
            color = if (hasImage) imageContent.copy(alpha = imageContent.alpha * 0.9f) else content,
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 3,
            overflow = TextOverflow.Ellipsis,
          )
        }
      }
    }
  }
}

private fun nativeRailSelectionEvent(index: Int, destination: Map<*, *>): Any {
  val id = (destination["id"] as? Number)?.toLong()
  return if (id == null) index else mapOf("index" to index, "id" to id)
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ENavigationRail(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val sections = properties["destinations"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val background = properties.color("backgroundColor")
  val expanded = properties["type"] == "expanded"
  val fabIcon = properties["fabIcon"] as? String
  val fabContentDescription = properties["fabContentDescription"] as? String ?: fabIcon
  val scrollable = properties.boolean("scrollable", true)

  if (expanded) {
    val state = rememberWideNavigationRailState(initialValue = WideNavigationRailValue.Expanded)
    val autoWidth = properties.boolean("autoWidth")
    val density = LocalDensity.current
    val measurementKey = properties.number("widthMeasurementKey")?.toInt() ?: 0
    var measuredWidthPx by remember { mutableIntStateOf(0) }
    val currentOnEvent by rememberUpdatedState(onEvent)
    LaunchedEffect(autoWidth, measurementKey, measuredWidthPx, density) {
      if (autoWidth && measuredWidthPx > 0) {
        currentOnEvent("measuredWidth", mapOf(
          "key" to measurementKey,
          "width" to with(density) { measuredWidthPx.toDp().value.toDouble() },
        ))
      }
    }
    WideNavigationRail(
      state = state,
      modifier = if (autoWidth) Modifier.fillMaxHeight().onSizeChanged { size ->
        measuredWidthPx = size.width
      } else Modifier.fillMaxSize(),
      colors = if (background == null) WideNavigationRailDefaults.colors()
        else WideNavigationRailDefaults.colors(containerColor = background),
      header = fabIcon?.let { iconName ->
        @Composable {
          NativeM3ENavigationRailFab(iconName, fabContentDescription, onEvent)
        }
      },
    ) {
      val railItems: @Composable () -> Unit = {
        var index = 0
        sections.forEach { rawSection ->
          val section = rawSection as? Map<*, *> ?: return@forEach
          val header = section["header"] as? String
          if (!header.isNullOrBlank()) {
            Text(
              text = header,
              style = MaterialTheme.typography.titleSmall,
              modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).semantics { heading() },
            )
          }
          val items = section["items"] as? List<*> ?: emptyList<Any?>()
          items.forEach { rawItem ->
            val item = rawItem as? Map<*, *> ?: return@forEach
            val currentIndex = index++
            val label = item["label"] as? String ?: ""
            val selected = selectedIndex == currentIndex
            val iconName = if (selected) {
              item["selectedIcon"] as? String ?: item["icon"] as? String
            } else {
              item["icon"] as? String
            }
            val semanticLabel = (item["semanticLabel"] as? String)?.takeIf { it.isNotBlank() } ?: label
            val badge = item["badge"] as? String
            val badgeSemanticsLabel = (item["badgeSemanticsLabel"] as? String)?.takeIf { it.isNotBlank() }
            val showLabel = label.isNotBlank() && when (properties["labelBehavior"]) {
              "neverShow" -> false
              "selectedOnly" -> selected
              else -> true
            }
            WideNavigationRailItem(
              selected = selected,
              onClick = { onEvent("destinationSelected", nativeRailSelectionEvent(currentIndex, item)) },
              icon = {
                if (!badge.isNullOrEmpty()) {
                  BadgedBox(badge = {
                    Badge {
                      Text(
                        badge,
                        modifier = badgeSemanticsLabel?.let { description ->
                          Modifier.semantics { contentDescription = description }
                        } ?: Modifier,
                      )
                    }
                  }) {
                    Icon(nativeM3EIcon(iconName), contentDescription = if (showLabel) null else semanticLabel)
                  }
                } else {
                  Icon(nativeM3EIcon(iconName), contentDescription = if (showLabel) null else semanticLabel)
                }
              },
              label = if (!showLabel) null else ({
                Text(label, modifier = if (semanticLabel == label) Modifier else Modifier.semantics { contentDescription = semanticLabel })
              }),
              railExpanded = true,
            )
          }
        }
      }
      if (scrollable) {
        Column(Modifier.verticalScroll(rememberScrollState())) { railItems() }
      } else {
        railItems()
      }
    }
  } else {
    NavigationRail(
      modifier = Modifier.fillMaxSize(),
      containerColor = background ?: NavigationRailDefaults.ContainerColor,
      header = fabIcon?.let { iconName ->
        @Composable {
          NativeM3ENavigationRailFab(iconName, fabContentDescription, onEvent)
        }
      },
    ) {
      val railItems: @Composable () -> Unit = {
        var index = 0
        sections.forEach { rawSection ->
          val section = rawSection as? Map<*, *> ?: return@forEach
          val header = section["header"] as? String
          if (!header.isNullOrBlank()) {
            Text(
              text = header,
              style = MaterialTheme.typography.titleSmall,
              modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp).semantics { heading() },
            )
          }
          val items = section["items"] as? List<*> ?: emptyList<Any?>()
          items.forEach { rawItem ->
            val item = rawItem as? Map<*, *> ?: return@forEach
            val currentIndex = index++
            val label = item["label"] as? String ?: ""
            val selected = selectedIndex == currentIndex
            val iconName = if (selected) {
              item["selectedIcon"] as? String ?: item["icon"] as? String
            } else {
              item["icon"] as? String
            }
            val badge = item["badge"] as? String
            val badgeSemanticsLabel = (item["badgeSemanticsLabel"] as? String)?.takeIf { it.isNotBlank() }
            val semanticLabel = (item["semanticLabel"] as? String)?.takeIf { it.isNotBlank() } ?: label
            val showLabel = label.isNotBlank() && properties["labelBehavior"] != "neverShow"
            NavigationRailItem(
              selected = selected,
              onClick = { onEvent("destinationSelected", nativeRailSelectionEvent(currentIndex, item)) },
              icon = {
                if (!badge.isNullOrEmpty()) {
                  BadgedBox(badge = {
                    Badge {
                      Text(
                        badge,
                        modifier = badgeSemanticsLabel?.let { description ->
                          Modifier.semantics { contentDescription = description }
                        } ?: Modifier,
                      )
                    }
                  }) {
                    Icon(nativeM3EIcon(iconName), contentDescription = if (showLabel) null else semanticLabel)
                  }
                } else {
                  Icon(nativeM3EIcon(iconName), contentDescription = if (showLabel) null else semanticLabel)
                }
              },
              label = if (!showLabel) null else ({
                Text(label, modifier = if (semanticLabel == label) Modifier else Modifier.semantics { contentDescription = semanticLabel })
              }),
              alwaysShowLabel = showLabel && properties["labelBehavior"] == "alwaysShow",
            )
          }
        }
      }
      if (scrollable) {
        // The scrolling Column is one child to NavigationRail, so it must
        // reproduce the native 4 dp spacing between its own destinations.
        Column(
          modifier = Modifier.verticalScroll(rememberScrollState()),
          verticalArrangement = Arrangement.spacedBy(4.dp),
        ) { railItems() }
      } else {
        railItems()
      }
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ENavigationRailFab(
  iconName: String,
  description: String?,
  onEvent: M3EAndroidEvent,
) {
  val label = description?.takeIf { it.isNotBlank() } ?: iconName
  TooltipBox(
    positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
    tooltip = {
      PlainTooltip(modifier = Modifier.semantics {
        paneTitle = label
        liveRegion = LiveRegionMode.Assertive
      }) { Text(label) }
    },
    state = rememberTooltipState(),
  ) {
    FloatingActionButton(
      onClick = { onEvent("fabPressed", null) },
      modifier = Modifier.padding(vertical = 12.dp),
    ) { Icon(nativeM3EIcon(iconName), contentDescription = label) }
  }
}

@Composable
private fun NativeM3ENavigationDrawer(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  NativeM3ENavigationDrawerSheet(properties, onEvent)
}

private fun nativeDrawerSelectionEvent(index: Int, destination: Map<*, *>): Any {
  val id = destination["id"] as? Number ?: return index
  return mapOf("index" to index, "id" to id)
}

@Composable
private fun NativeM3ENavigationDrawerOverlay(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
  val scope = rememberCoroutineScope()
  var hasStartedTransition by remember { mutableStateOf(false) }
  var didSendTerminalEvent by remember { mutableStateOf(false) }
  var pendingSelection by remember { mutableStateOf<Any?>(null) }
  val direction = LocalLayoutDirection.current
  LaunchedEffect(Unit) { drawerState.open() }
  LaunchedEffect(drawerState) {
    snapshotFlow {
      Triple(drawerState.targetValue, drawerState.isClosed, drawerState.isAnimationRunning)
    }.collect { (target, closed, animating) ->
      if (animating || (target == DrawerValue.Open && !closed)) {
        hasStartedTransition = true
      }
      if (hasStartedTransition && target == DrawerValue.Closed && closed && !animating && !didSendTerminalEvent) {
        didSendTerminalEvent = true
        val selection = pendingSelection
        if (selection == null) onEvent("dismissed", null)
        else onEvent("destinationSelected", selection)
      }
    }
  }
  Dialog(
    onDismissRequest = { scope.launch { drawerState.close() } },
    properties = DialogProperties(usePlatformDefaultWidth = false),
  ) {
    val dialogWindow = (LocalView.current.parent as? DialogWindowProvider)?.window
    SideEffect { dialogWindow?.setDimAmount(0f) }
    val drawerDirection = if (properties.boolean("isEndDrawer")) {
      if (direction == LayoutDirection.Ltr) LayoutDirection.Rtl else LayoutDirection.Ltr
    } else {
      direction
    }
    CompositionLocalProvider(LocalLayoutDirection provides drawerDirection) {
      ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
          NativeM3ENavigationDrawerSheet(properties, { event, value ->
            if (event == "destinationSelected" && value != null) {
              pendingSelection = value
              scope.launch { drawerState.close() }
            } else onEvent(event, value)
          }, drawerState, contentDirection = direction)
        },
      ) {
        Box(Modifier.fillMaxSize())
      }
    }
  }
}

@Composable
private fun NativeM3ENavigationDrawerSheet(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
  drawerState: androidx.compose.material3.DrawerState? = null,
  contentDirection: LayoutDirection? = null,
) {
  val destinations = properties["destinations"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val background = properties.color("backgroundColor") ?: DrawerDefaults.modalContainerColor
  val requestedWidth = (properties.number("width") ?: 304.0).toFloat().coerceAtLeast(1f).dp
  val sheetModifier = Modifier.width(minOf(requestedWidth, DrawerDefaults.MaximumDrawerWidth)).fillMaxHeight()
  val sheetContent: @Composable androidx.compose.foundation.layout.ColumnScope.() -> Unit = {
    CompositionLocalProvider(LocalLayoutDirection provides (contentDirection ?: LocalLayoutDirection.current)) {
    Column(
      modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()),
    ) {
      val header = properties["header"] as? String
      val supportingHeader = properties["supportingHeader"] as? String
      if (!header.isNullOrBlank() || !supportingHeader.isNullOrBlank()) {
        Column(Modifier.fillMaxWidth().padding(start = 28.dp, top = 28.dp, end = 20.dp, bottom = 20.dp)) {
          if (!header.isNullOrBlank()) {
            Text(
              header,
              style = MaterialTheme.typography.titleLarge,
              modifier = Modifier.semantics { heading() },
            )
          }
          if (!supportingHeader.isNullOrBlank()) {
            Spacer(Modifier.height(4.dp))
            Text(supportingHeader, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
          }
        }
      } else {
        Spacer(Modifier.height(12.dp))
      }
      destinations.forEachIndexed { index, rawDestination ->
        val destination = rawDestination as? Map<*, *> ?: return@forEachIndexed
        val label = destination["label"] as? String ?: ""
        val iconName = if (index == selectedIndex) {
          destination["selectedIcon"] as? String ?: destination["icon"] as? String
        } else {
          destination["icon"] as? String
        }
        val supportingText = destination["supportingText"] as? String
        val badge = (destination["badge"] as? String)?.takeIf { it.isNotBlank() }
        val badgeSemanticsLabel = (destination["badgeSemanticsLabel"] as? String)?.takeIf { it.isNotBlank() }
        val enabled = destination["enabled"] as? Boolean ?: true
        val selected = index == selectedIndex
        val disabledDescription = listOfNotNull(
          label.takeIf { it.isNotBlank() },
          supportingText?.takeIf { it.isNotBlank() },
          badge?.takeIf { it.isNotBlank() }?.let { badgeSemanticsLabel ?: it },
        ).joinToString(", ")
        NavigationDrawerItem(
          label = {
            Column {
              Text(label)
              if (!supportingText.isNullOrBlank()) {
                Text(supportingText, style = MaterialTheme.typography.bodySmall)
              }
            }
          },
          icon = iconName?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
          badge = badge?.let { text -> ({
            Text(
              text,
              modifier = badgeSemanticsLabel?.let { description ->
                Modifier.semantics { contentDescription = description }
              } ?: Modifier,
            )
          }) },
          selected = selected,
          onClick = {
            if (enabled) onEvent("destinationSelected", nativeDrawerSelectionEvent(index, destination))
          },
          modifier = Modifier
            .padding(NavigationDrawerItemDefaults.ItemPadding)
            .then(if (enabled) Modifier else Modifier
              .pointerInput(Unit) {
                awaitPointerEventScope {
                  while (true) {
                    awaitPointerEvent(PointerEventPass.Initial).changes.forEach { it.consume() }
                  }
                }
              }
              .focusProperties { canFocus = false }
              .clearAndSetSemantics {
                contentDescription = disabledDescription
                role = Role.Tab
                this.selected = selected
                disabled()
              }
              .alpha(0.38f)),
        )
      }
      Spacer(Modifier.height(12.dp))
    }
    }
  }
  if (drawerState == null) {
    ModalDrawerSheet(modifier = sheetModifier, drawerContainerColor = background, content = sheetContent)
  } else {
    ModalDrawerSheet(drawerState = drawerState, modifier = sheetModifier, drawerContainerColor = background, content = sheetContent)
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EIconButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val selected = properties["selected"] as? Boolean
  val variant = properties["variant"] as? String ?: "standard"
  val size = properties["size"] as? String ?: "small"
  val square = properties["shape"] == "square"
  val widthOption = when (properties["width"] as? String) {
    "narrow" -> IconButtonDefaults.IconButtonWidthOption.Narrow
    "wide" -> IconButtonDefaults.IconButtonWidthOption.Wide
    else -> IconButtonDefaults.IconButtonWidthOption.Uniform
  }
  val containerSize = when (size) {
    "extraSmall" -> IconButtonDefaults.extraSmallContainerSize(widthOption)
    "medium" -> IconButtonDefaults.mediumContainerSize(widthOption)
    "large" -> IconButtonDefaults.largeContainerSize(widthOption)
    "extraLarge" -> IconButtonDefaults.extraLargeContainerSize(widthOption)
    else -> IconButtonDefaults.smallContainerSize(widthOption)
  }
  val iconSize = when (size) {
    "extraSmall" -> IconButtonDefaults.extraSmallIconSize
    "medium" -> IconButtonDefaults.mediumIconSize
    "large" -> IconButtonDefaults.largeIconSize
    "extraLarge" -> IconButtonDefaults.extraLargeIconSize
    else -> IconButtonDefaults.smallIconSize
  }
  val baseShape = when (size) {
    "extraSmall" -> if (square) IconButtonDefaults.extraSmallSquareShape else IconButtonDefaults.extraSmallRoundShape
    "medium" -> if (square) IconButtonDefaults.mediumSquareShape else IconButtonDefaults.mediumRoundShape
    "large" -> if (square) IconButtonDefaults.largeSquareShape else IconButtonDefaults.largeRoundShape
    "extraLarge" -> if (square) IconButtonDefaults.extraLargeSquareShape else IconButtonDefaults.extraLargeRoundShape
    else -> if (square) IconButtonDefaults.smallSquareShape else IconButtonDefaults.smallRoundShape
  }
  val pressedShape = when (size) {
    "extraSmall" -> IconButtonDefaults.extraSmallPressedShape
    "medium" -> IconButtonDefaults.mediumPressedShape
    "large" -> IconButtonDefaults.largePressedShape
    "extraLarge" -> IconButtonDefaults.extraLargePressedShape
    else -> IconButtonDefaults.smallPressedShape
  }
  val checkedShape = when (size) {
    "extraSmall" -> if (square) IconButtonDefaults.extraSmallSelectedSquareShape else IconButtonDefaults.extraSmallSelectedRoundShape
    "medium" -> if (square) IconButtonDefaults.mediumSelectedSquareShape else IconButtonDefaults.mediumSelectedRoundShape
    "large" -> if (square) IconButtonDefaults.largeSelectedSquareShape else IconButtonDefaults.largeSelectedRoundShape
    "extraLarge" -> if (square) IconButtonDefaults.extraLargeSelectedSquareShape else IconButtonDefaults.extraLargeSelectedRoundShape
    else -> if (square) IconButtonDefaults.smallSelectedSquareShape else IconButtonDefaults.smallSelectedRoundShape
  }
  val shapes = IconButtonDefaults.shapes(shape = baseShape, pressedShape = pressedShape)
  val toggleableShapes = IconButtonDefaults.toggleableShapes(
    shape = baseShape,
    pressedShape = pressedShape,
    checkedShape = checkedShape,
  )
  val displayedIconSize = properties.number("iconSizeOverride")
    ?.takeIf { it.isFinite() && it >= 0.0 }
    ?.dp ?: iconSize
  val modifier = Modifier
    .size(
      width = maxOf(containerSize.width, displayedIconSize),
      height = maxOf(containerSize.height, displayedIconSize),
    )
    .then((properties["semanticLabel"] as? String ?: properties["tooltip"] as? String)
      ?.let { label -> Modifier.semantics { contentDescription = label } } ?: Modifier)
  val selectedState = selected ?: false
  val iconName = if (selectedState) {
    properties["selectedIcon"] as? String ?: properties["icon"] as? String
  } else {
    properties["icon"] as? String
  }
  val image = nativeM3EIcon(iconName)
  val displayedIconColor = properties.color("iconColorOverride")
  val icon: @Composable () -> Unit = {
    Icon(
      image,
      contentDescription = null,
      modifier = Modifier.size(displayedIconSize),
      tint = displayedIconColor ?: LocalContentColor.current,
    )
  }
  val aiPowered = properties["aiPowered"] as? Boolean ?: false
  val displayIcon: @Composable () -> Unit = {
    if (aiPowered) {
      NativeM3EAiSparkleIcon(iconName, size = displayedIconSize, tint = displayedIconColor)
    } else {
      icon()
    }
  }
  val badge = properties["badge"] as? String
  val badgeSemanticsLabel = (properties["badgeSemanticsLabel"] as? String)
    ?.takeIf { it.isNotBlank() }
  val content: @Composable () -> Unit = {
    if (!badge.isNullOrEmpty()) {
      BadgedBox(badge = {
        Badge {
          Text(
            badge,
            modifier = badgeSemanticsLabel?.let { description ->
              Modifier.semantics { contentDescription = description }
            } ?: Modifier,
          )
        }
      }) { displayIcon() }
    } else {
      displayIcon()
    }
  }
  val foreground = properties.color("foregroundColor") ?: Color.Unspecified
  val background = properties.color("backgroundColor") ?: Color.Unspecified
  val selectedForeground = properties.color("selectedForegroundColor") ?: Color.Unspecified
  val selectedBackground = properties.color("selectedBackgroundColor") ?: Color.Unspecified
  val onClick = { if (enabled) onEvent("pressed", null) }
  val button: @Composable () -> Unit = {
  if (selected != null) {
    val onCheckedChange: (Boolean) -> Unit = { if (enabled) onEvent("selectionChanged", it) }
    when (variant) {
      "filled" -> FilledIconToggleButton(
        checked = selected,
        onCheckedChange = onCheckedChange,
        enabled = enabled,
        modifier = modifier,
        shapes = toggleableShapes,
        colors = IconButtonDefaults.filledIconToggleButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
          checkedContainerColor = selectedBackground,
          checkedContentColor = selectedForeground,
        ),
        content = content,
      )
      "tonal" -> FilledTonalIconToggleButton(
        checked = selected,
        onCheckedChange = onCheckedChange,
        enabled = enabled,
        modifier = modifier,
        shapes = toggleableShapes,
        colors = IconButtonDefaults.filledTonalIconToggleButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
          checkedContainerColor = selectedBackground,
          checkedContentColor = selectedForeground,
        ),
        content = content,
      )
      "outlined" -> OutlinedIconToggleButton(
        checked = selected,
        onCheckedChange = onCheckedChange,
        enabled = enabled,
        modifier = modifier,
        shapes = toggleableShapes,
        colors = IconButtonDefaults.outlinedIconToggleButtonVibrantColors().copy(
          containerColor = background,
          contentColor = foreground,
          checkedContainerColor = selectedBackground,
          checkedContentColor = selectedForeground,
        ),
        content = content,
      )
      else -> IconToggleButton(
        checked = selected,
        onCheckedChange = onCheckedChange,
        enabled = enabled,
        modifier = modifier,
        shapes = toggleableShapes,
        colors = IconButtonDefaults.iconToggleButtonVibrantColors().copy(
          containerColor = background,
          contentColor = foreground,
          checkedContainerColor = selectedBackground,
          checkedContentColor = selectedForeground,
        ),
        content = content,
      )
    }
  } else {
    when (variant) {
      "filled" -> FilledIconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shapes = shapes,
        colors = IconButtonDefaults.filledIconButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      "tonal" -> FilledTonalIconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shapes = shapes,
        colors = IconButtonDefaults.filledTonalIconButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      "outlined" -> OutlinedIconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shapes = shapes,
        colors = IconButtonDefaults.outlinedIconButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      else -> IconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shapes = shapes,
        colors = IconButtonDefaults.iconButtonColors().copy(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
    }
  }
  }
  val tooltip = (properties["tooltip"] as? String)?.takeIf { it.isNotBlank() }
  SoundEffectOnInteraction(enabled = properties.boolean("enableFeedback", true)) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
      if (tooltip == null) {
        button()
      } else {
        TooltipBox(
          positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Below),
          tooltip = {
            PlainTooltip(modifier = Modifier.semantics {
              paneTitle = tooltip
              liveRegion = LiveRegionMode.Assertive
            }) { Text(tooltip) }
          },
          state = rememberTooltipState(),
        ) { button() }
      }
    }
  }
}

@Composable
private fun NativeM3EAiSparkleIcon(
  icon: String?,
  size: androidx.compose.ui.unit.Dp,
  tint: Color? = null,
  sparkleTint: Color = MaterialTheme.colorScheme.primary,
  semanticLabel: String? = null,
) {
  val semantics = semanticLabel?.takeIf { it.isNotBlank() }
    ?.let { label -> Modifier.semantics { contentDescription = label } }
    ?: Modifier
  Box(
    modifier = Modifier.size(size).then(semantics),
    contentAlignment = Alignment.Center,
  ) {
    if (tint == null) {
      Icon(nativeM3EIcon(icon), contentDescription = null, modifier = Modifier.fillMaxSize())
    } else {
      Icon(nativeM3EIcon(icon), contentDescription = null, tint = tint, modifier = Modifier.fillMaxSize())
    }
    Canvas(Modifier.align(Alignment.TopEnd).size(size * 0.46f)) {
      val w = this.size.width
      val h = this.size.height
      val path = Path().apply {
        moveTo(w * 0.5f, 0f)
        cubicTo(w * 0.58f, h * 0.39f, w * 0.61f, h * 0.42f, w, h * 0.5f)
        cubicTo(w * 0.61f, h * 0.58f, w * 0.58f, h * 0.61f, w * 0.5f, h)
        cubicTo(w * 0.42f, h * 0.61f, w * 0.39f, h * 0.58f, 0f, h * 0.5f)
        cubicTo(w * 0.39f, h * 0.42f, w * 0.42f, h * 0.39f, w * 0.5f, 0f)
        close()
      }
      drawPath(path, sparkleTint)
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EFab(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val disabledColors = if (enabled) null else ButtonDefaults.buttonColors()
  val background = disabledColors?.disabledContainerColor
    ?: properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = disabledColors?.disabledContentColor
    ?: properties.color("foregroundColor") ?: fabContentColor(properties)
  val elevation = if (!enabled) {
    FloatingActionButtonDefaults.elevation(
      defaultElevation = 0.dp,
      pressedElevation = 0.dp,
      focusedElevation = 0.dp,
      hoveredElevation = 0.dp,
    )
  } else properties.number("elevation")?.dp?.let {
    FloatingActionButtonDefaults.elevation(defaultElevation = it)
  } ?: FloatingActionButtonDefaults.elevation()
  val tooltip = (properties["tooltip"] as? String)?.takeIf { it.isNotBlank() }
  val description = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() } ?: tooltip
  val modifier = nativeFabInteractionModifier(enabled, description)
  val icon = nativeM3EIcon(properties["icon"] as? String)
  val iconSizeOverride = properties.number("iconSizeOverride")?.dp
  val size = properties["size"] as? String ?: "standard"
  val iconSize = iconSizeOverride ?: when (size) {
    "medium" -> FloatingActionButtonDefaults.MediumIconSize
    "large" -> FloatingActionButtonDefaults.LargeIconSize
    else -> 24.dp
  }
  val iconColorOverride = properties.color("iconColorOverride")
  val aiPowered = properties["aiPowered"] as? Boolean ?: false
  val click = { if (enabled) onEvent("pressed", null) }
  val fabIcon: @Composable () -> Unit = {
    if (aiPowered) {
      NativeM3EAiSparkleIcon(
        properties["icon"] as? String,
        size = iconSize,
        tint = iconColorOverride,
      )
    } else {
      Icon(
        icon,
        contentDescription = null,
        modifier = Modifier.size(iconSize),
        tint = iconColorOverride ?: LocalContentColor.current,
      )
    }
  }
  val colors = Triple(background, foreground, elevation)
  val button: @Composable () -> Unit = {
    when (size) {
      "small" -> SmallFloatingActionButton(
        onClick = click,
        modifier = modifier,
        containerColor = colors.first,
        contentColor = colors.second,
        elevation = colors.third,
      ) { fabIcon() }
      "medium" -> MediumFloatingActionButton(
        onClick = click,
        modifier = modifier,
        containerColor = colors.first,
        contentColor = colors.second,
        elevation = colors.third,
      ) { fabIcon() }
      "large" -> LargeFloatingActionButton(
        onClick = click,
        modifier = modifier,
        containerColor = colors.first,
        contentColor = colors.second,
        elevation = colors.third,
      ) { fabIcon() }
      else -> FloatingActionButton(
        onClick = click,
        modifier = modifier,
        containerColor = colors.first,
        contentColor = colors.second,
        elevation = colors.third,
      ) { fabIcon() }
    }
  }
  if (tooltip == null) {
    button()
  } else {
    TooltipBox(
      positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
      tooltip = { NativeM3EPlainActionTooltip(tooltip) },
      state = rememberTooltipState(),
    ) { button() }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EExtendedFab(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val extended = properties.boolean("extended", true)
  val disabledColors = if (enabled) null else ButtonDefaults.buttonColors()
  val background = disabledColors?.disabledContainerColor
    ?: properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = disabledColors?.disabledContentColor
    ?: properties.color("foregroundColor") ?: fabContentColor(properties)
  val elevation = if (!enabled) {
    FloatingActionButtonDefaults.elevation(
      defaultElevation = 0.dp,
      pressedElevation = 0.dp,
      focusedElevation = 0.dp,
      hoveredElevation = 0.dp,
    )
  } else properties.number("elevation")?.dp?.let {
    FloatingActionButtonDefaults.elevation(defaultElevation = it)
  } ?: FloatingActionButtonDefaults.elevation()
  val icon = nativeM3EIcon(properties["icon"] as? String)
  val iconSizeOverride = properties.number("iconSizeOverride")?.dp
  val iconColorOverride = properties.color("iconColorOverride")
  val label = properties["label"] as? String ?: ""
  val tooltip = (properties["tooltip"] as? String)?.takeIf { it.isNotBlank() }
  val description = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
    ?: tooltip ?: label
  val density = LocalDensity.current
  val click = { if (enabled) onEvent("pressed", null) }
  val button: @Composable () -> Unit = {
    ExtendedFloatingActionButton(
      onClick = click,
      icon = {
        Icon(
          icon,
          contentDescription = if (extended) null else description,
          modifier = iconSizeOverride?.let { Modifier.size(it) } ?: Modifier,
          tint = iconColorOverride ?: LocalContentColor.current,
        )
      },
      text = { Text(label) },
      expanded = extended,
      modifier = nativeFabInteractionModifier(enabled, description).onSizeChanged { size ->
        onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
        onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
      },
      containerColor = background,
      contentColor = foreground,
      elevation = elevation,
    )
  }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.CenterEnd) {
    if (tooltip == null && extended) {
      button()
    } else {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
        tooltip = { NativeM3EPlainActionTooltip(tooltip ?: label) },
        state = rememberTooltipState(),
      ) { button() }
    }
  }
}

private fun nativeFabInteractionModifier(enabled: Boolean, description: String?): Modifier {
  if (enabled) {
    return if (description.isNullOrBlank()) Modifier else Modifier.semantics {
      contentDescription = description
    }
  }
  // Compose FABs have no enabled parameter. Keep their native rendering but
  // prevent the internal clickable from receiving pointer, focus, or a11y input.
  return Modifier
    .pointerInput(Unit) {
      awaitPointerEventScope {
        while (true) {
          awaitPointerEvent(PointerEventPass.Initial).changes.forEach { it.consume() }
        }
      }
    }
    .focusProperties { canFocus = false }
    .clearAndSetSemantics {
      if (!description.isNullOrBlank()) contentDescription = description
      role = Role.Button
      disabled()
    }
}

private data class M3EFabMenuPendingAction(val index: Int, val id: Long?)

@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EFabMenu(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  // A recreated transient menu starts closed so its collapsed host height can
  // be measured before any selection waits for the native exit animation.
  var expanded by remember { mutableStateOf(false) }
  var pendingAction by remember { mutableStateOf<M3EFabMenuPendingAction?>(null) }
  var collapsedHeightPx by remember(properties["size"]) { mutableIntStateOf(0) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  val background = properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = properties.color("foregroundColor") ?: fabContentColor(properties)
  val colorScheme = MaterialTheme.colorScheme
  val containerColor = ToggleFloatingActionButtonDefaults.containerColor(
    initialColor = background,
    finalColor = properties.color("backgroundColor") ?: colorScheme.primary,
  )
  val iconColor = ToggleFloatingActionButtonDefaults.iconColor(
    initialColor = properties.color("iconColor") ?: foreground,
    finalColor = properties.color("closeIconColor")
      ?: properties.color("foregroundColor")
      ?: colorScheme.onPrimary,
  )
  val containerSize = when (properties["size"] as? String) {
    "small" -> ToggleFloatingActionButtonDefaults.containerSize(initialSize = 40.dp)
    "large" -> ToggleFloatingActionButtonDefaults.containerSizeLarge()
    else -> ToggleFloatingActionButtonDefaults.containerSize()
  }
  val containerCornerRadius = when (properties["size"] as? String) {
    "small" -> ToggleFloatingActionButtonDefaults.containerCornerRadius(initialSize = 12.dp)
    "large" -> ToggleFloatingActionButtonDefaults.containerCornerRadiusLarge()
    else -> ToggleFloatingActionButtonDefaults.containerCornerRadius()
  }
  val defaultIconSize = when (properties["size"] as? String) {
    "small" -> ToggleFloatingActionButtonDefaults.iconSize(initialSize = 24.dp)
    "large" -> ToggleFloatingActionButtonDefaults.iconSizeLarge()
    else -> ToggleFloatingActionButtonDefaults.iconSize()
  }
  val initialIconSize = properties.number("iconSize")?.takeIf { it.isFinite() && it >= 0.0 }?.dp
  val finalIconSize = properties.number("closeIconSize")?.takeIf { it.isFinite() && it >= 0.0 }?.dp
  val iconSize = if (initialIconSize != null || finalIconSize != null) {
    ToggleFloatingActionButtonDefaults.iconSize(
      initialSize = initialIconSize ?: defaultIconSize(0f),
      finalSize = finalIconSize ?: defaultIconSize(1f),
    )
  } else defaultIconSize
  val closedIcon = nativeM3EIcon(properties["icon"] as? String)
  val openIcon = nativeM3EIcon(properties["closeIcon"] as? String)
  val alignment = if (properties["position"] == "left") Alignment.Start else Alignment.End
  val cornerAlignment = if (alignment == Alignment.Start) Alignment.BottomStart else Alignment.BottomEnd
  val toggleLabel = properties["toggleMenuLabel"] as? String ?: "Toggle menu"
  val closeMenuLabel = properties["closeMenuLabel"] as? String ?: "Close menu"
  val currentToggleLabel = if (expanded) closeMenuLabel else toggleLabel
  val expandedLabel = properties["expandedStateLabel"] as? String ?: "Expanded"
  val collapsedLabel = properties["collapsedStateLabel"] as? String ?: "Collapsed"
  val closeFocusRequester = remember { FocusRequester() }
  val serializedItems = properties["items"] as? List<*> ?: emptyList<Any?>()

  BackHandler(enabled = expanded) { expanded = false }
  LaunchedEffect(expanded) {
    if (expanded) closeFocusRequester.requestFocus()
  }
  Box(
    Modifier.fillMaxSize().onPreviewKeyEvent { event ->
      if (expanded && event.type == KeyEventType.KeyDown && event.key == Key.Escape) {
        expanded = false
        true
      } else false
    },
  ) {
    FloatingActionButtonMenu(
      expanded = expanded,
      button = {
        Box(
          modifier = if (properties["size"] == "small") Modifier.size(56.dp) else Modifier,
          contentAlignment = Alignment.Center,
        ) {
          TooltipBox(
            positionProvider = TooltipDefaults.rememberTooltipPositionProvider(
              if (expanded) TooltipAnchorPosition.Start else TooltipAnchorPosition.Above,
            ),
            tooltip = {
              PlainTooltip(modifier = Modifier.semantics {
                paneTitle = currentToggleLabel
                liveRegion = LiveRegionMode.Assertive
              }) {
                Text(currentToggleLabel)
              }
            },
            state = rememberTooltipState(),
          ) {
            ToggleFloatingActionButton(
              checked = expanded,
              onCheckedChange = { if (pendingAction == null) expanded = it },
              modifier = Modifier
                .semantics {
                  contentDescription = currentToggleLabel
                  stateDescription = if (expanded) expandedLabel else collapsedLabel
                  traversalIndex = -1f
                }
                .animateFloatingActionButton(visible = true, alignment = cornerAlignment)
                .focusRequester(closeFocusRequester),
              containerColor = containerColor,
              containerSize = containerSize,
              containerCornerRadius = containerCornerRadius,
              contentAlignment = if (alignment == Alignment.Start) Alignment.TopStart else Alignment.TopEnd,
            ) {
              val icon = if (checkedProgress > 0.5f) openIcon else closedIcon
              Icon(
                icon,
                contentDescription = null,
                modifier = Modifier.animateIcon(
                  { checkedProgress },
                  color = iconColor,
                  size = iconSize,
                ),
              )
            }
          }
        }
      },
      horizontalAlignment = alignment,
      modifier = Modifier.align(cornerAlignment).onSizeChanged { size ->
        if (expanded) return@onSizeChanged
        val action = pendingAction
        if (action == null) {
          collapsedHeightPx = size.height
        } else if (collapsedHeightPx > 0 && size.height <= collapsedHeightPx) {
          pendingAction = null
          currentOnEvent(
            "itemPressed",
            action.id?.let { mapOf("index" to action.index, "id" to it) } ?: action.index,
          )
        }
      },
    ) {
      serializedItems.forEachIndexed { index, raw ->
        val item = raw as? Map<*, *> ?: return@forEachIndexed
        val label = item["label"] as? String ?: ""
        val icon = nativeM3EIcon(item["icon"] as? String)
        val itemIconSize = (item["iconSize"] as? Number)?.toFloat()?.takeIf { it.isFinite() && it >= 0f }
        val itemIconColor = (item["iconColor"] as? Number)?.toLong()?.toInt()?.let(::Color)
        FloatingActionButtonMenuItem(
          onClick = {
            if (pendingAction == null) {
              pendingAction = M3EFabMenuPendingAction(index, (item["id"] as? Number)?.toLong())
              expanded = false
            }
          },
          text = { M3EFabMenuItemLabel(label) },
          icon = {
            Icon(
              icon,
              contentDescription = null,
              modifier = itemIconSize?.dp?.let { Modifier.size(it) } ?: Modifier,
              tint = itemIconColor ?: LocalContentColor.current,
            )
          },
          modifier = Modifier.semantics {
            isTraversalGroup = true
            if (index == serializedItems.lastIndex) {
              customActions = listOf(
                CustomAccessibilityAction(label = closeMenuLabel) {
                  expanded = false
                  true
                },
              )
            }
          }.then(if (index == 0) Modifier.onPreviewKeyEvent { event ->
            if (
              event.type == KeyEventType.KeyDown &&
              (event.key == Key.DirectionUp ||
                event.key == Key.NumPadDirectionUp ||
                (event.isShiftPressed && event.key == Key.Tab))
            ) {
              closeFocusRequester.requestFocus()
              true
            } else false
          } else Modifier),
          containerColor = background,
          contentColor = foreground,
        )
      }
    }
  }
}

@Composable
private fun fabContainerColor(properties: Map<String, Any?>): Color = when (properties["color"] as? String) {
  "secondary" -> MaterialTheme.colorScheme.secondaryContainer
  "tertiary" -> MaterialTheme.colorScheme.tertiaryContainer
  "surface" -> MaterialTheme.colorScheme.surfaceContainerHigh
  else -> MaterialTheme.colorScheme.primaryContainer
}

@Composable
private fun fabContentColor(properties: Map<String, Any?>): Color = when (properties["color"] as? String) {
  "secondary" -> MaterialTheme.colorScheme.onSecondaryContainer
  "tertiary" -> MaterialTheme.colorScheme.onTertiaryContainer
  "surface" -> MaterialTheme.colorScheme.onSurface
  else -> MaterialTheme.colorScheme.onPrimaryContainer
}

private fun nativeM3EIcon(name: String?): ImageVector = when (name) {
  "add" -> Icons.Filled.Add
  "arrowBack" -> Icons.AutoMirrored.Filled.ArrowBack
  "arrowDropDown" -> Icons.Filled.ArrowDropDown
  "arrowForward" -> Icons.AutoMirrored.Filled.ArrowForward
  "autoAwesome" -> Icons.Filled.AutoAwesome
  "calendarToday" -> Icons.Filled.CalendarToday
  "check" -> Icons.Filled.Check
  "close" -> Icons.Filled.Close
  "delete" -> Icons.Filled.Delete
  "done" -> Icons.Filled.Done
  "edit" -> Icons.Filled.Edit
  "expandMore" -> Icons.Filled.ExpandMore
  "favorite" -> Icons.Filled.Favorite
  "home" -> Icons.Filled.Home
  "info" -> Icons.Filled.Info
  "message" -> Icons.AutoMirrored.Filled.Message
  "menu" -> Icons.Filled.Menu
  "moreVert" -> Icons.Filled.MoreVert
  "notifications" -> Icons.Filled.Notifications
  "person" -> Icons.Filled.Person
  "refresh" -> Icons.Filled.Refresh
  "save" -> Icons.Filled.Save
  "search" -> Icons.Filled.Search
  "settings" -> Icons.Filled.Settings
  "share" -> Icons.Filled.Share
  else -> Icons.Filled.Add
}

@Composable
private fun NativeM3EDivider(properties: Map<String, Any?>) {
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    val thickness = properties.number("thickness")?.dp ?: DividerDefaults.Thickness
    val color = properties.color("color") ?: DividerDefaults.color
    val indent = (properties.number("indent") ?: 0.0).dp
    val endIndent = (properties.number("endIndent") ?: 0.0).dp
    if (properties["orientation"] == "vertical") {
      VerticalDivider(
        modifier = Modifier.fillMaxHeight().padding(top = indent, bottom = endIndent),
        thickness = thickness,
        color = color,
      )
    } else {
      HorizontalDivider(
        modifier = Modifier.fillMaxWidth().padding(start = indent, end = endIndent),
        thickness = thickness,
        color = color,
      )
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ELoadingIndicator(properties: Map<String, Any?>) {
  val size = (properties.number("size") ?: 48.0).dp
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val progress = properties.number("progress")?.toFloat()?.coerceIn(0f, 1f)
  val polygons = (properties["polygons"] as? List<*>)
    ?.filterIsInstance<String>()
    ?.takeIf { it.size >= 2 }
    ?.map(::materialShape)
    ?: if (progress == null) LoadingIndicatorDefaults.IndeterminateIndicatorPolygons
      else LoadingIndicatorDefaults.DeterminateIndicatorPolygons
  val animatedProgress by animateFloatAsState(
    targetValue = progress ?: 0f,
    animationSpec = ProgressIndicatorDefaults.ProgressAnimationSpec,
    label = "nativeLoadingIndicatorProgress",
  )
  val modifier = Modifier
    .size(size)
    .then(if (semanticLabel == null) Modifier else Modifier.semantics {
      contentDescription = semanticLabel
    })
  if (properties["variant"] == "contained") {
    val indicatorColor = properties.color("color") ?: LoadingIndicatorDefaults.containedIndicatorColor
    val containerColor = properties.color("containerColor") ?: LoadingIndicatorDefaults.containedContainerColor
    if (progress == null) {
      ContainedLoadingIndicator(
        modifier = modifier,
        indicatorColor = indicatorColor,
        containerColor = containerColor,
        polygons = polygons,
      )
    } else {
      ContainedLoadingIndicator(
        progress = { animatedProgress },
        modifier = modifier,
        indicatorColor = indicatorColor,
        containerColor = containerColor,
        polygons = polygons,
      )
    }
  } else {
    val color = properties.color("color") ?: LoadingIndicatorDefaults.indicatorColor
    if (progress == null) {
      LoadingIndicator(modifier = modifier, color = color, polygons = polygons)
    } else {
      LoadingIndicator(
        progress = { animatedProgress },
        modifier = modifier,
        color = color,
        polygons = polygons,
      )
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EPullRefreshIndicator(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val state = rememberPullToRefreshState()
  val isRefreshing = properties.boolean("isRefreshing")
  val exitRequested = properties.boolean("exitRequested")
  val pullFraction = properties.number("pullFraction")?.toFloat()?.coerceIn(0f, 1.5f) ?: 0f
  LaunchedEffect(state, isRefreshing, pullFraction, exitRequested) {
    when {
      exitRequested -> {
        state.animateToHidden()
        onEvent("hidden", null)
      }
      isRefreshing -> state.animateToThreshold()
      pullFraction > 0f -> state.snapTo(pullFraction)
      else -> state.snapTo(0f)
    }
  }
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val semanticValue = (properties["semanticValue"] as? String)?.takeIf { it.isNotBlank() }
  val modifier = if (semanticLabel == null && semanticValue == null) Modifier else Modifier.semantics {
    if (semanticLabel != null) contentDescription = semanticLabel
    if (semanticValue != null) stateDescription = semanticValue
  }
  PullToRefreshDefaults.LoadingIndicator(
    state = state,
    isRefreshing = isRefreshing,
    modifier = modifier,
    containerColor = properties.color("containerColor")
      ?: PullToRefreshDefaults.loadingIndicatorContainerColor,
    color = properties.color("color") ?: PullToRefreshDefaults.loadingIndicatorColor,
  )
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EProgressIndicator(properties: Map<String, Any?>) {
  val linear = properties.boolean("linear")
  val value = properties.number("value")?.toFloat()?.coerceIn(0f, 1f)
  val shape = properties["shape"] as? String ?: "flat"
  val color = properties.color("color") ?: when {
    shape == "wavy" -> WavyProgressIndicatorDefaults.indicatorColor
    linear -> ProgressIndicatorDefaults.linearColor
    else -> ProgressIndicatorDefaults.circularColor
  }
  val trackColor = properties.color("trackColor") ?: when {
    shape == "wavy" -> WavyProgressIndicatorDefaults.trackColor
    linear -> ProgressIndicatorDefaults.linearTrackColor
    value == null -> ProgressIndicatorDefaults.circularIndeterminateTrackColor
    else -> ProgressIndicatorDefaults.circularDeterminateTrackColor
  }
  val animatedProgress by animateFloatAsState(
    targetValue = value ?: 0f,
    animationSpec = if (linear && shape == "wavy") {
      WavyProgressIndicatorDefaults.ProgressAnimationSpec
    } else {
      ProgressIndicatorDefaults.ProgressAnimationSpec
    },
    label = "nativeProgressIndicator",
  )
  val semanticsLabel = (properties["semanticsLabel"] as? String)?.takeIf { it.isNotBlank() }
  val semanticsModifier = semanticsLabel?.let { label ->
    Modifier.semantics(mergeDescendants = true) { contentDescription = label }
  } ?: Modifier

  if (linear) {
    val trackThickness = (properties.number("trackThickness") ?: 4.0).dp
    val containerHeight = properties.number("containerHeight")?.dp
    val linearInset = (properties.number("linearInset") ?: 0.0).dp
    val cornerRadii = properties["cornerRadii"] as? Map<*, *>
    val cornerClipModifier = if (cornerRadii == null) Modifier else {
      val density = LocalDensity.current.density
      val radii = floatArrayOf(
        (cornerRadii["topLeftX"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["topLeftY"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["topRightX"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["topRightY"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["bottomRightX"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["bottomRightY"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["bottomLeftX"] as? Number)?.toFloat() ?: 0f,
        (cornerRadii["bottomLeftY"] as? Number)?.toFloat() ?: 0f,
      )
      Modifier.clip(GenericShape { size, _ ->
        if (size.width > 0f && size.height > 0f) {
          val scale = maxOf(
            1f,
            (radii[0] + radii[2]) * density / size.width,
            (radii[6] + radii[4]) * density / size.width,
            (radii[1] + radii[7]) * density / size.height,
            (radii[3] + radii[5]) * density / size.height,
          )
          fun corner(index: Int) = CornerRadius(
            radii[index] * density / scale,
            radii[index + 1] * density / scale,
          )
          addRoundRect(RoundRect(
            0f, 0f, size.width, size.height,
            topLeftCornerRadius = corner(0),
            topRightCornerRadius = corner(2),
            bottomRightCornerRadius = corner(4),
            bottomLeftCornerRadius = corner(6),
          ))
        }
      })
    }
    if (shape == "wavy") {
      val strokePx = with(LocalDensity.current) { trackThickness.toPx() }
      val stroke = Stroke(width = strokePx, cap = StrokeCap.Round)
      val wavyModifier = semanticsModifier.fillMaxWidth()
        .padding(horizontal = linearInset)
        .then(if (containerHeight == null) Modifier else Modifier.height(containerHeight))
        .then(cornerClipModifier)
      if (value == null) {
        LinearWavyProgressIndicator(
          modifier = wavyModifier,
          color = color,
          trackColor = trackColor,
          stroke = stroke,
          trackStroke = stroke,
        )
      } else {
        LinearWavyProgressIndicator(
          progress = { animatedProgress },
          modifier = wavyModifier,
          color = color,
          trackColor = trackColor,
          stroke = stroke,
          trackStroke = stroke,
        )
      }
    } else {
      val flatModifier = semanticsModifier.fillMaxWidth()
        .padding(horizontal = linearInset)
        .height(containerHeight ?: trackThickness).then(cornerClipModifier)
      if (value == null) {
        LinearProgressIndicator(
          modifier = flatModifier,
          color = color,
          trackColor = trackColor,
        )
      } else {
        LinearProgressIndicator(
          progress = { animatedProgress },
          modifier = flatModifier,
          color = color,
          trackColor = trackColor,
        )
      }
    }
    return
  }

  val size = (properties.number("size") ?: 20.0).dp
  val strokeWidth = (properties.number("strokeWidth") ?: 3.0).dp
  val strokePx = with(LocalDensity.current) { strokeWidth.toPx() }
  val stroke = Stroke(width = strokePx, cap = StrokeCap.Round)
  val circularModifier = semanticsModifier.size(size)
  if (shape == "wavy") {
    if (value == null) {
      CircularWavyProgressIndicator(
        modifier = circularModifier,
        color = color,
        trackColor = trackColor,
        stroke = stroke,
        trackStroke = stroke,
      )
    } else {
      CircularWavyProgressIndicator(
        progress = { animatedProgress },
        modifier = circularModifier,
        color = color,
        trackColor = trackColor,
        stroke = stroke,
        trackStroke = stroke,
      )
    }
  } else if (value == null) {
    CircularProgressIndicator(
      modifier = circularModifier,
      color = color,
      trackColor = trackColor,
      strokeWidth = strokeWidth,
    )
  } else {
    CircularProgressIndicator(
      progress = { animatedProgress },
      modifier = circularModifier,
      color = color,
      trackColor = trackColor,
      strokeWidth = strokeWidth,
    )
  }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
private fun NativeM3EButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val style = properties["style"] as? String ?: "filled"
  val radii = (properties["borderRadii"] as? List<*>)
    ?.takeIf { it.size == 4 || it.size == 8 }
    ?.mapNotNull { (it as? Number)?.toFloat()?.takeIf { value -> value.isFinite() && value >= 0f } }
    ?.takeIf { it.size == 4 || it.size == 8 }
  val foreground = properties.color("foregroundColor")
  val background = properties.color("backgroundColor")
  val borderColor = properties.color("borderColor")
  val buttonHeight = (properties.number("minHeight") ?: 40.0).dp
  val modifier = Modifier.height(buttonHeight)
  val shapes = ButtonDefaults.shapesFor(buttonHeight).let { defaults ->
    when (radii?.size) {
      4 -> defaults.copy(shape = AbsoluteRoundedCornerShape(radii[0].dp, radii[1].dp, radii[2].dp, radii[3].dp))
      8 -> {
        val density = LocalDensity.current.density
        val customShape = GenericShape { size, _ ->
          if (size.width > 0f && size.height > 0f) {
            val scale = maxOf(
              1f,
              (radii[0] + radii[2]) * density / size.width,
              (radii[6] + radii[4]) * density / size.width,
              (radii[1] + radii[7]) * density / size.height,
              (radii[3] + radii[5]) * density / size.height,
            )
            fun corner(index: Int) = CornerRadius(
              radii[index] * density / scale,
              radii[index + 1] * density / scale,
            )
            addRoundRect(RoundRect(
              0f, 0f, size.width, size.height,
              topLeftCornerRadius = corner(0),
              topRightCornerRadius = corner(2),
              bottomRightCornerRadius = corner(4),
              bottomLeftCornerRadius = corner(6),
            ))
          }
        }
        // Material's ButtonShapes only interpolates CornerBasedShape families.
        // Keep the explicit ellipse stable while Compose owns the real button.
        defaults.copy(shape = customShape, pressedShape = customShape)
      }
      else -> defaults
    }
  }
  val icon = properties["icon"] as? String
  val iconSize = properties.number("iconSize")
    ?.takeIf { it.isFinite() && it >= 0.0 }
    ?.dp ?: ButtonDefaults.iconSizeFor(buttonHeight)
  val iconColor = properties.color("iconColor")
  val label = properties["label"] as? String ?: ""
  val labelTextOptions = properties["labelTextOptions"] as? Map<*, *>
  val labelColor = properties.color("labelColor") ?: Color.Unspecified
  val iconOnly = icon != null && label.isEmpty()
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val trailingIcon = properties.boolean("trailingIcon") && !iconOnly
  val iconSpacing = properties.number("iconSpacing")?.dp ?: ButtonDefaults.iconSpacingFor(buttonHeight)
  val padding = properties["padding"] as? List<*>
  val contentPadding = if (padding?.size == 4) {
    PaddingValues(
      start = ((padding[0] as? Number)?.toDouble() ?: 0.0).dp,
      top = ((padding[1] as? Number)?.toDouble() ?: 0.0).dp,
      end = ((padding[2] as? Number)?.toDouble() ?: 0.0).dp,
      bottom = ((padding[3] as? Number)?.toDouble() ?: 0.0).dp,
    )
  } else if (iconOnly) {
    PaddingValues(horizontal = maxOf(0.dp, (buttonHeight - iconSize) / 2))
  } else ButtonDefaults.contentPaddingFor(
    buttonHeight,
    hasStartIcon = icon != null && !trailingIcon,
    hasEndIcon = trailingIcon,
  )
  @Composable
  fun content() {
    Row(
      verticalAlignment = Alignment.CenterVertically,
      horizontalArrangement = Arrangement.Center,
    ) {
      if (icon != null && !trailingIcon) {
        Icon(nativeM3EIcon(icon), contentDescription = if (iconOnly) semanticLabel else null, modifier = Modifier.size(iconSize), tint = iconColor ?: LocalContentColor.current)
        if (label.isNotEmpty()) Spacer(Modifier.width(iconSpacing))
      }
      if (label.isNotEmpty()) NativeM3EListText(
        label,
        labelTextOptions,
        labelColor,
        maxLinesLimit = 1,
        defaultOverflow = TextOverflow.Ellipsis,
        baseStyle = ButtonDefaults.textStyleFor(buttonHeight),
      )
      if (icon != null && trailingIcon) {
        Spacer(Modifier.width(iconSpacing))
        Icon(nativeM3EIcon(icon), contentDescription = null, modifier = Modifier.size(iconSize), tint = iconColor ?: LocalContentColor.current)
      }
    }
  }
  val click = { if (enabled) onEvent("pressed", null) }

  val button: @Composable () -> Unit = { when (style) {
    "plain" -> TextButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shapes = shapes,
      colors = ButtonDefaults.textButtonColors(
        contentColor = foreground ?: Color.Unspecified,
      ),
      contentPadding = contentPadding,
    ) { content() }

    "bordered" -> OutlinedButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shapes = shapes,
      border = borderColor?.let { BorderStroke(1.dp, it) } ?: ButtonDefaults.outlinedButtonBorder(enabled),
      colors = ButtonDefaults.outlinedButtonColors(
        contentColor = foreground ?: Color.Unspecified,
      ),
      contentPadding = contentPadding,
    ) { content() }

    "tinted", "gray", "glass" -> FilledTonalButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shapes = shapes,
      colors = ButtonDefaults.filledTonalButtonColors(
        containerColor = background ?: Color.Unspecified,
        contentColor = foreground ?: Color.Unspecified,
      ),
      contentPadding = contentPadding,
    ) { content() }

    else -> Button(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shapes = shapes,
      colors = ButtonDefaults.buttonColors(
        containerColor = background ?: Color.Unspecified,
        contentColor = foreground ?: Color.Unspecified,
      ),
      contentPadding = contentPadding,
    ) { content() }
  } }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    if (iconOnly && semanticLabel != null) {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
        tooltip = { NativeM3EPlainActionTooltip(semanticLabel) },
        state = rememberTooltipState(),
      ) { button() }
    } else {
      button()
    }
  }
}

@Composable
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
private fun NativeM3EFilterChip(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val label = properties["label"] as? String ?: ""
  val selected = properties.boolean("selected")
  val showCheckmark = properties.boolean("showCheckmark")
  val leadingIcon = properties["leadingIcon"] as? String
  val trailingIcon = properties["trailingIcon"] as? String
  val maxWidth = properties.number("maxWidth")?.takeIf { it.isFinite() && it > 0.0 }?.dp
  val density = LocalDensity.current
  val chipModifier = (if (maxWidth != null) {
    Modifier.wrapContentWidth(unbounded = true).widthIn(max = maxWidth)
  } else {
    Modifier.wrapContentWidth(unbounded = true)
  })
    .wrapContentHeight(unbounded = true)
    .onSizeChanged { size ->
      onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
      onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
    }
  val leading: (@Composable () -> Unit)? = when {
    selected && showCheckmark -> ({
      Icon(Icons.Filled.Check, contentDescription = null, modifier = Modifier.size(FilterChipDefaults.IconSize))
    })
    leadingIcon != null -> ({
      Icon(nativeM3EIcon(leadingIcon), contentDescription = null, modifier = Modifier.size(FilterChipDefaults.IconSize))
    })
    else -> null
  }
  val trailing: (@Composable () -> Unit)? = trailingIcon?.let { name -> ({
    Icon(nativeM3EIcon(name), contentDescription = null, modifier = Modifier.size(FilterChipDefaults.IconSize))
  }) }
  val click = { onEvent("selectedChanged", !selected) }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    if (properties.boolean("elevated")) {
      ElevatedFilterChip(
        selected = selected,
        onClick = click,
        label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        modifier = chipModifier,
        enabled = enabled,
        leadingIcon = leading,
        trailingIcon = trailing,
        shapes = FilterChipDefaults.shapes(),
      )
    } else {
      FilterChip(
        selected = selected,
        onClick = click,
        label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        modifier = chipModifier,
        enabled = enabled,
        leadingIcon = leading,
        trailingIcon = trailing,
        shapes = FilterChipDefaults.shapes(),
      )
    }
  }
}

@Composable
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
private fun NativeM3EInputChip(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val label = properties["label"] as? String ?: ""
  val selected = properties.boolean("selected")
  val dismissible = properties.boolean("dismissible")
  val dismissLabel = (properties["dismissLabel"] as? String)?.takeIf { it.isNotBlank() }
  val leadingIcon = properties["leadingIcon"] as? String
  val avatarIcon = properties["avatarIcon"] as? String
  val avatarBytes = properties["avatarImageBytes"] as? ByteArray
  val avatarDescription = (properties["avatarSemanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val maxWidth = properties.number("maxWidth")?.takeIf { it.isFinite() && it > 0.0 }?.dp
  val density = LocalDensity.current
  val avatarSizePx = with(density) { InputChipDefaults.AvatarSize.roundToPx() }
  val avatarBitmap = rememberM3EImageBitmapResult(avatarBytes, avatarSizePx, avatarSizePx).image
  val avatarContent: (@Composable () -> Unit)? = if (avatarBytes != null) ({
    Box(Modifier.size(InputChipDefaults.AvatarSize)) {
      avatarBitmap?.let { bitmap ->
        Image(
          bitmap,
          contentDescription = avatarDescription,
          contentScale = ContentScale.Crop,
          modifier = Modifier.size(InputChipDefaults.AvatarSize).clip(CircleShape),
        )
      }
    }
  }) else avatarIcon?.let { name -> ({
    Icon(nativeM3EIcon(name), contentDescription = avatarDescription, modifier = Modifier.size(InputChipDefaults.AvatarSize))
  }) }
  val leadingContent: (@Composable () -> Unit)? = leadingIcon?.let { name -> ({
    Icon(nativeM3EIcon(name), contentDescription = null, modifier = Modifier.size(InputChipDefaults.IconSize))
  }) }
  val trailingContent: (@Composable () -> Unit)? = if (dismissible) ({
    Icon(Icons.Filled.Close, contentDescription = dismissLabel, modifier = Modifier.size(InputChipDefaults.AvatarSize))
  }) else null
  val chipModifier = (if (maxWidth != null) {
    Modifier.wrapContentWidth(unbounded = true).widthIn(max = maxWidth)
  } else {
    Modifier.wrapContentWidth(unbounded = true)
  })
    .wrapContentHeight(unbounded = true)
    .onSizeChanged { size ->
      onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
      onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
    }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    InputChip(
      selected = selected,
      onClick = {
        if (dismissible) onEvent("dismissed", null)
        else onEvent("selectedChanged", !selected)
      },
      label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
      shapes = InputChipDefaults.shapes(),
      modifier = chipModifier,
      enabled = enabled,
      leadingIcon = leadingContent,
      avatar = avatarContent,
      trailingIcon = trailingContent,
    )
  }
}

@Composable
private fun NativeM3EActionChip(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
  suggestion: Boolean,
) {
  val label = properties["label"] as? String ?: ""
  val leadingIcon = properties["leadingIcon"] as? String
  val trailingIcon = properties["trailingIcon"] as? String
  val maxWidth = properties.number("maxWidth")?.takeIf { it.isFinite() && it > 0.0 }?.dp
  val density = LocalDensity.current
  val chipModifier = (if (maxWidth != null) {
    Modifier.wrapContentWidth(unbounded = true).widthIn(max = maxWidth)
  } else {
    Modifier.wrapContentWidth(unbounded = true)
  })
    .wrapContentHeight(unbounded = true)
    .onSizeChanged { size ->
      onEvent("measuredWidth", with(density) { size.width.toDp().value.toDouble() })
      onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
    }
  val iconSize = if (suggestion) SuggestionChipDefaults.IconSize else AssistChipDefaults.IconSize
  val leadingContent: (@Composable () -> Unit)? = leadingIcon?.let { name -> ({
    Icon(nativeM3EIcon(name), contentDescription = null, modifier = Modifier.size(iconSize))
  }) }
  val trailingContent: (@Composable () -> Unit)? = trailingIcon?.let { name -> ({
    Icon(nativeM3EIcon(name), contentDescription = null, modifier = Modifier.size(AssistChipDefaults.IconSize))
  }) }
  val click = { onEvent("pressed", null) }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    if (suggestion) {
      if (properties.boolean("elevated")) {
        ElevatedSuggestionChip(
          onClick = click,
          label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
          modifier = chipModifier,
          enabled = enabled,
          icon = leadingContent,
        )
      } else {
        SuggestionChip(
          onClick = click,
          label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
          modifier = chipModifier,
          enabled = enabled,
          icon = leadingContent,
        )
      }
    } else if (properties.boolean("elevated")) {
      ElevatedAssistChip(
        onClick = click,
        label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        modifier = chipModifier,
        enabled = enabled,
        leadingIcon = leadingContent,
        trailingIcon = trailingContent,
      )
    } else {
      AssistChip(
        onClick = click,
        label = { Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        modifier = chipModifier,
        enabled = enabled,
        leadingIcon = leadingContent,
        trailingIcon = trailingContent,
      )
    }
  }
}

private fun nativePopupMenuSelectionEvent(index: Int, item: Map<*, *>): Any {
  val id = item["id"] as? Number ?: return index
  return mapOf("index" to index, "id" to id)
}

@Composable
private fun nativePopupMenuItemShape(items: List<*>, index: Int): Shape {
  var start = index
  while (start > 0 && (items[start - 1] as? Map<*, *>)?.get("divider") != true) {
    start--
  }
  var end = index
  while (end < items.lastIndex && (items[end + 1] as? Map<*, *>)?.get("divider") != true) {
    end++
  }
  return MenuDefaults.itemShape(index - start, end - start + 1).shape
}

@Composable
private fun nativeM3EPopupLeadingIcon(imageBytes: ByteArray?, iconName: String?): (@Composable () -> Unit)? {
  if (imageBytes == null) {
    return iconName?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) }
  }
  val targetPx = with(LocalDensity.current) { 32.dp.roundToPx() }
  val imageLoad = rememberM3EImageBitmapResult(imageBytes, targetPx, targetPx)
  val image = imageLoad.image
  if (image == null && imageLoad.complete) {
    return iconName?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) }
  }
  return ({
    Box(Modifier.size(32.dp), contentAlignment = Alignment.Center) {
      if (image != null) {
        Image(image, contentDescription = null, modifier = Modifier.size(32.dp).clip(CircleShape))
      } else if (iconName != null) {
        Icon(nativeM3EIcon(iconName), contentDescription = null)
      }
    }
  })
}

@Composable
@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
private fun NativeM3EPopupMenuButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  var expanded by remember { mutableStateOf(false) }
  var pendingSelection by remember { mutableStateOf<Any?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  LaunchedEffect(enabled) { if (!enabled) expanded = false }
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  val anchorType = properties["anchorType"] as? String ?: "text"
  val tint = properties.color("tint")
  val label = properties["label"] as? String ?: ""
  val buttonHeight = maxOf(ButtonDefaults.MinHeight, (properties.number("buttonHeight") ?: 40.0).dp)
  val buttonShapes = ButtonDefaults.shapesFor(buttonHeight)
  val buttonPadding = ButtonDefaults.contentPaddingFor(buttonHeight, hasEndIcon = true)
  val buttonTextStyle = ButtonDefaults.textStyleFor(buttonHeight)
  val buttonIconSize = ButtonDefaults.iconSizeFor(buttonHeight)
  val requestedIconSize = (properties.number("buttonSize") ?: 44.0).dp
  val iconSizeTier = when {
    requestedIconSize >= IconButtonDefaults.extraLargeContainerSize().height -> "extraLarge"
    requestedIconSize >= IconButtonDefaults.largeContainerSize().height -> "large"
    requestedIconSize >= IconButtonDefaults.mediumContainerSize().height -> "medium"
    requestedIconSize < IconButtonDefaults.smallContainerSize().height -> "extraSmall"
    else -> "small"
  }
  val iconContainerSize = when (iconSizeTier) {
    "extraSmall" -> IconButtonDefaults.extraSmallContainerSize()
    "medium" -> IconButtonDefaults.mediumContainerSize()
    "large" -> IconButtonDefaults.largeContainerSize()
    "extraLarge" -> IconButtonDefaults.extraLargeContainerSize()
    else -> IconButtonDefaults.smallContainerSize()
  }
  val iconGraphicSize = when (iconSizeTier) {
    "extraSmall" -> IconButtonDefaults.extraSmallIconSize
    "medium" -> IconButtonDefaults.mediumIconSize
    "large" -> IconButtonDefaults.largeIconSize
    "extraLarge" -> IconButtonDefaults.extraLargeIconSize
    else -> IconButtonDefaults.smallIconSize
  }
  val iconShape = when (iconSizeTier) {
    "extraSmall" -> IconButtonDefaults.extraSmallRoundShape
    "medium" -> IconButtonDefaults.mediumRoundShape
    "large" -> IconButtonDefaults.largeRoundShape
    "extraLarge" -> IconButtonDefaults.extraLargeRoundShape
    else -> IconButtonDefaults.smallRoundShape
  }
  val iconPressedShape = when (iconSizeTier) {
    "extraSmall" -> IconButtonDefaults.extraSmallPressedShape
    "medium" -> IconButtonDefaults.mediumPressedShape
    "large" -> IconButtonDefaults.largePressedShape
    "extraLarge" -> IconButtonDefaults.extraLargePressedShape
    else -> IconButtonDefaults.smallPressedShape
  }
  val iconShapes = IconButtonDefaults.shapes(shape = iconShape, pressedShape = iconPressedShape)
  val iconModifier = Modifier.size(iconContainerSize.width, iconContainerSize.height)
  val density = LocalDensity.current.density
  @Composable
  fun triggerContent() {
    Text(label, style = buttonTextStyle)
    Icon(Icons.Filled.ArrowDropDown, contentDescription = null, modifier = Modifier.size(buttonIconSize))
  }
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.CenterStart) {
  Box(Modifier.onSizeChanged { size ->
    if (anchorType == "text") {
      onEvent("triggerSize", listOf(size.width / density, size.height / density))
    }
  }) {
    if (anchorType == "text") {
      when (properties["style"] as? String) {
        "filled" -> Button(
          onClick = { expanded = true }, enabled = enabled,
          modifier = Modifier.heightIn(min = buttonHeight),
          shapes = buttonShapes, contentPadding = buttonPadding,
          colors = ButtonDefaults.buttonColors(contentColor = tint ?: Color.Unspecified),
        ) { triggerContent() }
        "tonal" -> FilledTonalButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = Modifier.heightIn(min = buttonHeight),
          shapes = buttonShapes, contentPadding = buttonPadding,
          colors = ButtonDefaults.filledTonalButtonColors(contentColor = tint ?: Color.Unspecified),
        ) { triggerContent() }
        "outlined" -> OutlinedButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = Modifier.heightIn(min = buttonHeight),
          shapes = buttonShapes, contentPadding = buttonPadding,
          colors = ButtonDefaults.outlinedButtonColors(contentColor = tint ?: Color.Unspecified),
        ) { triggerContent() }
        else -> TextButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = Modifier.heightIn(min = buttonHeight),
          shapes = buttonShapes, contentPadding = buttonPadding,
          colors = ButtonDefaults.textButtonColors(contentColor = tint ?: Color.Unspecified),
        ) { triggerContent() }
      }
    }
    if (anchorType == "icon") {
      val iconContent: @Composable () -> Unit = {
        Icon(
          nativeM3EIcon(properties["icon"] as? String),
          contentDescription = properties["semanticLabel"] as? String ?: "More options",
          tint = tint ?: LocalContentColor.current,
          modifier = Modifier.size(iconGraphicSize),
        )
      }
      when (properties["style"] as? String) {
        "filled" -> FilledIconButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = iconModifier,
          shapes = iconShapes,
          colors = IconButtonDefaults.filledIconButtonColors(contentColor = tint ?: Color.Unspecified),
          content = iconContent,
        )
        "tonal" -> FilledTonalIconButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = iconModifier,
          shapes = iconShapes,
          colors = IconButtonDefaults.filledTonalIconButtonColors(contentColor = tint ?: Color.Unspecified),
          content = iconContent,
        )
        "outlined" -> OutlinedIconButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = iconModifier,
          shapes = iconShapes,
          colors = IconButtonDefaults.outlinedIconButtonColors(contentColor = tint ?: Color.Unspecified),
          content = iconContent,
        )
        else -> IconButton(
          onClick = { expanded = true }, enabled = enabled,
          modifier = iconModifier,
          shapes = iconShapes,
          colors = IconButtonDefaults.iconButtonColors(contentColor = tint ?: Color.Unspecified),
          content = iconContent,
        )
      }
    }
    DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
      DisposableEffect(Unit) {
        onDispose {
          val selection = pendingSelection
          if (selection != null) {
            currentOnEvent("selected", selection)
            pendingSelection = null
          }
        }
      }
      items.forEachIndexed { index, rawItem ->
        val item = rawItem as? Map<*, *> ?: return@forEachIndexed
        if (item["divider"] == true) {
          HorizontalDivider(modifier = Modifier.padding(MenuDefaults.HorizontalDividerPadding))
        } else {
          val labelText = item["label"] as? String ?: ""
          if (labelText.isBlank()) return@forEachIndexed
          val subtitle = item["subtitle"] as? String
          val iconName = item["icon"] as? String
          val destructive = item["destructive"] as? Boolean ?: false
          val imageBytes = item["imageBytes"] as? ByteArray
          val leadingIcon = nativeM3EPopupLeadingIcon(imageBytes, iconName)
          DropdownMenuItem(
            text = { Text(labelText) },
            shape = nativePopupMenuItemShape(items, index),
            supportingText = subtitle?.takeIf { it.isNotBlank() }?.let { text -> ({ Text(text) }) },
            leadingIcon = leadingIcon,
            colors = if (destructive) MenuDefaults.itemColors(
              textColor = MaterialTheme.colorScheme.error,
              leadingIconColor = MaterialTheme.colorScheme.error,
            ) else MenuDefaults.itemColors(),
            enabled = item["enabled"] as? Boolean ?: true,
            onClick = {
              if (pendingSelection == null) {
                pendingSelection = nativePopupMenuSelectionEvent(index, item)
                expanded = false
              }
            },
          )
        }
      }
    }
  }
  }
}

@Composable
private fun NativeM3EAnchoredPopupMenu(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  val x = (properties.number("anchorX") ?: 0.0).dp
  val y = (properties.number("anchorY") ?: 0.0).dp
  var expanded by remember { mutableStateOf(true) }
  var pendingEvent by remember { mutableStateOf<Pair<String, Any?>?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  fun close(event: String, value: Any?) {
    if (pendingEvent == null) {
      pendingEvent = event to value
      expanded = false
    }
  }
  Box(Modifier.absoluteOffset(x = x, y = y).size(1.dp)) {
    DropdownMenu(expanded = expanded, onDismissRequest = { close("dismissed", null) }) {
      DisposableEffect(Unit) {
        onDispose {
          pendingEvent?.let { (event, value) ->
            pendingEvent = null
            currentOnEvent(event, value)
          }
        }
      }
      items.forEachIndexed { index, rawItem ->
        val item = rawItem as? Map<*, *> ?: return@forEachIndexed
        if (item["divider"] == true) {
          HorizontalDivider(modifier = Modifier.padding(MenuDefaults.HorizontalDividerPadding))
        } else {
          val label = item["label"] as? String ?: ""
          if (label.isBlank()) return@forEachIndexed
          val subtitle = item["subtitle"] as? String
          val iconName = item["icon"] as? String
          val destructive = item["destructive"] as? Boolean ?: false
          val imageBytes = item["imageBytes"] as? ByteArray
          val leadingIcon = nativeM3EPopupLeadingIcon(imageBytes, iconName)
          DropdownMenuItem(
            text = { Text(label) },
            shape = nativePopupMenuItemShape(items, index),
            supportingText = subtitle?.takeIf { it.isNotBlank() }?.let { text -> ({ Text(text) }) },
            leadingIcon = leadingIcon,
            colors = if (destructive) MenuDefaults.itemColors(
              textColor = MaterialTheme.colorScheme.error,
              leadingIconColor = MaterialTheme.colorScheme.error,
            ) else MenuDefaults.itemColors(),
            enabled = item["enabled"] as? Boolean ?: true,
            onClick = {
              close("selected", nativePopupMenuSelectionEvent(index, item))
            },
          )
        }
      }
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ESearchBar(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val query = properties["query"] as? String ?: ""
  val selectionBase = properties.number("selectionBase")?.toInt() ?: query.length
  val selectionExtent = properties.number("selectionExtent")?.toInt() ?: selectionBase
  val desiredSelection = TextRange(
    selectionBase.coerceIn(0, query.length),
    selectionExtent.coerceIn(0, query.length),
  )
  val externalRevision = properties.number("externalRevision")?.toInt() ?: 0
  val fieldState = rememberTextFieldState(
    initialText = query,
    initialSelection = desiredSelection,
  )
  val hint = properties["hint"] as? String ?: ""
  val showClear = fieldState.text.isNotEmpty()
  val autofocus = properties.boolean("autofocus")
  val focusRequested = properties.boolean("focusRequested")
  val focusRequestVersion = properties.number("focusRequestVersion")?.toInt() ?: 0
  var requestedFocus by remember { mutableStateOf(false) }
  var reportedFocus by remember { mutableStateOf(false) }
  val focusRequester = remember { androidx.compose.ui.focus.FocusRequester() }
  val focusManager = LocalFocusManager.current
  val inputInteractions = remember { MutableInteractionSource() }
  val currentOnEvent by rememberUpdatedState(onEvent)
  LaunchedEffect(externalRevision) {
    if (externalRevision > 0 &&
      (fieldState.text.toString() != query || fieldState.selection != desiredSelection)
    ) {
      fieldState.edit {
        if (toString() != query) replace(0, length, query)
        selection = desiredSelection
      }
    }
  }
  LaunchedEffect(fieldState) {
    snapshotFlow {
      Triple(fieldState.text.toString(), fieldState.selection, fieldState.composition)
    }.drop(1).collect { (text, selection, composition) ->
      currentOnEvent("changed", mapOf(
        "text" to text,
        "selectionBase" to selection.start,
        "selectionExtent" to selection.end,
        "composingBase" to (composition?.start ?: -1),
        "composingExtent" to (composition?.end ?: -1),
      ))
    }
  }
  LaunchedEffect(inputInteractions, enabled) {
    if (enabled) {
      inputInteractions.interactions.collect { interaction ->
        if (interaction is PressInteraction.Release) currentOnEvent("tapped", null)
      }
    }
  }
  LaunchedEffect(autofocus) {
    if (autofocus && !requestedFocus) {
      requestedFocus = true
      focusRequester.requestFocus()
    }
  }
  LaunchedEffect(focusRequestVersion) {
    if (focusRequestVersion > 0) {
      if (focusRequested) focusRequester.requestFocus() else focusManager.clearFocus()
    }
  }
  val inputModifier = Modifier
    .then(if (autofocus || focusRequestVersion > 0) Modifier.focusRequester(focusRequester) else Modifier)
    .onFocusChanged { state ->
      if (reportedFocus != state.hasFocus) {
        reportedFocus = state.hasFocus
        currentOnEvent("focusChanged", state.hasFocus)
      }
    }
  val clearIcon: (@Composable () -> Unit)? = if (showClear) {
    {
      IconButton(
        onClick = { currentOnEvent("cleared", null) },
        enabled = enabled,
        shapes = IconButtonDefaults.shapes(),
      ) {
        Icon(Icons.Filled.Close, contentDescription = properties["clearDescription"] as? String ?: "Clear search")
      }
    }
  } else null
  val suggestions = properties["searchSuggestions"] as? List<*>
  if (suggestions != null) {
    val prefersDockedSearch = LocalConfiguration.current.screenWidthDp >= 600
    var useDockedSearch by remember { mutableStateOf(prefersDockedSearch) }
    val searchState = rememberSearchBarState()
    val scope = rememberCoroutineScope()
    var pendingSearchEvent by remember { mutableStateOf<Pair<String, String>?>(null) }
    LaunchedEffect(prefersDockedSearch, useDockedSearch, searchState.currentValue, searchState.isAnimating, pendingSearchEvent) {
      if (prefersDockedSearch != useDockedSearch && pendingSearchEvent == null &&
        searchState.currentValue == SearchBarValue.Collapsed && !searchState.isAnimating
      ) {
        useDockedSearch = prefersDockedSearch
      }
    }
    LaunchedEffect(pendingSearchEvent, searchState) {
      val pending = pendingSearchEvent ?: return@LaunchedEffect
      snapshotFlow {
        searchState.currentValue == SearchBarValue.Collapsed && !searchState.isAnimating
      }.first { it }
      if (pendingSearchEvent == pending) {
        pendingSearchEvent = null
        currentOnEvent(pending.first, pending.second)
      }
    }
    LaunchedEffect(enabled, searchState) {
      if (!enabled) searchState.animateToCollapsed()
    }
    val inputField: @Composable () -> Unit = {
      SearchBarDefaults.InputField(
        textFieldState = fieldState,
        searchBarState = searchState,
        onSearch = { text ->
          if (pendingSearchEvent == null) {
            pendingSearchEvent = "submitted" to text
            scope.launch { searchState.animateToCollapsed() }
          }
        },
        enabled = enabled,
        interactionSource = inputInteractions,
        placeholder = { Text(hint) },
        leadingIcon = {
          if (searchState.currentValue == SearchBarValue.Expanded) {
            IconButton(
              onClick = { scope.launch { searchState.animateToCollapsed() } },
              shapes = IconButtonDefaults.shapes(),
            ) {
              Icon(
                Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = properties["backDescription"] as? String,
              )
            }
          } else {
            Icon(Icons.Filled.Search, contentDescription = null)
          }
        },
        trailingIcon = clearIcon,
        modifier = inputModifier,
      )
    }
    SearchBar(
      state = searchState,
      inputField = inputField,
      modifier = Modifier.fillMaxWidth(),
    )
    val searchResults: @Composable () -> Unit = {
      val currentQuery = fieldState.text.toString()
      val filtered = suggestions.mapNotNull { it as? String }
        .filter { currentQuery.isBlank() || it.contains(currentQuery, ignoreCase = true) }
      LazyColumn(Modifier.fillMaxSize()) {
        items(count = filtered.size) { index ->
          val suggestion = filtered[index]
          ListItem(
            onClick = {
              if (enabled && pendingSearchEvent == null) {
                fieldState.setTextAndPlaceCursorAtEnd(suggestion)
                pendingSearchEvent = "suggestionSelected" to suggestion
                scope.launch { searchState.animateToCollapsed() }
              }
            },
            enabled = enabled,
            leadingContent = { Icon(Icons.Filled.Search, contentDescription = null) },
          ) { Text(suggestion) }
        }
      }
    }
    if (useDockedSearch) {
      ExpandedDockedSearchBar(
        state = searchState,
        inputField = inputField,
      ) { searchResults() }
    } else {
      ExpandedFullScreenSearchBar(
        state = searchState,
        inputField = inputField,
      ) { searchResults() }
    }
    return
  }
  val inputField: @Composable () -> Unit = {
    SearchBarDefaults.InputField(
      state = fieldState,
      onSearch = { currentOnEvent("submitted", it) },
      expanded = false,
      onExpandedChange = {},
      enabled = enabled,
      interactionSource = inputInteractions,
      placeholder = { Text(hint) },
      leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
      trailingIcon = clearIcon,
      modifier = inputModifier,
    )
  }
  SearchBar(
    inputField = inputField,
    expanded = false,
    onExpandedChange = {},
    modifier = Modifier.fillMaxWidth(),
  ) {}
}

private fun nativeM3EGraphemeCount(value: CharSequence): Int {
  val boundaries = BreakIterator.getCharacterInstance()
  boundaries.setText(value.toString())
  boundaries.first()
  var count = 0
  while (boundaries.next() != BreakIterator.DONE) count++
  return count
}

private fun nativeM3EMaxLengthTransformation(maxLength: Int?): InputTransformation? =
  maxLength?.takeIf { it >= 0 }?.let { limit ->
    InputTransformation {
      val proposedCount = nativeM3EGraphemeCount(asCharSequence())
      if (proposedCount > limit && proposedCount >= nativeM3EGraphemeCount(originalText)) {
        revertAllChanges()
      }
    }
  }

@Composable
private fun NativeM3ETextFieldSupporting(
  state: TextFieldState,
  message: String?,
  maxLength: Int?,
) {
  Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
    if (message == null) {
      Spacer(Modifier.weight(1f))
    } else {
      Text(message, modifier = Modifier.weight(1f))
    }
    if (maxLength != null) {
      val count = nativeM3EGraphemeCount(state.text)
      Text(
        text = if (maxLength < 0) "$count" else "$count / $maxLength",
        modifier = Modifier.padding(start = 8.dp),
      )
    }
  }
}

@Composable
private fun NativeM3ETextField(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val query = properties["query"] as? String ?: ""
  val selectionBase = properties.number("selectionBase")?.toInt() ?: query.length
  val selectionExtent = properties.number("selectionExtent")?.toInt() ?: selectionBase
  val desiredSelection = TextRange(
    selectionBase.coerceIn(0, query.length),
    selectionExtent.coerceIn(0, query.length),
  )
  val externalRevision = properties.number("externalRevision")?.toInt() ?: 0
  val fieldState = rememberTextFieldState(
    initialText = query,
    initialSelection = desiredSelection,
  )
  val currentOnEvent by rememberUpdatedState(onEvent)
  LaunchedEffect(externalRevision) {
    if (externalRevision > 0 &&
      (fieldState.text.toString() != query || fieldState.selection != desiredSelection)
    ) {
      fieldState.edit {
        if (toString() != query) replace(0, length, query)
        selection = desiredSelection
      }
    }
  }
  LaunchedEffect(fieldState) {
    snapshotFlow {
      Triple(fieldState.text.toString(), fieldState.selection, fieldState.composition)
    }.drop(1).collect { (text, selection, composition) ->
      currentOnEvent("changed", mapOf(
        "text" to text,
        "selectionBase" to selection.start,
        "selectionExtent" to selection.end,
        "composingBase" to (composition?.start ?: -1),
        "composingExtent" to (composition?.end ?: -1),
      ))
    }
  }
  val label = properties["label"] as? String
  val placeholder = properties["placeholder"] as? String
  val errorText = properties["errorText"] as? String
  val helperText = properties["helperText"] as? String
  val prefixText = properties["prefixText"] as? String
  val suffixText = properties["suffixText"] as? String
  val prefixIcon = properties["prefixIcon"] as? String
  val suffixIcon = properties["suffixIcon"] as? String
  val maxLength = properties.number("maxLength")?.toInt()
  val maxLines = properties.number("maxLines")?.toInt()?.coerceAtLeast(1)
  val minLines = (properties.number("minLines") ?: 1.0).toInt().coerceAtLeast(1)
  val autoHeight = properties.boolean("autoHeight")
  val density = LocalDensity.current
  val autofocus = properties.boolean("autofocus")
  val focusRequested = properties.boolean("focusRequested")
  val focusRequestVersion = properties.number("focusRequestVersion")?.toInt() ?: 0
  var requestedFocus by remember { mutableStateOf(false) }
  var reportedFocus by remember { mutableStateOf(false) }
  val focusRequester = remember { androidx.compose.ui.focus.FocusRequester() }
  val focusManager = LocalFocusManager.current
  LaunchedEffect(autofocus) {
    if (autofocus && !requestedFocus) {
      requestedFocus = true
      focusRequester.requestFocus()
    }
  }
  LaunchedEffect(focusRequestVersion) {
    if (focusRequestVersion > 0) {
      if (focusRequested) focusRequester.requestFocus() else focusManager.clearFocus()
    }
  }
  val baseTextStyle = MaterialTheme.typography.bodyLarge
  val fieldFontWeight = properties.number("fontWeight")?.toInt()?.let(::FontWeight)
  val fieldFontStyle = when (properties["fontStyle"] as? String) {
    "italic" -> FontStyle.Italic
    "normal" -> FontStyle.Normal
    else -> null
  }
  val fieldFontFamily = LocalM3EFlutterFonts.current.resolve(
    properties["fontFamily"] as? String,
    variations = properties["fontVariations"],
    requestedWeight = fieldFontWeight?.weight ?: baseTextStyle.fontWeight?.weight,
    requestedItalic = (fieldFontStyle ?: baseTextStyle.fontStyle) == FontStyle.Italic,
    allowDeviceFamily = true,
  )
  val textStyle = baseTextStyle.copy(
    fontSize = properties.number("fontSize")?.sp ?: baseTextStyle.fontSize,
    fontWeight = fieldFontWeight ?: baseTextStyle.fontWeight,
    fontStyle = fieldFontStyle ?: baseTextStyle.fontStyle,
    fontFamily = fieldFontFamily ?: baseTextStyle.fontFamily,
    textDecoration = nativeM3ETextDecoration(properties["textDecoration"] as? String)
      ?: baseTextStyle.textDecoration,
    fontFeatureSettings = properties["fontFeatureSettings"] as? String
      ?: baseTextStyle.fontFeatureSettings,
    letterSpacing = properties.number("letterSpacing")?.sp ?: baseTextStyle.letterSpacing,
    lineHeight = properties.number("lineHeight")?.em ?: baseTextStyle.lineHeight,
    color = properties.color("textColor") ?: Color.Unspecified,
  )
  val keyboardType = nativeM3EKeyboardType(properties["keyboardType"] as? String)
  val imeAction = when (properties["textInputAction"] as? String) {
    "none", "newline" -> ImeAction.None
    "unspecified" -> ImeAction.Default
    "go" -> ImeAction.Go
    "search" -> ImeAction.Search
    "next" -> ImeAction.Next
    "previous" -> ImeAction.Previous
    "send" -> ImeAction.Send
    else -> ImeAction.Done
  }
  val capitalization = when (properties["capitalization"] as? String) {
    "characters" -> KeyboardCapitalization.Characters
    "words" -> KeyboardCapitalization.Words
    "sentences" -> KeyboardCapitalization.Sentences
    else -> KeyboardCapitalization.None
  }
  val padding = properties["contentPadding"] as? List<*>
  val layoutDirection = LocalLayoutDirection.current
  val customContentPadding = padding?.takeIf { it.size == 4 }?.let {
    val left = ((it[0] as? Number)?.toDouble() ?: 0.0).dp
    val top = ((it[1] as? Number)?.toDouble() ?: 0.0).dp
    val right = ((it[2] as? Number)?.toDouble() ?: 0.0).dp
    val bottom = ((it[3] as? Number)?.toDouble() ?: 0.0).dp
    PaddingValues(
      start = if (layoutDirection == LayoutDirection.Ltr) left else right,
      top = top,
      end = if (layoutDirection == LayoutDirection.Ltr) right else left,
      bottom = bottom,
    )
  }
  val filledContentPadding = customContentPadding ?: if (label == null) {
    TextFieldDefaults.contentPaddingWithoutLabel()
  } else TextFieldDefaults.contentPaddingWithLabel()
  val outlinedContentPadding = customContentPadding ?: if (label == null) {
    OutlinedTextFieldDefaults.contentPaddingWithoutLabel()
  } else OutlinedTextFieldDefaults.contentPaddingWithLabel()
  val contentTypes = (properties["autofillHints"] as? List<*>)
    .orEmpty()
    .mapNotNull { hint ->
      when (hint as? String) {
        "email", "emailAddress" -> ContentType.EmailAddress
        "username" -> ContentType.Username
        "newUsername" -> ContentType.NewUsername
        "password" -> ContentType.Password
        "newPassword" -> ContentType.NewPassword
        "telephoneNumber" -> ContentType.PhoneNumber
        "postalAddress" -> ContentType.PostalAddress
        "postalCode" -> ContentType.PostalCode
        "name" -> ContentType.PersonFullName
        "givenName" -> ContentType.PersonFirstName
        "familyName" -> ContentType.PersonLastName
        "creditCardNumber" -> ContentType.CreditCardNumber
        else -> null
      }
    }
  val textAlign = when (properties["textAlign"] as? String) {
    "center" -> TextAlign.Center
    "left" -> TextAlign.Left
    "right" -> TextAlign.Right
    "end" -> TextAlign.End
    "justify" -> TextAlign.Justify
    else -> TextAlign.Start
  }
  val fieldModifier = Modifier
      .fillMaxWidth()
      .then(
        if (autoHeight) Modifier.wrapContentHeight(unbounded = true).onSizeChanged { size ->
          onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
        } else Modifier,
      )
      .then(if (autofocus || focusRequestVersion > 0) Modifier.focusRequester(focusRequester) else Modifier)
      .then(
        if (contentTypes.isEmpty()) Modifier else Modifier.semantics {
          contentType = contentTypes.reduce { accumulated, type -> accumulated + type }
        },
      )
      .then(maxLength?.takeIf { it >= 0 }?.let { limit ->
        Modifier.semantics { maxTextLength = limit }
      } ?: Modifier)
      .then(
        if (properties.boolean("hasTapCallback")) Modifier.pointerInput(Unit) {
          awaitEachGesture {
            awaitFirstDown(pass = androidx.compose.ui.input.pointer.PointerEventPass.Initial)
            val up = waitForUpOrCancellation(pass = androidx.compose.ui.input.pointer.PointerEventPass.Initial)
            if (up != null) onEvent("tapped", null)
          }
        } else Modifier,
      )
      .onFocusChanged { state ->
        if (reportedFocus != state.hasFocus) {
          reportedFocus = state.hasFocus
          onEvent("focusChanged", state.hasFocus)
        }
      }
  val inputTransformation = nativeM3EMaxLengthTransformation(maxLength)
  val supportingMessage = errorText ?: helperText
  val supportingContent: (@Composable () -> Unit)? =
    if (supportingMessage != null || maxLength != null) {
      { NativeM3ETextFieldSupporting(fieldState, supportingMessage, maxLength) }
    } else null
  val keyboardOptions = KeyboardOptions(
      capitalization = capitalization,
      autoCorrectEnabled = properties.boolean("autocorrect", true),
      keyboardType = keyboardType,
      imeAction = imeAction,
    )
  val prefixIconColors = properties["prefixIconColors"] as? Map<*, *>
  val suffixIconColors = properties["suffixIconColors"] as? Map<*, *>
  val outlineBorderColors = properties["outlineBorderColors"] as? Map<*, *>
  val underlineIndicatorColors = properties["underlineIndicatorColors"] as? Map<*, *>
  fun iconRole(colors: Map<*, *>?, role: String): Color =
    (colors?.get(role) as? Number)?.toLong()?.toInt()?.let(::Color) ?: Color.Unspecified
  val containerColor = if (properties.boolean("filled")) {
    properties.color("fillColor") ?: MaterialTheme.colorScheme.surfaceContainerHighest
  } else Color.Transparent
  val outlineRadii = (properties["outlineRadii"] as? List<*>)
    ?.takeIf { it.size == 4 }
    ?.mapNotNull { (it as? Number)?.toFloat()?.takeIf { radius -> radius.isFinite() && radius >= 0f } }
    ?.takeIf { it.size == 4 }
  val outlineShape = outlineRadii?.let {
    AbsoluteRoundedCornerShape(it[0].dp, it[1].dp, it[2].dp, it[3].dp)
  } ?: OutlinedTextFieldDefaults.roundedShape
  val underlineRadii = (properties["underlineRadii"] as? List<*>)
    ?.takeIf { it.size == 4 }
    ?.mapNotNull { (it as? Number)?.toFloat()?.takeIf { radius -> radius.isFinite() && radius >= 0f } }
    ?.takeIf { it.size == 4 }
  val underlineShape = underlineRadii?.let {
    AbsoluteRoundedCornerShape(it[0].dp, it[1].dp, it[2].dp, it[3].dp)
  } ?: TextFieldDefaults.shape
  val colors = OutlinedTextFieldDefaults.colors(
      focusedContainerColor = containerColor,
      unfocusedContainerColor = containerColor,
      disabledContainerColor = containerColor,
      errorContainerColor = containerColor,
      focusedBorderColor = iconRole(outlineBorderColors, "focused"),
      unfocusedBorderColor = iconRole(outlineBorderColors, "unfocused"),
      disabledBorderColor = iconRole(outlineBorderColors, "disabled"),
      errorBorderColor = iconRole(outlineBorderColors, "error"),
      focusedLeadingIconColor = iconRole(prefixIconColors, "focused"),
      unfocusedLeadingIconColor = iconRole(prefixIconColors, "unfocused"),
      disabledLeadingIconColor = iconRole(prefixIconColors, "disabled"),
      errorLeadingIconColor = iconRole(prefixIconColors, "error"),
      focusedTrailingIconColor = iconRole(suffixIconColors, "focused"),
      unfocusedTrailingIconColor = iconRole(suffixIconColors, "unfocused"),
      disabledTrailingIconColor = iconRole(suffixIconColors, "disabled"),
      errorTrailingIconColor = iconRole(suffixIconColors, "error"),
    )
  val leadingIconContent: @Composable (() -> Unit)? = prefixIcon?.let { name -> ({
    Icon(
      nativeM3EIcon(name),
      contentDescription = properties["prefixIconSemanticLabel"] as? String,
      modifier = properties.number("prefixIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
      tint = properties.color("prefixIconColor") ?: LocalContentColor.current,
    )
  }) }
  val trailingIconContent: @Composable (() -> Unit)? = suffixIcon?.let { name -> ({
    Icon(
      nativeM3EIcon(name),
      contentDescription = properties["suffixIconSemanticLabel"] as? String,
      modifier = properties.number("suffixIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
      tint = properties.color("suffixIconColor") ?: LocalContentColor.current,
    )
  }) }
  if ((properties.boolean("filled") || properties.boolean("underlined") || properties.boolean("borderless")) &&
      !properties.boolean("outlined")) {
    val borderless = properties.boolean("borderless")
    val fillColor = if (properties.boolean("filled")) {
      properties.color("fillColor") ?: Color.Unspecified
    } else Color.Transparent
    val filledColors = TextFieldDefaults.colors(
      focusedContainerColor = fillColor,
      unfocusedContainerColor = fillColor,
      disabledContainerColor = fillColor,
      errorContainerColor = fillColor,
      focusedIndicatorColor = if (borderless) Color.Transparent else iconRole(underlineIndicatorColors, "focused"),
      unfocusedIndicatorColor = if (borderless) Color.Transparent else iconRole(underlineIndicatorColors, "unfocused"),
      disabledIndicatorColor = if (borderless) Color.Transparent else iconRole(underlineIndicatorColors, "disabled"),
      errorIndicatorColor = if (borderless) Color.Transparent else iconRole(underlineIndicatorColors, "error"),
      focusedLeadingIconColor = iconRole(prefixIconColors, "focused"),
      unfocusedLeadingIconColor = iconRole(prefixIconColors, "unfocused"),
      disabledLeadingIconColor = iconRole(prefixIconColors, "disabled"),
      errorLeadingIconColor = iconRole(prefixIconColors, "error"),
      focusedTrailingIconColor = iconRole(suffixIconColors, "focused"),
      unfocusedTrailingIconColor = iconRole(suffixIconColors, "unfocused"),
      disabledTrailingIconColor = iconRole(suffixIconColors, "disabled"),
      errorTrailingIconColor = iconRole(suffixIconColors, "error"),
    )
    if (properties.boolean("obscureText")) {
      SecureTextField(
        state = fieldState,
        modifier = fieldModifier,
        enabled = enabled && !properties.boolean("readOnly"),
        textStyle = textStyle.copy(textAlign = textAlign),
        label = label?.let { text -> ({ Text(text) }) },
        placeholder = placeholder?.let { text -> ({ Text(text) }) },
        leadingIcon = leadingIconContent,
        trailingIcon = trailingIconContent,
        prefix = prefixText?.let { text -> ({ Text(text) }) },
        suffix = suffixText?.let { text -> ({ Text(text) }) },
        supportingText = supportingContent,
        isError = errorText != null,
        inputTransformation = inputTransformation,
        keyboardOptions = keyboardOptions.copy(
          capitalization = KeyboardCapitalization.None,
          autoCorrectEnabled = false,
          keyboardType = nativeM3ESecureKeyboardType(keyboardType),
        ),
        onKeyboardAction = if (imeAction == ImeAction.None || imeAction == ImeAction.Default) null else { performDefaultAction ->
          if (imeAction == ImeAction.Done || imeAction == ImeAction.Go ||
            imeAction == ImeAction.Search || imeAction == ImeAction.Send
          ) onEvent("submitted", fieldState.text.toString())
          performDefaultAction()
        },
        colors = filledColors,
        shape = underlineShape,
        contentPadding = filledContentPadding,
      )
    } else {
      TextField(
        state = fieldState,
        modifier = fieldModifier,
        enabled = enabled,
        readOnly = properties.boolean("readOnly"),
        textStyle = textStyle.copy(textAlign = textAlign),
        label = label?.let { text -> ({ Text(text) }) },
        placeholder = placeholder?.let { text -> ({ Text(text) }) },
        leadingIcon = leadingIconContent,
        trailingIcon = trailingIconContent,
        prefix = prefixText?.let { text -> ({ Text(text) }) },
        suffix = suffixText?.let { text -> ({ Text(text) }) },
        supportingText = supportingContent,
        isError = errorText != null,
        inputTransformation = inputTransformation,
        keyboardOptions = keyboardOptions,
        onKeyboardAction = if (imeAction == ImeAction.None || imeAction == ImeAction.Default) null else { performDefaultAction ->
          if (imeAction == ImeAction.Done || imeAction == ImeAction.Go ||
            imeAction == ImeAction.Search || imeAction == ImeAction.Send
          ) onEvent("submitted", fieldState.text.toString())
          performDefaultAction()
        },
        lineLimits = if (maxLines == 1) TextFieldLineLimits.SingleLine else
          TextFieldLineLimits.MultiLine(minLines.coerceAtMost(maxLines ?: Int.MAX_VALUE), maxLines ?: Int.MAX_VALUE),
        colors = filledColors,
        shape = underlineShape,
        contentPadding = filledContentPadding,
      )
    }
    return
  }
  if (properties.boolean("obscureText")) {
    OutlinedSecureTextField(
      state = fieldState,
      modifier = fieldModifier,
      enabled = enabled && !properties.boolean("readOnly"),
      textStyle = textStyle.copy(textAlign = textAlign),
      label = label?.let { text -> ({ Text(text) }) },
      placeholder = placeholder?.let { text -> ({ Text(text) }) },
      leadingIcon = leadingIconContent,
      trailingIcon = trailingIconContent,
      prefix = prefixText?.let { text -> ({ Text(text) }) },
      suffix = suffixText?.let { text -> ({ Text(text) }) },
      supportingText = supportingContent,
      isError = errorText != null,
      inputTransformation = inputTransformation,
      keyboardOptions = keyboardOptions.copy(
        capitalization = KeyboardCapitalization.None,
        autoCorrectEnabled = false,
        keyboardType = nativeM3ESecureKeyboardType(keyboardType),
      ),
      onKeyboardAction = if (imeAction == ImeAction.None || imeAction == ImeAction.Default) null else { performDefaultAction ->
        if (imeAction == ImeAction.Done || imeAction == ImeAction.Go ||
          imeAction == ImeAction.Search || imeAction == ImeAction.Send
        ) onEvent("submitted", fieldState.text.toString())
        performDefaultAction()
      },
      colors = colors,
      shape = outlineShape,
      contentPadding = outlinedContentPadding,
    )
  } else {
    OutlinedTextField(
      state = fieldState,
      modifier = fieldModifier,
      enabled = enabled,
      readOnly = properties.boolean("readOnly"),
      textStyle = textStyle.copy(textAlign = textAlign),
      label = label?.let { text -> ({ Text(text) }) },
      placeholder = placeholder?.let { text -> ({ Text(text) }) },
      leadingIcon = leadingIconContent,
      trailingIcon = trailingIconContent,
      prefix = prefixText?.let { text -> ({ Text(text) }) },
      suffix = suffixText?.let { text -> ({ Text(text) }) },
      supportingText = supportingContent,
      isError = errorText != null,
      inputTransformation = inputTransformation,
      keyboardOptions = keyboardOptions,
      onKeyboardAction = if (imeAction == ImeAction.None || imeAction == ImeAction.Default) null else { performDefaultAction ->
        if (imeAction == ImeAction.Done || imeAction == ImeAction.Go ||
          imeAction == ImeAction.Search || imeAction == ImeAction.Send
        ) onEvent("submitted", fieldState.text.toString())
        performDefaultAction()
      },
      lineLimits = if (maxLines == 1) TextFieldLineLimits.SingleLine else
        TextFieldLineLimits.MultiLine(minLines.coerceAtMost(maxLines ?: Int.MAX_VALUE), maxLines ?: Int.MAX_VALUE),
      colors = colors,
      shape = outlineShape,
      contentPadding = outlinedContentPadding,
    )
  }
}

@Composable
private fun NativeM3ESwitchListTile(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val density = LocalDensity.current
  val listModifier = Modifier.fillMaxWidth()
    .wrapContentHeight(unbounded = true)
    .onSizeChanged { size ->
      onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
    }
  val checked = properties.boolean("value")
  val title = properties["title"] as? String ?: ""
  val subtitle = properties["subtitle"] as? String
  val titleTextOptions = properties["titleTextOptions"] as? Map<*, *>
  val titleColor = properties.color("titleColor") ?: Color.Unspecified
  val subtitleTextOptions = properties["subtitleTextOptions"] as? Map<*, *>
  val subtitleColor = properties.color("subtitleColor") ?: Color.Unspecified
  val leadingIcon = properties["leadingIcon"] as? String
  val hasOnTap = properties.boolean("hasOnTap")
  val hasOnChanged = properties.boolean("hasOnChanged")
  val canToggle = enabled && hasOnChanged
  val supporting: @Composable (() -> Unit)? = subtitle?.let { text -> ({ NativeM3EListText(text, subtitleTextOptions, subtitleColor) }) }
  val leading: @Composable (() -> Unit)? =
    leadingIcon?.let { name -> ({
      Icon(
        nativeM3EIcon(name),
        contentDescription = properties["leadingIconSemanticLabel"] as? String,
        modifier = properties.number("leadingIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
        tint = properties.color("leadingIconColor") ?: LocalContentColor.current,
      )
    }) }
  val trailing: @Composable () -> Unit = {
    val thumbIconName = if (checked) properties["checkedThumbIcon"] as? String
      else properties["uncheckedThumbIcon"] as? String
    Switch(
      checked = checked,
      onCheckedChange = if (hasOnTap && canToggle) ({ onEvent("changed", it) }) else null,
      enabled = canToggle,
      thumbContent = thumbIconName?.let { name ->
        { NativeM3ESwitchThumbIcon(name) }
      },
      colors = properties.color("activeColor")?.let { color ->
        SwitchDefaults.colors(checkedTrackColor = color)
      } ?: SwitchDefaults.colors(),
    )
  }
  if (hasOnTap || canToggle) {
    ListItem(
      onClick = {
        if (hasOnTap) onEvent("tapped", null) else onEvent("changed", !checked)
      },
      modifier = listModifier.then(
        if (!hasOnTap) Modifier.semantics {
          role = Role.Switch
          toggleableState = if (checked) ToggleableState.On else ToggleableState.Off
        } else Modifier
      ),
      enabled = enabled,
      supportingContent = supporting,
      leadingContent = leading,
      trailingContent = trailing,
    ) { NativeM3EListText(title, titleTextOptions, titleColor) }
  } else {
    ListItem(
      modifier = listModifier,
      enabled = enabled,
      supportingContent = supporting,
      leadingContent = leading,
      trailingContent = trailing,
    ) { NativeM3EListText(title, titleTextOptions, titleColor) }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EListTile(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val density = LocalDensity.current
  val selected = properties.boolean("selected")
  val segmentIndex = properties.number("segmentIndex")?.toInt()
  val segmentCount = properties.number("segmentCount")?.toInt()
  val segmented = segmentIndex != null && segmentCount != null &&
    segmentCount > 0 && segmentIndex in 0 until segmentCount
  val leadingIcon = properties["leadingIcon"] as? String
  val trailingIcon = properties["trailingIcon"] as? String
  val padding = properties["padding"] as? List<*>
  val contentPadding = if (padding?.size == 4) {
    PaddingValues.Absolute(
      left = ((padding[0] as? Number)?.toDouble() ?: 16.0).dp,
      top = ((padding[1] as? Number)?.toDouble() ?: 10.0).dp,
      right = ((padding[2] as? Number)?.toDouble() ?: 16.0).dp,
      bottom = ((padding[3] as? Number)?.toDouble() ?: 10.0).dp,
    )
  } else ListItemDefaults.ContentPadding
  val backgroundColor = properties.color("backgroundColor")
  val colors = when {
    segmented && backgroundColor == null -> ListItemDefaults.segmentedColors()
    segmented -> ListItemDefaults.segmentedColors(
      containerColor = backgroundColor!!,
      selectedContainerColor = backgroundColor,
    )
    backgroundColor == null -> ListItemDefaults.colors()
    else -> ListItemDefaults.colors(
      containerColor = backgroundColor,
      selectedContainerColor = backgroundColor,
    )
  }
  val title = properties["title"] as? String ?: ""
  val titleTextOptions = properties["titleTextOptions"] as? Map<*, *>
  val titleColor = properties.color("titleColor") ?: Color.Unspecified
  val subtitleTextOptions = properties["subtitleTextOptions"] as? Map<*, *>
  val subtitleColor = properties.color("subtitleColor") ?: Color.Unspecified
  val supporting: @Composable (() -> Unit)? =
    (properties["subtitle"] as? String)?.let { text -> ({ NativeM3EListText(text, subtitleTextOptions, subtitleColor) }) }
  val leading: @Composable (() -> Unit)? =
    leadingIcon?.let { name -> ({
      Icon(
        nativeM3EIcon(name),
        contentDescription = properties["leadingIconSemanticLabel"] as? String,
        modifier = properties.number("leadingIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
        tint = properties.color("leadingIconColor") ?: LocalContentColor.current,
      )
    }) }
  val trailing: @Composable (() -> Unit)? =
    trailingIcon?.let { name -> ({
      Icon(
        nativeM3EIcon(name),
        contentDescription = properties["trailingIconSemanticLabel"] as? String,
        modifier = properties.number("trailingIconSize")?.dp?.let { Modifier.size(it) } ?: Modifier,
        tint = properties.color("trailingIconColor") ?: LocalContentColor.current,
      )
    }) }
  val onLongClick: (() -> Unit)? =
    if (properties.boolean("hasOnLongPress")) ({ onEvent("longPressed", null) }) else null
  val currentOnLongClick by rememberUpdatedState(onLongClick)
  val itemShapes = if (segmented) {
    ListItemDefaults.segmentedShapes(index = segmentIndex, count = segmentCount)
  } else ListItemDefaults.shapes()
  val noninteractiveShapes = if (selected) {
    itemShapes.copy(shape = itemShapes.selectedShape)
  } else itemShapes
  val noninteractiveColors = if (selected) {
    colors.copy(
      containerColor = colors.selectedContainerColor,
      contentColor = colors.selectedContentColor,
      leadingContentColor = colors.selectedLeadingContentColor,
      trailingContentColor = colors.selectedTrailingContentColor,
      supportingContentColor = colors.selectedSupportingContentColor,
    )
  } else colors
  val noninteractiveModifier = Modifier.fillMaxWidth()
        .then(if (selected) Modifier.semantics { this.selected = true } else Modifier)
        .then(if (onLongClick != null && enabled) Modifier
          .pointerInput(Unit) {
            detectTapGestures(onLongPress = { currentOnLongClick?.invoke() })
          }
          .semantics {
            onLongClick {
              currentOnLongClick?.let { action ->
                action()
                true
              } ?: false
            }
          } else Modifier)
  val row: @Composable () -> Unit = {
    if (properties.boolean("hasOnTap")) {
      if (segmented) {
        SegmentedListItem(
          selected = selected,
          onClick = { onEvent("tapped", null) },
          shapes = itemShapes,
          modifier = Modifier.fillMaxWidth(),
          enabled = enabled,
          supportingContent = supporting,
          leadingContent = leading,
          trailingContent = trailing,
          onLongClick = onLongClick,
          colors = colors,
          contentPadding = contentPadding,
        ) { NativeM3EListText(title, titleTextOptions, titleColor) }
      } else {
        ListItem(
          selected = selected,
          onClick = { onEvent("tapped", null) },
          modifier = Modifier.fillMaxWidth(),
          enabled = enabled,
          supportingContent = supporting,
          leadingContent = leading,
          trailingContent = trailing,
          onLongClick = onLongClick,
          colors = colors,
          contentPadding = contentPadding,
        ) { NativeM3EListText(title, titleTextOptions, titleColor) }
      }
    } else if (segmented) {
      SegmentedListItem(
        shapes = noninteractiveShapes,
        modifier = noninteractiveModifier,
        enabled = enabled,
        supportingContent = supporting,
        leadingContent = leading,
        trailingContent = trailing,
        colors = noninteractiveColors,
        contentPadding = contentPadding,
      ) { NativeM3EListText(title, titleTextOptions, titleColor) }
    } else {
      ListItem(
        modifier = noninteractiveModifier,
        enabled = enabled,
        supportingContent = supporting,
        leadingContent = leading,
        trailingContent = trailing,
        shapes = noninteractiveShapes,
        colors = noninteractiveColors,
        contentPadding = contentPadding,
      ) { NativeM3EListText(title, titleTextOptions, titleColor) }
    }
  }
  Column(
    modifier = Modifier.fillMaxWidth()
      .wrapContentHeight(unbounded = true)
      .onSizeChanged { size ->
        onEvent("measuredHeight", with(density) { size.height.toDp().value.toDouble() })
      },
  ) {
    row()
    if (segmented && segmentIndex < segmentCount - 1) {
      Spacer(Modifier.height(ListItemDefaults.SegmentedGap))
    }
  }
}

@Composable
private fun NativeM3ECardSurface(
  properties: Map<String, Any?>,
  cardPressEvents: ReceiveChannel<M3ECardPressEvent>,
  cardHoverEvents: ReceiveChannel<Boolean>,
  cardFocusEvents: ReceiveChannel<Boolean>,
) {
  val style = properties["style"] as? String ?: "filled"
  val cornerRadii = properties["cornerRadii"] as? Map<*, *>
  val density = LocalDensity.current.density
  val shape: Shape = if (cornerRadii != null) {
    val radii = floatArrayOf(
      (cornerRadii["topLeftX"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["topLeftY"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["topRightX"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["topRightY"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["bottomRightX"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["bottomRightY"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["bottomLeftX"] as? Number)?.toFloat() ?: 0f,
      (cornerRadii["bottomLeftY"] as? Number)?.toFloat() ?: 0f,
    )
    GenericShape { size, _ ->
      if (size.width > 0f && size.height > 0f) {
        val scale = maxOf(
          1f,
          (radii[0] + radii[2]) * density / size.width,
          (radii[6] + radii[4]) * density / size.width,
          (radii[1] + radii[7]) * density / size.height,
          (radii[3] + radii[5]) * density / size.height,
        )
        fun corner(index: Int) = CornerRadius(
          radii[index] * density / scale,
          radii[index + 1] * density / scale,
        )
        addRoundRect(
          RoundRect(
            0f,
            0f,
            size.width,
            size.height,
            topLeftCornerRadius = corner(0),
            topRightCornerRadius = corner(2),
            bottomRightCornerRadius = corner(4),
            bottomLeftCornerRadius = corner(6),
          ),
        )
      }
    }
  } else {
    properties.number("radius")?.dp?.let { RoundedCornerShape(it) } ?: when (style) {
      "elevated" -> CardDefaults.elevatedShape
      "outlined" -> CardDefaults.outlinedShape
      else -> CardDefaults.shape
    }
  }
  val customColor = properties.color("color")
  val containerColor = customColor ?: if (properties.boolean("glass")) {
    MaterialTheme.colorScheme.surfaceContainerHigh
  } else null
  val colors = when (style) {
    "elevated" -> containerColor?.let { CardDefaults.elevatedCardColors(containerColor = it) }
      ?: CardDefaults.elevatedCardColors()
    "outlined" -> containerColor?.let { CardDefaults.outlinedCardColors(containerColor = it) }
      ?: CardDefaults.outlinedCardColors()
    else -> containerColor?.let { CardDefaults.cardColors(containerColor = it) }
      ?: CardDefaults.cardColors()
  }
  val requestedElevation = properties.number("elevation")?.dp
  val elevation = when (style) {
    "elevated" -> requestedElevation?.let { CardDefaults.elevatedCardElevation(defaultElevation = it) }
      ?: CardDefaults.elevatedCardElevation()
    "outlined" -> requestedElevation?.let { CardDefaults.outlinedCardElevation(defaultElevation = it) }
      ?: CardDefaults.outlinedCardElevation()
    else -> requestedElevation?.let { CardDefaults.cardElevation(defaultElevation = it) }
      ?: CardDefaults.cardElevation()
  }
  val border = properties.number("borderWidth")?.dp?.let { width ->
    properties.color("borderColor")?.let { color -> BorderStroke(width, color) }
  }
  val outlinedBorder = border ?: if (properties.boolean("foregroundBorder")) {
    BorderStroke(0.dp, Color.Transparent)
  } else CardDefaults.outlinedCardBorder()
  if (properties.boolean("interactive")) {
    val interactionSource = remember { MutableInteractionSource() }
    LaunchedEffect(cardPressEvents, interactionSource) {
      var activeId: Long? = null
      var activePress: PressInteraction.Press? = null
      for (event in cardPressEvents) {
        val position = event.position
        if (position != null) {
          activePress?.let { interactionSource.emit(PressInteraction.Cancel(it)) }
          val press = PressInteraction.Press(Offset(position.x * density, position.y * density))
          activeId = event.id
          activePress = press
          interactionSource.emit(press)
        } else if (event.id == activeId) {
          activePress?.let { press ->
            interactionSource.emit(
              if (event.cancelled) PressInteraction.Cancel(press) else PressInteraction.Release(press),
            )
          }
          activeId = null
          activePress = null
        }
      }
    }
    LaunchedEffect(cardHoverEvents, interactionSource) {
      var activeHover: HoverInteraction.Enter? = null
      for (hovered in cardHoverEvents) {
        if (hovered && activeHover == null) {
          val enter = HoverInteraction.Enter()
          activeHover = enter
          interactionSource.emit(enter)
        } else if (!hovered) {
          activeHover?.let { interactionSource.emit(HoverInteraction.Exit(it)) }
          activeHover = null
        }
      }
    }
    LaunchedEffect(cardFocusEvents, interactionSource) {
      var activeFocus: FocusInteraction.Focus? = null
      for (focused in cardFocusEvents) {
        if (focused && activeFocus == null) {
          val focus = FocusInteraction.Focus()
          activeFocus = focus
          interactionSource.emit(focus)
        } else if (!focused) {
          activeFocus?.let { interactionSource.emit(FocusInteraction.Unfocus(it)) }
          activeFocus = null
        }
      }
    }
    val modifier = Modifier.fillMaxSize().focusProperties { canFocus = false }.clearAndSetSemantics {}
    when {
      style == "outlined" -> OutlinedCard(
        onClick = {}, modifier = modifier, shape = shape, colors = colors,
        elevation = elevation, border = outlinedBorder, interactionSource = interactionSource,
      ) {}
      style == "elevated" && border == null -> ElevatedCard(
        onClick = {}, modifier = modifier, shape = shape, colors = colors,
        elevation = elevation, interactionSource = interactionSource,
      ) {}
      else -> Card(
        onClick = {}, modifier = modifier, shape = shape, colors = colors,
        elevation = elevation, border = border, interactionSource = interactionSource,
      ) {}
    }
  } else {
    when {
      style == "outlined" -> OutlinedCard(
        modifier = Modifier.fillMaxSize(), shape = shape, colors = colors,
        elevation = elevation, border = outlinedBorder,
      ) {}
      style == "elevated" && border == null -> ElevatedCard(
        modifier = Modifier.fillMaxSize(), shape = shape, colors = colors,
        elevation = elevation,
      ) {}
      else -> Card(
        modifier = Modifier.fillMaxSize(), shape = shape, colors = colors,
        elevation = elevation, border = border,
      ) {}
    }
  }
}

private fun nativeM3EReadableDialogActionColor(color: Color, containerColor: Color): Color {
  val containerLuminance = containerColor.luminance()
  fun contrast(candidate: Color): Float {
    val actionLuminance = candidate.luminance()
    val lighter = maxOf(actionLuminance, containerLuminance)
    val darker = minOf(actionLuminance, containerLuminance)
    return (lighter + 0.05f) / (darker + 0.05f)
  }
  if (contrast(color) >= 4.5f) return color

  val target = if (containerLuminance > 0.179f) Color.Black else Color.White
  var low = 0f
  var high = 1f
  repeat(12) {
    val middle = (low + high) / 2f
    if (contrast(androidx.compose.ui.graphics.lerp(color, target, middle)) >= 4.5f) {
      high = middle
    } else {
      low = middle
    }
  }
  return androidx.compose.ui.graphics.lerp(color, target, high)
}

@Composable
private fun NativeM3EAlertDialog(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val hasInput = properties.containsKey("initialValue")
  val maxLength = properties.number("maxLength")?.toInt()
  val inputState = rememberTextFieldState(initialText = properties["initialValue"] as? String ?: "")
  val inputTransformation = nativeM3EMaxLengthTransformation(maxLength)
  val inputModifier = Modifier.fillMaxWidth().then(maxLength?.takeIf { it >= 0 }?.let { limit ->
    Modifier.semantics { maxTextLength = limit }
  } ?: Modifier)
  val inputSupportingContent: (@Composable () -> Unit)? =
    if (maxLength != null) {
      { NativeM3ETextFieldSupporting(inputState, null, maxLength) }
    } else null
  val requestedKeyboardType = properties["keyboardType"] as? String
  val keyboardType = nativeM3EKeyboardType(requestedKeyboardType)
  val obscureText = properties.boolean("obscureText")
  val inputKeyboardOptions = if (obscureText) {
    KeyboardOptions(
      autoCorrectEnabled = false,
      keyboardType = nativeM3ESecureKeyboardType(keyboardType),
    )
  } else if (requestedKeyboardType != null) {
    KeyboardOptions(keyboardType = keyboardType)
  } else {
    KeyboardOptions.Default
  }
  val iconName = properties["icon"] as? String
  val iconColor = properties.color("iconColor")
  val iconSize = properties.number("iconSize")?.dp ?: AlertDialogDefaults.IconSize
  val title = (properties["title"] as? String)?.takeIf { it.isNotBlank() }
  val message = (properties["message"] as? String)?.takeIf { it.isNotBlank() }
  val oneTimeCode = (properties["oneTimeCode"] as? String)?.takeIf { it.isNotBlank() }
  val hasTextContent = message != null || oneTimeCode != null || hasInput
  AlertDialog(
    onDismissRequest = { onEvent("dismissed", null) },
    icon = iconName?.let { name ->
      ({ Icon(nativeM3EIcon(name), contentDescription = null, tint = iconColor ?: LocalContentColor.current, modifier = Modifier.size(iconSize)) })
    },
    title = title?.let { value -> ({ Text(value) }) },
    text = if (hasTextContent) ({
      Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        message?.let { Text(it) }
        oneTimeCode?.let {
          Text(it, style = MaterialTheme.typography.headlineSmall, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
        }
        if (hasInput) {
          if (obscureText) {
            OutlinedSecureTextField(
              state = inputState,
              modifier = inputModifier,
              keyboardOptions = inputKeyboardOptions,
              placeholder = { Text(properties["placeholder"] as? String ?: "") },
              supportingText = inputSupportingContent,
              inputTransformation = inputTransformation,
              shape = OutlinedTextFieldDefaults.roundedShape,
            )
          } else {
            OutlinedTextField(
              state = inputState,
              modifier = inputModifier,
              keyboardOptions = inputKeyboardOptions,
              placeholder = { Text(properties["placeholder"] as? String ?: "") },
              supportingText = inputSupportingContent,
              inputTransformation = inputTransformation,
              lineLimits = TextFieldLineLimits.SingleLine,
              shape = OutlinedTextFieldDefaults.roundedShape,
            )
          }
        }
      }
    }) else null,
    confirmButton = {
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        if (action["style"] == "cancel") return@forEachIndexed
        val actionTitle = (action["title"] as? String)?.takeIf { it.isNotBlank() } ?: return@forEachIndexed
        val style = action["style"] as? String ?: "defaultAction"
        val enabled = (action["enabled"] as? Boolean ?: true) && style != "disabled"
        val actionColor = when (style) {
          "destructive" -> MaterialTheme.colorScheme.error
          "success" -> nativeM3EReadableDialogActionColor(Color(0xFF2E7D32), AlertDialogDefaults.containerColor)
          "warning" -> nativeM3EReadableDialogActionColor(Color(0xFFED6C02), AlertDialogDefaults.containerColor)
          "info" -> MaterialTheme.colorScheme.primary
          else -> null
        }
        TextButton(
          onClick = { onEvent("selected", listOf(index, inputState.text.toString())) },
          enabled = enabled,
          shapes = ButtonDefaults.shapes(),
          colors = actionColor?.let { androidx.compose.material3.ButtonDefaults.textButtonColors(contentColor = it) }
            ?: androidx.compose.material3.ButtonDefaults.textButtonColors(),
        ) { Text(actionTitle) }
      }
    },
    dismissButton = {
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        if (action["style"] != "cancel") return@forEachIndexed
        val actionTitle = (action["title"] as? String)?.takeIf { it.isNotBlank() } ?: return@forEachIndexed
        TextButton(
          onClick = { onEvent("selected", listOf(index, inputState.text.toString())) },
          enabled = action["enabled"] as? Boolean ?: true,
          shapes = ButtonDefaults.shapes(),
        ) { Text(actionTitle) }
      }
    },
  )
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun NativeM3EActionSheet(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val sheetState = rememberBottomSheetState(
    initialValue = SheetValue.Hidden,
    enabledValues = setOf(SheetValue.Hidden, SheetValue.Expanded),
  )
  val scope = rememberCoroutineScope()
  var selectionPending by remember { mutableStateOf(false) }
  ModalBottomSheet(
    onDismissRequest = {
      if (!selectionPending && !sheetState.isVisible) onEvent("dismissed", null)
    },
    sheetState = sheetState,
  ) {
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .verticalScroll(rememberScrollState())
        .padding(start = 8.dp, end = 8.dp, top = 8.dp, bottom = 24.dp),
    ) {
      val title = properties["title"] as? String
      val message = properties["message"] as? String
      if (title != null || message != null) {
        Column(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp)) {
          title?.let {
            NativeM3EListText(
              it,
              properties["titleTextOptions"] as? Map<*, *>,
              properties.color("titleColor") ?: Color.Unspecified,
              modifier = Modifier.semantics { heading() },
              baseStyle = MaterialTheme.typography.titleMedium,
            )
          }
          if (!message.isNullOrBlank()) {
            NativeM3EListText(
              message,
              properties["messageTextOptions"] as? Map<*, *>,
              properties.color("messageColor") ?: MaterialTheme.colorScheme.onSurfaceVariant,
              baseStyle = MaterialTheme.typography.bodyMedium,
            )
          }
        }
        Spacer(Modifier.height(8.dp))
      }
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val label = action["label"] as? String ?: ""
        if (label.isBlank()) return@forEachIndexed
        val icon = action["icon"] as? String
        val iconColor = (action["iconColor"] as? Number)?.let { Color(it.toLong().toInt()) }
        val iconSize = (action["iconSize"] as? Number)?.toFloat()?.takeIf { it.isFinite() && it >= 0f }?.dp
        val iconSemanticLabel = action["iconSemanticLabel"] as? String
        val cancel = action["cancel"] as? Boolean ?: false
        val destructive = action["destructive"] as? Boolean ?: false
        val defaultAction = action["default"] as? Boolean ?: false
        val labelOptions = (action["labelTextOptions"] as? Map<*, *>)?.toMutableMap()
          ?: mutableMapOf<Any?, Any?>()
        if (defaultAction && !labelOptions.containsKey("fontWeight")) {
          labelOptions["fontWeight"] = FontWeight.SemiBold.weight
        }
        if (cancel && !labelOptions.containsKey("textAlign")) {
          labelOptions["textAlign"] = "center"
        }
        val labelColor = (action["labelColor"] as? Number)?.let { Color(it.toLong().toInt()) }
          ?: Color.Unspecified
        if (cancel) Spacer(Modifier.height(8.dp))
        val actionColor = when {
          destructive -> MaterialTheme.colorScheme.error
          defaultAction -> MaterialTheme.colorScheme.primary
          else -> Color.Unspecified
        }
        ListItem(
          onClick = {
            if (!selectionPending) {
              selectionPending = true
              scope.launch {
                try {
                  sheetState.hide()
                } finally {
                  if (sheetState.isVisible) {
                    selectionPending = false
                  } else {
                    onEvent("selected", index)
                  }
                }
              }
            }
          },
          modifier = Modifier.fillMaxWidth(),
          leadingContent = icon?.let { name -> ({
            Icon(
              nativeM3EIcon(name),
              contentDescription = iconSemanticLabel,
              modifier = iconSize?.let { Modifier.size(it) } ?: Modifier,
              tint = iconColor ?: LocalContentColor.current,
            )
          }) },
          colors = ListItemDefaults.colors(
            contentColor = actionColor,
            leadingContentColor = if (destructive) MaterialTheme.colorScheme.error else Color.Unspecified,
          ),
        ) {
          NativeM3EListText(
            label,
            labelOptions,
            labelColor,
            modifier = if (cancel) Modifier.fillMaxWidth() else Modifier,
          )
        }
      }
    }
  }
}

@Composable
private fun NativeM3EContextMenu(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val x = (properties.number("anchorX") ?: 0.0).dp
  val y = (properties.number("anchorY") ?: 0.0).dp
  var expanded by remember { mutableStateOf(true) }
  var pendingEvent by remember { mutableStateOf<Pair<String, Any?>?>(null) }
  val currentOnEvent by rememberUpdatedState(onEvent)
  fun close(event: String, value: Any?) {
    if (pendingEvent == null) {
      pendingEvent = event to value
      expanded = false
    }
  }
  Box(Modifier.absoluteOffset(x = x, y = y).size(1.dp)) {
    DropdownMenu(expanded = expanded, onDismissRequest = { close("dismissed", null) }) {
      DisposableEffect(Unit) {
        onDispose {
          pendingEvent?.let { (event, value) ->
            pendingEvent = null
            currentOnEvent(event, value)
          }
        }
      }
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val title = action["title"] as? String ?: ""
        if (title.isBlank()) return@forEachIndexed
        val icon = action["icon"] as? String
        val destructive = action["destructive"] as? Boolean ?: false
        DropdownMenuItem(
          text = { Text(title) },
          shape = MenuDefaults.itemShape(index, actions.size).shape,
          leadingIcon = icon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
          colors = if (destructive) MenuDefaults.itemColors(
            textColor = MaterialTheme.colorScheme.error,
            leadingIconColor = MaterialTheme.colorScheme.error,
          ) else MenuDefaults.itemColors(),
          enabled = action["enabled"] as? Boolean ?: true,
          onClick = { close("selected", nativePopupMenuSelectionEvent(index, action)) },
        )
      }
    }
  }
}

@Composable
private fun NativeM3EDatePicker(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val initial = properties.number("initialDateMillis")?.toLong()
  val first = properties.number("firstDateMillis")?.toLong() ?: 0L
  val last = properties.number("lastDateMillis")?.toLong() ?: Long.MAX_VALUE
  val firstYear = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")).apply { timeInMillis = first }.get(java.util.Calendar.YEAR)
  val lastYear = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")).apply { timeInMillis = last }.get(java.util.Calendar.YEAR)
  val selectableDates = remember(first, last) {
    object : SelectableDates {
      override fun isSelectableDate(utcTimeMillis: Long): Boolean = utcTimeMillis in first..last
      override fun isSelectableYear(year: Int): Boolean = year in firstYear..lastYear
    }
  }
  val state = rememberDatePickerState(
    initialSelectedDateMillis = initial,
    yearRange = firstYear..lastYear,
    selectableDates = selectableDates,
  )
  val selectedDate = state.selectedDateMillis?.takeIf { it in first..last }
  DatePickerDialog(
    onDismissRequest = { onEvent("dismissed", null) },
    confirmButton = {
      TextButton(
        onClick = { selectedDate?.let { onEvent("submitted", it) } },
        enabled = selectedDate != null,
        shapes = ButtonDefaults.shapes(),
      ) {
        Text(properties["confirmLabel"] as? String ?: "OK")
      }
    },
    dismissButton = {
      TextButton(onClick = { onEvent("dismissed", null) }, shapes = ButtonDefaults.shapes()) {
        Text(properties["dismissLabel"] as? String ?: "Cancel")
      }
    },
  ) {
    DatePicker(state = state)
  }
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ETimePicker(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val state = rememberTimePickerState(
    initialHour = (properties.number("initialHour") ?: 0.0).toInt(),
    initialMinute = (properties.number("initialMinute") ?: 0.0).toInt(),
    is24Hour = properties.boolean("use24HourFormat"),
  )
  val configuration = LocalConfiguration.current
  val canShowDial = configuration.screenHeightDp.dp > TimePickerDialogDefaults.MinHeightForTimePicker
  var isPickerMode by rememberSaveable { mutableStateOf(true) }
  val displayMode = if (isPickerMode && canShowDial) TimePickerDisplayMode.Picker else TimePickerDisplayMode.Input
  val minuteInterval = (properties.number("minuteInterval")?.toInt() ?: 1).coerceAtLeast(1)
  val keepSelectedDay = properties.boolean("keepSelectedDay")
  val minimumMinuteOfDay = properties.number("minimumMinuteOfDay")?.toInt()
  val maximumMinuteOfDay = properties.number("maximumMinuteOfDay")?.toInt()

  @Composable
  fun confirmButton() {
    val selectedMinute = state.hour * 60 + state.minute
    val roundedMinute =
      (selectedMinute + minuteInterval / 2) / minuteInterval * minuteInterval
    val alignedMinute = if (keepSelectedDay) {
      roundedMinute.coerceAtMost(24 * 60 - minuteInterval)
    } else {
      roundedMinute % (24 * 60)
    }
    TextButton(
      enabled = state.isInputValid &&
        (minimumMinuteOfDay == null || alignedMinute >= minimumMinuteOfDay) &&
        (maximumMinuteOfDay == null || alignedMinute <= maximumMinuteOfDay),
      onClick = { onEvent("submitted", listOf(state.hour, state.minute)) },
      shapes = ButtonDefaults.shapes(),
    ) { Text(properties["confirmLabel"] as? String ?: "OK") }
  }

  @Composable
  fun dismissButton() {
    TextButton(onClick = { onEvent("dismissed", null) }, shapes = ButtonDefaults.shapes()) {
      Text(properties["dismissLabel"] as? String ?: "Cancel")
    }
  }

  @Composable
  fun modeToggleButton() {
    if (canShowDial) {
      TimePickerDialogDefaults.DisplayModeToggle(
        onDisplayModeChange = { isPickerMode = !isPickerMode },
        displayMode = displayMode,
      )
    }
  }

  @Composable
  fun pickerContent() {
    if (displayMode == TimePickerDisplayMode.Picker) {
      TimePicker(state = state, shapes = TimePickerDefaults.shapes())
    } else {
      TimeInput(state = state, shapes = TimeInputDefaults.shapes())
    }
  }

  if (configuration.screenWidthDp >= 600 && canShowDial) {
    VibrantTimePickerDialog(
      onDismissRequest = { onEvent("dismissed", null) },
      confirmButton = { confirmButton() },
      dismissButton = { dismissButton() },
      modeToggleButton = { modeToggleButton() },
    ) { pickerContent() }
  } else {
    TimePickerDialog(
      onDismissRequest = { onEvent("dismissed", null) },
      title = { TimePickerDialogDefaults.Title(displayMode = displayMode) },
      confirmButton = { confirmButton() },
      dismissButton = { dismissButton() },
      modeToggleButton = { modeToggleButton() },
    ) { pickerContent() }
  }
}

@Composable
private fun NativeM3ESwitch(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val semanticModifier = semanticLabel?.let { label ->
    Modifier.semantics { contentDescription = label }
  } ?: Modifier
  val thumbIconName = if (properties.boolean("value")) properties["checkedThumbIcon"] as? String
    else properties["uncheckedThumbIcon"] as? String
  val thumbColor = properties.color("thumbColor") ?: Color.Unspecified
  Switch(
    checked = properties.boolean("value"),
    onCheckedChange = { onEvent("changed", it) },
    enabled = enabled,
    thumbContent = thumbIconName?.let { name ->
      { NativeM3ESwitchThumbIcon(name) }
    },
    modifier = Modifier.size(width = 52.dp, height = 48.dp).then(semanticModifier),
    colors = SwitchDefaults.colors().copy(
      checkedTrackColor = properties.color("activeColor") ?: Color.Unspecified,
      checkedThumbColor = thumbColor,
      uncheckedThumbColor = thumbColor,
    ),
  )
}

@Composable
private fun NativeM3ESwitchThumbIcon(name: String) {
  Icon(
    imageVector = nativeM3EIcon(name),
    contentDescription = null,
    modifier = Modifier.size(SwitchDefaults.IconSize),
  )
}

@Composable
private fun NativeM3ECheckbox(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val semanticModifier = semanticLabel?.let { label ->
    Modifier.semantics { contentDescription = label }
  } ?: Modifier
  val value = properties["value"] as? Boolean
  val colors = CheckboxDefaults.colors(
    checkedColor = properties.color("activeColor") ?: Color.Unspecified,
    checkmarkColor = properties.color("checkColor") ?: Color.Unspecified,
  )
  if (properties.boolean("tristate") || value == null) {
    val state = when (value) {
      true -> ToggleableState.On
      null -> ToggleableState.Indeterminate
      false -> ToggleableState.Off
    }
    TriStateCheckbox(
      state = state,
      onClick = {
        onEvent("changed", when (state) {
          ToggleableState.Off -> true
          ToggleableState.On -> null
          ToggleableState.Indeterminate -> false
        })
      },
      enabled = enabled,
      modifier = Modifier.size(48.dp).then(semanticModifier),
      colors = colors,
    )
  } else {
    Checkbox(
      checked = value,
      onCheckedChange = { onEvent("changed", it) },
      enabled = enabled,
      modifier = Modifier.size(48.dp).then(semanticModifier),
      colors = colors,
    )
  }
}

@Composable
private fun NativeM3ERadio(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val semanticLabel = (properties["semanticLabel"] as? String)?.takeIf { it.isNotBlank() }
  val semanticModifier = semanticLabel?.let { label ->
    Modifier.semantics { contentDescription = label }
  } ?: Modifier
  val selected = properties.boolean("selected")
  val toggleable = properties.boolean("toggleable")
  RadioButton(
    selected = selected,
    onClick = {
      if (!selected || toggleable) {
        onEvent("changed", !selected)
      }
    },
    enabled = enabled,
    modifier = Modifier.size(48.dp).then(semanticModifier),
    colors = RadioButtonDefaults.colors(
      selectedColor = properties.color("activeColor") ?: Color.Unspecified,
    ),
  )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ESlider(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val min = properties.number("min") ?: 0.0
  val max = properties.number("max") ?: 1.0
  val divisions = properties.number("divisions")?.toInt()?.let { (it - 1).coerceAtLeast(0) } ?: 0
  val value = (properties.number("value") ?: min).coerceIn(min, max)
  val vertical = properties["orientation"] == "vertical"
  val centeredTrack = properties.boolean("centeredTrack")
  key(min, max, divisions) {
    val sliderState = rememberSliderState(
      value = value.toFloat(),
      steps = divisions,
      trackRange = min.toFloat()..max.toFloat(),
    )
    val interactionSource = remember { MutableInteractionSource() }
    val isDragged by interactionSource.collectIsDraggedAsState()
    var changeInProgress by remember { mutableStateOf(false) }
    val label = properties["label"] as? String
    LaunchedEffect(value, isDragged) {
      if (!isDragged && sliderState.value != value.toFloat()) {
        sliderState.value = value.toFloat()
      }
    }
    LaunchedEffect(enabled) {
      if (!enabled) changeInProgress = false
    }
    val sliderColors = SliderDefaults.colors(
      thumbColor = properties.color("thumbColor") ?: Color.Unspecified,
      activeTrackColor = properties.color("activeColor") ?: Color.Unspecified,
    )
    val onValueChange: (Float) -> Unit = { next ->
      if (!changeInProgress) {
        changeInProgress = true
        if (properties.boolean("hasStartCallback")) {
          onEvent("started", sliderState.value.toDouble())
        }
      }
      sliderState.value = next
      onEvent("changed", sliderState.value.toDouble())
    }
    val onValueChangeFinished: () -> Unit = {
      if (!changeInProgress && properties.boolean("hasStartCallback")) {
        onEvent("started", sliderState.value.toDouble())
      }
      changeInProgress = false
      if (properties.boolean("hasEndCallback")) {
        onEvent("finished", sliderState.value.toDouble())
      }
    }
    val thumb: @Composable (SliderState) -> Unit = { _ ->
      if (label.isNullOrBlank()) {
        SliderDefaults.Thumb(
          interactionSource = interactionSource,
          isVertical = vertical,
          colors = sliderColors,
          enabled = enabled,
        )
      } else {
        Label(
          label = { PlainTooltip { Text(label) } },
          interactionSource = interactionSource,
        ) {
          SliderDefaults.Thumb(
            interactionSource = interactionSource,
            isVertical = vertical,
            colors = sliderColors,
            enabled = enabled,
          )
        }
      }
    }
    val track: @Composable (SliderState) -> Unit = { state ->
      if (centeredTrack) {
        SliderDefaults.CenteredTrack(
          sliderState = state,
          colors = sliderColors,
          enabled = enabled,
        )
      } else if (vertical) {
        SliderDefaults.Track(
          sliderState = state,
          trackCornerSize = Dp.Unspecified,
          colors = sliderColors,
          enabled = enabled,
        )
      } else {
        SliderDefaults.Track(
          sliderState = state,
          colors = sliderColors,
          enabled = enabled,
        )
      }
    }
    if (vertical) {
      VerticalSlider(
        state = sliderState,
        onValueChange = onValueChange,
        enabled = enabled,
        modifier = Modifier.fillMaxHeight(),
        topToBottom = properties.boolean("topToBottom", true),
        interactionSource = interactionSource,
        onValueChangeFinished = onValueChangeFinished,
        colors = sliderColors,
        thumb = thumb,
        track = track,
      )
    } else {
      Slider(
        state = sliderState,
        onValueChange = onValueChange,
        enabled = enabled,
        modifier = Modifier.fillMaxWidth(),
        interactionSource = interactionSource,
        onValueChangeFinished = onValueChangeFinished,
        colors = sliderColors,
        thumb = thumb,
        track = track,
      )
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3ERangeSlider(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val min = properties.number("min") ?: 0.0
  val max = properties.number("max") ?: 1.0
  val nativeMin = min.toFloat()
  val nativeMax = max.toFloat()
  val start = (properties.number("start") ?: min).toFloat().coerceIn(nativeMin, nativeMax)
  val end = (properties.number("end") ?: max).toFloat().coerceIn(start, nativeMax)
  val steps = properties.number("divisions")?.toInt()?.let { (it - 1).coerceAtLeast(0) } ?: 0
  key(min, max, steps) {
    val rangeState = rememberRangeSliderState(
      startValue = start,
      endValue = end,
      steps = steps,
      trackRange = nativeMin..nativeMax,
    )
    val startSource = remember { MutableInteractionSource() }
    val endSource = remember { MutableInteractionSource() }
    val startDragged by startSource.collectIsDraggedAsState()
    val endDragged by endSource.collectIsDraggedAsState()
    var changeInProgress by remember { mutableStateOf(false) }

    fun applyRange(nextStart: Float, nextEnd: Float) {
      if (nextEnd > rangeState.endValue) {
        rangeState.endValue = nextEnd
        rangeState.startValue = nextStart
      } else {
        rangeState.startValue = nextStart
        rangeState.endValue = nextEnd
      }
    }

    fun currentRange(): Map<String, Double> = mapOf(
      "start" to rangeState.startValue.toDouble(),
      "end" to rangeState.endValue.toDouble(),
    )

    LaunchedEffect(start, end, startDragged, endDragged) {
      if (!startDragged && !endDragged) applyRange(start, end)
    }
    LaunchedEffect(enabled) {
      if (!enabled) changeInProgress = false
    }

    val colors = SliderDefaults.colors(
      activeTrackColor = properties.color("activeColor") ?: Color.Unspecified,
      inactiveTrackColor = properties.color("inactiveColor") ?: Color.Unspecified,
    )
    val startLabel = properties["startLabel"] as? String
    val endLabel = properties["endLabel"] as? String
    RangeSlider(
      state = rangeState,
      onValueChange = { next ->
        if (!changeInProgress) {
          changeInProgress = true
          if (properties.boolean("hasStartCallback")) onEvent("started", currentRange())
        }
        applyRange(next.start, next.endInclusive)
        onEvent("changed", currentRange())
      },
      modifier = Modifier.fillMaxWidth(),
      enabled = enabled,
      onValueChangeFinished = {
        if (!changeInProgress && properties.boolean("hasStartCallback")) {
          onEvent("started", currentRange())
        }
        changeInProgress = false
        if (properties.boolean("hasEndCallback")) onEvent("finished", currentRange())
      },
      colors = colors,
      startThumbInteractionSource = startSource,
      endThumbInteractionSource = endSource,
      startThumb = {
        if (startLabel.isNullOrBlank()) {
          SliderDefaults.Thumb(interactionSource = startSource, colors = colors, enabled = enabled)
        } else {
          Label(label = { PlainTooltip { Text(startLabel) } }, interactionSource = startSource) {
            SliderDefaults.Thumb(interactionSource = startSource, colors = colors, enabled = enabled)
          }
        }
      },
      endThumb = {
        if (endLabel.isNullOrBlank()) {
          SliderDefaults.Thumb(interactionSource = endSource, colors = colors, enabled = enabled)
        } else {
          Label(label = { PlainTooltip { Text(endLabel) } }, interactionSource = endSource) {
            SliderDefaults.Thumb(interactionSource = endSource, colors = colors, enabled = enabled)
          }
        }
      },
    )
  }
}

private fun Map<String, Any?>.boolean(key: String, default: Boolean = false): Boolean =
  this[key] as? Boolean ?: default

private fun nativeM3EKeyboardType(name: String?): KeyboardType = when (name) {
  "number" -> KeyboardType.Number
  "numberSigned" -> KeyboardType.NumberSigned
  "decimal" -> KeyboardType.Decimal
  "decimalSigned" -> KeyboardType.DecimalSigned
  "phone" -> KeyboardType.Phone
  "dateTime" -> KeyboardType.DateTime
  "email" -> KeyboardType.Email
  "url" -> KeyboardType.Uri
  "password" -> KeyboardType.Password
  "passwordVisible" -> KeyboardType.PasswordVisible
  "personName" -> KeyboardType.PersonName
  "postalAddress" -> KeyboardType.PostalAddress
  else -> KeyboardType.Text
}

private fun nativeM3ESecureKeyboardType(type: KeyboardType): KeyboardType = when (type) {
  KeyboardType.Number -> KeyboardType.NumberPassword
  KeyboardType.NumberSigned -> KeyboardType.NumberPasswordSigned
  KeyboardType.Decimal -> KeyboardType.DecimalPassword
  KeyboardType.DecimalSigned -> KeyboardType.DecimalPasswordSigned
  KeyboardType.Phone -> KeyboardType.Phone
  else -> KeyboardType.Password
}

private fun Map<String, Any?>.number(key: String): Double? =
  (this[key] as? Number)?.toDouble()

private fun Map<String, Any?>.color(key: String): Color? {
  val argb = (this[key] as? Number)?.toLong()?.toInt() ?: return null
  return Color(argb)
}
