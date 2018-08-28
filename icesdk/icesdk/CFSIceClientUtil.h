//
//  CFSIceClientUtil.h
//  icesdk
//
//  Created by allen on 2018/8/28.
//  Copyright © 2018年 cinfsec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Ice.h>
@interface CFSIceClientUtil : NSObject
+ (instancetype)sharedInstance;
- (id<ICEObjectPrx>) getServicePrx:(NSString*)serviceName class:(Class)serviceCls;

- (id<ICEObjectPrx>) createIceProxy:(id<ICECommunicator>)c serviceName:(NSString*)serviceName class:(Class)serviceCls;
@end
