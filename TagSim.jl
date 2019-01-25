#=
Tranisit

All angles are in radians except for latitudes and longitudes

=#
include("OrbitMechFcns.jl") # Hopefully this will be a package soon!
using LsqFit
using Random
using ForwardDiff

# Define constants
μ = 398600.441      #
rₑ = 6378.137       # [km] Earth radius
J₂ = 1.0826267e-3   # Oblatness
# Epoch, start/stop time and step size
# ⏰ = UT12MJD(11,22,2018,0,0,0)
⏰ = UT12MJD(10,7,2018,0,0,0)
# tstart = .0215*86400
tstart = 0 # This should always be zero! Otherwise you miss the propagation from epoch to tstart!
# tstop = 2*60*60 # two hours
tstop = .03*86400
dt = 2 # [sec] step size

# Define the orbital elements of the satellite
a = rₑ+500          # 500 km altitude orbit
e = 0.01            # Near circular orbit
i = deg2rad(89)     # Near polar orbit
Ω = deg2rad(90)
ω = 0
ν = 0
oeᵢ = OrbitalElementVec(a,e,i,Ω,ω,ν)
R,V = OE2ECI(oeᵢ)

# Simulate the orbit with ODE propagator
ICs = [R;V]
tspan = (tstart,tstop)
params = [μ;rₑ;J₂]
prob = ODEProblem(GravitationalForce,ICs,tspan,params)
ECIsol = solve(prob,saveat = dt)

# Extract the position and velocity data
# Subscript i for inertial frame
Rᵢ, Vᵢ = [],[]
for vect in ECIsol.u
    push!(Rᵢ,vect[1:3])
    push!(Vᵢ,vect[4:6])
end

# # Making sure the data looks right!
# xdata = zeros(length(ECIsol.u),1) # There should be a better way to extract this ..
# ydata = zeros(length(ECIsol.u),1)
# zdata = zeros(length(ECIsol.u),1)
# for i = 1:length(ECIsol.u)
#     xdata[i] = ECIsol.u[i][1]
#     ydata[i] = ECIsol.u[i][2]
#     zdata[i] = ECIsol.u[i][3]
# end
# plot1 = plot(xdata,ydata,zdata,xlim=(-8000,8000), ylim=(-8000,8000), zlim=(-8000,8000),
#        title = "Orbit via ODEsolver")


# Turn the ECI postitions into ECEF positions
# Subscript x for earth-fixed frame
MJD = ⏰ .+ ECIsol.t./86400
θ = MJD2GMST(MJD)
Rₓ,Vₓ = ECI2ECEF(Rᵢ,Vᵢ,θ)

# # Plot ground track for fun ...
# EP = EarthGroundPlot()
ϕ,λ,h = ECEF2GEO(Rₓ)
# plot!(λ,ϕ)


# Define the ground station
ϕground = 37.42662
λground = -122.173355

Rsat = GroundRange(Rₓ,ϕground,λground)

Az,Alt = SatAzAlt(Rsat)
viz = findall(Alt.>0)

# Plot GS and where sat is visible
EP = EarthGroundPlot()
plot!([λground λground],[ϕground ϕground],markershape=:star5,markersize=3)
plot!(λ[viz],ϕ[viz])
# display(EP)
"""
Here are the functions converting the relative position into the relative
velocities and doppler curve
"""

# Combine the ECEF position and velocities into one vector
X = []
for i = 1:length(Rₓ)
    push!(X,hcat(Rₓ[i]',Vₓ[i]'))
end
Xviz = X[viz]
XX = vcat(Xviz...) # This makes the array of vectors just an array

# Make an initial guess that is under sat at start of visible section
IG = Xviz[1][1:3]

function GetRelVel(X,P) # But this doesnt work with curve_fit
    H = []
    for vect in X
        val = (vect[1:3]-P)'*vect[4:6]/sqrt((vect[1:3]-P)'*(vect[1:3]-P))
        push!(H,val)
    end
    return H
