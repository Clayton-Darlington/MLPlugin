import { MLPlugin } from 'ml-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    MLPlugin.echo({ value: inputValue })
}
