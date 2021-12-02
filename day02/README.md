# Running

With GHC installed, compile with:
```bash
$ mkdir build
$ ghc -odir build/t1 -hidir build/t1 part1.hs -o part1
$ ghc -odir build/t2 -hidir build/t2 part2.hs -o part2
```

Then run with:
```bash
$ ./part1
$ ./part2
```
