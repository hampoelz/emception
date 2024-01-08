import * as Comlink from 'comlink';
import EmceptionWorker from './emception.worker.js';

const emception = Comlink.wrap(new EmceptionWorker());
window.emception = emception;
window.Comlink = Comlink;
