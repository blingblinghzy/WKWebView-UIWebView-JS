//
//  WebLoadViewController.m
//  Myfavor
//
//  Created by apple on 17/7/25.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WebLoadingViewController.h"

#import "WebViewJavascriptBridge.h"

@interface WebLoadingViewController () <WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
{
    WKWebView *_webView;
}
@property WebViewJavascriptBridge* bridge;
@end

@implementation WebLoadingViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    [_bridge setWebViewDelegate:self];
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        //js传值过来，
        NSLog(@"testObjcCallback called: %@", data);
//         native做完处理回传
        responseCallback(data);
    }];
}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];

        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.selectionGranularity = WKSelectionGranularityDynamic;
        config.allowsInlineMediaPlayback = YES;
        config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    
        WKPreferences *preferences = [WKPreferences new];
        //是否支持JavaScript
        preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preferences;
    
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 300, 700) configuration:config];
    [_webView setUserInteractionEnabled:YES];
   
//        [_webView setScalesPageToFit:YES];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
  
    _webView.backgroundColor = [UIColor whiteColor];
    
        [self.view addSubview:_webView];
        NSString * path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
        NSURL* url = [NSURL  fileURLWithPath:path];//创建URL
        NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
        [_webView loadRequest:request];//加载

    NSString * token = @"token";
    //将token刷入weblocalStorage供前端调用
    NSString *sendToken = [NSString stringWithFormat:@"localStorage.setItem(\"accessToken\",'%@');",token];
    
    //WKUserScriptInjectionTimeAtDocumentStart JS加载前执行
    //WKUserScriptInjectionTimeAtDocumentEnd JS加载后执行
    //injectionTime配置不要写错  forMainFrameOnly  NO(全局窗口) YES(只限主窗口)
    WKUserScript *sendTokenScript = [[WKUserScript alloc]initWithSource:sendToken injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    
    //注入JS
    [config.userContentController addUserScript:sendTokenScript];
    
}

#pragma mark - UIWebViewDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
    NSURL * url = [webView URL];

    NSString *str = url.absoluteString;
    NSLog(@"h5调用的URLStr=%@",str);
    
    if ([str isEqualToString:@"market://login"]) {

    }
 

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    调用js
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"clickAction1(%@)",@"777"] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"error222 = %@",error);
    }];

}


// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{

}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

       completionHandler();

   }]];

   [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
    
}



#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
  NSLog(@"name:%@\n body:%@\n frameInfo:%@\n",message.name,message.body,message.frameInfo);
//    NSString *bodyStr =(NSDictionary*) message.body;
    NSDictionary * dic = (NSDictionary*) message.body;
    if ([message.name isEqualToString:@"decryptSecretData"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"JS调用的OC回调方法" preferredStyle:UIAlertControllerStyleAlert];//testFunc(this.notifyDecryptedData)("333")
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self->_webView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)",dic[@"callback"],@"333"] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                NSLog(@"error = %@",error);
            }];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
  
}
- (void)dealloc {
  
//    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"decryptSecretData"];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
