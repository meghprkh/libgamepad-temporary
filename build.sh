valac -g \
  -X -lm \
  --vapidir drivers/linux/vapi/ \
  --pkg libevdev --pkg posix --pkg linux --pkg gio-2.0 --pkg gudev-1.0 \
  -o test \
      drivers/interface/raw-gamepad-monitor.vala \
      drivers/interface/raw-gamepad.vala \
      drivers/linux/raw-gamepad-monitor.vala \
      drivers/linux/guid-helpers.vala \
      drivers/linux/raw-gamepad.vala \
  gamepad-monitor.vala \
  gamepad.vala \
  guid.vala \
  input-type.vala \
  mapping-helpers.vala \
  mappings.vala \
  standard-gamepad-axis.vala \
  standard-gamepad-button.vala \
  test.vala \
