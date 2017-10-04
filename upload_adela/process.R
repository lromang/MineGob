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
suppressPackageStartupMessages(library(RGA))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(lubridate))

###################################
## Read data
###################################
## MAT
## PUBLIC_DATA
## DATOSGOB_RESUM
## REDMX
###################################

## Read in dataset
mat    <- read.csv("MAT.csv",
                  stringsAsFactors = FALSE)
## Order names
mat$X <- NULL

## Obtain dependencies with inventory
invent <- mat[str_detect(mat$conj_tit,
                        "(I|i)nventario (I|i)nstitucional de (D|d)atos .*"),
             c(4, 7)]
plans <- mat[str_detect(mat$conj_tit,
                       "(P|p)lan de (A|a)pertura (I|i)nstitucional .*"),
            c(4, 7)] %>%
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
# all_conj     <- mat.conj[, plyr::count(conj), by = "slug"]
# all_conj.f   <- all_conj[, .N, by = "slug"]

###################################
## fecha
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
write.csv(ent_rec_conj, "dirty_adela.csv", row.names = FALSE)

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
## Agregar datos sin recursos
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
          "dataset_presidencia.csv",
          row.names = FALSE)

###################################
## Google Analytics
###################################
## Profiles
##        id              name
## 1 88225771 All Web Site Data
## 2 91319629 All Web Site Data DESCARGAS 2014/10/01 - today
## 3 91863615 All Web Site Data VISITAS   2014/10/01 - today

## token <- Auth("497323299158-elgh4c5t1o57dd8qfvakr99ge6d2qge3.apps.googleusercontent.com",
##              "I7wDgHvwULRHkB7bjt_JrrJt")
## save(token, file="oauth_token")
## load("oauth_token")
## Validate Token
## ValidateToken(token)
authorize()
## -----------------------------
## Queries
##
## Downloads :
## 85102504(2014-07-01 -> 2014-09-30)
## +
## 91319629(2014-10-01 -> today)
##
## Sessions:
## 91863615(2014-07-01 -> today)
## +
## 91319629(2014-10-01 -> today)
## -----------------------------
yesterday <- today()

##################################################
## Downloads
##################################################

## (2014-10-01 -> today)
## CKAN
id <- 91319629
query.downloads.ckan <- get_ga(id, start.date   = "2014-07-01",
                              end.date    = yesterday,
                              dimensions  = "ga:date, ga:pagePath",
                              metrics     = "ga:totalEvents",
                              sort        = "-ga:date",
                              fetch.by    = "day")
analytic_downloads <- sum(query.downloads.ckan$totalEvents)
## all.queries.downloads <- query.downloads

## Date
query.downloads.ckan$date        <- as.Date(query.downloads.ckan$date)
query.downloads.ckan$date_n_time <- strptime(paste0(query.downloads.ckan$date, ":",
                                              query.downloads.ckan$hour),
                                       format="%Y-%m-%d:%H")
## (2014-07-01 -> 2014-09-30)
## BETA
id <- 88225771
query.downloads.beta <- get_ga(id, start.date   = "2014-07-01",
                              end.date    = "2014-09-30",
                              dimensions  = "ga:date, ga:pagePath",
                              metrics     = "ga:totalEvents",
                              sort        = "-ga:date",
                              fetch.by    = "day")
## all downloads
analytic_downloads <- analytic_downloads + sum(query.downloads.beta$totalEvents)

## Date
query.downloads.beta$date        <- as.Date(query.downloads.beta$date)
query.downloads.beta$date_n_time <- strptime(paste0(query.downloads.beta$date, ":",
                                              query.downloads.beta$hour),
                                            format="%Y-%m-%d:%H")
## ------------------------------
## ALL DOWNLOADS
## ------------------------------
all.downloads <- rbind(query.downloads.ckan,
                      query.downloads.beta)
all.downloads <- all.downloads[all.downloads$totalEvents > 0,]

## Conj Downloads
all.downloads$conj.downloads <- str_extract(all.downloads$pagePath,
                                           "/dataset/([[:alnum:]]+-?)+") %>%
    str_replace("/dataset/","")

## Rec Downloads
all.downloads$rec.downloads <- str_extract(all.downloads$pagePath,
                                          "/resource/([[:alnum:]]+-?)+") %>%
    str_replace("/resource/","")
## ------------------------------
## data-table
## ------------------------------
all.downloads.t      <- data.table(all.downloads)

## CONJ
conj.join.mat <- select(mat, c(dep, conj_tit, conj))
conj.join.mat <- filter(conj.join.mat, !duplicated(conj.join.mat))

all.downloads.t.conj <- all.downloads.t[, sum(totalEvents),
                                       by = c("date", "conj.downloads")]
