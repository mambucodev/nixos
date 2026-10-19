#!/usr/bin/env python3
import json
import os
import sys

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, Gdk, Gtk

CSS = """
.cheatsheet { padding: 28px 32px 32px 32px; }
.section { padding: 18px 20px; }
.section-title {
  color: var(--accent-color);
  font-size: 0.78em;
  font-weight: 800;
  letter-spacing: 0.12em;
}
.keycap {
  min-width: 14px;
  padding: 3px 9px;
  border-radius: 7px;
  background: alpha(currentColor, 0.07);
  border: 1px solid alpha(currentColor, 0.14);
  box-shadow: inset 0 -2px alpha(currentColor, 0.14);
  font-family: monospace;
  font-weight: 700;
  font-size: 0.88em;
}
.keycap.super {
  background: var(--accent-bg-color);
  color: var(--accent-fg-color);
  border-color: transparent;
  box-shadow: inset 0 -2px alpha(black, 0.25);
}
image.keycap { padding: 3px 8px 4px 8px; }
.key-sep { opacity: 0.45; font-weight: 700; }
"""


def keycaps(keys):
    box = Gtk.Box(spacing=4, valign=Gtk.Align.CENTER)
    for key in keys:
        if key == "/":
            box.append(Gtk.Label(label="/", css_classes=["key-sep"]))
            continue
        if key == "Super":
            box.append(Gtk.Image(icon_name="super-symbolic", pixel_size=14, css_classes=["keycap", "super"]))
        else:
            box.append(Gtk.Label(label=key, css_classes=["keycap"]))
    return box


def section(data):
    card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14, css_classes=["card", "section"])
    card.append(Gtk.Label(label=data["title"].upper(), xalign=0, css_classes=["section-title"]))
    grid = Gtk.Grid(row_spacing=10, column_spacing=18)
    for i, row in enumerate(data["rows"]):
        grid.attach(keycaps(row["keys"]), 0, i, 1, 1)
        grid.attach(Gtk.Label(label=row["action"], xalign=0, hexpand=True), 1, i, 1, 1)
    card.append(grid)
    return card


class Cheatsheet(Adw.Application):
    def __init__(self, columns):
        super().__init__(application_id="local.mambuco.KeybindingsCheatsheet")
        self.columns = columns
        self.win = None

    def do_startup(self):
        Adw.Application.do_startup(self)
        # Stays resident with the window prebuilt; activation only toggles visibility.
        self.hold()

        provider = Gtk.CssProvider()
        provider.load_from_string(CSS)
        display = Gdk.Display.get_default()
        Gtk.StyleContext.add_provider_for_display(display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        Gtk.IconTheme.get_for_display(display).add_search_path(
            os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "share", "icons")
        )

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=22, css_classes=["cheatsheet"])

        header = Gtk.Box(spacing=12)
        header.append(Gtk.Label(label="Keyboard Shortcuts", xalign=0, hexpand=True, css_classes=["title-1"]))
        hint = Gtk.Box(spacing=6, valign=Gtk.Align.CENTER, css_classes=["dim-label"])
        hint.append(keycaps(["Esc"]))
        hint.append(Gtk.Label(label="to close"))
        header.append(hint)
        root.append(header)

        cols = Gtk.Box(spacing=16, homogeneous=True)
        for column in self.columns:
            col = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
            for data in column:
                col.append(section(data))
            cols.append(col)
        root.append(cols)

        self.win = Adw.ApplicationWindow(
            application=self, content=root, resizable=False, hide_on_close=True, title="Keyboard Shortcuts"
        )

        keys = Gtk.EventControllerKey()
        keys.connect("key-pressed", lambda _c, keyval, *_: keyval == Gdk.KEY_Escape and self.win.set_visible(False))
        self.win.add_controller(keys)
        self.win.connect("notify::is-active", lambda w, _p: w.is_active() or w.set_visible(False))

    def do_activate(self):
        if self.win.get_visible():
            self.win.set_visible(False)
        else:
            self.win.present()


if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        columns = json.load(f)
    sys.exit(Cheatsheet(columns).run(sys.argv[:1] + sys.argv[2:]))
