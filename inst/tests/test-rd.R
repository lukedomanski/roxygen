context("Rd")
roc <- rd_roclet()

test_that("empty file gives empty list", {
  out <- roc_proc_text(roc, "")
  expect_identical(out, list())
})

test_that("NULL gives empty list", {
  out <- roc_proc_text(roc, "NULL")
  expect_identical(out, list())
})

test_that("generic keys produce expected output", {
  out <- roc_proc_text(roc, "
    #' @references test
    #' @note test
    #' @author test
    #' @seealso test
    #' @concept test
    #' @encoding test
    #' @name a
    NULL")[[1]]
  expect_equal(get_tag(out, "references")$values, "test")
  expect_equal(get_tag(out, "note")$values, "test")
  expect_equal(get_tag(out, "seealso")$values, "test")
  expect_equal(get_tag(out, "concept")$values, "test")
  expect_equal(get_tag(out, "encoding")$values, "test")
  expect_equal(get_tag(out, "author")$values, "test")
})

test_that("@noRd inhibits documentation", {
  out <- roc_proc_text(roc, "
    #' Would be title
    #' @title Overridden title
    #' @name a
    #' @noRd
    NULL")

  expect_equal(length(out), 0)
})


test_that("deleted objects not documented", {
  out <- roc_proc_text(roc, "
    f <- function(){
      .a <- 0
      function(x = 1){
        .a <<- .a + x
        .a
      }
    }
    
    #' Addition function.
    f2 <- f()
    rm(f)
  ")
  expect_equal(names(out), "f2.Rd")
})


test_that("documenting unknown function requires name", {
  expect_error(roc_proc_text(rd_roclet(), "
    #' Virtual Class To Enforce Max Slot Lenght
    #' 
    #' @export
    setClass('A')
    
    #' Validity function.
    setValidity('A', function(object) TRUE)  
    "),
    "Missing name"
  )
})
