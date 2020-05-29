function stringResponse() {
    return "taylor";
}
function intResponse() {
    return 27;
}
function doubleResponse() {
    return 10.5;
}
function boolResponse() {
    return true;
}
function arrayResponse() {
    return [1, 2, 3, 4];
}
function jsonResponse() {
    return {
        name: "tmac",
        age: 27
    };
}
function noResponse() {}
function returnContents(contents) {
    return contents;
}
function nullableResponse(contents, returning) {
    if (returning) {
        return contents;
    } else {
        return null;
    }
}
function undefinedResponse(contents, returning) {
    if (returning) {
        return contents;
    } else {
        return undefined;
    }
}

var undefinable = undefined;
var nullable = null;
var string = "taylor";
var int = 27;
var double = 10.5;
var bool = true;
var array = [1, 2, 3, 4];
var json = {
    name: "tmac",
    age: 27
};
