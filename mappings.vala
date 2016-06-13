/**
 * This class gives methods to set/update the mappings
 *
 * The client interfaces with this class primarily
 */
public class LibGamepad.Mappings {
	private static HashTable<string, string> names;
	private static HashTable<string, string> mappings;

	/**
	 * Adds mappings from a file
	 * @param file_name
	 */
	public static void add_from_file (string file_name) throws IOError {
		var f = File.new_for_path(file_name);
		var ds = new DataInputStream (f.read());
		var str = ds.read_line();
		while (str != null) {
			add_mapping(str);
			str = ds.read_line ();
		}
	}

	/**
	 * Adds a mapping from a string (only one gamepad)
	 */
	public static void add_mapping (string str) {
		if (names == null) names = new HashTable<string, string> (str_hash, str_equal);
		if (mappings == null) mappings = new HashTable<string, string> (str_hash, str_equal);

		if (str == "" || str[0] == '#') return;

		if (str.index_of ("platform") == -1 || str.index_of ("platform:Linux") != -1) {
			var split = str.split(",", 3);
			names.insert(split[0], split[1]);
			mappings.insert(split[0], split[2]);
		}
	}

	/**
	 * Gets the name of a gamepad from the database
	 * @param  guid          The guid of the wanted gamepad
	 * @return The name if present in the database
	 */
	public static string get_name (string guid) {
		return names.get(guid);
	}

	/**
	 * Gets the current mapping from the databse
	 * @param  guid          The guid of the wanted gamepad
	 * @return The mapping if present in the database
	 */
	public static string get_mapping (string guid) {
		return mappings.get(guid);
	}
}
