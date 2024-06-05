
# Timing information

Run a test with `prove6 --timer` on the old and new modules. The older tests take much more time than the newer modules, but it does many more tests than in the newer modules. It will take time to have the new tests with about the same number of tests. Anyways, a comparison of apples with pears for the moment.

Important note is that the number of tests are only the top level tests, not including those within subtests. This means that in the api 1 version there are many more tests within the subtests than in the api 2 version. So this is also an unfair comparison until the tests are also in place on the api 2 version.

## Api 1 tests
|cc| Date       | Dist      |#c| Files | Tests | secs |
|--|------------|-----------|--|-------|-------|------|
| a| 2023 12 28 | Gtk3      | *|   144 |   367 |  510 |
| b| 2023 12 28 |           |  |   144 |   367 |  145 |
|  | 2023 12 30 | Gdk3      | *|    11 |    20 |   64 |
|  | 2023 12 30 |           |  |    11 |    20 |    6 |
|  | 2023 12 30 | Glib      | *|    10 |    21 |   24 |
|  | 2023 12 30 |           |  |    10 |    21 |    6 |
|  | 2023 12 30 | Gio       | *|    24 |    43 |   69 |
|  | 2023 12 30 |           |  |    24 |    43 |   12 |


## Api 2 tests

Legend for test tables

* **cc**; compare code for next table
* **#c**; rough number of files to be compiled. **.** ⅓ of total, **-** half, **+** ⅔, **\*** all files
* **Tests** number of top level tests done. Tests in `subtest ( )` are not counted by `prove6`
* **secs**; Number of seconds to run. Some tests needed a `sleep()` which is not working time really.

Legend for compare tables

* **cc**; compares entries from above tables
* **Comp**; The number of seconds the new version should have when compared to the older version. The calculation is `(nbr tests in new version) * (nbr seconds of old version) / (nbr tests in old version)`
* **secs**; number of seconds of testing new version.
* **Diff**; difference in seconds compared to real value of new version tests


### Tests for the `Gnome::Gtk4:api<2>` distro

|cc| Date       |#c| Files | Tests | secs | Note
|--|------------|--|-------|-------|------|------
| 1| 2023 12 28 |  |    97 |   249 |   78 |
|  | 2023 12 28 | -|    97 |   249 |  171 |
| 2| 2023 12 30 |  |   128 |   318 |  106 |
| 3| 2024 01 07 | *|   139 |   350 |  261 |
| 4| 2024 01 07 | *|   139 |   350 |  111 |
| 5| 2024 01 08 |  |   154 |   393 |  124 |
|  | 2024 01 12 |  |   172 |   443 |  149 |
|  | 2024 01 16 |  |   188 |   485 |  336 |
|  | 2024 05 05 |  |   220 |   574 |  267 |
|  | 2024 06 05 | *|   238 |   624 |  420 | A change in Gnome::N
|  | 2024 06 05 |  |   238 |   624 |  179 |

#### Compare with `Gnome::Gtk3:api<1>`
The calculation is to show how much time it would take when the newer version would do the same number of equal tests.

| o vs n |  Comp | secs | Diff | Speedup % |
|--------|-------|------|------|-----------|
| 1 vs b |    98 |   78 |   20 |       126 |
| 2 vs b |   125 |  106 |   19 |       118 |
| 3 vs a |   486 |  261 |  225 |       186 |
| 4 vs b |   138 |  111 |   27 |       124 |
| 5 vs b |   155 |  124 |   31 |       125 |

### Tests for the `Gnome::Gdk4` distro

|cc| Date       |#c| Files | Tests | secs |
|--|------------|--|-------|-------|------|
|  | 2023 12 30 |  |     3 |    15 |    2 |
|  | 2024 01 02 |  |     7 |    22 |    5 |

### Tests for the `Gnome::Glib` distro

|cc| Date       |#c| Files | Tests | secs |
|--|------------|--|-------|-------|------|
|  | 2023 12 30 |  |    16 |    38 |   10 |


### Tests for the `Gnome::Gio` distro

|cc| Date       |#c| Files | Tests | secs |
|--|------------|--|-------|-------|------|
|  | 2023 12 30 |  |    16 |   106 |   13 |


* **cc**; compares entries from above tables
* **Comp**; The number of seconds the new version should have when compared to the older version. The calculation is `(nbr tests in new version) * (nbr seconds of old version) / (nbr tests in old version)`
* **secs**; number of seconds of testing new version.
* **Diff**; difference in seconds compared to real value of new version tests


* Number of lines coded and generated in this project
```
find . -name '*.raku*' | xargs wc -l
```
