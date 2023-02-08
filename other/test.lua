
require(".packages.spacker.SPAC_LIB")

fs.delete("Test/spacker")
sleep(0.5)
SPAC.packFiles("./packages/spacker")
SPAC.unpackFiles("./packages/spacker.spac", "Test/")