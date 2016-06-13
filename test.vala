using LibGamepad;

int main () {
	Mappings.add_from_file("./gamecontrollerdb.txt");
	var gm = new GamepadMonitor();
	var g = new Gamepad();
	gm.on_plugin.connect((guid, name) => {
		print(@"GM Plugged in $(guid.to_string()) - $name\n");
		g.open(guid);
	});

	gm.on_unplug.connect((guid, name) => print (@"GM Unplugged $(guid.to_string()) - $name\n"));

	List<Guid> gp_list = gm.get_gamepads ();
	Guid gp_guid = gp_list.nth_data(0);
	if (gp_guid != null) {
		print(@"Initial open $(gp_guid.to_string ())\n");
		g.open(gp_guid);
	}

	g.button_event.connect((button, value) => print(@"$(button.to_string()) - $value\n"));
	g.axis_event.connect((axis, value) => print(@"$(axis.to_string()) - $value\n"));
	g.unplug.connect(() => print("G Unplugged\n"));

	new MainLoop().run();
	return 0;
}
