{ ... }:

{
  # oomd is on by default but monitors no cgroups, so runaway memory
  # pressure livelocks the machine instead of killing the hog.
  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };
}
