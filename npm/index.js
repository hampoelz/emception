import * as Comlink from "comlink";
import EmceptionWorker from "./emception.worker.js";

const emception = Comlink.wrap(new EmceptionWorker());

if(!window){
    window = {};
}

window.emception = emception;
window.Comlink = Comlink;

let cppValue = `#include <iostream>

int main(void) {
    std::cout << "Hello from CPP!\\n";
    return 0;
}
`;

emception.onstdout = Comlink.proxy((str) => console.log(str + "\n"));
emception.onstderr = Comlink.proxy((str) => console.log(str + "\n"));

window.onerror = function(event) {
    // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
    Module.setStatus('Exception thrown, see JavaScript console');
    spinnerElement.style.display = 'none';
    Module.setStatus = function(text) {
        if (text) console.error('[post-exception status] ' + text);
    };
};

async function main() {
    const onprocessstart = (argv) => {
        console.log("onprocessstart", argv);
    };
    const onprocessend = () => {
        // console.log("onprocessend");
    };

    emception.onprocessstart = Comlink.proxy(onprocessstart);
    emception.onprocessend = Comlink.proxy(onprocessend);

    console.log("Loading Emception...\n");

    await emception.init();

    console.log("Emception is ready\n");

    console.log("Compiling C++ code...\n");
    console.log(cppValue);

    let flags = "-O2 -fexceptions -sEXIT_RUNTIME=1";

    try {
        await emception.fileSystem.writeFile("/working/main.cpp", cppValue);
        const cmd = `em++ ${flags} -sSINGLE_FILE=1 -sUSE_CLOSURE_COMPILER=0 -sEXPORT_NAME='CppAreaModule' main.cpp -o main.js`;
        onprocessstart(`/emscripten/${cmd}`.split(/\s+/g));
        console.log(`$ ${cmd}\n\n`);
        const result = await emception.run(cmd);
        if (result.returncode == 0) {
            console.log("Emception compilation finished");
            const content = new TextDecoder().decode(await emception.fileSystem.readFile("/working/main.js"));
            eval(content);
            console.log("Execution finished");
        } else {
            console.log(`Emception compilation failed`);
        }
    } catch (err) {
        console.error(err);
    } finally {

    }
}

main();