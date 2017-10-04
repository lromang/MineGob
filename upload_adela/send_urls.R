#! /usr/bin/Rscript

###################################
###### Librerias utilizadas #######
###################################
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(R.utils))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(lubridate))

###################################
### Enviar resultados
###################################

send_ticket <- function(urls, recs, dates, admi, idad, subid, email){
    op_curl <- paste0(
        "curl https://mxabierto.zendesk.com/api/v2/tickets.json -d ", "'", '{"ticket": {"subject": "Actualización de Analytics DGM", "comment": { "body": "Escuadrón: ', ",\\n\\nActualización Analítics DGM:\\n\\n------------------------------\\n\\n")

    f_urls <- paste(
       paste(paste0("Recurso: ", recs), paste0("URL: ", urls), paste0("Fecha de Actualización: ", dates), sep = "\\n\\n" ),
       collapse = "\\n\\n----------------------\\n\\n"
   )

   conc <- "\\n\\n Sin más por el momento, me mantengo a su disposición para resolver cualquier duda sobre el proceso de cumplimiento de la Política de Datos Abiertos en el correo escuadron@datos.gob.mx o vía telefónica al 50935300 ext: 7054.\\n\\nSaludos cordiales."

    cl_curl <- paste0('"}, "status": "open", "type": "task", "priority": "normal" , "description":"Resumen de analytics de DGM", "tags": ["analytics"], "collaborator_ids":[',subid ,'] ,"requester": {"id":', idad,',"name":','"', admi,'", "email":', '"', email,'"}}', "}'",' -H "Content-Type: application/json" -v -u mail@mail:psswd -X POST')

    all_text <- paste(op_curl, f_urls, conc, cl_curl, sep = "")
    ## writeLines(all_text, "test.txt")
    if(length(urls) > 0){
        system(all_text)
    }
}

send_multi_ticket <- function(){
    recs <- c("Resumen Analytics DGM",
             "Recursos y Conjuntos Red Mx")
    urls <- c("https://drive.google.com/uc?export=download&id=0B5p8KkRjjG4HOHhwTHhwenBIUk0",
             "https://drive.google.com/uc?export=download&id=0B5p8KkRjjG4HbUkxSi15T01WMTQ")
    dates <- c(rep(today(), 2))
    email   <- "mail@mail"
    admi    <- "user"
    idad    <- "123456"
    subid   <- "123456"
    send_ticket(urls, recs, dates, admi, idad, subid, email)
}
#######
send_multi_ticket()
