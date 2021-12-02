# Running

With GHC installed, compile with:
```bash
$ ghc -odir build -hidir build -o build/part1 part1.hs
$ ghc -odir build -hidir build -o build/part1 part2.hs
```
Alternatively, the `build.sh` script can be used

Then run with:
```bash
$ ./build/part1
$ ./build/part2
```
