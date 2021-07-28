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

function triggerMessage() {
    window.webkit.messageHandlers.ECMASwiftMessage.postMessage({"message":"hello!"});
}
function triggerRequestVoid() {
    window.webkit.messageHandlers.ECMASwiftRequest.postMessage({"object":"Jobs","toHandler":"setJobs","type":"function"});
}
function triggerRequestReturn() {
    window.webkit.messageHandlers.ECMASwiftRequest.postMessage({"object":"Person","toHandler":"returnContents","type":"function"});
}
function triggerPromptVariable() {
    window.webkit.messageHandlers.ECMASwiftPrompt.postMessage({"name":"json","type":"variable"});
}
function triggerPromptFunction() {
    window.webkit.messageHandlers.ECMASwiftPrompt.postMessage({"name":"jsonResponse","type":"function"});
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
