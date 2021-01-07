require("httr");require("dplyr");require("purrr");require("data.table");require("rvest")
# ************************
#   getConstituents
# ************************
# ticker
ticker = "VTI"
# page url
pg <- html_session(paste0("https://www.barchart.com/etfs-funds/quotes/",ticker,"/constituents"))
# save page cookies
cookies <- pg$response$cookies
# Use a named character vector for unquote splicing with !!!
token <- URLdecode(dplyr::recode("XSRF-TOKEN", !!!setNames(cookies$value, 
                                                           cookies$name)))
# get data by passing in url and cookies
pg <- 
  pg %>% rvest:::request_GET(
    paste0("https://www.barchart.com/proxies/core-api/v1/EtfConstituents?",
           "composite=",ticker,"&fields=symbol%2CsymbolName%2Cpercent%2CsharesHeld%2C",
           "symbolCode%2CsymbolType%2ClastPrice%2CdailyLastPrice&orderBy=percent",
           "&orderDir=desc&meta=field.shortName%2Cfield.type%2Cfield.description&",
           "page=1&limit=10000&raw=1"),
    config = httr::add_headers(`x-xsrf-token` = token)
  )

# raw data
data_raw <- httr::content(pg$response)
# convert into a data table
data <- rbindlist(lapply(data_raw$data,"[[",6), fill = TRUE, use.names = TRUE)

