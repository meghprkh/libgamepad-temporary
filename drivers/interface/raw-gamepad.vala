using LibGamepad;

public interface LibGamepad.RawGamepad : Object {
	public abstract signal void button_event (int code, bool value);
	public abstract signal void axis_event (int axis, double value);
	public abstract signal void hat_event (int hat, int axis, int value);
	public abstract signal void unplug ();

	public abstract string name { get; protected set; }
	public abstract Guid guid { get; protected set; }

	public abstract uint8 naxes { get; protected set; default = 0; }
	public abstract uint8 nbuttons { get; protected set; default = 0; }
	public abstract uint8 nhats { get; protected set; default = 0; }
}
