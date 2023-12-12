import React, {useRef} from "react";
import {App, Button, Collapse, Flex, Space, notification, Layout, Menu, Breadcrumb, Row, Col} from "antd";
import {CopyOutlined, PlayCircleFilled, UndoOutlined} from "@ant-design/icons";
import Editor from "@monaco-editor/react";
const { Header, Content, Footer } = Layout;


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
                                                                   initialValue = "// code here",
                                                                   theme = "vs-dark",
                                                                   language = "cpp",
                                                                   height = "20vh"}) => {

    const [api, contextHolder] = notification.useNotification();


    function handleEditorChange(value: any, event: any) {
        // here is the current value
    }

    function handleEditorDidMount(editor: any, monaco: any) {
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

    const editorRef = useRef(null);
    const monacoRef = useRef(null);
    const outputRef = React.createRef<string>();

    const onRunClick= async () => {
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
        label: `nav ${index + 1}`,
    }));


    return (
        <>
            {contextHolder}
            <Layout>
                <Header style={{ display: 'flex', alignItems: 'center' }}>
                    <div className="demo-logo" />
                    <Menu
                        theme="dark"
                        mode="horizontal"
                        defaultSelectedKeys={['2']}
                        items={items}
                        style={{ flex: 1, minWidth: 0 }}
                    />
                </Header>

                <Content style={{padding: '0 48px'}}>
                    <Breadcrumb style={{margin: '16px 0'}} items={[{title: "Home"}, {title: "List"}, {title: "App"}]}/>
                    <div
                        style={{
                            // background: colorBgContainer,
                            minHeight: 280,
                            padding: 24,
                            // borderRadius: borderRadiusLG,
                        }}
                    >
                        <Space direction="vertical">
                            <p>{content}</p>
                            <p>ouintdaountaoeuntaoe aonhtd aoeunt adoeunthdao naontd aoncdao clado rclao lao drlcao
                                crldao lrcado ntaod naotd rcaeo daoecgd aonthd aeonthd cgre gaoedahnotd aoenhtd oaendthd
                                aonthdao ntado nhtadeocraoe gcraeodraeodreoa aogdd aehnot ao</p>
                            <Editor
                                height={height}
                                defaultLanguage={language}
                                theme={theme}
                                defaultValue={initialValue}
                                onChange={handleEditorChange}
                                onMount={handleEditorDidMount}
                                beforeMount={handleEditorWillMount}
                                onValidate={handleEditorValidation}
                            />
                            <Row justify="space-between">
                                <Col>
                                    <Space direction="horizontal">
                                        <Button type="primary" icon={<PlayCircleFilled/>}>Run</Button>
                                    </Space>
                                </Col>
                                <Col>
                                    <Button type="default" icon={<UndoOutlined/>}>Reset code</Button>
                                    <Button type="default" icon={<CopyOutlined/>}>Copy code</Button>
                                </Col>
                            </Row>
                        </Space>
                    </div>
                    <div style={containerStyle}>
                        <div style={style}>
                            {outputRef.current}
                        </div>
                    </div>
                </Content>
                <Footer style={{textAlign: 'center'}}>GameGuild ©2023 Created by Alexandre Tolstenko</Footer>
            </Layout>
        </>
    );
};

export default SyntaxTrainingPage;