names(all.downloads.t.conj) <- c("date", "conj", "downloads")
all.downloads.t.conj        <- na.omit(all.downloads.t.conj)
all.downloads.conj          <- merge(all.downloads.t.conj,
                                    conj.join.mat,
                                    by = "conj",
                                    all.x = TRUE) %>%
    na.omit()
write.csv(all.downloads.conj, "./downloads_conj.csv", row.names = FALSE)

## REC
rec.join.mat <- select(mat, c(dep, rec_id, rec, rec_des))
rec.join.mat <- filter(rec.join.mat,
                      !duplicated(rec.join.mat))

all.downloads.t.rec  <- all.downloads.t[, sum(totalEvents),
                                      by = c("date", "rec.downloads")]
names(all.downloads.t.rec) <- c("date", "rec_id", "downloads")
all.downloads.t.rec        <- na.omit(all.downloads.t.rec)
all.downloads.rec          <- merge(all.downloads.t.rec,
                                    rec.join.mat,
                                    by = "rec_id",
                                    all.x = TRUE) %>%
    na.omit()

write.csv(all.downloads.rec, "./downloads_rec.csv", row.names = FALSE)
##################################################
## Visites
##################################################
id <- 91863615
query.visits <- get_ga(id, start.date   = "2014-10-01",
                      end.date    = yesterday,
                      dimensions  = "ga:date, ga:pagePath, ga:hour, ga:medium",
                      metrics     = "ga:sessions,ga:pageviews,ga:bounces",
                      sort        = "-ga:date",
                      fetch.by    = "day",
                      max.results = NULL)
analytic_visits  <- sum(query.visits$sessions)
analytic_bounces <- sum(query.visits$bounces)
## Date
query.visits$date <- as.Date(query.visits$date)
query.visits$date_n_time <- strptime(paste0(query.visits$date, ":", query.visits$hour),
                                       format="%Y-%m-%d:%H")
png("visitas.png")
ggplot(data = query.visits, aes(x = date_n_time, y = sessions)) +
    geom_point( color = "#00cc99") + geom_jitter(color = "#00cc99") +
theme(panel.background = element_blank(), axis.title = element_text(colour = "#424242")) +
ylab("Número de visitas") + xlab("Fecha")
dev.off()
## -----------------------------
## Daily data
## -----------------------------
## Daily downloads
q.downloads <- data.table(all.downloads)
down_dates  <- q.downloads[,sum(totalEvents), by = "date"]
names(down_dates) <- c("fecha",
                      "Descargas")
## Daily visits
q.visits <- data.table(query.visits)
vis_dates  <- q.visits[,sum(sessions), by = "date"]
names(vis_dates) <- c("fecha",
                      "Visitas")
write.csv(vis_dates,
          "data_visits.csv",
          row.names = FALSE)

## -------------------
## Visites CKAN
## -------------------
id <- 91319629
query.visits.ckan <- get_ga(id, start.date   = "2014-07-01",
                      end.date    = yesterday,
                      dimensions  = "ga:date, ga:pagePath, ga:hour",
                      metrics     = "ga:sessions",
                      sort        = "-ga:date",
                      fetch.by    = "day",
                      max.results = NULL)
analytic_visits.ckan  <- sum(query.visits.ckan$sessions)



###################################
## Add data
###################################
conj.dep.hack <- length(RJSONIO::fromJSON(getURL("https://datos.gob.mx/busca/api/3/action/package_list"))$result)
data_summ <- data.frame("Concepto" = c(
                           "Recursos de datos publicados",
                           "Conjuntos de datos total publicados",
                           "Conjuntos de datos de dependencias",
                           "Dependencias publicando",
                           "Dependencias con Inventario",
                           "Dependencias con Plan",
                           "Visitas",
                           "Descargas",
                           "Periodo"
                       ), "Total" = c(
                              nrow(all),
                              conj.dep.hack,
                              conj_dep_sum,
                              nrow(final_data) - 3,
                              nrow(invent),
                              nrow(plans),
                              analytic_visits + analytic_visits.ckan,
                              analytic_downloads,
                              paste("2014-07-01", yesterday, sep = " / ")
                          ))
write.csv(data_summ,
          "datosgob_resum.csv",
          row.names = FALSE)

###################################
## Public data
###################################
public_data <- all[,c(11, 4, 3, 5, 2)]
public_data$clave <- paste0(public_data$dep,
                           public_data$conj_id)
public_data <- filter(public_data,
                     !duplicated(clave))
public_data <- public_data[order(public_data$slug),]
write.csv(public_data, "public_data.csv",
          row.names = FALSE)

###################################
## Red MX
###################################
redmx <- dplyr::filter(all,
                      str_detect(dep, "Estado de") |
                      str_detect(dep, "Ayuntamiento de") |
                      str_detect(dep, "Auditoría superior de") |
                      str_detect(dep, "(ase|ASE)")
                      )
redmx <- redmx[order(redmx$dep),]
write.csv(redmx, "redmx.csv", row.names = FALSE)
