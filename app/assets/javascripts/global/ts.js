/*******************************************************************************
 *
 * Baobab Touchscreen Toolkit Version 2.0
 *
 * A library for transforming HTML pages into touch-friendly user interfaces.
 *
 * (c) 2014 Baobab Health Trust (http://www.baobabhealth.org)
 *
 * For license details, see the README.md file
 *
 ******************************************************************************/


var imgTick = 'data:image/png;base64,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';

var imgUnTick = 'data:image/png;base64,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';

var styles = "body {-moz-user-select: none; overflow: hidden; font-family: 'Nimbus Sans L', 'Arial Narrow', sans-serif; min-width: 800px; min-height: 700px; } .button:active {border:1px solid #5ca6c4 !important;background-color: #82bbd1 !important; background-image: -webkit-gradient(linear, left top, left bottom, from(#82bbd1), to(#cd8912)) !important;background-image: -webkit-linear-gradient(top, #82bbd1, #cd8912) !important;background-image: -moz-linear-gradient(top, #efb144, #cd8912) !important;background-image: -ms-linear-gradient(top, #efb144, #cd8912) !important;background-image: -o-linear-gradient(top, #efb144, #cd8912) !important;background-image: linear-gradient(to bottom, #efb144, #cd8912) !important;filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#efb144, endColorstr=#cd8912) !important;} .input_date_cell {font-size: 1.2em;padding: 10px;border: 1px solid #3465a4;border-radius: 10px;width: 80%;} .input_cell {font-size: 1.2em;padding: 10px;border: 1px solid #3465a4;border-radius: 10px;width: 80%;}button {font-size: 1em;padding: 15px;min-width: 120px;cursor: pointer;min-height: 75px;border-radius: 10px !important;margin: 3px;}.button {font-size: 1em;padding: 15px;min-width: 100px;  cursor: pointer;  min-height: 60px;border-radius: 10px !important;margin: 3px;}.blue{border:1px solid #7eb9d0; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:28px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;background-color: #a7cfdf; background-image: -webkit-gradient(linear, left top, left bottom, from(#a7cfdf), to(#23538a));background-image: -webkit-linear-gradient(top, #a7cfdf, #23538a);background-image: -moz-linear-gradient(top, #a7cfdf, #23538a);background-image: -ms-linear-gradient(top, #a7cfdf, #23538a);background-image: -o-linear-gradient(top, #a7cfdf, #23538a);background-image: linear-gradient(to bottom, #a7cfdf, #23538a);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#a7cfdf, endColorstr=#23538a);}.blue:hover{border:1px solid #5ca6c4;background-color: #82bbd1; background-image: -webkit-gradient(linear, left top, left bottom, from(#82bbd1), to(#193b61));background-image: -webkit-linear-gradient(top, #82bbd1, #193b61);background-image: -moz-linear-gradient(top, #82bbd1, #193b61);background-image: -ms-linear-gradient(top, #82bbd1, #193b61);background-image: -o-linear-gradient(top, #82bbd1, #193b61);background-image: linear-gradient(to bottom, #82bbd1, #193b61);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#82bbd1, endColorstr=#193b61);}.green{border:1px solid #34740e; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:28px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;background-color: #4ba614; background-image: -webkit-gradient(linear, left top, left bottom, from(#4ba614), to(#008c00));background-image: -webkit-linear-gradient(top, #4ba614, #008c00);background-image: -moz-linear-gradient(top, #4ba614, #008c00);background-image: -ms-linear-gradient(top, #4ba614, #008c00);background-image: -o-linear-gradient(top, #4ba614, #008c00);background-image: linear-gradient(to bottom, #4ba614, #008c00);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#4ba614, endColorstr=#008c00);}.green:hover{border:1px solid #224b09;background-color: #36780f; background-image: -webkit-gradient(linear, left top, left bottom, from(#36780f), to(#005900));background-image: -webkit-linear-gradient(top, #36780f, #005900);background-image: -moz-linear-gradient(top, #36780f, #005900);background-image: -ms-linear-gradient(top, #36780f, #005900);background-image: -o-linear-gradient(top, #36780f, #005900);background-image: linear-gradient(to bottom, #36780f, #005900);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#36780f, endColorstr=#005900);}.red{border:1px solid #72021c; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:28px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;background-color: #a90329; background-image: -webkit-gradient(linear, left top, left bottom, from(#a90329), to(#6d0019));background-image: -webkit-linear-gradient(top, #a90329, #6d0019);background-image: -moz-linear-gradient(top, #a90329, #6d0019);background-image: -ms-linear-gradient(top, #a90329, #6d0019);background-image: -o-linear-gradient(top, #a90329, #6d0019);background-image: linear-gradient(to bottom, #a90329, #6d0019);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#a90329, endColorstr=#6d0019);}.red:hover{border:1px solid #450111;background-color: #77021d; background-image: -webkit-gradient(linear, left top, left bottom, from(#77021d), to(#3a000d));background-image: -webkit-linear-gradient(top, #77021d, #3a000d);background-image: -moz-linear-gradient(top, #77021d, #3a000d);background-image: -ms-linear-gradient(top, #77021d, #3a000d);background-image: -o-linear-gradient(top, #77021d, #3a000d);background-image: linear-gradient(to bottom, #77021d, #3a000d);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#77021d, endColorstr=#3a000d);}.gray{border:1px solid #ccc; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:28px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;background-color: #ccc; background-image: -webkit-gradient(linear, left top, left bottom, from(#ccc), to(#999));background-image: -webkit-linear-gradient(top, #ccc, #999);background-image: -moz-linear-gradient(top, #ccc, #999);background-image: -ms-linear-gradient(top, #ccc, #999);background-image: -o-linear-gradient(top, #ccc, #999);background-image: linear-gradient(to bottom, #ccc, #999);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#ccc, endColorstr=#999);}.gray:hover{border:1px solid #ccc;background-color: #ddd; background-image: -webkit-gradient(linear, left top, left bottom, from(#333), to(#ccc));background-image: -webkit-linear-gradient(top, #333, #ccc);background-image: -moz-linear-gradient(top, #333, #ccc);background-image: -ms-linear-gradient(top, #333, #ccc);background-image: -o-linear-gradient(top, #333, #ccc);background-image: linear-gradient(to bottom, #333, #ccc);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#333, endColorstr=#ccc);}.orange{border:1px solid #ef8544; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:28px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;background-color: #ef8544; background-image: -webkit-gradient(linear, left top, left bottom, from(#ef8544), to(#efb144));background-image: -webkit-linear-gradient(top, #ef8544, #efb144);background-image: -moz-linear-gradient(top, #ef8544, #efb144);background-image: -ms-linear-gradient(top, #ef8544, #efb144);background-image: -o-linear-gradient(top, #ef8544, #efb144);background-image: linear-gradient(to bottom, #ef8544, #efb144);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#ef8544, endColorstr=#efb144);}.orange:hover{border:1px solid #ef8544;background-color: #ddd; background-image: -webkit-gradient(linear, left top, left bottom, from(#ff420e), to(#ef8544));background-image: -webkit-linear-gradient(top, #ff420e, #ef8544);background-image: -moz-linear-gradient(top, #ff420e, #ef8544);background-image: -ms-linear-gradient(top, #ff420e, #ef8544);background-image: -o-linear-gradient(top, #ff420e, #ef8544);background-image: linear-gradient(to bottom, #ff420e, #ef8544);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#ff420e, endColorstr=#ef8544);}"

$(document).on('keydown',function(e)
{
    var key = e.charCode || e.keyCode;
    if(key == 122 || key == 27 )
    {}
    else
        e.preventDefault();
});

var caretPosition = null;

var currentCaseUpper = true;
var currentKeysNumeric = false;
var currentKeysQWERTY = false;
var currentKeysSym = false;

var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

var monthNames = {
    "Jan": 0,
    "Feb": 1,
    "Mar": 2,
    "Apr": 3,
    "May": 4,
    "Jun": 5,
    "Jul": 6,
    "Aug": 7,
    "Sep": 8,
    "Oct": 9,
    "Nov": 10,
    "Dec": 11
};

var timers = {};

var timerHandles = {};

var fieldsets = [];

var navigablefieldsets = [];

var currentPage = 0;

var btnClear, btnBack, btnNext;

var textSize = "24px";

var cursorPos = 0;

var tracker;

var incomplete = false;

var trackingString = "";

var validityTmr;

var overwriteNumber = false;

var validationControl;

var navigatingBack = false;

var summaryHash = {};

var buttonNavigation = false;

if (Object.getOwnPropertyNames(Date.prototype).indexOf("format") < 0) {

    Object.defineProperty(Date.prototype, "format", {
        value: function (format) {
            var date = this;

            var result = "";

            if (!format) {

                format = ""

            }

            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

            var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
                "October", "November", "December"];

            if (format.match(/YYYY\-mm\-dd\sHH\:\MM\:SS/)) {

                result = date.getFullYear() + "-" + padZeros((parseInt(date.getMonth()) + 1), 2) + "-" +
                    padZeros(date.getDate(), 2) + " " + padZeros(date.getHours(), 2) + ":" +
                    padZeros(date.getMinutes(), 2) + ":" + padZeros(date.getSeconds(), 2);

            } else if (format.match(/YYYY\-mm\-dd/)) {

                result = date.getFullYear() + "-" + padZeros((parseInt(date.getMonth()) + 1), 2) + "-" +
                    padZeros(date.getDate(), 2);

            } else if (format.match(/mmm\/d\/YYYY/)) {

                result = months[parseInt(date.getMonth())] + "/" + date.getDate() + "/" + date.getFullYear();

            } else if (format.match(/d\smmmm,\sYYYY/)) {

                result = date.getDate() + " " + monthNames[parseInt(date.getMonth())] + ", " + date.getFullYear();

            } else {

                result = date.getDate() + "/" + months[parseInt(date.getMonth())] + "/" + date.getFullYear();

            }

            return result;
        }
    });

};

function __$(id) {
    return document.getElementById(id);
}

function padZeros(number, positions) {
    var zeros = parseInt(positions) - String(number).length;
    var padded = "";

    for (var i = 0; i < zeros; i++) {
        padded += "0";
    }

    padded += String(number);

    return padded;
}

function padZerosAfter(numberArray) {
    var number;
    var padded;
    if (numberArray[1] == undefined) {
        number = 0;
    } else {
        number = numberArray[1];
    }

    if (String(number).length < 3){
        var zeros = 3 - String(number).length;

        for (var i = 0; i < zeros; i++) {
            number += "0";
        }
      }
    padded = parseFloat(numberArray[0] + "." + number).toFixed(3);

    return padded;
}

function checkCtrl(obj) {
    var o = obj;
    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while ((o ? (o.offsetParent != document.body) : false)) {
        o = o.offsetParent;
        t += (o ? o.offsetTop : 0);
        l += (o ? o.offsetLeft : 0);
    }
    return [w, h, t, l];
}

function init() {
    var style = document.createElement("style");
    style.innerHTML = styles;

    document.head.appendChild(style);

    loadLabels();

    var forms = document.forms;

    for (var i = 0; i < forms.length; i++) {

        forms[i].style.display = "none";

    }

    fieldsets = document.forms[0].getElementsByTagName("fieldset");

    for (var i = 0; i < fieldsets.length; i++) {

        var currentset = fieldsets[i].elements;
        var resultset = [];

        navigablefieldsets.push([]);

        for (var j = 0; j < currentset.length; j++) {

            if (currentset[j].type.toLowerCase() != "hidden") {

                navigablefieldsets[i].push(currentset[j]);

            }

        }

    }

    loadPage(currentPage);

    // validityTmr = setTimeout("checkValidity()", 10);
}

function getCaretPosition (oField) {

    var iCaretPos = 0;

    if (document.selection) {

        oField.focus ();

        var oSel = document.selection.createRange ();

        oSel.moveStart ('character', -oField.value.length);

        iCaretPos = oSel.text.length;
    }

    else if (oField.selectionStart || oField.selectionStart == '0')
        iCaretPos = oField.selectionStart;

    return (iCaretPos);
}

function showFixedKeyboard(ctrl, container, disabled, numbers, caps, symbols) {
    if (ctrl == undefined || container == undefined)
        return;

    container.innerHTML = "";

    if (__$('fixedkeyboard')) {
        document.body.removeChild(__$('fixedkeyboard'));
    }

    if (!__$("main")) {
        var main = document.createElement("div");
        main.id = "main";

        container.appendChild(main);
    }

    if (typeof(target) != 'undefined' && target.id != ctrl.id){

        caretPosition = ctrl.value.length || 0

    }

    target = ctrl;

    target.onmouseup = function(){

        caretPosition = getCaretPosition(this);

    }

    var pos = checkCtrl(ctrl);

    if (typeof(disabled) == 'undefined') disabled = {};

    if (typeof(numbers) == 'undefined') numbers = false;

    if (typeof(symbols) == 'undefined') symbols = false;

    if (typeof(caps) == 'undefined') caps = false;

    currentCaseUpper = caps;

    currentKeysSYM = symbols;

    currentKeysNumeric = numbers;

    var div = document.createElement('div');
    div.id = 'fixedkeyboard';
    div.style.margin = 'auto';
    div.style.width = "600px";
    div.style.borderRadius = '10px';
    div.style.backgroundColor = 'rgba(255,255,255,0.8)';

    container.appendChild(div);

    var keys;

    if (currentKeysNumeric) {

        keys = [
            [1, 2, 3, ':'],
            [4, 5, 6, '/'],
            [7, 8, 9, '.'],
            ['sym', 'del', 0, 'N/A', 'abc']
        ];

    }
    else if (currentKeysSYM){

        keys = [
            ['!', '@', '#', '$', '+', '-'],
            ['{', '}', '*', '(', ')', 'del'],
            [',', ':', ';','%', "'", '/'],
            ['^', '&nbsp;', '123', 'qwe']
        ]

    }else {

        if (currentKeysQWERTY) {

            keys = [
                ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                ["A", "S", "D", "F", "G", "H", "J", "K", "L", 'del'],
                ["Z", "X", "C", "V", "B", "N", "M", 'N/A', "CAP"],
                [".", "-", 'sym', '&nbsp;', "123", "abc"]
            ];

        } else {

            keys = [
                ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"],
                ["K", "L", "M", "N", "O", "P", "Q", "R", "S", 'del'],
                ["T", "U", "V", "W", "X", "Y", "Z", "N/A", "CAP"],
                [".", "-", 'sym', '&nbsp;', "123", "qwe"]
            ];

        }

    }

    var letters = {"A": true, "B": true, "C": true, "D": true, "E": true, "F": true, "G": true, "H": true,
        "I": true, "J": true, "K": true, "L": true, "M": true, "N": true, "O": true, "P": true, "Q": true,
        "R": true, "S": true, "T": true, "U": true, "V": true, "W": true, "X": true, "Y": true, "Z": true, "CAP": true};

    var table = document.createElement('div');
    table.style.display = 'table';
    table.style.margin = 'auto';

    div.appendChild(table);

    for (var i = 0; i < keys.length; i++) {
        var row = document.createElement('div');
        row.style.display = 'table-row';

        table.appendChild(row);

        var mainCell = document.createElement('div');
        mainCell.style.display = 'table-cell';
        mainCell.style.textAlign = "center";
        mainCell.style.padding = "0px";

        row.appendChild(mainCell);

        for (var j = 0; j < keys[i].length; j++) {
            /*var cell = document.createElement('div');
            cell.style.display = 'table-cell';

            row.appendChild(cell);*/

            if (String(keys[i][j]).trim().length == 0) {
                mainCell.innerHTML = "&nbsp;";

                continue;
            }

            var button = document.createElement('button');
            var button = document.createElement('button');
             button.setAttribute('class', (disabled[keys[i][j]] ? 'button gray' : 'button blue'));
            
            if(keys[i][j] == "&nbsp;"){
             button.style.width = "286px";
            }else if(keys[i][j] == "CAP") {
             button.style.width = '112px';
            }else{
             button.style.width = '54px';
            }
            
            button.style.height = '60px';
            button.style.minWidth = '40px';
            button.style.minHeight = '40px';
            button.style.margin = '2px';
            button.style.fontSize = "22px";

            button.id = keys[i][j];

            mainCell.appendChild(button);

            if (target && keys[i][j] == '.') {
                if (target.value.trim().match(/\./) || target.value.trim().length == 0) {
                    button.setAttribute('class', 'button gray');
                } else {
                    button.setAttribute('class', 'button blue');
                }
            }

            if (keys[i][j] == "hide") {

                button.style.fontSize = "0.9em";

            }

            if (letters[keys[i][j]]) {

                button.innerHTML = (String(keys[i][j]).trim().toLowerCase() == "cap" ? (!currentCaseUpper ? String(keys[i][j]).toLowerCase() : String(keys[i][j]).toUpperCase()) : (!currentCaseUpper ? String(keys[i][j]).toUpperCase() : String(keys[i][j]).toLowerCase()));

            } else {

                button.innerHTML = keys[i][j];

            }

            if (disabled[keys[i][j]]) {
                button.setAttribute('class', 'button gray');
            } else {
                button.setAttribute('class', 'button blue');

                button.onmousedown = function () {

                    if (this.innerHTML == 'del') {

                        if (target) {

                            if ("N/A" == target.value.trim()) {

                                target.value = "";

                            } else {

                                deleteText(target, caretPosition);

                            }

                            if(target.getAttribute("target")){

                                if(__$(target.getAttribute("target"))){

                                    __$(target.getAttribute("target")).value = target.value;

                                }

                            }

                        }

                    } else if (this.innerHTML == "N/A") {

                        target.value = "N/A";

                        if(target.getAttribute("target")){

                            if(__$(target.getAttribute("target"))){

                                __$(target.getAttribute("target")).value = target.value;

                            }

                        }

                    }else if (this.innerHTML.trim() == 'sym') {

                        currentKeysSYM = true;

                        currentKeysQWERTY = false;

                        currentKeysNumeric = false;

                        showFixedKeyboard(__$(target.id), container,  disabled, currentKeysNumeric, currentCaseUpper, currentKeysSYM);
                    }else if (this.innerHTML.trim() == '123') {

                        currentKeysNumeric = true;

                        showFixedKeyboard(__$(target.id), container, disabled, currentKeysNumeric, currentCaseUpper);

                    } else if (this.innerHTML.trim() == 'abc') {

                        currentKeysQWERTY = false;

                        currentKeysNumeric = false;

                        showFixedKeyboard(__$(target.id), container, disabled, currentKeysNumeric, currentCaseUpper);

                    } else if (this.innerHTML.trim() == 'qwe') {

                        currentKeysQWERTY = true;

                        currentKeysNumeric = false;

                        showFixedKeyboard(__$(target.id), container, disabled, currentKeysNumeric, currentCaseUpper);

                    } else if (this.innerHTML.trim() == '?') {

                        target.value = "?";

                        if(target.getAttribute("target")){

                            if(__$(target.getAttribute("target"))){

                                __$(target.getAttribute("target")).value = target.value;

                            }

                        }

                    } else if (this.innerHTML.trim().toLowerCase() == 'cap') {
                        currentCaseUpper = !currentCaseUpper;

                        var keys = Object.keys(letters);

                        if (!currentCaseUpper) {

                            for (var l = 0; l < keys.length - 1; l++) {
                                if (__$(keys[l])) {
                                    __$(keys[l]).innerHTML = keys[l].toUpperCase();
                                }
                            }

                            this.innerHTML = "cap";

                        } else {


                            for (var l = 0; l < keys.length - 1; l++) {
                                if (__$(keys[l])) {
                                    __$(keys[l]).innerHTML = keys[l].toLowerCase();
                                }
                            }

                            this.innerHTML = "CAP";

                        }

                    } else if (this.innerHTML.trim() == '&nbsp;') {

                        addText(target, this, caretPosition);

                    } else {

                        if (target.value.trim() == "?" || target.value.trim() == "Unknown" || target.value.trim() == "N/A") {

                            target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                            if(target.getAttribute("target")){

                                if(__$(target.getAttribute("target"))){

                                    __$(target.getAttribute("target")).value = target.value;

                                }

                            }

                        } else {

                            if (overwriteNumber) {

                                target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                                if(target.getAttribute("target")){

                                    if(__$(target.getAttribute("target"))){

                                        __$(target.getAttribute("target")).value = target.value;

                                    }

                                }

                                overwriteNumber = false;

                                if (target.value.trim().length > 0) {

                                    if (__$("CAP") && !currentCaseUpper) {

                                        currentCaseUpper = !currentCaseUpper;

                                        showFixedKeyboard(__$(target.id), container, disabled, currentKeysNumeric, currentCaseUpper);


                                    }

                                }

                            } else {

                                addText(target, this, caretPosition);

                                if(target.getAttribute("target")){

                                    if(__$(target.getAttribute("target"))){

                                        __$(target.getAttribute("target")).value = target.value;

                                    }

                                }

                                if (target.value.trim().length > 0) {

                                    if (__$("CAP") && !currentCaseUpper) {

                                        currentCaseUpper = !currentCaseUpper;

                                        showFixedKeyboard(__$(target.id), container, disabled, currentKeysNumeric, currentCaseUpper);

                                    }

                                }

                            }

                        }

                    }

                    if (!disabled['.'] && __$('.')) {
                        __$('.').setAttribute('class', 'button blue');
                    }

                    if (target.getAttribute("ajaxURL") != null || target.getAttribute("ajaxUrl") != null || target.getAttribute("ajaxurl") != null) {

                        if (target.getAttribute("target") != null) {

                            checkLookup(target.getAttribute("target"));

                        }

                    }

                }
            }


            if (String(keys[i][j]).trim() == "Unknown") {

                button.style.fontSize = "14px";
                mainCell.style.marginTop = "-10px";

            }

            // cell.appendChild(button);
        }
    }

    if (__$("fixedkeyboard")) {

        // [w, h, t, l]
        var kpos = checkCtrl(__$("fixedkeyboard"));
        var w = window.innerWidth;
        var h = window.innerHeight;

        if (kpos[0] + kpos[3] > w) {

            __$("fixedkeyboard").style.left = (w - kpos[0] - 10) + "px";

        }

        if (kpos[1] + kpos[2] > h) {

            __$("fixedkeyboard").style.top = (pos[2] - kpos[1] - 2) + "px";

        }

    }


}

