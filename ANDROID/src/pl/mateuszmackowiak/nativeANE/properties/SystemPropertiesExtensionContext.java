package pl.mateuszmackowiak.nativeANE.properties;

import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.ViewConfiguration;


import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;


public class SystemPropertiesExtensionContext extends FREContext 
{
	public static final String ERROR_EVENT = "error";
	private static String TAG = "[SystemProperties]";
	
	public SystemPropertiesExtensionContext()
	{
		Log.d(TAG, "Creating Extension Context");
	}
	
	@Override
	public void dispose() 
	{
		Log.d(TAG, "Disposing Extension Context");
		SystemPropertiesExtension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() 
	{
		Log.d(TAG, "Registering Extension Functions");
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put(getSystemProperty.KEY, new getSystemProperty());
		functionMap.put(consoleLog.KEY, new consoleLog());
		return functionMap;	
	}
	
	
	/**
	 * gets the messages while flash gets a Recive event
	 */
	public class consoleLog implements FREFunction{
		public static final String KEY = "console";

		@Override
		public FREObject call(FREContext context, FREObject[] args) {
			try{
				String text = args[0].getAsString();
				Log.i(TAG, text);				
			}catch(Exception e){
				context.dispatchStatusEventAsync(ERROR_EVENT,TAG+"   "+e.toString());
			}
			return null;
		}
	}
	
	
    protected static String getImei(Context context) {
        TelephonyManager m = (TelephonyManager) context
                .getSystemService(Context.TELEPHONY_SERVICE);
        String imei = m != null ? m.getDeviceId() : null;
        return imei;
    }
    
    /*protected static String getDeviceId(Context context) throws Exception {
        String imei = getImei(context);
        if (imei != null) return imei;
        String tid = getWifiMacAddress(context);
        return tid;
    }*/
    
    protected static String md5(String s) throws Exception {
        MessageDigest md = MessageDigest.getInstance("MD5");

        md.update(s.getBytes());

        byte digest[] = md.digest();
        StringBuffer result = new StringBuffer();

        for (int i = 0; i < digest.length; i++) {
            result.append(Integer.toHexString(0xFF & digest[i]));
        }
        return (result.toString());
    }
    
    
    protected static String getWifiMacAddress(Context context) throws Exception {
        WifiManager manager = (WifiManager) context
                .getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = manager.getConnectionInfo();
        if (wifiInfo == null || wifiInfo.getMacAddress() == null)
            return md5(UUID.randomUUID().toString());
        else return wifiInfo.getMacAddress().replace(":", "").replace(".", "");
    }
    
    
	public static Boolean hasHardwareMenuButton(Activity activity)
    {
    	if(android.os.Build.VERSION.SDK_INT>11){
    		if(android.os.Build.VERSION.SDK_INT>14)
    			return ViewConfiguration.get(activity.getBaseContext()).hasPermanentMenuKey();
    		return false;
    	}
    	return true;
    }
    
	
	public static String getMyPhoneNumber(Activity activity){
	    TelephonyManager mTelephonyMgr;
	    mTelephonyMgr = (TelephonyManager)activity.getSystemService(Context.TELEPHONY_SERVICE);
	    if(mTelephonyMgr!=null)
	    	return mTelephonyMgr.getLine1Number();
	    else
	    	return null;
	}
    
	
	
    private class getSystemProperty implements FREFunction
    {
        
        public static final String KEY = "getSystemProperty";

        @Override
        public FREObject call(FREContext context, FREObject[] args) 
        {
        	
        	
        	
            FREObject dictionary = null;
            try
            {
            	dictionary = FREObject.newObject("flash.utils.Dictionary",null);
            	//dictionary.setProperty("java",FREObject.newObject(System.getProperty("java.specification.version")));
            	dictionary.setProperty("os",FREObject.newObject(System.getProperty("os.name")) );
            	dictionary.setProperty("language",FREObject.newObject(System.getProperty("user.language") ));
            	dictionary.setProperty("arch",FREObject.newObject(System.getProperty("os.arch")) );
            	dictionary.setProperty("version",FREObject.newObject(System.getProperty("os.version") ));
            	
            	dictionary.setProperty("model",FREObject.newObject(android.os.Build.MODEL));

            	if(android.os.Build.VERSION.SDK_INT>9)
            		dictionary.setProperty("serial",FREObject.newObject(android.os.Build.SERIAL));
            	
            	dictionary.setProperty("name",FREObject.newObject(android.os.Build.DEVICE));

            	final Activity activity = context.getActivity();

            	try{
		        	PackageInfo pInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0);
		        	dictionary.setProperty("packageName",FREObject.newObject(pInfo.packageName));
		        	dictionary.setProperty("sourceDir",FREObject.newObject(pInfo.applicationInfo.sourceDir));
		        	dictionary.setProperty("AppUid",FREObject.newObject(String.valueOf(pInfo.applicationInfo.uid)));
		        	
		        	
            	}catch(Exception e){
            		context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}	
		        try{
		        	dictionary.setProperty("phoneNumber", FREObject.newObject(getMyPhoneNumber(activity)));
		        }catch(Exception e){
		        	context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}	
		        try{
		        	dictionary.setProperty("hasHardwareMenuButton", FREObject.newObject(hasHardwareMenuButton(activity)));
		        }catch(Exception e){
		        	context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}	
		        try{
		        	final TelephonyManager tm = (TelephonyManager) activity.getBaseContext().getSystemService(Context.TELEPHONY_SERVICE);
		
		        	String imsi = tm.getSubscriberId();
		        	dictionary.setProperty("IMSI",FREObject.newObject(imsi));
		        	 
		        	 
		    	    final String tmDevice, tmSerial, androidId;
		    	    tmDevice = "" + tm.getDeviceId();
		    	    tmSerial = "" + tm.getSimSerialNumber();
		    	    androidId = "" + android.provider.Settings.Secure.getString(activity.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
		
		    	    UUID deviceUuid = new UUID(androidId.hashCode(), ((long)tmDevice.hashCode() << 32) | tmSerial.hashCode());
		    
		    	    dictionary.setProperty("UID",FREObject.newObject(deviceUuid.toString()));

		        }catch(Exception e){
		        	context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}	
		        /*try{
		        	dictionary.setProperty("UID2",FREObject.newObject(getDeviceId(activity.getBaseContext()).toString()));
		        }catch(Exception e){
            		dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}*/	
		        try{
		        	String MACAdress = getWifiMacAddress(activity.getBaseContext()).toString();
		        	dictionary.setProperty("MACAddress",FREObject.newObject(MACAdress));
		        }catch(Exception e){
		        	context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}	
		        try{
		        	String IMEI = getImei(activity.getBaseContext()).toString();
		        	dictionary.setProperty("IMEI",FREObject.newObject(IMEI));
            	}catch(Exception e){
            		
            		context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
            		//dictionary.setProperty("error",FREObject.newObject(e.toString()));
            	}
            }catch (Exception e){
            	context.dispatchStatusEventAsync(ERROR_EVENT,e.toString());
                e.printStackTrace();
            }
            return dictionary;
    	}
    }
}
