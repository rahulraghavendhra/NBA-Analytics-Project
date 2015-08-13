# Load table values as a data frame
d.f = read.csv("/home/rahul/Documents/Howba/GuidedProject2/Dataset/playercompletedetails-WithoutNUllSalary-2000-2014.csv",header=TRUE)

##############################################
# Density Plots
plot(density(log(d.f$salary)))
plot(density(logsal, kernel = "gaussian", adjust=1, bw="SJ"))

##############################################
# Q-Q Plot
qqnorm(d.f$salary, main = 'Normal Q-Q Plot (Salary)')
qqnorm(log(d.f$salary), main = 'Normal Q-Q Plot (Logsal)')

##############################################
# Find Log of Sal
d.f$LogSal =  log(d.f$salary)

##############################################
# Kmeans
scatterplotMatrix(~Age+experience+FG+LogSal+MP+PTS+G, reg.line=lm,smooth=TRUE, spread=FALSE, span=0.5, id.n=0, diagonal = 'density', data=d.f)
scatterplotMatrix(~LogSal+TWOP + THREEP+ FT+ORB+DRB+TRB, reg.line=lm,smooth=TRUE, spread=FALSE, span=0.5, id.n=0, diagonal = 'density', data=d.f)
scatterplotMatrix(~AST+STL+LogSal+BLK+TOV+PF, reg.line=lm,smooth=TRUE, spread=FALSE, span=0.5, id.n=0, diagonal = 'density', data=d.f)

sapply(d.f,class)
kmdata <- scale(d.f)
wss <- (nrow(kmdata)-1)*sum(apply(kmdata,2,var))
for (i in 2:10) wss[i] <- sum(kmeans(kmdata, centers=i)$withinss)
plot(1:10, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares",
     main="Optimal Cluster")

cluster<-kmeans(model.matrix(~-1 + MP+ PTS + G + TWOPTHREEPPERCENT + experience + TRB,d.f),centers = 4, iter.max = 10)
plot(d.f$MP+d.f$PTS+d.f$G+d.f$TWOPTHREEPPERCENT+d.f$experience+d.f$TRB,d.f$salary, col=cluster$cluster, main="Clusters : MP + AST + BLK + TRB + TOV")

cluster$centers
cluster$size
cluster$betweenss/cluster$totss

##############################################
# Create dummy variables for the Position of the players
d.f$experience <- factor(d.f$experience)
is.factor(d.f$pos)
d.f$pos[1:5]

##############################################
# Linear regression
regression <- lm(salary~P + MP+ PTS + G + TWOP + THREEP + experience + FG + FT + AST + BLK + STL + TOV + PF + age, data = d.f)
summary(regression)

logsal = log(d.f$salary)
reggressionmodel = lm(LogSal ~ experience+FG+MP+PTS+G+TWOP+THREEP+FT+TRB+PF+TOV, data = d.f)
summary(regressionmodel)
step <- stepAIC(reggressionmodel, direction="both")
step$anova

# Analyse coefficients
coefficient = coefficients(regmodel)

##############################################
# Panel data analysis

# Fixed data analysis
# Include Panel data model Library
library(plm)

# Attach Data Set without Dummy Variables
FEdata<- read.csv("/Users/VishnuGT/Desktop/Vishnu/Computing Sem 2/Howba/Assignment/Assignment 2/PanelDataComplete_Final.csv")
attach(FEdata)

# Fixed Effect Model
femodel1=lm(salary ~ height+weight+G+MP+THREEP+TWOP+ORB+DRB+AST+STL+BLK+TOV+PF+PTS+experience)
summary(femodel1)


# Individual time fixed effect
# Include library for Panel data model
library(plm)

# Attach Dataset for Analysis - Filled with Dummy Variables
FEdata<- read.csv("/Users/VishnuGT/Desktop/Vishnu/Computing Sem 2/Howba/Assignment/Assignment 2/PanelDataComplete_DumFilled.csv")
attach(FEdata)

# Individual Fixed Effect Model
playerdummy=as.factor(playerid)
treg3=lm(salary ~ height+weight+G+MP+THREEP+TWOP+ORB+DRB+AST+STL+BLK+TOV+PF+PTS+experience+playerdummy)
summary(treg3)

# Time Fixed Effect Model
seasondummy=as.factor(season)
treg4=lm(salary ~ height+weight+G+MP+THREEP+TWOP+ORB+DRB+AST+STL+BLK+TOV+PF+PTS+experience+playerdummy+seasondummy)
summary(treg4)

# Fixed vs Random Effects
# Include Panel Data Model Library
library(plm)

# Attach Data Set
mydata<- read.csv("/Users/VishnuGT/Desktop/Vishnu/Computing Sem 2/Howba/Assignment/Assignment 2/PanelDataComplete_DumFilled.csv")
attach(mydata)

# Dependent Variable - Salary
Y <- cbind(salary)

# Independent Variables
X <- cbind(height, weight, G, MP, THREEP, TWOP, ORB, DRB, AST, STL, BLK, TOV, PF, PTS,experience)

# Index - PlayerId and Time Index - Season
paneldata <- plm.data(mydata, index=c("playerid","season"))

# Summary of variables
summary(Y)
summary(X)

# Pooled Estimator
pooledestimator <- plm(Y ~ X, data=paneldata, model= "pooling")
summary(pooledestimator)

# Fixed effects or within estimator
fixedestimator <- plm(Y ~ X, data=paneldata, model= "within")
summary(fixedestimator)

# Random effects estimator
randomestimator <- plm(Y ~ X, data=paneldata, model= "random")
summary(randomestimator)

# Hausman test for fixed versus random effects model
phtest(randomestimator, fixedestimator)

# Visual inspection:
residuals = resid(fixedestimator)
plot(residuals)
lines(residuals)

##############################################
# Prediction intervals - Lower bound/Upper bound

confint(regmodel, level=0.95)
predict(regmodel,interval="prediction")