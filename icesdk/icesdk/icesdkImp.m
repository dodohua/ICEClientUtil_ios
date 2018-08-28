//
//  icesdkImp.m
//  icesdk
//
//  Created by allen on 2018/8/27.
//  Copyright © 2018年 cinfsec. All rights reserved.
//

#import "icesdkImp.h"
#import <objc/Ice.h>
#import <service.h>
#import "CFSIceClientUtil.h"

@implementation icesdkImp
+(void)iceTest
{
    id<entryEntryServicePrx> prx = (id<entryEntryServicePrx>)[[CFSIceClientUtil sharedInstance]getServicePrx:@"EntryService" class:[entryEntryServicePrx class]];
    
    
    for (int i = 0; i<10000; i++) {
        [prx begin_login:@"123" response:^(NSMutableString *str) {
            NSLog(@"登录返回值：%@",str);
        } exception:^(ICEException *ex) {
            
            NSLog(@"请求报错%@",[ex description]);
        }];
        NSLog(@"i:%d",i);
    }
}
@end
