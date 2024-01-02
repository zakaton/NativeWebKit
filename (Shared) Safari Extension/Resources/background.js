class Console {
    /**
     * @callback LogFunction
     * @param {...any} data
     */

    #emptyFunction = function () {};

    /** @param {string|undefined} newPrefix */
    set prefix(newPrefix) {
        const args = [console];
        if (newPrefix) {
            if (Array.isArray(newPrefix)) {
                args.push(...newPrefix);
            } else {
                args.push(newPrefix);
            }
        }

        this.#log = console.log.bind(...args);
        this.#warn = console.warn.bind(...args);
        this.#error = console.error.bind(...args);
    }

    /** @type {boolean} */
    isLoggingEnabled = true;
    /** @type {LogFunction} */
    get log() {
        return this.isLoggingEnabled ? this.#log : this.#emptyFunction;
    }
    #log = console.log.bind(console);

    /** @type {boolean} */
    isWarningEnabled = false;
    /** @type {LogFunction} */
    get warn() {
        return this.isWarningEnabled ? this.#warn : this.#emptyFunction;
    }
    /** @type {LogFunction} */
    #warn = console.warn.bind(console);

    /** @type {boolean} */
    isErrorEnabled = false;
    /** @type {LogFunction} */
    get error() {
        return this.isErrorEnabled ? this.#error : this.#emptyFunction;
    }
    /** @type {LogFunction} */
    #error = console.error.bind(console);

    /** @param {boolean} isEnabled */
    set isEnabled(isEnabled) {
        this.isLoggingEnabled = isEnabled;
        this.isWarningEnabled = isEnabled;
        this.isErrorEnabled = isEnabled;
    }

    /**
     *
     * @param {string|undefined} prefix
     */
    constructor(prefix) {
        if (prefix) {
            this.prefix = prefix;
        }
    }
}

const _console = new Console();

 // inject "flag.js" in every webpage (window.isNativeWebKitSafariExtensionInstalled = true)
 const flagScript = {
     id: "nativewebkit-flag.js",
     js: ["flag.js"],
     matches: ["<all_urls>"],
     run_at: "document_start",
     all_frames: true,
     world: "MAIN",
     persistAcrossSessions: true,
 };

 try {
     _console.log("trying to registerContentScripts...", [flagScript]);
     browser.scripting.registerContentScripts([flagScript]);
 } catch (error) {
     _console.error(error);
 }

/**
 * @typedef NKMessage
 * @type {object}
 * @param {string} type
 */

/**
 * background.js -> SafariWebExtensionHandler.swift)
 * @param {NKMessage|NKMessage[]} message
 */
function sendMessageToApp(message) {
    _console.log("sending message to app", message);
    browser.runtime.sendNativeMessage("application.id", message, (response) => {
        _console.log("received response from app", response);
        if (response) {
            sendMessageToBrowser(response);
        }
    });
}

/**
 * background.js -> popup.js/content.js
 * @param {object} message
 */
async function sendMessageToBrowser(message) {
    browser.runtime.sendMessage(message);
    const tab = await browser.tabs.getCurrent();
    browser.tabs.sendMessage(tab.id, message);
}

/**
 * callback for background.js <- popup.js/content.js
 * @param {object} message
 * @param {MessageType} message.type
 * @param {object} sender
 * @param {(response:object)=>void} sendResponse
 */
const browserRuntimeMessageListener = (message, sender, sendResponse) => {
    _console.log("received browser message", message, "from sender", sender);
    sendMessageToApp(message);
    sendResponse(true);
};
// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener(browserRuntimeMessageListener);
