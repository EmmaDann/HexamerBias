library(parallel)
source("/hpc/hub_oudenaarden/edann/bin/coverage_bias/deltaGprediction/binding_model_functions.r")

compute.enrichment.score <- function(dens.df, fc.df){
  # dens.df <- pred.cov.df %>%
  #   mutate(binding.dens = pred.cov/abundance) 
  enrichment.score <- dens.df %>%
    inner_join(., fc, by="template") %>%
    mutate(dens.fc=binding.dens*fc) %>%
    summarise(score=sum(dens.fc)) %>%
    .$score
  return(enrichment.score)
}

joining.fun <- function(...){
  df1 = list(...)[[1]]
  df2 = list(...)[[2]]
  col1 = colnames(df1)[1]
  col2 = colnames(df2)[1]
  xxx = left_join(..., by = setNames(col2,col1))
  return(xxx)
}

density.combo <- function(prob.vec, keqs.df=d3r.keqs, eps=epsilon.d3r, nreads=2238543){
  b.probs <- batch.prob.uniform(hexs=all.hexamers(), nuc.probs = prob.vec)
  pred.cov.b <- predict.coverage(keqs.df, eps, prob = b.probs)
  dens.df <- pred.cov.b %>%
    mutate(pred.cov=(pred.cov/sum(pred.cov))*nreads) %>%
    mutate(binding.dens = pred.cov/abundance)  %>% 
    dplyr::select(template, binding.dens)
  colnames(dens.df)[2] <- do.call(paste,c('dens',prob.vec, sep='_'))
  return(dens.df)
  }

## Load Keqs and epsilon for mouse BS-seq
load("/hpc/hub_oudenaarden/edann/VAN2591/mm10.onepreamp.keqs.RData")
epsilon.d3r <- 557.4402

## Make table of sequence combosition combos
prob.combos <- hexamerMatrix(stepSize = 0.05)
test.combos <- prob.combos[which(prob.combos['pC']!=0 & prob.combos['pG']!=0),]
l.test.combos <- lapply(seq_len(nrow(test.combos)), function(i) test.combos[i,])

## Compute density for all combos and save in table
test.combo.density <- mclapply(l.test.combos, function(x) density.combo(x, keqs.df = mm10.onepreamp.keqs), mc.cores = detectCores())
dens.table <- Reduce( joining.fun, test.combo.density)
save(dens.table, file="/hpc/hub_oudenaarden/edann/primer_combos_density_onepreamp.RData")