function showKeyboard(ctrl, disabled, numbers, caps, symbols) {

    if (__$('popupkeyboard') && numbers == undefined) {

        document.body.removeChild(__$('popupkeyboard'));

    } else {

        if (__$('popupkeyboard')) {
            document.body.removeChild(__$('popupkeyboard'));
        }

        if (!__$("main")) {
            var main = document.createElement("div");
            main.id = "main";

            document.body.appendChild(main);
        }

        if (typeof(target) != 'undefined' && target.id != ctrl.id){

           caretPosition = ctrl.value.length || 0

       }

         target = ctrl;
 
       target.onmouseup = function(){

           caretPosition = getCaretPosition(this);
       }


        var pos = checkCtrl(ctrl);

        if (typeof(disabled) == 'undefined') disabled = {};

        if (typeof(numbers) == 'undefined') numbers = false;

        if (typeof(symbols) == 'undefined') symbols = false;

        if (typeof(caps) == 'undefined') caps = false;

        currentCaseUpper = caps;

        currentKeysNumeric = numbers;

        currentKeysSYM = symbols;

        var div = document.createElement('div');
        div.id = 'popupkeyboard';
        div.style.position = 'absolute';
        div.style.border = '1px solid #5ca6c4';
        div.style.borderRadius = '10px';
        div.style.left = pos[3] + 'px';
        div.style.top = (pos[2] + pos[1] + 2 - window.scrollY - (__$("display") ? __$("display").scrollTop : 0)) + 'px';
        div.style.zIndex = '1000';
        div.style.backgroundColor = 'rgba(255,255,255,0.8)';

        document.body.appendChild(div);

        var keys;

        if (currentKeysNumeric) {

            keys = [
                [1, 2, 3, ':'],
                [4, 5, 6, '/'],
                [7, 8, 9, '.', 'sym'],
                ['del', 0, '?', 'abc', "hide"]
            ];

        }else if (currentKeysSYM){

            keys = [
                ['!', '@', '#', '$', '%', '-'],
                ['^', '&', '*', '(', ')', 'del'],
                ['?', ':', ';', ',','?', '<']
            ]

        } else {

            if (currentKeysQWERTY) {

                keys = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L", 'del'],
                    ['', "Z", "X", "C", "V", "B", "N", "M", 'N/A', "CAP"],
                    ['sym', '&nbsp;', "'", ".", "-", "num", "abc", "hide"]
                ];

            } else {

                keys = [
                    ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
                    ["J", "K", "L", "M", "N", "O", "P", "Q", "R"],
                    ["S", "T", "U", "V", "W", "X", "Y", "Z", "CAP"],
                    ["sym", "&nbsp;", "'", ".", "-", "num", "qwe", "N/A", 'del', "hide"]
                ];

            }

        }

        var letters = {"A": true, "B": true, "C": true, "D": true, "E": true, "F": true, "G": true, "H": true,
            "I": true, "J": true, "K": true, "L": true, "M": true, "N": true, "O": true, "P": true, "Q": true,
            "R": true, "S": true, "T": true, "U": true, "V": true, "W": true, "X": true, "Y": true, "Z": true, "CAP": true};

        var table = document.createElement('div');
        table.style.display = 'table';
        table.style.margin = 'auto';

        div.appendChild(table);

        for (var i = 0; i < keys.length; i++) {
            var row = document.createElement('div');
            row.style.display = 'table-row';

            table.appendChild(row);

            for (var j = 0; j < keys[i].length; j++) {
                var cell = document.createElement('div');
                cell.style.display = 'table-cell';

                row.appendChild(cell);

                if (String(keys[i][j]).trim().length == 0) {
                    cell.innerHTML = "&nbsp;";

                    continue;
                }

                var button = document.createElement('button');
                button.setAttribute('class', (disabled[keys[i][j]] ? 'button gray' : 'button blue'));
                button.style.width = '65px';
                button.style.height = '60px';
                button.style.minWidth = '40px';
                button.style.minHeight = '40px';
                button.style.margin = '2px';
                button.style.fontSize = "24px";

                button.id = keys[i][j];

                if (target && keys[i][j] == '.') {
                    if (target.value.trim().match(/\./) || target.value.trim().length == 0) {
                        button.setAttribute('class', 'button gray');
                    } else {
                        button.setAttribute('class', 'button blue');
                    }
                }

                if (keys[i][j] == "hide") {

                    button.style.fontSize = "0.9em";

                }

                if (letters[keys[i][j]]) {

                    button.innerHTML = (String(keys[i][j]).trim().toLowerCase() == "cap" ? (!currentCaseUpper ? String(keys[i][j]).toLowerCase() : String(keys[i][j]).toUpperCase()) : (!currentCaseUpper ? String(keys[i][j]).toUpperCase() : String(keys[i][j]).toLowerCase()));

                } else {

                    button.innerHTML = keys[i][j];

                }

                if (disabled[keys[i][j]]) {
                    button.setAttribute('class', 'button gray');
                } else {
                    button.setAttribute('class', 'button blue');

                    button.onmousedown = function () {

                        if (this.innerHTML == 'del') {

                            if (target) {

                                if ("N/A" == target.value.trim()) {

                                    target.value = "";

                                } else {

                                    deleteText(target, caretPosition);

                                }

                                if(target.getAttribute("target")){

                                    if(__$(target.getAttribute("target"))){

                                        __$(target.getAttribute("target")).value = target.value;

                                    }

                                }

                            }

                        } else if (this.innerHTML == "N/A") {

                            target.value = "N/A";

                            if(target.getAttribute("target")){

                                if(__$(target.getAttribute("target"))){

                                    __$(target.getAttribute("target")).value = target.value;

                                }

                            }

                        } else if (this.innerHTML.trim() == 'hide') {

                            if (__$("shield")) {

                                if (__$("popup")) {

                                    document.body.removeChild(__$("popup"));

                                }

                                if (__$("popupkeyboard")) {

                                    var action = __$("shield").getAttribute("action");

                                    if (action != null) {

                                        eval(action);

                                    }

                                    document.body.removeChild(__$('popupkeyboard'));

                                }

                                document.body.removeChild(__$("shield"));

                                return;

                            } else if (__$('popupkeyboard')) {
                                document.body.removeChild(__$('popupkeyboard'));

                                return;
                            }

                        } else if (this.innerHTML.trim() == 'num') {

                            currentKeysNumeric = true;

                            showKeyboard(__$(target.id), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == 'abc') {

                            currentKeysQWERTY = false;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == 'sym') {

                            currentKeysSYM = true;

                            currentKeysQWERTY = false;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), disabled, currentKeysNumeric, currentCaseUpper, currentKeysSYM);

                        }else if (this.innerHTML.trim() == 'qwe') {

                            currentKeysQWERTY = true;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == '?') {

                            target.value = "?";

                            if(target.getAttribute("target")){

                                if(__$(target.getAttribute("target"))){

                                    __$(target.getAttribute("target")).value = target.value;

                                }

                            }

                        } else if (this.innerHTML.trim() == '&nbsp;') {

                            addText(target, this, caretPosition);


                        }else if (this.innerHTML.trim().toLowerCase() == 'cap') {
                            currentCaseUpper = !currentCaseUpper;

                            var keys = Object.keys(letters);

                            if (!currentCaseUpper) {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toUpperCase();
                                    }
                                }

                                this.innerHTML = "cap";

                            } else {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toLowerCase();
                                    }
                                }

                                this.innerHTML = "CAP";

                            }

                        } else if (this.innerHTML.trim() == '&nbsp;') {

                            addText(target, this, caretPosition);

                            if(target.getAttribute("target")){

                                if(__$(target.getAttribute("target"))){

                                    __$(target.getAttribute("target")).value = target.value;

                                }

                            }

                        } else {

                            if (target.value.trim() == "?" || target.value.trim() == "Unknown" || target.value.trim() == "N/A") {

                                target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                                if(target.getAttribute("target")){

                                    if(__$(target.getAttribute("target"))){

                                        __$(target.getAttribute("target")).value = target.value;

                                    }

                                }

                                if (overwriteNumber){

                                    overwriteNumber = false;

                                }

                            } else {

                                if (overwriteNumber) {

                                    target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                                    if(target.getAttribute("target")){

                                        if(__$(target.getAttribute("target"))){

                                            __$(target.getAttribute("target")).value = target.value;

                                        }

                                    }

                                    overwriteNumber = false;

                                } else {

                                    addText(target, this, caretPosition);

                                    if(target.getAttribute("target")){

                                        if(__$(target.getAttribute("target"))){

                                            __$(target.getAttribute("target")).value = target.value;

                                        }

                                    }

                                }

                            }

                        }

                        if (!disabled['.']) {
                            __$('.').setAttribute('class', 'button blue');
                        }

                        if (target.getAttribute("ajaxURL") != null || target.getAttribute("ajaxUrl") != null || target.getAttribute("ajaxurl") != null) {

                            if (target.getAttribute("target") != null) {

                                checkLookup(target.getAttribute("target"));

                            }

                        }

                    }
                }


                if (String(keys[i][j]).trim() == "Unknown") {

                    button.style.fontSize = "14px";
                    cell.style.marginTop = "-10px";

                }

                cell.appendChild(button);
            }
        }

        if (__$("popupkeyboard")) {

            // [w, h, t, l]
            var kpos = checkCtrl(__$("popupkeyboard"));
            var w = window.innerWidth;
            var h = window.innerHeight;

            if (kpos[0] + kpos[3] > w) {

                __$("popupkeyboard").style.left = (w - kpos[0] - 10) + "px";

            }

            if (kpos[1] + kpos[2] > h) {

                __$("popupkeyboard").style.top = (pos[2] - kpos[1] - 2) + "px";

            }

        }

    }


}


function deleteText(node, pos){

    if (pos == null) {
        pos = node.value.length || 0;
    }

    if (caretPosition == 0){
        return;
    }

    var stringA = node.value.substring(0, pos);
    var stringB = node.value.substring(pos, node.value.length);

    if (stringA.length > 0) {
        stringA = stringA.substring(0, (stringA.length - 1));
    }

    caretPosition = stringA.length;

    node.value = stringA + stringB;

}

function addText(node, buttn, pos){

    if (pos == null) {
        pos = node.value.length || 0;
    }

    var stringA = node.value.substring(0, pos);
    var stringB = node.value.substring(pos, node.value.trim().length);

    stringA = stringA + (currentCaseUpper ? buttn.innerHTML.toLowerCase().replace("&nbsp;", ' ') : buttn.innerHTML.replace("&nbsp;", ' '));

    caretPosition = stringA.length;

    node.value = stringA + stringB;

}

function loadLabels() {
    var labels = document.getElementsByTagName('LABEL');
    for (var i = 0; i < labels.length; i++) {
        if (labels[i].htmlFor != '') {
            var elem = document.getElementById(labels[i].htmlFor);
            if (elem)
                elem.label = labels[i];
        }
    }
}

function addTimer(parent, limit, label, scale) {

    if (parent == undefined || limit == undefined || label == undefined) {
        return;
    }

    var tbl = document.createElement("div");
    tbl.style.display = "table";
    tbl.style.borderSpacing = (5 * scale) + "px";
    tbl.style.width = (400 * scale) + "px";

    tbl.style.border = "1px solid #3465a4";
    tbl.style.borderRadius = (10 * scale) + "px";

    parent.appendChild(tbl);

    var row1 = document.createElement("div");
    row1.style.display = "table-row";

    tbl.appendChild(row1);

    var row2 = document.createElement("div");
    row2.style.display = "table-row";

    tbl.appendChild(row2);

    var row3 = document.createElement("div");
    row3.style.display = "table-row";

    tbl.appendChild(row3);

    var cell1 = document.createElement("div");
    cell1.style.display = "table-cell";
    cell1.style.textAlign = "left";
    cell1.style.verticalAlign = "middle";
    cell1.style.fontSize = (18 * scale) + "px";
    cell1.style.padding = (10 * scale) + "px";

    row1.appendChild(cell1);

    addLabel(cell1, label, (2.5 * scale) + "em");

    var cell2 = document.createElement("div");
    cell2.style.display = "table-cell";
    cell2.style.textAlign = "center";
    cell2.style.verticalAlign = "middle";
    cell2.style.padding = (10 * scale) + "px";
    cell2.style.paddingLeft = (60 * scale) + "px";
    cell2.style.paddingRight = (60 * scale) + "px";
    cell2.style.paddingBottom = "0px";

    row2.appendChild(cell2);

    var disc = document.createElement("div");
    disc.style.border = "2px solid #3465a4";
    disc.style.padding = (20 * scale) + "px";
    disc.style.fontSize = (120 * scale) + "px";
    disc.style.width = (350 * scale) + "px";
    disc.style.height = (350 * scale) + "px";
    disc.style.borderRadius = (350 * scale) + "px";
    disc.style.verticalAlign = "middle";
    disc.style.textAlign = "center";
    disc.style.marginBottom = (-40 * scale) + "px";

    cell2.appendChild(disc);

    var time = document.createElement("div");
    time.style.marginTop = (100 * scale) + "px";
    time.id = "time" + parent.id;
    time.innerHTML = "00:00";

    disc.appendChild(time);

    var cell3 = document.createElement("div");
    cell3.style.display = "cell";
    cell3.style.textAlign = "right";
    cell3.style.paddingBottom = (10 * scale) + "px";
    cell3.style.paddingRight = (10 * scale) + "px";
    cell3.id = "cell3_" + parent.id;

    row3.appendChild(cell3);

    var btn = addButton(cell3, "Start", "green");

    btn.style.width = (100 * scale) + "px";
    btn.setAttribute("limit", limit);
    btn.id = "btnTmr" + parent.id;
    btn.setAttribute("target", parent.id);

    btn.style.fontSize = (28 * scale) + "px";

    btn.style.minWidth = (100 * scale) + "px";

    btn.style.minHeight = (60 * scale) + "px";

    btn.style.width = (100 * scale) + "px";

    btn.style.height = (80 * scale) + "px";

    btn.onmousedown = function () {

        countDown(this.getAttribute('target'), this.getAttribute('limit'))

    }

    return tbl;

}

function countDown(id, limit) {

    clearTimeout(timerHandles[id]);

    if (timers[id] == undefined) {

        if (limit != undefined) {

            timers[id] = parseInt(limit) * 60;

            if (__$("btnTmr" + id)) {

                __$("btnTmr" + id).className = "button red";

                __$("btnTmr" + id).innerHTML = "Stop";

                __$("btnTmr" + id).onmousedown = function () {

                    if (this.innerHTML.trim().toLowerCase() == "reset") {

                        this.innerHTML = "Start";

                        this.className = "button green";

                        if (__$("time" + this.getAttribute('target'))) {

                            __$("time" + this.getAttribute('target')).innerHTML = "00:00";

                        }

                        this.onmousedown = function () {

                            countDown(this.getAttribute('target'), this.getAttribute('limit'));

                        }

                    } else {

                        clearTimeout(timerHandles[this.getAttribute("target")]);

                        delete timers[this.getAttribute("target")];

                        this.innerHTML = "Reset";

                    }

                }

            }

        }

    } else {

        timers[id] -= 1;

    }

    var seconds = timers[id] % (60);

    var minutes = (timers[id] - seconds) / (60);

    if (__$("time" + id)) {

        __$("time" + id).innerHTML = padZeros(minutes, 2) + ":" + padZeros(seconds, 2);

    }

    if (timers[id] <= 0) {

        delete timers[id];

        if (__$("btnTmr" + id)) {

            __$("btnTmr" + id).innerHTML = "Start";

            __$("btnTmr" + id).className = "button green";

            if (__$("time" + id)) {

                __$("time" + id).innerHTML = "00:00";

            }

            __$("btnTmr" + id).onmousedown = function () {

                countDown(this.getAttribute('target'), this.getAttribute('limit'));

            }
        }

    } else {

        timerHandles[id] = setTimeout("countDown('" + id + "', '" + limit + "')", 1000);

    }

}

