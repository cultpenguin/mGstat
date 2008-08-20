% mgstat_dir : return the install directory for mGstat
function mgstat_install_dir=mgstat_dir;
[mgstat_install_dir]=fileparts(which('gstat.m'));