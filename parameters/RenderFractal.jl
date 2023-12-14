using CairoMakie
using Images
using ColorSchemes 

struct EscapeTimeProblem
    z0::Number
    f::Function
    stop::Function
    maxiter::Int
end

function problem_array(patch::Matrix,f::Function,s::Function,maxiter::Int)

    PA = Array{EscapeTimeProblem}(undef,size(patch)...)
    for i in eachindex(patch)
        PA[i] = EscapeTimeProblem(patch[i],f,s,maxiter)
    end
    return PA
end

#We can unify the following two funcitons

function escape_time(prob::EscapeTimeProblem,colors::Vector{RGB{Float64}})
    z = prob.z0
    for iter in 1:prob.maxiter
        if prob.stop(z) == true
            return colors[mod1(iter - 1,256)]
        else
            z = prob.f(z)
        end
    end
    return colors[mod1(iter,256)]
end


function binarycolor(prob::EscapeTimeProblem, color::Function)
    z = prob.z0
    #=
    This function acts as a stop condition
    "You shall stop."
    =#
    for iter in 1:prob.maxiter
        if prob.stop(z) == true
            return color(z)
        else
            z = prob.f(z)
        end
    end
    #=
    As well as a function which takes a point satisfying the stop condition and gives it a color,
    "Hi, thanks for coming, here's a color"
    =#
    return RGB{Float64}(0.7,0.2,0.8)

end

function normalize_escape_time!(patch::Matrix)
    patch = patch .- patch[1,1]
end

function apply_color(patch::Matrix,colors::Vector{RGB{Float64}})
    pic = zeros(RGB{Float64},size(patch))
    for i in eachindex(patch)
        pic[i] = colors[patch[i]+1]
    end
    return pic
end



function blackwhite(alpha::Real)

    function color(z::Complex)
        turns = angle(z)/(2*pi) + 0.5
        if  turns >= alpha/2 && turns <alpha/2+0.5
            return RGB{Float64}(1,1,1)
        else
            return RGB{Float64}(0,0,0)
        end
    end

    return color

end

function escape(Radius::Real)

    function escaped(z::Number)
        if abs2(z) > Radius
            return true
        else
            return false
        end
    end

    return escaped
end






function julia_patch(center::Complex, right_center::Complex)
    #Overall strategy: 
    #we will first compute the patch at the correct scale and orientation, centered at the origin
    #we will then translate the patch to to correct location and return it

    top_center = 1.0*im*right_center
    #points from the origin to the top of the frame

    horizontal_axis = LinRange(-right_center,right_center,1000)
    vertical_axis = LinRange(-top_center,top_center,1000)

    origin_patch = transpose(horizontal_axis) .+ vertical_axis
    #we want a matrix whose i,jth element is H[i] + V[j]

    return origin_patch .+ center
end


