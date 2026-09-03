import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

/// How long a section of a device card, or of a list of them, takes to slide
/// open — and the curve it slides on.
///
/// Taken from the `catalog_card` component of the DI Scan prototype
/// (`ds-thomasja/di-scan`, `lib/components/catalog_card`), which expands its
/// own card body with exactly this `AnimatedSize`. Public, and deliberately
/// not named after any one animation, because `DeviceModal` reuses it for the
/// device list its "All devices" button grows and shrinks: every reveal in
/// this component pair moves at the same rate, from one pair of constants.
///
/// `lightning_core_ui` v52 exposes no motion tokens, so these are literals
/// here as they are in `catalog_card` — replace both sites together if a
/// duration/easing token ever lands.
const Duration deviceRevealDuration = Duration(milliseconds: 380);

/// The easing of a device reveal; see [deviceRevealDuration].
const Curve deviceRevealCurve = Curves.easeOutQuint;

/// The availability status communicated by [DeviceCard]'s built-in status tag.
enum DeviceCardStatus {
  /// The device is online. Rendered as a success-styled "Online" tag.
  online,

  /// The device is offline. Rendered as a neutral-styled "Offline" tag.
  offline,

  /// The device is busy in another session. Rendered as an
  /// information-styled "In use" tag.
  inUse,

  /// The device reports warnings. Rendered as a warning-styled "Warning" tag;
  /// pass [DeviceCard.statusLabel] to name the count ("3 warnings").
  warning,

  /// The device's calibration is outdated. Rendered as a warning-styled
  /// "Calibration outdated" tag carrying [DSIcons.warning], per the Figma
  /// "Notifikationen" device-card states.
  calibrationOutdated,

  /// The device's firmware is outdated. Rendered as an information-styled
  /// "Firmware outdated" tag carrying [DSIcons.infoCircle], per the Figma
  /// "Notifikationen" device-card states.
  firmwareOutdated,
}

/// How a [DeviceCardStatus] is presented as a DS status tag.
///
/// Exposed so widgets that compose *with* [DeviceCard] — e.g. `DeviceModal`,
/// which shows the focused device's status in its own header row rather than on
/// a card — render exactly the same tag instead of duplicating the mapping.
extension DeviceCardStatusPresentation on DeviceCardStatus {
  /// The tag label.
  ///
  /// Hardcoded English, like the rest of this component: the project has no
  /// localizations of its own yet, and DS only localizes its own strings.
  String get label => switch (this) {
        DeviceCardStatus.online => 'Online',
        DeviceCardStatus.offline => 'Offline',
        DeviceCardStatus.inUse => 'In Benutzung',
        DeviceCardStatus.warning => 'Warnung',
        DeviceCardStatus.calibrationOutdated => 'Kalibrierung veraltet',
        DeviceCardStatus.firmwareOutdated => 'Firmware veraltet',
      };

  /// The DS status tag styling.
  DSStatusTagType get tagType => switch (this) {
        DeviceCardStatus.online => DSStatusTagType.success,
        DeviceCardStatus.offline => DSStatusTagType.neutral,
        DeviceCardStatus.inUse => DSStatusTagType.information,
        DeviceCardStatus.warning => DSStatusTagType.warning,
        DeviceCardStatus.calibrationOutdated => DSStatusTagType.warning,
        DeviceCardStatus.firmwareOutdated => DSStatusTagType.information,
      };

  /// The icon rendered inline with the tag's label, or null for a text-only
  /// tag. Only the two "Notifikationen" states carry one, per the Figma node.
  DSIconRef? get icon => switch (this) {
        DeviceCardStatus.calibrationOutdated => DSIcons.warning,
        DeviceCardStatus.firmwareOutdated => DSIcons.infoCircle,
        DeviceCardStatus.online ||
        DeviceCardStatus.offline ||
        DeviceCardStatus.inUse ||
        DeviceCardStatus.warning =>
          null,
      };
}

/// The explanatory section [DeviceCard] reveals below its content.
///
/// Rendered as the Figma "Notification" frame: a `border/subdued` rule across
/// the full inner width of the card, a multi-line description, and an optional
/// link. It is what a non-selectable card shows when tapped — see
/// [DeviceCard.selectable] — but the card itself only renders what it is
/// given; when the section is shown, and what it says, is the caller's.
class DeviceCardNotification {
  /// Creates a notification section.
  const DeviceCardNotification({
    required this.description,
    this.linkText,
    this.onLinkPressed,
  });

  /// The explanatory copy. Wraps onto as many lines as it needs.
  final String description;

  /// The link below [description]. No link is rendered when null.
  final String? linkText;

  /// Called when [linkText] is pressed; the link is inert when null.
  final VoidCallback? onLinkPressed;
}

