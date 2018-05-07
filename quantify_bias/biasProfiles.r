## Plot profiles
library(data.table)
library(readr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(reshape2)
library(RColorBrewer)

get.profile.from.matrix <- function(file.gz){
  mat <- read.table(file.gz, skip = 1)
  profMat <- t(mat[,-c(1:6)])
  profile <- apply(profMat,1,mean, na.rm=TRUE)
  return(profile/sum(profile))
}

load.profile <- function(profile.txt, normalize=TRUE, method='zscore'){
  profile <- scan(profile.txt)
  if (normalize) {
    if (method=='zscore'){
      return((profile-mean(profile))/sd(profile))
    }
    else {
      return(profile/sum(profile))
    }
  }
  else {
    return(profile)
  }
  }

make.df.of.profiles <- function(profiles){
  prof.df <- data.frame(profiles) %>%
    mutate(position = seq(1,n())) %>%
    melt(id.vars = c('position'), variable.name='sample')
  return(prof.df)
}

plot.genes.profile.df <- function(df, big.labels=FALSE){
  p <-ggplot(df, aes(position,value, color=sample)) + 
    theme_classic() +
    geom_line(size=2) +
    scale_x_continuous(breaks = c(0,300,800,1100), 
                       labels = c('0' = '-3kb', '300' = 'TSS', '800' = 'TES', '1100' = '+3kb')) +
    xlab('Relative position') + ylab('normalized coverage') +
    theme(axis.title = element_text(size = 30), 
          axis.text = element_text(size=25), 
          plot.title = element_text(hjust = 0.5,size=33),
          legend.title = element_blank(),
          legend.text = element_text(size=25), 
          legend.key.size = unit(1,"cm"),
          legend.position = "bottom") 
  if (big.labels) {
    p <- p + theme(axis.title = element_text(size = 50), 
                   axis.text = element_text(size=45), 
                   plot.title = element_text(hjust = 0,size=50),
                   legend.text = element_text(size=55)
    )
  }
  return(p)
}

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

plot.refpoint.profile.df <- function(df, center='CTCF sites'){
  breaks <- seq(0,max(df$position), length.out = 3)
  print(breaks)
  names(breaks) <- c('-3kb', center, '+3kb')
  p <-ggplot(df, aes(position,value, color=sample)) + 
    theme_classic() +
    geom_line(size=2) +
    scale_x_continuous(breaks = breaks,
                       labels = names(breaks)) +
    xlab('Relative position') + ylab('normalized coverage') +
    theme(axis.title = element_text(size = 33), 
          axis.text = element_text(size=25), 
          title = element_text(size=22),
          legend.title = element_blank(),
          legend.text = element_text(size=25), 
          legend.key.size = unit(1,"cm"),
          legend.position = "bottom")
  return(p)
}

### BS vs noBS
pbat.profile <- load.profile('~/mnt/edann/noPreAmp_crypts/PBAT_mm10.profile.txt')
noBS.profile <-load.profile('~/mnt/edann/noPreAmp_crypts/noBS_noChrUn.profile.txt')

df <- make.df.of.profiles(list(BS=pbat.profile, noBS = noBS.profile))
plot.genes.profile.df(df)

## Purified vs non-purified
VAN1667.profile <- load.profile("~/mnt/edann/hexamers/strand_specific/VAN1667.profile.txt")
purified.profile <- load.profile("~/mnt/edann/hexamers/OUD2086prediction/10_R1.profile.txt")
pcc <- round(cor(VAN1667.profile, purified.profile), 3)
df <- make.df.of.profiles(list(non.purified=VAN1667.profile, purified=purified.profile))
plot.genes.profile.df(df, big.labels = TRUE) +
  annotate('text',x=900, y=5.9, label=paste('PCC =', pcc), size=15) +
  ylab('Coverage (Z-score)') +
  scale_color_discrete(labels=c('purified'='Std. extraction', 'non.purified'='Trizol extraction')) +
  # theme(legend.position = "bottom",
  #       plot.title = element_text(hjust = 0.5, size=33),
  #       ) +
  ggtitle('Impact of genome accessibility') +
  
ggsave('~/AvOwork/formatted_figs/accessibility_bias.png')

## artificial coverage
artCov.prof <- load.profile('~/mnt/edann/hexamers/strand_specific/artificial_coverage/highcov.random.42.artCov.profile.txt')
VAN1667.subsmp.prof <- load.profile('~/mnt/edann/hexamers/strand_specific/VAN1667_se.highcov42.profile.txt')
pcc <- round(cor(artCov.prof, VAN1667.subsmp.prof), 3)

df <- make.df.of.profiles(list(experimental = VAN1667.subsmp.prof, predicted = artCov.prof ))
plot.genes.profile.df(df) +
  annotate('text',x=800, y=5.7, label=paste('PCC =', pcc), size=10) +
  ylab('Coverage (Z-score)')
ggsave("~/AvOwork/output/artificial_coverage/bias_artCovVSVAN1667subsmp_zscore.pdf")

## Hand-mixed profiles
CP <- load.profile("~/mnt/edann/crypts_bs/VAN2408/CP.profile.txt")
MP <- load.profile("~/mnt/edann/crypts_bs/VAN2408/MP.profile.txt")
p <- plot.genes.profile.df(make.df.of.profiles(list(hand.mixed.CP = CP, hand.mixed.MP = MP, machine.mixed = VAN1667.profile))) 
p + ylab('coverage (Z-score)') 
ggsave("~/AvOwork/output/coverage_bias/hadMixVSmachineMix_covprofile_zscore.pdf")

## Priming VS ligation
lig <- load.profile("~/mnt/edann/SRR1769256_chr1.profile.txt")
prim <- load.profile("~/mnt/edann/VAN1667.chr1.profile.txt")
pcc <- round(cor(lig, prim), 3)
p <- plot.genes.profile.df(make.df.of.profiles(list(ligation=lig, priming=prim)), big.labels = T) +
  ylab('coverage (Z-score)') 
cols <- gg_color_hue(2)
my.cols <- c(gg_color_hue(7)[7], cols[2])
names(my.cols) <- unique(p$data$sample)
p  +  annotate('text',x=900, y=5.9, label=paste('PCC =', pcc), size=15) +
  # scale_color_manual(values=cols)
  scale_color_manual(values =my.cols,
                     labels=c('ligation'='Ligation\n(Farlik et al. 2014)', 
                              'priming'='Random priming')) +
  ggtitle('Impact of WGA method') 
  ggsave('~/AvOwork/formatted_figs/wga_bias.png')
ggsave("~/AvOwork/output/coverage_bias/ligationVSpriming_covprofile_zscore.pdf")

## Reference point profile (CTCF)
CTCF.pred.norm <- load.profile('~/mnt/edann/hexamers/strand_specific/artificial_coverage/highcov.random.42.artCov.CTCF.profile.txt')
CTCF.pred.prop <- load.profile('~/mnt/edann/hexamers/strand_specific/artificial_coverage/highcov.random.42CTCF.flank200.coverage.artCov.CTCF.profile.txt')
CTCF.exp <- load.profile('~/mnt/edann/hexamers/strand_specific/VAN1667_se.highcov42.CTCF.profile.txt')

CTCF.df <- make.df.of.profiles(list(predicted.norm=CTCF.pred.norm,
                                    predicted.prop=CTCF.pred.prop,  
                                    experimental=CTCF.exp))
                               
p <- plot.refpoint.profile.df(CTCF.df)
p + geom_vline(xintercept = 300, color='red') +
  ylab('coverage (Z-score)') 
ggsave("~/AvOwork/output/coverage_bias/CTCFsites_proportionalVSnormal_covprofile_zscore.pdf")

## Smaller flank
CTCF.pred.norm <- load.profile('~/mnt/edann/hexamers/strand_specific/artificial_coverage/highcov.random.42.artCov.CTCF.profile.txt', normalize = FALSE)[280:320]
CTCF.pred.prop <- load.profile('~/mnt/edann/hexamers/strand_specific/artificial_coverage/highcov.random.42CTCF.flank200.coverage.artCov.CTCF.profile.txt', normalize = FALSE)[280:320]
CTCF.exp <- load.profile('~/mnt/edann/hexamers/strand_specific/VAN1667_se.highcov42.CTCF.profile.txt', normalize = FALSE)[200:400]

z.pred.norm <- (CTCF.pred.norm-mean(CTCF.pred.norm))/sd(CTCF.pred.norm)
z.pred.prop <- (CTCF.pred.prop-mean(CTCF.pred.prop))/sd(CTCF.pred.prop)

CTCF.df <- make.df.of.profiles(list(predicted.norm=z.pred.norm,
                                    predicted.prop=z.pred.prop))

 plot.profile.df(CTCF.df)
