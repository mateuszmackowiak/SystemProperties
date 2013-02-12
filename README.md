# SystemProperties #
================

Adobe Air Native Extension System Properties  (Android / IOS)

***
If You like what I make pleas donate:
[![Foo](https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CMYHNG32SVXZ4)
***

SystemProperties class can provide some of the missing properties that You can’t get in adobe air.
Also enables to check on IOS can a url be opened with other programs.


*Usage (badge):*

    if(SystemProperties.isBadgeSupported())
      SystemProperties.getInstance().badge = 4;
		
		
Available parameters: 

(IOS/Android)
* version - The current version of the operating system.
* os - The name of the operating system running on the device.
* language - the set language in the system
* UID - created a unique ID for the device based on some of the device properties
* name - the name of the device
* MACAddress - MAC Address
* model

(Android)
* serial - serial number of Android system 
* arch - architecture of the cpu
* packageName - package name
* sourceDir - source directory
* AppUid -always when a application is installed on device the system creates a unique id for setting up the space for it
* phoneNumber
* IMSI
* IMEI

(IOS)
* localizedModel 


**requires **

	<uses-permission android:name="android.permission.READ_PHONE_STATE" />
*Usage:*

		
		public function listAllPropertiesFromSystemProperties():void
  		{
				if(SystemProperties.isSupported){
					var dictionary:Dictionary = SystemProperties.getInstance().getSystemProperites();
					if(!dictionary){
						mess("return null dictionary");
						return;
					}
					
					mess("--------------------");
					for (var key:String in dictionary) 
					{ 
						var readingType:String = key; 
						var readingValue:String = dictionary[key]; 
						mess(readingType + "=" + readingValue); 
					} 
					mess("--------------------");
					dictionary = null;
				}else{
					mess("SystemProperties is NOT supported on this platform!!");
				}
			}
		
		
		if(SystemPropertie.isIOS()){
			trace(SystemProperties.getInstance().canOpenUrl("http://maps.google.com/maps?ll=-37.812022,144.969277"));
		}
		
		
		SystemProperties.getInstance().console("some text to console");
	
