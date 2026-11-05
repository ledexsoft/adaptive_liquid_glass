package com.ledexsoft.adaptive_liquid_glass

import android.os.Build
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DatePickerState
import androidx.compose.material3.SelectableDates
import androidx.compose.material3.TimePicker
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialExpressiveTheme
import androidx.compose.material3.MotionScheme
import androidx.compose.material3.LoadingIndicator
import androidx.compose.material3.ContainedLoadingIndicator
import androidx.compose.material3.HorizontalDivider
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
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.BottomSheetDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.rememberDrawerState
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.WideNavigationRail
import androidx.compose.material3.WideNavigationRailItem
import androidx.compose.material3.WideNavigationRailDefaults
import androidx.compose.material3.WideNavigationRailValue
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SplitButtonLayout
import androidx.compose.material3.SplitButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.SearchBar
import androidx.compose.material3.SearchBarDefaults
import androidx.compose.material3.BottomAppBarDefaults
import androidx.compose.material3.FlexibleBottomAppBar
import androidx.compose.material3.AppBarRow
import androidx.compose.material3.AppBarColumn
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
import androidx.compose.material3.OutlinedToggleButton
import androidx.compose.material3.ElevatedToggleButton
import androidx.compose.material3.ToggleButtonSize
import androidx.compose.material3.ToggleButtonDefaults
import androidx.compose.material3.rememberWideNavigationRailState
import androidx.compose.material3.Icon
import androidx.compose.material3.LargeFloatingActionButton
import androidx.compose.material3.SmallFloatingActionButton
import androidx.compose.material3.ToggleFloatingActionButton
import androidx.compose.material3.ToggleFloatingActionButtonDefaults
import androidx.compose.material3.CircularWavyProgressIndicator
import androidx.compose.material3.LinearWavyProgressIndicator
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.PlainTooltip
import androidx.compose.material3.TooltipAnchorPosition
import androidx.compose.material3.TooltipBox
import androidx.compose.material3.TooltipDefaults
import androidx.compose.material3.rememberTooltipState
import androidx.compose.material3.TriStateCheckbox
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.expressiveLightColorScheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Snackbar
import androidx.compose.material3.SnackbarDefaults
import androidx.compose.material3.TextButton
import androidx.compose.material3.carousel.HorizontalCenteredHeroCarousel
import androidx.compose.material3.carousel.HorizontalMultiBrowseCarousel
import androidx.compose.material3.carousel.HorizontalUncontainedCarousel
import androidx.compose.material3.carousel.CarouselItemScope
import androidx.compose.material3.carousel.rememberCarouselState
import androidx.compose.material3.carousel.CarouselDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.snapshotFlow
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.autofill.ContentType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.contentType
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.font.FontWeight
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.window.DialogWindowProvider
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsDraggedAsState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.Brush
import androidx.compose.foundation.Image
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.shape.CircleShape
import android.graphics.BitmapFactory
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
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
import androidx.compose.material.icons.filled.Message
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

@Composable
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
internal fun M3EAndroidTheme(
  properties: Map<String, Any?>,
  content: @Composable () -> Unit,
) {
  val dark = properties.boolean("isDark")
  val primary = properties.color("primaryColor") ?: Color(0xFF6750A4)
  val dynamic = properties.boolean("dynamicColoring") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
  val context = LocalContext.current
  val foreground = if (primary.luminance() > 0.5f) Color.Black else Color.White
  val colors = if (dynamic && dark) {
    dynamicDarkColorScheme(context)
  } else if (dynamic) {
    dynamicLightColorScheme(context)
  } else if (dark) {
    darkColorScheme(primary = primary, onPrimary = foreground)
  } else {
    expressiveLightColorScheme().copy(primary = primary, onPrimary = foreground)
  }
  MaterialExpressiveTheme(
    colorScheme = colors,
    motionScheme = MotionScheme.expressive(),
    content = content,
  )
}

@Composable
internal fun M3EAndroidContent(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val enabled = properties.boolean("enabled", true)
  val hasCallback = properties.boolean("hasCallback", true)

  Box(
    modifier = Modifier.fillMaxSize(),
    contentAlignment = Alignment.Center,
  ) {
    when (properties["component"] as? String) {
      "aiSparkleIcon" -> NativeM3EAiSparkleIcon(
        icon = properties["icon"] as? String,
        size = (properties.number("size") ?: 24.0).dp,
        tint = properties.color("color"),
        sparkleTint = properties.color("sparkleColor") ?: MaterialTheme.colorScheme.primary,
        semanticLabel = properties["semanticLabel"] as? String,
      )
      "expressiveShape" -> NativeM3EExpressiveShape(properties)
      "button" -> NativeM3EButton(properties, enabled && hasCallback, onEvent)
      "switch" -> NativeM3ESwitch(properties, enabled && hasCallback, onEvent)
      "checkbox" -> NativeM3ECheckbox(properties, enabled && hasCallback, onEvent)
      "radio" -> NativeM3ERadio(properties, enabled && hasCallback, onEvent)
      "slider" -> NativeM3ESlider(properties, enabled && hasCallback, onEvent)
      "loadingIndicator" -> NativeM3ELoadingIndicator(properties)
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
      "badge" -> NativeM3EBadge(properties)
      "splitButton" -> NativeM3ESplitButton(properties, enabled, onEvent)
      "toolbar" -> NativeM3EToolbar(properties, onEvent)
      "buttonGroup" -> NativeM3EButtonGroup(properties, onEvent)
      "bottomNavigationBar" -> NativeM3EBottomNavigationBar(properties, onEvent)
      "topAppBar" -> NativeM3ETopAppBar(properties, onEvent)
      "popupMenuButton" -> NativeM3EPopupMenuButton(properties, enabled && hasCallback, onEvent)
      "anchoredPopupMenu" -> NativeM3EAnchoredPopupMenu(properties, onEvent)
      "searchBar" -> NativeM3ESearchBar(properties, enabled, onEvent)
      "switchListTile" -> NativeM3ESwitchListTile(properties, enabled, onEvent)
      "listTile" -> NativeM3EListTile(properties, enabled, onEvent)
      "cardSurface" -> NativeM3ECardSurface(properties)
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

@Composable
private fun NativeM3EExpansionTile(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val expanded = properties.boolean("expanded")
  val enabled = properties.boolean("enabled", true)
  val title = properties["title"] as? String ?: ""
  val subtitle = properties["subtitle"] as? String
  val leading = properties["leadingIcon"] as? String
  val trailing = properties["trailingIcon"] as? String
  val background = properties.color("backgroundColor")
  val titleColor = properties.color("textColor") ?: MaterialTheme.colorScheme.onSurface
  val subtitleColor = properties.color("subtitleColor") ?: MaterialTheme.colorScheme.onSurfaceVariant
  val iconColor = properties.color("iconColor") ?: MaterialTheme.colorScheme.onSurfaceVariant
  Surface(
    color = background ?: Color.Transparent,
    modifier = Modifier.fillMaxSize().then(if (enabled) Modifier.clickable { onEvent("tapped", null) } else Modifier),
  ) {
    ListItem(
      headlineContent = { Text(title, color = titleColor) },
      supportingContent = subtitle?.let { text -> ({ Text(text, color = subtitleColor) }) },
      leadingContent = leading?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null, tint = iconColor) }) },
      trailingContent = if (trailing != null) {
        ({ Icon(nativeM3EIcon(trailing), contentDescription = null, tint = iconColor) })
      } else {
        ({ Icon(if (expanded) Icons.Filled.ExpandMore else Icons.Filled.ExpandMore, contentDescription = null, tint = iconColor) })
      },
      colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )
  }
}