/// A selectable card summarizing a connected device: thumbnail, name,
/// serial/status line, optional battery level, and a connectivity status tag.
///
/// Built on top of [DSSpaciousCard] for its *chrome*, which already
/// implements everything a card needs to behave like the rest of the DS:
/// token-driven background/border/shadow per `DSClickableState`, keyboard
/// activation (Enter/Space), and mouse hover/press/focus visuals.
///
/// The card's whole inner layout, on the other hand, is supplied through
/// `DSSpaciousCard.body`: the thumbnail, the name/subline/battery block, the
/// status tag and the [DeviceCardNotification] section. The thumbnail and
/// tags are *not* handed to `DSSpaciousCard.imageWidget`/`.tags`, even though
/// those slots exist, because both render beside — and so indent — the
/// content column, while the notification's rule has to span the card's full
/// inner width. Owning the row is what buys that, at the cost of
/// re-deriving three things `DSSpaciousCard` would otherwise have supplied:
/// the thumbnail's `image.size.card` size, its `opacities/disabled` dimming
/// (which this card needs per-variant anyway — see [selectable]) and the
/// `spacing/component` gaps around both, all of which
/// [DeviceCardThemeData] now reads from the same tokens the DS card does.
///
/// ## Relationship to the Figma source of truth
///
/// The design lives in Figma "Equipment-Components", node `4837:19131`. Where
/// that node and [DSSpaciousCard] disagree on card *chrome*, this widget
/// follows [DSSpaciousCard] (and therefore the current DS tokens) rather than
/// re-implementing the chrome by hand:
///
/// - Content padding: Figma shows `spacing/component/m` (16), DS uses
///   `spacing.layout.m` (24 on non-small form factors).
/// - Thumbnail size: Figma shows 120x120, DS uses `image.size.card`
///   (128 on non-small, 64 on small).
///
/// The notification section is the exception, and is reproduced from Figma
/// "Device card", node `5389:18149`, token for token: a `border/subdued` rule
/// at `border/width/standard`, `spacing/component/m` above and below it,
/// `spacing/component/xs` of side padding, a `textBase` description in
/// `text/standard`, and a `textAction` link in `text/interactive`.
///
/// Everything the card *content* controls does follow the Figma node exactly,
/// including the thumbnail's `border/radius/small` corner (which deliberately
/// differs from the card's own `border/radius/standard`).
class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.name,
    this.subline,
    this.thumbnail,
    this.batteryPercent,
    this.lowBatteryThreshold = 30,
    this.status = DeviceCardStatus.online,
    this.statusLabel,
    this.sublineMaxLines = defaultSublineMaxLines,
    this.selected = false,
    this.selectable = true,
    this.enabled = true,
    this.isLoading = false,
    this.notification,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.width = 438,
  });

  /// Primary device name/title.
  final String name;

  /// Secondary line, e.g. a serial number ("SN:865562").
  final String? subline;

  /// How many lines [subline] may occupy before it is truncated with an
  /// ellipsis, or null to let it wrap onto as many lines as it needs.
  ///
  /// Defaults to [defaultSublineMaxLines], which is what the Figma "Device
  /// card" node shows: its subline is a serial number, so two lines is
  /// generous. Cards whose subline is a sentence — the ones the Figma device
  /// *detail* nodes list below the device photo, whose subline box carries no
  /// line clamp and grows instead — pass null.
  ///
  /// A battery indicator that does not fit inline may still add one line on
  /// top of this budget; see [_SublineRow].
  final int? sublineMaxLines;

  /// Widget rendered in the thumbnail slot. Falls back to a plain placeholder
  /// box when omitted.
  final Widget? thumbnail;

  /// Battery level 0-100. The battery indicator is hidden when null.
  ///
  /// Forwarded verbatim to [DSBatteryIndicator.batteryLevel], which asserts
  /// the 0-100 range.
  final int? batteryPercent;

  /// At or below this battery level the battery indicator switches to the
  /// critical icon color.
  ///
  /// Forwarded to [DSBatteryIndicator.lowLevelThreshold]; the default of 30
  /// mirrors that widget's own default.
  final int lowBatteryThreshold;

  /// The availability status shown as a tag below the subline/battery row.
  /// `null` hides the tag entirely.
  final DeviceCardStatus? status;

  /// Replaces the tag text that [status] would otherwise supply, keeping its
  /// styling. Meant for statuses whose copy carries data the enum cannot —
  /// e.g. [DeviceCardStatus.warning] rendered as "3 warnings".
  ///
  /// Ignored when [status] is `null`, which renders no tag at all.
  final String? statusLabel;

  final bool selected;

  /// Whether this device can be picked.
  ///
  /// A non-selectable card is the Figma variant that looks like the default
  /// card except for its thumbnail, which carries `opacities/disabled`. It is
  /// deliberately *not* the same as `enabled: false`: the card keeps its
  /// standard text colors, its full-opacity tags and its whole interactive
  /// chrome, because tapping it is what reveals the [notification] explaining
  /// why it cannot be picked. [selected] is ignored while this is false.
  ///
  /// Ignored when [enabled] is false, which dims the card as a whole.
  final bool selectable;

  final bool enabled;

  /// Puts the card into its loading state and disables interaction.
  ///
  /// This does **not** swap in a separate placeholder layout. The real content
  /// tree is built either way; [DSSkeletonizer] merely publishes the ambient
  /// skeleton flag, and each skeleton-aware DS widget below renders itself as
  /// a bone whose shape is derived from the content it was actually given.
  ///
  /// The practical consequence is that whatever [name] and [subline] the
  /// caller passes while loading determines the bone widths, so callers should
  /// pass representative placeholder (or last-known) strings rather than empty
  /// ones.
  ///
  /// Two parts of the card are not covered by that mechanism, and are instead
  /// suppressed outright while loading:
  ///
  /// - The tags row, matching the Figma "Disabled + loading" variant, which
  ///   renders no tags row at all.
  /// - The battery indicator: [DSBatteryIndicator] is not skeleton-aware in
  ///   `lightning_core_ui` v51.0.0 — it neither wraps itself in the DS
  ///   skeleton wrapper nor is listed among `DSSkeletonizer`'s supported
  ///   widgets — so left alone it would keep rendering as sharp, real content
  ///   (icon and percentage) next to the skeleton bones around it. This card
  ///   works around that package gap by hiding the battery indicator outright
  ///   while loading, the same way the tags row is hidden, rather than
  ///   showing a mismatched mix of real and skeleton content.
  ///
  /// - The thumbnail. It used to be boned for free by
  ///   `DSSpaciousCard.imageWidget`, but that slot renders beside the content
  ///   column, and the Figma [notification] section has to span the card's
  ///   full inner width — so the thumbnail moved into the content column,
  ///   which the DS card does not bone. The DS bone effect itself is not
  ///   reachable from outside `lightning_core_ui` (`DSSkeletonizeWrapper` is
  ///   `@internal`), so rather than paint an off-token imitation the
  ///   thumbnail is hidden the same way the battery indicator is, leaving its
  ///   empty `surface/subdued` slot.
  /// - The [notification] section, which is not part of the loading state at
  ///   all.
  final bool isLoading;

  /// Card is non-interactive (no hover/press/focus visuals, not keyboard
  /// activatable) when null.
  final VoidCallback? onTap;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The fixed card width from the Figma node.
  final double width;

  /// The section revealed below the card's content, across its full inner
  /// width. Hidden when null, and suppressed entirely while [isLoading].
  ///
  /// See [DeviceCardNotification], and [selectable] for what it is for.
  final DeviceCardNotification? notification;

  bool get _interactive => enabled && !isLoading && onTap != null;

  /// Whether the thumbnail carries `opacities/disabled`.
  ///
  /// Both the disabled and the non-selectable variant dim it; only the
  /// disabled one dims everything else too.
  bool get _thumbnailDimmed => !enabled || !selectable;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);
    final theme = DeviceCardThemeData(tokens);
    final status = this.status;

    final notification = isLoading ? null : this.notification;

    // Everything inside the card's padding, in one slot.
    //
    // The thumbnail and the tags row are laid out here rather than handed to
    // `DSSpaciousCard.imageWidget`/`.tags`, both of which live *beside*, and
    // therefore indent, the content column. The Figma node's notification
    // rule spans the card's full inner width, so the row above it has to be
    // this slot's own child. Card chrome, hover/press/focus visuals and
    // keyboard activation all still come from `DSSpaciousCard`, which is the
    // part worth not re-implementing — see [DeviceCard]'s class doc.
    final card = DSSpaciousCard(
      // Animates the card's height whenever the notification section comes or
      // goes, growing downwards from the content row, which stays put — the
      // "slide open" of the sibling `catalog_card` component, at the same
      // duration and easing. See [deviceRevealDuration].
      //
      // AnimatedSize clips to its animating box (`Clip.hardEdge` by default),
      // so the section is revealed rather than spilling out of the card while
      // it grows. It does not animate its first layout, so a card built with
      // its notification already open simply starts open.
      body: AnimatedSize(
        duration: deviceRevealDuration,
        curve: deviceRevealCurve,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _Thumbnail(
                  // Hidden while loading: see [isLoading].
                  thumbnail: isLoading ? null : thumbnail,
                  dimmed: _thumbnailDimmed,
                  theme: theme,
                ),
                SizedBox(width: theme.thumbnailGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // `DSText` opts into skeleton mode on its own, so while
                      // [isLoading] the name and subline render as bones whose
                      // width and height are derived from the text and text
                      // style actually passed in — which is how the DS skeleton
                      // mechanism is meant to be driven. See [isLoading].
                      _DeviceCardBody(
                        name: name,
                        subline: subline,
                        sublineMaxLines: sublineMaxLines,
                        batteryPercent: batteryPercent,
                        lowBatteryThreshold: lowBatteryThreshold,
                        enabled: enabled,
                        isLoading: isLoading,
                        theme: theme,
                      ),
                      // The Figma node renders no tags row at all while loading.
                      if (!isLoading && status != null)
                        Padding(
                          padding: EdgeInsets.only(top: theme.tagsTopGap),
                          // Per Figma the whole tags row carries its own
                          // `opacities/disabled`, independently of the
                          // text-color swap applied to the name/subline. With a
                          // single tag, dimming the tag is equivalent to
                          // dimming the row.
                          child: Opacity(
                            opacity: enabled ? 1 : theme.disabledOpacity,
                            child: DSTag.status(
                              text: statusLabel ?? status.label,
                              icon: status.icon,
                              statusType: status.tagType,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (notification != null) ...[
              SizedBox(height: theme.notificationTopGap),
              _Notification(notification: notification, theme: theme),
            ],
          ],
        ),
      ),
      // Never in the selected state when the device cannot be picked.
      selected: selected && selectable,
      focusNode: focusNode,
      autofocus: autofocus,
      onPressed: _interactive ? onTap : null,
    );

    return Semantics(
      // Exposed unconditionally so assistive tech reports the correct role,
      // enabled and selected state even when the card is currently
      // non-interactive (e.g. disabled or still loading).
      button: true,
      enabled: enabled,
      selected: selectable ? selected : null,
      child: SizedBox(
        width: width,
        // The single mechanism that produces the loading state: it publishes
        // the ambient skeleton flag that every skeleton-aware DS widget in
        // the card below reads. There is deliberately no parallel, hand-built
        // placeholder tree. See [isLoading].
        child: DSSkeletonizer(enabled: isLoading, child: card),
      ),
    );
  }
}

