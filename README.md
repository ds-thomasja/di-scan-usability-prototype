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

`lib/components/device_card/` and `lib/components/device_modal/` are unmodified
copies of the shared Flutter components from
[`ds-thomasja/overarching`](https://github.com/ds-thomasja/overarching/tree/main/lib/components),
vendored because that repo is not a publishable package. Re-copy them from
`main` rather than editing them here; they are built against
`lightning_core_ui` v51, this prototype pins v52.

`showCaptureScanModal` (`lib/flows/capture_scan.dart`) is the prototype's own
glue: it feeds `MockData.devices` into `DeviceModal.selectDevice` for the
"Capture scan" buttons on the Patient detail and Treatment detail pages. The
device photos in `assets/devices/` are exported from the Figma frame
*DI Scan · Projects*, node `40250-121538`.

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