end
function LSQfun(R,P) # THIS ONE WORKS !!!!!!
    x = [r[1] for r in R]
    y = [r[2] for r in R]
    z = [r[3] for r in R]
    u = [r[4] for r in R]
    v = [r[5] for r in R]
    w = [r[6] for r in R]

    top = ((x.-P[1]).*u .+ (y.-P[2]).*v .+ (z.-P[3]).*w)
    bottom = sqrt.((x.-P[1]).^2 .+ (y.-P[2]).^2 .+ (z.-P[3]).^2)
    rv = top./bottom

    c = 299792458
    f0 = 400
    h = f0.*(1 .+ -(1000 .* rv)./c)
    return h
end

function LSQfunoffset(R,P) # the offset makes it harder to guess the true location
    x = [r[1] for r in R]
    y = [r[2] for r in R]
    z = [r[3] for r in R]
    u = [r[4] for r in R]
    v = [r[5] for r in R]
    w = [r[6] for r in R]

    xg,yg,zg,f0 = P

    top = ((x.-xg).*u .+ (y.-yg).*v .+ (z.-zg).*w)
    bottom = sqrt.((x.-xg).^2 .+ (y.-yg).^2 .+ (z.-zg).^2)
    rv = top./bottom

    c = 299792458
    # f0 = 400
    h = f0.*(1 .+ -(1000 .* rv)./c) .+ 0
    return h
end

Rgs = LatLong2ECEF(ϕground,λground)
freqoff = 5
freq = 400
# testdata = GetRelVel(X,Rgs)
Random.seed!(2)
noise = .001*randn(length(Xviz))

P = [Rgs[1],Rgs[2],Rgs[3],freq]

testdata = LSQfun(Xviz,P) + .1*noise
testdata2 = LSQfunoffset(Xviz,P) + .1*noise
# p0 = [IG[1],IG[2],IG[3],0]
p0 = [0.0,0.0,0.0,400.0]
# p0 = P
fit = curve_fit(LSQfun, Xviz, testdata, p0)
fit2 = curve_fit(LSQfunoffset, Xviz, testdata2, p0)

estPos = fit.param[1:3]
estPos2 = fit2.param[1:3]

err = abs.(Rgs-estPos)

d1 = LSQfunoffset(Xviz,fit2.param)
d2 = LSQfunoffset(Xviz,P)

freqplot = plot(testdata2,label="Data")
plot!(freqplot,LSQfunoffset(Xviz,fit2.param),label="Estimate")
plot!(freqplot,LSQfunoffset(Xviz,P),label="True")
display(freqplot)


ϕest,λest,hest = ECEF2GEO([estPos2])

EP2 = EarthGroundPlot()
plot!(EP2,[λground λground],[ϕground ϕground],markershape=:star5,markersize=3,label="True")
plot!(EP2,[λest λest],[ϕest ϕest],markershape=:star6,markersize=3,label="Estimate")
plot!(EP2,λ[viz],ϕ[viz])
display(EP2)

# Turn function into frequency dependent
# Add bias offset - gets wrong side of passs ...
# Try a moving base
#   break into smaller solves?
#   try estimating a velocity?
# Fisher information ...


# TEST
# data1 = LSQfun(Xviz,estPos)
# data2 = LSQfun(Xviz,estPos2)
#
# testplt = plot(data1,label="Ture Curve")
# plot!(testplt,data2,label="Est CUrve")
# display(testplt)

"""
MOVING TAG
These functions deal with a moving tag
"""
# Given an initial lat/long and a final lat/long this gives the ECEF coordinates
# over the span defined by tvec
function GroundMotion(ϕstart,λstart,ϕend,λend,tvec)
    R = []
    ϕ = range(ϕstart, stop = ϕend, length = length(tvec))
    λ = range(λstart, stop = λend, length = length(tvec))
    for i = 1:length(tvec)
        push!(R,LatLong2ECEF(ϕ[i],λ[i]))
    end
    return R,ϕ,λ
end

