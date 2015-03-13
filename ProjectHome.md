[STRING](http://string-db.org) is a database of known and predicted protein-protein interactions (PPI). Currently (as of version 9.0) it covers over 5 mio. proteins from 1133 organisms.

The full dataset is downloadable, as well as a web interface for querying on specific proteins.

For use in R, the dataset can be overwhelming can takes some time to get the relevant data from the > 1 GB text file. We there present a package for R, which can create data packages for R, which are easy to load and document.
The packages further includes functions for querying specific proteins as well as mapping to e.g. entrez gene identifiers. To top it off, all PPI's for the given organism is present as a ready to use object based on certain settings.

**Example of usage:** (fictional results)
```
> library(STRING.Bt.db)
> print(STRING.Bt_organism)
[1] "Bos taurus"

> STRING.Bt.PPI('ENSBTAP00000000017', cutoff=900)
                 id1                 id2  score
1 ENSBTAP00000000017  ENSBTAP00000000018    900
2 ENSBTAP00000000017  ENSBTAP00000000020    950
3 ENSBTAP00000000017  ENSBTAP00000000021    915
```