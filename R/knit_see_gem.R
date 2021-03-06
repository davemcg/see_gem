#' Knit SeeGEM with peddy stats
#' 
#' Create the interactive html document
#' 
#' @param rmd Path to a custom R markdown file. A default R markdown file is 
#' provided with this package
#' @param output_file Output name (I recommend ending in 'html', as this is what the file
#' is) of your output file. 
#' @param output_directory Directory the output file will be written to. 
#' Defaults to your working directory.
#' @param GEMINI_data Path to .Rdata data frame which contains the Data Frame 
#' of the GEMINI output that will be plotted. Helper scripts are provided as 
#' \code{\link{gemini_test_wrapper}} and \code{\link{gemini_query_wrapper}} 
#' which will return the GEMINI output as a data frame into your R session. 
#' @param sample_name The name of your sample
#' @param title The title of the document
#' @param peddy_path_prefix Path and prefix for the peddy output
#' @param peddy_id A character vector of the samples you want to highlight in the
#' peddy QC tab
#' @param decorate TRUE or FALSE. If set to TRUE (default), then the data frame 
#' given as input `GEMINI_data` will be decorated with the default settings for
#' \code{\link{See_GEM_formatter}}. If you have already run this function on
#' the data frame you are giving to \code{\link{knit_see_gem}}, then set this
#' to FALSE.
#' @param skip_stats If set to 'yes' this will use an alternate template which
#' has no `peddy QC` tab. 
#' 
#' @return None
#' 
#' @import rmarkdown
#' @import tidyr
#' @import ggplot2
#' @import knitr
#' @importFrom ggbeeswarm geom_quasirandom
#' @importFrom cowplot plot_grid
#' @importFrom cowplot get_legend
#' @importFrom ggrepel geom_text_repel
#' 
#' @export
#' 
#' @examples 
#' \dontrun{
#' # will output just the example document to ~/SeeGEM_document.html
#' knit_see_gem()
#' # more realistic example which does an automsal recessive test 
#' knit_see_gem(GEMINI_data = 
#' gemini_test_wrapper('2018_06_28__OGVFB_exomes.GATK.PED_master.gemini.db', 
#' test = 'autosomal_recessive', 
#' families = 'DDL003'), 
#' output_file='~/quick_SeeGEM.html', 
#' skip_stats = 'yes')
#' }

knit_see_gem <- function(rmd = system.file("rmd/document_template.Rmd", package="SeeGEM"),
                         output_file = 'SeeGEM_document.html',
                         output_directory = getwd(),
                         GEMINI_data = system.file("extdata/GEMINI_data.Rdata", package="SeeGEM"),
                         sample_name = NA,
                         title = "SeeGEM Test Report",
                         peddy_path_prefix = paste0(system.file("extdata/", package="SeeGEM"), "/SEE_GEM_PEDDY"),
                         peddy_id = c('1045', '1046', '1265'),
                         decorate = TRUE,
                         skip_stats = 'no'){
  
  # if data given as character, assume it's a path to an Rdata file
  if (is.character(GEMINI_data)){
    gdf <- load(GEMINI_data)
    GEMINI_data <- get(gdf)
    rm(gdf)
  }
  
  # warn if nrow or ncol is 0 for input data 
  if (decorate == FALSE){
    document_data <- GEMINI_data
  } else if ((nrow(GEMINI_data) == 0 | ncol(GEMINI_data) == 0)){
    warning('Empty data frame given as input!')
    document_data <- GEMINI_data
  } else { 
    document_data <- See_GEM_formatter(GEMINI_data) 
  }
  
  
  if (skip_stats == 'no'){
    
    rmarkdown::render(system.file("rmd/document_template.Rmd", package="SeeGEM"),
                      output_file = output_file,
                      output_dir = output_directory,
                      params = list(GEMINI_data_frame = GEMINI_data,
                                    sample_name = sample_name,
                                    title = title,
                                    peddy_id = peddy_id,
                                    decorate = decorate,
                                    peddy_path_prefix = peddy_path_prefix))
  } else{
    rmarkdown::render(system.file("rmd/document_template_noStats.Rmd", package="SeeGEM"),
                      output_file = output_file,
                      output_dir = output_directory,
                      params = list(GEMINI_data_frame = GEMINI_data,
                                    sample_name = sample_name,
                                    decorate = decorate,
                                    title = title))
  }
  
}
