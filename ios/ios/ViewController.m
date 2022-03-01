//
//  ViewController.m
//  ios
//
//  Created by 孙武东 on 2022/3/1.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) UIProgressView *loadingProgressView;
@property (nonatomic, weak  ) WKUserContentController *userContentController;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@property (nonatomic, strong) WKWebView *wk_WebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.wk_WebView];
    [self registerBridge];
    [self loadRequest];
}

#pragma mark - delegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];


    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - private methods
- (void)loadRequest{

    NSURL *url = [NSURL URLWithString:@"http://10.10.6.165:8081/#/"];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:15.0];
    
    [self.wk_WebView loadRequest:theRequest];
    
}

- (void)registerBridge{
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.wk_WebView];
    
    [self.bridge registerHandler:@"nativeMethod" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC Echo called with: %@", data);
    }];
    [self.bridge registerHandler:@"getNativeData" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC Echo called with: %@", data);
        responseCallback(@"我是回传给dart的数据阿");
    }];
    [self.bridge registerHandler:@"dartMethod" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.wk_WebView evaluateJavaScript: @"flutterMethod()"
           completionHandler:^(id response, NSError * error) {
               NSLog(@"response: %@, \nerror: %@", response, error);
           }];
    }];
    [self.bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);
    }];
    
}

#pragma mark - getter and setters

- (WKWebView*)wk_WebView {
    if (!_wk_WebView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        config.preferences = [[WKPreferences alloc]init];
        WKUserContentController *userContentController = [[WKUserContentController alloc]init];  //交互的重要之点
        config.userContentController = userContentController;

        _wk_WebView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        _wk_WebView.scrollView.backgroundColor = [UIColor whiteColor];
        _wk_WebView.backgroundColor = [UIColor whiteColor];
        _wk_WebView.navigationDelegate = self;
        _wk_WebView.UIDelegate = self;
        [_wk_WebView setClearsContextBeforeDrawing:NO];
        _wk_WebView.scrollView.bounces = NO;
    }
    return _wk_WebView;
}

@end
