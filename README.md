# Den

![Den](preview.png)

A Windows-style overflow flyout for the [Omarchy](https://omarchy.org) shell
bar. Clicking the chevron drops down a compact grid of icon tiles holding
every tray app that isn't pinned on the stock tray, plus any bar plugins
tucked away inside. Strictly a declutter tool — Den never enables, disables,
or removes anything.

## Why

New tray apps and plugin widgets pile up on the bar. Den gives them one home:
unpinned tray apps appear automatically, and any bar widget can be dragged in
— leaving your bar minimal and your overflow one click away.

## Local fork: Omarchy 4.0.3 compatibility

This fork restores tucked widgets on Omarchy 4.0.3-1.

The stock bar now injects a scoped `PluginBarApi`, without the widget registry,
full shell config, or drag state that Den used. Den locates the host through a
built-in sibling widget in the same visual tree. This is an internal compatibility
bridge, **not a supported public API**: Den itself gains access to the real bar
and shell, just as on older versions. It requires the stock bar and a mounted
built-in sibling widget; future Omarchy releases may need another adaptation.
Other third-party widgets mounted inside Den receive a scoped `DrawerBarApi`
owned by their drawer slot. These facades are outside the stock visible-slot
cache, so layout-triggered `prunePluginBarApis()` does not destroy them. They
retain per-plugin shell access and mirror the host presentation/popout state.
No packaged Omarchy files are modified.

The local installation is a symlink:
`~/.config/omarchy/plugins/so.den -> /home/nero/Work/so.den`.
Edit this checkout, then run `omarchy-shell shell rescanPlugins` or
`omarchy restart shell` if the symlinked source change is not picked up.
Avoid `omarchy plugin update so.den` while this checkout has local edits.

Diagnostics: `omarchy-shell so.den status` reports configured, resolved and
mounted IDs. `omarchy-shell so.den toggle` opens/closes the instance owning the
IPC target; with multiple monitors this is one instance, not all of them.

Verified locally on 2026-09-10: manifest validation, `git diff --check`, shell
restart, all eight configured widgets mounted, and an expanded drawer screenshot
showing plugin and tray icons. Drag/reorder, every plugin panel, and a fresh
WeChat unread event have not been retested.

Pre-switch files and shell config are backed up in
`/home/nero/Work/den-upgrade-backups/20260910-192643/`.
To roll back, remove only the installation symlink and move that backup's
`plugin` directory back to `~/.config/omarchy/plugins/so.den`, then restart the
shell. The fork checkout remains intact.

### Layout-change regression check

On 2026-09-10, explicitly running the stock bar's `prunePluginBarApis()`
reproduced null bar references for all three tucked third-party widgets before
the fix. With drawer-owned facades, repeated pruning preserved all eight bar
references; Pane and Time Machine panels were visually verified beside Den.
The user subsequently confirmed the panel-position fix in actual desktop use.
The agent did not run a full drag/reorder gesture matrix. Temporary pruning
and panel-opening IPC test methods were removed after verification; the
read-only `status` method retains per-widget `barPresent` diagnostics.

## WeChat attention reveal

Hidden WeChat tray icons appear temporarily before the Den chevron while their
icon changes signal unread-message blinking, then hide again after 1250 ms
without updates. The pinned/hidden tray configuration is preserved.
`revealAttentionIds` selects watched app IDs and defaults to `["wechat"]`.
The same temporary button also handles `NeedsAttention`, activation,
middle-click and scrolling. Nonvisual icon listeners use `Instantiator`.

## Gestures

| Action | How |
|---|---|
| Open / close | click the chevron |
| Tuck a widget away | press-and-hold it anywhere on the bar → drop on the glowing chevron or the open card |
| Show again | drag the tile onto the eject strip at the top of the card ("Release to show") |
| Show at an exact spot | plugins only — drag the tile out of the card and drop it between two bar widgets |
| Activate | left-click a tile (apps launch; plugins toggle their panel under the card) |
| App menu | right-click an app tile — full menu with submenus, rendered inline |
| Send plugin back | right-click a plugin tile |
| Reorder | hold a tile, hover a landing slot (accent ring), release |

Middle-click and scroll behave like normal tray icons. The chevron always
points toward the flyout: down on a top bar, up on a bottom bar, inward on
left/right bars.

## Plugin icons

Omarchy plugins carry no icon metadata, so tile faces resolve through a
fallback chain:

1. manual overrides — add an `icons` map to Den's entry in
   `~/.config/omarchy/shell.json`:
   ```json
   { "id": "so.den", "widgets": ["..."], "icons": { "omaplug": "\uf013" } }
   ```
2. optional manifest convention — `icon` or `barWidget.icon` accepts a Nerd
   Font glyph or an image path (relative paths resolve against the plugin dir)
3. live extraction of the widget's actual bar-button glyph from its mounted
   instance — a pure nerd-font glyph first, then one stripped out of mixed
   button text ("󰁁 Notifications"), then a plain Unicode symbol (⌨)
4. a builtin guess from the plugin id/name (keyboard, window, hotspot,
   notifications, stats and friends)
5. letter avatar

Tray apps always render their real icon (symbolic icons are tinted to match
your theme).

## Install

```sh
omarchy plugin add https://github.com/SaifOmar/so.den.git --enable
```

That's it. Place it on your bar:

```sh
omarchy bar move so.den --section right
```

## Uninstall

```sh
omarchy plugin remove so.den
```

### Settings

All settings live on Den's entry in `~/.config/omarchy/shell.json`:

- `widgets` — which bar plugins are tucked away (managed by dragging; edit by
  hand if you prefer)
- `captureOverflow` — default `true`. Registers unpinned tray ids as hidden on
  the stock tray so its own hover-expander stays empty and Den becomes the
  single overflow. Set to `false` to leave the stock tray alone.
- `icons` — per-plugin icon overrides, see above.
- `popupMaxWidth` — default `184`. Width of the dropdown card, in Omarchy
  "space" units (the same UI scale used everywhere, so it tracks DPI).
- `popupMaxHeight` — default `340`. Height of the dropdown card in the same
  units. A taller card lets the inner tile grid show more rows before scrolling.

The card is resized directly: grab any edge (top, bottom, left, right) or
corner and drag. Sizes snap to whole tile columns and rows, so you always
land on a clean grid with no half-cut tiles, and the choice is saved once
when you release. Double-click any edge to reset that axis to its default.
The two keys above hold the persisted values if you prefer to edit
`shell.json` by hand; sizes are clamped to a sane range and to the screen.

## Files

- `manifest.json` — plugin metadata (bar-widget kind)
- `Den.qml` — the widget
- `DenModel.js` — pure config/tray helpers

## License

[MIT](LICENSE)