function addAge(parent, target, date, label1, label2) {

    if (parent == undefined || target == undefined || label1 == undefined || label2 == undefined) {
        return;
    }

    parent.innerHTML = "";

    var fontsize = "20px";

    var tbl = document.createElement("div");
    tbl.style.display = "table";
    tbl.style.borderSpacing = "5px";
    tbl.style.margin = "auto";

    tbl.style.borderRadius = "10px";

    parent.appendChild(tbl);

    var row1 = document.createElement("div");
    row1.style.display = "table-row";

    tbl.appendChild(row1);

    var cell1_1 = document.createElement("div");
    cell1_1.style.display = "table-cell";
    cell1_1.id = "cell1_1_" + target.id;
    cell1_1.style.padding = "10px";
    cell1_1.style.fontStyle = "italic";
    cell1_1.style.textAlign = "center";
    cell1_1.style.fontSize = fontsize;

    row1.appendChild(cell1_1);

    addLabel(cell1_1, label1, fontsize);

    var cell1_2 = document.createElement("div");
    cell1_2.style.fontWeight = "bold";
    cell1_2.style.fontStyle = "italic";
    cell1_2.style.textAlign = "center";
    cell1_2.style.padding = "10px";
    cell1_2.innerHTML = "OR";
    cell1_2.style.fontSize = fontsize;

    row1.appendChild(cell1_2);

    var cell1_3 = document.createElement("div");
    cell1_3.style.display = "table-cell";
    cell1_3.id = "cell1_3_" + target.id;
    cell1_3.style.padding = "10px";
    cell1_3.style.fontStyle = "italic";
    cell1_3.style.textAlign = "center";
    cell1_3.style.fontSize = fontsize;

    row1.appendChild(cell1_3);

    addLabel(cell1_3, label2, fontsize);

    var row2 = document.createElement("div");
    row2.style.display = "table-row";

    tbl.appendChild(row2);

    var cell2_1 = document.createElement("div");
    cell2_1.style.display = "table-cell";
    cell2_1.id = "cell2_1_" + target.id;
    cell2_1.style.textAlign = "center";

    row2.appendChild(cell2_1);

    addDate(cell2_1, target, date);

    var cell2_2 = document.createElement("div");
    cell2_2.style.display = "table-cell";
    cell2_2.id = "cell2_2_" + target.id;
    cell2_2.style.textAlign = "center";
    cell2_2.innerHTML = "&nbsp;";

    row2.appendChild(cell2_2);

    var cell2_3 = document.createElement("div");
    cell2_3.style.display = "table-cell";
    cell2_3.id = "cell2_3_" + target.id;
    cell2_3.style.textAlign = "center";
    cell2_3.style.verticalAlign = "middle";

    row2.appendChild(cell2_3);

    var age = addTextbox(cell2_3, "number", target);

    age.style.width = "100px";
    age.style.fontSize = "24px";
    age.style.textAlign = "center";
    age.setAttribute("target", target.id);
    age.id = "age" + target.id;

    age.onmousedown = function () {

        overwriteNumber = true;

        if (__$('popupkeyboard')) {

            document.body.removeChild(__$('popupkeyboard'));

        } else {

            showKeyboard(__$('age' + this.getAttribute('target')), { '/': '/', '.': '.', 'abc': 'abc'}, true);

        }

        showShield("checkDate('" + this.getAttribute('target') + "', true)");

        checkDate(this.getAttribute('target'), true);

    }
}

