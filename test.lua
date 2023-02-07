require(".packages.libraries.INSTALLER")

INSTALLER.install("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/packages/packages.inst", "testinstall")

require(".testinstall.packages.drones.DRONE_LIB")

DRONE.Initialize();