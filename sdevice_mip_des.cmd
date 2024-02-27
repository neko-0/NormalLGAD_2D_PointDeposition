
################################################################
# Charge deposition
################################################################

File {
    Grid = "n@node|sde@_LGAD_msh.tdr"
    Current = "n@node@_Current_MIP_LGAD"
    Plot = "n@node@_Plot_MIP_LGAD"
    Output = "n@node@_MIP_LGAD"
}


Electrode {
    {Name = "pad" Voltage=0 Material = "Aluminum"}
    {Name = "back_contact" Voltage=0 Material = "Aluminum"}
}

Physics{
	Fermi
	Temperature = @Temp@
	AreaFactor = 1
	Mobility(
		DopingDependence
		HighFieldSaturation
		Enormal(Lombardi)
        CarrierCarrierScattering
        Diffusivity
	)

	Recombination(
		SRH(DopingDependence TempDependence)
		SurfaceSRH
		Auger
		Band2Band
		Avalanche(vanOverstraeten)
	)

	EffectiveIntrinsicDensity(BandGapNarrowing(Slotboom))
}

Physics(Material="Silicon"){
    Fermi
	Temperature = @Temp@
	AreaFactor = 1
	Mobility(
		DopingDependence
		HighFieldSaturation
		Enormal(Lombardi)
        CarrierCarrierScattering
        Diffusivity
	)

	Recombination(
		SRH(DopingDependence TempDependence)
		SurfaceSRH
		Auger
		Band2Band
		Avalanche(vanOverstraeten)
	)

	EffectiveIntrinsicDensity(BandGapNarrowing(Slotboom))

    HeavyIon(
        #if [ string compare @direction@ "bot" ] == 0
            !(
                set center [expr @width@/2]
                puts "StartPoint=($center, @y_loc@, 0)"
            )!
            Direction=(0, -1)
            Length=@track_length@
        #endif

        #if [ string compare @direction@ "top" ] == 0
            !(
                set center [expr @width@/2]
                puts "StartPoint=($center, @y_loc@, 0)"
            )!
            Direction=(0, 1)
            Length=@track_length@
        #endif

        Time= 1e-9
        Wt_hi=0.5
        LET_f=@LET@
        *Exponential
        Gaussian
        PicoCoulomb
    )
}

Physics(MaterialInterface="Silicon/Oxide") {
    Traps((FixedCharge Conc=2.3e10))
}


Plot {
    TotalCurrent
    ConductionCurrent
    Current Current/Vector
    eCurrent eCurrent/Vector
    hCurrent hCurrent/Vector

    eDensity hDensity
    eVelocity hVelocity
    eMobility hMobility
    eDiffusivityMobility hDiffusivityMobility

    ElectricField ElectricField/Vector
    eEparallel hEparallel

    Potential
    SpaceCharge
    Doping
    DonorConcentration
    AcceptorConcentration

    AvalancheGeneration eAvalanche hAvalanche

    Auger
    AugerRecombination
    SRHRecombination
    TotalRecombination
    SurfaceRecombination

    HeavyIonChargeDensity
    HeavyIonGeneration
    HeavyIonCharge

    #MeanIonIntegral
    #eIonIntegral
    #hIonIntegral
    NonLocal
}

CurrentPlot {
    AvalancheGeneration(
        Integrate(Material="Silicon")
    )
    HeavyIonGeneration(
        Integrate(Material="Silicon")
    )
}

Math {
    *ExtendedPrecision(80)
    *ExtendedPrecision
    Digits=8
    Iterations=30
    Notdamped=1000

    Number_of_threads=6
    *NumberOfThreads=4
    *NumberOfAssemblyThreads=8

    Method=Pardiso
    *Method=blocked
    *SubMethod=Pardiso
    *Method=ILS
    *SubMethod=Pardiso
    *Pardiso ILS Super
    Transient=BE

    ParallelToInterfaceInBoundaryLayer(FullLayer)

    Extrapolate
    RelErrControl
    *RHSmin= 1e-8
    *RHSmax= 1e64
    *RHSFactor= 1e64

    Derivatives
    AvalDerivatives

    *CDensityMin (controlling the minimum current density for which impact ionization is considered)
    *CDensityMin=1e-30

    *when error is less than 1 or RHS min, accepting the solution
    *eDrForceRefDens=1e10
    *hDrForceRefDens=1e10

    Wallclock

    *RecBoxIntegr(1e-5 10 100) (1e-2 10 1000)
    RecBoxIntegr(1e-3 50 1000)

    ExitOnFailure
}



!(
	for {set x 0} {$x<@endBias@} {incr x 0 } {

		if { $x == 0 } {
			set x @startBias@
		} else {
            if { $x < 50 } {
                incr x 20
            } elseif { $x >= @TurnOnBias@ } {
                incr x 10
            } else {
                incr x 50
            }
            if { $x > @endBias@ } {
                set x @endBias@
            }
        }

		set final_t @final_t@

        puts "Solve {"
            puts "Load(FilePrefix = \"n@node|sdevice@_IV_LGAD_voltage_$x\V\")"
            puts "NewCurrentPrefix = \"n@node@_MIP_LGAD_$x\V_\""

            puts "Coupled(Iterations = 100){ Poisson Electron Hole }"

            puts "Transient ("
                puts "InitialTime = 0.0"
                puts "FinalTime = 0.9e-9"
                puts "InitialStep = 0.1e-9"
                puts "MaxStep = 0.3e-9"
                puts "MinStep = 1e-13"
                puts "Increment =1.5"
            puts "Decrement =1.5 )"
                puts "{ Coupled {Poisson Electron Hole} "
                puts "Plot (FilePrefix=\"n@node@_MIP_LGAD_part1_voltage_$x\V\" Time=(0.9e-9) NoOverwrite ) }"

                puts "Transient ("
                puts "InitialTime = 0.9e-9"
                puts "FinalTime = 1.1e-9"
                puts "InitialStep = 3e-12"
                puts "MaxStep = 5e-12"
                puts "MinStep = 1e-13"
                puts "Increment =1.5 "
            puts "Decrement =1.5 )"
                puts "{ Coupled {Poisson Electron Hole} "
                puts "Plot (FilePrefix=\"n@node@_MIP_LGAD_part2_voltage_$x\V\" Time=(Range=(1e-9,1.1e-9) intervals=10) NoOverwrite ) }"

            puts "Transient ("
                puts "InitialTime = 1.1e-9"
                puts "FinalTime = $final_t"
                puts "InitialStep = 1e-11"
                puts "MaxStep = 1e-10"
                puts "MinStep = 1e-13"
                puts "Increment =1.5 "
            puts "Decrement =1.5 )"
                #puts "{ Coupled (iterations=8, notdamped=15) {Poisson Electron Hole} "
                puts "{ Coupled {Poisson Electron Hole} "
                puts "Plot (FilePrefix=\"n@node@_MIP_LGAD_part3_voltage_$x\V\" Time=( 1.15e-9; 1.2e-9; 1.3e-9; 1.4e-9; 1.5e-9; 2e-9; 4e-9; 6e-9; 8e-9; 1e-8) NoOverwrite ) }"

		puts "}"
	}
)!
