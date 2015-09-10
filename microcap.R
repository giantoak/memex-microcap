microcap <- read.csv("~/Downloads/data/microcap.csv", stringsAsFactors=FALSE)
names(microcap)[1]<-'Symbol'
microcap$Date<-as.Date(microcap$Date)
mc<-split(microcap,microcap$Symbol)

mc<-lapply(mc, function(x){x[with(x, order(Date)),]})

mc2<-mc[lapply(mc, function(x){length(x$Open)}) > 20]
features<-sapply(mc2,function(x){as.data.frame(tsmeasures(data.frame(x$Adj.Close)))})
features.adj<-sapply(mc2,function(x){as.data.frame(tsmeasures(data.frame(x$Adj.Close)))})
features.vol<-sapply(mc2,function(x){as.data.frame(tsmeasures(data.frame(x$Volume)))})
features.vol$Symbol<-names(mc2)
feat<-t(features)featvol<-as.matrix(featvol)

feat.adj<-t(features.adj)
feat.vol<-t(features.vol)
row.names(feat.adj)<-NULL
row.names(feat.vol)<-NULL
feat.vol$Symbol<-names(mc2)

write.table(as.data.frame(feat),file="/home/gmueller/XDATA/microcap_features.csv",sep=",",quote=FALSE,row.names=FALSE)
write.table(as.data.frame(feat.vol),file="/home/gmueller/XDATA/microcap_features_adj.csv",sep=",",quote=FALSE,row.names=FALSE)
write.table(as.data.frame(output.adj),file="/home/gmueller/XDATA/microcap_features_vol.csv",sep=",",quote=FALSE,row.names=FALSE)
output.vol <- do.call(rbind,lapply(t(features.vol),matrix,ncol=13,byrow=TRUE))


output.adj <- do.call(rbind,lapply(t(features.adj),matrix,byrow=TRUE))
output.adj <- do.call(rbind,lapply(t(features.vol),matrix,byrow=TRUE))
out2<-as.data.frame(output.adj)

names(out2)[1:13]<-row.names(features.adj)
View(out)
out[1,:]
out[1,]
out[,c(14,1:13)]
outf2<-out2[,c(14,1:13)]
View(outf)
write.table(outf2,file="/home/gmueller/XDATA/microcap_features_adj.csv",sep=",",quote=FALSE,row.names=FALSE)

dat<-t(features.adj)

dat2<-as.matrix(dat)

df <- data.frame(matrix(unlist(t(dat2)), ncol=13, byrow=T))

df$Symbol<-names(mc2)

names(df)[1:13]<-row.names(features.adj)

df2<-df[,c(14,1:13)]

write.table(df2,file="/home/gmueller/XDATA/microcap_features_adj.csv",sep=",",quote=FALSE,row.names=FALSE)


