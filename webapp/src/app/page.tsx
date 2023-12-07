'use client';
import { DatePicker } from 'antd';
import { Button } from 'antd';

import * as monaco from "monaco-editor/esm/vs/editor/editor.api";
import { Terminal } from "xterm";
import { FitAddon } from 'xterm-addon-fit';
import Split from "split-grid";
import { spinner, previewTemplate, miniBrowserTemplate } from "./preview-template.mjs";

import { render, html } from "lit";

import EmceptionWorker from "./emception.worker.js";

import "./style.css";
import "xterm/css/xterm.css";

const emception = EmceptionWorker;

async function run() {
    console.log("run");
}
export default function Home() {
    // const emception = EmceptionWorker;
    const editorContainer = document.createElement("div");
    const editor = monaco.editor.create(editorContainer, {
        value: "",
        language: "cpp",
        theme: "vs-dark",
    });

    const terminalContainer = document.createElement("div");
    const terminal = new Terminal({
        convertEol: true,
        theme: {
            background: "#1e1e1e",
            foreground: "#d4d4d4",
        },
    });
    terminal.open(terminalContainer);

    const terminalFitAddon = new FitAddon();
    terminal.loadAddon(terminalFitAddon);

    editor.setValue(`#include <iostream>
int main(void) {
    std::cout << "hello world!\\n";
    return 0;
}
`);

    // emception.onstdout = Comlink.proxy((str: string) => terminal.write(str + "\n"));
    // emception.onstderr = Comlink.proxy((str: string) => terminal.write(str + "\n"));

    // window.addEventListener("resize", () => {
    //     editor.layout();
    //     terminalFitAddon.fit();
    // });

    // call run on click
    return <Button onClick={run}>Run</Button>;
}
