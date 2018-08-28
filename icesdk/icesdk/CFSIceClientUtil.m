//
//  CFSIceClientUtil.m
//  icesdk
//
//  Created by allen on 2018/8/28.
//  Copyright © 2018年 cinfsec. All rights reserved.
//

#import "CFSIceClientUtil.h"

@interface CFSIceClientUtil(){
    id<ICECommunicator> communicator;
    NSMutableDictionary * cls2PrxMap;
}

@end
@implementation CFSIceClientUtil
+ (instancetype)sharedInstance {
    static CFSIceClientUtil *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[CFSIceClientUtil alloc]init];
        [_shared createCommunicator];
    });
    
    return _shared;
}
-(void)createCommunicator
{
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties setProperty:@"Ice.Default.Locator" value:@"CINFSEC/Locator:tcp -h 10.15.135.88 -p 23000"];
    [initData.properties setProperty:@"Ice.ACM.Client.Timeout" value:@"5"];
    [initData.properties setProperty:@"Ice.Override.Timeout" value:@"5000"];
    [initData.properties setProperty:@"Ice.Override.ConnectTimeout" value:@"10000"];
    
    // Dispatch AMI callbacks on the main thread 设置必须要异步调用，这个是保证异步回调在主线程执行
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
    };
    communicator = [ICEUtil createCommunicator:initData];
    cls2PrxMap = [NSMutableDictionary dictionary];
}
- (id<ICEObjectPrx>) getServicePrx:(NSString*)serviceName class:(Class)serviceCls{
    id<ICEObjectPrx> proxy = [cls2PrxMap objectForKey:serviceName];
    if(proxy != nil){
        return proxy;
    }
    proxy = [self createIceProxy:communicator serviceName:serviceName class:serviceCls];
    [cls2PrxMap setObject:proxy forKey:serviceName];
    
    return proxy;
}

- (id<ICEObjectPrx>) createIceProxy:(id<ICECommunicator>)c serviceName:(NSString*)serviceName class:(Class)serviceCls {
    id<ICEObjectPrx> proxy = nil;
    @try{
        ICEObjectPrx* base = [communicator stringToProxy:serviceName];
        NSLog(@"base Identity:\nname:%@ category:%@",[base ice_getIdentity].name,[base ice_getIdentity].category);
//        base = [base ice_invocationTimeout:5000];//设置timeout后，不能用checkedCast 会系统报错 trycatch 都捕抓不到err
        SEL selector = NSSelectorFromString(@"uncheckedCast:");
        proxy = [serviceCls performSelector:selector withObject:base];
        return proxy;
    } @catch(ICEEndpointParseException* ex) {
        NSLog(@"ICEEndpointParseException %@",[ex description]);
        return nil;
    } @catch(ICEException* ex) {
        NSLog(@"ICEException %@",[ex description]);
        return nil;
    }@catch(NSException* ex){
        NSLog(@"NSException %@",[ex description]);
        return nil;
    }
}
@end
