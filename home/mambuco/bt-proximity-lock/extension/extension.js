import GObject from 'gi://GObject';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

const SERVICE_NAME = 'bt-proximity-lock.service';

const ProximityToggle = GObject.registerClass(
class ProximityToggle extends QuickSettings.QuickToggle {
    _init() {
        super._init({
            title: 'Proximity Lock',
            subtitle: 'Checking...',
            iconName: 'system-lock-screen-symbolic',
            toggleMode: true,
        });

        this._syncState();

        this.connect('clicked', () => this._onToggle());
        this._pollTimer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 4, () => {
            this._syncState();
            return GLib.SOURCE_CONTINUE;
        });
    }

    _isServiceActive() {
        try {
            let [res, stdout] = GLib.spawn_command_line_sync('systemctl --user is-active ' + SERVICE_NAME);
            return stdout ? new TextDecoder().decode(stdout).trim() === 'active' : false;
        } catch (e) {
            return false;
        }
    }

    _syncState() {
        const active = this._isServiceActive();
        this.checked = active;
        this.subtitle = active ? 'Active' : 'Paused';
    }

    _onToggle() {
        const targetCmd = this.checked
            ? 'systemctl --user start ' + SERVICE_NAME
            : 'systemctl --user stop ' + SERVICE_NAME;
        GLib.spawn_command_line_async(targetCmd);
        this.subtitle = this.checked ? 'Active' : 'Paused';
    }

    destroy() {
        if (this._pollTimer) {
            GLib.source_remove(this._pollTimer);
            this._pollTimer = null;
        }
        if (super.destroy)
            super.destroy();
    }
});

const ProximityIndicator = GObject.registerClass(
class ProximityIndicator extends QuickSettings.SystemIndicator {
    _init() {
        super._init();
        this.quickSettingsItems.push(new ProximityToggle());
    }
});

export default class BtProximityExtension extends Extension {
    enable() {
        this._indicator = new ProximityIndicator();
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);
    }

    disable() {
        if (this._indicator) {
            this._indicator.quickSettingsItems.forEach(item => item.destroy());
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
