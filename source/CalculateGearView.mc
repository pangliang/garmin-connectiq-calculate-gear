import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
/*
参考文档:
https://developer.garmin.com/connect-iq/api-docs/index.html
https://developer.garmin.com/connect-iq/core-topics/
*/
class CalculateGearView extends WatchUi.SimpleDataField {

    var wheelCircumferenceM = (622 + 25 * 2) * 3.1415 / 1000;
    var frontTeeth = 40;
    var cassette_s11_1225 = [12, 13, 14, 15, 16, 17, 18, 19, 21, 23, 25] as Array<Number>;
    var cassette_s8_1132 = [11, 13, 15, 18, 21, 24, 28, 32] as Array<Number>;
    var cassette_s11_1125 = [11,12,13,14,15,16,17,19,21,23,25] as Array<Number>;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "飞轮";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        if (info == null or info.currentCadence == null or info.currentSpeed == null or info.currentCadence <= 0) {
            return "--";
        }
        var speed = info.currentSpeed;
        var cadence = info.currentCadence.toFloat() / 2f;
        var turn = speed / wheelCircumferenceM;
        var gearRatio = (turn / (cadence / 60f));
        var realTeethF = frontTeeth / gearRatio;
        var cassette = cassette_s11_1125;
        var size = cassette.size();
        for (var i = 0; i < size - 1; i++) {
            if (realTeethF < cassette[0]) {
                realTeethF = cassette[0];
                break;
            }
            if (((cassette[i] < realTeethF) && (realTeethF < cassette[i + 1]))) {
                var diff1 = realTeethF - cassette[i];
                var diff2 = cassette[i + 1] - realTeethF;
                realTeethF = diff1 < diff2 ? cassette[i] : cassette[i + 1];
                break;
            }
            if (realTeethF > cassette[size - 1]) {
                realTeethF = cassette[size - 1];
                break;
            }
        }
        // System.println("speed:"+speed+",cadence:"+cadence+",turn:"+turn+",gearRatio:"+gearRatio+",realTeethF:"+realTeethF);
        return realTeethF.toNumber();
    }

}