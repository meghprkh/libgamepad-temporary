using LibGamepad;

private class LibGamepad.Hat : Object {
	public InputType types[4];
	public int values[4];
	public int axisval[2];
}

public class LibGamepad.Gamepad : Object {
	public signal void button_event (StandardGamepadButton button, bool value);
	public signal void axis_event (StandardGamepadAxis axxis, double value);
	public signal void unplug ();

	public string? raw_name { get; private set; }
	public Guid? guid { get; private set; }
	public string? name { get; private set; }

	private RawGamepad rg;
	private InputType[] buttons;
	private int[] buttons_value;
	private InputType[] axes;
	private int[] axes_value;
	private Hat[] hats;

	public Gamepad (Guid? guid = null) throws FileError {
		open(guid);
	}

	public void open (Guid? guid = null) throws FileError {
		if (guid == null) return;
		rg = GamepadMonitor.get_raw_gamepad (guid);
		if (rg == null) return;

		raw_name = rg.name;
		this.guid = rg.guid;
		buttons.resize (rg.nbuttons);
		buttons_value.resize (rg.nbuttons);
		axes.resize (rg.naxes);
		axes_value.resize (rg.naxes);
		hats.resize (rg.nhats);
		for (var i = 0; i < rg.nhats; i++) {
			hats[i] = new Hat();
			hats[i].axisval[0] = hats[i].axisval[1] = 0;
		}
		add_mapping (Mappings.get_mapping(guid.to_string ()));
		rg.button_event.connect (on_raw_button_event);
		rg.axis_event.connect (on_raw_axis_event);
		rg.hat_event.connect (on_raw_hat_event);
		rg.unplug.connect (() => unplug ());
	}

	private void on_raw_button_event (int button, bool value) {
		switch(buttons[button]) {
			case InputType.AXIS:
				axis_event((StandardGamepadAxis) buttons_value[button], (double) value);
				break;
			case InputType.BUTTON:
				button_event((StandardGamepadButton) buttons_value[button], value);
				break;
		}
	}

	private void on_raw_axis_event (int axis, double value) {
		switch(axes[axis]) {
			case InputType.AXIS:
				axis_event((StandardGamepadAxis) axes_value[axis], value);
				break;
			case InputType.BUTTON:
				button_event((StandardGamepadButton) axes_value[axis], (bool) value);
				break;
		}
	}

	private void on_raw_hat_event (int hati, int axis, int value) {
		int hatp;
		var hat = hats[hati];
		if (value == 0) hatp = (hat.axisval[axis] + axis + 4) % 4;
		else hatp = (value + axis + 4) % 4;
		hat.axisval[axis] = value;
		value = value.abs();
		switch(hat.types[hatp]) {
			case InputType.AXIS:
				axis_event((StandardGamepadAxis) hat.values[hatp], value);
				break;
			case InputType.BUTTON:
				button_event((StandardGamepadButton) hat.values[hatp], (bool) value);
				break;
		}
	}

	private void add_mapping (string mappingstring) {
		var mappings = mappingstring.split(",");
		foreach (var mapping in mappings) {
			if (mapping.split(":").length == 2) {
				var str = mapping.split(":")[0];
				var real = mapping.split(":")[1];
				var type = MappingHelpers.map_type(str);
				var value = MappingHelpers.map_value(str);
				switch (real[0]) {
				case 'h':
					var hatarr = real[1:real.length].split(".");
					var hati = int.parse(hatarr[0]);
					var hatp = int.parse(hatarr[1]);
					hatp = (int) Math.log2(hatp);
					hats[hati].types[hatp] = type;
					hats[hati].values[hatp] = value;
					break;
				case 'b':
					int button = int.parse(real[1:real.length]);
					buttons[button] = type;
					buttons_value[button] = value;
					break;
				case 'a':
					int axis = int.parse(real[1:real.length]);
					axes[axis] = type;
					axes_value[axis] = value;
					break;
				}
			}
		}
	}
}
