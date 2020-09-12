# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoEstimation

using GeoStatsBase

using NearestNeighbors
using StaticArrays
using Distances
using LinearAlgebra

import GeoStatsBase: solve

include("idw.jl")
include("lwr.jl")

export
  InvDistWeight,
  LocalWeightRegress

end
