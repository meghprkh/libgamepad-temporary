using Libevdev;

public class LibGamepad.Guid : Object {
	public uint16[] guid { get; private set; default = new uint16[8]; }

	public Guid.from_data (uint16[] raw_guid) {
		for (var i = 0; i < 8; i++)
			guid[i] = raw_guid[i];
	}

	/*public Guid.parse (string )*/

	public string to_string () {
		const string k_rgchHexToASCII = "0123456789abcdef";
	    var builder = new StringBuilder ();
	    for (var i = 0; i < 8; i++) {
	        uint8 c = (uint8) guid[i];

	        builder.append_unichar(k_rgchHexToASCII[c >> 4]);
	        builder.append_unichar(k_rgchHexToASCII[c & 0x0F]);

	        c = (uint8) (guid[i] >> 8);
	        builder.append_unichar(k_rgchHexToASCII[c >> 4]);
	        builder.append_unichar(k_rgchHexToASCII[c & 0x0F]);
	    }
		return builder.str;
	}
}