/// Content-level design tokens for [DeviceCard].
///
/// The outer card chrome (background, border, two-layer `shadows.elevation1`,
/// hover/press/focus visuals, keyboard activation) is entirely supplied by
/// [DSSpaciousCard]; this theme only covers the content DSSpaciousCard has no
/// opinion about. It follows the same token-derivation convention used by the
/// DS package's internal `*ThemeData` classes (e.g. `DSCheckboxThemeData`): a
/// plain class whose fields are computed once from [DSTokensData] in the
/// constructor.
class DeviceCardThemeData {
  DeviceCardThemeData(DSTokensData d)
      : nameTextStyle = d.text.textBaseStrong,
        sublineTextStyle = d.text.textBase,
        textColorStandard = d.text.standard,
        textColorDisabled = d.text.disabled,
        disabledOpacity = d.opacities.disabled,
        dividerWidth = d.spacing.component.m,
        sublineRowRunSpacing = d.spacing.component.xxs,
        thumbnailBorderRadius = BorderRadius.circular(d.border.radius.small),
        thumbnailSize = Size.square(d.image.size.card),
        thumbnailPlaceholderColor = d.surface.subdued,
        thumbnailGap = d.spacing.component.m,
        tagsTopGap = d.spacing.component.xs,
        notificationTopGap = d.spacing.component.m,
        notificationBorderSide = BorderSide(
          color: d.border.subdued,
          width: d.border.width.standard,
        ),
        notificationPadding = EdgeInsets.only(
          top: d.spacing.component.m,
          left: d.spacing.component.xs,
          right: d.spacing.component.xs,
        ),
        notificationLinkGap = d.spacing.component.xxs,
        notificationTextStyle =
            d.text.textBase.copyWith(color: d.text.standard);

