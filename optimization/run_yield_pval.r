### Testing yield score ###
suppressPackageStartupMessages(library(argparse))
library(rtracklayer)
library(purrr)
library(zoo)
library(flux)
source("/hpc/hub_oudenaarden/edann/bin/coverage_bias/artificial_coverage/compare_peaks.r")


parser <- ArgumentParser()
parser$add_argument("roiBed", type="character",
                    help = "BED file of regions on which to compare yields")
args <- parser$parse_args()

ROI.track.file <- args$roiBed

## Load track for best and even 
load('/hpc/hub_oudenaarden/edann/bestVSeven_track.RData', verbose=T)

## Scale to remove values under zero
scaled.track <- best.even.track.all
score.cols <- colnames(values(scaled.track)[sapply(values(scaled.track), is.numeric)])
min.score <- min(as.matrix(scaled.track@elementMetadata[score.cols]))
for (col in score.cols) {
  scaled.track@elementMetadata[col][[1]] <- scaled.track@elementMetadata[col][[1]] + abs(min.score)
}

## Load track for regions of interest
roi.track <- import(ROI.track.file, format = 'BED')

## Compute p-val
realVSrandom.df <- random.delta.yield.dist(sample(scaled.track, 500000), roi.track, n.iterations = 1000)

## Save
save(realVSrandom.df, file = '/hpc/hub_oudenaarden/edann/yield_pval_output.RData')