@Composable
private fun NativeM3ESnackbar(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val message = properties["message"] as? String ?: ""
  val action = properties["action"] as? String
  val duration = (properties.number("durationMs") ?: 4000.0).toLong().coerceAtLeast(0)
  val background = properties.color("backgroundColor") ?: SnackbarDefaults.color
  val content = properties.color("contentColor") ?: SnackbarDefaults.contentColor
  LaunchedEffect(Unit) {
    kotlinx.coroutines.delay(duration)
    onEvent("dismissed", null)
  }
  Dialog(
    onDismissRequest = { onEvent("dismissed", null) },
    properties = DialogProperties(usePlatformDefaultWidth = false),
  ) {
    Box(Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 24.dp), contentAlignment = Alignment.BottomCenter) {
      Snackbar(
        action = {
          action?.let { label ->
            TextButton(onClick = { onEvent("actionPressed", null) }) { Text(label) }
          }
        },
        containerColor = background,
        contentColor = content,
        actionContentColor = content,
      ) { Text(message) }
    }
  }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun NativeM3ETooltip(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val message = properties["message"] as? String ?: ""
  val preferBelow = properties.boolean("preferBelow", true)
  val anchorLeft = properties.number("left") ?: 0.0
  val anchorTop = properties.number("top") ?: 0.0
  val anchorWidth = properties.number("width") ?: 0.0
  val anchorHeight = properties.number("height") ?: 0.0
  val showDuration = (properties.number("showDurationMs") ?: 2000.0).toLong().coerceAtLeast(0)
  val padding = properties["padding"] as? List<*>
  val margin = properties["margin"] as? List<*>
  val background = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.inverseSurface
  val foreground = properties.color("textColor") ?: MaterialTheme.colorScheme.inverseOnSurface
  val fontSize = (properties.number("fontSize") ?: 14.0).sp
  val tooltipHeight = properties.number("tooltipHeight")?.dp
  val tooltipState = rememberTooltipState(isPersistent = true)
  LaunchedEffect(Unit) {
    val showJob = launch { tooltipState.show() }
    kotlinx.coroutines.delay(showDuration)
    tooltipState.dismiss()
    showJob.join()
    onEvent("dismissed", null)
  }
  Dialog(
    onDismissRequest = { onEvent("dismissed", null) },
    properties = DialogProperties(usePlatformDefaultWidth = false),
  ) {
    Box(Modifier.fillMaxSize()) {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(
          if (preferBelow) TooltipAnchorPosition.Below else TooltipAnchorPosition.Above,
        ),
        tooltip = {
          PlainTooltip(
            modifier = Modifier.padding(
              start = ((margin?.getOrNull(0) as? Number)?.toDouble() ?: 0.0).dp,
              top = ((margin?.getOrNull(1) as? Number)?.toDouble() ?: 0.0).dp,
              end = ((margin?.getOrNull(2) as? Number)?.toDouble() ?: 0.0).dp,
              bottom = ((margin?.getOrNull(3) as? Number)?.toDouble() ?: 0.0).dp,
            ),
            containerColor = background,
            contentColor = foreground,
          ) {
            Text(
              message,
              fontSize = fontSize,
              modifier = Modifier
                .then(if (tooltipHeight == null) Modifier else Modifier.height(tooltipHeight))
                .padding(
                  start = ((padding?.getOrNull(0) as? Number)?.toDouble() ?: 12.0).dp,
                  top = ((padding?.getOrNull(1) as? Number)?.toDouble() ?: 8.0).dp,
                  end = ((padding?.getOrNull(2) as? Number)?.toDouble() ?: 12.0).dp,
                  bottom = ((padding?.getOrNull(3) as? Number)?.toDouble() ?: 8.0).dp,
                ),
            )
          }
        },
        state = tooltipState,
        enableUserInput = false,
      ) {
        Box(
          Modifier
            .offset(x = anchorLeft.dp, y = anchorTop.dp)
            .size(width = anchorWidth.coerceAtLeast(1.0).dp, height = anchorHeight.coerceAtLeast(1.0).dp),
        )
      }
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ETopAppBar(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val title = properties["title"] as? String ?: ""
  val subtitle = properties["subtitle"] as? String
  val leadingIcon = properties["leadingIcon"] as? String
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val variant = properties["variant"] as? String ?: "small"
  val centerAligned = properties.boolean("centerAligned")
  val transparentWhenScrolled = properties.boolean("transparentWhenScrolled")
  val scrollOffset = (properties.number("scrollOffset") ?: 0.0).toFloat().coerceAtLeast(0f)
  val scrollDelta = (properties.number("scrollDelta") ?: 0.0).toFloat()
  val scrollKind = properties["scrollBehavior"] as? String ?: "pinned"
  val contentColor = properties.color("contentColor") ?: Color.Unspecified
  val surfaceColor = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.surface
  val density = LocalDensity.current
  val isFlexible = variant == "mediumFlexible" || variant == "largeFlexible"
  val collapsedHeight = TopAppBarDefaults.TopAppBarExpandedHeight
  val expandedHeight = when {
    variant == "largeFlexible" && !subtitle.isNullOrBlank() -> 152.dp
    variant == "largeFlexible" -> 120.dp
    variant == "mediumFlexible" && !subtitle.isNullOrBlank() -> 136.dp
    variant == "mediumFlexible" -> 112.dp
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
  val scrollDeltaPx = with(density) { scrollDelta.dp.toPx() }
  LaunchedEffect(scrollOffsetPx, scrollDeltaPx, scrollKind, isFlexible) {
    appBarState.contentOffset = -scrollOffsetPx
    appBarState.heightOffset = when (scrollKind) {
      "enterAlways" -> (appBarState.heightOffset - scrollDeltaPx).coerceIn(heightOffsetLimit, 0f)
      "exitUntilCollapsed" -> if (isFlexible) (-scrollOffsetPx).coerceIn(heightOffsetLimit, 0f) else 0f
      else -> 0f
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
  val leadingFocusRequester = remember { FocusRequester() }
  val firstActionFocusRequester = remember { FocusRequester() }
  val firstActionIndex = actions.indexOfFirst { raw ->
    val item = raw as? Map<*, *>
    item?.get("icon") is String || item?.get("title") is String
  }
  LaunchedEffect(leadingIcon, firstActionIndex, actions.size, variant) {
    if (leadingIcon != null) leadingFocusRequester.requestFocus()
    else if (firstActionIndex >= 0 && variant != "search") firstActionFocusRequester.requestFocus()
  }

  val logoBytes = properties["logoBytes"] as? ByteArray
  val logo = remember(logoBytes) {
    logoBytes?.let { bytes -> BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.asImageBitmap() }
  }
  val logoDescription = properties["logoContentDescription"] as? String
  val logoReplacesSmallTitle = properties.boolean("logoReplacesSmallTitle", true)

  @Composable
  fun titleContent(maxLines: Int, includeSubtitle: Boolean = true) {
    Column(
      horizontalAlignment = if (centerAligned) Alignment.CenterHorizontally else Alignment.Start,
    ) {
      if (logo != null && variant != "search") {
        val logoSemantics = logoDescription ?: if (variant == "small" && logoReplacesSmallTitle) title else null
        Image(
          bitmap = logo,
          contentDescription = logoSemantics,
          modifier = Modifier.size(if (isFlexible) 36.dp else 32.dp),
          contentScale = ContentScale.Fit,
        )
      }
      if (title.isNotEmpty() && !(variant == "small" && logo != null && logoReplacesSmallTitle)) {
        Text(
          text = title,
          maxLines = maxLines,
          overflow = TextOverflow.Clip,
          modifier = Modifier.semantics { heading() },
        )
      }
      if (includeSubtitle && !subtitle.isNullOrBlank()) {
        Text(
          text = subtitle,
          maxLines = if (isFlexible) 2 else 1,
          overflow = TextOverflow.Clip,
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
      tooltip = { PlainTooltip { Text(description) } },
      state = rememberTooltipState(),
    ) {
      val leadingSize = IconButtonDefaults.smallContainerSize(
        if (transparentWhenScrolled) IconButtonDefaults.IconButtonWidthOption.Narrow
        else IconButtonDefaults.IconButtonWidthOption.Uniform,
      )
      val leadingButtonContent: @Composable () -> Unit = {
        if (logo != null && variant == "search") {
          Image(logo, contentDescription = logoDescription, modifier = Modifier.size(24.dp))
        } else {
          Icon(nativeM3EIcon(leadingIcon), contentDescription = description)
        }
      }
      if (transparentWhenScrolled) {
        FilledTonalIconButton(
          onClick = { onEvent("leadingPressed", null) },
          enabled = properties.boolean("leadingEnabled", true),
          shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape),
          modifier = Modifier.focusRequester(leadingFocusRequester).size(leadingSize),
        ) { leadingButtonContent() }
      } else {
        IconButton(
          onClick = { onEvent("leadingPressed", null) },
          enabled = properties.boolean("leadingEnabled", true),
          shapes = IconButtonDefaults.shapes(),
          modifier = Modifier.focusRequester(leadingFocusRequester).size(leadingSize),
        ) { leadingButtonContent() }
      }
    }
  }

  val menuExpanded = remember { mutableStateOf(false) }
  @Composable
  fun actionButton(index: Int, action: Map<*, *>, requestFocus: Boolean) {
    val icon = action["icon"] as? String
    val titleLabel = action["title"] as? String
    val label = action["semanticLabel"] as? String ?: titleLabel ?: "Action ${index + 1}"
    val style = action["style"] as? String ?: "standard"
    val wide = action["wide"] as? Boolean ?: false
    val enabled = action["enabled"] as? Boolean ?: true
    val focusModifier = if (requestFocus) Modifier.focusRequester(firstActionFocusRequester) else Modifier
    val widthOption = if (wide) IconButtonDefaults.IconButtonWidthOption.Wide else IconButtonDefaults.IconButtonWidthOption.Uniform
    val buttonSize = IconButtonDefaults.smallContainerSize(widthOption)
    val buttonModifier = focusModifier.size(buttonSize)
    if (icon == null) {
      TextButton(
        onClick = { onEvent("actionPressed", index) },
        enabled = enabled,
        modifier = focusModifier,
      ) { Text(titleLabel ?: label, maxLines = 1) }
      return
    }
    TooltipBox(
      positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Below),
      tooltip = { PlainTooltip { Text(label) } },
      state = rememberTooltipState(),
    ) {
      val onClick = { onEvent("actionPressed", index) }
      when (style) {
        "filled" -> FilledIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
          Icon(nativeM3EIcon(icon), contentDescription = label)
        }
        "filledTonal" -> FilledTonalIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
          Icon(nativeM3EIcon(icon), contentDescription = label)
        }
        else -> if (transparentWhenScrolled) {
          FilledTonalIconButton(onClick, shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape), enabled = enabled, modifier = buttonModifier) {
            Icon(nativeM3EIcon(icon), contentDescription = label)
          }
        } else {
          IconButton(onClick, shapes = IconButtonDefaults.shapes(), enabled = enabled, modifier = buttonModifier) {
            Icon(nativeM3EIcon(icon), contentDescription = label)
          }
        }
      }
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
      actionButton(index, action, requestFocus = index == firstActionIndex && leadingIcon == null)
    }
    if (visibleActions.size > maxVisible) {
      Box {
        val moreButtonSize = IconButtonDefaults.smallContainerSize(
          if (transparentWhenScrolled) IconButtonDefaults.IconButtonWidthOption.Wide
          else IconButtonDefaults.IconButtonWidthOption.Uniform,
        )
        val moreButtonContent: @Composable () -> Unit = {
          Icon(Icons.Filled.MoreVert, contentDescription = "More actions")
        }
        if (transparentWhenScrolled) {
          FilledTonalIconButton(
            onClick = { menuExpanded.value = true },
            shapes = IconButtonDefaults.shapes(shape = IconButtonDefaults.filledShape),
            modifier = Modifier.size(moreButtonSize),
          ) { moreButtonContent() }
        } else {
          IconButton(
            onClick = { menuExpanded.value = true },
            shapes = IconButtonDefaults.shapes(),
            modifier = Modifier.size(moreButtonSize),
          ) { moreButtonContent() }
        }
        DropdownMenu(expanded = menuExpanded.value, onDismissRequest = { menuExpanded.value = false }) {
          visibleActions.drop(maxVisible).forEach { (index, action) ->
            val label = action["semanticLabel"] as? String ?: action["title"] as? String ?: "Action ${index + 1}"
            DropdownMenuItem(
              text = { Text(action["title"] as? String ?: label) },
              leadingIcon = (action["icon"] as? String)?.let { icon -> ({ Icon(nativeM3EIcon(icon), contentDescription = null) }) },
              onClick = { menuExpanded.value = false; onEvent("actionPressed", index) },
            )
          }
        }
      }
    }
  }

  if (variant == "search") {
    val searchState = rememberContainedSearchBarState()
    val textFieldState = rememberTextFieldState()
    val scope = rememberCoroutineScope()
    val searchScrollState = rememberSearchBarScrollState(
      initialScrollOffsetLimit = with(density) { -64.dp.toPx() },
    )
    val searchScrollBehavior = SearchBarDefaults.enterAlwaysSearchBarScrollBehavior(searchScrollState)
    val searchColors = SearchBarDefaults.appBarWithSearchColors(
      appBarContainerColor = surfaceColor,
      scrolledAppBarContainerColor = if (transparentWhenScrolled) Color.Transparent else MaterialTheme.colorScheme.surfaceContainer,
      appBarNavigationIconColor = contentColor,
      appBarActionIconColor = contentColor,
    )
    val searchOffsetPx = with(density) { scrollOffset.dp.toPx() }
    val searchDeltaPx = with(density) { scrollDelta.dp.toPx() }
    LaunchedEffect(scrollOffset, scrollDelta, scrollKind) {
      searchScrollState.contentOffset = -searchOffsetPx
      searchScrollState.scrollOffset = when (scrollKind) {
        "enterAlways" -> (searchScrollState.scrollOffset - searchDeltaPx)
          .coerceIn(searchScrollState.scrollOffsetLimit, 0f)
        else -> 0f
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
        onSearch = { query -> onEvent("searchSubmitted", query); scope.launch { searchState.animateToCollapsed() } },
        placeholder = { Text(properties["searchHint"] as? String ?: "Search", modifier = Modifier.semantics { contentDescription = properties["searchHint"] as? String ?: "Search" }) },
        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
        trailingIcon = if (insideSearchIndex >= 0) {
          val action = actions[insideSearchIndex] as? Map<*, *>
          val icon = action?.get("icon") as? String
          val label = action?.get("semanticLabel") as? String ?: action?.get("title") as? String ?: "Search action"
          if (action != null && icon != null) ({
            IconButton(onClick = { onEvent("actionPressed", insideSearchIndex) }, shapes = IconButtonDefaults.shapes()) {
              Icon(nativeM3EIcon(icon), contentDescription = label)
            }
          }) else null
        } else null,
      )
    }
    LaunchedEffect(textFieldState) {
      snapshotFlow { textFieldState.text.toString() }.distinctUntilChanged().collect { query ->
        onEvent("searchQueryChanged", query)
      }
    }
    Column(Modifier.fillMaxWidth()) {
      AppBarWithSearch(
        state = searchState,
        inputField = inputField,
        navigationIcon = { leadingContent() },
        actions = { actionContent(search = true) },
        colors = searchColors,
        scrollBehavior = searchScrollBehavior,
      )
      ExpandedFullScreenContainedSearchBar(
        state = searchState,
        inputField = inputField,
        colors = searchColors.searchBarColors,
      ) {
        val query = textFieldState.text.toString()
        val suggestions = properties["searchSuggestions"] as? List<*> ?: emptyList<Any?>()
        Column(Modifier.fillMaxWidth()) {
          suggestions.mapNotNull { it as? String }
            .filter { query.isBlank() || it.contains(query, ignoreCase = true) }
            .forEach { suggestion ->
              ListItem(
                modifier = Modifier.clickable {
                  textFieldState.setTextAndPlaceCursorAtEnd(suggestion)
                  onEvent("searchResultSelected", suggestion)
                  scope.launch { searchState.animateToCollapsed() }
                },
                leadingContent = { Icon(Icons.Filled.Search, contentDescription = null) },
              ) { Text(suggestion) }
            }
        }
      }
    }
    return
  }

  if (variant == "mediumFlexible") {
    MediumFlexibleTopAppBar(
      title = { titleContent(maxLines = 2, includeSubtitle = false) },
      subtitle = if (subtitle.isNullOrBlank()) null else ({ Text(subtitle, maxLines = 2, overflow = TextOverflow.Clip) }),
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
      subtitle = if (subtitle.isNullOrBlank()) null else ({ Text(subtitle, maxLines = 2, overflow = TextOverflow.Clip) }),
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
      if (centerAligned) {
        CenterAlignedTopAppBar(
          title = { titleContent(maxLines = 1) },
          navigationIcon = { leadingContent() },
          actions = { actionContent() },
          colors = colors,
          scrollBehavior = scrollBehavior,
        )
      } else {
        TopAppBar(
          title = { titleContent(maxLines = 1) },
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
  NavigationBar(
    modifier = Modifier.fillMaxWidth(),
    containerColor = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.surfaceContainer,
    contentColor = properties.color("contentColor") ?: MaterialTheme.colorScheme.onSurface,
    tonalElevation = (properties.number("tonalElevation") ?: 0.0).dp,
  ) {
    destinations.forEachIndexed { index, rawDestination ->
      val destination = rawDestination as? Map<*, *> ?: return@forEachIndexed
      val label = destination["label"] as? String ?: ""
      val selected = index == selectedIndex
      val iconName = if (selected) {
        destination["selectedIcon"] as? String ?: destination["icon"] as? String
      } else destination["icon"] as? String
      val badgeCount = (destination["badgeCount"] as? Number)?.toInt() ?: 0
      NavigationBarItem(
        selected = selected,
        onClick = { if (properties.boolean("interactive", true)) onEvent("destinationSelected", index) },
        colors = if (selectedColor == null) NavigationBarItemDefaults.colors()
          else NavigationBarItemDefaults.colors(indicatorColor = selectedColor),
        icon = {
          val nativeIcon = nativeM3EIcon(iconName)
          if (badgeCount > 0) {
            BadgedBox(badge = { Badge { Text(if (badgeCount > 99) "99+" else badgeCount.toString()) } }) {
              Icon(nativeIcon, contentDescription = label)
            }
          } else {
            Icon(nativeIcon, contentDescription = label)
          }
        },
        label = if (properties.boolean("hideLabels")) null else ({ Text(label) }),
        alwaysShowLabel = properties.boolean("alwaysShowLabels"),
      )
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EButtonGroup(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  if (actions.isEmpty()) return
  val multiSelect = properties.boolean("multiSelect")
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: -1
  val selectedIndices = (properties["selectedIndices"] as? List<*>)
    ?.mapNotNull { (it as? Number)?.toInt() }
    ?.toSet()
    ?: emptySet()
  val size = when (properties["size"] as? String) {
    "small" -> ToggleButtonSize.Small
    "large" -> ToggleButtonSize.Large
    else -> ToggleButtonSize.Medium
  }
  val style = properties["style"] as? String ?: "filled"
  val spacing = (properties.number("spacing") ?: 8.0).dp

  @Composable
  fun renderButton(
    index: Int,
    item: Map<*, *>,
    modifier: Modifier = Modifier,
    interactionSource: MutableInteractionSource? = null,
  ) {
    val checked = if (multiSelect) index in selectedIndices else index == selectedIndex
    val enabled = item["enabled"] as? Boolean ?: true
    val label = if (checked) item["checkedLabel"] as? String ?: item["label"] as? String ?: ""
      else item["label"] as? String ?: ""
    val iconName = if (checked) item["checkedIcon"] as? String ?: item["icon"] as? String
      else item["icon"] as? String
    val semanticLabel = item["semanticLabel"] as? String ?: item["tooltip"] as? String ?: label
    val itemInteractionSource = interactionSource ?: remember(index) { MutableInteractionSource() }
    val click: (Boolean) -> Unit = { next -> onEvent("selectionChanged", listOf(index, next)) }
    val iconSlot: (@Composable () -> Unit)? = iconName?.let {
      { Icon(nativeM3EIcon(it), contentDescription = null) }
    }
    val shapes = ToggleButtonDefaults.shapesFor(size)
    when (style) {
      "tonal" -> FilledTonalToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = modifier.semantics { contentDescription = semanticLabel },
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { Text(label) }
      "outlined" -> OutlinedToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = modifier.semantics { contentDescription = semanticLabel },
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { Text(label) }
      "elevated" -> ElevatedToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = modifier.semantics { contentDescription = semanticLabel },
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { Text(label) }
      else -> ToggleButton(
        checked = checked,
        onCheckedChange = click,
        modifier = modifier.semantics { contentDescription = semanticLabel },
        buttonSize = size,
        enabled = enabled,
        shapes = shapes,
        interactionSource = itemInteractionSource,
        icon = iconSlot,
      ) { Text(label) }
    }
  }

  if (properties["direction"] == "vertical") {
    Column(verticalArrangement = Arrangement.spacedBy(spacing)) {
      actions.forEachIndexed { index, raw ->
        val item = raw as? Map<*, *> ?: return@forEachIndexed
        renderButton(index, item)
      }
    }
  } else {
    ButtonGroup(
      overflowIndicator = { menuState -> ButtonGroupDefaults.OverflowIndicator(menuState = menuState) },
      modifier = Modifier.fillMaxWidth(),
      expandedRatio = if (properties.boolean("neighborSquish", true)) 0.2f else 0f,
      horizontalArrangement = Arrangement.spacedBy(
        if (properties["type"] == "connected") 0.dp else spacing,
      ),
    ) {
      actions.forEachIndexed { index, raw ->
        val item = raw as? Map<*, *> ?: return@forEachIndexed
        val checked = if (multiSelect) index in selectedIndices else index == selectedIndex
        val enabled = item["enabled"] as? Boolean ?: true
        val label = if (checked) item["checkedLabel"] as? String ?: item["label"] as? String ?: ""
          else item["label"] as? String ?: ""
        val semanticLabel = item["semanticLabel"] as? String ?: item["tooltip"] as? String ?: label
        customItem(
          buttonGroupContent = {
            val interactionSource = remember(index) { MutableInteractionSource() }
            renderButton(index, item, Modifier.animateWidth(interactionSource), interactionSource)
          },
          menuContent = { menuState ->
            DropdownMenuItem(
              text = { Text(label) },
              onClick = {
                onEvent("selectionChanged", listOf(index, !checked))
                menuState.dismiss()
              },
              enabled = enabled,
              leadingIcon = (if (checked) item["checkedIcon"] as? String else null)
                ?.let { { Icon(nativeM3EIcon(it), contentDescription = null) } }
                ?: (item["icon"] as? String)?.let { { Icon(nativeM3EIcon(it), contentDescription = null) } },
              trailingIcon = if (checked) ({ Icon(Icons.Filled.Check, contentDescription = "Selected") }) else null,
            )
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
  onEvent: M3EAndroidEvent,
) {
  val title = properties["title"] as? String
  val leading = properties["leadingIcon"] as? String
  val trailing = properties["trailingIcon"] as? String
  val fabIcon = properties["fabIcon"] as? String
  val fabTooltip = properties["fabTooltip"] as? String ?: "Primary action"
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val activeIndex = properties.number("activeIndex")?.toInt() ?: -1
  val supportsSelection = properties["activeIndex"] is Number
  val docked = properties.boolean("docked")
  val vibrant = properties["colorStyle"] == "vibrant"
  val standardColors = FloatingToolbarDefaults.standardFloatingToolbarColors()
  val vibrantColors = FloatingToolbarDefaults.vibrantFloatingToolbarColors()
  val floatingColors = if (vibrant) vibrantColors else standardColors
  val floatingContainer = properties.color("backgroundColor")
    ?: floatingColors.toolbarContainerColor
  val contentColor = properties.color("foregroundColor") ?: if (docked) {
    if (vibrant) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onSurface
  } else floatingColors.toolbarContentColor
  val fabContainer = if (vibrant) vibrantColors.fabContainerColor else standardColors.fabContainerColor
  val fabContent = if (vibrant) vibrantColors.fabContentColor else standardColors.fabContentColor
  val safeBottomInsetPx = with(LocalDensity.current) {
    (properties.number("safeBottomInset") ?: 0.0).dp.roundToPx()
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

  @Composable
  fun actionIcon(index: Int, action: Map<*, *>) {
    val icon = action["icon"] as? String ?: return
    val label = action["tooltip"] as? String ?: action["label"] as? String ?: "Action ${index + 1}"
    TooltipBox(
      positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
      tooltip = { PlainTooltip { Text(label) } },
      state = rememberTooltipState(),
    ) {
      Icon(nativeM3EIcon(icon), contentDescription = label, tint = contentColor)
    }
  }

  @Composable
  fun actionRow(modifier: Modifier = Modifier) {
    AppBarRow(
      modifier = modifier,
      overflowIndicator = { state -> AppBarOverflowIndicator(menuState = state) },
    ) {
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val label = action["tooltip"] as? String ?: action["label"] as? String ?: "Action ${index + 1}"
        val enabled = action["enabled"] as? Boolean ?: true
        if (supportsSelection) {
          toggleableItem(
            checked = index == activeIndex,
            onCheckedChange = { checked ->
              if (checked) onEvent("activeIndexChanged", index)
              onEvent("actionPressed", index)
            },
            icon = { actionIcon(index, action) },
            label = label,
            enabled = enabled,
          )
        } else {
          clickableItem(
            onClick = { onEvent("actionPressed", index) },
            icon = { actionIcon(index, action) },
            label = label,
            enabled = enabled,
          )
        }
      }
    }
  }

  @Composable
  fun actionColumn() {
    AppBarColumn(
      modifier = Modifier.fillMaxHeight(),
      overflowIndicator = { state -> AppBarOverflowIndicator(menuState = state) },
    ) {
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val label = action["tooltip"] as? String ?: action["label"] as? String ?: "Action ${index + 1}"
        val enabled = action["enabled"] as? Boolean ?: true
        if (supportsSelection) {
          toggleableItem(
            checked = index == activeIndex,
            onCheckedChange = { checked ->
              if (checked) onEvent("activeIndexChanged", index)
              onEvent("actionPressed", index)
            },
            icon = { actionIcon(index, action) },
            label = label,
            enabled = enabled,
          )
        } else {
          clickableItem(
            onClick = { onEvent("actionPressed", index) },
            icon = { actionIcon(index, action) },
            label = label,
            enabled = enabled,
          )
        }
      }
    }
  }

  @Composable
  fun horizontalContent() {
    Row(verticalAlignment = Alignment.CenterVertically) {
      if (leading != null) {
        IconButton(onClick = { onEvent("leadingPressed", null) }, enabled = properties.boolean("leadingEnabled")) {
          Icon(
            nativeM3EIcon(leading),
            contentDescription = properties["leadingTooltip"] as? String ?: "Navigate",
            tint = contentColor,
          )
        }
      }
      if (!title.isNullOrBlank()) {
        Text(
          title,
          modifier = Modifier.widthIn(max = 180.dp),
          color = contentColor,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
      }
      actionRow()
      if (trailing != null) {
        IconButton(onClick = { onEvent("trailingPressed", null) }, enabled = properties.boolean("trailingEnabled")) {
          Icon(
            nativeM3EIcon(trailing),
            contentDescription = properties["trailingTooltip"] as? String ?: "More actions",
            tint = contentColor,
          )
        }
      }
    }
  }

  @Composable
  fun verticalContent() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
      if (leading != null) {
        IconButton(onClick = { onEvent("leadingPressed", null) }, enabled = properties.boolean("leadingEnabled")) {
          Icon(
            nativeM3EIcon(leading),
            contentDescription = properties["leadingTooltip"] as? String ?: "Navigate",
            tint = contentColor,
          )
        }
      }
      if (!title.isNullOrBlank()) {
        Text(title, color = contentColor, maxLines = 1, overflow = TextOverflow.Ellipsis)
      }
      actionColumn()
      if (trailing != null) {
        IconButton(onClick = { onEvent("trailingPressed", null) }, enabled = properties.boolean("trailingEnabled")) {
          Icon(
            nativeM3EIcon(trailing),
            contentDescription = properties["trailingTooltip"] as? String ?: "More actions",
            tint = contentColor,
          )
        }
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
      expandedHeight = 64.dp,
      contentPadding = PaddingValues(horizontal = 16.dp),
      horizontalArrangement = BottomAppBarDefaults.FlexibleHorizontalArrangement,
      containerColor = dockedContainer,
      contentColor = dockedContent,
      windowInsets = androidx.compose.foundation.layout.WindowInsets(bottom = safeBottomInsetPx),
    ) {
      if (leading != null) {
        IconButton(onClick = { onEvent("leadingPressed", null) }, enabled = properties.boolean("leadingEnabled")) {
          Icon(nativeM3EIcon(leading), contentDescription = properties["leadingTooltip"] as? String ?: "Navigate", tint = contentColor)
        }
      }
      if (!title.isNullOrBlank()) {
        Text(title, modifier = Modifier.weight(1f), color = contentColor, maxLines = 1)
      }
      Box(modifier = Modifier.weight(1f)) { actionRow(Modifier.fillMaxWidth()) }
      if (trailing != null) {
        IconButton(onClick = { onEvent("trailingPressed", null) }, enabled = properties.boolean("trailingEnabled")) {
          Icon(nativeM3EIcon(trailing), contentDescription = properties["trailingTooltip"] as? String ?: "More actions", tint = contentColor)
        }
      }
    }
  } else {
    val expanded = properties.boolean("expanded", true)
    @Composable
    fun fabIconContent() {
      TooltipBox(
        positionProvider = TooltipDefaults.rememberTooltipPositionProvider(TooltipAnchorPosition.Above),
        tooltip = { PlainTooltip { Text(fabTooltip) } },
        state = rememberTooltipState(),
      ) {
        Icon(nativeM3EIcon(fabIcon!!), contentDescription = fabTooltip)
      }
    }
    val floating = @Composable {
      if (fabIcon != null) {
        if (vibrant) {
          FloatingToolbarDefaults.VibrantFloatingActionButton(
            onClick = { onEvent("fabPressed", null) },
            containerColor = fabContainer,
            contentColor = fabContent,
          ) { fabIconContent() }
        } else {
          FloatingToolbarDefaults.StandardFloatingActionButton(
            onClick = { onEvent("fabPressed", null) },
            containerColor = fabContainer,
            contentColor = fabContent,
          ) { fabIconContent() }
        }
      }
    }
    if (properties["axis"] == "vertical") {
      if (fabIcon == null) {
        VerticalFloatingToolbar(expanded = expanded, colors = resolvedFloatingColors) { verticalContent() }
      } else {
        VerticalFloatingToolbar(expanded = expanded, colors = resolvedFloatingColors, floatingActionButton = floating) { verticalContent() }
      }
    } else {
      if (fabIcon == null) {
        HorizontalFloatingToolbar(expanded = expanded, colors = resolvedFloatingColors) { horizontalContent() }
      } else {
        HorizontalFloatingToolbar(expanded = expanded, colors = resolvedFloatingColors, floatingActionButton = floating) { horizontalContent() }
      }
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ESplitButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  var expanded by remember { mutableStateOf(false) }
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: -1
  val label = properties["label"] as? String ?: ""
  val iconName = properties["leadingIcon"] as? String
  val menuButtonLabel = properties["menuButtonSemanticLabel"] as? String
    ?: "More $label options"
  val primaryEnabled = properties.boolean("primaryEnabled")
  val buttonHeight = when (properties["size"] as? String) {
    "extraSmall" -> SplitButtonDefaults.ExtraSmallContainerHeight
    "small" -> SplitButtonDefaults.SmallContainerHeight
    "medium" -> SplitButtonDefaults.MediumContainerHeight
    "large" -> SplitButtonDefaults.LargeContainerHeight
    "extraLarge" -> SplitButtonDefaults.ExtraLargeContainerHeight
    else -> SplitButtonDefaults.SmallContainerHeight
  }
  val style = properties["style"] as? String ?: "filled"
  val arrowRotation by animateFloatAsState(
    targetValue = if (expanded) 180f else 0f,
    animationSpec = MotionScheme.standard().defaultSpatialSpec(),
    label = "splitButtonMenuArrowRotation",
  )

  @Composable
  fun leadingContent() {
    Row(
      horizontalArrangement = Arrangement.spacedBy(8.dp),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      if (iconName != null) Icon(nativeM3EIcon(iconName), contentDescription = null)
      Text(label)
    }
  }

  @Composable
  fun trailingContent() {
    Icon(
      imageVector = Icons.Filled.ArrowDropDown,
      contentDescription = menuButtonLabel,
      modifier = Modifier.rotate(arrowRotation),
    )
  }

  Box {
    SplitButtonLayout(
      leadingButton = {
        val shapes = SplitButtonDefaults.leadingButtonShapesFor(buttonHeight)
        val contentPadding = SplitButtonDefaults.leadingButtonContentPaddingFor(buttonHeight)
        when (style) {
          "tonal" -> SplitButtonDefaults.TonalLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          "outlined" -> SplitButtonDefaults.OutlinedLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          "elevated" -> SplitButtonDefaults.ElevatedLeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
            enabled = primaryEnabled,
            shapes = shapes,
            contentPadding = contentPadding,
          ) { leadingContent() }
          else -> SplitButtonDefaults.LeadingButton(
            onClick = { if (primaryEnabled) onEvent("primaryPressed", null) },
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
          val onCheckedChange: (Boolean) -> Unit = { expanded = it }
          when (style) {
            "tonal" -> SplitButtonDefaults.TonalTrailingButton(
              checked = expanded,
              onCheckedChange = onCheckedChange,
              enabled = enabled,
              shapes = shapes,
              contentPadding = contentPadding,
            ) { trailingContent() }
            "outlined" -> SplitButtonDefaults.OutlinedTrailingButton(
              checked = expanded,
              onCheckedChange = onCheckedChange,
              enabled = enabled,
              shapes = shapes,
              contentPadding = contentPadding,
            ) { trailingContent() }
            "elevated" -> SplitButtonDefaults.ElevatedTrailingButton(
              checked = expanded,
              onCheckedChange = onCheckedChange,
              enabled = enabled,
              shapes = shapes,
              contentPadding = contentPadding,
            ) { trailingContent() }
            else -> SplitButtonDefaults.TrailingButton(
              checked = expanded,
              onCheckedChange = onCheckedChange,
              enabled = enabled,
              shapes = shapes,
              contentPadding = contentPadding,
            ) { trailingContent() }
          }

          DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            offset = DpOffset(0.dp, 4.dp),
          ) {
            items.forEachIndexed { index, rawItem ->
              val item = rawItem as? Map<*, *> ?: return@forEachIndexed
              val itemIcon = item["icon"] as? String
              DropdownMenuItem(
                text = { Text(item["label"] as? String ?: "") },
                onClick = {
                  expanded = false
                  onEvent("selected", index)
                },
                enabled = enabled && (item["enabled"] as? Boolean ?: true),
                leadingIcon = itemIcon?.let { { Icon(nativeM3EIcon(it), contentDescription = null) } },
                trailingIcon = if (index == selectedIndex) ({ Icon(Icons.Filled.Check, contentDescription = "Selected") }) else null,
              )
            }
          }
        }
      },
    )
  }
}

@Composable
private fun NativeM3EBadge(properties: Map<String, Any?>) {
  val label = properties["label"] as? String
  val background = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.error
  val foreground = properties.color("textColor") ?: MaterialTheme.colorScheme.onError
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    Badge(containerColor = background, contentColor = foreground) {
      if (!label.isNullOrEmpty()) {
        Text(
          text = label,
          style = MaterialTheme.typography.labelSmall,
          maxLines = 1,
          modifier = Modifier.padding(horizontal = 2.dp),
        )
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
  val count = icons?.size ?: labels.size
  if (count == 0) return
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val enabled = properties.boolean("enabled", true)
  val selectedContainer = properties.color("selectedColor")
  SingleChoiceSegmentedButtonRow(
    modifier = Modifier.fillMaxWidth().heightIn(min = (properties.number("height") ?: 36.0).dp),
  ) {
    (0 until count).forEach { index ->
      val label = labels.getOrNull(index) as? String ?: ""
      val icon = icons?.getOrNull(index) as? String
      SegmentedButton(
        selected = index == selectedIndex,
        onClick = { if (enabled) onEvent("selected", index) },
        enabled = enabled,
        shape = SegmentedButtonDefaults.itemShape(index = index, count = count),
        colors = SegmentedButtonDefaults.colors(
          activeContainerColor = selectedContainer ?: MaterialTheme.colorScheme.secondaryContainer,
        ),
        label = {
          Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
            if (icon != null) Icon(nativeM3EIcon(icon), contentDescription = null)
            if (label.isNotEmpty()) Text(label, maxLines = 1)
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
  val selectedIndex = (properties.number("selectedIndex") ?: 0.0).toInt().coerceIn(0, labels.lastIndex)
  val selectedColor = properties.color("selectedColor")
  val unselectedColor = properties.color("unselectedColor")
  androidx.compose.material3.PrimaryTabRow(
    selectedTabIndex = selectedIndex,
    containerColor = properties.color("backgroundColor") ?: Color.Transparent,
    contentColor = selectedColor ?: MaterialTheme.colorScheme.primary,
  ) {
    labels.forEachIndexed { index, rawLabel ->
      val label = rawLabel as? String ?: ""
      androidx.compose.material3.Tab(
        selected = selectedIndex == index,
        onClick = {
          onEvent("selected", index)
        },
        selectedContentColor = selectedColor ?: MaterialTheme.colorScheme.primary,
        unselectedContentColor = unselectedColor ?: MaterialTheme.colorScheme.onSurfaceVariant,
        text = { Text(label, maxLines = 1) },
      )
    }
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
  val state = rememberCarouselState { items.size }
  LaunchedEffect(state) {
    snapshotFlow { state.currentItem }
      .distinctUntilChanged()
      .collect { onEvent("positionChanged", it) }
  }
  val type = properties["type"] as? String ?: "hero"
  val itemWidth = (properties.number("itemWidth") ?: 300.0).dp
  val itemSpacing = (properties.number("itemSpacing") ?: 8.0).dp
  val cornerRadius = (properties.number("cornerRadius") ?: 28.0).dp
  val freeScroll = properties["freeScroll"] as? Boolean ?: false
  val userScrollEnabled = properties["userScrollEnabled"] as? Boolean ?: true
  val flingBehavior = if (freeScroll) {
    CarouselDefaults.noSnapFlingBehavior()
  } else {
    CarouselDefaults.singleAdvanceFlingBehavior(state)
  }
  val carouselModifier = Modifier.fillMaxWidth().fillMaxHeight()
  val content: @Composable CarouselItemScope.(Int) -> Unit = { index ->
    val item = items[index] as? Map<*, *> ?: emptyMap<Any?, Any?>()
    NativeM3ECarouselCard(item, cornerRadius) {
      onEvent("itemPressed", index)
    }
  }
  when (type) {
    "contained" -> HorizontalMultiBrowseCarousel(
      state = state,
      preferredItemWidth = itemWidth,
      modifier = carouselModifier,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = PaddingValues(horizontal = 16.dp),
      content = content,
    )
    "uncontained" -> HorizontalUncontainedCarousel(
      state = state,
      itemWidth = itemWidth,
      modifier = carouselModifier,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = PaddingValues(horizontal = 16.dp),
      content = content,
    )
    else -> HorizontalCenteredHeroCarousel(
      state = state,
      modifier = carouselModifier,
      preferredItemWidth = itemWidth,
      itemSpacing = itemSpacing,
      flingBehavior = flingBehavior,
      userScrollEnabled = userScrollEnabled,
      contentPadding = PaddingValues(horizontal = 16.dp),
      content = content,
    )
  }
}

@Composable
private fun NativeM3ECarouselCard(
  item: Map<*, *>,
  cornerRadius: androidx.compose.ui.unit.Dp,
  onClick: () -> Unit,
) {
  val container = (item["containerColor"] as? Number)?.let { Color(it.toLong().toInt()) }
    ?: MaterialTheme.colorScheme.surfaceContainerHigh
  val content = (item["contentColor"] as? Number)?.let { Color(it.toLong().toInt()) }
    ?: MaterialTheme.colorScheme.onSurface
  val title = item["title"] as? String ?: ""
  val supportingText = item["supportingText"] as? String
  val description = item["semanticDescription"] as? String ?: title
  val imageBytes = item["imageBytes"] as? ByteArray
  val image = remember(imageBytes) {
    imageBytes?.let { BitmapFactory.decodeByteArray(it, 0, it.size)?.asImageBitmap() }
  }
  Card(
    modifier = Modifier
      .fillMaxHeight()
      .clip(RoundedCornerShape(cornerRadius))
      .clickable(onClick = onClick)
      .semantics { contentDescription = description },
    shape = RoundedCornerShape(cornerRadius),
    colors = CardDefaults.cardColors(containerColor = container),
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
      Column(
        modifier = if (image != null) {
          Modifier.align(Alignment.BottomStart)
            .fillMaxWidth()
            .background(Brush.verticalGradient(listOf(Color.Transparent, Color.Black.copy(alpha = 0.78f))))
            .padding(24.dp)
        } else {
          Modifier.fillMaxSize().padding(24.dp)
        },
        horizontalAlignment = if (image == null) Alignment.CenterHorizontally else Alignment.Start,
        verticalArrangement = if (image == null) Arrangement.Center else Arrangement.Bottom,
      ) {
        val icon = item["icon"] as? String
        if (icon != null && image == null) {
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
          color = if (image != null) Color.White else content,
          style = MaterialTheme.typography.headlineSmall,
          maxLines = 2,
          overflow = TextOverflow.Ellipsis,
        )
        if (!supportingText.isNullOrBlank()) {
          Spacer(Modifier.size(8.dp))
          Text(
            supportingText,
            color = if (image != null) Color.White.copy(alpha = 0.9f) else content,
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 3,
            overflow = TextOverflow.Ellipsis,
          )
        }
      }
    }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ENavigationRail(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val sections = properties["destinations"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val background = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.surface
  val expanded = properties["type"] == "expanded"
  val fabIcon = properties["fabIcon"] as? String
  val scrollable = properties.boolean("scrollable", true)
  val state = rememberWideNavigationRailState(
    initialValue = if (expanded) WideNavigationRailValue.Expanded else WideNavigationRailValue.Collapsed,
  )

  if (expanded) {
    WideNavigationRail(
      state = state,
      modifier = Modifier.fillMaxHeight(),
      colors = WideNavigationRailDefaults.colors(containerColor = background),
      header = fabIcon?.let { iconName ->
        @Composable {
          FloatingActionButton(
            onClick = { onEvent("fabPressed", null) },
            modifier = Modifier.padding(vertical = 12.dp),
          ) { Icon(nativeM3EIcon(iconName), contentDescription = null) }
        }
      },
    ) {
      val columnModifier = if (scrollable) Modifier.verticalScroll(rememberScrollState()) else Modifier
      Column(modifier = columnModifier) {
        var index = 0
        sections.forEach { rawSection ->
          val section = rawSection as? Map<*, *> ?: return@forEach
          val header = section["header"] as? String
          if (!header.isNullOrBlank()) {
            Text(
              text = header,
              style = MaterialTheme.typography.titleSmall,
              modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
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
            val semanticLabel = item["semanticLabel"] as? String ?: label
            val badge = item["badge"] as? String
            WideNavigationRailItem(
              selected = selected,
              onClick = { onEvent("destinationSelected", currentIndex) },
              icon = {
                if (!badge.isNullOrEmpty()) {
                  BadgedBox(badge = { Badge { Text(badge) } }) {
                    Icon(nativeM3EIcon(iconName), contentDescription = semanticLabel)
                  }
                } else {
                  Icon(nativeM3EIcon(iconName), contentDescription = semanticLabel)
                }
              },
              label = if (properties["labelBehavior"] == "neverShow") null else ({ Text(label) }),
              railExpanded = true,
            )
          }
        }
      }
    }
  } else {
    NavigationRail(
      modifier = Modifier.fillMaxHeight(),
      containerColor = background,
      header = fabIcon?.let { iconName ->
        @Composable {
          FloatingActionButton(
            onClick = { onEvent("fabPressed", null) },
            modifier = Modifier.padding(vertical = 12.dp),
          ) { Icon(nativeM3EIcon(iconName), contentDescription = null) }
        }
      },
    ) {
      val columnModifier = if (scrollable) Modifier.verticalScroll(rememberScrollState()) else Modifier
      Column(modifier = columnModifier) {
        var index = 0
        sections.forEach { rawSection ->
          val section = rawSection as? Map<*, *> ?: return@forEach
          val header = section["header"] as? String
          if (!header.isNullOrBlank()) {
            Text(
              text = header,
              style = MaterialTheme.typography.titleSmall,
              modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
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
            NavigationRailItem(
              selected = selected,
              onClick = { onEvent("destinationSelected", currentIndex) },
              icon = {
                if (!badge.isNullOrEmpty()) {
                  BadgedBox(badge = { Badge { Text(badge) } }) {
                    Icon(nativeM3EIcon(iconName), contentDescription = item["semanticLabel"] as? String ?: label)
                  }
                } else {
                  Icon(nativeM3EIcon(iconName), contentDescription = item["semanticLabel"] as? String ?: label)
                }
              },
              label = if (properties["labelBehavior"] == "neverShow") null else ({ Text(label) }),
              alwaysShowLabel = properties["labelBehavior"] == "alwaysShow",
            )
          }
        }
      }
    }
  }
}

@Composable
private fun NativeM3ENavigationDrawer(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  NativeM3ENavigationDrawerSheet(properties, onEvent)
}

@Composable
private fun NativeM3ENavigationDrawerOverlay(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
  var wasOpened by remember { mutableStateOf(false) }
  val direction = LocalLayoutDirection.current
  LaunchedEffect(Unit) { drawerState.open() }
  LaunchedEffect(drawerState.currentValue) {
    if (drawerState.currentValue == DrawerValue.Open) {
      wasOpened = true
    } else if (wasOpened) {
      onEvent("dismissed", null)
    }
  }
  Dialog(
    onDismissRequest = { onEvent("dismissed", null) },
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
        scrimColor = MaterialTheme.colorScheme.scrim.copy(alpha = 0.32f),
        drawerContent = { NativeM3ENavigationDrawerSheet(properties, onEvent) },
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
) {
  val destinations = properties["destinations"] as? List<*> ?: emptyList<Any?>()
  val selectedIndex = properties.number("selectedIndex")?.toInt() ?: 0
  val background = properties.color("backgroundColor") ?: MaterialTheme.colorScheme.surfaceContainerLow
  ModalDrawerSheet(
    modifier = Modifier.fillMaxSize(),
    drawerContainerColor = background,
  ) {
    Column(
      modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()),
    ) {
      val header = properties["header"] as? String
      val supportingHeader = properties["supportingHeader"] as? String
      if (!header.isNullOrBlank() || !supportingHeader.isNullOrBlank()) {
        Column(Modifier.fillMaxWidth().padding(start = 28.dp, top = 28.dp, end = 20.dp, bottom = 20.dp)) {
          if (!header.isNullOrBlank()) {
            Text(header, style = MaterialTheme.typography.titleLarge)
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
        val badge = destination["badge"] as? String
        val enabled = destination["enabled"] as? Boolean ?: true
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
          badge = badge?.let { text -> ({ Text(text) }) },
          selected = index == selectedIndex,
          onClick = { if (enabled) onEvent("destinationSelected", index) },
          modifier = Modifier
            .padding(horizontal = 12.dp)
            .then(if (enabled) Modifier else Modifier.alpha(0.38f)),
        )
      }
      Spacer(Modifier.height(12.dp))
    }
  }
}

@Composable
private fun NativeM3EIconButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val selected = properties["selected"] as? Boolean
  val variant = properties["variant"] as? String ?: "standard"
  val shape = if (properties["shape"] == "square") {
    RoundedCornerShape(16.dp)
  } else {
    IconButtonDefaults.standardShape
  }
  val width = (properties.number("widthDp") ?: 48.0).dp
  val height = (properties.number("sizeDp") ?: 48.0).dp
  val modifier = Modifier
    .size(width = width, height = height)
    .then((properties["semanticLabel"] as? String ?: properties["tooltip"] as? String)
      ?.let { label -> Modifier.semantics { contentDescription = label } } ?: Modifier)
  val selectedState = selected ?: false
  val iconName = if (selectedState) {
    properties["selectedIcon"] as? String ?: properties["icon"] as? String
  } else {
    properties["icon"] as? String
  }
  val image = nativeM3EIcon(iconName)
  val icon: @Composable () -> Unit = { Icon(image, contentDescription = null) }
  val aiPowered = properties["aiPowered"] as? Boolean ?: false
  val displayIcon: @Composable () -> Unit = {
    if (aiPowered) {
      NativeM3EAiSparkleIcon(iconName, size = 24.dp)
    } else {
      icon()
    }
  }
  val badge = properties["badge"] as? String
  val content: @Composable () -> Unit = {
    if (!badge.isNullOrEmpty()) {
      BadgedBox(badge = { Badge { Text(badge) } }) { displayIcon() }
    } else {
      displayIcon()
    }
  }
  val defaultForeground = when (variant) {
    "filled" -> MaterialTheme.colorScheme.onPrimary
    "tonal" -> MaterialTheme.colorScheme.onSecondaryContainer
    "outlined" -> MaterialTheme.colorScheme.onSurfaceVariant
    else -> MaterialTheme.colorScheme.onSurfaceVariant
  }
  val defaultBackground = when (variant) {
    "filled" -> MaterialTheme.colorScheme.primary
    "tonal" -> MaterialTheme.colorScheme.secondaryContainer
    else -> Color.Transparent
  }
  val foreground = properties.color("foregroundColor") ?: defaultForeground
  val background = properties.color("backgroundColor") ?: defaultBackground
  val selectedForeground = properties.color("selectedForegroundColor") ?: foreground
  val selectedBackground = properties.color("selectedBackgroundColor") ?: background
  val onClick = { if (enabled) onEvent("pressed", null) }
  if (selected != null) {
    val onCheckedChange: (Boolean) -> Unit = { if (enabled) onEvent("selectionChanged", it) }
    when (variant) {
      "filled" -> FilledIconToggleButton(
        checked = selected,
        onCheckedChange = onCheckedChange,
        enabled = enabled,
        modifier = modifier,
        shape = shape,
        colors = IconButtonDefaults.filledIconToggleButtonColors(
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
        shape = shape,
        colors = IconButtonDefaults.filledTonalIconToggleButtonColors(
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
        shape = shape,
        colors = IconButtonDefaults.outlinedIconToggleButtonColors(
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
        shape = shape,
        colors = IconButtonDefaults.iconToggleButtonColors(
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
        shape = shape,
        colors = IconButtonDefaults.filledIconButtonColors(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      "tonal" -> FilledTonalIconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shape = shape,
        colors = IconButtonDefaults.filledTonalIconButtonColors(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      "outlined" -> OutlinedIconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shape = shape,
        colors = IconButtonDefaults.outlinedIconButtonColors(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
      else -> IconButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        shape = shape,
        colors = IconButtonDefaults.iconButtonColors(
          containerColor = background,
          contentColor = foreground,
        ),
        content = content,
      )
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

@Composable
private fun NativeM3EFab(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val background = properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = properties.color("foregroundColor") ?: fabContentColor(properties)
  val elevation = properties.number("elevation")?.dp?.let {
    FloatingActionButtonDefaults.elevation(defaultElevation = it)
  } ?: FloatingActionButtonDefaults.elevation()
  val modifier = Modifier.then(
    (properties["tooltip"] as? String)?.let { label ->
      Modifier.semantics { contentDescription = label }
    } ?: Modifier,
  )
  val icon = nativeM3EIcon(properties["icon"] as? String)
  val aiPowered = properties["aiPowered"] as? Boolean ?: false
  val click = { if (enabled) onEvent("pressed", null) }
  val fabIcon: @Composable () -> Unit = {
    if (aiPowered) NativeM3EAiSparkleIcon(properties["icon"] as? String, 24.dp)
    else Icon(icon, contentDescription = null)
  }
  val colors = Triple(background, foreground, elevation)
  when (properties["size"] as? String) {
    "small" -> SmallFloatingActionButton(
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

@Composable
private fun NativeM3EExtendedFab(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val extended = properties.boolean("extended", true)
  val background = properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = properties.color("foregroundColor") ?: fabContentColor(properties)
  val elevation = properties.number("elevation")?.dp?.let {
    FloatingActionButtonDefaults.elevation(defaultElevation = it)
  } ?: FloatingActionButtonDefaults.elevation()
  val icon = nativeM3EIcon(properties["icon"] as? String)
  val label = properties["label"] as? String ?: ""
  val click = { if (enabled) onEvent("pressed", null) }
  if (extended) {
    ExtendedFloatingActionButton(
      onClick = click,
      icon = { Icon(icon, contentDescription = null) },
      text = { Text(label) },
      containerColor = background,
      contentColor = foreground,
      elevation = elevation,
    )
  } else {
    FloatingActionButton(
      onClick = click,
      containerColor = background,
      contentColor = foreground,
      elevation = elevation,
    ) { Icon(icon, contentDescription = null) }
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EFabMenu(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  var expanded by rememberSaveable { mutableStateOf(false) }
  val size = when (properties["size"] as? String) {
    "small" -> 40.dp
    "large" -> 96.dp
    else -> 56.dp
  }
  val background = properties.color("backgroundColor") ?: fabContainerColor(properties)
  val foreground = properties.color("foregroundColor") ?: fabContentColor(properties)
  val closedIcon = nativeM3EIcon(properties["icon"] as? String)
  val openIcon = nativeM3EIcon(properties["closeIcon"] as? String)
  val alignment = if (properties["position"] == "left") Alignment.Start else Alignment.End
  val serializedItems = properties["items"] as? List<*> ?: emptyList<Any?>()

  ToggleFloatingActionButton(
    checked = expanded,
    onCheckedChange = { expanded = it },
    modifier = Modifier.size(size),
    containerColor = { background },
  ) {
    val icon = if (checkedProgress > 0.5f) openIcon else closedIcon
    Icon(icon, contentDescription = null, modifier = Modifier.size(24.dp), tint = foreground)
  }

  if (expanded) {
    Dialog(
      onDismissRequest = { expanded = false },
      properties = DialogProperties(usePlatformDefaultWidth = false),
    ) {
      Box(Modifier.fillMaxSize(), contentAlignment = Alignment.BottomEnd) {
        FloatingActionButtonMenu(
          expanded = true,
          button = { Spacer(Modifier.size(size)) },
          horizontalAlignment = alignment,
          modifier = Modifier
            .align(Alignment.BottomEnd)
            .padding(16.dp),
        ) {
          serializedItems.forEachIndexed { index, raw ->
            val item = raw as? Map<*, *> ?: return@forEachIndexed
            val label = item["label"] as? String ?: ""
            val icon = nativeM3EIcon(item["icon"] as? String)
            FloatingActionButtonMenuItem(
              onClick = {
                expanded = false
                onEvent("itemPressed", index)
              },
              text = { Text(label) },
              icon = { Icon(icon, contentDescription = null) },
              containerColor = background,
              contentColor = foreground,
            )
          }
        }
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
  "message" -> Icons.Filled.Message
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
  HorizontalDivider(
    modifier = Modifier
      .fillMaxWidth()
      .padding(
        start = (properties.number("indent") ?: 0.0).dp,
        end = (properties.number("endIndent") ?: 0.0).dp,
      ),
    thickness = (properties.number("thickness") ?: 1.0).dp,
    color = properties.color("color") ?: MaterialTheme.colorScheme.outlineVariant,
  )
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3ELoadingIndicator(properties: Map<String, Any?>) {
  val size = (properties.number("size") ?: 48.0).dp
  val semanticLabel = properties["semanticLabel"] as? String
  val modifier = Modifier
    .size(size)
    .then(if (semanticLabel == null) Modifier else Modifier.semantics {
      contentDescription = semanticLabel
    })
  val color = properties.color("color") ?: MaterialTheme.colorScheme.primary

  if (properties["variant"] == "contained") {
    ContainedLoadingIndicator(
      modifier = modifier,
      indicatorColor = color,
      containerColor = properties.color("containerColor")
        ?: MaterialTheme.colorScheme.primaryContainer,
    )
  } else {
    LoadingIndicator(
      modifier = modifier,
      color = color,
    )
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun NativeM3EProgressIndicator(properties: Map<String, Any?>) {
  val linear = properties.boolean("linear")
  val value = properties.number("value")?.toFloat()?.coerceIn(0f, 1f)
  val color = properties.color("color") ?: MaterialTheme.colorScheme.primary
  val trackColor = properties.color("trackColor") ?: MaterialTheme.colorScheme.secondaryContainer
  val shape = properties["shape"] as? String ?: "flat"
  val semanticsLabel = properties["semanticsLabel"] as? String
  val semanticsModifier = semanticsLabel?.let { label ->
    Modifier.semantics(mergeDescendants = true) { contentDescription = label }
  } ?: Modifier

  if (linear) {
    val trackThickness = (properties.number("trackThickness") ?: 4.0).dp
    val linearInset = (properties.number("linearInset") ?: 4.0).dp
    if (shape == "wavy") {
      val strokePx = with(LocalDensity.current) { trackThickness.toPx() }
      val stroke = Stroke(width = strokePx, cap = StrokeCap.Round)
      val wavyModifier = semanticsModifier.fillMaxWidth().padding(horizontal = linearInset)
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
          progress = { value },
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
        .height(trackThickness)
      if (value == null) {
        LinearProgressIndicator(
          modifier = flatModifier,
          color = color,
          trackColor = trackColor,
        )
      } else {
        LinearProgressIndicator(
          progress = { value },
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
        progress = { value },
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
      progress = { value },
      modifier = circularModifier,
      color = color,
      trackColor = trackColor,
      strokeWidth = strokeWidth,
    )
  }
}

@Composable
private fun NativeM3EButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val style = properties["style"] as? String ?: "filled"
  val radius = properties.number("borderRadius")?.dp
  val shape = radius?.let { RoundedCornerShape(it) } ?: MaterialTheme.shapes.medium
  val foreground = properties.color("foregroundColor")
  val background = properties.color("backgroundColor")
  val minHeight = (properties.number("minHeight") ?: 40.0).dp
  val modifier = Modifier.heightIn(min = minHeight)
  val contentPadding = properties.number("horizontalPadding")?.let {
    PaddingValues(horizontal = it.dp)
  } ?: ButtonDefaults.ContentPadding
  val icon = properties["icon"] as? String
  val label = properties["label"] as? String ?: ""
  @Composable
  fun content() {
    Row(
      verticalAlignment = Alignment.CenterVertically,
      horizontalArrangement = Arrangement.Center,
    ) {
      if (icon != null) {
        Icon(nativeM3EIcon(icon), contentDescription = null, modifier = Modifier.size(18.dp))
        if (label.isNotEmpty()) Spacer(Modifier.width(8.dp))
      }
      if (label.isNotEmpty()) Text(label, fontSize = (properties.number("fontSize") ?: 14.0).sp)
    }
  }
  val click = { if (enabled) onEvent("pressed", null) }

  when (style) {
    "plain" -> TextButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.textButtonColors(
        contentColor = foreground ?: MaterialTheme.colorScheme.primary,
      ),
      contentPadding = contentPadding,
    ) { content() }

    "bordered" -> OutlinedButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      border = BorderStroke(1.dp, background ?: MaterialTheme.colorScheme.outline),
      colors = ButtonDefaults.outlinedButtonColors(
        contentColor = foreground ?: MaterialTheme.colorScheme.primary,
      ),
      contentPadding = contentPadding,
    ) { content() }

    "tinted", "gray", "glass" -> FilledTonalButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.filledTonalButtonColors(
        containerColor = background ?: MaterialTheme.colorScheme.secondaryContainer,
        contentColor = foreground ?: MaterialTheme.colorScheme.onSecondaryContainer,
      ),
      contentPadding = contentPadding,
    ) { content() }

    else -> Button(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.buttonColors(
        containerColor = background ?: MaterialTheme.colorScheme.primary,
        contentColor = foreground ?: MaterialTheme.colorScheme.onPrimary,
      ),
      contentPadding = contentPadding,
    ) { content() }
  }
}

@Composable
private fun NativeM3EPopupMenuButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  var expanded by remember { mutableStateOf(false) }
  val items = properties["items"] as? List<*> ?: emptyList<Any?>()
  val anchorType = properties["anchorType"] as? String ?: "text"
  val tint = properties.color("tint") ?: MaterialTheme.colorScheme.primary
  val label = properties["label"] as? String ?: ""
  Box {
    if (anchorType == "text") {
      when (properties["style"] as? String) {
        "filled" -> Button(onClick = { expanded = true }, enabled = enabled) {
          Text(label)
          Icon(Icons.Filled.ArrowDropDown, contentDescription = null)
        }
        "tonal" -> FilledTonalButton(onClick = { expanded = true }, enabled = enabled) {
          Text(label)
          Icon(Icons.Filled.ArrowDropDown, contentDescription = null)
        }
        "outlined" -> OutlinedButton(onClick = { expanded = true }, enabled = enabled) {
          Text(label)
          Icon(Icons.Filled.ArrowDropDown, contentDescription = null)
        }
        else -> TextButton(onClick = { expanded = true }, enabled = enabled) {
          Text(label)
          Icon(Icons.Filled.ArrowDropDown, contentDescription = null)
        }
      }
    }
    if (anchorType == "icon") {
      IconButton(onClick = { expanded = true }, enabled = enabled) {
        Icon(nativeM3EIcon(properties["icon"] as? String), contentDescription = "More options", tint = tint)
      }
    }
    DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
      items.forEachIndexed { index, rawItem ->
        val item = rawItem as? Map<*, *> ?: return@forEachIndexed
        if (item["divider"] == true) {
          HorizontalDivider()
        } else {
          val labelText = item["label"] as? String ?: ""
          val subtitle = item["subtitle"] as? String
          val iconName = item["icon"] as? String
          val destructive = item["destructive"] as? Boolean ?: false
          val imageBytes = item["imageBytes"] as? ByteArray
          val image = imageBytes?.let { BitmapFactory.decodeByteArray(it, 0, it.size)?.asImageBitmap() }
          DropdownMenuItem(
            text = {
              Column {
                Text(labelText, color = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface)
                if (!subtitle.isNullOrBlank()) Text(subtitle, style = MaterialTheme.typography.bodySmall)
              }
            },
            leadingIcon = when {
              image != null -> ({ Image(image, contentDescription = null, modifier = Modifier.size(32.dp).clip(CircleShape)) })
              iconName != null -> ({ Icon(nativeM3EIcon(iconName), contentDescription = null, tint = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant) })
              else -> null
            },
            enabled = item["enabled"] as? Boolean ?: true,
            onClick = {
              expanded = false
              onEvent("selected", index)
            },
          )
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
  Box(Modifier.offset(x = x, y = y).size(1.dp)) {
    DropdownMenu(expanded = true, onDismissRequest = { onEvent("dismissed", null) }) {
      items.forEachIndexed { index, rawItem ->
        val item = rawItem as? Map<*, *> ?: return@forEachIndexed
        if (item["divider"] == true) {
          HorizontalDivider()
        } else {
          val label = item["label"] as? String ?: ""
          val subtitle = item["subtitle"] as? String
          val iconName = item["icon"] as? String
          val destructive = item["destructive"] as? Boolean ?: false
          val imageBytes = item["imageBytes"] as? ByteArray
          val image = imageBytes?.let {
            BitmapFactory.decodeByteArray(it, 0, it.size)?.asImageBitmap()
          }
          DropdownMenuItem(
            text = {
              Column {
                Text(
                  label,
                  color = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface,
                )
                if (!subtitle.isNullOrBlank()) {
                  Text(subtitle, style = MaterialTheme.typography.bodySmall)
                }
              }
            },
            leadingIcon = when {
              image != null -> ({
                Image(image, contentDescription = null, modifier = Modifier.size(32.dp).clip(CircleShape))
              })
              iconName != null -> ({
                Icon(
                  nativeM3EIcon(iconName),
                  contentDescription = null,
                  tint = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant,
                )
              })
              else -> null
            },
            enabled = item["enabled"] as? Boolean ?: true,
            onClick = { onEvent("selected", index) },
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
  val hint = properties["hint"] as? String ?: ""
  val showClear = properties.boolean("showClear") && query.isNotEmpty()
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
  val inputField: @Composable () -> Unit = {
    SearchBarDefaults.InputField(
      query = query,
      onQueryChange = { onEvent("changed", it) },
      onSearch = { onEvent("submitted", it) },
      expanded = false,
      onExpandedChange = { if (it) onEvent("tapped", null) },
      enabled = enabled,
      placeholder = { Text(hint) },
      leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
      trailingIcon = if (showClear) {
        ({
          IconButton(onClick = { onEvent("cleared", null) }) {
            Icon(Icons.Filled.Close, contentDescription = "Clear search")
          }
        })
      } else null,
      modifier = Modifier
        .then(if (autofocus || focusRequestVersion > 0) Modifier.focusRequester(focusRequester) else Modifier)
        .onFocusChanged { state ->
          if (reportedFocus != state.hasFocus) {
            reportedFocus = state.hasFocus
            onEvent("focusChanged", state.hasFocus)
          }
        },
    )
  }
  SearchBar(
    inputField = inputField,
    expanded = false,
    onExpandedChange = { if (it) onEvent("tapped", null) },
    modifier = Modifier.fillMaxWidth(),
  ) {}
}

@Composable
private fun NativeM3ETextField(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val query = properties["query"] as? String ?: ""
  val label = properties["label"] as? String
  val placeholder = properties["placeholder"] as? String
  val errorText = properties["errorText"] as? String
  val helperText = properties["helperText"] as? String
  val prefixText = properties["prefixText"] as? String
  val suffixText = properties["suffixText"] as? String
  val prefixIcon = properties["prefixIcon"] as? String
  val suffixIcon = properties["suffixIcon"] as? String
  val maxLength = properties.number("maxLength")?.toInt()
  val maxLines = (properties.number("maxLines") ?: 1.0).toInt().coerceAtLeast(1)
  val minLines = (properties.number("minLines") ?: 1.0).toInt().coerceAtLeast(1)
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
  val textStyle = TextStyle(
    fontSize = (properties.number("fontSize") ?: 16.0).sp,
    fontWeight = properties.number("fontWeight")?.toInt()?.let(::FontWeight),
    color = properties.color("textColor") ?: MaterialTheme.colorScheme.onSurface,
  )
  val keyboardType = when (properties["keyboardType"] as? String) {
    "number" -> KeyboardType.Number
    "decimal" -> KeyboardType.Decimal
    "phone" -> KeyboardType.Phone
    "email" -> KeyboardType.Email
    "url" -> KeyboardType.Uri
    "password" -> KeyboardType.Password
    "multiline" -> KeyboardType.Text
    else -> KeyboardType.Text
  }
  val imeAction = when (properties["textInputAction"] as? String) {
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
  val padding = properties["padding"] as? List<*>
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
    "end", "right" -> TextAlign.End
    "justify" -> TextAlign.Justify
    else -> TextAlign.Start
  }
  OutlinedTextField(
    value = query,
    onValueChange = { next ->
      onEvent("changed", if (maxLength == null) next else next.take(maxLength))
    },
    modifier = Modifier
      .fillMaxWidth()
      .then(
        if (padding?.size == 4) Modifier.padding(
          start = ((padding[0] as? Number)?.toDouble() ?: 0.0).dp,
          top = ((padding[1] as? Number)?.toDouble() ?: 0.0).dp,
          end = ((padding[2] as? Number)?.toDouble() ?: 0.0).dp,
          bottom = ((padding[3] as? Number)?.toDouble() ?: 0.0).dp,
        ) else Modifier,
      )
      .then(if (autofocus || focusRequestVersion > 0) Modifier.focusRequester(focusRequester) else Modifier)
      .then(
        if (contentTypes.isEmpty()) Modifier else Modifier.semantics {
          contentType = contentTypes.reduce { accumulated, type -> accumulated + type }
        },
      )
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
      },
    enabled = enabled,
    readOnly = properties.boolean("readOnly"),
    textStyle = textStyle.copy(textAlign = textAlign),
    label = label?.let { text -> ({ Text(text) }) },
    placeholder = placeholder?.let { text -> ({ Text(text) }) },
    leadingIcon = prefixIcon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
    trailingIcon = suffixIcon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
    prefix = prefixText?.let { text -> ({ Text(text) }) },
    suffix = suffixText?.let { text -> ({ Text(text) }) },
    supportingText = (errorText ?: helperText)?.let { text -> ({ Text(text) }) },
    isError = errorText != null,
    visualTransformation = if (properties.boolean("obscureText")) PasswordVisualTransformation() else VisualTransformation.None,
    keyboardOptions = KeyboardOptions(
      capitalization = capitalization,
      autoCorrectEnabled = properties.boolean("autocorrect", true),
      keyboardType = keyboardType,
      imeAction = imeAction,
    ),
    keyboardActions = KeyboardActions(
      onDone = { onEvent("submitted", query) },
      onGo = { onEvent("submitted", query) },
      onSearch = { onEvent("submitted", query) },
      onSend = { onEvent("submitted", query) },
    ),
    singleLine = maxLines == 1,
    minLines = minLines,
    maxLines = maxLines,
    colors = OutlinedTextFieldDefaults.colors(
      focusedContainerColor = if (properties.boolean("filled")) properties.color("fillColor") ?: MaterialTheme.colorScheme.surfaceContainerHighest else Color.Transparent,
      unfocusedContainerColor = if (properties.boolean("filled")) properties.color("fillColor") ?: MaterialTheme.colorScheme.surfaceContainerHighest else Color.Transparent,
    ),
  )
}

@Composable
private fun NativeM3ESwitchListTile(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val checked = properties.boolean("value")
  val title = properties["title"] as? String ?: ""
  val subtitle = properties["subtitle"] as? String
  val leadingIcon = properties["leadingIcon"] as? String
  ListItem(
    modifier = Modifier
      .fillMaxWidth()
      .then(if (properties.boolean("hasOnTap")) Modifier.clickable(enabled = enabled) { onEvent("tapped", null) } else Modifier),
    headlineContent = { Text(title) },
    supportingContent = subtitle?.let { text -> ({ Text(text) }) },
    leadingContent = leadingIcon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
    trailingContent = {
      Switch(
        checked = checked,
        onCheckedChange = { onEvent("changed", it) },
        enabled = enabled,
        colors = SwitchDefaults.colors(
          checkedTrackColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
        ),
      )
    },
  )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NativeM3EListTile(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val selected = properties.boolean("selected")
  val leadingIcon = properties["leadingIcon"] as? String
  val trailingIcon = properties["trailingIcon"] as? String
  val padding = properties["padding"] as? List<*>
  val modifier = Modifier
    .fillMaxWidth()
    .then(
      if (padding?.size == 4) {
        Modifier.padding(
          start = ((padding[0] as? Number)?.toDouble() ?: 16.0).dp,
          top = ((padding[1] as? Number)?.toDouble() ?: 4.0).dp,
          end = ((padding[2] as? Number)?.toDouble() ?: 16.0).dp,
          bottom = ((padding[3] as? Number)?.toDouble() ?: 4.0).dp,
        )
      } else Modifier
    )
    .combinedClickable(
      enabled = enabled && (properties.boolean("hasOnTap") || properties.boolean("hasOnLongPress")),
      onClick = { if (properties.boolean("hasOnTap")) onEvent("tapped", null) },
      onLongClick = { if (properties.boolean("hasOnLongPress")) onEvent("longPressed", null) },
    )
  val containerColor = properties.color("backgroundColor")
    ?: if (selected) MaterialTheme.colorScheme.secondaryContainer else MaterialTheme.colorScheme.surface
  ListItem(
    modifier = modifier,
    headlineContent = { Text(properties["title"] as? String ?: "") },
    supportingContent = (properties["subtitle"] as? String)?.let { text -> ({ Text(text) }) },
    leadingContent = leadingIcon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
    trailingContent = trailingIcon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
    colors = ListItemDefaults.colors(containerColor = containerColor),
  )
}

@Composable
private fun NativeM3ECardSurface(properties: Map<String, Any?>) {
  val radius = (properties.number("radius") ?: 12.0).dp
  Card(
    modifier = Modifier.fillMaxSize(),
    shape = RoundedCornerShape(radius),
    colors = CardDefaults.cardColors(
      containerColor = properties.color("color") ?: MaterialTheme.colorScheme.surfaceContainerLow,
    ),
    elevation = CardDefaults.cardElevation(
      defaultElevation = (properties.number("elevation") ?: 1.0).dp,
    ),
  ) {}
}

@Composable
private fun NativeM3EAlertDialog(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val hasInput = properties.containsKey("initialValue")
  val maxLength = properties.number("maxLength")?.toInt()
  var input by rememberSaveable { mutableStateOf(properties["initialValue"] as? String ?: "") }
  val iconName = properties["icon"] as? String
  val iconColor = properties.color("iconColor") ?: MaterialTheme.colorScheme.primary
  val iconSize = (properties.number("iconSize") ?: 24.0).dp
  Dialog(onDismissRequest = { onEvent("dismissed", null) }) {
    AlertDialog(
      onDismissRequest = { onEvent("dismissed", null) },
      icon = iconName?.let { name ->
        ({ Icon(nativeM3EIcon(name), contentDescription = null, tint = iconColor, modifier = Modifier.size(iconSize)) })
      },
      title = { Text(properties["title"] as? String ?: "") },
      text = {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
          (properties["message"] as? String)?.let { Text(it) }
          (properties["oneTimeCode"] as? String)?.let {
            Text(it, style = MaterialTheme.typography.headlineSmall, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
          }
          if (hasInput) {
            androidx.compose.material3.OutlinedTextField(
              value = input,
              onValueChange = { next ->
                input = if (maxLength == null) next else next.take(maxLength)
              },
              label = { Text(properties["placeholder"] as? String ?: "") },
              singleLine = true,
              visualTransformation = if (properties.boolean("obscureText")) PasswordVisualTransformation() else androidx.compose.ui.text.input.VisualTransformation.None,
            )
          }
        }
      },
      confirmButton = {
        Row(horizontalArrangement = Arrangement.End) {
          actions.forEachIndexed { index, rawAction ->
            val action = rawAction as? Map<*, *> ?: return@forEachIndexed
            if (action["style"] == "cancel") return@forEachIndexed
            val style = action["style"] as? String ?: "defaultAction"
            val enabled = (action["enabled"] as? Boolean ?: true) && style != "disabled"
            val actionColor = when (style) {
              "destructive" -> MaterialTheme.colorScheme.error
              "success" -> Color(0xFF2E7D32)
              "warning" -> Color(0xFFED6C02)
              "info" -> MaterialTheme.colorScheme.primary
              else -> null
            }
            TextButton(
              onClick = { onEvent("selected", listOf(index, input)) },
              enabled = enabled,
              colors = actionColor?.let { androidx.compose.material3.ButtonDefaults.textButtonColors(contentColor = it) }
                ?: androidx.compose.material3.ButtonDefaults.textButtonColors(),
            ) { Text(action["title"] as? String ?: "") }
          }
        }
      },
      dismissButton = {
        Row {
          actions.forEachIndexed { index, rawAction ->
            val action = rawAction as? Map<*, *> ?: return@forEachIndexed
            if (action["style"] != "cancel") return@forEachIndexed
            TextButton(
              onClick = { onEvent("selected", listOf(index, input)) },
              enabled = action["enabled"] as? Boolean ?: true,
            ) { Text(action["title"] as? String ?: "Cancel") }
          }
        }
      },
    )
  }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun NativeM3EActionSheet(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val actions = properties["actions"] as? List<*> ?: emptyList<Any?>()
  val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
  ModalBottomSheet(
    onDismissRequest = { onEvent("dismissed", null) },
    sheetState = sheetState,
    containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
    scrimColor = MaterialTheme.colorScheme.scrim.copy(alpha = 0.32f),
  ) {
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .verticalScroll(rememberScrollState())
        .padding(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 24.dp),
    ) {
      val title = properties["title"] as? String
      val message = properties["message"] as? String
      if (title != null || message != null) {
        Column(Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 4.dp)) {
          title?.let { Text(it, style = MaterialTheme.typography.titleMedium) }
          if (!message.isNullOrBlank()) {
            Text(
              message,
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
          }
        }
        Spacer(Modifier.height(8.dp))
      }
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val label = action["label"] as? String ?: ""
        val icon = action["icon"] as? String
        val cancel = action["cancel"] as? Boolean ?: false
        val destructive = action["destructive"] as? Boolean ?: false
        val defaultAction = action["default"] as? Boolean ?: false
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .clip(RoundedCornerShape(16.dp))
            .clickable { onEvent("selected", index) }
            .padding(horizontal = 12.dp, vertical = 10.dp),
          verticalAlignment = Alignment.CenterVertically,
        ) {
          if (icon != null) {
            Icon(
              nativeM3EIcon(icon),
              contentDescription = null,
              tint = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.width(16.dp))
          }
          Text(
            label,
            modifier = Modifier.weight(1f),
            color = when {
              destructive -> MaterialTheme.colorScheme.error
              defaultAction -> MaterialTheme.colorScheme.primary
              else -> MaterialTheme.colorScheme.onSurface
            },
            fontWeight = if (defaultAction) androidx.compose.ui.text.font.FontWeight.SemiBold else null,
            textAlign = if (cancel) androidx.compose.ui.text.style.TextAlign.Center else null,
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
  Box(Modifier.offset(x = x, y = y).size(1.dp)) {
    DropdownMenu(expanded = true, onDismissRequest = { onEvent("dismissed", null) }) {
      actions.forEachIndexed { index, rawAction ->
        val action = rawAction as? Map<*, *> ?: return@forEachIndexed
        val title = action["title"] as? String ?: ""
        val icon = action["icon"] as? String
        val destructive = action["destructive"] as? Boolean ?: false
        DropdownMenuItem(
          text = { Text(title, color = if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface) },
          leadingIcon = icon?.let { name -> ({ Icon(nativeM3EIcon(name), contentDescription = null) }) },
          enabled = action["enabled"] as? Boolean ?: true,
          onClick = { onEvent("selected", index) },
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
  val state = rememberDatePickerState(
    initialSelectedDateMillis = initial,
    yearRange = firstYear..lastYear,
    selectableDates = object : SelectableDates {
      override fun isSelectableDate(utcTimeMillis: Long): Boolean = utcTimeMillis in first..last
      override fun isSelectableYear(year: Int): Boolean = year in firstYear..lastYear
    },
  )
  DatePickerDialog(
    onDismissRequest = { onEvent("dismissed", null) },
    confirmButton = {
      TextButton(onClick = { state.selectedDateMillis?.let { onEvent("submitted", it) } }) {
        Text("OK")
      }
    },
    dismissButton = {
      TextButton(onClick = { onEvent("dismissed", null) }) { Text("Cancel") }
    },
  ) {
    DatePicker(state = state)
  }
}

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
  Dialog(onDismissRequest = { onEvent("dismissed", null) }) {
    AlertDialog(
      onDismissRequest = { onEvent("dismissed", null) },
      title = { Text("Select time") },
      text = { TimePicker(state = state) },
      confirmButton = {
        TextButton(onClick = { onEvent("submitted", listOf(state.hour, state.minute)) }) {
          Text("OK")
        }
      },
      dismissButton = {
        TextButton(onClick = { onEvent("dismissed", null) }) { Text("Cancel") }
      },
    )
  }
}

@Composable
private fun NativeM3ESwitch(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  Switch(
    checked = properties.boolean("value"),
    onCheckedChange = { onEvent("changed", it) },
    enabled = enabled,
    modifier = Modifier.size(width = 64.dp, height = 48.dp),
    colors = SwitchDefaults.colors(
      checkedTrackColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
      checkedThumbColor = properties.color("thumbColor") ?: MaterialTheme.colorScheme.onPrimary,
    ),
  )
}

@Composable
private fun NativeM3ECheckbox(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val value = properties["value"] as? Boolean
  val colors = CheckboxDefaults.colors(
    checkedColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
    checkmarkColor = properties.color("checkColor") ?: MaterialTheme.colorScheme.onPrimary,
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
      modifier = Modifier.size(48.dp),
      colors = colors,
    )
  } else {
    Checkbox(
      checked = value,
      onCheckedChange = { onEvent("changed", it) },
      enabled = enabled,
      modifier = Modifier.size(48.dp),
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
  val selected = properties.boolean("selected")
  val toggleable = properties.boolean("toggleable")
  RadioButton(
    selected = selected,
    onClick = {
      onEvent("changed", if (selected && toggleable) false else true)
    },
    enabled = enabled,
    modifier = Modifier.size(48.dp),
    colors = RadioButtonDefaults.colors(
      selectedColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
    ),
  )
}

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
  var latestValue by remember(value) { mutableFloatStateOf(value.toFloat()) }
  val interactionSource = remember { MutableInteractionSource() }
  val isDragged by interactionSource.collectIsDraggedAsState()
  val label = properties["label"] as? String
  LaunchedEffect(isDragged) {
    if (isDragged && properties.boolean("hasStartCallback")) {
      onEvent("started", latestValue.toDouble())
    }
  }
  Column {
    if (isDragged && !label.isNullOrBlank()) {
      Text(label, modifier = Modifier.align(Alignment.CenterHorizontally))
    }
    Slider(
      value = value.toFloat(),
      onValueChange = {
        latestValue = it
        onEvent("changed", it.toDouble())
      },
      enabled = enabled,
      modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp),
      valueRange = min.toFloat()..max.toFloat(),
      steps = divisions,
      interactionSource = interactionSource,
      onValueChangeFinished = { onEvent("finished", latestValue.toDouble()) },
      colors = SliderDefaults.colors(
        thumbColor = properties.color("thumbColor") ?: MaterialTheme.colorScheme.primary,
        activeTrackColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
      ),
    )
  }
}

private fun Map<String, Any?>.boolean(key: String, default: Boolean = false): Boolean =
  this[key] as? Boolean ?: default

private fun Map<String, Any?>.number(key: String): Double? =
  (this[key] as? Number)?.toDouble()

private fun Map<String, Any?>.color(key: String): Color? {
  val argb = (this[key] as? Number)?.toLong()?.toInt() ?: return null
  return Color(argb)
}