  /// Text style for the device name.
  final TextStyle nameTextStyle;

  /// Text style for the subline (e.g. serial number).
  final TextStyle sublineTextStyle;

  /// Text color used when the card is enabled.
  final Color textColorStandard;

  /// Text color used when the card is disabled.
  final Color textColorDisabled;

  /// Opacity applied to the battery indicator group and the tags row when the
  /// card is disabled.
  ///
  /// [DSBatteryIndicator] has no disabled state of its own, so this card
  /// applies the token as a group opacity around it.
  final double disabledOpacity;

  /// Total width of the "·" divider between the subline and the battery
  /// indicator. The glyph is centered inside it.
  final double dividerWidth;

  /// Vertical gap between the two lines of the subline row when the battery
  /// indicator wraps onto its own line.
  final double sublineRowRunSpacing;

  /// Corner radius of the thumbnail, in every state including loading.
  ///
  /// Deliberately `border/radius/small`, smaller than the card's own
  /// `border/radius/standard`, per the Figma node.
  ///
  /// A static Figma "loading" frame shows the thumbnail placeholder at
  /// `border/radius/standard` instead. That is not reproduced here: the DS
  /// skeleton mechanism derives bones from the real content, so the real
  /// component keeps its own radius while loading. Real component behavior
  /// wins over the static mockup.
  final BorderRadius thumbnailBorderRadius;

  /// The thumbnail slot's side length (`image.size.card`, 128 on non-small
  /// form factors and 64 on small).
  ///
  /// Read from the same token `DSSpaciousCard` sizes its own image slot from,
  /// so moving the thumbnail into the content column did not change its size.
  /// The Figma node specifies a fixed 120; the DS token wins here, as it did
  /// before the move.
  final Size thumbnailSize;

  /// Fills the thumbnail slot when there is no thumbnail to show.
  final Color thumbnailPlaceholderColor;

  /// Gap between the thumbnail and the name/subline column
  /// (`spacing/component/m`, 16) — the same gap `DSSpaciousCard` applied as
  /// its `contentWithImagePadding`.
  final double thumbnailGap;

  /// Gap above the tags row (`spacing/component/xs`, 8) — the same gap
  /// `DSSpaciousCard` applied as its `tagsPadding`.
  final double tagsTopGap;

  /// Gap between the card's content row and the notification rule
  /// (`spacing/component/m`, 16).
  final double notificationTopGap;

  /// The notification section's top rule (`border/subdued`,
  /// `border/width/standard`).
  final BorderSide notificationBorderSide;

  /// Padding inside the notification section, below its rule: 16 above, and
  /// `spacing/component/xs` (8) on each side, per the Figma node.
  final EdgeInsets notificationPadding;

  /// Gap between the notification's description and its link
  /// (`spacing/component/xxs`, 4).
  final double notificationLinkGap;

  /// Text style of the notification's description (`textBase` in
  /// `text/standard`).
  final TextStyle notificationTextStyle;
}

