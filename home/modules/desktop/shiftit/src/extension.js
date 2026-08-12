// Fractional window placement on the ShiftIt chord (ctrl+alt+super, née
// ctrl+alt+cmd). A port of the Hammerspoon config this repo carries for
// macOS — same units table, same repeated-press width cycles.

import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const TODOIST_WIDTH = 5 / 24;
const FANTASTICAL_WIDTH = 19 / 40;
const MESSAGES_WIDTH = FANTASTICAL_WIDTH - TODOIST_WIDTH;

// Unit rectangles of the monitor work area, straight from init.lua
const UNITS = {
  fullscreen: {x: 0.00, y: 0.00, w: 1.00, h: 1.00},

  left33: {x: 0.00, y: 0.00, w: 1 / 3, h: 1.00},
  left50: {x: 0.00, y: 0.00, w: 1 / 2, h: 1.00},
  left66: {x: 0.00, y: 0.00, w: 2 / 3, h: 1.00},
  left75: {x: 0.00, y: 0.00, w: 3 / 4, h: 1.00},
  right33: {x: 2 / 3, y: 0.00, w: 1 / 3, h: 1.00},
  right50: {x: 1 / 2, y: 0.00, w: 1 / 2, h: 1.00},
  right66: {x: 1 / 3, y: 0.00, w: 2 / 3, h: 1.00},
  right75: {x: 1 / 4, y: 0.00, w: 3 / 4, h: 1.00},

  upleft2: {x: 0.00, y: 0.00, w: 1 / 2, h: 1 / 2},
  upright2: {x: 1 / 2, y: 0.00, w: 1 / 2, h: 1 / 2},
  botleft2: {x: 0.00, y: 1 / 2, w: 1 / 2, h: 1 / 2},
  botright2: {x: 1 / 2, y: 1 / 2, w: 1 / 2, h: 1 / 2},

  upleft3: {x: 0.00, y: 0.00, w: 1 / 3, h: 1 / 2},
  botleft3: {x: 0.00, y: 1 / 2, w: 1 / 3, h: 1 / 2},
  upmid3: {x: 1 / 3, y: 0.00, w: 1 / 3, h: 1 / 2},
  botmid3: {x: 1 / 3, y: 1 / 2, w: 1 / 3, h: 1 / 2},
  upright3: {x: 2 / 3, y: 0.00, w: 1 / 3, h: 1 / 2},
  botright3: {x: 2 / 3, y: 1 / 2, w: 1 / 3, h: 1 / 2},

  todoist: {x: 1 / 2, y: 1 / 2 + 0.1, w: TODOIST_WIDTH, h: 1 / 2},
  fantastical: {x: 1 / 2, y: 0.00, w: FANTASTICAL_WIDTH, h: 1 / 2},
  messages: {x: 1 / 2 + TODOIST_WIDTH, y: 1 / 2, w: MESSAGES_WIDTH, h: 1 / 2},
};

const LEFT_CYCLE = [UNITS.left33, UNITS.left50, UNITS.left66, UNITS.left75];
const RIGHT_CYCLE = [UNITS.right33, UNITS.right50, UNITS.right66, UNITS.right75];

// Matches the Lua one-decimal comparison loosely enough to survive
// fractional-scaling pixel rounding
const EPSILON = 0.03;

export default class ShiftIt extends Extension {
  enable() {
    this._settings = this.getSettings();
    this._bindings = [];

    const moves = {
      'fullscreen': UNITS.fullscreen,
      'quarter-top-left': UNITS.upleft2,
      'quarter-top-right': UNITS.upright2,
      'quarter-bottom-left': UNITS.botleft2,
      'quarter-bottom-right': UNITS.botright2,
      'sixth-top-left': UNITS.upleft3,
      'sixth-bottom-left': UNITS.botleft3,
      'sixth-top-middle': UNITS.upmid3,
      'sixth-bottom-middle': UNITS.botmid3,
      'sixth-top-right': UNITS.upright3,
      'sixth-bottom-right': UNITS.botright3,
      'spot-todoist': UNITS.todoist,
      'spot-calendar': UNITS.fantastical,
      'spot-messages': UNITS.messages,
    };

    for (const [name, unit] of Object.entries(moves))
      this._addBinding(name, () => this._move(unit));

    this._addBinding('cycle-left', () => this._cycle(LEFT_CYCLE));
    this._addBinding('cycle-right', () => this._cycle(RIGHT_CYCLE));
  }

  disable() {
    for (const name of this._bindings)
      Main.wm.removeKeybinding(name);
    this._bindings = [];
    this._settings = null;
  }

  _addBinding(name, handler) {
    Main.wm.addKeybinding(
      name,
      this._settings,
      Meta.KeyBindingFlags.IGNORE_AUTOREPEAT,
      Shell.ActionMode.NORMAL,
      handler,
    );
    this._bindings.push(name);
  }

  _move(unit) {
    const win = global.display.focus_window;
    if (!win || !win.resizeable)
      return;

    // A maximized window ignores move_resize_frame until unmaximized. The
    // flags argument came and went across mutter versions; tolerate both.
    if (win.maximized_horizontally || win.maximized_vertically) {
      try {
        win.unmaximize(Meta.MaximizeFlags.BOTH);
      } catch {
        win.unmaximize();
      }
    }

    const area = win.get_work_area_current_monitor();
    win.move_resize_frame(
      true,
      Math.round(area.x + unit.x * area.width),
      Math.round(area.y + unit.y * area.height),
      Math.round(unit.w * area.width),
      Math.round(unit.h * area.height),
    );
  }

  _cycle(cycle) {
    const win = global.display.focus_window;
    if (!win)
      return;

    const area = win.get_work_area_current_monitor();
    const frame = win.get_frame_rect();
    const current = {
      x: (frame.x - area.x) / area.width,
      y: (frame.y - area.y) / area.height,
      w: frame.width / area.width,
      h: frame.height / area.height,
    };

    let next = cycle[0];
    for (let i = 0; i < cycle.length; i++) {
      if (this._matches(current, cycle[i])) {
        next = cycle[(i + 1) % cycle.length];
        break;
      }
    }
    this._move(next);
  }

  _matches(a, b) {
    return Math.abs(a.x - b.x) < EPSILON &&
      Math.abs(a.y - b.y) < EPSILON &&
      Math.abs(a.w - b.w) < EPSILON &&
      Math.abs(a.h - b.h) < EPSILON;
  }
}
