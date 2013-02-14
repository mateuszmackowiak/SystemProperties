package pl.mateuszmackowiak.nativeANE.properties
{
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	/**
	 * System Properties class can provide some of the missing properties that You can’t get in adobe air
	 * @author Mateusz Maćkowiak
	 * @see http://mateuszmackowiak.wordpress.com/
	 * @since 2011
	 */
	public class SystemProperties extends EventDispatcher
	{
		
		
		/**
		 * The current version of the operating system.
		 * <br><b>Supported on IOS and Android</b>
		 */
		public static const VERSION:String = 'version';
		/**
		 * The name of the operating system running on the device.
		 * <br><b>Supported on IOS and Android</b>
		 */
		public static const OS:String = 'os';
		/**
		 * <br><b>Supported on IOS and Android</b>
		 */
		public static const UID:String = isIOS()?'UDID':'UID';
		/**
		 * The name identifying the device.
		 * <br><b>Supported on IOS and Android</b>
		 */
		public static const NAME:String = 'name';
		/**
		 * <br><b>Supported on IOS and Android</b>
		 */
		public static const MAC_ADDRESS:String = 'MACAddress';
		/**
		 * The model of the device.
		 * <br><b>Supported only on IOS and Android</b>
		 */
		public static const MODEL:String = 'model';
		/**
		 * <br><b>Supported only on IOS and Android</b>
		 */
		public static const LANGUAGE:String = 'language';
		
		
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const SERIAL:String = 'serial';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const PHONE_NUMBER:String = 'phoneNumber';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const IMSI:String = 'IMSI';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const IMEI:String = 'IMEI';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const ARCHITECTURE:String = 'arch';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const PACKAGE_NAME:String = 'packageName';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const PACKAGE_DIRECTORY:String = 'sourceDir';
		/**
		 * <br><b>Supported only on Android</b>
		 */
		public static const APP_UID:String = 'AppUid';
		
		
		
		/**
		 * The model of the device as a localized string.
		 * <br><b>Supported only on IOS</b>
		 */
		public static const LOCALIZED_MODEL:String = 'localizedModel';
		
		
		
		/**
		 * @private
		 */
		private static var _allowInstantiation:Boolean;
		/**
		 * @private
		 */
		private var _context:ExtensionContext = null;
		/**
		 * @private
		 */
		private static var _instance:SystemProperties;
		
		
		
		/**
		 * System Properties class can provide some of the missing properties that You can’t get in adobe air
		 * @author Mateusz Maćkowiak
		 * @see http://mateuszmackowiak.wordpress.com/
		 * @since 2011
		 */
		public function SystemProperties():void
		{
			if (!_allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SystemProperties.getInstance() instead of new.");
			}
		}
		/**
		 * @private
		 */
		private function init():void
		{
			try{
				_context = ExtensionContext.createExtensionContext("pl.mateuszmackowiak.nativeANE.properties.SystemProperties", 'SystemProperites');
				_context.addEventListener(StatusEvent.STATUS, onStatus);
			}catch(e:Error){
				throw new Error("SystemProperties initialization error : "+e.message,e.errorID);
			}
		}
		
		/**
		 * Gets the single instance of the SystemProperties class.
		 * <br>This object manages systemProperties.
		 */
		public static function getInstance():SystemProperties
		{
			if (!_instance) {
				_allowInstantiation = true;
				_instance = new SystemProperties();
				_allowInstantiation = false;
				
				_instance.init();
			}
			return _instance;
		}
		
		/**
		 * Returns Dictionary object with additional system properties that are missing in Adobe AIR
		 */
		public function getSystemProperites():Dictionary
		{
			try{
				return  _context.call('getSystemProperty') as Dictionary;
			}catch(error:Error){
				handleError(error.message);
			}
			return null;
		}
		
		/**
		 * Returns whether an application can open a given URL resource.
		 * <br><b>Supported only on IOS</b>
		 */
		public function canOpenUrl(url:String):Boolean
		{
			if(isIOS()){
				try{
					return _context.call('canOpenUrl',url) as Boolean;
				}catch(error:Error){
					handleError(error.message);
					return false;
				}
			}else{
				trace("canOpenUrl is not supported on this platform");
			}
			
			return false;
		}
		/**
		 * Writes messages to system console
		 */
		public function console(message:String):void
		{
			if(message){
				_context.call("console",message);
			}
		}
		
		
		
		/**
		 * Whether the badge is available on the device (true);<br>otherwise false
		 * @see pl.mateuszmackowiak.nativeANE.properties.SystemProperties.badge
		 */
		public static function isBadgeSupported():Boolean
		{
			return isIOS();
		}
		/**
		 * Whether the canOpenUrl function is available on the device (true);<br>otherwise false
		 * @see pl.mateuszmackowiak.nativeANE.properties.SystemProperties.canOpenUrl
		 */
		public static function isCanOpenUrlSupported():Boolean
		{
			return isIOS();
		}
		
		/**
		 * The number currently set as the badge of the application icon in Springboard
		 * <br>Set to 0 (zero) to hide the badge number. The default is 0.
		 * @see pl.mateuszmackowiak.nativeANE.properties.SystemProperties.isBadgeSupported
		 */
		public function set badge(value:uint):void
		{
			if(isNaN(value))
				return;
			try{
				_context.call("setBadge",value);
			}catch(e:Error){
				handleError(e.message,e.errorID);
			}
		}
		/**
		 * @privates
		 */
		public function get badge():uint
		{
			try{
				return _context.call("getBadge") as uint;
			}catch(e:Error){
				handleError(e.message,e.errorID);
			}
			return NaN;
		}
		
		
		
		public static function isIOS():Boolean
		{
			return Capabilities.os.toLowerCase().indexOf("ip")>-1;
		}
		public static function isAndroid():Boolean
		{
			return Capabilities.os.toLowerCase().indexOf("linux")>-1;
		}
		
		/**
		 * If the extension is available on the device (true);<br>otherwise false
		 */
		public static function get isSupported():Boolean{
			if(isAndroid() || isIOS())
				return true;
			else
				return false;
		}
		
		/**
		 * Is showing network spinning gear in status bar supported.
		 * <b>ONLY IOS</b>
		 */
		public static function get isNetworkActivitySupported():Boolean
		{
			if(isIOS()){
				return true;
			}else{
				return false;
			}
		}
		/**
		 * Showing network spinning gear in status bar.
		 * @default false
		 */
		public function setNetworkActivityIndicatorVisibility(visbile:Boolean):Boolean
		{
			if(isIOS()){
				try{
					const answer:Object = _context.call("networkIndicator",visbile);
					if(answer is Boolean)
						var ret:Boolean = answer as Boolean;
					else trace(answer);
					return ret;
				}catch(e:Error){
					trace("Error calling setNetworkActivityIndicatorVisibility method "+e.message,e.errorID);
				}
			}else{
				trace("Network Activity Indicator is not supported on this platform");
			}
			return false;
		}
		
		/**
		 * @copy flash.external.ExtensionContext#dispose()
		 */
		public function dispose():void{
			if(_context){
				_context.removeEventListener(StatusEvent.STATUS, onStatus);
				_context.dispose();
				_instance = null;
			}
			
		}
		/**
		 * @private
		 */
		private function onStatus(event:StatusEvent):void
		{
			switch(event.code)
			{
				case "error":
				{
					handleError(event.level);
					break;
				}
				default:
				{
					trace("Unknown SystemProperties event "+event.code +"  "+event.level);
					break;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handleError(text:String,id:int=0):void
		{
			if(hasEventListener(ErrorEvent.ERROR))
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,text,id));
			else
				trace(text);
		}
	}
}


