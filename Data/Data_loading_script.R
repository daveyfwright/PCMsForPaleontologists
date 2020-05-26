#Open R or RStudio and set the working directory for the session to the folder that contains the data files

#If you don't have ape installed already use install.packages('ape') first
#Load the package ape, which allows R to properly read the phylogeny
library(ape)

#The tree we use in this example is the maximum clade credibility tree from the posterior of a Bayesian tip dating analysis
#First read the tree in
tree <- read.tree("Eucladid_MCC.tre")


#The phylogenies output from the inference analysis already have branch lengths in our example
#If all tips are extinct you should set the root age 
#This can be done by adding the final extinction time to the maximum root to tip distance (see manuscript for more detail)
#A root age is required by some analyses and also makes plotting on a timescale easier
tree$root.time <- max(vcv(tree) + 268.8)

#Some of the branches in our MCC tree have branch lengths of 0
#This will prevent some analyses from running, so we add 0.001 to all the zero length branches
#See manuscript for more detail
tree$edge.length[tree$edge.length == 0] <- 0.001

#Some analyses require that the tree has node labels, so set them next
#For now it doesn't matter that they're all the same label
tree$node.label <- rep(1, Nnode(tree))

#Now read in and format the trait data
#The three traits we use are calyx shape (measured as the length/width ratio of the calyx)
#filtration fan density (approximate number of proximal feeding appendages an individual of the species has)
#calyx complexity (number of plates interrupting the posterior interray)

#Read in the data files as tables
#This file has both shape and complexity
data <- read.table("Shape_and_CalyxComplexity.txt", 
                   header = TRUE)

#This file contains the fan data
Fan_data <- read.table("Fan_density.txt", 
                       header = TRUE)

#Some functions we will be using require each trait to be stored in a separate vector
#The shape ratio has to be logged before analysis
#log and assign shape to a vector
Shape <- log(data$Shape)
#Assign the correct species names to each trait value
names(Shape) <- row.names(data)

#Assign complexity to a vector
Complexity <- data$Calyx_Complexity
#Assign the correct species names to each trait value
names(Complexity) <- row.names(data)
# Increase values of complexity by 1. # this means that taxa with zero plates are given state "1", and taxa with 1 plates are labeded state "2", etc. 
# Although seemingly arbitrary, this step is necessary because later we use fitDiscrete in geiger, which does not accept states labeled as zero.
Complexity <- Complexity + 1 

#Assign filtration fan density to a vector
Density <- Fan_data$Fan_density
#Assign the correct species names to each trait value
names(Density) <- row.names(Fan_data)

#the density trait doesn't have entries for all of the taxa we have in the tree
#Some analyses require the tree and traits to match exactly
#Make a smaller tree that matches the density data by removing tips
prunedTree <- drop.tip(tree, 
                       setdiff(tree$tip.label, names(Density))
)

#Other functions we will be using require that all the trait data are in a single table
#They also require there to be no missing data

#Find the species that are in the data tables for both 
overlapTaxa <- intersect(row.names(data), 
                         row.names(Fan_data))


#Make a data frame with trait values for the same set of species
allTraits <- data.frame(
  Species = overlapTaxa, 
  Shape = Shape[overlapTaxa], 
  Complexity = Complexity[overlapTaxa], 
  Density = Density[overlapTaxa]
)

#This formatted data should enable you to execute any of the code in the manuscript