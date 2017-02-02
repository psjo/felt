using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Cal;
using Toybox.Math as Math;

class feltView extends Ui.WatchFace {
    var sleep = false;
    var loadSettings = true;

    var bluetooth = true;
    var marks = false;
    var date = true;
    var hands = false;
    var invert = true;
    var w;
    var r, dr, dr2, cr = 6, rr = 8;
    var sqrt3d2 = Math.sqrt(3) / 2;
    var pit2 = Math.PI * 2;
    var pid6 = Math.PI / 6;
    var min = []; // minute hand
    var hour = []; // hour hand
    var dots = [];

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        w = dc.getWidth();
        r = w >> 1;
        dr = r - rr;
        dr2 = dr >> 1;
        min = [ [ 0, r - cr ],
                [ 0, r - cr*4 ],
                [ -cr*2, r - cr*8 ],
                [ -4, r - cr*8 ],
                [ -cr, -cr*2 ],
                [ 0, -cr*3 ],
                [ cr, -cr*2 ],
                [ 4, r - cr*8 ],
                [ cr*2, r - cr*8 ],
                [ 0, r - cr*4 ],
                [ 0, r - cr*2 ] ];
        min = toCyl(min, 11); // make hand to [radius, angle]
        hour = [ [ 0, r - cr*4 ],
                [ 0, r - cr*6 ],
                [ -cr << 1, r - cr*9 ],
                [ -cr << 1 + 3, cr*2 ],
                [ -cr, cr ],
                [ 0, -cr << 1],
                [ cr, cr ],
                [ cr << 1 - 3, cr*2 ],
                [ cr << 1, r - cr*9 ],
                [ 0, r - cr*6 ],
                [ 0, r - cr*4 ] ];
        hour = toCyl(hour, 11);
        dots = [r - dr2, r + dr2, r - dr*sqrt3d2, r + dr*sqrt3d2];
    }

    function onShow() {
    }

    function onUpdate(dc) {
        if (loadSettings) {
            getSettings();
            loadSettings = false;
        }

        drawBG(dc);
        if(invert) {
            drawInv(dc);
        }
        if (!sleep && bluetooth) {
            drawBT(dc);
        }
        if (date && !sleep && !invert) {
            drawDate(dc);
        }
        drawSome(dc);
        drawTime(dc);
    }

    function drawBG(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
    }

    function drawTime(dc) {
        // Get and show the current time
        var now = Sys.getClockTime();
        var m = now.min;
        var h = pid6*(now.hour % 12 + m/60.0);
        m = pid6*m/5.0;

        var mina = new [2];

        dc.setPenWidth(4);
        // hour
        for (var i = 0; i < 2; i += 1) {
            mina[i] = [r + hour[i][0]*Math.sin(hour[i][1] + h), r - hour[i][0]*Math.cos(hour[i][1] + h)];
        }
        if(invert) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        }
        dc.drawLine(mina[0][0], mina[0][1], mina[1][0], mina[1][1]);
        // minute
        for (var i = 0; i < 2; i += 1) {
            mina[i] = [r + min[i][0]*Math.sin(min[i][1] + m), r - min[i][0]*Math.cos(min[i][1] + m)];
        }
        //center
        if(invert) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        //dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(mina[0][0], mina[0][1], mina[1][0], mina[1][1]);
        if (!sleep) {
            var s = pid6*now.sec/5.0;
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(r + (r-4)*Math.sin(s), r - (r-4)*Math.cos(s), 4);

        }
    }

    function drawInv(dc) {
        dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(r, r, min[0][0]);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(r, r, hour[0][0]);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(r, r, hour[0][0]);

        //dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(r, r, hour[1][0]);

    }
    function drawDate(dc) {
        var now = Cal.info(Time.now(), Time.FORMAT_MEDIUM);
        var day = now.day.format("%d");
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(w - 20, r - 16, Gfx.FONT_SYSTEM_MEDIUM, day, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawSome(dc) {
        var bat = Sys.getSystemStats().battery;
        if (bat < 15) {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
            if (invert) {
                dc.setPenWidth(23);
                dc.drawArc(r, r, hour[1][0]-13, 0, 227, 313);
            } else {
                dc.fillCircle(r, w, r >> 3);
            }
        }
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(r >> 1, r >> 1, r, r, 13);
    }

    function drawBT(dc) {

        var settings = Sys.getDeviceSettings();
        var conn = settings.phoneConnected;

        if (conn) {

            var msgs = settings.notificationCount;
            var alarms = settings.alarmCount;

            if (msgs > 0) {
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                if (invert) {
                    dc.setPenWidth(23);
                    dc.drawArc(r, r, hour[1][0]-13, 0, 137, 223);
                } else {
                    dc.fillCircle(r, 0, r >> 3);
                }
            }

            if (alarms > 0){
                dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                if (invert) {
                    dc.setPenWidth(23);
                    dc.drawArc(r, r, hour[1][0]-13, 0, 317, 43);
                } else {
                    dc.fillCircle(w, r, r >> 3);
                }
            }
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            if (invert) {
                dc.setPenWidth(23);
                dc.drawArc(r, r, hour[1][0]-13, 1, 133, 47);
            } else {
                dc.fillCircle(0, r, r >> 3);
            }
        }
    }


    function onHide() {
    }
    function onExitSleep() {
        sleep = false;
    }
    function onEnterSleep() {
        sleep = true;
    }

    function toCyl(pos, len) {
        var r;
        var a;
        for (var i = 0; i < len; i += 1) {
            r = Math.sqrt(Math.pow(pos[i][0], 2) + Math.pow(pos[i][1], 2));
            a = Math.acos(pos[i][1]/r);
            if (pos[i][0] < 0) {
                pos[i] = [r, -a];
            } else {
                pos[i] = [r, a];
            }
        }
        return pos;
    }

    function getSettings() {
        var app = App.getApp();
        bluetooth = app.getProperty("bt_prop");
        marks = app.getProperty("marks_prop");
        date = app.getProperty("date_prop");
        hands = app.getProperty("hands_prop");
    }
}
