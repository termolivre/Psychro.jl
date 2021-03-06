#=

 This file implements the functions presented in the paper

 * [2] Wexler, A. and Hyland, R. W., "Formulations for the thermodynamic properties of dry air from 173.15 K to 473.15 K, and of saturated moist air from 173.15 K to 372.15 K at pressures to 5 MPa

=#    



"""
    Bm(Tk,xv)

First virial coefficient Bm of moist air of saturated vapor eq 2 [2].

 * `Tk` Temperature in K
 * `xv` Molar fraction of water vapor in the moist air
 * Output: Bm in m^3/mol


# Examples
```julia-repl
julia> Psychro.Bm(300, 0.01)
-7.8025792841398e-6
```
"""
function Bm(Tk, xv)
    xa = 1 - xv
    xa*xa*Baa(Tk) + 2*xa*xv*Baw(Tk) + xv*xv*Bww(Tk)
end

"""
    dBm(Tk,xv)

Derivative of first virial coefficient [`Bm`](@ref) of moist air of saturated vapor eq 2 [2].

 * `Tk` Temperature in K
 * `xv` Molar fraction of water vapor in the moist air
 * Output: dBm/dT in m^3/mol/K

# Examples
```julia-repl
julia> Psychro.dBm(300, 0.01)
1.9873214515110309e-7
```
"""
function dBm(Tk, xv)
    xa = 1.0 - xv
    xa*xa*dBaa(Tk) + 2*xa*xv*dBaw(Tk) + xv*xv*dBww(Tk)
end


"""
    Cm(Tk,xv)

Second virial coefficient Cm of moist air of saturated vapor eq 3 [2] (see [`Psychro`](@ref)).

 * `Tk` Temperature in K
 * `xv` Molar fraction of water vapor in the moist air
 * Output: Cm in m^6/mol^2

# Examples
```julia-repl
julia> Psychro.Cm(300, 0.01)
1.2734495937889647e-9
```
"""
function Cm(Tk, xv)
    xa = 1-xv
    xa*xa*xa*Caaa(Tk) + 3*xa*xa*xv*Caaw(Tk) + 3*xa*xv*xv*Caww(Tk) + xv*xv*xv*Cwww(Tk)
end

"""
    dCm(Tk,xv)

Derivative of second virial coefficient [`Cm`](@ref) of moist air of saturated vapor eq 3 [2] (see [`Psychro`](@ref)).

 * `Tk` Temperature in K
 * `xv` Molar fraction of water vapor in the moist air
 * Output: dCm/dT in m^6/mol^2/K

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function dCm(Tk, xv)
    xa = 1-xv
    xa*xa*xa*dCaaa(Tk) + 3*xa*xa*xv*dCaaw(Tk) + 3*xa*xv*xv*dCaww(Tk) + xv*xv*xv*dCwww(Tk)
end


"""
    Baa(Tk)

 Bₐₐ of dry air eq 10 [2] (see the docs for [`Psychro`](@ref)).

 * `Tk` Temperature in K
 * Output: Bₐₐ in m^3/mol

# Examples
```julia-repl
julia> Psychro.Baa(300)
-7.259614814814822e-6
```
"""
Baa(Tk) = 0.349568e-4 + (1.0/Tk)*(-0.668772e-2 + (1.0/Tk) * (-0.210141e1 + 0.924746e2/Tk))

"""
    dBaa(Tk)

Derivative of Bₐₐ(T), function [`Baa`](@ref). Calculated from equation 10 [2].

 * `Tk` Temperature in K
 * Output: Bₐₐ in m^3/mol/K

# Examples
```julia-repl
julia> Psychro.dBaa(300)
1.9571814814814817e-7
```
"""
dBaa(Tk) = 1.0/(Tk*Tk) * (0.668772e-2 + (1.0/Tk)*(0.420282e1 - 2.774238e2/Tk))

"""
    Caaa(Tk)

Second virial coefficient Cₐₐₐ of dry air eq 11 [2].

 * `Tk` Temperature in K
 * Output: Bₐₐ in m^6/mol^2

