# A* shortest-path algorithm
module AStar

# The enqueue! and dequeue! methods defined in Base.Collections (needed for
# PriorityQueues) conflict with those used for queues. Hence we wrap the A*
# code in its own module.

using FastGraphs
using Base.Collections

export a_star_sp

function a_star_impl!(
    graph::AbstractFastGraph,# the graph
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    edge_distfn::Function,  # cost of each edge
    heuristic::Function,    # heuristic fn (under)estimating distance to target
    t::Int)  # the end vertex

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for edge in out_edges(graph, u)
            v = edge.dst
            if colormap[v] < 2
                colormap[v] = 1
                new_path = cat(1, path, edge)
                path_cost = cost_so_far + edge_distfn(edge)
                enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(v))
            end
        end
        colormap[u] = 2
    end
    nothing
end


function a_star_sp(
    graph::AbstractFastGraph,  # the graph
    edge_distfn::Function,      # cost of each edge
    s::Int,                       # the start vertex
    t::Int,                       # the end vertex
    heuristic::Function = n -> 0)
            # heuristic (under)estimating distance to target
    frontier = VERSION < v"0.4-" ? PriorityQueue{(Float64,Array{Edge,1},Int),Float64}() : PriorityQueue((Float64,Array{Edge,1},Int),Float64)
    frontier[(zero(Float64), Edge[], s)] = zero(Float64)
    colormap = zeros(Int, nv(graph))
    colormap[s] = 1
    a_star_impl!(graph, frontier, colormap, edge_distfn, heuristic, t)
end

function a_star_sp(
    graph::AbstractFastGraph,  # the graph
    s::Int,                       # the start vertex
    t::Int,                       # the end vertex
    heuristic::Function = n -> 0)
    a_star_sp(graph, n -> 1.0, s, t, heuristic)
end


end

using .AStar