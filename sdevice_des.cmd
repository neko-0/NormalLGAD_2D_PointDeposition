
################################################################
# Electrical boundaries (bias voltage) ramping
################################################################

File {
	Grid = "n@node|sde@_LGAD_msh.tdr"
	Current = "n@node@_Current_IV_LGAD"
	Plot = "n@node@_Plot_IV_LGAD"
	Output = "n@node@_IV_LGAD"
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
}

Physics(MaterialInterface="Silicon/Oxide") {
	Traps((FixedCharge Conc=2.3e10))
}


Plot {
	hCurrent/Vector
	eCurrent/Vector
	eCurrent
	hCurrent
	eDensity
	hDensity
	eMobility
	hMobility
	eVelocity
	hVelocity
	ElectricField
	ElectricField/Vector
	Potential
	Doping
	DonorConcentration
	AcceptorConcentration
	SpaceCharge
	srhRecombination
	AugerRecombination
	AvalancheGeneration
	TotalRecombination
	NonLocal
	SurfaceRecombination
	eIonIntegral
	hIonIntegral
	MeanIonIntegral
	eAlphaAvalanche
	hAlphaAvalanche
}

Math {
	*ExtendedPrecision
	*Digits=8
	Iterations=30
	Notdamped=1000

	Number_of_threads=6
	*NumberOfThreads=4
	*NumberOfAssemblyThreads=8

	Method=Pardiso
	*Method=blocked
	*SubMethod=Pardiso
	*Method=ILS
	*Pardiso ILS Super
	*Method = ILS(set=5)
	ILSrc= "set (5) {
		iterative(gmres(100), tolrel=1e-9, tolunprec=1e-4, tolabs=0, maxit=500);
		preconditioning(ilut(1e-7,-1), left);
		ordering(symmetric=nd, nonsymmetric=mpsilst);
		options(compact=yes, linscale=0, refineresidual=50, verbose=0); };
	"

	Transient=BE

	ParallelToInterfaceInBoundaryLayer(FullLayer)

	Extrapolate
	RelErrControl
	RHSmin= 1e-8
	*RHSmax= 1e64
	*RHSFactor= 1e64

	Derivatives
	*AvalDerivatives

	*CDensityMin (controlling the minimum current density for which impact ionization is considered)
  	*CDensityMin=1e-30

	*when error is less than 1 or RHS min, accepting the solution
	*eDrForceRefDens=1e10
	*hDrForceRefDens=1e10

	Wallclock

	BreakCriteria{
		Current(Contact="pad" Absval=1e-6)
		Current(Contact="back_contact" Absval=1e-6)
	}
	ExitOnFailure
}

Solve {
	#if @restore@ > 0
		Load(FilePrefix = "n@node|sdevice@_IV_LGAD_voltage_@restore@V")
	#endif

	Coupled(Iterations = 42 LineSearchDamping= 1e-8){ Poisson }
	Coupled(Iterations = 42 LineSearchDamping= 1e-8){ Poisson Electron Hole }

	!(
		#if @restore@ > 0
			set init_volt @restore@
		#else
			set init_volt 10
		#endif

		for {set x 0} {$x < @MaxBias@} {incr x 0} {
			if { $x == 0 } {
				set x $init_volt
			} else {
				if { $x < 50 } {
					incr x 20
				} elseif { $x >= @TurnOnBias@ } {
					incr x 10
				} else {
					incr x 50
				}
				if { $x > @MaxBias@ } {
					set x @MaxBias@
				}
			}
			puts "QuasiStationary("
			puts "InitialStep = 1e-2"
			puts "MaxStep = 2.0"
			puts "MinStep = 1e-9"
			puts "Increment = 1.1"
			puts "Decrement = 3.0"
			puts "Goal{ Name= \"back_contact\" Voltage = -$x }"
			puts ")"

			puts "{ Coupled{Poisson Electron Hole} }"
			puts "Plot(FilePrefix=\"n@node@_IV_LGAD_voltage_$x\V\" OverWrite Time=(Range=(0 1) Intervals=1))"

			puts "Save( FilePrefix = \"n@node@_IV_LGAD_voltage_$x\V\")"

		}
	)!
}
