@testset "LWR" begin
  # 1D regression
  Random.seed!(2017)
  N = 100
  x = range(0, stop=1, length=N)
  y = x.^2 .+ [i/1000*randn() for i=1:N]

  sdata   = georef((y=y,), reshape(x, 1, length(x)))
  sdomain = RegularGrid((0.,), (1.,), dims=(N,))
  problem = EstimationProblem(sdata, sdomain, :y)

  solver = LWR(:y => (neighbors=10,))

  solution = solve(problem, solver)

  yhat = solution[:y]
  yvar = solution[Symbol("y-variance")]

  if visualtests
    plt = scatter(x, y, label="data", size=(1000,400))
    plot!(x, yhat, ribbon=yvar, fillalpha=.5, label="LWR")
    @test_ref_plot "data/lwr-1D.png" plt
  end

  # 2D regression
  sdata   = georef((y=[1.,0.,1.,0.],), [25. 50. 75. 75.;  25. 75. 50. 25.])
  sdomain = RegularGrid(100,100)
  problem = EstimationProblem(sdata, sdomain, :y)

  solver₃ = LWR(:y => (neighbors=3,))
  solver₄ = LWR(:y => (neighbors=4,))

  sol₃ = solve(problem, solver₃)
  sol₄ = solve(problem, solver₄)

  if visualtests
    plt = contourf(sol₃)
    plot!(sdata)
    @test_ref_plot "data/lwr-3neigh.png" plt

    plt = contourf(sol₄)
    plot!(sdata)
    @test_ref_plot "data/lwr-4neigh.png" plt
  end

  # Haversine distance
  x = [81.45,81.42,83.35,85.24,89.51,91.01,93.05,93.07,96.04,94.09,95.03,310.0,31.0,324.0,301.0,285.0,12.0,359.0,90.0,67.0,236.0,284.0,271.0,292.0,123.0,225.0,107.0,237.0,126.0,126.0,127.5,129.0,129.0,12.56,13.23,10.23,303.0,307.0,314.0,301.0,305.0,312.0,322.0,194.0,192.0,191.0,177.0,352.99,349.75,343.61,342.84,341.85,342.83,341.43,338.93,346.0,341.7,335.5,342.5,9.0,358.55,355.75,351.45,347.79,346.92,344.42,342.73,343.7,342.0,347.65,155.39,153.29,154.08,153.45,152.0,152.2,139.17,310.44,310.52,312.0,309.93,310.47,352.41,314.85,299.72,12.36,255.64,214.41,121.32,130.58,254.7,278.76,103.07,269.0,92.0,110.0,119.0,354.0,342.0,350.0,110.0,228.3,276.1,264.4,161.4,240.82,302.0,130.13,107.11,106.43,88.57,353.0,341.5,337.92,344.94,246.4,286.27,300.36,299.65,300.63,300.42,311.6,332.0,338.0,353.0,332.0,5.25,352.0,6.8,346.01,326.0,333.0,284.0,288.0,106.4,49.2,182.13,182.7,183.18,277.0,73.3,60.0,28.0,23.0,136.0,43.0,124.2,309.5,286.45,286.6,289.76,358.0,132.65,115.63,115.4,119.0,145.05,275.0,265.0,262.66,149.3,44.0,49.0,150.0,290.0,288.0,168.0,241.0,226.0,34.5,301.0,289.7,121.9,288.0,326.0,332.0,333.0,160.0,280.0,85.0,33.0,127.0,140.0,170.0,150.0,106.0,122.0,298.0,69.0,180.0,147.0,43.0,40.0,140.0,145.0,83.0,171.0,115.0,25.0,323.0,55.5,356.8,352.2,351.3,349.5,346.25,351.5,35.0,5.0,12.0,36.0,36.2,41.0,42.5,48.0,43.15,314.58,304.68,324.95,319.5,287.88,300.0,8.0,132.0,132.0,128.0,146.15,172.4,289.1,38.85,32.6,32.87,18.45,13.28,11.3,2.9,280.0,240.0,170.0,120.0,60.0,20.0,320.0,37.0]
  y = [9.39,11.32,14.42,16.38,18.28,18.21,17.11,14.3,12.46,11.45,10.12,0.0,32.0,-11.0,-34.5,11.2,-6.0,53.0,21.0,24.0,46.3,40.3,30.0,49.0,31.0,70.0,9.0,37.5,37.0,35.0,34.5,35.0,37.0,-29.42,-25.36,-14.53,64.0,62.0,60.0,59.0,55.0,59.5,60.0,54.0,54.0,54.0,53.0,34.2,32.24,25.02,23.44,21.2,19.29,13.5,4.55,28.0,17.0,12.5,8.0,42.0,34.41,31.58,28.59,22.44,20.32,18.09,14.38,14.08,14.0,11.43,50.51,48.59,49.56,48.23,47.0,-31.5,-35.1,65.07,65.1,7.5,65.1,65.08,45.04,43.29,-52.55,-12.12,18.13,54.37,2.42,36.39,19.06,-7.35,-7.21,13.0,5.0,7.0,23.0,3.0,14.0,36.0,35.0,46.3,-3.6,4.1,46.3,47.09,-35.0,-9.06,-8.25,-8.7,-6.02,62.0,63.4,60.57,46.3,27.0,-16.92,14.72,13.03,12.55,11.03,3.4,69.0,65.0,62.0,78.0,60.5,71.0,65.0,72.9,67.0,72.3,-46.2,-38.0,-7.9,-67.37,-18.57,-18.5,-20.13,3.0,0.4,-10.0,-32.0,-33.0,-36.0,15.0,-8.3,13.25,-49.75,-52.33,-54.95,58.0,-1.2,-33.32,-34.42,-20.0,-4.08,10.0,13.0,19.83,-5.0,-12.0,-19.0,-5.0,-65.0,-66.0,-15.0,37.62,53.0,-20.0,-63.5,-23.85,20.25,-42.0,65.0,70.5,71.0,-10.0,13.0,-59.0,-27.0,-8.0,35.0,54.0,10.0,-6.0,-10.0,16.0,-49.0,-80.0,-43.0,12.0,20.0,27.0,15.0,-65.0,-45.0,25.0,67.0,66.0,-21.0,36.1,36.8,35.8,45.4,56.5,47.5,26.0,43.0,45.0,37.0,37.0,17.5,11.6,12.0,11.6,-60.95,-66.05,-74.4,-77.15,69.0,66.5,68.0,-4.0,-7.0,-9.0,-17.3,-41.0,-69.5,-23.37,-31.5,-29.63,-35.78,-30.58,-25.5,-50.58,-70.0,-70.0,-70.0,-65.0,-65.0,-70.0,-75.0,25.0]
  z = [-16.2,-16.1,-13.9,-15.1,-12.6,-12.8,-8.6,-9.3,-11.3,-9.2,-10.0,-9.2,-3.3,-12.9,-10.3,-8.3,-16.1,-13.5,-15.7,-12.2,-6.6,-11.3,-10.9,-5.3,-10.7,-14.3,-9.5,-3.6,-16.9,-13.2,-18.4,-13.4,-23.9,-11.0,-12.2,-18.8,-27.5,-24.1,-16.5,-17.0,-27.7,-8.8,-7.9,7.4,7.6,7.2,8.5,-11.7,-13.0,-15.3,-14.4,-14.8,-14.3,-15.7,-18.6,-12.8,-14.6,-12.0,-14.4,-13.0,-11.8,-13.6,-17.1,-17.8,-17.9,-17.1,-16.2,-14.3,-14.5,-12.1,7.6,7.3,7.7,9.6,10.1,-1.3,-6.0,-33.0,-24.2,-10.2,-34.3,-26.1,-9.9,-24.5,-4.4,-24.9,4.2,1.6,4.2,-9.3,1.3,-5.0,-13.8,2.0,-13.8,-10.6,-9.6,-9.1,-13.6,-8.5,-9.7,-6.1,-4.3,-3.4,-0.5,-6.0,-9.0,-9.3,-3.1,-2.8,-7.7,-6.5,7.6,3.4,-11.6,7.6,-3.2,-9.1,-9.6,-11.6,-13.3,-10.7,4.0,8.0,7.0,-13.0,-14.0,5.0,-14.0,-13.7,-38.0,-29.8,5.6,2.5,-2.6,-38.2,9.2,8.8,7.5,9.8,6.4,7.3,-9.2,-9.5,-21.1,4.1,-1.9,-12.0,-1.4,1.1,9.8,-10.6,4.1,1.7,-4.6,-15.1,7.1,7.3,5.9,1.5,8.3,3.4,-22.1,8.3,1.1,-3.2,7.4,-0.5,9.6,-14.5,5.7,5.5,-2.8,2.1,-38.0,4.0,-29.8,1.8,4.1,-0.5,-30.0,-12.4,7.7,7.4,7.4,0.0,-3.3,5.5,0.0,-20.8,-5.2,5.0,5.0,2.3,6.7,-8.0,-5.3,-10.2,-19.4,-26.0,4.0,-10.1,-8.4,-11.8,-11.6,-11.1,-11.6,-9.1,-9.7,-10.8,-6.2,-6.3,-4.2,6.2,10.0,6.3,-6.2,-5.7,-7.7,-10.4,-23.1,-25.8,-15.1,-8.7,-8.1,-9.5,-6.3,1.2,5.5,-15.5,-13.4,-15.3,-11.2,-11.6,-11.6,-4.8,-4.1,-3.7,-6.8,-14.3,-18.8,-14.0,-8.0,-11.2]
  sdata   = georef((z=z,), [x y]')
  sdomain = begin
    dims = (180, 91)
    start = (1.0, -89.01098901098901)
    finish = (359.0, 89.01098901098901)
    RegularGrid(start, finish, dims=dims)
  end
  problem = EstimationProblem(sdata, sdomain, :z)

  solver = LWR(:z => (distance=Haversine(6371.),neighbors=49))

  solution = solve(problem, solver)

  if visualtests
    gr(size=(900,250))
    @test_ref_plot "data/lwr-haversine.png" contourf(solution)
  end
end
