using Libevdev;
using Linux.Input;
using LibGamepad;

public class LibGamepad.LinuxRawGamepad : Object, RawGamepad {
	public string name { get; protected set; }
	public Guid guid { get; protected set; }

	public uint8 naxes { get; protected set; default = 0; }
	public uint8 nbuttons { get; protected set; default = 0; }
	public uint8 nhats { get; protected set; default = 0; }

	private int fd;
	private FileMonitor monitor;
	private uint? event_source_id;
	private Evdev dev;

	private uint8 key_map[KEY_MAX];
	private uint8 abs_map[ABS_MAX];
	private AbsInfo abs_info[ABS_MAX];

	public LinuxRawGamepad (string file_name) throws FileError {
		fd = Posix.open (file_name, Posix.O_RDONLY | Posix.O_NONBLOCK);

		if (fd < 0)
			throw new FileError.FAILED (@"Unable to open file $file_name: $(Posix.strerror(Posix.errno))");

		dev = new Evdev();
		if (dev.set_fd(fd) < 0)
			throw new FileError.FAILED ("Locha ho gaya o bhaiya locha ho gaya");

		// Monitor the file for deletion
		monitor = File.new_for_path (file_name).monitor_file (FileMonitorFlags.NONE);
		monitor.changed.connect ((f1, f2, e) => {
			if (e == FileMonitorEvent.DELETED) {
				remove_event_source ();
				unplug ();
			}
		});

		name = dev.name;
		guid = LinuxGuidHelpers.from_dev(dev);

		// Poll the events in the default main loop
		var channel = new IOChannel.unix_new (fd);
		event_source_id = channel.add_watch (IOCondition.IN, () => { return poll_events (); });

		// Initialize hats, buttons and axes
		uint i;
		for (i = BTN_JOYSTICK; i < KEY_MAX; ++i) {
			if (dev.has_event_code(EV_KEY, i)) {
				key_map[i - BTN_MISC] = nbuttons;
				++nbuttons;
			}
		}
		for (i = BTN_MISC; i < BTN_JOYSTICK; ++i) {
			if (dev.has_event_code(EV_KEY, i)) {
				key_map[i - BTN_MISC] = nbuttons;
				++nbuttons;
			}
		}


		// Get info about axes
	    for (i = 0; i < ABS_MAX; ++i) {
	        /* Skip hats */
	        if (i == ABS_HAT0X) {
	            i = ABS_HAT3Y;
	            continue;
	        }
	        if (dev.has_event_code(EV_ABS, i)) {
				AbsInfo? absinfo = dev.get_abs_info(i);
	            abs_map[i] = naxes;
				abs_info[naxes] = absinfo;
	            ++naxes;
	        }
	    }

		// Get info about hats
		for (i = ABS_HAT0X; i <= ABS_HAT3Y; i += 2) {
			if (dev.has_event_code(EV_ABS, i) || dev.has_event_code(EV_ABS, i+1)) {
				AbsInfo? absinfo = dev.get_abs_info(i);
				if (absinfo == null) continue;

				++nhats;
			}
		}
	}

	private bool poll_events () {
		while (dev.has_event_pending() > 0) on_event();

		return true;
	}

	private void on_event () {
		int rc;
		Linux.Input.Event ev;
		rc = dev.next_event(ReadFlag.NORMAL, out ev);
		if (rc == 0) {
			int code = ev.code;
            switch (ev.type) {
            case EV_KEY:
                if (code >= BTN_MISC) {
					button_event (key_map[code - BTN_MISC], (bool) ev.value);
                }
                break;
            case EV_ABS:
                switch (code) {
                case ABS_HAT0X:
                case ABS_HAT0Y:
                case ABS_HAT1X:
                case ABS_HAT1Y:
                case ABS_HAT2X:
                case ABS_HAT2Y:
                case ABS_HAT3X:
                case ABS_HAT3Y:
                    code -= ABS_HAT0X;
					hat_event (code / 2, code % 2, ev.value);
                    break;
                default:
					int axis = abs_map[code];
					axis_event (axis, (double) ev.value / abs_info[axis].maximum);
                    break;
                }
                break;
            case EV_REL:
                switch (code) {
                case REL_X:
                case REL_Y:
                    code -= REL_X;
					// TODO : ball events
                    print("Ball %d Axis %d Value %d\n", code / 2, code % 2, ev.value);
                    break;
                default:
                    break;
                }
                break;
            }
		}
	}

	~LinuxRawGamepad () {
		Posix.close (fd);
		remove_event_source ();
	}

	private void remove_event_source () {
		if (event_source_id == null)
			return;

		Source.remove (event_source_id);
		event_source_id = null;
	}
}
