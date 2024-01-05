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
    isWarningEnabled = true;
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

window.addEventListener("nativewebkit-send", async (event) => {
    const { id, message } = event.detail;
    _console.log(`received nativewebkit-send request #${id}`, message);
    const didReceiveResponse = await browser.runtime.sendMessage(message);
    _console.log(`did background.js receive response for nativewebkit-send request #${id}?`, didReceiveResponse);
    if (!didReceiveResponse) {
        _console.error("didn't receive response from background.js");
    }
    window.dispatchEvent(new CustomEvent(`nativewebkit-receive-${id}`, { detail: didReceiveResponse }));
});

window.addEventListener("is-nativewebkit-extension-installed", async (event) => {
    _console.log(`received "is-nativewebkit-extension-installed" message from browser`);
    window.dispatchEvent(new Event("nativewebkit-extension-is-installed"));
});

browser.runtime.onMessage.addListener((message) => {
    _console.log("received message from background.js: ", message);
    window.dispatchEvent(new CustomEvent("nativewebkit-receive", { detail: message }));
});