function addDate(parent, target, date) {
    if (parent == undefined || target == undefined) {
        return;
    }

    var currentdate;

    if (date == undefined || date == null || date.trim().length == 0) {

        if (target.value.trim().match(/^(\d|\d{2}|\?)\/([A-Za-z]{3}|\?)\/(\d{4}|\?)$/)) {
            currentdate = target.value.trim().split("/");

            date = new Date(currentdate[2] + "-" + padZeros((monthNames[currentdate[1]] + 1), 2) + "-" + padZeros(parseInt(currentdate[0]), 2));
        } else {

            date = new Date();

        }

    } else if (target.value.trim().match(/^(\d|\d{2}|\?)\/([A-Za-z]{3}|\?)\/(\d{4}|\?)$/)) {
        currentdate = target.value.trim().split("/");

        date = new Date(currentdate[2] + "-" + padZeros((monthNames[currentdate[1]] + 1), 2) + "-" + padZeros(parseInt(currentdate[0]), 2));
    } else {

        date = new Date(date);

    }

    var tbl = document.createElement("div");
    tbl.style.display = "table";
    tbl.style.borderSpacing = "5px";

    parent.appendChild(tbl);

    var cells;

    if (target.id == "person_birthdate") {

        cells = [
            [

                {
                    "type": "button",
                    "id": "btnAddYearFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementYear(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnAddMonthFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementMonth(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnAddDateFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementDate(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                }
                ,
                {
                    "type": "hidden"

                }


            ],
            [

                {
                    "type": "input",
                    "id": "txtYearFor" + target.id,
                    "target": target.id,
                    "value": (!isNaN(date.getFullYear()) ? date.getFullYear() : (currentdate.length == 3 ? currentdate[2] : "?")),
                    "onmousedown": "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtYearFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc','sym':'sym'},true);} checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                },
                {
                    "type": "input",
                    "id": "txtMonthFor" + target.id,
                    "target": target.id,
                    "value": (typeof(months[date.getMonth()]) != "undefined" ? months[date.getMonth()] : (currentdate.length == 3 ? currentdate[1] : "?")),
                    "onmousedown": "showShield(); addList(__$('txtMonthFor' + this.getAttribute('target')),{'Jan':'January','Feb':'February','Mar':'March','Apr':'April','May':'May','Jun':'June','Jul':'July','Aug':'August','Sep':'September','Oct':'October','Nov':'November','Dec':'December','?':'Unknown'},'single',__$('txtMonthFor' + this.getAttribute('target')),__$('txtMonthFor' + this.getAttribute('target')), 'checkDate(\"' + this.getAttribute('target') + '\")'); checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                },
                {
                    "type": "input",
                    "id": "txtDateFor" + target.id,
                    "target": target.id,
                    "value": (!isNaN(date.getDate()) ? date.getDate() : (currentdate.length == 3 ? currentdate[0] : "?")),
                    "onmousedown": "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtDateFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc','sym':'sym'},true);} checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                }
                ,
                {
                    "type": "button",
                    "id": "btnToday" + target.id,
                    "target": target.id,
                    "value": "Today",
                    "onclick": "getCurrentDate(this.getAttribute('target'))",
                    "class": "button green",
                    "style": "height: 58px; margin: auto; width: 100%;"
                }
            ],
            [
                {
                    "type": "button",
                    "id": "btnSubtractYearFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementYear(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnSubtractMonthFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementMonth(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnSubtractDateFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementDate(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                }
                ,
                {
                    "type": "hidden"
                }

            ]
        ];

    } else {

        cells = [
            [

                {
                    "type": "button",
                    "id": "btnAddYearFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementYear(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnAddMonthFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementMonth(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnAddDateFor" + target.id,
                    "target": target.id,
                    "value": "+",
                    "onmousedown": "incrementDate(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                }


            ],
            [

                {
                    "type": "input",
                    "id": "txtYearFor" + target.id,
                    "target": target.id,
                    "value": (!isNaN(date.getFullYear()) ? date.getFullYear() : (currentdate.length == 3 ? currentdate[2] : "?")),
                    "onmousedown": "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtYearFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc','sym':'sym'},true);} checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                },
                {
                    "type": "input",
                    "id": "txtMonthFor" + target.id,
                    "target": target.id,
                    "value": (typeof(months[date.getMonth()]) != "undefined" ? months[date.getMonth()] : (currentdate.length == 3 ? currentdate[1] : "?")),
                    "onmousedown": "showShield(); addList(__$('txtMonthFor' + this.getAttribute('target')),{'Jan':'January','Feb':'February','Mar':'March','Apr':'April','May':'May','Jun':'June','Jul':'July','Aug':'August','Sep':'September','Oct':'October','Nov':'November','Dec':'December','?':'Unknown'},'single',__$('txtMonthFor' + this.getAttribute('target')),__$('txtMonthFor' + this.getAttribute('target')), 'checkDate(\"' + this.getAttribute('target') + '\")'); checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                },
                {
                    "type": "input",
                    "id": "txtDateFor" + target.id,
                    "target": target.id,
                    "value": (!isNaN(date.getDate()) ? date.getDate() : (currentdate.length == 3 ? currentdate[0] : "?")),
                    "onmousedown": "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtDateFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc','sym':'sym'},true);} checkDate(this.getAttribute('target'));",
                    "class": "input_date_cell",
                    "style": "font-size: 24px; text-align: center; width: 80%;"
                }


            ],
            [
                {
                    "type": "button",
                    "id": "btnSubtractYearFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementYear(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnSubtractMonthFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementMonth(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                },
                {
                    "type": "button",
                    "id": "btnSubtractDateFor" + target.id,
                    "target": target.id,
                    "value": "-",
                    "onmousedown": "decrementDate(this.getAttribute('target'))",
                    "class": "button blue",
                    "style": "height: 60px; margin: auto; width: 96%;"
                }


            ]
        ];

    }

    for (var i = 0; i < cells.length; i++) {
        var row = document.createElement("div");
        row.style.display = "table-row";

        tbl.appendChild(row);

        for (var j = 0; j < cells[i].length; j++) {
            var cell = document.createElement("div");
            cell.style.display = "table-cell";
            cell.style.width = "140px";
            cell.style.textAlign = "center";

            row.appendChild(cell);

            var input = document.createElement("input");

            for (var key in cells[i][j]) {
                input.setAttribute(key, cells[i][j][key]);
            }

            cell.appendChild(input);
        }
    }

    return tbl;
}

function incrementYear(id) {
    if (__$("txtYearFor" + id)) {
        var yr = parseInt(__$("txtYearFor" + id).value.trim());

        yr++;

        __$("txtYearFor" + id).value = yr;

        checkDate(id);
    }
}

function decrementYear(id) {
    if (__$("txtYearFor" + id)) {
        var yr = parseInt(__$("txtYearFor" + id).value.trim());

        yr--;

        __$("txtYearFor" + id).value = yr;

        checkDate(id);
    }
}

function incrementMonth(id) {
    if (__$("txtMonthFor" + id)) {
        var month = monthNames[__$("txtMonthFor" + id).value.trim()];

        if (month + 1 < 12) {
            month++;
        } else {
            month = 0;
        }

        __$("txtMonthFor" + id).value = months[month];

        checkDate(id);
    }
}

function decrementMonth(id) {
    if (__$("txtMonthFor" + id)) {
        var month = monthNames[__$("txtMonthFor" + id).value.trim()];

        if (month - 1 >= 0) {
            month--;
        } else {
            month = 11;
        }

        __$("txtMonthFor" + id).value = months[month];

        checkDate(id);
    }
}

function incrementDate(id) {
    if (__$("txtDateFor" + id)) {
        var value = parseInt(__$("txtDateFor" + id).value.trim());

        var month = monthNames[__$("txtMonthFor" + id).value.trim()];

        if (month + 2 < 12) {
            month += 2;
        } else {
            month = 1;
        }

        var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

        date.setDate(date.getDate() - 1);

        if (value + 1 <= date.getDate()) {
            value++;
        } else {
            value = 1;
        }

        __$("txtDateFor" + id).value = value;

        checkDate(id);
    }
}

function decrementDate(id) {
    if (__$("txtDateFor" + id)) {
        var value = parseInt(__$("txtDateFor" + id).value.trim());

        var month = monthNames[__$("txtMonthFor" + id).value.trim()];

        if (month + 2 < 12) {
            month += 2;
        } else {
            month = 1;
        }

        var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

        date.setDate(date.getDate() - 1);

        if (value - 1 > 0) {
            value--;
        } else {
            value = date.getDate();
        }

        __$("txtDateFor" + id).value = value;


        checkDate(id);
    }
}

function getCurrentDate(id) {
    var today = new Date();
    var day = today.getDate();
    var month = today.getMonth();
    var year = today.getFullYear();

    __$("txtDateFor" + id).value = day;
    __$("txtMonthFor" + id).value = months[month];
    __$("txtYearFor" + id).value = year;

    checkDate(id);

}

function checkDate(id, byAge) {

    if (__$("txtDateFor" + id) && __$("txtYearFor" + id) && __$("txtMonthFor" + id)) {

        if (byAge == undefined || byAge == false) {

            if (!__$("txtYearFor" + id).value.trim().match(/^\d{4}$/)) {

                __$("txtYearFor" + id).value = "?";

                __$("txtMonthFor" + id).value = "?";

                __$("txtDateFor" + id).value = "?";

                if (__$(id)) {

                      __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("textFor" + id)) {

                    __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("age" + id)) {

                    __$("age" + id).value = "";

                }

                return;

            }

            if (__$("txtMonthFor" + id).value.trim() == "?") {

                __$("txtMonthFor" + id).value = "?";

                __$("txtDateFor" + id).value = "?";

                if (__$(id)) {

                    __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("textFor" + id)) {

                    __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("age" + id)) {

                    var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);

                    var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);

                    __$("age" + id).value = Math.round(age);

                }

                return;

            }

            if (__$("txtDateFor" + id).value.trim() == "?") {

                __$("txtDateFor" + id).value = "?";

                if (__$(id)) {

                    __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("textFor" + id)) {

                    __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("age" + id)) {

                    var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);

                    var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);

                    __$("age" + id).value = Math.round(age);

                }

                return;

            }

            var value = parseInt(__$("txtDateFor" + id).value.trim());

            var month = monthNames[__$("txtMonthFor" + id).value.trim()];

            if (month + 1 < 12) {
                month += 2;
            } else {
                month = 1;
            }

            var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

            date.setDate(date.getDate() - 1);

            if (value > date.getDate()) {
                value = date.getDate();
            }

            __$("txtDateFor" + id).value = value;

            if (__$(id)) {

                __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

            }

            if (__$("textFor" + id)) {

                __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

            }

            if (__$("age" + id)) {

                var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((month - 1 < 1 ? 12 : (month - 1)), 2) + "-" + padZeros(parseInt(__$("txtDateFor" + id).value.trim()), 2);

                var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);

                __$("age" + id).value = Math.round(age);

            }

        } else {

            if (__$("age" + id)) {

                var age = parseInt(__$("age" + id).value);

                if (!isNaN(age)) {

                    var yrs = (new Date()).getFullYear() - age;

                    __$("txtYearFor" + id).value = yrs;

                    __$("txtMonthFor" + id).value = "?";

                    __$("txtDateFor" + id).value = "?";

                } else {

                    __$("txtYearFor" + id).value = "?";

                    __$("txtMonthFor" + id).value = "?";

                    __$("txtDateFor" + id).value = "?";

                }
            }

            if (__$(id)) {

                if (!__$("txtYearFor" + id).value.trim().match(/^\d{4}$/)) {

                    __$("txtYearFor" + id).value = "?";

                    __$("txtMonthFor" + id).value = "?";

                    __$("txtDateFor" + id).value = "?";

                    if (__$(id)) {

                        __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    if (__$("age" + id)) {

                        __$("age" + id).value = "";

                    }

                    if (__$("textFor" + id)) {

                        __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    return;

                }

                if (__$("txtMonthFor" + id).value.trim() == "?") {

                    __$("txtMonthFor" + id).value = "?";

                    __$("txtDateFor" + id).value = "?";

                    if (__$(id)) {

                        __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    if (__$("age" + id)) {

                        var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);

                        var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);

                        __$("age" + id).value = Math.round(age);

                    }

                    if (__$(id)) {

                        __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    if (__$("textFor" + id)) {

                        __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    return;

                }

                if (__$("txtDateFor" + id).value.trim() == "?") {

                    __$("txtDateFor" + id).value = "?";

                    if (__$(id)) {

                        __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    if (__$("age" + id)) {

                        var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);

                        var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);

                        __$("age" + id).value = Math.round(age);

                    }

                    if (__$(id)) {

                        __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    if (__$("textFor" + id)) {

                        __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                    }

                    return;

                }

                var value = parseInt(__$("txtDateFor" + id).value.trim());

                var month = monthNames[__$("txtMonthFor" + id).value.trim()];

                if (month + 1 < 12) {
                    month += 2;
                } else {
                    month = 1;
                }

                var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

                date.setDate(date.getDate() - 1);

                if (value > date.getDate()) {
                    value = date.getDate();
                }

                __$("txtDateFor" + id).value = value;

                if (__$(id)) {

                    __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                if (__$("textFor" + id)) {

                    __$("textFor" + id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

                }

                // __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

            }

        }
    }

}

/*
 parent:   control to attach to
 boxType:  type of textbox [text|password|barcode|number]
 [target]:   control to update onchange (OPTIONAL)
 [callback]: callback function to call when barcode scanned (OPTIONAL)
 */
function addTextbox(parent, boxType, target, callback) {
    if (parent == undefined || target == undefined) {
        return;
    }

    if (boxType == undefined) {

        if (__$(target)) {

            if (__$(target).type != undefined && __$(target).type.toLowerCase() == "password") {

                boxType = "password";

            } else if (__$(target).type != undefined && __$(target).type.toLowerCase() == "barcode") {

                boxType = "barcode";

            } else if (__$(target).type != undefined && __$(target).type.toLowerCase() == "number") {

                boxType = "number";

            } else {

                boxType = "text";

            }

        } else {

            boxType = "text";

        }

    }

    var txt = document.createElement("input");
    txt.style.fontSize = "1.2em";
    txt.style.padding = "10px";
    txt.style.border = "1px solid #3465a4";
    txt.style.borderRadius = "10px";
    txt.style.width = "98.5%";
    txt.style.margin = "auto";
    txt.setAttribute("target", target.id);
    txt.setAttribute("fieldtype", boxType.toLowerCase());

    parent.appendChild(txt);

    /*txt.onchange = function () {
        if (__$(this.getAttribute("target"))) {
            __$(this.getAttribute("target")).value = this.value;
        }
    }

    txt.onkeyup = function () {
        if (__$(this.getAttribute("target"))) {
            __$(this.getAttribute("target")).value = this.value;
        }
    }*/

    switch (boxType.toLowerCase()) {
        case "password":
            txt.setAttribute("type", "password");

            break;
        case "number":
            txt.setAttribute("type", "number");

            break;
        case "barcode":

            if (callback != undefined) {
                // eval(callback);

                txt.setAttribute("callback", callback);

            }

        default:
            txt.setAttribute("type", "text");

            break;
    }

    return txt;

}

function addList(parent, options, optionType, target1, target2, action, lHeight, lWidth) {
    if (parent == undefined || options == undefined || target1 == undefined || target2 == undefined || optionType == undefined) {
        return;
    }

    var id = parent.id;

    if (__$(id)) {

        if (__$("popupkeyboard")) {

            document.body.removeChild(__$("popupkeyboard"));

        } else {

            var pos = checkCtrl(__$(id));
            var list = document.createElement("div");
            list.style.position = "absolute";
            list.style.border = "1px solid #999";
            list.style.boxShadow = "inset 0px 11px 8px -10px #CCC, inset 0px -11px 8px -10px #CCC";
            list.style.width = (lWidth != undefined ? lWidth : "300px");
            list.style.height = (lHeight != undefined ? lHeight : "618px");
            list.id = "popupkeyboard";
            list.style.left = (pos[3]) + "px";
            list.style.top = (pos[2] + pos[1] - (__$("main-content-area") ? __$("main-content-area").scrollTop : 0)) + "px";
            list.style.backgroundColor = "#fff";
            list.style.overflow = "auto";

            document.body.appendChild(list);

            addCombo(list, options, optionType, target1, target2, (optionType == "single" ? true : false), id, action);

            // [w, h, t, l]
            var lpos = checkCtrl(__$("popupkeyboard"));
            var w = window.innerWidth;
            var h = window.innerHeight;

            if (lpos[0] + lpos[3] > w) {

                __$("popupkeyboard").style.left = (w - lpos[0] - 10) + "px";

            }

            if (lpos[1] + lpos[2] > h) {

                if ((pos[2] - lpos[1] + 5) < 0) {

                    __$("popupkeyboard").style.top = (pos[2] - lpos[1] + ((pos[2] - lpos[1] - 5) * -1)) + "px";

                } else {

                    __$("popupkeyboard").style.top = (pos[2] - lpos[1] - 2) + "px";

                }

            }

        }
    }

}

/*
 parent:       control to attach to
 options:      value:display associative array e.g. {"F":"Female","M":"Male"}
 optionType:   [single|multiple] for single or multiple selection with
 default single selection
 target1:       target display control to receive value
 target2:       target hidden control to receive value
 */
function addCombo(parent, options, optionType, target1, target2, collapseOnClick, id, action, selected) {
    if (parent == undefined || options == undefined || target1 == undefined || target2 == undefined || optionType == undefined) {

        return;
    }

    if (collapseOnClick == undefined) {

        collapseOnClick = false;

    }

    if (id == undefined) {

        id = null;

    }

    if (action == undefined) {

        action = null;

    }

    if (selected == undefined) {

        selected = {};

    }

    var base = document.createElement("div");
    base.style.width = "100%";
    base.style.height = "100%"; // "618px";
    base.style.overflow = "auto";

    parent.appendChild(base);

    var ul = document.createElement("ul");
    ul.style.marginTop = "0px";
    ul.style.marginBottom = "5px";
    ul.style.paddingLeft = "0px";
    ul.style.paddingTop = "0px";

    var uls = document.getElementsByTagName("ul");

    ul.id = "ul" + (uls.length + 1);

    base.appendChild(ul);

    var i = 0;

    for (var key in options) {
        var li = document.createElement("li");
        li.style.color = "black";
        li.style.listStyle = "none";
        li.style.paddingLeft = "5px";
        li.style.paddingRight = "5px";
        li.style.marginTop = "2px";
        li.style.marginBottom = "2px";
        li.style.fontFamily = '"Nimbus Sans L","Arial Narrow",sans-serif';
        li.style.fontSize = "28px";
        li.style.padding = "20px";
        li.style.cursor = "pointer";
        li.setAttribute("target", ul.id);
        li.setAttribute("collapseonclick", collapseOnClick);
        li.setAttribute("parent", id);
        li.setAttribute("action", action);

        li.setAttribute("tag", (i % 2 > 0 ? "odd" : "even"));

        if (selected[key]) {

            li.style.backgroundColor = "lightblue";
            li.setAttribute("selecttag", true);
            li.style.color = "black";

        } else {

            li.style.backgroundColor = (i % 2 > 0 ? "#eee" : "");

        }

        li.onmouseover = function () {
            if (this.getAttribute("selecttag") == null) {
                this.style.backgroundColor = "#999";
                this.style.color = "#eee";
            }
        }

        li.onmouseout = function () {
            if (this.getAttribute("selecttag") == null) {
                if (this.getAttribute("tag") == "odd") {
                    this.style.backgroundColor = "#eee";
                } else {
                    this.style.backgroundColor = "";
                }
                this.style.color = "#000";
            }
        }

        li.setAttribute("value", key);
        li.innerHTML = options[key];

        ul.appendChild(li);

        switch (optionType.toLowerCase()) {
            case "single":
                actOnSingle(li, target1, target2);
                break;
            case "multiple":
                actOnMultiple(li, target1, target2);
                break;
        }

        i++;
    }

    return ul;
}

function actOnSingle(li, target1, target2) {
    if (li == undefined || target1 == undefined || target2 == undefined) {
        return;
    }

    li.onmousedown = function () {
        if (this.getAttribute("target") != null) {
            if (__$(this.getAttribute("target"))) {
                var opts = __$(this.getAttribute("target")).children;

                for (var i = 0; i < opts.length; i++) {
                    if (opts[i].getAttribute("selecttag") != null) {
                        opts[i].removeAttribute("selecttag");
                        opts[i].style.backgroundColor = (opts[i].getAttribute("tag") == "odd" ? "#eee" : "");

                        target1.value = "";
                        target2.value = "";
                    }
                }
            }

            this.setAttribute("selecttag", true);
            this.style.backgroundColor = "lightblue";
            this.style.color = "black";
            target1.value = this.innerHTML;
            target2.value = this.getAttribute("value");

            if (this.getAttribute("collapseonclick") != null && this.getAttribute("collapseonclick") == "true") {

                eval(this.getAttribute("action"));

                if (__$("popupkeyboard"))
                    document.body.removeChild(__$("popupkeyboard"));

                if (__$("shield")) {

                    showShield();

                }

            } else if (this.getAttribute("action") != null) {

                eval(this.getAttribute("action"));

            }

            checkConditions();
        }
    }
}

function actOnMultiple(li, target1, target2) {
    if (li == undefined || target1 == undefined || target2 == undefined) {
        return;
    }

    li.onmousedown = function () {
        var t1 = target1.value.split(";");
        var t2 = [];
        var opts = target2.options;

        for (var i = 0; i < opts.length; i++) {

            if (opts[i].selected) {

                t2.push(opts[i].value);

            }

        }

        var h1 = {};
        var h2 = {};

        for (var i = 0; i < t1.length; i++) {

            if (t1[i].trim().length > 0)
                h1[t1[i]] = true;

            if (t2[i] != undefined && t2[i].trim().length > 0)
                h2[t2[i]] = true;

        }

        if (this.getAttribute("selecttag") != null) {

            this.removeAttribute("selecttag");
            this.style.backgroundColor = (this.getAttribute("tag") == "odd" ? "#eee" : "");

            delete h1[this.innerHTML];
            delete h2[this.getAttribute("value")];

        } else {
            this.setAttribute("selecttag", true);
            this.style.backgroundColor = "lightblue";
            this.style.color = "black";

            h1[this.innerHTML] = true;
            h2[this.getAttribute("value")] = true;
        }

        var result1 = "";
        var result2 = "";

        for (var i in h1) {

            result1 += i + ";";

        }

        for (var i = 0; i < opts.length; i++) {

            if (h2[opts[i].value]) {

                opts[i].selected = true;

            } else {

                opts[i].selected = false;

            }

        }

        target1.value = result1;
        // target2.value = result2;

    }
}

function addLabel(parent, text, size, color) {
    if (parent == undefined || text == undefined) {
        return;
    }

    if (color == undefined) {
        color = "black";
    }

    if (size == undefined) {
        size = "1em";
    }

    var lbl = document.createElement("label");
    lbl.style.color = color;
    lbl.style.fontSize = size;
    lbl.innerHTML = text;

    parent.appendChild(lbl);

    return lbl;
}

function addButton(parent, text, color) {
    if (parent == undefined || text == undefined) {
        return;
    }

    if (color == undefined) {
        color = "blue";
    }

    var _button = document.createElement("button");
    _button.style.margin = "3px";
    _button.style.height = "60px";
    _button.innerHTML = text;

    switch (color.toLowerCase()) {
        case "green":
            _button.className = "button green";
            break;
        case "red":
            _button.className = "button red";
            break;
        case "gray":
            _button.className = "button gray";
            break;
        case "orange":
            _button.className = "button orange";
            break;
        default:
            _button.className = "button blue";
            break;
    }

    parent.appendChild(_button);

    return _button;
}

function greenButton(btn) {
    if (btn == undefined) {
        return;
    }

    btn.style.border = "1px solid #34740e";
    btn.style.borderRadius = "10px";
    btn.style.fontSize = "28px";
    btn.style.fonFamily = "arial helvetica, sans-serif";
    btn.style.padding = "10px 10px 10px 10px";
    btn.style.textDecoration = "none";
    btn.style.display = "inline-block";
    btn.style.textShadow = "-1px -1px 0 rgba(0,0,0,0.3)";
    btn.style.fontWeight = "bold";
    btn.style.color = "#FFFFFF";
    btn.style.backgroundColor = "#4ba614";
    btn.style.backgroundImage = "-moz-linear-gradient(top, #4ba614, #008c00)";

    btn.onmouseout = function () {
        this.style.border = "1px solid #34740e";
        this.style.backgroundColor = "#4ba614";
        this.style.backgroundImage = "-moz-linear-gradient(top, #4ba614, #008c00)";
    }

    btn.onmouseover = function () {
        this.style.border = "1px solid #224b09";
        this.style.backgroundColor = "#36780f";
        this.style.backgroundImage = "-moz-linear-gradient(top, #36780f, #005900)";
    }
}

function redButton(btn) {
    if (btn == undefined) {
        return;
    }

    btn.style.border = "1px solid #72021c";
    btn.style.borderRadius = "10px";
    btn.style.fontSize = "28px";
    btn.style.fonFamily = "arial helvetica, sans-serif";
    btn.style.padding = "10px 10px 10px 10px";
    btn.style.textDecoration = "none";
    btn.style.display = "inline-block";
    btn.style.textShadow = "-1px -1px 0 rgba(0,0,0,0.3)";
    btn.style.fontWeight = "bold";
    btn.style.color = "#FFFFFF";
    btn.style.backgroundColor = "#a90329";
    btn.style.backgroundImage = "-moz-linear-gradient(top, #a90329, #6d0019)";

    btn.onmouseout = function () {
        this.style.border = "1px solid #72021c";
        this.style.backgroundColor = "#a90329";
        this.style.backgroundImage = "-moz-linear-gradient(top, #a90329, #6d0019)";
    }

    btn.onmouseover = function () {
        this.style.border = "1px solid #450111";
        this.style.backgroundColor = "#77021d";
        this.style.backgroundImage = "-moz-linear-gradient(top, #77021d, #3a000d)";
    }
}

function grayButton(btn) {
    if (btn == undefined) {
        return;
    }

    btn.style.border = "1px solid #ccc";
    btn.style.borderRadius = "10px";
    btn.style.fontSize = "28px";
    btn.style.fonFamily = "arial helvetica, sans-serif";
    btn.style.padding = "10px 10px 10px 10px";
    btn.style.textDecoration = "none";
    btn.style.display = "inline-block";
    btn.style.textShadow = "-1px -1px 0 rgba(0,0,0,0.3)";
    btn.style.fontWeight = "bold";
    btn.style.color = "#FFFFFF";
    btn.style.backgroundColor = "#a7cfdf";
    btn.style.backgroundImage = "-moz-linear-gradient(top, #ccc, #999)";

    btn.onmouseout = function () {
        this.style.border = "1px solid #ccc";
        this.style.backgroundColor = "#ccc";
        this.style.backgroundImage = "-moz-linear-gradient(top, #ccc, #999)";
    }

    btn.onmouseover = function () {
        this.style.border = "1px solid #ccc";
        this.style.backgroundColor = "#ddd";
        this.style.backgroundImage = "-moz-linear-gradient(top, #333, #ccc)";
    }

    btn.onmousedown = function () {
    }

}

function blueButton(btn) {
    if (btn == undefined) {
        return;
    }

    btn.style.border = "1px solid #7eb9d0";
    btn.style.borderRadius = "10px";
    btn.style.fontSize = "28px";
    btn.style.fonFamily = "arial helvetica, sans-serif";
    btn.style.padding = "10px 10px 10px 10px";
    btn.style.textDecoration = "none";
    btn.style.display = "inline-block";
    btn.style.textShadow = "-1px -1px 0 rgba(0,0,0,0.3)";
    btn.style.fontWeight = "bold";
    btn.style.color = "#FFFFFF";
    btn.style.backgroundColor = "#a7cfdf";
    btn.style.backgroundImage = "-moz-linear-gradient(top, #a7cfdf, #23538a)";

    btn.onmouseout = function () {
        this.style.border = "1px solid #7eb9d0";
        this.style.backgroundColor = "#a7cfdf";
        this.style.backgroundImage = "-moz-linear-gradient(top, #a7cfdf, #23538a)";
    }

    btn.onmouseover = function () {
        this.style.border = "1px solid #5ca6c4";
        this.style.backgroundColor = "#82bbd1";
        this.style.backgroundImage = "-moz-linear-gradient(top, #82bbd1, #193b61)";
    }
}

function resize() {

    if (__$("main")) {

        __$("main").style.height = (window.innerHeight - 20) + 'px';

    } else {

        setTimeout("resize()", 100);

        return;

    }

    if (__$("display")) {
        __$("display").style.height = (window.innerHeight - 150) + 'px';
    }

    if (__$("__content") && __$("display")) {

        __$("__content").style.width = (window.innerWidth - 22) + "px";

        __$("__content").style.height = (window.innerHeight - 170) + "px";

        if (__$("main-content-area")) {

            __$("main-content-area").style.height = (window.innerHeight - 170 - 50 - 300) + "px";

        }

    }

}

function loadPage(section, back) {
    if (isNaN(section))
        return;

    if (back == undefined)
        back = false;

    currentPage = section;

    if (__$("__content")) {

        __$("__content").innerHTML = "";

    } else {

        var content = document.createElement("div");
        content.id = "__content";
        content.style.width = (window.innerWidth - 12) + "px";
        content.style.height = (window.innerHeight - 12) + "px";
        // content.style.border = "1px solid #000";

        if (__$("display")) {

            __$("display").appendChild(content);

        } else {

            document.body.appendChild(content);

        }

        document.body.style.margin = "5px";

    }

    var main = document.createElement("div");
    main.style.display = "table";
    // main.style.border = "1px solid #000";
    main.style.width = "100%";
    main.style.height = "100%";
    main.style.borderSpacing = "5px";

    __$("__content").appendChild(main);

    var row0 = document.createElement("div");
    row0.style.display = "table-row";

    main.appendChild(row0);

    var cell0_1 = document.createElement("div");
    cell0_1.style.display = "table-cell";
    cell0_1.style.borderBottom = "1px solid #3465a4";
    cell0_1.style.color = "#3465a4";
    cell0_1.style.overflow = "hidden";
    cell0_1.style.fontSize = "36px";
    cell0_1.style.height = "50px";


    cell0_1.innerHTML = fieldsets[section].getElementsByTagName("legend")[0].innerHTML.trim()

    if (__$("legend")) {

      __$("legend").innerHTML = fieldsets[section].getElementsByTagName("legend")[0].innerHTML.trim() +
      "<p style='color: red; font-style: italic; font-size: 12px;'>* Required fields.</p>";

    }

    /*
    cell0_1.innerHTML = (fieldsets[section].getElementsByTagName("legend")[0].innerHTML.trim().length > 40 ?
        fieldsets[section].getElementsByTagName("legend")[0].innerHTML.substr(0, 40) + "..." : fieldsets[section].getElementsByTagName("legend")[0].innerHTML);

    // row0.appendChild(cell0_1);

    if (__$("legend")) {

        __$("legend").innerHTML = (fieldsets[section].getElementsByTagName("legend")[0].innerHTML.trim().length > 40 ?
            fieldsets[section].getElementsByTagName("legend")[0].innerHTML.substr(0, 40) + "..." : fieldsets[section].getElementsByTagName("legend")[0].innerHTML) +
            "<p style='color: red; font-style: italic; font-size: 12px;'>* Required fields.</p>";

        // fieldsets[section].getElementsByTagName("legend")[0].innerHTML;

    } */

    var row1 = document.createElement("div");
    row1.style.display = "table-row";

    main.appendChild(row1);

    var cell1_1 = document.createElement("div");
    cell1_1.style.display = "table-cell";
    cell1_1.style.borderBottom = "1px solid #3465a4";

    row1.appendChild(cell1_1);

    var row2 = document.createElement("div");
    row2.style.display = "table-row";

    main.appendChild(row2);

    var cell2_1 = document.createElement("div");
    cell2_1.style.display = "table-cell";
    cell2_1.style.height = "300px";

    row2.appendChild(cell2_1);

    var table = document.createElement("div");
    table.style.display = "table";
    table.style.width = "100%";
    table.style.height = "100%";

    cell2_1.appendChild(table);

    var row = document.createElement("div");
    row.style.display = "table-row";

    table.appendChild(row);

    var stage = document.createElement("div");
    stage.style.display = "table-cell";
    stage.style.border = "1px solid #3465a4";
    stage.style.overflow = "hidden";
    stage.style.borderRadius = "10px";
    stage.innerHTML = "&nbsp;";
    stage.id = "stage";
    stage.style.textAlign = "center";
    stage.style.verticalAlign = "top";
    stage.style.height = "300px";

    row.appendChild(stage);

    var toolsTable = document.createElement("div");
    toolsTable.style.display = "table";
    toolsTable.width = "100%";
    toolsTable.height = "100%";
    toolsTable.style.margin = "auto";
    toolsTable.style.marginTop = "0px";

    stage.appendChild(toolsTable);

    var toolsCell1 = document.createElement("div");
    toolsCell1.style.display = "table-cell";
    // toolsCell1.style.border = "1px solid #ccc";
    toolsCell1.style.borderRadius = "10px";
    toolsCell1.style.width = (window.innerWidth - 600) + "px";
    toolsCell1.style.height = (280) + "px";
    toolsCell1.style.overflow = "auto";
    toolsCell1.style.textAlign = "left";
    toolsCell1.id = "toolsCell1";

    toolsTable.appendChild(toolsCell1);

    var toolsCell2 = document.createElement("div");
    toolsCell2.style.display = "table-cell";
    // toolsCell2.style.border = "1px solid #ccc";
    toolsCell2.style.borderRadius = "10px";
    toolsCell2.style.width = (600) + "px";
    toolsCell2.style.height = (280) + "px";
    toolsCell2.id = "toolsCell2";

    toolsTable.appendChild(toolsCell2);

    var buttons = document.createElement("div");
    buttons.style.display = "table-cell";
    buttons.style.border = "1px solid #3465a4";
    buttons.style.overflow = "hidden";
    buttons.style.borderRadius = "10px";
    buttons.style.width = "120px";
    buttons.style.height = "100%";
    buttons.style.verticalAlign = "middle";

    row.appendChild(buttons);

    var btntable = document.createElement("div");
    btntable.style.display = "table";
    btntable.style.margin = "auto";
    btntable.style.borderSpacing = "5px";
    btntable.style.width = "100%";

    buttons.appendChild(btntable);

    var brow0 = document.createElement("div");
    brow0.style.display = "table-row";

    btntable.appendChild(brow0);

    var bcell0 = document.createElement("div");
    bcell0.style.display = "table-cell";
    bcell0.id = "btn0";

    brow0.appendChild(bcell0);

    var brow1 = document.createElement("div");
    brow1.style.display = "table-row";

    btntable.appendChild(brow1);

    var bcell1 = document.createElement("div");
    bcell1.style.display = "table-cell";
    bcell1.id = "btn1";

    brow1.appendChild(bcell1);

    var brow2 = document.createElement("div");
    brow2.style.display = "table-row";

    btntable.appendChild(brow2);

    var bcell2 = document.createElement("div");
    bcell2.style.display = "table-cell";
    bcell2.id = "btn2";

    brow2.appendChild(bcell2);

    var brow3 = document.createElement("div");
    brow3.style.display = "table-row";

    btntable.appendChild(brow3);

    var bcell3 = document.createElement("div");
    bcell3.style.display = "table-cell";
    bcell3.id = "btn3";

    brow3.appendChild(bcell3);

    btnCancel = addButton(__$("btn0"), "Cancel", "red");

    btnClear = addButton(__$("btn1"), "Clear", "blue");

    btnBack = addButton(__$("btn2"), "Back", "gray");

    btnNext = addButton(__$("btn3"), "Next", "green");

    if (btnCancel) {
        btnCancel.style.width = "98%";

        btnCancel.style.fontSize = "24px";

        btnCancel.onmousedown = function () {

            var msg = "Are you sure you want to cancel the data entry process?";

            var action = "if (typeof(cancelDestination) != 'undefined') { window.location = cancelDestination; }";

            showMsgForAction(msg, action);

        }
    }

    if (btnClear) {
        btnClear.style.width = "98%";

        btnClear.style.fontSize = "24px";
    }

    if (btnBack) {
        btnBack.style.width = "98%";

        btnBack.style.fontSize = "24px";
    }

    if (btnNext) {
        btnNext.style.width = "98%";

        btnNext.style.fontSize = "24px";
    }

    var fields = navigablefieldsets[section];	// fieldsets[section].elements;

    var mainContentArea = document.createElement("div");
    mainContentArea.style.overflowY = "auto";
    mainContentArea.id = "main-content-area";
    mainContentArea.style.height = (window.innerHeight - 40 - 50 - 300) + "px";
    mainContentArea.style.width = "100%";

    cell1_1.appendChild(mainContentArea);

    var work = document.createElement("div");
    work.id = "work";
    work.style.display = "table";
    work.style.width = "99.5%";

    mainContentArea.appendChild(work);

    if (fieldsets[section].getAttribute("custom") != null) {

        if (fieldsets[section].getAttribute("fs_onLoad") != null) {

            eval(fieldsets[section].getAttribute("fs_onLoad"));

        }

    } else {

        for (var i = 0; i < fields.length; i++) {

            if (fields[i].type == "radio" && __$("btn" + fields[i].id)) {

                continue;

            }

            if (fields[i].type == "hidden") {

                continue;

            }

            var row = document.createElement("div");
            row.style.display = "table-row";

            work.appendChild(row);

            for (var j = 0; j < 4; j++) {
                var cell = document.createElement("div");
                cell.style.display = "table-cell";

                switch (j) {
                    case 0:
                        cell.style.width = "40%";
                        cell.style.textAlign = "right";
                        cell.style.padding = "20px";
                        cell.id = "cell" + i + "." + j;

                        var label = addLabel(cell, (fields[i].label != undefined ? fields[i].label.innerHTML +
                            (fields[i].getAttribute("optional") == null ? "<span style='color: red;'> *</span>" : "") : "Undefined"), textSize, "#333");

                        break;
                    case 1:
                        cell.innerHTML = "&nbsp;";
                        cell.style.width = "50px";
                        cell.style.textAlign = "center";
                        // cell.style.paddingTop = "20px";
                        cell.style.color = "blue";
                        cell.style.fontSize = "24px";
                        // cell.style.verticalAlign = "middle";
                        cell.id = "cell" + i + "." + j;
                        break;
                    case 3:
                        cell.innerHTML = "&nbsp;";
                        cell.style.width = "80px";
                        cell.style.textAlign = "center";
                        cell.style.verticalAlign = "middle";
                        cell.id = "cell" + i + "." + j;
                        break;
                    case 2:
                        cell.id = "cell" + i + "." + j;

                        if (fields[i].type == "radio") {

                            var labels = document.getElementsByTagName('LABEL');
                            for (var s = 0; s < labels.length; s++) {
                                if (labels[s].htmlFor != '' && labels[s].htmlFor == fields[i].name) {

                                    if (__$("cell" + i + ".0")) {

                                        __$("cell" + i + ".0").innerHTML = "";

                                        var label = addLabel(__$("cell" + i + ".0"), labels[s].innerHTML, textSize, "#333");

                                        break;

                                    }

                                }
                            }

                            var btns = document.getElementsByName(fields[i].name);

                            var choiceTable = document.createElement("div");
                            choiceTable.style.display = "table";

                            cell.appendChild(choiceTable);

                            var choiceRow = document.createElement("table-row");
                            choiceRow.style.display = "table-row";

                            choiceTable.appendChild(choiceRow);

                            for (var r = 0; r < btns.length; r++) {

                                var choiceCell = document.createElement("table-cell");
                                choiceCell.style.display = "table-cell";

                                choiceRow.appendChild(choiceCell);

                                var btnChoice = addButton(choiceCell, btns[r].label.innerHTML, (btns[r].checked ? "orange" : "blue"));

                                btnChoice.style.fontSize = "20px";

                                btnChoice.style.height = "60px";

                                btnChoice.name = "btn" + btns[r].name;

                                btnChoice.id = "btn" + btns[r].id;

                                btnChoice.setAttribute("target", btns[r].id);

                                btnChoice.setAttribute("pos", i);

                                btnChoice.setAttribute("section", section);

                                btnChoice.onmousedown = function () {

                                    var group = document.getElementsByName(this.name);

                                    for (var g = 0; g < group.length; g++) {

                                        group[g].className = "button blue";

                                    }

                                    if (__$(this.getAttribute("target"))) {

                                        __$(this.getAttribute("target")).click();

                                        this.className = "button orange";

                                    }

                                    cursorPos = parseInt(this.getAttribute("pos"));

                                    var section = parseInt(this.getAttribute("section"));

                                    navigateTo(cursorPos, section);

                                }

                            }

                        } else {

                            var fieldtype = fields[i].getAttribute("fieldtype");

                            var callback = fields[i].getAttribute("callback");

                            var txt = addTextbox(cell, fieldtype, fields[i].id, (callback != null ? callback : undefined));

                            txt.style.fontSize = textSize;

                            txt.id = "textFor" + fields[i].id;

                            txt.setAttribute("target", fields[i].id);

                            txt.setAttribute("pos", i);

                            if (fields[i].getAttribute("placeholder") != null) {

                                txt.setAttribute("placeholder", fields[i].getAttribute("placeholder"));

                            }

                            txt.setAttribute("section", section);

                            if (fields[i].getAttribute("ajaxURL") != null) {

                                txt.setAttribute("ajaxURL", fields[i].getAttribute("ajaxURL"));

                            } else if (fields[i].getAttribute("ajaxUrl") != null) {

                                txt.setAttribute("ajaxURL", fields[i].getAttribute("ajaxUrl"));

                            } else if (fields[i].getAttribute("ajaxurl") != null) {

                                txt.setAttribute("ajaxURL", fields[i].getAttribute("ajaxurl"));

                            }

                            if (fields[i].tagName.toLowerCase() == "select" && fields[i].type.toLowerCase() == "select-multiple") {

                                var values = "";

                                var opts = fields[i].options;

                                for (var k = 0; k < opts.length; k++) {

                                    if (opts[k].selected) {

                                        values += opts[k].innerHTML + ";";

                                    }

                                }

                                txt.value = values;

                            } else {

                                txt.value = fields[i].value;

                            }

                            txt.onfocus = function () {

                                if (!buttonNavigation && validationControl != null && validationControl.id != this.id && !navigatingBack) {

                                    var canGo = clickCanGo();

                                    if (!canGo) {

                                        validationControl.focus();

                                        return;

                                    }

                                }

                                buttonNavigation = false;

                                var m = checkCtrl(__$("main-content-area"));

                                var c = checkCtrl(this);

                                // [w, h, t, l]

                                if ((m[2] + m[1]) < (c[2] + c[1])) {

                                    __$("main-content-area").scrollTop += 60;

                                } else if ((m[2] + m[1]) > c[2]) {

                                    __$("main-content-area").scrollTop -= 60;

                                }

                                cursorPos = parseInt(this.getAttribute("pos"));

                                var section = parseInt(this.getAttribute("section"));

                                navigatingBack = false;

                                validationControl = this;

                                if (navigablefieldsets[section][cursorPos].getAttribute("condition") != null) {

                                    checkConditions();

                                }

                                if (navigablefieldsets[section][cursorPos].value.length > 0) {

                                    navigablefieldsets[section][cursorPos].setAttribute("textCase", 'lower');

                                }

                                navigateTo(cursorPos, section);

                                if (this.getAttribute("callback") != null) {

                                    eval(this.getAttribute("callback"));

                                }

                            }

                        }

                        break;
                }

                row.appendChild(cell);
            }

        }

    }

    cursorPos = 0;      // (navigatingBack ? (fields.length - 1) : 0);

    if (navigatingBack) {

        [cursorPos, section] = getValidPreviousValue((fields.length - 1), section);

    }

    checkConditions();

    navigateTo(cursorPos, section, back);

    clearMarks(currentPage);

}

function navigateTo(pos, section, back) {

    if (back == undefined)
        back = false;

    timers = {};

    for (var t in timerHandles) {

        clearTimeout(timerHandles[t]);

    }

    cursorPos = pos;

    timerHandles = {};

    if (__$("popupkeyboard")) {

        document.body.removeChild(__$("popupkeyboard"));

    }

    if (fieldsets[section].getAttribute("condition") != null) {

        if (!eval(fieldsets[section].getAttribute("condition"))) {

            /*if (back) {

             var s = section - 1;

             while (s > 0) {

             if (!eval(fieldsets[s].getAttribute("condition"))) {

             s = s - 1;

             } else {

             section = s;

             break;

             }

             }

             incomplete = false;

             navigatingBack = true;

             loadPage(section - 1, true);

             } else {*/

            if (!back) {

                loadPage(section + 1);

                // }

                return;

            }

        }

    }

    var fields = navigablefieldsets[section];		// fieldsets[section].elements;

    if (fields[pos] != undefined && fields[pos].getAttribute("disabled") != null) {

        // if (incomplete)
        //    return;

        if ((pos + 1) < fields.length - 1) {

            navigateTo(pos + 1, section);

        } else if (section + 1 < fieldsets.length) {

            /*if (back) {

             navigatingBack = true;

             loadPage(section - 1);

             } else {*/

            if (!back) {

                checkValidity();

                if (incomplete)
                    return;

                loadPage(section + 1);

            }

            // }

        } else {

            checkValidity();

            if (incomplete)
                return;

            if (Object.keys(summaryHash).length > 0) {

                submitAfterSummary();

            } else {

                document.forms[0].submit();

            }

        }

        return;
    }

    var fieldtype = (fields[pos] != undefined ? fields[pos].getAttribute("fieldtype") : null);

    if (!__$("cursor")) {

        var cursor = document.createElement("label");
        cursor.id = "cursor";
        cursor.innerHTML = "&#9654;";

        document.body.appendChild(cursor);

    }

    if (__$("cell" + pos + ".1")) {

        __$("cell" + pos + ".1").appendChild(__$("cursor"));

    }

    if (fieldsets[section].getAttribute("custom") == null && __$("toolsCell2") && __$("toolsCell1")) {

        __$("toolsCell2").innerHTML = "&nbsp;";

        __$("toolsCell1").innerHTML = "&nbsp;";

    }

    if (fields[pos] != undefined && __$("toolsCell2") && __$("toolsCell1") && __$("textFor" + fields[pos].id)) {

        clearTimeout(tracker);

        tracker = setTimeout("checkChanges('" + fields[pos].id + "')", 500);

        __$("toolsCell2").style.verticalAlign = "middle";

        __$("toolsCell1").style.verticalAlign = "middle";

        if (btnClear != null) {

            btnClear.setAttribute("pos", pos);

            btnClear.setAttribute("section", section);

            btnClear.onmousedown = function () {

                validatingAlready = false;

                if (this.getAttribute("pos") != null && this.getAttribute("section") != null) {

                    var pos = parseInt(this.getAttribute("pos"));

                    var section = parseInt(this.getAttribute("section"));

                    var fields = navigablefieldsets[section];		// fieldsets[section].elements;

                    __$("textFor" + fields[pos].id).value = "";

                    if (fields[pos].tagName.toLowerCase() == "select" || fields[pos].getAttribute("ajaxURL") != null ||
                        fields[pos].getAttribute("ajaxurl") != null || fields[pos].getAttribute("ajaxUrl") != null) {

                        for (var k = pos + 1; k < fields.length; k++) {

                            fields[k].value = "";

                            if (__$("textFor" + fields[k].id)) {

                                __$("textFor" + fields[k].id).value = "";

                            }

                        }

                    }

                    if (fields[pos].tagName.toLowerCase() == "select") {

                        var opts = fields[pos].options;

                        for (var i = 0; i < opts.length; i++) {

                            opts[i].selected = false;

                        }

                    } else {

                        fields[pos].value = "";

                    }

                    navigateTo(pos, section);
                }

                validatingAlready = false;

            }

        }

        if (btnBack != null) {

            if (fields[pos - 1]) {
                if (fields[pos - 1].type == "radio") {
                    var radios = document.getElementsByName(fields[pos - 1].name);

                    btnBack.setAttribute("step", radios.length);
                } else {

                    btnBack.removeAttribute("step");

                }
            } else {

                btnBack.removeAttribute("step");

            }

            btnBack.setAttribute("pos", pos);

            btnBack.setAttribute("section", section);

            if ((section > 0 && pos > 0) || (section == 0 && pos > 0)) {

                btnBack.className = "button blue";

                btnBack.onmousedown = function () {

                    navigatingBack = true;

                    incomplete = false;

                    var pos = parseInt(this.getAttribute("pos")) - (this.getAttribute("step") != null ? parseInt(this.getAttribute("step")) : 1);

                    var section = parseInt(this.getAttribute("section"));

                    [pos, section] = getValidPreviousValue(pos, section);

                    navigateTo(pos, section, true);

                }

            } else if (section > 0 && pos == 0) {

                btnBack.className = "button blue";

                btnBack.onmousedown = function () {

                    navigatingBack = true;

                    incomplete = false;

                    var section = parseInt(this.getAttribute("section")) - 1;

                    var new_section = getValidPreviousSection(section);

                    loadPage(new_section, true);

                }

            } else {

                btnBack.className = "button gray";

                btnBack.onmousedown = function () {
                };

            }

        }

        if (btnNext != null) {

            btnNext.setAttribute("pos", pos);

            btnNext.setAttribute("section", section);

            if (section < fieldsets.length && pos < fields.length - 1) {

                btnNext.innerHTML = "Next";

            } else if ((section < fieldsets.length - 1 && pos == fields.length - 1) || (section == fieldsets.length - 1 && pos < fields.length - 1)) {

                btnNext.innerHTML = "Next";

            } else {

                btnNext.innerHTML = "Finish";

            }

            btnNext.onmousedown = function () {

                buttonNavigation = true;

                if (validationControl != null && validationControl.id != this.id && !navigatingBack) {

                    var canGo = clickCanGo();

                    if (!canGo) {

                        return;

                    }

                }

                gotoQuestion(pos, section);

            }

        }

        loadControlKeys(fields, fieldtype, pos);

        if (fields[pos].getAttribute("tt_onload") != null) {

            eval(fields[pos].getAttribute("tt_onload"));

        }

    }

    if (validationControl != null && (validationControl.getAttribute("ajaxURL") != null || validationControl.getAttribute("ajaxUrl") != null || validationControl.getAttribute("ajaxurl") != null)) {

        checkLookup(validationControl.getAttribute("target"));

    }

    if (fields[pos] != undefined && __$("textFor" + fields[pos].id)) {

        __$("textFor" + fields[pos].id).focus();

        var m = checkCtrl(__$("main-content-area"));

        var c = checkCtrl(__$("textFor" + fields[pos].id));

        // [w, h, t, l]

        if ((m[2] + m[1]) < (c[2] + c[1])) {

            __$("main-content-area").scrollTop += 60;

        } else if ((m[2] + m[1]) > c[2]) {

            __$("main-content-area").scrollTop -= 60;

        }

    }

    resize();

}

function loadControlKeys(fields, fieldtype, pos) {

    if (fieldtype != null) {

        switch (fieldtype.toLowerCase()) {
            case "age":
                __$("toolsCell1").innerHTML = "";

                addAge(__$("toolsCell2"), fields[pos], (!isNaN((new Date(__$("textFor" + fields[pos].id).value.trim())).getDay()) ? __$("textFor" + fields[pos].id).value.trim() : undefined), "Specify Actual Date of Birth", "Age");

                break;
            case "select":

                var opts = fields[pos].options;

                var options = {};

                var selected = {};

                __$("textFor" + fields[pos].id).value = "";

                var optionType = (fields[pos].type.toLowerCase() == "select-multiple" ? "multiple" : "single");

                for (var i = 0; i < opts.length; i++) {

                    if (opts[i].innerHTML.trim().length) {

                        options[opts[i].value] = opts[i].innerHTML;

                        if (opts[i].selected) {

                            selected[opts[i].value] = true;

                            __$("textFor" + fields[pos].id).value += opts[i].innerHTML + (optionType == "multiple" ? ";" : "");

                        }

                    }

                }

                __$("toolsCell2").innerHTML = "";

                __$("toolsCell1").innerHTML = "";

                __$("toolsCell1").style.verticalAlign = "top";

                // addCombo(parent, options, optionType, target1, target2, collapseOnClick, id, action, selected)
                var combo = addCombo(__$("toolsCell1"), options, optionType, __$("textFor" + fields[pos].id), fields[pos], false, (fields[pos].getAttribute("onchange") != null ? fields[pos].getAttribute("onchange") : undefined), undefined, selected);

                combo.style.fontSize = textSize;

                combo.style.textAlign = "left";

                break;
            case "barcode":
                __$("toolsCell2").innerHTML = "";

                __$("toolsCell1").innerHTML = "";

                break;
            case "date":
                __$("toolsCell2").innerHTML = "";

                __$("toolsCell1").innerHTML = "";

                var ctrl = addDate(__$("toolsCell2"), fields[pos], __$("textFor" + fields[pos].id).value);

                ctrl.style.margin = "auto";

                break;
            case "number":
                __$("toolsCell1").innerHTML = "";

                showFixedKeyboard(__$("textFor" + fields[pos].id), __$("toolsCell2"), {"/": true, ":": true, "abc": true, ".": true}, true)

                break;
            case "decimal":
                __$("toolsCell1").innerHTML = "";

                showFixedKeyboard(__$("textFor" + fields[pos].id), __$("toolsCell2"), {"/": true, ":": true, "abc": true}, true)

                break;
            default:
                var lower = (fields[pos].getAttribute("textCase") != null ? (fields[pos].getAttribute("textCase").trim().toLowerCase() == "lower" ? true : false) : false )

                __$("toolsCell1").innerHTML = "";

                showFixedKeyboard(__$("textFor" + fields[pos].id), __$("toolsCell2"), {}, false, lower)

                break;
        }

    } else {

        if (fields[pos].tagName.toLowerCase() == "select") {

            var opts = fields[pos].options;

            var options = {};

            var selected = {};

            __$("textFor" + fields[pos].id).value = "";

            var optionType = (fields[pos].type.toLowerCase() == "select-multiple" ? "multiple" : "single");

            for (var i = 0; i < opts.length; i++) {

                if (opts[i].innerHTML.trim().length) {

                    options[opts[i].value] = opts[i].innerHTML;

                    if (opts[i].selected) {

                        selected[opts[i].value] = true;

                        __$("textFor" + fields[pos].id).value += opts[i].innerHTML + (optionType == "multiple" ? ";" : "");

                    }

                }

            }

            __$("toolsCell2").innerHTML = "&nbsp";

            __$("toolsCell1").innerHTML = "&nbsp";

            __$("toolsCell1").style.verticalAlign = "top";


            var combo = addCombo(__$("toolsCell1"), options, optionType, __$("textFor" + fields[pos].id), fields[pos], false, undefined, (fields[pos].getAttribute("onchange") != null ? fields[pos].getAttribute("onchange") : undefined), selected);

            combo.style.fontSize = textSize;

            combo.style.textAlign = "left";

        } else {
            var lower = (fields[pos].getAttribute("textCase") != null ? (fields[pos].getAttribute("textCase").trim().toLowerCase() == "lower" ? true : false) : false )

            showFixedKeyboard(__$("textFor" + fields[pos].id), __$("toolsCell2"), {}, false, lower)

        }

    }
}

function gotoQuestion(pos, section) {

    pos = parseInt(pos);

    section = parseInt(section);

    var fields = navigablefieldsets[section];


    if (fields[pos]){
        if (fields[pos].getAttribute("tt_BeforeUnload") != null) {

            var val = eval(fields[pos].getAttribute("tt_BeforeUnload"));

        }
    }

    if (fields[pos]){
        if (fields[pos].getAttribute("tt_onUnload") != null) {

            eval(fields[pos].getAttribute("tt_onUnload"));

        }
    }

    incomplete = false;

    if (section < fieldsets.length && pos < fields.length - 1) {

        pos++;

        [pos, section] = getValidNextValue(pos, section);

        if (__$("textFor" + navigablefieldsets[section][pos].id) &&
            __$("textFor" + navigablefieldsets[section][pos].id).getAttribute("disabled") == null &&
            navigablefieldsets[section][pos].getAttribute("condition") == null) {

            __$("textFor" + navigablefieldsets[section][pos].id).focus();

        } else {

            if (navigablefieldsets[section][pos].getAttribute("condition") != null) {

                checkConditions();

            }

            navigateTo(pos, section);

        }

    } else if ((section < fieldsets.length - 1 && pos == fields.length - 1) || (section == fieldsets.length - 1 && pos < fields.length - 1)) {

        checkValidity();

        if (!incomplete) {

            section++;

            loadPage(section);

        }

    } else {

        checkValidity();

        if (incomplete)
            return;

        if (Object.keys(summaryHash).length > 0) {

            submitAfterSummary();

        } else {

            document.forms[0].submit();

        }
    }

    var fieldtype = (fields[pos] != undefined ? fields[pos].getAttribute("fieldtype") : null);

}

function getValidNextValue(pos, section) {

    var new_pos, new_section;

    var fields = navigablefieldsets[section];

    for (var i = parseInt(pos); i < fields.length; i++) {

        if (fields[i].getAttribute("condition") != null) {

            if (eval(fields[i].getAttribute("condition"))) {

                new_pos = i;

                new_section = section;

                break;

            }

        } else {

            new_pos = i;

            new_section = section;

            break;

        }

    }

    if (new_pos == undefined && new_section == undefined) {

        new_pos = 0;

        new_section = section + 1;

        loadLabels(new_section);

        return [pos, section];

    }

    return [new_pos, new_section];

}

function getValidPreviousValue(pos, section) {

    var new_pos, new_section;

    var fields = navigablefieldsets[section];

    for (var i = parseInt(pos); i >= 0; i--) {

        if (fields[i].getAttribute("condition") != null) {

            if (eval(fields[i].getAttribute("condition"))) {

                new_pos = i;

                new_section = section;

                break;

            }

        } else {

            new_pos = i;

            new_section = section;

            break;

        }

    }

    if (new_pos == undefined && new_section == undefined) {

        new_pos = 0;

        new_section = getValidPreviousSection(section);       // (section > 0 ? section - 1 : 0);

        loadLabels(new_section);

        return [pos, section];

    }

    return [new_pos, new_section];

}

function getValidPreviousSection(section) {

    section = parseInt(section);

    if (fieldsets[section].getAttribute("condition") != null) {

        if (eval(fieldsets[section].getAttribute("condition"))) {

            return section;

        } else {

            if (section > 0) {

                section -= 1;

                return getValidPreviousSection(section);

            } else {

                return section;

            }

        }
    } else {

        return section;

    }
}

function checkChanges(id) {

    clearTimeout(tracker);

    if (__$(id) && __$("textFor" + id)) {

        if (__$(id).tagName.toLowerCase() == "select" && __$(id).type == "select-multiple") {

            var values = __$("textFor" + id).value.trim().split(";");

            var selected = {};

            for (var i = 0; i < values.length; i++) {

                selected[values[i].trim()] = true;

            }

            var opts = __$(id).options;

            for (var i = 0; i < opts.length; i++) {

                if (opts[i].innerHTML.trim() == selected[opts[i].innerHTML.trim()]) {

                    opts[i].selected = true;

                } else {

                    opts[i].selected = false;

                }

            }

        } else {

            __$(id).value = __$("textFor" + id).value;

        }

    }

    if (__$(id)) {

        setTimeout("checkChanges('" + id + "')", 1000);

    }

}

var changedTracker = "";
var localCheck = false;

function checkValidity() {

    showSpinner();

    // clearTimeout(validityTmr);

    var fields = navigablefieldsets[currentPage];		// fieldsets[currentPage].elements;

    incomplete = false;

    for (var i = 0; i < fields.length; i++) {

        if (fields[i].getAttribute("condition") != null) {

            if (!eval(fields[i].getAttribute("condition"))) {

                if (__$("textFor" + fields[i].id)) {

                    __$("textFor" + fields[i].id).value = "";

                    fields[i].id.value = "";

                    __$("textFor" + fields[i].id).setAttribute("disabled", true);

                } else if (fields[i].type == "radio") {

                    fields[i].checked = false;

                    if (__$("btn" + fields[i].id)) {

                        __$("btn" + fields[i].id).setAttribute("disabled", true);

                        __$("btn" + fields[i].id).className = "button gray";

                    }

                }

                if (__$("cell" + i + ".0")) {

                    __$("cell" + i + ".0").style.opacity = "0.4";

                }

                fields[i].setAttribute("disabled", true);

            } else {

                if (__$("textFor" + fields[i].id)) {

                    __$("textFor" + fields[i].id).removeAttribute("disabled");

                } else if (fields[i].type == "radio") {

                    if (__$("btn" + fields[i].id) && __$("btn" + fields[i].id).getAttribute("disabled")) {

                        __$("btn" + fields[i].id).removeAttribute("disabled");

                        __$("btn" + fields[i].id).className = "button blue";

                    }

                }

                if (__$("cell" + i + ".0")) {

                    __$("cell" + i + ".0").style.opacity = "1";

                }

                fields[i].removeAttribute("disabled");

            }

        }

        if (fields[i].type == "radio") {

            var radios = document.getElementsByName(fields[i].name);

            var checked = false;

            var disabled = false;

            for (var j = 0; j < radios.length; j++) {

                if (radios[j].getAttribute("disabled") != null) {

                    disabled = true;

                    break;

                }

                if (radios[j].checked) {

                    checked = true;

                    break;

                }

            }

            if (__$("cell" + i + ".3") && !disabled) {
                if (!checked) {

                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                    incomplete = true;

                } else {

                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                }
            } else if (__$("cell" + i + ".3")) {

                __$("cell" + i + ".3").innerHTML = "";

            }

            // i = i + radios.length - 1;

        } else {


            if (fields[i].getAttribute("uniq_check") != null) {

                if (changedTracker != __$("textFor" + fields[i].id).value.trim()) {
                    checkUniqueness(fields[i].getAttribute("uniq_check") + __$("textFor" + fields[i].id).value.trim(), __$("textFor" + fields[i].id), __$("cell" + i + ".3"));
                } else if (__$("textFor" + fields[i].id).value.trim().length == 0) {
                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                    incomplete = true;

                } else {
                    incomplete = localCheck;
                }

                changedTracker = __$("textFor" + fields[i].id).value.trim();

            } else if (fields[i].getAttribute("optional") == null) {
                if (fields[i].getAttribute("disabled") == null && __$("textFor" + fields[i].id)) {
                    if (fields[i].getAttribute("regex") != null) {

                        if (__$("textFor" + fields[i].id).value.trim().match(fields[i].getAttribute("regex")) == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                            incomplete = true;

                        } else {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                        }

                    } else {
                        if (__$("textFor" + fields[i].id).value.trim().length == 0) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                            incomplete = true;

                        } else if (fields[i].getAttribute("fieldtype") != null && fields[i].getAttribute("fieldtype").toLowerCase() == "number" && __$("textFor" + fields[i].id).value.trim().match(/^\d+$/) == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                            incomplete = true;

                        } else if (fields[i].getAttribute("fieldtype") != null && (fields[i].getAttribute("fieldtype").toLowerCase() == "date" || fields[i].getAttribute("fieldtype").toLowerCase() == "age")) {

                            if (__$("textFor" + fields[i].id).value.trim().match(/^(\d|\d{2}|\?)\/([A-Za-z]{3}|\?)\/(\d{4}|\?)$/) == null) {
                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                                incomplete = true;

                            } else {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />"

                            }

                            if (fields[i].getAttribute("absolute_max") != null && fields[i].getAttribute("absolute_min") != null) {

                                var current_set_date = new Date(__$("textFor" + fields[i].id).value.trim());
                                var absolute_max_date = new Date(fields[i].getAttribute("absolute_max").toLowerCase());
                                var absolute_mini_date = new Date(fields[i].getAttribute("absolute_min").toLowerCase());
                                if (current_set_date > absolute_max_date || current_set_date < absolute_mini_date) {

                                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                                    incomplete = true;

                                } else {

                                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                                }

                            }


                        } else {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                        }
                    }

                } else if (__$("cell" + i + ".3")) {

                    __$("cell" + i + ".3").innerHTML = "";

                }


            } else {

                if (fields[i].getAttribute("disabled") == null && __$("textFor" + fields[i].id)) {
                    if (fields[i].getAttribute("regex") != null) {

                        if (__$("textFor" + fields[i].id).value.trim().length > 0) {
                            if (__$("textFor" + fields[i].id).value.trim().match(fields[i].getAttribute("regex")) == null) {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                                incomplete = true;

                            } else {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />"

                            }
                        } else {

                            __$("cell" + i + ".3").innerHTML = "&nbsp;";

                        }

                    } else {
                        if (__$("textFor" + fields[i].id).value.trim().length == 0) {

                            __$("cell" + i + ".3").innerHTML = "&nbsp;";

                        }
                    }
                } else if (__$("cell" + i + ".3")) {

                    __$("cell" + i + ".3").innerHTML = "";

                }

            }

        }

    }

    // validityTmr = setTimeout("checkValidity()", 1000);

    hideSpinner();

}

function checkUniqueness(path, control, target) {

    value = control.value;

    if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
    } else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            var results = xmlhttp.responseText;

            if (results == 'N/A' || results.trim().length == 0) {
                incomplete = true;

                localCheck = true;

                if (control.value.trim().length > 0) {
                    target.innerHTML = "<img src='" + imgUnTick + "' height=60 />";
                } else {
                    if (control.getAttribute("optional") != null) {
                        target.innerHTML = "<img src='" + imgTick + "' height=60 />";
                    }
                }
            } else {

                localCheck = false;

                if (control.value.trim().length > 0) {
                    target.innerHTML = "<img src='" + imgTick + "' height=60 />";
                }
            }
        }
    }
    xmlhttp.open("GET", path, true);
    xmlhttp.send();

}

function showShield(action, clickCloses) {

    if (clickCloses == undefined) {

        clickCloses = true;

    }

    if (__$("shield")) {

        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("popupkeyboard")) {

            if (action != undefined) {

                eval(action);

            }

            document.body.removeChild(__$('popupkeyboard'));

        }

        document.body.removeChild(__$("shield"));

    } else {

        var shield = document.createElement("div");
        shield.style.position = "absolute";
        shield.style.backgroundColor = "rgba(0,0,0,0.1)";
        shield.style.top = "0px";
        shield.style.left = "0px";
        shield.style.width = "100%";
        shield.style.height = "100%";
        shield.id = "shield";

        if (action != undefined) {

            shield.setAttribute("action", action);

        }

        if (clickCloses) {

            shield.onmousedown = function () {

                if (this.getAttribute("action") != null) {
                    showShield(this.getAttribute("action"));
                } else {
                    showShield();
                }

            }

        }

        document.body.appendChild(shield);

    }

}

function loadAjax(id, target1, target2, url, search) {

    var textfile;
    if (window.XMLHttpRequest) {
        textfile = new XMLHttpRequest();
    }

    trackingString = search.trim();

    textfile.onreadystatechange = function () {
        if (textfile.readyState == 4 && textfile.status == 200) {
            var content = textfile.responseText;

            var results = content.split("\n");

            var options = {};

            for (var i = 0; i < results.length; i++) {

                if (results[i].toLowerCase().match(/*"^" + */ search.toLowerCase())) {

                    options[results[i]] = results[i];

                }

            }

            if (id.trim().toLowerCase() != validationControl.id.trim().toLowerCase()) {

                return;

            }

            if (__$("toolsCell1")) {

                __$("toolsCell1").innerHTML = "";

                addCombo(__$("toolsCell1"), options, "single", target1, target2, true, id, "clearLookup('" + id + "')");

            } else {

                addList(__$(id), options, "single", target1, target2, "clearLookup('" + id + "')", (__$("main-content-area").offsetHeight - 50) + "px", __$(id).offsetWidth + "px");

            }

        }
    }
    textfile.open("GET", url + (url.trim().match(/\?.+/) ? "&search" + search : "?search=" + search), true);
    textfile.send();

}

function clearLookup(id) {

    if (__$(id)) {

        __$(id).removeAttribute("lookup");

    }

}

function checkLookup(id) {

    if (__$("textFor" + id) && __$(id) && __$(id).getAttribute("ajaxURL") != null) {

        if (__$(id).getAttribute("ajaxURL") != null) {

            loadAjax("textFor" + id, __$("textFor" + id), __$(id), __$(id).getAttribute("ajaxURL"), __$("textFor" + id).value.trim());

        } else if (__$(id).getAttribute("ajaxUrl") != null) {

            loadAjax("textFor" + id, __$("textFor" + id), __$(id), __$(id).getAttribute("ajaxUrl"), __$("textFor" + id).value.trim());

        } else if (__$(id).getAttribute("ajaxurl") != null) {

            loadAjax("textFor" + id, __$("textFor" + id), __$(id), __$(id).getAttribute("ajaxurl"), __$("textFor" + id).value.trim());

        }
    }

}

function clearUl(id) {

    if (__$(id)) {
        var kids = __$(id).children;

        for (var i = 0; i < kids.length; i++) {

            kids[i].style.backgroundColor = (kids[i].getAttribute("tag") == "odd" ? "#eee" : "");

        }
    }

}

function checkScrolls() {
    if (__$("display")) {

        __$("display").onscroll = function () {

            if (__$("popupkeyboard")) {

                document.body.removeChild(__$('popupkeyboard'));

            }
        }

    }
}

var spinner;

function showSpinner(action, clickOnClose, shieldOn) {

    if (!document.getElementById('spin')) {
        var div = document.createElement("div");
        div.id = "spin";
        div.style.position = "absolute";
        div.style.top = ((window.innerHeight / 2) - 80) + "px";
        div.style.left = ((window.innerWidth / 2)) + "px";

        div.innerHTML = '<img src="data:image/gif;base64,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"/>';

        document.body.appendChild(div);
    }

    if (shieldOn == true) {
        showShield(action, clickOnClose);
    }
}

function hideSpinner() {


    if (__$("spin")) {

        document.body.removeChild(__$("spin"));

    }

    if (__$("shield")) {

        document.body.removeChild(__$("shield"));

    }

}

var validatingAlready = false;

function clickCanGo() {

    if (validatingAlready) {

        // return;

    }

    if (validationControl != null) {

        var i = validationControl.getAttribute("pos");

        var parent = null;

        if (validationControl.getAttribute("target") != null) {

            parent = __$(validationControl.getAttribute("target"));

        }

        if (parent == null) {

            return true;

        }

        if (parent.getAttribute("optional") == null) {

            if (__$("textFor" + parent.id)) {

                if (__$("textFor" + parent.id).value.trim().length == 0) {

                    showMsg("Please enter a valid value in the empty field.");

                    if (__$("cell" + i + ".3")) {

                        if (parent.getAttribute("optional") == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                        } else {

                            __$("cell" + i + ".3").innerHTML = "";

                        }

                    }

                    return false;

                }

            }

        }

        if(parent.getAttribute("word_min_length") && parent.getAttribute("word_min_length") > 0){
            
            var word_min_length = parent.getAttribute("word_min_length")? parent.getAttribute("word_min_length") : 0;
            if(__$("textFor" + parent.id) && __$("textFor" + parent.id).value.trim().length > 0 && __$("textFor" + parent.id).value.trim().length < word_min_length){
                  
                  showMsg("Entered value length doesn't meet minimum required length of "+word_min_length+" character(s)");

                  if (__$("cell" + i + ".3")) {

                        if (parent.getAttribute("optional") == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                        } else {

                            __$("cell" + i + ".3").innerHTML = "";

                        }

                    }

                    return false;
            }

        }

        if(parent.getAttribute("word_max_length") && parent.getAttribute("word_max_length") > 0){
            
            var word_max_length = parent.getAttribute("word_max_length")? parent.getAttribute("word_max_length") : 0;
            if(__$("textFor" + parent.id) && __$("textFor" + parent.id).value.trim().length > 0 && __$("textFor" + parent.id).value.trim().length > word_max_length){
                  
                  showMsg("Entered value length execeeds the maximum required length of "+word_max_length+" character(s)");

                  if (__$("cell" + i + ".3")) {

                        if (parent.getAttribute("optional") == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                        } else {

                            __$("cell" + i + ".3").innerHTML = "";

                        }

                    }

                    return false;
            }

        }

          if(parent.getAttribute("length") && parent.getAttribute("length") > 0){
            
            var length = parent.getAttribute("length")? parent.getAttribute("length") : 0;
            if(__$("textFor" + parent.id).value.trim().length > 0 && __$("textFor" + parent.id).value.trim().length != length){
                  
                  showMsg("Entered value has "+__$("textFor" + parent.id).value.trim().length
                               + " character(s) but the field   expects exactly "+
                                   length+ " character(s)");

                  if (__$("cell" + i + ".3")) {

                        if (parent.getAttribute("optional") == null) {

                            __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                        } else {

                            __$("cell" + i + ".3").innerHTML = "";

                        }

                    }

                    return false;
            }

        }


        if (parent.getAttribute("optional") == null || (parent.getAttribute("optional") != null && validationControl.value.trim().length > 0)) {
            if (parent.getAttribute("absolute_max") != null) {
                if (parent.getAttribute("fieldtype") == "date" || parent.getAttribute("fieldtype") == "age") {
                    if (validationControl) {

                        var date = new Date(validationControl.value.trim());
                        var absolute_date = new Date(parent.getAttribute("absolute_max"));

                        if (validationControl.id == "textForchild_acknowledgement_of_receipt_date") {

                            if (__$(validationControl.id).value.match(/[?=]/i) != null) {

                              showMsg("Please enter exact date")
                              unTicked(i);

                              return false;
                          }

                        }
                        else if (validationControl.id == "textForchild_mother_birthdate" || validationControl.id == "textForchild_birthdate" || validationControl.id == "textForchild_date_of_marriage"){

                          if (__$(validationControl.id).value.split('/')[2] == "?") {

                              showMsg("Please enter atleast year.");

                              unTicked(i);

                              return false;

                          }
/*
                          else if (__$(validationControl.id).value.split('/')[1] == "?" && validationControl.id == "textForchild_mother_birthdate"){

                            if (__$('child_mother_birthdate').value.split('/')[2] > __$('child_birthdate').value.split('/')[2]){
                              showMsg("Mother younger than child.");

                              if (__$("cell" + i + ".3")) {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                              }

                              return false;
                            }

                          }
*/
                            if(validationControl.value.trim().match(/\W?/i) != null){
                                // adding checks for unknown dates with years

                                entered_date = validationControl.value.trim().split("/")

                                if (entered_date[1] == '?') {
                                    entered_date[0] = "1";
                                    entered_date[1] = "07";
                                }
                                else if (entered_date[0] == '?') {
                                    entered_date[0] = "15"
                                }

                                date = new Date(entered_date[0] + "/" + entered_date[1] + "/" + entered_date[2]);
                            }

                        }

                        if (date > absolute_date) {

                            showMsg("The date that you have entered is greater than the \nexpected date ("+ absolute_date.toLocaleFormat( "%d %b %Y" ) +"). \nPlease enter a valid date.");

                            unTicked(i);

                            return false;

                        }

                    }

                } else if (parent.getAttribute("fieldtype") == "password") {

                  if (validationControl) {

                    if (eval(validationControl.value.trim().length > eval(parent.getAttribute("absolute_max")))) {

                      showMsg("The value you have entered is greater than the \nexpected value("+parent.getAttribute("absolute_max")+").\nPlease enter a valid value.");

                      unTicked(i);

                      return false;

                    }

                  }

                } else {

                    if (validationControl) {

                        if (validationControl.value.trim() != "N/A"){
                            if (eval(validationControl.value.trim()) > eval(parent.getAttribute("absolute_max"))) {

                                showMsg("The value you have entered is greater than the \nexpected value("+parent.getAttribute("absolute_max")+").\nPlease enter a valid value.");

                                if (__$("cell" + i + ".3")) {

                                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                                }

                                return false;

                            }
                            /*
                            if (validationControl.id == "textForchild_birth_weight"){

                                if ((validationControl.value.trim().split(".")[1] || []).length > 3)
                                {
                                    var msg = "Expecting baby weight to have 3 decimal places.\nRound birth weight to 3 decimal places?";

                                    var action = 'var birth_weight = __$("textForchild_birth_weight").value.trim(); ' +
                                        'var birth_weight_rounded = round(birth_weight,3); __$("textForchild_birth_weight").value = ' +
                                        ' birth_weight_rounded; __$("child_birth_weight").value = birth_weight_rounded; gotoNext();';

                                    // msg, action, width, title, noAction

                                    showMsgForAction(msg, action, undefined, undefined, "dontGo()");

                                    return false;

                                }
                            } */
                        }
                    }

                }

            }

            if (parent.getAttribute("max") != null) {

                if (parent.getAttribute("fieldtype") == "date" || parent.getAttribute("fieldtype") == "age") {

                    if (validationControl) {

                        var date = new Date(validationControl.value.trim());
                        var max_date = new Date(parent.getAttribute("max"));

                        if (validationControl.id == "textForchild_mother_birthdate" || validationControl.id == "textForchild_birthdate" || validationControl.id == "textForchild_date_of_marriage")
                        {
                            if (validationControl.value.trim().match(/\W?/i)){
                                entered_date = validationControl.value.trim().split("/")

                                if (entered_date[1] == '?') {
                                    entered_date[0] = "1";
                                    entered_date[1] = "07";
                                }
                                else if (entered_date[0] == '?') {
                                    entered_date[0] = "15"
                                }

                                date = new Date(entered_date[0] + "/" + entered_date[1] + "/" + entered_date[2]);
                            }
                        }

                        if (date > max_date) {

                            var msg = "The date you have entered is greater than the maximum \nrequired date ("+ max_date.toLocaleFormat( "%d %b %Y" ) +").Should we keep the same value?";

                            var action = 'var i = ' + i + '; var id = "' + parent.id + '"; __$(id).setAttribute("max", "' +
                                validationControl.value.trim() + '"); __$("textFor" + id).setAttribute("max", "' +
                                validationControl.value.trim() + '"); ' + '__$("cell" + i + ".3").innerHTML = "<img src=\'' +
                                imgTick + '\' height=60 />"; gotoNext();';

                            showMsgForAction(msg, action, undefined, undefined, "dontGo()");

                            return false;

                        }

                    }

                } else {

                    if (validationControl) {
                        if (validationControl.value.trim() != "N/A"){
                            if (eval(validationControl.value.trim()) > eval(parent.getAttribute("max"))) {

                                var msg = "The value you entered is greater than expected("+parent.getAttribute("max")+").\nShould we keep the same value?";

                                var action = 'var i = ' + i + '; var id = "' + parent.id + '"; __$(id).setAttribute("max", "' +
                                    validationControl.value.trim() + '"); __$("textFor" + id).setAttribute("max", "' +
                                    validationControl.value.trim() + '"); ' + '__$("cell" + i + ".3").innerHTML = "<img src=\'' +
                                    imgTick + '\' height=60 />"; gotoNext();';

                                showMsgForAction(msg, action);

                                return false;

                            }
                        }
                    }

                }

            }

            if (parent.getAttribute("absolute_min") != null) {

                if (parent.getAttribute("fieldtype") == "date" || parent.getAttribute("fieldtype") == "age") {
                    if (validationControl) {
                        var date = new Date(validationControl.value.trim());
                        var absolute_date = new Date(parent.getAttribute("absolute_min"));

                        if (validationControl.id == "textForchild_mother_birthdate" || validationControl.id == "textForchild_birthdate" || validationControl.id == "textForchild_date_of_marriage")
                        {
                            if (validationControl.value.trim().match(/\W?/i)){
                                entered_date = validationControl.value.trim().split("/")

                                if (entered_date[1] == '?') {
                                    entered_date[0] = "1";
                                    entered_date[1] = "07";
                                }
                                else if (entered_date[0] == '?') {
                                    entered_date[0] = "15"
                                }

                                date = new Date(entered_date[0] + "/" + entered_date[1] + "/" + entered_date[2]);
                            }
                        }

                        if (date < absolute_date) {

                            showMsg("The date you have entered is less than the minimum required date ("+ absolute_date.toLocaleFormat( "%d %b %Y" )+").\nPlease enter a valid date");

                            if (__$("cell" + i + ".3")) {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                            }

                            return false;

                        }

                    }
                } else if (parent.getAttribute("fieldtype") == "password") {

                  if (validationControl) {

                    if (eval(validationControl.value.trim().length < eval(parent.getAttribute("absolute_min")))) {

                      showMsg("The value you have entered is less than the \nexpected value("+parent.getAttribute("absolute_min")+").\nPlease enter a valid value.");

                      unTicked(i);

                      return false;

                    }

                  }

                } else {

                    if (validationControl) {
                        if (validationControl.value.trim() != "N/A"){
                            if (eval(validationControl.value.trim()) < eval(parent.getAttribute("absolute_min"))) {


                                showMsg("The value you entered is less than minimum allowable("+parent.getAttribute("absolute_min")+"). \nPlease enter a valid date");

                                if (__$("cell" + i + ".3")) {

                                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                                }

                                return false;

                            }
                            if (validationControl.id == "textForchild_birth_weight"){

                                  if (eval(validationControl.value.trim()) < eval(parent.getAttribute("min"))) {

                                    var msg = "The value you entered is less than ("+parent.getAttribute("min")+") expected.\nShould we keep the same value?";

                                    var action = 'var i = ' + i + '; var id = "' + parent.id + '"; __$(id).setAttribute("min", "' +
                                    validationControl.value.trim() + '"); __$("textFor" + id).setAttribute("min", "' +
                                    validationControl.value.trim() + '"); ' + '__$("cell" + i + ".3").innerHTML = "<img src=\'' +
                                    imgTick + '\' height=60 />"; gotoNext();';

                                    showMsgForAction(msg, action);

                                    return false;
                                }


                                if ((validationControl.value.trim().split(".")[1] || []).length > 3)
                                {
                                    var msg = "Expecting baby weight to have 3 decimal places.\nRound birth weight to 3 decimal places?";

                                    var action = 'var birth_weight = __$("textForchild_birth_weight").value.trim(); ' +
                                        'var birth_weight_rounded = round(birth_weight,3); __$("textForchild_birth_weight").value = ' +
                                        ' birth_weight_rounded; __$("child_birth_weight").value = birth_weight_rounded; gotoNext();';

                                    // msg, action, width, title, noAction

                                    showMsgForAction(msg, action, undefined, undefined, "dontGo()");

                                    return false;

                                }
                            }
                        }
                    }
                }
            }

            if (parent.getAttribute("min") != null) {

                if (parent.getAttribute("fieldtype") == "date" || parent.getAttribute("fieldtype") == "age") {

                    if (validationControl) {

                        var date = new Date(validationControl.value.trim());
                        var min_date = new Date(parent.getAttribute("min"));

                        if (validationControl.id == "textForchild_mother_birthdate" || validationControl.id == "textForchild_birthdate" || validationControl.id == "textForchild_date_of_marriage")
                        {
                            if (validationControl.value.trim().match(/\W?/i)){
                                entered_date = validationControl.value.trim().split("/")

                                if (entered_date[1] == '?') {
                                    entered_date[0] = "1";
                                    entered_date[1] = "07";
                                }
                                else if (entered_date[0] == '?') {
                                    entered_date[0] = "15"
                                }

                                date = new Date(entered_date[0] + "/" + entered_date[1] + "/" + entered_date[2]);
                            }
                        }

                        if (date < min_date) {

                            var msg = "The date you have entered is less than the minimum required date("+min_date.toLocaleFormat( "%d %b %Y" )+").\nShould we keep the same value?";

                            var action = 'var i = ' + i + '; var id = "' + parent.id + '"; __$(id).setAttribute("min", "' +
                                validationControl.value.trim() + '"); __$("textFor" + id).setAttribute("min", "' +
                                validationControl.value.trim() + '"); ' + '__$("cell" + i + ".3").innerHTML = "<img src=\'' +
                                imgTick + '\' height=60 />"; gotoNext();';

                            showMsgForAction(msg, action, undefined, undefined, "dontGo()");

                            return false;

                        }

                    }

                } else {

                    if (validationControl) {
                        if (validationControl.value.trim() != "N/A"){
                            if (eval(validationControl.value.trim()) < eval(parent.getAttribute("min"))) {

                                var msg = "The value you entered is less than ("+parent.getAttribute("min")+") expected.\nShould we keep the same value?";

                                var action = 'var i = ' + i + '; var id = "' + parent.id + '"; __$(id).setAttribute("min", "' +
                                    validationControl.value.trim() + '"); __$("textFor" + id).setAttribute("min", "' +
                                    validationControl.value.trim() + '"); ' + '__$("cell" + i + ".3").innerHTML = "<img src=\'' +
                                    imgTick + '\' height=60 />"; gotoNext();';

                                showMsgForAction(msg, action);

                                return false;
                            }

                        }
                    }
                }

            }

            if (parent.getAttribute("regex") != null) {

                if (validationControl) {
                    if (validationControl.value.trim() != "N/A"){
                        var re = RegExp(parent.getAttribute("regex"));

                        if (__$("textForchild_birth_weight") != null) {

                            __$("textForchild_birth_weight").value.search(re)

                        } else if (__$("textForchild_informant_phone_number") != null) {

                            __$("textForchild_informant_phone_number").value.search(re)

                        }

                        if (validationControl.value.trim().search(re) == -1) {

                            if (__$("textForchild_birth_weight") != null && parent.getAttribute("regex_message") != null) {

                                var msg = parent.getAttribute("regex_message");

                                var action = 'var birth_weight = __$("textForchild_birth_weight").value.trim().split("."); ' +
                                    'var birth_weight_padded = padZerosAfter(birth_weight); __$("textForchild_birth_weight").value = ' +
                                    ' birth_weight_padded; __$("child_birth_weight").value = birth_weight_padded; gotoNext();';

                                // msg, action, width, title, noAction

                                showMsgForAction(msg, action, undefined, undefined, "dontGo()");

                                return false;

                            } else if ((__$("textForchild_informant_phone_number") != null && parent.getAttribute("regex_message") != null)) {

                                showMsg(parent.getAttribute("regex_message"));


                            } else {

                                showMsg("Please enter a value in the empty field.");

                            }

                            if (__$("cell" + i + ".3")) {

                                __$("cell" + i + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

                            }

                            return false;

                        }

                    }

                }

            }

            if (__$("cell" + i + ".3")) {

                if (parent.getAttribute("optional") == null) {

                    __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                } else {

                    if (validationControl.value.trim().length > 0) {

                        __$("cell" + i + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

                    } else {

                        __$("cell" + i + ".3").innerHTML = "";

                    }

                }

            }

        }

    }

    validatingAlready = false;

    // checkConditions();

    return true;

}

function unTicked(index){

  if (__$("cell" + index + ".3")) {

    __$("cell" + index + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

  }

}

function showMsg(msg, errorMessage) {

    showShield(undefined, true);

    if (!__$("shield")) {

        showShield(undefined, true);

    }

    var popup = document.createElement("div");
    popup.id = "popup";
    popup.style.position = "absolute";
    popup.style.minHeight = "200px";
    popup.style.top = "20%";

    if (errorMessage == true) {
      popup.style.width = "500px";
      popup.style.left = ((window.innerWidth - 500) / 2) + "px";
    } else {
      popup.style.width = "330px";
      popup.style.left = ((window.innerWidth - 330) / 2) + "px";
    }

    popup.style.backgroundColor = "#eee";
    popup.style.zIndex = 120;
    popup.style.border = "2px outset #eee";
    popup.style.borderRadius = "8px";

    document.body.appendChild(popup);

    var table = document.createElement("table");
    table.width = "100%";
    table.style.fontSize = "24px";

    popup.appendChild(table);

    var tbody = document.createElement("tbody");

    table.appendChild(tbody);

    var tr1 = document.createElement("tr");

    tbody.appendChild(tr1);

    var th = document.createElement("th");

    if (errorMessage == true) {
		  th.innerHTML = "Error";
		  th.style.backgroundColor = "#ff9900";
		  th.style.color = "#000";
    } else {
		  th.innerHTML = "Info";
		  th.style.backgroundColor = "#345d8c";
		  th.style.color = "#fff";
    }

    th.style.borderTopLeftRadius = "8px";
    th.style.borderTopRightRadius = "8px";
    th.style.border = "2px outset #23538a";
    th.colSpan = "2";
    th.style.padding = "5px";

    tr1.appendChild(th);

    var tr2 = document.createElement("tr");

    tbody.appendChild(tr2);

    var td1_1 = document.createElement("td");
    td1_1.colSpan = "2";
    td1_1.style.padding = "5px";
    td1_1.style.paddingTop = "15px";
    td1_1.style.paddingBottom = "15px";

    if (errorMessage == true) {
       td1_1.style.paddingLeft = "25px";
       td1_1.align = "left";
    } else {

      td1_1.align = "center";
    }

    td1_1.innerHTML = msg;
    td1_1.style.lineHeight = "120%";
    td1_1.style.fontSize = "20px";

    tr2.appendChild(td1_1);

    var tr3 = document.createElement("tr");

    tbody.appendChild(tr3);

    var td2_2 = document.createElement("td");
    td2_2.align = "center";
    td2_2.style.padding = "10px";
    td2_2.colSpan = "2";

    tr3.appendChild(td2_2);

    var btnYes = document.createElement("button");
    btnYes.className = "blue";
    btnYes.innerHTML = "OK";
    btnYes.style.width = "120px";
    btnYes.style.cursor = "pointer";
    btnYes.style.fontSize = "24px";
    btnYes.style.minHeight = "60px";

    td2_2.appendChild(btnYes);

    btnYes.onmousedown = function () {

        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("shield")) {

            document.body.removeChild(__$("shield"));

        }

    }

}

function showMsgForAction(msg, action, width, title, noAction) {

    showShield(undefined, true);

    if (!__$("shield")) {

        showShield(undefined, true);

    }

    var popup = document.createElement("div");
    popup.id = "popup";
    popup.style.position = "absolute";
    popup.style.minWidth = "750px";
    popup.style.minHeight = "200px";
    popup.style.top = "20%";
    // popup.style.width = (width == undefined ? "330px" : width);
    popup.style.left = ((window.innerWidth - 330) / 2) + "px";
    popup.style.backgroundColor = "#eee";
    popup.style.zIndex = 120;
    popup.style.border = "2px outset #eee";
    popup.style.borderRadius = "8px";

    document.body.appendChild(popup);

    var table = document.createElement("table");
    table.width = "100%";
    table.style.fontSize = "24px";

    popup.appendChild(table);

    var tbody = document.createElement("tbody");

    table.appendChild(tbody);

    var tr1 = document.createElement("tr");

    tbody.appendChild(tr1);

    var th = document.createElement("th");
    th.innerHTML = (title == undefined ? "Info" : title);
    th.style.backgroundColor = "#345d8c";
    th.style.color = "#fff";
    th.style.borderTopLeftRadius = "8px";
    th.style.borderTopRightRadius = "8px";
    th.style.border = "2px outset #23538a";
    th.colSpan = "2";
    th.style.padding = "5px";

    tr1.appendChild(th);

    var tr2 = document.createElement("tr");

    tbody.appendChild(tr2);

    var td1_1 = document.createElement("td");
    td1_1.colSpan = "2";
    td1_1.style.padding = "5px";
    td1_1.style.paddingTop = "15px";
    td1_1.style.paddingBottom = "15px";
    td1_1.align = "center";
    td1_1.innerHTML = msg;
    td1_1.style.lineHeight = "120%";
    td1_1.style.fontSize = "20px";

    tr2.appendChild(td1_1);

    var tr3 = document.createElement("tr");

    tbody.appendChild(tr3);

    var td2_1 = document.createElement("td");
    td2_1.align = "center";
    td2_1.style.padding = "10px";

    tr3.appendChild(td2_1);

    var td2_2 = document.createElement("td");
    td2_2.align = "center";
    td2_2.style.padding = "10px";

    tr3.appendChild(td2_2);

    var btnCancel = document.createElement("button");
    btnCancel.className = "blue";
    btnCancel.innerHTML = "Cancel";
    btnCancel.style.visibility = "hidden"
    btnCancel.style.width = "120px";
    btnCancel.style.cursor = "pointer";
    btnCancel.style.fontSize = "24px";
    btnCancel.style.minHeight = "60px";
    btnCancel.style.marginRight = "20px"
    btnCancel.id = "cancel"
    td2_2.appendChild(btnCancel);

    var btnNo = document.createElement("button");
    btnNo.className = "blue";
    btnNo.innerHTML = "No";
    btnNo.style.width = "120px";
    btnNo.style.cursor = "pointer";
    btnNo.style.fontSize = "24px";
    btnNo.style.minHeight = "60px";
    btnNo.style.marginRight = "20px"
    btnNo.id = "no"

    td2_2.appendChild(btnNo);

    var btnYes = document.createElement("button");
    btnYes.className = "blue";
    btnYes.innerHTML = "Yes";
    btnYes.id = "yes"
    btnYes.style.width = "120px";
    btnYes.style.cursor = "pointer";
    btnYes.style.fontSize = "24px";
    btnYes.style.marginRight = "20px"
    btnYes.style.minHeight = "60px";

    td2_2.appendChild(btnYes);

    btnYes.onmousedown = function () {

        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("shield")) {

            document.body.removeChild(__$("shield"));

        }

        eval(action);

    }

    btnCancel.onmousedown = function(){
        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("shield")) {

            document.body.removeChild(__$("shield"));

        }
    }

    btnNo.onmousedown = function () {

        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("shield")) {

            document.body.removeChild(__$("shield"));

        }

        if (noAction != undefined) {

            eval(noAction);

        }

    }

    if (__$("popup")) {

        var c = checkCtrl(__$("popup"));

        // [w, h, t, l]

        if (c[1] > 240) {

            __$("popup").style.top = ((window.innerHeight / 2) - (c[1] / 2)) + "px";

        }

        if (c[0] > 330) {

            __$("popup").style.left = ((window.innerWidth / 2) - (c[0] / 2)) + "px";

        }

    }

}


function checkConditions() {

    showSpinner();

    // clearTimeout(validityTmr);

    var fields = navigablefieldsets[currentPage];		// fieldsets[currentPage].elements;

    incomplete = false;

    for (var i = 0; i < fields.length; i++) {

        if (fields[i].getAttribute("condition") != null) {

            if (!eval(fields[i].getAttribute("condition"))) {

                if (__$("textFor" + fields[i].id)) {

                    __$("textFor" + fields[i].id).value = "";

                    fields[i].id.value = "";

                    __$("textFor" + fields[i].id).setAttribute("disabled", true);

                    if (__$("cell" + i + ".3")) {

                        __$("cell" + i + ".3").innerHTML = "";

                    }

                } else if (fields[i].type == "radio") {

                    fields[i].checked = false;

                    if (__$("btn" + fields[i].id)) {

                        __$("btn" + fields[i].id).setAttribute("disabled", true);

                        __$("btn" + fields[i].id).className = "button gray";

                    }

                }

                if (__$("cell" + i + ".0")) {

                    __$("cell" + i + ".0").style.opacity = "0.4";

                }

                fields[i].setAttribute("disabled", true);

            } else {

                if (__$("textFor" + fields[i].id)) {

                    __$("textFor" + fields[i].id).removeAttribute("disabled");

                } else if (fields[i].type == "radio") {

                    if (__$("btn" + fields[i].id) && __$("btn" + fields[i].id).getAttribute("disabled")) {

                        __$("btn" + fields[i].id).removeAttribute("disabled");

                        __$("btn" + fields[i].id).className = "button blue";

                    }

                }

                if (__$("cell" + i + ".0")) {

                    __$("cell" + i + ".0").style.opacity = "1";

                }

                fields[i].removeAttribute("disabled");

            }

        }
    }

    hideSpinner();

}

function clearMarks(section) {

    var fields = navigablefieldsets[section];

    for (var i = 0; i < fields.length; i++) {

        if (__$("cell" + i + ".3")) {

            __$("cell" + i + ".3").innerHTML = "";

        }

    }

}


function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function duplicatesPopup(data,checkbox){
       var people = data.response
       console.log(data.exact);
       if (__$("msg.shield")) {
            document.body.removeChild(__$("msg.shield"));
        }

        var shield = document.createElement("div");
        shield.style.position = "absolute";
        shield.style.position = "absolute";
        shield.style.top = "0px";
        shield.style.left = "0px";
        shield.style.width = "100%";
        shield.style.height = "100%";
        shield.id = "msg.shield";
        shield.style.backgroundColor = "rgba(128,128,128,0.5)";
        shield.style.zIndex = 1050;
        document.body.appendChild(shield);

        var width = 700;
        var height = 500;

        var div = document.createElement("div");
        div.id = "msg.popup";
        div.style.position = "absolute";
        div.style.width = width + "px";
        div.style.height = height + "px";
        div.style.backgroundColor = "#ffffff";
        div.style.overflowY = "scroll";
        div.style.borderRadius = "1px";
        div.style.left = "calc(50% - " + (width / 2) + "px)";
        div.style.top = "calc(50% - " + (height * 0.6) + "px)";
        div.style.border = "1px outset #fff";
        div.style.boxShadow = "5px 2px 5px 0px rgba(0,0,0,0.75)";
        div.style.fontFamily = "arial, helvetica, sans-serif";
        div.style.MozUserSelect = "none";

        shield.appendChild(div);

        var table = document.createElement("table");
        table.style.marginTop = "0.5%";
        table.style.height = "400px";
        table.style.width = "100%";
        table.style.margin ="auto";
        div.appendChild(table);

        var tr = document.createElement("tr");
        tr.style.height = "30px";
        table.appendChild(tr);

        var th =  document.createElement("th");
        th.colSpan = "5";
        th.style.padding = "0.8em";
        th.style.color = "#ffffff";
        th.style.fontSize = "1.2em";
        th.style.backgroundColor = "#526a83";
        th.innerHTML = "The record is "+(data.exact ? "exact" : "potential")+" duplicate to "+ (people && people.length ? people.length : "0")  +" record(s)";
        tr.appendChild(th);

        var tr = document.createElement("tr");
        tr.style.backgroundColor ="#e0dcdc"
        table.appendChild(tr);

        tr.style.height = "15px";

        var th = document.createElement("th");
        th.innerHTML = "#";
        th.style.padding = "0.5em"
        th.style.float ="left"
        tr.appendChild(th)


        var th = document.createElement("th");
        th.innerHTML = "Name(Sex)";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Date of Birth";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Mother's name";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Father's name";
        tr.appendChild(th);


        if(people){
            for(var i = 0; i < people.length ; i++){
              var tr = document.createElement("tr");
              table.appendChild(tr);
              tr.style.height = "15px";

              var td = document.createElement("td");
              td.style.borderBottom = "1px solid gray";
              td.style.width = "5%";
              td.innerHTML = (i + 1);
              td.style.padding = "0.5em"
              tr.appendChild(td);


              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = people[i]["_source"]["first_name"]+" "+ people[i]["_source"]["last_name"] + "("+people[i]["_source"]["gender"].split("")[0]+")";
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = new Date(people[i]["_source"]["birthdate"]).format();
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = (people[i]["_source"]["mother_first_name"] ? people[i]["_source"]["mother_first_name"] : "") +
                             " " +(people[i]["_source"]["mother_last_name"]? people[i]["_source"]["mother_last_name"] : "N/A");
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
               td.innerHTML = (people[i]["_source"]["father_first_name"] ? people[i]["_source"]["father_first_name"] : "") +
                              " "+(people[i]["_source"]["father_last_name"]? people[i]["_source"]["father_last_name"] : "N/A");
              tr.appendChild(td);
            }
        }
        var tr = document.createElement("tr");
        table.appendChild(tr);

        var footdiv = document.createElement("div");
        footdiv.style.width = "100%";
        footdiv.style.height = "25%";
        footdiv.style.textAlign = "center";
        div.appendChild(footdiv);
        if(facility_type  =="FC"){
            var ok = document.createElement("button");
            ok.innerHTML = "Cancel";
            ok.className = "red";
            ok.id = "popup.ok"
            ok.style.height = "40px";
            ok.style.width = "15%"
            ok.onclick = function () {
               ids = people.map(function(person){
                    return person["_id"]
               }).join("|");
               __$("person_duplicate").value = ids;

               __$("person_is_exact_duplicate").value = data.exact
               window.location.href = "/"
            }
            footdiv.appendChild(ok);

        }else{

            var cancel = document.createElement("button");
            cancel.innerHTML = "Cancel";
            cancel.className = "red";
            cancel.id = "popup.cancel"
            cancel.style.height = "40px";
            cancel.style.width = "15%"
            cancel.style.marginRight ="10%";
            cancel.onclick = function () {
               document.body.removeChild(shield);
            }
            footdiv.appendChild(cancel);

            var ok = document.createElement("button");
            ok.innerHTML = "Proceed";
            ok.className = "blue";
            ok.id = "popup.ok"
            ok.style.height = "40px";
            ok.style.width = "15%"
            ok.onclick = function () {
               ids = people.map(function(person){
                    return person["_id"]
               }).join("|");
               __$("person_duplicate").value = ids;

               __$("person_is_exact_duplicate").value = data.exact
               if(data.exact && facility_type  =="FC"){
                   window.location.href = "/"
               }else{
                   document.body.removeChild(shield);
                   document.forms[0].submit();            
               }
            }
            footdiv.appendChild(ok);
        }
}

function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
function canSearchPotential(data){
    if(!data.exact && facility_type == "FC"){
        return false;
    }else{
        return true;
    }
}
function submitAfterSummary() {
    
    /*summaryHash = {
     "Child's Name" : ["child_first_name", "child_middle_name", "child_last_name"],
     "Mother's Name" : ["child_mother_first_name", "child_mother_middle_name", "child_mother_last_name"],
     "Father's Name" : ["child_father_first_name", "child_father_middle_name", "child_father_last_name"]
     }*/

    showSpinner();

    
    var duplicate_search = [
                                        "person_first_name",
                                        "person_last_name",
                                        "person_middle_name",
                                        "person_birth_district",
                                        "person_birthdate",
                                        "person_gender",
                                        "person_mother_last_name",
                                        "person_mother_first_name",
                                        "person_mother_middle_name",
                                        "person_foster_mother_last_name",
                                        "person_foster_mother_first_name",
                                        "person_foster_mother_middle_name",
                                        "person_father_first_name",
                                        "person_father_last_name",
                                        "person_father_middle_name",
                                        "person_foster_father_last_name",
                                        "person_foster_father_first_name",
                                        "person_foster_father_middle_name",
                                        "person_type_of_birth",
                                        "person_relationship"]

    var data = {"twin_id": getUrlVars()["id"]}

    for(var i = 0 ; i < duplicate_search.length ; i++){
        if (__$(duplicate_search[i]) && __$(duplicate_search[i]).value){
             data[duplicate_search[i].replace("person_","").replace("person_foster_","")] = __$(duplicate_search[i]).value
         } else {

         }
           
    }

    

    $.getJSON("/search_similar_record",data,function(response){

        
        if(response.response && response.response.length != 0 && canSearchPotential(response)){
            
            
            duplicatesPopup(response);

            hideSpinner();

        }else{
            var msg = "";

            var parent = document.createElement("div");

            var div = document.createElement("div");
            div.style.height = "300px";
            div.style.overflow = "auto";

            parent.appendChild(div);

            var table = document.createElement("table");
            table.style.width = "100%";

            div.appendChild(table);

            var tbody = document.createElement("tbody");

            table.appendChild(tbody);

            var keys = Object.keys(summaryHash);

            for (var i = 0; i < keys.length; i++) {

                var tr = document.createElement("tr");

                tbody.appendChild(tr);

                var td1 = document.createElement("th");
                td1.align = "right";
                td1.innerHTML = keys[i];
                td1.style.width = "50%";
                tr.appendChild(td1);

                var td2 = document.createElement("td");
                td2.innerHTML = ":";

                tr.appendChild(td2);

                var td3 = document.createElement("td");
                td3.style.width = "50%";
                var label = "";

                for (var j = 0; j < summaryHash[keys[i]].length; j++) {
                    if (__$(summaryHash[keys[i]][j])) {

                        if (label.trim().length > 0) {

                            label = label.trim() + " " + humanize(__$(summaryHash[keys[i]][j]).value);

                        } else {

                            label = humanize(__$(summaryHash[keys[i]][j]).value.trim());

                        }

                    }

                }

                label = (label.trim) ? label.trim() : label.replace(/^\s+/,'');

                if (label == '')
                  label = "<span class='blank'>N/A</span>"

                if (keys[i].match(/weight/i))
                  label = label + " Kg"

                td3.innerHTML = label;

                tr.appendChild(td3);

            }

            var pos = checkCtrl(parent);

            msg = parent.innerHTML;

            var action = "document.forms[0].submit();";

            hideSpinner();

            showMsgForAction(msg, action, "600px", "Captured Data Summary");
        }
    });

}

function humanize(str) {
  return str
  .replace(/^[\s_]+|[\s_]+$/g, '')
  .replace(/[_\s]+/g, ' ')
  .replace(/^[a-z]/, function(m) { return m.toUpperCase(); });
}

function gotoNext() {

    if (__$("cell" + cursorPos + ".3")) {

        __$("cell" + cursorPos + ".3").innerHTML = "<img src='" + imgTick + "' height=60 />";

    }

    if (clickCanGo())
        gotoQuestion(cursorPos, currentPage);

}

function dontGo() {

    if (__$("cell" + cursorPos + ".3")) {

        __$("cell" + cursorPos + ".3").innerHTML = "<img src='" + imgUnTick + "' height=60 />";

    }

    navigateTo(cursorPos, currentPage);

}


function round(value, decimals) {
    var number = Number(Math.round(value+'e'+decimals)+'e-'+decimals)
    return padZerosAfter(number.toString().split("."));
}


(function(open) {

    XMLHttpRequest.prototype.open = function(method, url, async, user, pass) {

        setTimeout(function(){showSpinner(null, false, false)}, 10);

        this.addEventListener("load", function() {
            hideSpinner();
        }, false);

        open.call(this, method, url, async, user, pass);
    };

})(XMLHttpRequest.prototype.open);

window.onbeforeunload = function(){

    setTimeout(function(){showSpinner(null, false, true)}, 10);

};

document.addEventListener('DOMContentLoaded', function() {

    hideSpinner();

});


setTimeout("checkScrolls()", 500);

// init();
//Custom date validations
var date_interval ;
function dateInterval(id,validation_date,estimatable){
        date_interval ? clearInterval(date_interval) : date_interval;
        var target = __$(id)
        if(!__$("textFor"+id)){
            clearInterval(date_interval);
            return
        }
        /*if(target.value.length == 0){
           resetDate(id,new Date(target.getAttribute("absolute_max")));
        }*/

        date_interval = setInterval(function(){

                  var today = new Date();
                  if(validation_date){
                    today = new Date(validation_date)
                  }else if(target.getAttribute("absolute_max")){
                      today = new Date(target.getAttribute("absolute_max"))        
                  }
                   var input_value;
                  if (!__$("textFor"+id)){
                        clearInterval(date_interval);
                        return
                  }else{
                      input_value  = __$("textFor"+id).value;
                  }

                  if(input_value.length == 0){
                     return;
                  }

                  var parts = input_value.split("/");
                  if(parts[0] == 0 && input_value.length != 0){

                     __$("textFor"+id).value = "?/"+parts[1]+"/"+parts[2]
                     __$("txtDateFor"+id).value = "?"
                     target.setAttribute("absolute_max",today.format());
                  }else if(parseInt(parts[2]) > today.getFullYear()){
                      __$("textFor"+id).value = parts[0]+"/"+parts[1]+"/"+today.getFullYear()
                      __$("txtYearFor"+id).value = today.getFullYear()
                  }else{
                    if(input_value.indexOf("?")>= 0){
                        var estimated = (parts[0] == "?" ? "15" : parts[0]) +"/"+
                                        (months.indexOf(parts[1]) >= 0 ? parts[1] : "Jul")
                                        +"/"+(parts[2] == "?" ? "2017" : parts[2]);   
                        if(months.indexOf(parts[1]) >= 0 && months.indexOf(parts[1]) > today.getMonth()){
                            if (!__$("shield")){
                                    showMsg("Date Estimated is greater than "+today.format(), "Date validation");
                                    resetDate(id, today)
                            }

                        }
                        __$(id).value = estimated;
                        if(__$(id+"_estimated")){
                            __$(id+"_estimated").value = 1 
                        }

                    }else{
                            var current_date = new Date(input_value);
                            if( current_date.format("YYYY-mm-dd") > today.format("YYYY-mm-dd")){
                                if (!__$("shield")){
                                    showMsg("Date Entered is greater than "+today.format(), "Date validation")
                                    resetDate(id, today)
                                }
                            }   
                    }
                
                  }

        },250);

}

function resetDate(target_id, today){
         if (today.getTime() === today.getTime()){
                __$("textFor"+ target_id).value  = today.getDate() +"/"+ months[today.getMonth()] + "/"+ today.getFullYear();
                __$("txtDateFor"+target_id).value = today.getDate();
                __$("txtMonthFor"+target_id).value = months[today.getMonth()];
                __$("txtYearFor"+ target_id).value = today.getFullYear()
         }else{
            __$("textFor"+ target_id).value  = "?/?/?";
            __$("txtDateFor"+target_id).value = "?"
            __$("txtMonthFor"+target_id).value = "?"
            __$("txtYearFor"+ target_id).value = "?"
            return;
         }
}

function clearDateInterval(id){
        clearInterval(date_interval);
        date_interval = null;
}

//Name validation
var spaceInterval ;
function checkSpace(id){
      spaceInterval? clearInterval(spaceInterval) : spaceInterval
      spaceInterval = setInterval(function(){
        if(!__$("textFor"+id)){
            clearInterval(spaceInterval);
            return
        }
        //console.log(__$("textFor"+id).value);
        var text_input =__$("textFor"+id).value
        if(text_input.length > 0){
          __$("textFor"+id).value = text_input.capitalize();
        }   
      },100);
      
}

var cont = {}
var name_length_interval
function validateNameLength(person,id,level){
     name_length_interval ? clearInterval(name_length_interval) : name_length_interval
      name_length_interval = setInterval(function(){
          if(!__$("textFor"+id)){
            clearInterval(name_length_interval);
            return;
          }
          var input  = __$("textFor"+id).value.trim();
          var regex = /^[a-zA-Z']{2,24}$/;
          var name_length = (__$(person+'_last_name') ? __$(person+'_last_name').value.length : "") + 
              (__$(person+'_first_name') ?  __$(person+'_first_name').value.length : "");

          if(__$(person+'_middle_name') && __$(person+'_middle_name').value.length > 0){
              name_length = name_length + __$(person+'_middle_name').value.split(" ").join("").length;
          }

          if(input.length > 0 ){
            if(parseInt(name_length) > 50){
              if(!__$("shield") && !cont[person]){
                    showMsg("Name of the person has "+name_length+" character(s) which is more than 50 characters", "Name length validations");
                    cont[person] = true
              }
            }
            if(!__$("shield")){
                var check_number_regex = /\d/;
                var check_space_regex = /\s/;
                var special_characters =  /[-!$%^&*()_+|~=`{}\[\]:";@\#<>?,.\/]/
                if(check_number_regex.test(input)){
                    showMsg("Name of the person can not contain a number", "Number in names validations");
                    __$("textFor"+id).value  = input.replace(check_number_regex,"")
                }else if(special_characters.test(input)){
                     showMsg("Name of the person can not contain special character(s)", "Special charactes validations");
                     __$("textFor"+id).value  = input.replace(special_characters,"")
                }else{

                }
            }

          }

      },200);
      //clearInterval(spaceInterval);
}

var special_characters_interval
function checkSpecialCharacters(id){
        special_characters_interval ? clearInterval(special_characters_interval) : special_characters_interval
        special_characters_interval = setInterval(function(){
          if(!__$("textFor"+id)){
              clearInterval(special_characters_interval);
              return;
          }
           var input  = __$("textFor"+id).value.trim();
           if(!__$("shield")){
                  var check_number_regex = /\d/;
                  var check_space_regex = /\s/;
                  var special_characters =  /[-!$%^&*()_+|~=`{}\[\]:";@\#<>?,'.\/]/
                  if(special_characters.test(input)){
                       showMsg("Name of the person contains special character(s)", "Special charactes validations");
                       __$("textFor"+id).value  = input.replace(special_characters,"")
                  }else{

                  }
            }
        },200);
}

var capitalize_all_interval 
function capitalizeAllCharacters(id){
        capitalize_all_interval ? clearInterval(capitalize_all_interval) : special_characters_interval;
        capitalize_all_interval = setInterval(function(){
            if(!__$("textFor"+id)){
                clearInterval(capitalize_all_interval);
                return;
            }
            __$("textFor"+id).value = __$("textFor"+id).value.toUpperCase();
            

        },200)
}

function loadDate(id, date){
        if(__$("textFor"+id) && __$("textFor"+id).value.trim() == ""){
            resetDate(id, new Date(date));
        }
}