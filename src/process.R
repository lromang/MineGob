#! /usr/bin/Rscript

######################################################################
## This script creates the general dataset of presidencia
######################################################################


###################################
## Libraries
###################################
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(RGA))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(RJSONIO))
suppressPackageStartupMessages(library(RGoogleAnalytics))
suppressPackageStartupMessages(library(ggplot2))

###################################
## Read data
###################################
## MAT
## PUBLIC_DATA
## DATOSGOB_RESUM
## REDMX
###################################

## Read in dataset
mat    <- read.csv("../data/MAT.csv",
                  stringsAsFactors = FALSE)

## Get institutions with inventory and plan
invent <- mat[str_detect(mat$conj_tit,
                        "(I|i)nventario (I|i)nstitucional de (D|d)atos .*"), ] %>%
    select(dep, rec) %>%
    na.omit()
plans <- mat[str_detect(mat$conj_tit,
                       "(P|p)lan de (A|a)pertura (I|i)nstitucional .*"), ] %>%
    select(dep, rec) %>%
    na.omit()

###################################
## Filter data
###################################
all      <- mat
mat      <- dplyr::filter(mat, slug != "")
mat.dc   <- data.table(mat)
mat.conj <- data.table(all)

###################################
## N rec, conj
###################################
rec          <- mat.dc[, .N, by = "slug"] # Resources by slug
conj         <- mat.dc[, plyr::count(conj), by = "slug"] # Datasets by slug
conj.f       <- conj[, .N, by = "slug"] # Unique datasets by slug
conj_dep_sum <- sum(conj.f$N) # Count of all datasets (dependencies)

###################################
## Dates
###################################
dates <- mat.dc[, max(fecha_m), by = "slug"]

###################################
## Put it all together
###################################
entities <- data.frame(apply(
    mat[, c(11, 4)],
    2,
    unique))
entities$tiene_inv  <- entities$slug %in% invent$slug
entities$tiene_plan <- entities$slug %in% plans$slug
ent_rec             <- merge(entities, rec, by = "slug", all.x = TRUE)
ent_rec_conj        <- merge(ent_rec, conj.f, by = "slug", all.x = TRUE)
names(ent_rec_conj) <- c("slug",
                        "dep",
                        "tiene_inventario",
                        "tiene_plan",
                        "recursos",
                        "conjuntos")
ent_rec_conj <- merge(ent_rec_conj, dates, by = "slug", all.x = TRUE)
names(ent_rec_conj) <- c("slug",
                        "dep",
                        "tiene_inventario",
                        "tiene_plan",
                        "recursos",
                        "conjuntos",
                        "fecha")
write.csv(ent_rec_conj, "../data/dirty_adela.csv", row.names = FALSE)

###################################
## Refinements
###################################
ent_rec_conj$tiene_inventario[
    ent_rec_conj$tiene_inventario == TRUE
] <-"Si"
ent_rec_conj$tiene_inventario[
    ent_rec_conj$tiene_inventario == FALSE
] <- "No"
ent_rec_conj$tiene_plan[
    ent_rec_conj$tiene_plan == TRUE] <- "Si"
ent_rec_conj$tiene_plan[
    ent_rec_conj$tiene_plan == FALSE] <- "No"

final_data <- ent_rec_conj
final_data <- final_data[,-1]
final_data[,c(4,5)] <- final_data[,c(5,4)]
names(final_data) <- c("Nombre de la dependencia",
                      "¿Cuenta con Inventario de Datos?",
                      "¿Cuenta con Plan de Apertura?",
                      "Número de conjuntos de datos publicados",
                      "Número de recursos de datos publicados",
                      "Última fecha de actualización")

###################################
## Data without resources
###################################
new_data  <- data.frame("dep"   = c("AGN","CENSIDA","PF"),
                       "inv"   = rep("Si", 3),
                       "plan"  = rep("Si", 3),
                       "conj"  = rep(0,3),
                       "rec"   = rep(0,3),
                       "fecha" = rep(NA, 3))
names(new_data) <- names(final_data)
final_data      <- rbind(final_data, new_data)
write.csv(final_data,
          "../data/dataset_presidencia.csv",
          row.names = FALSE)
