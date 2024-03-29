% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/competitions.R
\name{kgl_competitions_list}
\alias{kgl_competitions_list}
\title{Competitions List}
\usage{
kgl_competitions_list(page = 1, search = NULL, clean_response = TRUE)
}
\arguments{
\item{page}{Numeric. Page number.}

\item{search}{Character. Search terms.}

\item{clean_response}{Logical. Clean the response from the Kaggle API. If \code{FALSE}, this will return the object from the \code{\link[httr2:req_perform]{httr2::req_perform()}} call.}
}
\value{
Based on \code{clean_response}
\itemize{
\item \code{TRUE}: A tibble containing information on the given \code{id}
\item \code{FALSE}: {httr2} httr2_response object
}
}
\description{
List competitions
}
\seealso{
Other Competitions: 
\code{\link{kgl_competition_submit}()},
\code{\link{kgl_competitions_data_download_all}()},
\code{\link{kgl_competitions_data_download}()},
\code{\link{kgl_competitions_data_list}()},
\code{\link{kgl_competitions_leaderboard_download}()},
\code{\link{kgl_competitions_leaderboard_view}()},
\code{\link{kgl_competitions_list_submissions}()}
}
\concept{Competitions}
