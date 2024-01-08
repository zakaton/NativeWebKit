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
    isLoggingEnabled = false;
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
    isErrorEnabled = true;
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
const scriptsToInject = {
    id: "nativewebkit-injection-scripts",
    js: ["flag.js"],
    matches: ["<all_urls>"],
    runAt: "document_start",
    allFrames: true,
    world: "MAIN",
    persistAcrossSessions: true,
};

const injectScripts = async () => {
    const registeredContentScripts = await browser.scripting.getRegisteredContentScripts();
    _console.log("registeredContentScripts", registeredContentScripts);
    const registeredFlagScript = registeredContentScripts.find((script) => script.id == scriptsToInject.id);
    _console.log("were injection scripts already registered?", registeredFlagScript);
    if (!registeredFlagScript) {
        try {
            _console.log("trying to registerContentScripts...", [scriptsToInject]);
            browser.scripting.registerContentScripts([scriptsToInject]);
        } catch (error) {
            _console.error(error);
        }
    }
};
injectScripts();

// inject scripts into all active tabs,
// because injectScripts doesn't work when you quit/reopen Safari on iOS
browser.tabs.onCreated.addListener(async (event) => {
    _console.log("onCreated", event);
    if (!event.active) {
        return;
    }
    const tabId = event.id;
    await executeInjectionScripts(tabId);
});
browser.tabs.onUpdated.addListener(async (tabId) => {
    _console.log("onUpdated", tabId);
    await executeInjectionScripts(tabId);
});

const executeInjectionScripts = async (tabId) => {
    const tab = await browser.tabs.get(tabId);
    console.log("executeInjectionScript?", tab);
    if (!tab.active || tab.status == "loading") {
        return;
    }
    _console.log("executeInjectionScript", tab, tabId);
    try {
        await browser.scripting.executeScript({
            files: scriptsToInject.js,
            world: "MAIN",
            injectImmediately: true,
            target: { tabId, allFrames: true },
        });
    } catch (error) {
        _console.error("error for tabId", tabId, error);
    }
};

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
    if (!message) {
        return;
    }
    _console.log("received browser message", message, "from sender", sender);
    sendMessageToApp(message);
    sendResponse(true);
};
// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener(browserRuntimeMessageListener);
