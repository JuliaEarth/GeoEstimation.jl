# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    IDW(var₁=>param₁, var₂=>param₂, ...)

Inverse distance weighting estimation solver.

## Parameters

* `neighbors` - Number of neighbors (default to all data locations)
* `distance`  - A distance defined in Distances.jl (default to `Euclidean()`)

### References

Shepard 1968. *A two-dimensional interpolation function for irregularly-spaced data.*
"""
@estimsolver IDW begin
  @param neighbors = nothing
  @param distance = Euclidean()
end

function solve(problem::EstimationProblem, solver::IDW)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)
  N = ncoords(pdomain)
  T = coordtype(pdomain)

  mactypeof = Dict(name(v) => mactype(v) for v in variables(problem))

  # result for each variable
  μs = []; σs = []

  for covars in covariables(problem, solver)
    for var in covars.names
      # get user parameters
      varparams = covars.params[(var,)]

      # determine value type
      V = mactypeof[var]

      # retrieve non-missing data
      locs = findall(!ismissing, pdata[var])
      𝒟 = view(pdata, locs)
      X = coordinates(𝒟)
      z = 𝒟[var]

      # number of data points for variable
      ndata = length(z)

      @assert ndata > 0 "estimation requires data"

      # allocate memory
      varμ = Vector{V}(undef, nelms(pdomain))
      varσ = Vector{V}(undef, nelms(pdomain))

      # fit search tree
      M = varparams.distance
      if M isa NearestNeighbors.MinkowskiMetric
        tree = KDTree(X, M)
      else
        tree = BallTree(X, M)
      end

      # determine number of nearest neighbors to use
      k = varparams.neighbors == nothing ? ndata : varparams.neighbors

      @assert k ≤ ndata "number of neighbors must be smaller or equal to number of data points"

      # pre-allocate memory for coordinates
      x = MVector{N,T}(undef)

      # estimation loop
      for loc in traverse(pdomain, LinearPath())
        coordinates!(x, pdomain, loc)

        is, ds = knn(tree, x, k)
        ws = one(V) ./ ds
        Σw = sum(ws)

        if isinf(Σw) # some distance is zero?
          j = findfirst(iszero, ds)
          μ = z[is[j]]
          σ = zero(V)
        else
          ws /= Σw
          vs  = view(z, is)
          μ = sum(ws[i]*vs[i] for i in eachindex(vs))
          σ = minimum(ds)
        end

        varμ[loc] = μ
        varσ[loc] = σ
      end

      push!(μs, var => varμ)
      push!(σs, var => varσ)
    end
  end

  EstimationSolution(pdomain, Dict(μs), Dict(σs))
end
