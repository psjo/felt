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

    var w;
    var r, dr, dr2, cr = 6, rr = 8;
    var sqrt3d2 = Math.sqrt(3)/2;
    var pit2 = Math.PI*2;
    var pid6 = Math.PI/6;
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
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        if (loadSettings) {
            //getSettings();
            loadSettings = false;
        }

        drawBG(dc);

        drawSome(dc);
        if (!sleep && bluetooth) {
            drawBT(dc);
        }
        if (marks && !sleep) {
            drawMark(dc);
        }
        if (date && !sleep) {
            drawDate(dc);
        }
        drawTime(dc);
    }

    function drawBG(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
    }

    function drawMark(dc) {
        //sin 30 = cos 60 = 1/2
        //sin 60 = cos 30 = sqrt(3)/2
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < 3; i += 2) {
            dc.fillCircle(dots[i], dots[(i + 2)&3], cr);
            dc.fillCircle(dots[i], dots[(i + 3)&3], cr);
            dc.fillCircle(dots[(i + 1)], dots[(i + 2)&3], cr);
            dc.fillCircle(dots[(i + 1)], dots[(i + 3)&3], cr);
        }
        // rectangles
        dc.fillRoundedRectangle(r - cr, 0, cr << 1, cr << 2, 4); // 12
        dc.fillRoundedRectangle(0, r - cr, cr << 2, cr << 1, 4); // 9
        dc.fillRoundedRectangle(r - cr, w - cr << 2, cr << 1, cr << 2, 4); // 6
        dc.fillRoundedRectangle(w - cr << 2, r - cr, cr << 2, cr << 1, 4); // 3
        dc.setPenWidth(2);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < 3; i += 2) {
            dc.drawCircle(dots[i], dots[(i + 2)&3], cr);
            dc.drawCircle(dots[i], dots[(i + 3)&3], cr);
            dc.drawCircle(dots[(i + 1)&3], dots[(i + 2)&3], cr);
            dc.drawCircle(dots[(i + 1)&3], dots[(i + 3)&3], cr);
        }
        // rectangles
        dc.drawRoundedRectangle(r - cr, 0, cr << 1, cr << 2, 4); // 12
        dc.drawRoundedRectangle(0, r - cr, cr << 2, cr << 1, 4); // 9
        dc.drawRoundedRectangle(r - cr, w - cr << 2, cr << 1, cr << 2, 4); // 6
        dc.drawRoundedRectangle(w - cr << 2, r - cr, cr << 2, cr << 1, 4); // 3
        if (date) {
            // date box
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(w - 40, r - 12, 40, 24, 4);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(w - 40, r - 13, 40, 26, 4);
        }
    }

    function drawTime(dc) {
        // Get and show the current time
        var now = Sys.getClockTime();
        var m = now.min;
        var h = pid6*(now.hour % 12 + m/60.0);
        m = pid6*m/5.0;

        if (!sleep && hands) {
            var mina = new [11];

            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            // hour
            for (var i = 0; i < 11; i += 1) {
                mina[i] = [r + hour[i][0]*Math.sin(hour[i][1] + h), r - hour[i][0]*Math.cos(hour[i][1] + h)];
            }
            dc.fillPolygon(mina);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            for (var i = 0; i < 11; i += 1) {
                dc.drawLine(mina[i][0], mina[i][1], mina[(i + 1)%11][0], mina[(i + 1)%11][1]);
            }
            dc.drawLine(mina[3][0], mina[3][1], mina[7][0], mina[7][1]);
            dc.drawLine(mina[2][0], mina[2][1], mina[8][0], mina[8][1]);
            dc.drawLine(mina[3][0], mina[3][1], mina[8][0], mina[8][1]);
            dc.drawLine(mina[2][0], mina[2][1], mina[7][0], mina[7][1]);

            // minute
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            for (var i = 0; i < 11; i += 1) {
                mina[i] = [r + min[i][0]*Math.sin(min[i][1] + m), r - min[i][0]*Math.cos(min[i][1] + m)];
            }
            dc.fillPolygon(mina);
            //center
            dc.fillCircle(r, r, cr);
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            for (var i = 0; i < 11; i += 1) {
                dc.drawLine(mina[i][0], mina[i][1], mina[(i + 1)%11][0], mina[(i + 1)%11][1]);
            }
            dc.drawLine(mina[3][0], mina[3][1], mina[7][0], mina[7][1]);

            //center
            dc.drawCircle(r, r, cr);
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(r, r, 1);
        } else {
            var mina = new [2];

            dc.setPenWidth(4);
            // hour
            for (var i = 0; i < 2; i += 1) {
                mina[i] = [r + hour[i][0]*Math.sin(hour[i][1] + h), r - hour[i][0]*Math.cos(hour[i][1] + h)];
            }
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawLine(mina[0][0], mina[0][1], mina[1][0], mina[1][1]);
            // minute
            for (var i = 0; i < 2; i += 1) {
                mina[i] = [r + min[i][0]*Math.sin(min[i][1] + m), r - min[i][0]*Math.cos(min[i][1] + m)];
            }
            //center
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.drawLine(mina[0][0], mina[0][1], mina[1][0], mina[1][1]);

        }
    }

    function drawDate(dc) {
        var now = Cal.info(Time.now(), Time.FORMAT_MEDIUM);
        var day = now.day.format("%d");
        if (marks) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        }
        dc.drawText(w - 20, r - 16, Gfx.FONT_SYSTEM_MEDIUM, day, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawSome(dc) {
        var bat = Sys.getSystemStats().battery;
        if (bat < 15) {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(r, w, r >> 3);
        }
    }

    function drawBT(dc) {

        var settings = Sys.getDeviceSettings();
        var conn = settings.phoneConnected;

        if (conn) {

            var msgs = settings.notificationCount;
            var alarms = settings.alarmCount;

            if (msgs > 0) {
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                dc.fillCircle(r, 0, r >> 2);
            }

            if (alarms > 0){
                dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                dc.fillCircle(w, r, r >> 2);
            }
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(0, r, r >> 3);
        }
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        sleep = false;
    }

    // Terminate any active timers and prepare for slow updates.
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
    }

}
