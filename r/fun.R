
scrape_site <- function(site) {
  page_url <- as.character(df_url[site,])
  page_html <- xml2::read_html(page_url)
  album_title <- page_html %>% 
    xml2::xml_find_all("//strong[contains(@class, 'stark')]") %>% 
    rvest::html_text()
  artist_name <- page_html %>% 
    rvest::html_nodes("h3") %>% 
    xml2::xml_find_all("span") %>% 
    rvest::html_text()
  review_author <- page_html %>% 
    xml2::xml_find_all("//em[contains(@class, 'author')]") %>% 
    rvest::html_text() %>% 
    str_replace("Kritik von ","")
  summary <- page_html %>% 
    xml2::xml_find_all("//p[contains(@class, 'teasertext')]") %>% 
    rvest::html_text() %>% 
    str_replace("\\s\\(\\d\\sKommentare\\)", "")
  rating_reader <- page_html %>% 
    xml2::xml_find_all("//li[contains(@class, 'voting-leser')]") %>% 
    rvest::html_text() %>% 
    str_extract("\\d")
  rating_author <- page_html %>% 
    xml2::xml_find_all("//li[contains(@class, 'voting-redaktion')]") %>% 
    rvest::html_text() %>% 
    str_extract("\\d")
  review_url <- page_html %>% 
    xml2::xml_find_all("//article[contains(@class, 'teaser')]") %>% 
    rvest::html_nodes("a") %>% 
    rvest::html_attr('href') %>% 
    str_replace("#kommentare", "") %>% 
    unique() %>% 
    str_c("https://www.laut.de",.)
  cover_url_small <- page_html %>% 
    xml2::xml_find_all("//img[contains(@class, 'teaserbild')]") %>% 
    rvest::html_attr('src') %>% 
    str_c("https://www.laut.de",.)
  df <- tibble(artist_name, album_title, review_author, summary, rating_reader, rating_author, review_url, cover_url_small)
  return(df)
}

scrape_review_site <- function(url){
  page_html <- xml2::read_html(url)
  album_genre <- page_html %>% 
    xml2::xml_find_all("//span[contains(@class, 'info')]") %>% 
    rvest::html_nodes("a") %>% 
    rvest::html_text() %>% 
    str_c(collapse = ", ")
  album_publisher <- page_html %>% 
    xml2::xml_find_all("//span[contains(@class, 'info')]") %>% 
    rvest::html_text() %>% 
    str_extract("\\(([^\\)]+)\\)") %>% #TODO: some publisher names contains parenthesis, regex should be changed accordingly
    str_replace("\\(","") %>% 
    str_replace("\\)","")
  album_release_date <- page_html %>% 
    xml2::xml_find_all("//span[contains(@class, 'info')]") %>% 
    rvest::html_text() %>% 
    str_extract("\\d+.\\s\\w+\\s\\d+") %>% 
    lubridate::dmy()
  album_title <- page_html %>% 
    xml2::xml_find_all("//meta[contains(@itemprop, 'itemreviewed')]") %>% 
    rvest::html_attr(name = "content") %>% 
    str_extract("\"(.+)\"") %>% 
    str_replace_all("\"","")
  df <- tibble(album_title, album_genre, album_publisher, album_release_date)
  return(df)
}