library(rgbif)


taxon_key = 7247523
#this is Lichen

gbif_user="myUserName"
gbif_pwd="my_pw"
gbif_email="my_email@gbif.org"


occ_download(
  pred_in("taxonKey", taxon_key),
  pred("hasCoordinate", TRUE),
  pred("hasGeospatialIssue", FALSE),
  pred_gte("year", 1990),
  pred_within("POLYGON((-149.45801 60.95215,-150.4248 60.93018,-151.36963 60.6665,-151.45752 60.09521,-151.85303 59.74365,-151.10596 59.63379,-151.89697 59.17236,-149.74365 59.5459,-148.8208 60.07324,-148.16162 60.09521,-149.45801 60.95215))"),
  format = "SIMPLE_CSV",
  user=gbif_user,pwd=gbif_pwd,email=gbif_email
)

#the predicates can be tweaked according to this https://docs.ropensci.org/rgbif/reference/download_predicate_dsl.html

