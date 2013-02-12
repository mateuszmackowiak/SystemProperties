//
//  UIDevice+MACAddress.h
//  SystemProperties
//
//  Created by Mateusz Mackowiak on 30.01.2013.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (MACAddress)

/**
 *John Muchow (http://iPhoneDeveloperTips.com/device/determine-mac-address.html)
 */
-(NSString*) macAddress;
- (NSString *)uniqueDeviceIdentifier;
@end
