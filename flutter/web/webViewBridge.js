function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
       return callback(WebViewJavascriptBridge); 
    }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback]; // 创建一个 WVJBCallbacks 全局属性数组，并将 callback 插入到数组中。
    var WVJBIframe = document.createElement('iframe'); // 创建一个 iframe 元素
    WVJBIframe.style.display = 'none'; // 不显示
    WVJBIframe.src = 'https://__BRIDGE_LOADED__'; // 设置 iframe 的 src 属性
    document.documentElement.appendChild(WVJBIframe); // 把 iframe 添加到当前文导航上。
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

function webviewBridge(fun,data) {
  setupWebViewJavascriptBridge(function(bridge){
      if ( window.WebViewJavascriptBridge) {
        window.WebViewJavascriptBridge.callHandler(fun,{'data':data});
      }
   
  });
}

function webviewCallBackBridge(fun,callback,data) {
    setupWebViewJavascriptBridge(function(bridge){
        if ( window.WebViewJavascriptBridge) {
            window.WebViewJavascriptBridge.callHandler(fun,{'data':data},callback);
          }
    });
}

window.setupWebViewJavascriptBridge = setupWebViewJavascriptBridge;
window.webviewBridge = webviewBridge;
window.webviewCallBackBridge = webviewCallBackBridge;