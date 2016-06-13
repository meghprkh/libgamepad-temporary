[CCode (cheader_filename = "libevdev/libevdev.h")]
namespace Libevdev {

	[CCode (cname = "libevdev_read_flag", cprefix = "LIBEVDEV_READ_FLAG_", has_type_id = false)]
	[Flags]
	public enum ReadFlag {
		SYNC,
		NORMAL,
		FORCE_SYNC,
		BLOCKING
	}

	[CCode (cname = "struct libevdev", cprefix = "libevdev_", free_function = "libevdev_free")]
	[Compact]
	public class Evdev {
		[CCode (cname = "libevdev_new")]
		public Evdev ();

		public int get_fd ();
		public int set_fd (int fd);

		public string name { get; set; }

		public int16 id_bustype { get; set; }
		public int16 id_vendor { get; set; }
		public int16 id_product { get; set; }
		public int16 id_version { get; set; }

		public unowned Linux.Input.AbsInfo? get_abs_info (uint code);
		public bool has_event_code (uint type, uint code);
		public int has_event_pending ();
		public int next_event (uint flags, out Linux.Input.Event ev);

		public static unowned string event_code_get_name(uint type, uint code);
	}

}
