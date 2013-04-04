citHeader("To cite package '{package-name}' in publications please use:")

desc  <-  packageDescription("{package-name}")
year  <-  strsplit(desc$Date, '-', fixed=TRUE)[[1]]
year  <-  year[nchar(year) == 4]
vers  <-  paste("R package version",  desc$Version)
title <-  paste(desc$Package, ': ', desc$Title, sep='')

bibentry('Misc', 
         textVersion = paste('Stefan McKinnon Edwards (', year, ') ', title, '. ', sep=''),
         mheader = "To cite package 'STRING.T1.db'  in  publications  use:",
         title = title,
         author = person('Stefan McKinnon','Edwards',email='stefan.hoj-edwards@agrsci.dk',role=c('aut','cre')),
         year = year
         )

bibentry('Article',
         title  = "The STRING database in 2011: functional interaction networks of proteins, globally integrated and scored.",
         author = c(person("Damian","Szklarczyk"),
                    person("Andrea","Franceschini"),
                    person("Michael","Kuhn"),
                    person("Milan","Simonovic"),
                    person("Alexander","Roth"),
                    person("Pablo","Minguez"),
                    person("Tobias","Doerks"),
                    person("Manuel","Stark"),
                    person("Jean","Muller"),
                    person("Peer","Bork"),
                    person("Lars J.","Jensen"),
                    person("Christian","von Mering")),
         year = 2011,
         volume = 39, 
         number = 'suppl 1', 
         pages = 'D561-D568', 
         year = 2011, 
         doi = '10.1093/nar/gkq973',
         URL = 'http://nar.oxfordjournals.org/content/39/suppl_1/D561.abstract', 
         eprint = 'http://nar.oxfordjournals.org/content/39/suppl_1/D561.full.pdf+html', 
         journal = 'Nucleic Acids Research',
         
         textVersion = 'Damian Szklarczyk, Andrea Franceschini, Michael Kuhn, Milan Simonovic, Alexander Roth, Pablo Minguez, Tobias Doerks, Manuel Stark, Jean Muller, Peer Bork, Lars J. Jensen, and Christian von Mering (2011) The STRING database in 2011: functional interaction networks of proteins, globally integrated and scored.
Nucl. Acids Res.  39(suppl 1): D561-D568 first published online November 2, 2010 doi:10.1093/nar/gkq973'
         )

