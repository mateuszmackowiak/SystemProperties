#import "FlashRuntimeExtensions.h"
#import "UIDevice+MACAddress.h"

#pragma mark - Helper stuff



/**
 * Helper method for putting a string value to a dictionary
 */
void setPropToDic(FREObject *dic,const uint8_t *param,NSString *value)
{
    FREObject valueObj=nil;
    const char *valueCh = (!value)? nil:[value UTF8String];
    if(valueCh)
        FRENewObjectFromUTF8(strlen(valueCh)+1, (const uint8_t*)valueCh, &valueObj);
    else{
        return;
    }
    if(valueObj)
        FRESetObjectProperty(dic, param, valueObj, NULL);
}




#pragma mark - ANE main functions


DEFINE_ANE_FUNCTION(getSystemProperty){
    
    FREObject dic;
    if(FRENewObject((const uint8_t *)"flash.utils.Dictionary",0, NULL, &dic, NULL)!=FRE_OK){
        return nil;
    }
    @try {
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *num = nil;

        if (defaults) {
            num = [defaults stringForKey:@"SBFormattedPhoneNumber"];
        }            
        
        UIDevice * device = [UIDevice currentDevice];
        #if !TARGET_IPHONE_SIMULATOR
            setPropToDic(dic,(const uint8_t*)"UDID"             ,[device uniqueDeviceIdentifier]);
            setPropToDic(dic,(const uint8_t*)"MACAddress"       ,[device macAddress]);
        #endif
        setPropToDic(dic,(const uint8_t*)"phoneNumber"      ,num);
        setPropToDic(dic,(const uint8_t*)"language"         ,[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]);
        setPropToDic(dic,(const uint8_t*)"os"               ,[device systemName]);
        setPropToDic(dic,(const uint8_t*)"version"          ,[device systemVersion]);
        setPropToDic(dic,(const uint8_t*)"name"             ,[device name]);
        
        setPropToDic(dic,(const uint8_t*)"localizedModel"   ,[device localizedModel]);
        setPropToDic(dic,(const uint8_t*)"model"            ,[device model]);
        
        return dic;
        
    }
    @catch (NSException *exception) {
        FREDispatchStatusEventAsync(context, (const uint8_t *)"error", (const uint8_t *)[[exception reason]UTF8String]);
    }
    return nil;
}




DEFINE_ANE_FUNCTION(canOpenUrl){
    FREObject retVal;
    FRENewObjectFromBool(NO, &retVal);
    @try {
        if(argc==0 || !argv[0])
            return retVal;
        
        if (![UIApplication instancesRespondToSelector:@selector(canOpenURL:)]) {
            return retVal;
        }
        
        uint32_t urlLength;
        const uint8_t *url;
        
        if(FREGetObjectAsUTF8(argv[0], &urlLength, &url)!=FRE_OK){
            return retVal;
        }
        
        if(!url)
            return retVal;
        
        NSString* nsStringUrl = [NSString stringWithUTF8String:(char*)url];
        
        if(!nsStringUrl || [nsStringUrl isEqualToString:@""]){
            return retVal;
        }
        
        UIApplication *app = [UIApplication sharedApplication];
        FRENewObjectFromBool([app canOpenURL:[NSURL URLWithString:nsStringUrl]], &retVal);
    }
    @catch (NSException *exception) {
        FREDispatchStatusEventAsync(context, (const uint8_t *)"error", (const uint8_t *)[[exception reason]UTF8String]);
    }
    return retVal;
}



DEFINE_ANE_FUNCTION(setBadge){
    @try{
        if(argc<=0 || !argv[0]){
            return nil;
        }
        int32_t value;
        FREGetObjectAsInt32(argv[0], &value);
        
        NSLog(@"setting badege to %i",value);

        [UIApplication sharedApplication].applicationIconBadgeNumber = value;
        
    }@catch (NSException *exception) {
        FREDispatchStatusEventAsync(context, (const uint8_t *)"error", (const uint8_t *)[[exception reason]UTF8String]);
    }
    return nil;
}


DEFINE_ANE_FUNCTION(getBadge){
    NSInteger ret = [UIApplication sharedApplication].applicationIconBadgeNumber;
    FREObject retObj = nil;
    if(ret && !isnan(ret)){
        FRENewObjectFromUint32(ret, &retObj);
    }else{
        FRENewObjectFromUint32(0, &retObj);
    }
    return retObj;
}



DEFINE_ANE_FUNCTION(console){
    if(argc==0 || !argv[0])
        return nil;
    
    uint32_t messageLength;
    const uint8_t *message;
    
    //Turn our actionscrpt code into native code.
    FREGetObjectAsUTF8(argv[0], &messageLength, &message);
    if(message)
        NSLog(@"%@",[NSString stringWithUTF8String:(char*)message]);
    
    return nil;
}



DEFINE_ANE_FUNCTION(IsSupported)
{

    FREObject fo;

    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        //things are fine
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        //aResult could be FRE_INVALID_ARGUMENT or FRE_WRONG_THREAD, take appropriate action.
        NSLog(@"Result = %d", aResult);
    }
    
    return fo;
}


DEFINE_ANE_FUNCTION(networkIndicator){
    @try {
        UIApplication* app = [UIApplication sharedApplication];
    
        if(argc>0 && argv[0]){
            uint32_t shownetworkActivity;
            if(app && FREGetObjectAsBool(argv[0], &shownetworkActivity)==FRE_OK){
                if(app.networkActivityIndicatorVisible != shownetworkActivity){
                    app.networkActivityIndicatorVisible = shownetworkActivity;
                }
            }
        }
        FREObject retVal;
        if(app && FRENewObjectFromBool(app.networkActivityIndicatorVisible, &retVal) == FRE_OK){
            return retVal;
        }else if(FRENewObjectFromBool(NO, &retVal) == FRE_OK){
            return retVal;
        }else{
            return nil;
        }
    }
    @catch (NSException *exception) {
        FREDispatchStatusEventAsync(context, (const uint8_t *)"error", (const uint8_t *)[[exception reason]UTF8String]);
    }
    return nil;
}

#pragma mark - ANE setup


/* SystemPropertiesExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
 */
void SystemPropertiesExtFinalizer(void* extData) 
{
    return;
}

/* SystemPropertiesContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void SystemPropertiesContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     * As a sample, the function isSupported is being provided.
     */
    *numFunctionsToTest = 7;

    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &IsSupported;

    func[1].name = (const uint8_t*) "canOpenUrl";
    func[1].functionData = NULL;
    func[1].function = &canOpenUrl;
    
    func[2].name = (const uint8_t*) "console";
    func[2].functionData = NULL;
    func[2].function = &console;
    
    func[3].name = (const uint8_t*) "setBadge";
    func[3].functionData = NULL;
    func[3].function = &setBadge;
    
    func[4].name = (const uint8_t*) "getBadge";
    func[4].functionData = NULL;
    func[4].function = &getBadge;
    
    func[5].name = (const uint8_t*) "getSystemProperty";
    func[5].functionData = NULL;
    func[5].function = &getSystemProperty;
    
    func[6].name = (const uint8_t*) "networkIndicator";
    func[6].functionData = NULL;
    func[6].function = &networkIndicator;
    
    *functionsToSet = func;

}

/* SystemPropertiesContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void SystemPropertiesContextFinalizer(FREContext ctx) 
{
    return;
}

/* SystemPropertiesExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml
 */
void SystemPropertiesExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &SystemPropertiesContextInitializer;
    *ctxFinalizerToSet = &SystemPropertiesContextFinalizer;
    
}


