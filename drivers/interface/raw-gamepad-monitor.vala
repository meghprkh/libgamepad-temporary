public interface LibGamepad.RawGamepadMonitor : Object {
	public abstract signal void on_plugin (string identifier, Guid guid);
	public abstract signal void on_unplug (string identifier);

	public delegate void ForeachGamepadCallback(string identifier, Guid guid);
	public abstract void foreach_gamepad (ForeachGamepadCallback cb);
}
