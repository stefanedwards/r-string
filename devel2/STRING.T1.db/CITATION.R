citHeader("To  cite  package  ’{package-name}’  in  publications  use:")

desc  <-  packageDescription("{package-name")
year  <-  sub(".*(2[[:digit:]]{3})-.*",  "\\1",  desc$Date)
vers  <-  paste("R  package  version",  desc$Version)
title <-  paste(desc$Package, ': ', desc$Title, sep='')

citEntry(entry = "Manual",
         title = title,
         
         textVersion = paste('Stefan McKinnon Edwards (', year, ') ', title, '. ')
)

# citEntry(entry="Manual",
#          title  =  "nlme:  Linear  and  Nonlinear  Mixed  Effects  Models",
#          author  =  personList(as.person("Jose  Pinheiro"),
#                                as.person("Douglas  Bates"),
#                                as.person("Saikat  DebRoy"),
#                                as.person("Deepayan  Sarkar"),
#                                as.person("the  R  Core  team")),
#          year  =  year,
#          note  =  vers,
#          textVersion  =
#            paste("Jose  Pinheiro,  Douglas  Bates,  Saikat  DebRoy,",
#                  "Deepayan  Sarkar  and  the  R  Core  team  (",
#                  year,
#                  ").  nlme:  Linear  and  Nonlinear  Mixed  Effects  Models.  ",
#                  vers,  ".",  sep=""))

citEntry(entry  = "Article",
         title  = "The STRING database in 2011: functional interaction networks of proteins, globally integrated and scored.",
         author = personList(as.person("Damian Szklarczyk"),
                             as.person("Andrea Franceschini"),
                             as.person("Michael Kuhn"),
                             as.person("Milan Simonovic"),
                             as.person("Alexander Roth"),
                             as.person("Pablo Minguez"),
                             as.person("Tobias Doerks"),
                             as.person("Manuel Stark"),
                             as.person("Jean Muller"),
                             as.person("Peer Bork"),
                             as.person("Lars J. Jensen"),
                             as.person("Christian von Mering")),
         year = 2011,
         volume = 39, 
         number = 'suppl 1', 
         pages = 'D561-D568', 
         year = 2011, 
         doi = '10.1093/nar/gkq973',
         URL = 'http://nar.oxfordjournals.org/content/39/suppl_1/D561.abstract', 
         eprint = 'http://nar.oxfordjournals.org/content/39/suppl_1/D561.full.pdf+html', 
         journal = 'Nucleic Acids Research',
         
         textVersion = 'Damian Szklarczyk, Andrea Franceschini, Michael Kuhn, Milan Simonovic, Alexander Roth, Pablo Minguez, Tobias Doerks, Manuel Stark, Jean Muller, Peer Bork, Lars J. Jensen, and Christian von Mering
The STRING database in 2011: functional interaction networks of proteins, globally integrated and scored
Nucl. Acids Res. (2011) 39(suppl 1): D561-D568 first published online November 2, 2010 doi:10.1093/nar/gkq973'
         )

