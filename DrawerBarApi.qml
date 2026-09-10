import QtQuick
import qs.Ui

// Owned by a Den drawer slot, not the stock bar's visible-slot cache.
// Keep the plugin's scoped shell and delegate UI operations by plugin ID.
PluginBarApi {
  id: api
  required property var host
  required property var widget

  _showTooltip: (target, text) => host.showTooltip(target, text)
  _hideTooltip: target => host.hideTooltip(target)
  _registerClickTarget: target => host.registerPluginClickTarget(pluginId, target)
  _unregisterClickTarget: target => host.unregisterPluginClickTarget(pluginId, target)
  _requestPopout: owner => host.requestPluginPopout(pluginId, owner)
  _releasePopout: owner => host.releasePluginPopout(pluginId, owner)
  _switchPanelFrom: (owner, direction) => host.switchPanelFrom(owner, direction)
  _targetBelongsToWindow: (target, window) => host.targetBelongsToWindow(target, window)
  _moduleWidgets: requestedId => requestedId === moduleName && widget ? [widget] : []
  _run: command => host.run(command)
  _setCenterHoverRevealSuppressed: value => { host.centerHoverRevealSuppressed = !!value }

  // bindPluginBarApi installs reactive scalar bindings. Since this facade
  // is outside the host cache, mirror the object snapshots explicitly too.
  Component.onCompleted: host.bindPluginBarApi(api)
  property Connections hostChanges: Connections {
    target: api.host
    function onActivePopoutChanged() { api.host.syncPluginBarApiObjects(api) }
    function onClickTargetsChanged() { api.host.syncPluginBarApiObjects(api) }
    function onLayoutConfigChanged() { api.host.syncPluginBarApiObjects(api) }
  }
}
