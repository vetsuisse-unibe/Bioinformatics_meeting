mean <- 20
x <- 40
Wsq <- seq(1,x,1)

for (i in seq(1,x,1)) {
  Wsq[i] <- chisq.test(c(mean,i), correct=TRUE)$p.value
   
}
Wsq
which(Wsq<0.05)