/// The card's thumbnail slot.
///
/// Carries `opacities/disabled` when [dimmed] — the only difference between
/// the default card and the non-selectable variant. See
/// [DeviceCard.selectable].
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.thumbnail,
    required this.dimmed,
    required this.theme,
  });

  final Widget? thumbnail;
  final bool dimmed;
  final DeviceCardThemeData theme;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: theme.thumbnailSize,
    // Decorative: the thumbnail conveys no information beyond what the
    // name and subline already state, so it is excluded from the
    // semantics tree rather than announced as an unlabeled image.
    child: ExcludeSemantics(
      child: ClipRRect(
        // Deliberately the smaller `border/radius/small`, per the Figma
        // node; see [DeviceCardThemeData.thumbnailBorderRadius].
        borderRadius: theme.thumbnailBorderRadius,
        child: Opacity(
          opacity: dimmed ? theme.disabledOpacity : 1,
          child:
              thumbnail ?? ColoredBox(color: theme.thumbnailPlaceholderColor),
        ),
      ),
    ),
  );
}

/// The Figma "Notification" frame: a rule across the card's full inner width,
/// a description, and an optional link.
class _Notification extends StatelessWidget {
  const _Notification({required this.notification, required this.theme});

  final DeviceCardNotification notification;
  final DeviceCardThemeData theme;

  @override
  Widget build(BuildContext context) {
    final linkText = notification.linkText;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: theme.notificationBorderSide),
      ),
      padding: theme.notificationPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unlike the card's name, the description is explicitly multi-line
          // in the Figma node, so it wraps instead of truncating.
          DSText(
            notification.description,
            style: theme.notificationTextStyle,
            maxLines: null,
            overflow: null,
          ),
          if (linkText != null) ...[
            SizedBox(height: theme.notificationLinkGap),
            // DSLinkWidget supplies `textAction` in `text/interactive`, which
            // is exactly what the node specifies, plus the DS link's own
            // hover/focus treatment.
            DSLinkWidget(text: linkText, onPressed: notification.onLinkPressed),
          ],
        ],
      ),
    );
  }
}

class _DeviceCardBody extends StatelessWidget {
  const _DeviceCardBody({
    required this.name,
    required this.subline,
    required this.sublineMaxLines,
    required this.batteryPercent,
    required this.lowBatteryThreshold,
    required this.enabled,
    required this.isLoading,
    required this.theme,
  });

  final String name;
  final String? subline;
  final int? sublineMaxLines;
  final int? batteryPercent;
  final int lowBatteryThreshold;
  final bool enabled;
  final bool isLoading;
  final DeviceCardThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Per Figma the name and subline swap to `text/disabled` when the card is
    // disabled, whereas the battery group and the tags row instead keep their
    // standard colors under a group opacity.
    final textColor =
        enabled ? theme.textColorStandard : theme.textColorDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The name is the one text in this card that Figma does mark as
        // truncating (`overflow-hidden text-ellipsis whitespace-nowrap`),
        // which is DSText's default behavior.
        DSText(name, style: theme.nameTextStyle.copyWith(color: textColor)),
        _SublineRow(
          subline: subline,
          maxLines: sublineMaxLines,
          // Hidden while loading: see [DeviceCard.isLoading].
          batteryPercent: isLoading ? null : batteryPercent,
          lowBatteryThreshold: lowBatteryThreshold,
          textColor: textColor,
          enabled: enabled,
          theme: theme,
        ),
      ],
    );
  }
}

/// The default number of lines the subline text may occupy before it is
/// truncated with an ellipsis; see [DeviceCard.sublineMaxLines], which
/// overrides it per card.
///
/// The battery indicator may add one more line on top of this budget; see
/// [_SublineRow].
const int defaultSublineMaxLines = 2;

/// The glyph separating the subline from an inline battery indicator.
const String _dividerGlyph = '·';

/// The ellipsis [DSText] renders for a truncated subline, mirrored here so the
/// measured last line matches the painted one.
///
/// This is the same character [RenderParagraph] uses for
/// [TextOverflow.ellipsis].
const String _ellipsis = '…';

/// Slack, in logical pixels, allowed when deciding whether the divider plus
/// the battery indicator still fit on the subline's last line.
///
/// Absorbs floating point noise from text measurement only; it is far below
/// one device pixel.
const double _inlineFitTolerance = 0.01;