# Examples
```julia-repl
julia> Psychro.Caaa(300)
1.326141111111111e-9
```
"""
Caaa(Tk) = (0.125975e-8 + 1.0/Tk * (-0.190905e-6 + 0.632467e-4/Tk))

"""
    dCaaa(Tk)

Derivative of second virial coefficient Cₐₐₐ (function [`Caaa`](@ref)) of dry air eq 11 [2].

 * `Tk` Temperature in K
 * Output: Bₐₐ in m^6/mol^2/K

# Examples
```julia-repl
julia> Psychro.dCaaa(300)
-2.5637740740740747e-12
```
"""
dCaaa(Tk) = 1.0/(Tk*Tk) * (0.190905e-6 - 1.264934e-4/Tk) 


"""
    Zair(Tk, P)

Compressibility factor of dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: Z (nondimensional)

# Examples
```julia-repl
julia> Psychro.Zair(300, 1e6)
0.9972959755940749
```
"""
function Zair(Tk, P)
    vm0 = R*Tk/P
    b0 = Baa(Tk) / vm0
    c0 = Caaa(Tk) / (vm0*vm0)
    z = calcz(b0, c0)
end

"""
    molarvolumeair(Tk, P)

Molar volume of dry air. Equation 12 of reference [1].
This function requires iteration to compute the volume.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: molar volume in m^3/mol

# Examples
```julia-repl
julia> Psychro.molarvolumeair(300, 1e6)
0.002487593203694677
```
"""
function molarvolumeair(Tk, P)

    vm0 = R*Tk/P

    b0 = Baa(Tk)/vm0
    c0 = Caaa(Tk)/(vm0*vm0)
    z = calcz(b0, c0)
    
    return z*vm0
end

"""
    volumeair(Tk, P)

Specific volume of dry air. Uses `molarvolumeair`.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: molar volume in m^3/kg

# Examples
```julia-repl
julia> Psychro.volumeair(300, 1e6)
0.08588717536536251
```
"""
volumeair(Tk, P) = molarvolumeair(Tk, P) / Ma


"""
    molarenthalpyair(Tk)

