
tree <- read.tree("Eucladid_MCC.tre")


#The output from RevBayes has branch lengths, but if all tips are extinct you should set the root age by adding the final extinction time to the maximum root to tip distance. This is required by some analyses and makes plotting on a timescale easier.


tree$root.time <- max(vcv(tree) + 268.8)

tree$edge.length[tree$edge.length == 0] <- 0.001
tree$node.label <- rep(1, Nnode(tree))

#For the purposes of this tutorial our main focus is on modelling change in continuous characters, but there is one discrete character for use later on. The three traits we will be modelling are calyx shape (measured as the length/width ratio of the calyx), fan density (approximate number of proximal feeding appendages an individual of the species has), and calyx complexity (number of plates interrupting the posterior interray), which is a discrete trait that could be ordered or unordered, depending on who you ask.

#Read in the data, take the natural log of the shape ratio and assign each trait to an individual vector (this format is required by some functions in `geiger`). Make a table of all taxa for which all three traits are available. Fan density is available for fewer taxa than are included in the tree, so make a pruned tree that only includes the overlapping taxa.

#read in data
data <- read.table("Shape_and_CalyxComplexity.txt", 
                   header = TRUE)
Fan_data <- read.table("Fan_density.txt", 
                       header = TRUE)

#log and assign to separate vectors
Shape <- log(data$Shape)
names(Shape) <- row.names(data)

Complexity <- data$Calyx_Complexity
names(Complexity) <- row.names(data)

Density <- Fan_data$Fan_density
names(Density) <- row.names(Fan_data) #this is already a logged value

#drop tips to make smaller tree that matches fan density data
prunedTree <- drop.tip(tree, 
                       setdiff(tree$tip.label, names(Density))
)

#make table with no missing data
overlapTaxa <- intersect(row.names(data), 
                         row.names(Fan_data))
allTraits <- data.frame(
  Species = overlapTaxa, 
  Shape = Shape[overlapTaxa], 
  Complexity = Complexity[overlapTaxa], 
  Density = Density[overlapTaxa]
)