/// The subline and the battery indicator, laid out as a single text flow.
///
/// The rules, in the order they apply:
///
/// - The subline wraps onto at most [_sublineMaxLines] lines. A subline that
///   would need a third line is truncated with a trailing ellipsis at the end
///   of line 2 — standard [DSText] `maxLines`/[TextOverflow.ellipsis]
///   semantics, which also gives the full string a hover tooltip.
/// - The "· + battery indicator" unit is an *inline trailing element*, but
///   only next to the subline's **first** line: if the subline is short
///   enough to fit on one line, the unit attaches to the end of it when there
///   is room. A subline that has already wrapped onto a second line never
///   gets an inline battery next to that second line, even if there would be
///   room — the battery always moves below in that case.
/// - Whenever the unit does not attach inline (no room on a single-line
///   subline, or the subline wrapped at all), the battery indicator alone
///   moves to one additional line below (a third line when the subline used
///   two), and the divider is not rendered at all — the divider only ever
///   separates the battery from subline text *on the same line*.
/// - The subline's two-line budget is independent of that decision: it is laid
///   out at the full available width either way, so bumping the battery onto
///   its own line never shortens the text. This is also why the whole thing is
///   not one `Text.rich` flow with a single `maxLines` cap: text lines fill
///   greedily, so no single cap can express "two lines for the subline, plus
///   one more only for the battery".
/// - With no subline the battery renders alone and, having nothing to be
///   divided from, without the divider.
///
/// This is implemented as a small render object ([_SublineFlow]) because the
/// inline-versus-own-line decision needs two measurements in the same layout
/// pass, before anything is positioned:
///
/// - the subline's *last line* geometry, which comes from a [TextPainter]
///   configured exactly like the [DSText] that paints the subline;
/// - the battery indicator's *real* width, which comes from laying out the
///   actual [DSBatteryIndicator] child. It cannot be derived from public DS
///   API — `DSBatteryIndicatorThemeData` (icon box, icon/text gap, percentage
///   text style) is `@internal` — and measuring the real widget keeps this
///   card correct if those internals change.
///
/// A [Wrap] (what this row used before) can make the inline-versus-own-line
/// decision on its own, but cannot drop the divider when the unit wraps, and
/// treats the subline as one unbreakable block rather than letting it wrap.
class _SublineRow extends StatelessWidget {
  const _SublineRow({
    required this.subline,
    required this.maxLines,
    required this.batteryPercent,
    required this.lowBatteryThreshold,
    required this.textColor,
    required this.enabled,
    required this.theme,
  });

  final String? subline;

  /// Forwarded to [DeviceCard.sublineMaxLines].
  final int? maxLines;

  final int? batteryPercent;
  final int lowBatteryThreshold;
  final Color textColor;
  final bool enabled;
  final DeviceCardThemeData theme;

  @override
  Widget build(BuildContext context) {
    final subline = this.subline;
    final batteryPercent = this.batteryPercent;
    if (subline == null && batteryPercent == null) {
      return const SizedBox.shrink();
    }

    final sublineStyle = theme.sublineTextStyle.copyWith(color: textColor);
    // What the `Text` inside `DSText` will actually resolve the style to: an
    // inheriting style is merged onto the ambient DefaultTextStyle (which
    // DSSpaciousCard installs around its body). Resolving it here keeps the
    // measured text metrics identical to the painted ones, and gives the
    // directly painted divider the same treatment the `Text` widget it
    // replaced used to get.
    final resolvedSublineStyle = sublineStyle.inherit
        ? DefaultTextStyle.of(context).style.merge(sublineStyle)
        : sublineStyle;

    return _SublineFlow(
      subline: subline,
      sublineMaxLines: maxLines,
      sublineStyle: resolvedSublineStyle,
      // Figma gives the divider a fixed 16px box with the glyph centered
      // inside, rather than padding around the glyph.
      dividerWidth: theme.dividerWidth,
      // Figma specifies a `4px 0px` gap: the horizontal separation is already
      // provided by the divider box, so only the run spacing is non-zero.
      runSpacing: theme.sublineRowRunSpacing,
      textScaler: MediaQuery.textScalerOf(context),
      battery: batteryPercent == null
          ? null
          // Figma applies `opacities/disabled` to this group as its own group
          // opacity rather than swapping the icon/text colors, so the
          // low-battery warning color stays recognizable while dimmed.
          // DSBatteryIndicator exposes no disabled state, so the opacity is
          // applied around it.
          : Opacity(
              opacity: enabled ? 1 : theme.disabledOpacity,
              child: DSBatteryIndicator(
                batteryLevel: batteryPercent,
                lowLevelThreshold: lowBatteryThreshold,
              ),
            ),
    );
  }
}

/// The two children [_SublineFlow] positions.
///
/// The divider is deliberately not among them: it is painted directly by
/// [_RenderSublineFlow], which is both how it can be omitted entirely (rather
/// than merely hidden) when the battery is not inline, and how it stays out of
/// the semantics tree — it is a decorative separator that assistive tech
/// should not announce.
enum _SublineSlot { subline, battery }