Molar enthalpy of dry air. Equation 13 of reference [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: m^3/mol

# Examples
```julia-repl
julia> Psychro.molarenthalpyair(300, 1e6)
723.6723547535232

julia> Psychro.molarenthalpyair(300, 1e5)
782.5441847700663
```
"""
function molarenthalpyair(Tk, P)
    h1 = -0.79078691e4 + Tk*(0.28709015e2 +
                             Tk*(0.26431805e-2 +
                                 Tk*(-0.10405863e-4 +
                                     Tk*(0.18660410e-7 - 0.97843331e-11*Tk))))
    va = molarvolumeair(Tk, P)

    h2 = R*Tk/va * ( (Baa(Tk) - Tk*dBaa(Tk)) + (Caaa(Tk) - 0.5*Tk*dCaaa(Tk))/va )

    return (h1 + h2)
    
end


"""
    enthalpyair(Tk)

Specific enthalpy of dry air. Equation 13 of reference [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: m^3/kg

# Examples
```julia-repl
julia> Psychro.enthalpyair(300, 1e5)
27018.28800973868

julia> Psychro.enthalpyair(300, 1e6)
24985.666606367435
```
"""
function enthalpyair(Tk, P)
    return molarenthalpyair(Tk, P) / Ma
    
end


const ℓ =  (-0.16175159e3, 0.52863609e-2, -0.15608795e-4,
            0.24880547e-7, -0.12230416e-10, 0.28709015e2)


"""
    molarentropyair(Tk)


Specific entropy of dry air. Equation 14 of reference [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: m^3/(kg.K)

# Examples
```julia-repl
julia> Psychro.molarentropyair(300, 1e6)
-16.47796807767681
```
"""
function molarentropyair(Tk, P)

    s1 = polyeval(Tk, ℓ, 5) + ℓ[6]*log(Tk) - R*log(P/101325.0)
    va = molarvolumeair(Tk, P)
    s2 = R*log(P*va/R/Tk) - R/va * ( (Baa(Tk) + Tk*dBaa(Tk)) + 0.5/va * (Caaa(Tk) + Tk*dCaaa(Tk)))

    return (s1 + s2) 
end



"""
    entropyair(Tk)


Specific entropy of dry air. Equation 14 of reference [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: m^3/(kg.K)

# Examples
```julia-repl
julia> Psychro.entropyair(300, 1e6)
-568.9218525964338
```
"""
function entropyair(Tk, P)

    return molarentropyair(Tk, P) / Ma
end


"""
    Baw(Tk)

Cross virial coefficient Baw of saturated vapor eq 15 [2]

 * `Tk` Temperature in K
 * Output: Baw in m^3/mol

# Examples
```julia-repl
julia> Psychro.Baw(300)
-2.8798043617283956e-5
```
"""
Baw(Tk) = 0.32366097e-4 + 1.0/Tk * (-0.141138e-1 + 1.0/Tk * (-0.1244535e1 - 0.2348789e4/(Tk*Tk)))


"""
    Baw(Tk)

Derivative of cross virial coefficient Bww of saturated vapor eq 15 [2]

 * `Tk` Temperature in K
 * Output: dBaw/dT in m^3/mol/K

# Examples
```julia-repl
julia> Psychro.dBaw(300)
2.5287409744855964e-7
```
"""
dBaw(Tk) = 1.0/(Tk*Tk) * (0.141138e-1 + 1.0/Tk * (0.248907e1 + 0.93951568e4 /(Tk*Tk)))

"""
    Caaw(Tk)

Cross virial coefficient Caaw of saturated vapor eq 16 [2]

 * `Tk` Temperature in K
 * Output: Caaw in m^6/mol^2

# Examples
```julia-repl
julia> Psychro.Caaw(300)
8.019777407407409e-10
```
"""
Caaw(Tk) = 0.482737e-9 + 1.0/Tk * (0.105678e-6 + 1.0/Tk *
                                   (-0.656394e-4 + 1.0/Tk*
                                    (0.294442e-1 - 0.319317e1/Tk)))

"""
    dCaaw(Tk)

Derivative of cross virial coefficient dCaaw/dT of saturated vapor eq 16 [2]

 * `Tk` Temperature in K
 * Output: dCaaw/dT in m^6/mol^2/K

# Examples
```julia-repl
julia> Psychro.dCaaw(300)
-1.9610345679012353e-12
```
"""
dCaaw(Tk) = 1.0/(Tk*Tk) * (-0.105678e-6 + 1.0/Tk*(1.312788e-4 + 1.0/Tk*(-0.883326e-1 + 1.277268e1/Tk)))


"""
    ```Caww(Tk)```

Cross virial coefficient Caaw of saturated vapor eq 17 [2]

 * `Tk` Temperature in K
 * Output: Caww in m^6/mol^2

# Examples
```julia-repl
julia> Psychro.Caww(300)
-1.1555278368039328e-7
```
"""
Caww(Tk) = -1e-6 * exp( -0.10728876e2 + 1.0/Tk * (0.347802e4 + 1.0/Tk*(-0.383383e6 +  0.33406e8/Tk)))

"""
    dCaww(Tk)

Derivative of cross virial coefficient dCaaw/dT of saturated vapor eq 17 [2]

 * `Tk` Temperature in K
 * Output: dCaww/dT in m^6/mol^2/K

# Examples
```julia-repl
julia> Psychro.dCaww(300)
2.61363277754134e-9
```
"""
dCaww(Tk) = 1.0/(Tk*Tk) * (-0.347802e4 + 1.0/Tk * (2*0.383383e6 - 3*0.33406e8/Tk)) * Caww(Tk)


"""
    efactor2(Tk,P)

Enhancement factor of moist air. Another calculation procedure
Uses an iterative procedure to calculate the Enhancement factor defined 
in equation 18 [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: enhancement factor
 
# Examples
```julia-repl
julia> Psychro.efactor2(300, 1e5)
1.0042133426083673
```
"""
function efactor2(Tk, P, EPS=1e-8, MAXITER=200)
    f = 1.0
    err = 0.0
    for i = 1:MAXITER
        xas = (P-f*Pws(Tk)) / P
        fnovo = exp(lnf2(Tk,P,xas))
        err = abs(fnovo-f)
        
        if err < EPS
            if fnovo < 1
                fnovo = 1.0
            end
            return fnovo
        end
        
        f = fnovo
    end
    if fnovo < 1.0
        fnovo = 1.0
    end

    throw(ConvergenceError("Enhancement factor calculation did not converge!", fnovo, MAXITER, err))
end

"""
    efactor(Tk,P)

Enhancement factor of moist air.
Uses an iterative procedure to calculate the Enhancement factor defined 
in equation 18 [2]

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: enhancement factor
 
# Examples
```julia-repl
julia> Psychro.efactor(300, 1e5)
1.0042133426087643
```
"""
function efactor(Tk, P, relax=1.0, EPS=1e-8, MAXITER=200)

    if Tk < 273.16
        vc = volumeice(Tk) * Mv
        p = Pws_s(Tk)
        k = 0.0
    else
        vc = volumewater(Tk) * Mv
        p = Pws_l(Tk)
        k = henryk(Tk)
    end
    
    κ = kappa_f(Tk)

    RT = R * Tk
    
    baa = Baa(Tk)
    bww = Bww(Tk)
    baw = Baw(Tk)
    caaa = Caaa(Tk)
    caaw = Caaw(Tk)
    caww = Caww(Tk)
    cwww = Cwww(Tk)
    fun = f -> (log(f) - lnf(f, P, p, k, κ, vc, RT, baa, baw, bww, caaa, caaw, caww, cwww))

    ef = 1e-8
    
    f = 1.0
    err = 0.0
    df = 0.0
    for i = 1:MAXITER
        g = fun(f)
        dg = (fun(f+ef) - g) / ef
        df = -g/dg
                
        if abs(df) < EPS
            f = f + df
            if f < 1
                f = 1.0
            end
            return f
        end
        
        f = f + relax*df
    end

    throw(ConvergenceError("Enhancement factor calculation did not converge!", f, MAXITER, abs(df)))
end


"""
    lnf(f, P, p, k, κ, vc, RT, baa, baw, bww, caaa, caaw, caww, cwww)

Auxiliar function used in [`efactor`](@ref). 
"""
function lnf(f, P, p, k, κ, vc, RT, baa, baw, bww, caaa, caaw, caww, cwww)
    P2 = P*P
    p2 = p*p
    xas = (P - f*p) / P
    xas2 = xas*xas
    RT2 = RT*RT

    t1 = vc/RT * ( (1 + κ*p)*(P-p) - 0.5*κ*(P2 - p2) )
    t2 = log(1.0 - k*xas*P) + (xas2*P/RT)*baa - (2*xas2*P/RT)*baw
    t3 = -(P-p-xas2*P)/RT*bww + xas2*xas*P*P/RT2 * caaa
    t4 = 3*xas2*(1-2xas)*P2/(2*RT2) * caaw - (3xas2*(1-xas)*P2)/RT2 * caww
    t5 = -( (1+2xas)*(1-xas)^2*P2 - p2 )/(2*RT2) * cwww - (xas2*(1-3xas)*(1-xas)*P2)/RT2 * baa*bww
    t6 = -(2xas2*xas*(2-3xas)*P2) / RT2 * baa*baw + ( 6xas2*(1-xas)^2*P2 )/RT2 * bww*baw
    t7 = -3xas2*xas2*P2/(2RT2)*baa*baa - ( 2xas2*(1-xas)*(1-3xas)*P2 )/RT2 * baw*baw
    t8 = -( p2 - (1+3xas)*(1-xas)^3*P2 ) / (2*RT2) * bww*bww
    

   return t1+t2+t3+t4+t5+t6+t7+t8
    
end

"""
    lnf(Tk, P, xas)

Auxiliary function used to calculate the enhancement factor 
implemented in function [`efactor2`](@ref).

Actually, this function implements the RHS of eq. 18 of [2].
"""
function lnf2(Tk, P, xas)
    if Tk < 273.16
        vc = volumeice(Tk) * Mv
        p = Pws_s(Tk)
        k = 0.0
    else
        vc = volumewater(Tk) * Mv
        p = Pws_l(Tk)
        k = henryk(Tk)
    end
    
    κ = kappa_f(Tk)

    RT = R*Tk
    RT2 = RT*RT
    xas2 = xas*xas
    p2 = p*p
    P2 = P*P
    
    baa = Baa(Tk)
    bww = Bww(Tk)
    baw = Baw(Tk)
    caaa = Caaa(Tk)
    caaw = Caaw(Tk)
    caww = Caww(Tk)
    cwww = Cwww(Tk)
    
    t1 = vc/RT * ( (1 + κ*p)*(P-p) - 0.5*κ*(P2 - p2) )
    t2 = log(1.0 - k*xas*P) + (xas2*P/RT)*baa - (2*xas2*P/RT)*baw
    t3 = -(P-p-xas2*P)/RT*bww + xas2*xas*P*P/RT2 * caaa
    t4 = 3*xas2*(1-2xas)*P2/(2*RT2) * caaw - (3xas2*(1-xas)*P2)/RT2 * caww
    t5 = -( (1+2xas)*(1-xas)^2*P2 - p2 )/(2*RT2) * cwww - (xas2*(1-3xas)*(1-xas)*P2)/RT2 * baa*bww
    t6 = -(2xas2*xas*(2-3xas)*P2) / RT2 * baa*baw + ( 6xas2*(1-xas)^2*P2 )/RT2 * bww*baw
    t7 = -3xas2*xas2*P2/(2RT2)*baa*baa - ( 2xas2*(1-xas)*(1-3xas)*P2 )/RT2 * baw*baw
    t8 = -( p2 - (1+3xas)*(1-xas)^3*P2 ) / (2*RT2) * bww*bww
    

   return t1+t2+t3+t4+t5+t6+t7+t8
   
end

"""
    molarfracmoist_sat(Tk, P) 

Molar fraction of water vapor in saturated moist air

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * Output: molar fraction

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
molarfracmoist_sat(Tk, P,EPS=1e-8, MAXITER=200) = efactor(Tk, P,EPS, MAXITER) * Pws(Tk) / P



"""
    ```Bww(Tk)```

Virial coefficient Bww of saturated vapor eq 19 [2]

 * `Tk` Temperature in K
 * Output: Bww in m^3/mol

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
Bww(Tk) = R * Tk * Blin(Tk)

"""
    ```dBww(Tk)```

Derivative of virial coefficient dBww/dT of saturated vapor eq 19 [2]

 * `Tk` Temperature in K
 * Output: dBww/dT in m^3/mol/K

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
dBww(Tk) = R * (Tk * dBlin(Tk) + Blin(Tk))


"""
    ```Cwww(Tk)```

Second virial coefficient Cwww of saturated vapor eq 20 [2]

 * `Tk` Temperature in K
 * Output: Cwww in m^3/mol

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
Cwww(Tk) = R*R*Tk*Tk * (Clin(Tk) + Blin(Tk)^2)


"""
    ```dCwww(Tk)```

Derivative of second virial coefficient dCww/dT of saturated vapor eq 20 [2]

 * `Tk` Temperature in K
 * Output: dCwww/dT in m^3/mol/K
"""
dCwww(Tk) = R*Tk*R*Tk * (dClin(Tk) + 2*Blin(Tk) * dBlin(Tk)) + (2*R*R*Tk) * (Clin(Tk) + Blin(Tk)^2)


"""
    kappa_l(Tk)

Isothermal compressibility of saturated liquid water. Equation 21, ref. [2].
Range of applicability 0°C - 150°C but can be extended up to 200°C
More details in reference [4].
 * `Tk` Temperature in K
 * Output: κ in 1/Pa

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function kappa_l(Tk)
    Tc = Tk - 273.15

    #@check_range Tc 0 200
    if Tc < 100.0
        k = (50.88496 + Tc*(0.6163813 +
                            Tc*(1.459187e-3 +
                                Tc*(20.08438e-6 + Tc*(-58.47727e-9 + Tc*0.4104110e-9))))) /
                                (1.0 + 0.1967348e-1*Tc)
        
                                    
    else
        k = (50.884917 + Tc*(0.62590623 +
                            Tc*(1.3848668e-3 +
                                Tc*(21.603427e-6 + Tc*(-0.72087667e-7 + Tc*0.46545054e-9))))) /
                                (1.0 + 0.1967348e-1*Tc)
    end

    k*1e-11
end

"""
    kappa_s(Tk)

Isothermal compressibility of ice. Equation 22, ref. [2].

 * `Tk` Temperature in K
 * Output: κ in 1/Pa

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
kappa_s(Tk) = (8.875 + 0.0165*Tk)*1e-11

kappa_f(Tk) = 
    if Tk < 273.16
        kappa_s(Tk)
    else
        kappa_l(Tk)
    end



"""
    henryk_O2(Tk)

Henry's coefficient for solubility of O2 in water.
Implements equation 23 from ref. [2]. See reference [3]
Valid for temperatures between 273.15 K and 500 K

 * `Tk` Temperature in K
 * Output: k in atm/mol * 10^(-4)

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function henryk_O2(Tk)

    τ = 1000.0/Tk
    α = -0.0005943
    β = -0.1470
    γ = -0.05120
    δ = -0.1076
    ɛ = 0.8447
    a2 = α;
    a1 = γ*τ + δ
    a0 = β*τ*τ + ɛ*τ - 1.0

    10^( (-a1-sqrt(a1*a1 - 4.0*a2*a0)) / (2.0*a2))
end


"""
    henryk_N2(Tk)

Henry's coefficient for solubility of N2 in water.
Implements equation 23 from ref. [2]. See reference [3]
Valid for temperatures between 273.15 K and 500 K

 * `Tk` Temperature in K
 * Output: k in atm/mol * 10^(-4)

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function henryk_N2(Tk)

    τ = 1000.0/Tk
    α = -0.1021
    β = -0.1482
    γ = -0.019
    δ = -0.03741
    ɛ = 0.851
    a2 = α;
    a1 = γ*τ + δ
    a0 = β*τ*τ + ɛ*τ - 1.0

    10^( (-a1-sqrt(a1*a1 - 4.0*a2*a0)) / (2.0*a2))
end


"""
    henryk(Tk)

Henry's coefficient for solubility of air in water.
Implements equations 24 and 25 from ref. [2]. See reference [3]
Valid for temperatures between 273.15 K and 500 K

 * `Tk` Temperature in K
 * Output: k in atm/mol fract * 10^(-4)

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function henryk(Tk)

    kO2 = henryk_O2(Tk)
    kN2 = henryk_N2(Tk)
    xO2 = 0.22
    xN2 = 0.78

    k = 1.0 / (xO2/kO2 + xN2/kN2)

    1e-4/k * 1.0 /101325.0
end




"""
    ```molarvolumemoist```

Molar volume of moist air given the molar fraction of water vapor.
Assumes a real gas.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv`  Molar fraction of water vapor
 * Output: molar volume in m^3/mol

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
molarvolumemoist(Tk, P, xv) = Zmoist(Tk, P, xv) * R * Tk / P

"""
    ```volumemoist```

Specific volume of moist air given the molar fraction of water vapor.
Assumes a real gas. The specific volume is defined as the volume occupied
by a mixture of dry air and water vapor per kg of dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv`  Molar fraction of water vapor
 * Output: molar volume in m^3/kg of dry air.

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
volumemoist(Tk, P, xv) = molarvolumemoist(Tk,P,xv) / (Ma*(1-xv))


"""
    ```Zmoist(Tk, P, xv)```

Compressibility factor of moist air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv` molar fraction of water vapor.
 * Output: Z (nondimensional)

# Examples
```julia-repl
julia> Psychro.dCm(300, 0.01)
-1.680079338778261e-12
```
"""
function Zmoist(Tk, P, xv)

    vm0 = R*Tk/P
    b0 = Bm(Tk, xv)/vm0
    c0 = Cm(Tk, xv)/(vm0*vm0)
    
    return calcz(b0, c0)
end




"Coefficients a_i to calculate enthalpy of moist air ref[2]"
const a = (0.63290874e1, 0.28709015e2, 0.26431805e-2,
           -0.10405863e-4, 0.18660410e-7, -0.97843331e-11)
"Coefficients d_i to calculate enthalpy of moist air ref[2]"
const d = (-0.5008e-2, 0.32491829e2, 0.65576345e-2,
           -0.26442147e-4, 0.51751789e-7, -0.31541624e-10)

"""
    molarenthalpymoist(Tk, P, xv, EPS=1e-8, MAXITER=100)

Molar enthalphy of moist air defined as enthalpy dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv` molar fraction of water vapor.
 * Output: J/mol

"""
function molarenthalpymoist(Tk, P, xv)
    xa = 1.0-xv
    h1 = xa*(polyeval(Tk, a, 6) -7914.1982)
    h2 = xv*(polyeval(Tk, d, 6) + 35994.17)
    vm = molarvolumemoist(Tk, P, xv)
    h3 = R*Tk/vm * (Bm(Tk, xv) - Tk*dBm(Tk,xv)
                    + 1/vm*( Cm(Tk,xv) - 0.5*Tk*dCm(Tk,xv) ) )
    return (h1 + h2 + h3)
end


"""
    enthalpymoist(Tk, P, xv, EPS=1e-8, MAXITER=100)

Specific enthalphy of moist air defined as enthalpy per kg of
dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv` molar fraction of water vapor.
 * Output: J/kg of dry air

"""
function enthalpymoist(Tk, P, xv)
    hm = molarenthalpymoist(Tk, P, xv)
    return hm / ((1-xv)*Ma)
end



"Coefficients g_i to calculate enthalpy of moist air ref[2]"
const g = (0.34373874e2, 0.52863609e-2, -0.15608795e-4,
           0.24880547e-7, -0.12230416e-10, 0.28709015e2)
"Coefficients k_i to calculate enthalpy of moist air ref[2]"
const k = (0.2196603e1, 0.19743819e-1, -0.70128225e-4,
           0.14866252e-6, -0.14524437e-9, 0.55663583e-13,
           0.32284652e2)



"""
    molarentropymoist(Tk, P, xv)

Molar entropy of moist air defined as entropy per kg of
dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv` molar fraction of water vapor.

 * Output: J/mol/K of dry air

"""
function molarentropymoist(Tk, P, xv)
    xa = 1.0-xv
    h1 =  polyeval(Tk, g, 5) + g[6]*log(Tk) - 196.125465
    h2 =  polyeval(Tk, k, 6) + k[7]*log(Tk) - 63.31449

    z = Zmoist(Tk, P, xv)
    vm = z*R*Tk/P
    
    h3 = -R * log(P / 101325.0) + xa*R*log(z/xa)
    if xv > 1e-8
        h3 = h3 + xv*R*log(z/xv)
    end
    
    h4 = -R/vm * (  (Bm(Tk, xv) + Tk*dBm(Tk,xv)) + 0.5/vm*(Cm(Tk, xv) + Tk*dCm(Tk, xv)) )
    

    return (xa*h1 + xv*h2 + h3 + h4)
end

"""
    entropymoist(Tk, P, xv, EPS=1e-8, MAXITER=100)

Specific entropy of moist air defined as entropy per kg of
dry air.

 * `Tk` Temperature in K
 * `P` Pressure in Pa
 * `xv` molar fraction of water vapor.
 * Output: J/kg/K of dry air

"""
function entropymoist(Tk, P, xv)

    return molarentropymoist(Tk, P, xv) / ( (1-xv)*Ma )
    
end

    
