//
//  WebLoadViewController.m
//  Myfavor
//
//  Created by apple on 17/7/25.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WebLoadViewController.h"
#import "UIWebView+TS_JavaScriptContext.h"

@protocol JSObjcDelegate <JSExport>
//js调用此方法获取token
- (NSString *)getToken;

@end

@interface WebLoadViewController () <TSWebViewDelegate,JSObjcDelegate>
{
    UIWebView *_webView;
}
@property (nonatomic, strong) JSContext *context;
@end

@implementation WebLoadViewController


- (void)viewDidLoad {

    [super viewDidLoad];

    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 300, 700)];
    [_webView setUserInteractionEnabled:YES];
    _webView.delegate = self;
    [self.view addSubview:_webView];

    NSString * path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL* url = [NSURL  fileURLWithPath:path];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [_webView loadRequest:request];//加载
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL * url = [request URL];

    NSString *str = url.absoluteString;
    NSLog(@"h5调用的URLStr=%@",str);

    if ([str isEqualToString:@"market://login"]) {
//    截取web链接并做相应处理，此为js调用native
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//页面加载完成后调用js
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"localStorage.setItem(%@,%@)", @"token", @"token"]];
    
    // 获取context对象
    self.context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //将AndroidWebView对象指向自身 js里面写window.AndroidWebView.indexOfMap() 就会调用原生里的indexOfMap方法
    self.context[@"IOSWebView"] = self;
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    // 获取到点击js按钮的事件
    self.context[@"clickAction0"] = ^(){
        NSLog(@"获取到点击js按钮的事件");
    };
    // oc调用js函数 并传参 js无返回值
    NSString *jsAction = @"clickAction1(555)";
    [self.context evaluateScript:jsAction];
    
    // oc调用js函数 并传参 接收js返回值
    NSString *str1 = [webView stringByEvaluatingJavaScriptFromString:@"clickAction2(666);"];
    NSLog(@"js函数给我的返回值：%@", str1);

}
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    // 获取context对象
    self.context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //将AndroidWebView对象指向自身 js里面写window.AndroidWebView.indexOfMap() 就会调用原生里的indexOfMap方法
    self.context[@"IOSWebView"] = self;
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}
//开放给js的API，返回token
- (NSString *)getToken {
    NSString * token = @"token";
    return token;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
   
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