/// Lays out the subline text and the battery indicator per the rules
/// documented on [_SublineRow].
class _SublineFlow
    extends SlottedMultiChildRenderObjectWidget<_SublineSlot, RenderBox> {
  const _SublineFlow({
    required this.subline,
    required this.sublineMaxLines,
    required this.sublineStyle,
    required this.battery,
    required this.dividerWidth,
    required this.runSpacing,
    required this.textScaler,
  });

  /// The subline text, or null when the battery renders on its own.
  final String? subline;

  /// Forwarded to [DeviceCard.sublineMaxLines].
  final int? sublineMaxLines;

  /// The style [subline] is painted with, already resolved against the ambient
  /// [DefaultTextStyle].
  ///
  /// Also used for the divider glyph, which Figma renders in the same style.
  final TextStyle sublineStyle;

  /// The battery indicator, or null when it is hidden (no battery level, or
  /// the card is loading).
  final Widget? battery;

  /// Total width of the fixed box the divider glyph is centered in.
  final double dividerWidth;

  /// Vertical gap between the subline block and a battery indicator that did
  /// not fit inline.
  final double runSpacing;

  /// The ambient text scaler, forwarded so measurement matches what [DSText]
  /// renders.
  final TextScaler textScaler;

  /// The span used to measure [subline]; kept in sync with the [DSText] built
  /// in [childForSlot] by deriving both from the same two fields.
  TextSpan? get _sublineSpan {
    final subline = this.subline;
    return subline == null
        ? null
        : TextSpan(text: subline, style: sublineStyle);
  }

  TextSpan get _dividerSpan =>
      TextSpan(text: _dividerGlyph, style: sublineStyle);

  @override
  Iterable<_SublineSlot> get slots => _SublineSlot.values;

  @override
  Widget? childForSlot(_SublineSlot slot) {
    final subline = this.subline;
    return switch (slot) {
      _SublineSlot.subline => subline == null
          ? null
          : DSText(
              subline,
              style: sublineStyle,
              maxLines: sublineMaxLines,
              // `DSText` defaults `overflow` to ellipsis, which an uncapped
              // subline has nothing to apply it to but would still hand the
              // painter — the same pairing [_Notification] spells out for its
              // own free-wrapping description.
              overflow: sublineMaxLines == null
                  ? null
                  : TextOverflow.ellipsis,
            ),
      _SublineSlot.battery => battery,
    };
  }

  @override
  _RenderSublineFlow createRenderObject(BuildContext context) =>
      _RenderSublineFlow(
        sublineSpan: _sublineSpan,
        sublineMaxLines: sublineMaxLines,
        dividerSpan: _dividerSpan,
        dividerWidth: dividerWidth,
        runSpacing: runSpacing,
        textScaler: textScaler,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSublineFlow renderObject,
  ) {
    renderObject
      ..sublineSpan = _sublineSpan
      ..sublineMaxLines = sublineMaxLines
      ..dividerSpan = _dividerSpan
      ..dividerWidth = dividerWidth
      ..runSpacing = runSpacing
      ..textScaler = textScaler;
  }
}

/// The result of one [_RenderSublineFlow] layout pass.
///
/// Offsets are relative to the render object's top left corner. A null
/// [dividerOffset] means the divider is not painted at all for this layout.
class _SublineGeometry {
  const _SublineGeometry({
    required this.size,
    this.sublineOffset = Offset.zero,
    this.batteryOffset = Offset.zero,
    this.dividerOffset,
  });

  final Size size;
  final Offset sublineOffset;
  final Offset batteryOffset;
  final Offset? dividerOffset;
}

