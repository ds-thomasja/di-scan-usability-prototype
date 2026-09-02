# DI Scan — usability-test prototype

A password-gated, click-through Flutter web prototype covering five screens
(Home, Patient list, Patient detail, Treatment list, Treatment detail) built
with Dentsply Sirona's DS Core design system (`lightning_core_ui`), matching
the Figma reference frames. Built for a usability-testing session, not for
production use — all patient/treatment data is fictional and hardcoded in
`lib/data/mock_data.dart`.

**Live URL:** https://ds-thomasja.github.io/di-scan-usability-prototype/
**Password:** see `lib/auth/auth_state.dart` (client-side check only — not real
security, just a casual-visitor deterrent while the link is shared for testing).

## Vendored components

`lib/components/device_card/` and `lib/components/device_modal/` are copies of
the shared Flutter components from
[`ds-thomasja/overarching`](https://github.com/ds-thomasja/overarching/tree/main/lib/components),
vendored because that repo is not a publishable package. Change them upstream
and re-copy them from `main` rather than editing them here; they are built
against `lightning_core_ui` v51, this prototype pins v52.

**They have diverged.** The changes below were made here to render the
"Select device" modal's second state (see `showCaptureScanModal` below), and
have to be re-applied — or, better, ported upstream — after any re-copy:

- `DeviceCardStatus` gained `inUse` and `warning` (information- and
  warning-styled tags), and `DeviceCard` gained a `statusLabel` that overrides
  the tag copy the enum supplies, for the counted "3 warnings" tag.
- `DeviceCard` gained `selectable`. A non-selectable card is the Figma variant
  that looks like the default card except for its thumbnail, which carries
  `opacities/disabled` — deliberately *not* `enabled: false`, which dims the
  text and tags too and makes the card inert.
- `DeviceCard` gained `notification` (`DeviceCardNotification`): the Figma
  "Device card" node `5389:18149` section — a `border/subdued` rule across the
  card's full inner width, a description, and a `text/interactive` link — that
  a non-selectable card reveals when tapped.
  - This is the one structural change: the thumbnail and the tags row moved out
    of `DSSpaciousCard.imageWidget`/`.tags` into its `body`, because both of
    those slots render *beside* the content column while the notification rule
    has to span the full inner width. Chrome, hover/press/focus and keyboard
    activation still come from `DSSpaciousCard`; `DeviceCardThemeData` now
    re-derives the thumbnail's size, dimming and gaps from the same tokens.
  - The section slides open and closed with an `AnimatedSize` (380ms,
    `Curves.easeOutQuint`, `Alignment.topCenter`) copied from the
    `catalog_card` component of
    [`ds-thomasja/di-scan`](https://github.com/ds-thomasja/di-scan/tree/main/lib/components/catalog_card),
    so both cards expand at the same rate. DS v52 has no motion tokens, so the
    values are literals in both places, exported as the public
    `deviceRevealDuration`/`deviceRevealCurve`.
  - Known cost: the thumbnail is no longer boned while `isLoading`, since the
    DS bone effect is not reachable outside `lightning_core_ui`
    (`DSSkeletonizeWrapper` is `@internal`). It is hidden instead, the same way
    the battery indicator already was. Nothing in this prototype uses
    `isLoading`.
- `DeviceCard` gained `sublineMaxLines` (default `defaultSublineMaxLines`, 2 —
  the previous hardcoded cap). The detail view's cards pass `null` so their
  subline wraps freely: it is a sentence, not a serial number, and the Figma
  detail nodes give that box no line clamp. It would otherwise truncate, because
  the vendored card's thumbnail follows the DS `image.size.card` token (128)
  rather than Figma's 120, leaving the text column 8px narrower than the node's.
  `DeviceModalDevice` forwards it.
- `DeviceModal.selectDevice` gained `secondaryLabel`/`onSecondaryPressed`,
  which put a secondary button in the footer of either list mode — a
  "one-click" list (`selectable: false`) previously had no footer button at
  all. `DeviceModalDevice` forwards the new `statusLabel`, `selectable` and
  `notification`, and the modal tracks which single non-selectable card has its
  notification open.
- `DeviceModal`'s body is wrapped in an `AnimatedSize` on the same
  `deviceRevealDuration`/`deviceRevealCurve`, so growing or shrinking `devices`
  — what the "All devices" button does — slides the rows in and eases the modal
  to its new height instead of snapping.
- The switch between the two modes rides that *same* height animation and
  nothing else: heading, info row, cards and footer button all snap, the
  surface eases to fit the new mode, and the 240 details image dissolves in
  over the same reveal (`_FadeInOnMount`) because at that size appearing
  outright reads as a pop. Growing reveals the taller mode from the top down;
  shrinking closes over the outgoing one.

  Cross-fading the two modes was tried first and abandoned twice. Fading them
  simultaneously — the obvious `AnimatedSwitcher` reading — ghosts two dense
  blocks of text: headings superimposed into illegible glyphs, the device list
  showing through the details content. (It also needs a custom `layoutBuilder`,
  since the default sizes to the larger child and so makes the surface jump to
  the taller mode's height before easing.) Sequencing the fade halves in time
  fixes the ghosting but still looks unsettled, because every element then
  moves on its own schedule. Snapping the text is calmer.

  The mode switch is keyed (`ValueKey(details == null)`) so Flutter replaces
  one body with the other instead of reconciling them child by child — both
  modes build the same `_Stack`, and without the key the details image would
  never be freshly mounted and so would never dissolve.

`showCaptureScanModal` (`lib/flows/capture_scan.dart`) is the prototype's own
glue: it feeds `MockData.devices` into `DeviceModal.selectDevice` for the
"Capture scan" buttons on the Patient detail and Treatment detail pages, and
owns the "All devices" toggle between the two states of the Figma frame
*DI Scan · Projects* — node `40250-121538` (the two selectable devices) and
node `40428-152410` (all four, the non-selectable two with dimmed thumbnails).
The device photos in `assets/devices/` are exported from the former.

It also owns the switch between the modal's two views. Picking a device swaps
the list for that device's detail view, built with `DeviceModal.deviceDetails`
from the device's own `detail*` fields in `lib/data/mock_data.dart`: Figma node
`40184-46885` for the scanner (serial number, battery and status in the header;
the "Status scan" / "Treatment scan" cards, whose artwork is in
`assets/scan_modes/`) and node `40184-46884` for the PC/Laptop (status only;
the "CEREC 5.3.1" / "Connect 5.3.1" cards, which reuse the machine's own photo,
as that node does). "Switch device" returns to the list.

The detail view is where the "Capture scan" path stops. Its cards are
deliberately inert — there is no frame behind them in Figma, so they are left
non-interactive rather than made to look live and lead nowhere.

The notification copy on the two non-selectable devices in
`lib/data/mock_data.dart` is **placeholder**: the Figma node carries only
lorem-ipsum, so it was written to be plausible for a test session, not signed
off. Its link is deliberately a dead end — styled live, per the node, but with
nothing behind it.

## Running locally

```sh
flutter pub get
flutter run -d chrome
```

`lightning_core_ui` is a git dependency hosted on the internal Bitbucket
(`bitbucket.dentsplysirona.com`) — `flutter pub get` requires VPN/network access
to that host.

## Deploying an update

GitHub Actions can't build this app: a public runner has no route to the
internal Bitbucket host that `lightning_core_ui` is fetched from. Instead,
build locally and publish the compiled static site directly to the `gh-pages`
branch:

```sh
flutter build web --base-href /di-scan-usability-prototype/

git worktree add --orphan -b gh-pages-update /tmp/di-scan-gh-pages-update
cp -r build/web/. /tmp/di-scan-gh-pages-update/
touch /tmp/di-scan-gh-pages-update/.nojekyll
cd /tmp/di-scan-gh-pages-update
git add -A && git commit -m "Deploy update"
git push origin gh-pages-update:gh-pages --force
cd -
git worktree remove /tmp/di-scan-gh-pages-update
```

GitHub Pages is configured to serve from the `gh-pages` branch root.
