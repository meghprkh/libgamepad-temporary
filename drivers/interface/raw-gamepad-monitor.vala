/**
 * This is one of the interfaces that needs to be implemented by the driver.
 *
 * This interface deals with handling events related to plugging and unplugging
 * of gamepads and also provides a method to iterate through all the plugged in
 * gamepads. An identifier is a string that is easily understood by the driver
 * and may depend on other factors, i.e. it may not be unique for the gamepad.
 */
public interface LibGamepad.RawGamepadMonitor : Object {
	/**
	 * This signal should be emmited when a gamepad is plugged in.
	 * @param  {string}  identifier    The identifier of the plugged in gamepad
	 * @param  {Guid}    guid          The GUID of the plugged in gamepad
	 * @param  {string}  raw_name      The raw name of the gamepad as reported by the OS
	 * @return {void}
	 */
	public abstract signal void on_plugin (string identifier, Guid guid, string? raw_name = null);
	/**
	 * This signal should be emitted when a gamepad is unplugged
	 *
	 * If an identifier which is not passed with on_plugin even once is passed,
	 * then it is ignored. Drivers may use this to their benefit
	 *
	 * @param  {string}  identifier    The identifier of the unplugged gamepad
	 * @return {void}
	 */
	public abstract signal void on_unplug (string identifier);

	public delegate void ForeachGamepadCallback(string identifier, Guid guid, string? raw_name = null);
	/**
	 * This function allows to iterate over all gamepads
	 * @param  {ForeachGamepadCallback}   cb
	 * @return {void}
	 */
	public abstract void foreach_gamepad (ForeachGamepadCallback cb);
}