/// Implements the layout described on [_SublineRow].
class _RenderSublineFlow extends RenderBox
    with SlottedContainerRenderObjectMixin<_SublineSlot, RenderBox> {
  _RenderSublineFlow({
    required this._sublineSpan,
    required this._sublineMaxLines,
    required this._dividerSpan,
    required this._dividerWidth,
    required this._runSpacing,
    required this._textScaler,
  }) {
    _applySublineMaxLines();
  }

  /// Measures — but never paints — the subline, to learn where its last line
  /// ends and how tall that line is.
  ///
  /// Configured to match the `Text` that [DSText] paints: left-to-right,
  /// start-aligned, and capped at [_sublineMaxLines] with an ellipsis — see
  /// [_applySublineMaxLines], which keeps the cap in sync. The left-to-right
  /// assumption mirrors [DSText]'s own internal measurement, which is likewise
  /// hard-coded to it.
  final TextPainter _sublinePainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// Paints the divider glyph. See [_SublineSlot] for why it is not a child.
  final TextPainter _dividerPainter =
      TextPainter(textDirection: TextDirection.ltr);

  Offset? _dividerOffset;

  TextSpan? _sublineSpan;
  set sublineSpan(TextSpan? value) {
    if (_sublineSpan == value) return;
    _sublineSpan = value;
    markNeedsLayout();
  }

  /// The line cap, mirrored onto [_sublinePainter] so the measured last line
  /// matches the painted one.
  ///
  /// An uncapped subline never truncates, so the painter is given no ellipsis
  /// either — `TextPainter` would otherwise have nothing to apply it to, but
  /// stating both together keeps the two in step.
  int? _sublineMaxLines;
  set sublineMaxLines(int? value) {
    if (_sublineMaxLines == value) return;
    _sublineMaxLines = value;
    _applySublineMaxLines();
    markNeedsLayout();
  }

  void _applySublineMaxLines() {
    _sublinePainter
      ..maxLines = _sublineMaxLines
      ..ellipsis = _sublineMaxLines == null ? null : _ellipsis;
  }

  TextSpan _dividerSpan;
  set dividerSpan(TextSpan value) {
    if (_dividerSpan == value) return;
    _dividerSpan = value;
    markNeedsLayout();
  }

  double _dividerWidth;
  set dividerWidth(double value) {
    if (_dividerWidth == value) return;
    _dividerWidth = value;
    markNeedsLayout();
  }

  double _runSpacing;
  set runSpacing(double value) {
    if (_runSpacing == value) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  TextScaler _textScaler;
  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    markNeedsLayout();
  }

  RenderBox? get _sublineChild => childForSlot(_SublineSlot.subline);

  RenderBox? get _batteryChild => childForSlot(_SublineSlot.battery);

  /// Paint order, which is also the order the children are visited in for
  /// semantics. Hit testing walks it in reverse.
  @override
  Iterable<RenderBox> get children => [
        ?_sublineChild,
        ?_batteryChild,
      ];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void dispose() {
    _sublinePainter.dispose();
    _dividerPainter.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    final geometry = _computeGeometry(constraints, dry: false);
    size = geometry.size;
    _offsetOf(_sublineChild)?.offset = geometry.sublineOffset;
    _offsetOf(_batteryChild)?.offset = geometry.batteryOffset;
    _dividerOffset = geometry.dividerOffset;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _computeGeometry(constraints, dry: true).size;

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
        _sublineChild?.getMinIntrinsicWidth(height) ?? 0,
        _batteryChild?.getMinIntrinsicWidth(height) ?? 0,
      );

  @override
  double computeMaxIntrinsicWidth(double height) {
    final subline = _sublineChild?.getMaxIntrinsicWidth(height);
    final battery = _batteryChild?.getMaxIntrinsicWidth(height);
    if (subline == null || battery == null) {
      return subline ?? battery ?? 0;
    }
    // Widest sensible layout: the whole subline on one line, with the divider
    // and the battery indicator inline behind it.
    return subline + _dividerWidth + battery;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _computeGeometry(BoxConstraints(maxWidth: width), dry: true).size.height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  BoxParentData? _offsetOf(RenderBox? child) =>
      child?.parentData as BoxParentData?;

  _SublineGeometry _computeGeometry(
    BoxConstraints constraints, {
    required bool dry,
  }) {
    final maxWidth = constraints.maxWidth;
    final childConstraints = BoxConstraints(maxWidth: maxWidth);
    Size measure(RenderBox child) => dry
        ? child.getDryLayout(childConstraints)
        : (child..layout(childConstraints, parentUsesSize: true)).size;

    final subline = _sublineChild;
    final battery = _batteryChild;
    final sublineSize = subline == null ? null : measure(subline);
    final batterySize = battery == null ? null : measure(battery);

    if (batterySize == null) {
      return _SublineGeometry(
        size: constraints.constrain(sublineSize ?? Size.zero),
      );
    }
    if (sublineSize == null) {
      // The battery renders alone: no subline means nothing to divide it from,
      // so no divider either.
      return _SublineGeometry(size: constraints.constrain(batterySize));
    }

    _sublinePainter
      ..text = _sublineSpan ?? const TextSpan(text: '')
      ..textScaler = _textScaler
      ..layout(maxWidth: maxWidth);
    // Guards against a painter/child disagreement (e.g. a skeleton bone
    // standing in for the text) clipping the block.
    final textHeight = math.max(sublineSize.height, _sublinePainter.height);

    final lines = _sublinePainter.computeLineMetrics();
    final lastLine = lines.isEmpty ? null : lines.last;
    final lastLineEnd = lastLine == null ? 0.0 : lastLine.left + lastLine.width;
    final lastLineBaseline = lastLine?.baseline ??
        _sublinePainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    // Inline placement is only attempted next to the subline's first line.
    // A subline that has already wrapped onto a second line always puts the
    // battery on its own line below, even if that second line has room.
    final fitsInline = lines.length <= 1 &&
        lastLineEnd + _dividerWidth + batterySize.width <=
            maxWidth + _inlineFitTolerance;

    if (!fitsInline) {
      // One extra line below everything the subline used, battery only.
      return _SublineGeometry(
        size: constraints.constrain(Size(
          math.max(sublineSize.width, batterySize.width),
          textHeight + _runSpacing + batterySize.height,
        )),
        batteryOffset: Offset(0, textHeight + _runSpacing),
      );
    }

    // Centered on the last line rather than on the whole text block, so a
    // wrapped subline keeps the indicator next to the line it belongs to.
    final lastLineTop =
        lastLine == null ? 0.0 : lastLine.baseline - lastLine.ascent;
    final lastLineBottom = lastLine == null
        ? textHeight
        : lastLine.baseline + lastLine.descent;
    final batteryLeft = lastLineEnd + _dividerWidth;
    final batteryTop = (lastLineTop + lastLineBottom - batterySize.height) / 2;
    // An indicator taller than the line it sits on pushes the whole block
    // down instead of being clipped at the top. On a single-line subline this
    // reproduces the vertical centering the previous [Wrap] produced.
    final shift = math.max(0.0, -batteryTop);

    _dividerPainter
      ..text = _dividerSpan
      ..textScaler = _textScaler
      ..layout();
    final dividerBaseline =
        _dividerPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    return _SublineGeometry(
      size: constraints.constrain(Size(
        math.max(sublineSize.width, batteryLeft + batterySize.width),
        math.max(textHeight, batteryTop + batterySize.height) + shift,
      )),
      sublineOffset: Offset(0, shift),
      batteryOffset: Offset(batteryLeft, batteryTop + shift),
      dividerOffset: Offset(
        // Centered in its fixed-width box, and sharing the last line's
        // baseline since it is set in the subline's own style.
        lastLineEnd + (_dividerWidth - _dividerPainter.width) / 2,
        lastLineBaseline - dividerBaseline + shift,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final subline = _sublineChild;
    if (subline != null) {
      context.paintChild(subline, offset + _offsetOf(subline)!.offset);
    }
    final dividerOffset = _dividerOffset;
    if (dividerOffset != null) {
      _dividerPainter.paint(context.canvas, offset + dividerOffset);
    }
    final battery = _batteryChild;
    if (battery != null) {
      context.paintChild(battery, offset + _offsetOf(battery)!.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in children.toList().reversed) {
      final childOffset = _offsetOf(child)!.offset;
      final hit = result.addWithPaintOffset(
        offset: childOffset,
        position: position,
        hitTest: (result, transformed) =>
            child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }
}
