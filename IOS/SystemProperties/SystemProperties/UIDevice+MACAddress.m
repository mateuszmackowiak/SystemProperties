//
//  UIDevice+MACAddress.m
//  SystemProperties
//
//  Created by Mateusz Mackowiak on 30.01.2013.
//
//

#import "UIDevice+MACAddress.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>

@implementation UIDevice (MACAddress)


-(NSString*) macAddress{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}


- (NSString *)uniqueDeviceIdentifier {
    
    // Create pointer to the string as UTF8
    const char *ptr = [[self macAddress] UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char hashedChars[CC_SHA256_DIGEST_LENGTH];
    
    // Hash pointer to hashedChars array
    CC_SHA256(ptr, CC_SHA256_DIGEST_LENGTH, hashedChars);
    
    // Convert SHA256 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString string];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        
        [output appendFormat:@"%02x",hashedChars[i]];
        
    }
    
    // add dashes
    [output insertString:@"-" atIndex:8];
    [output insertString:@"-" atIndex:13];
    [output insertString:@"-" atIndex:18];
    [output insertString:@"-" atIndex:23];
    [output insertString:@"-" atIndex:36];
    [output insertString:@"-" atIndex:49];
    [output insertString:@"-" atIndex:54];
    [output insertString:@"-" atIndex:59];
    [output insertString:@"-" atIndex:64];
    
    return [output uppercaseString];
 
}

@end
