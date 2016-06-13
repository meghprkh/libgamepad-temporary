public enum LibGamepad.InputType {
	AXIS,
	BUTTON;

	public static uint length () {
		return InputType.BUTTON + 1;
	}
}
