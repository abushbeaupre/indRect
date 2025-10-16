test_that("plot_direct_effect creates a ggplot", {
  # Create simple test data
  test_data <- data.frame(
    E = seq(-2, 2, length.out = 30),
    estimate = seq(40, 70, length.out = 30),
    conf.low = seq(38, 68, length.out = 30),
    conf.high = seq(42, 72, length.out = 30)
  )
  
  p <- plot_direct_effect(test_data, "E", title = "Test Plot")
  
  expect_s3_class(p, "ggplot")
})


test_that("plot_indirect_effect creates a ggplot", {
  # Create simple test data
  test_data_M <- data.frame(
    M = seq(30, 80, length.out = 30),
    estimate = seq(0.1, 0.8, length.out = 30),
    conf.low = seq(0.05, 0.75, length.out = 30),
    conf.high = seq(0.15, 0.85, length.out = 30)
  )
  
  test_data_ME <- data.frame(
    M = seq(40, 70, length.out = 20),
    E = seq(-2, 2, length.out = 20),
    estimate = seq(0.2, 0.6, length.out = 20),
    conf.low = seq(0.15, 0.55, length.out = 20),
    conf.high = seq(0.25, 0.65, length.out = 20)
  )
  
  p <- plot_indirect_effect(test_data_M, test_data_ME, "M", "E")
  
  expect_s3_class(p, "ggplot")
})


test_that("plot_indirect_interaction creates a ggplot", {
  # Create simple test data
  test_data <- data.frame(
    M = rep(seq(0, 50, length.out = 30), 3),
    E1 = rep(c(-1, 0, 1), each = 30),
    E2 = rep(seq(0, 10, length.out = 30), 3),
    estimate = runif(90, 0, 1),
    conf.low = runif(90, 0, 0.5),
    conf.high = runif(90, 0.5, 1)
  )
  
  p <- plot_indirect_interaction(test_data, "M", "E1", "E2")
  
  expect_s3_class(p, "ggplot")
})


test_that("plot_indirect_mediator_interaction creates a ggplot", {
  # Create simple test data
  test_data_M1M2 <- data.frame(
    M1 = rep(seq(30, 80, length.out = 30), 3),
    M2 = rep(c(1, 3, 5), each = 30),
    estimate = runif(90, 0, 1),
    conf.low = runif(90, 0, 0.5),
    conf.high = runif(90, 0.5, 1)
  )
  
  test_data_M1M2E <- data.frame(
    M1 = rep(seq(40, 70, length.out = 20), 3),
    M2 = rep(c(1, 3, 5), each = 20),
    E = rep(seq(-2, 2, length.out = 20), 3),
    estimate = runif(60, 0, 1),
    conf.low = runif(60, 0, 0.5),
    conf.high = runif(60, 0.5, 1)
  )
  
  p <- plot_indirect_mediator_interaction(test_data_M1M2, test_data_M1M2E, 
                                         "M1", "M2", "E")
  
  expect_s3_class(p, "ggplot")
})
