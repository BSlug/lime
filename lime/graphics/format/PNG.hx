package lime.graphics.format;


import lime.graphics.Image;
import lime.system.System;
import lime.utils.ByteArray;


class PNG {
	
	
	public static function encode (image:Image):ByteArray {
		
		#if java
		
		#elseif (sys && (!disable_cffi || !format))
			
			return lime_image_encode (image.buffer, 0, 0);
			
		#elseif !js
			
			try {
				
				var bytes = Bytes.alloc (image.width * image.height * 4 + image.height);
				var sourceBytes = image.buffer.data.getByteBuffer ();
				var sourceIndex:Int, index:Int;
				
				for (y in 0...image.height) {
					
					sourceIndex = y * image.width * 4;
					index = y * image.width * 4 + y;
					
					bytes.set (index, 0);
					bytes.blit (index + 1, sourceBytes, sourceIndex, image.width * 4);
					
				}
				
				var data = new List ();
				data.add (CHeader ({ width: image.width, height: image.height, colbits: 8, color: ColTrue (true), interlaced: false }));
				data.add (CData (Deflate.run (bytes)));
				data.add (CEnd);
				
				var output = new BytesOutput ();
				var png = new Writer (output);
				png.write (data);
				
				return ByteArray.fromBytes (output.getBytes ());
				
			} catch (e:Dynamic) {}
			
		#end
		
		return null;
		
	}
	
	
	
	
	// Native Methods
	
	
	
	
	#if (cpp || neko || nodejs)
	private static var lime_image_encode:ImageBuffer -> Int -> Int -> ByteArray = System.load ("lime", "lime_image_encode", 3);
	#end
	
	
}