public class LibGamepad.GamepadMonitor : Object {
	public static uint ngamepads { get; private set; default = 0; }
	public signal void on_plugin (Guid guid);
	public signal void on_unplug (Guid guid);

	public List<Guid> get_gamepads () {
		return identifier_to_guid.get_values ();
	}

	public GamepadMonitor() {
		init_static_if_not();

		gm = new LinuxRawGamepadMonitor ();
		gm.on_plugin.connect (on_raw_plugin);
		gm.on_unplug.connect (on_raw_unplug);

		Guid guid;
		string identifier;
		gm.foreach_gamepad((identifier, guid) => {
			add_gamepad (identifier, guid);
		});
	}

	public static RawGamepad? get_raw_gamepad (Guid guid) {
		init_static_if_not();

		var identifier = guid_to_identifier.get (guid.to_string ());
		if (identifier == null) return null;
		else {
			var rg = new LinuxRawGamepad (identifier);
			return rg;
		}
	}

	private static HashTable<string, Guid> identifier_to_guid;
	private static HashTable<string, string> guid_to_identifier;
	private RawGamepadMonitor gm;

	private static void init_static_if_not () {
		/*if (ngamepads == null) ngamepads = 0;*/
		if (identifier_to_guid == null)
			identifier_to_guid = new HashTable<string, Guid> (str_hash, str_equal);
		if (guid_to_identifier == null)
			guid_to_identifier = new HashTable<string, string> (str_hash, str_equal);
	}

	private void add_gamepad (string identifier, Guid guid) {
		ngamepads++;
		identifier_to_guid.replace (identifier, guid);
		guid_to_identifier.replace (guid.to_string (), identifier);
	}

	private void on_raw_plugin (string identifier, Guid guid) {
		add_gamepad (identifier, guid);
		on_plugin (guid);
	}

	private void on_raw_unplug (string identifier) {
		var guid = identifier_to_guid.get (identifier);
		if (guid == null) return;
		ngamepads--;
		identifier_to_guid.remove (identifier);
		guid_to_identifier.remove (guid.to_string ());
		on_unplug (guid);
	}
}