# This gives the doppler curve
function MovingTag(X,V,P)
    c = 299792458
    f0 = 400
    h = zeros(length(X))
    for i = 1:length(X)
        rv = (X[i]-P[i])'*V[i]/sqrt((X[i]-P[i])'*(X[i]-P[i]))
        h[i] = f0*(1 + -(1000 * rv)/c)
    end
    return h
end


# Create a moving tag and find satellite visible times
Rgs2,ϕtag,λtag = GroundMotion(ϕground,λground,ϕground+5,λground+5,ECIsol.t)
Rsat2 = GroundRange(Rₓ,ϕtag,λtag)
Az2,Alt2 = SatAzAlt(Rsat2)
viz2 = findall(Alt2.>0)

realdata =  MovingTag(Rₓ[viz2],Vₓ[viz2],Rgs2[viz2])
# plot(realdata)
Xviz2 = X[viz2]
n = length(Xviz2)
bins = 4
valperbin = floor(n/bins)
partition(x, n) = [x[i:min(i+n-1,length(x))] for i in 1:n:length(x)]

Xsplit = partition(Xviz2,Int(valperbin))
datasplit = partition(realdata,Int(valperbin))
ϕmov,λmov = [],[]
movPos = []
for i = 1:bins
    movingfit = curve_fit(LSQfun, Xsplit[i], datasplit[i], [0.0,0.0,0.0])
    movpos = movingfit.param
    # moverr = Rgs2 .- [movPos]
    # @show moverr
    ϕm,λm = ECEF2GEO([movpos])
    push!(ϕmov,ϕm)
    push!(λmov,λm)
    push!(movPos,movpos)
end



EP3 = EarthGroundPlot()
plot!(EP3, λtag, ϕtag,label="Tag motion",legend=true)
plot!(EP3,λmov,ϕmov,markershape=:star6,markersize=3,label="Estimate")
display(EP3)

# make the data plot piecewise...
p3 = plot(realdata,label="real data")
for i = 1:bins
    estdata = LSQfun(Xviz2,movPos[i])
    plot!(p3,estdata,label="estimated")
end
display(p3)


# CALCULATE GRADIENT FOR FISHER INFORMATION
function GetSignal(X::Vector) # need one input for ForwardDiff
    x = X[1:6]
    p = X[7:9]

    rv = (x[1:3]-p)'*x[4:6]/sqrt((x[1:3]-p)'*(x[1:3]-p))
    f0 = 400
    c = 299792458
    f = f0*(1 + -(1000 * rv)/c)
    return f
end

val = [Xviz[1]';estPos]

fᵢ = GetSignal(val)

g1 = x -> ForwardDiff.gradient(GetSignal,x)
FI1 = []
for vect in Xviz
    val = [vect';estPos]
    grad = g1(val)
    push!(FI1,grad)
end

function OnePointDoppler(p)
        rv = (XX[1:3]-p)'*XX[4:6]/sqrt((XX[1:3]-p)'*(XX[1:3]-p))
        f0 = 400
        c = 299792458
        f = f0*(1 + -(1000 * rv)/c)
        return f
end

g = x -> ForwardDiff.gradient(OnePointDoppler,x)
FI = []
fi_tot = [0.0, 0.0, 0.0]
for vect in Xviz
    XX = vect
    grad = g(estPos)
    global fi_tot += grad
    push!(FI,grad)
end
yvar = 1.0;
FImat = fi_tot*yvar*fi_tot';

function OnePointDopplerFreq(P)
    p = P[1:3]
    rv = (XX[1:3]-p)'*XX[4:6]/sqrt((XX[1:3]-p)'*(XX[1:3]-p))
    f0 = 400
    c = 299792458
    f = f0*(1 + -(1000 * rv)/c) + P[4]
    return f
end
g2 = x -> ForwardDiff.gradient(OnePointDopplerFreq,x)
fi_tot2 = [0.0, 0.0, 0.0, 0.0]
testing = [-1677.13, -4755.17, 3868.69, 0.1]
for vect in Xviz
    XX = vect
    grad = g2(testing)
    global fi_tot2 += grad
    push!(FI,grad)
end
FImat2 = fi_tot2*yvar*fi_tot2';
