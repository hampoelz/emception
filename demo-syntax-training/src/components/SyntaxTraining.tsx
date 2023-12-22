const path = require('path');
import { CopyOutlined, PlayCircleFilled, UndoOutlined } from "@ant-design/icons";
import { Editor } from "@monaco-editor/react";
import { Breadcrumb, Button, Col, Layout, Menu, notification, Row, Space } from "antd";

import * as Comlink from "comlink";
import { editor } from "monaco-editor";
import React, { useEffect, useRef } from "react";
import Emception from "./emception";

const { Header, Content, Footer } = Layout;

// import EmceptionWorker from "./emception.worker";
// const emception = Comlink.wrap(new EmceptionWorker());

// const emception = Comlink.wrap(worker);
// window.emception = emception;
// window.Comlink = Comlink;

const containerStyle: React.CSSProperties = {
  width: '100%',
  height: 100,
  overflow: 'auto',
  border: '1px solid #40a9ff',
};

const style: React.CSSProperties = {
  width: '100%',
};

interface SyntaxTrainingPageProps {
  content?: string;
  initialValue?: string;
  theme?: string;
  language?: string;
  height?: string;
}

const SyntaxTrainingPage: React.FC<SyntaxTrainingPageProps> = ({
                                                                 content = "Syntax Training Title",
                                                                 initialValue = "// code goes here",
                                                                 theme = "vs-dark",
                                                                 language = "cpp",
                                                                 height = "20vh"
                                                               }) => {

  const [api, contextHolder] = notification.useNotification();

  let emception: Emception;

  async function loadEmception(): Promise<any> {
    showNotification("Loading emception...");
    // const workerPath = path.join(__dirname, 'emception.worker.ts');

    const emceptionWorker = new Worker(new URL('./emception.worker.ts', import.meta.url), { type: 'module' });

    emception = Comlink.wrap(emceptionWorker);
    await emception.init();
    // emception = new Emception();
    // await emception.init();
    showNotification("Emception loaded");
  }

  useEffect(() => {
    loadEmception()
  }, []);

  // useEffect(() => {
  //     console.log('Component is mounted');
  //     loadEmception();
  // }, []);

  // var emceptionLoadingState: "notLoaded" | "loading" | "loaded" = "notLoaded";

  // async function loadEmception(): Promise<any> {
  //     if (emceptionLoadingState === "notLoaded") {
  //         showNotification("Loading emception...");
  //         emceptionLoadingState = "loading";
  //         (window as any).emception = await import("./emception");
  //         showNotification("Emception loaded");
  //         emceptionLoadingState = "loaded";
  //         console.log((window as any).emception);
  //     }
  //     return (window as any).emception;
  // }

  let editorRef = useRef<editor.IStandaloneCodeEditor | null>(null)
  let monacoRef = useRef(null);
  let outputRef = React.createRef<string>();

  function handleEditorChange(value: any, event: any) {
    // here is the current value
    console.log(value);
    console.log('event', event);
  }

  function handleEditorDidMount(editor: editor.IStandaloneCodeEditor, monaco: any) {
    editorRef.current = editor;
    monacoRef.current = monaco;
    console.log('onMount: the editor instance:', editor);
    console.log('onMount: the monaco instance:', monaco);
  }

  function handleEditorWillMount(monaco: any) {
    monacoRef.current = monaco;
    console.log('beforeMount: the monaco instance:', monaco);
  }

  function handleEditorValidation(markers: any) {
    // model markers
    // markers.forEach(marker => console.log('onValidate:', marker.message));
  }


  const onRunClick = async () => {
    console.log('onRunClick: the editor instance:', editorRef.current?.getValue());
    // get the instance of monaco editor from the CodeBlock component
  }

  const showNotification = (message: string) => {
    api.info({
      message: message,
      placement: 'topRight'
    });
  };

  const items = new Array(15).fill(null).map((_, index) => ({
    key: index + 1,
    label: `nav ${ index + 1 }`,
  }));

  const resetCode = () => {
    editorRef.current?.setValue(initialValue);
    showNotification('Code reset');
  }

  const copyCode = async () => {
    // await navigator.clipboard.writeText(editorRef.current?.getValue() || '')
  }

  return (
    <>
      { contextHolder }
      <Layout>
        <Header style={ { display: 'flex', alignItems: 'center' } }>
          <div className="demo-logo"/>
          <Menu
            theme="dark"
            mode="horizontal"
            defaultSelectedKeys={ ['2'] }
            items={ items }
            style={ { flex: 1, minWidth: 0 } }
          />
        </Header>

        <Content style={ { padding: '0 48px' } }>
          <Breadcrumb style={ { margin: '16px 0' } }
                      items={ [{ title: "Home" }, { title: "List" }, { title: "App" }] }/>
          <div
            style={ {
              // background: colorBgContainer,
              minHeight: 280,
              padding: 24,
              // borderRadius: borderRadiusLG,
            } }
          >
            <Space direction="vertical">
              <p>{ content }</p>
              <p>ouintdaountaoeuntaoe aonhtd aoeunt adoeunthdao naontd aoncdao clado rclao lao drlcao
                crldao lrcado ntaod naotd rcaeo daoecgd aonthd aeonthd cgre gaoedahnotd aoenhtd oaendthd
                aonthdao ntado nhtadeocraoe gcraeodraeodreoa aogdd aehnot ao</p>
              <Editor
                height={ height }
                defaultLanguage={ language }
                theme={ theme }
                defaultValue={ initialValue }
                onChange={ handleEditorChange }
                onMount={ handleEditorDidMount }
                beforeMount={ handleEditorWillMount }
                onValidate={ handleEditorValidation }
                options={ { automaticLayout: true, wordWrap: 'on' } }
              />
              <Row justify="space-between">
                <Col>
                  <Space direction="horizontal">
                    <Button type="primary" onClick={ onRunClick } icon={ <PlayCircleFilled/> }>Run</Button>
                  </Space>
                </Col>
                <Col>
                  <Button type="default" icon={ <UndoOutlined/> } onClick={ resetCode }>Reset code</Button>
                  <Button type="default" icon={ <CopyOutlined/> } onClick={ copyCode }>Copy code</Button>
                </Col>
              </Row>
            </Space>
          </div>
          <div style={ containerStyle }>
            <div style={ style }>
              { outputRef.current }
            </div>
          </div>
        </Content>
        <Footer style={ { textAlign: 'center' } }>GameGuild ©2023. Created by Alexandre Tolstenko.</Footer>
      </Layout>
    </>
  );
};

export default SyntaxTrainingPage;