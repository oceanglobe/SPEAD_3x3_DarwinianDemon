#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_TRAITS.h
C     !INTERFACE:
C #include DARWIN_TRAITS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C the parameters in this file are traits
C
C Requires: DARWIN_SIZE.h

C Replace nTrac by nTrac in all instances (:s/nTrac/nTrac/g)
C Can be reversed if necessary (Le Gland, 09/03/2021)

C--   COMMON /DARWIN_TRAITS_i/ Per-plankton traits (generated, maybe overwritten by data.traits)
C     isPhoto   :: 1: does photosynthesis, 0: not
C     bactType  :: 1: particle associated, 2: free living bacteria, 0: not bacteria
C     isAerobic :: 1: is aerobic bacteria (also set bactType), 0: not
C     isDenit   :: 1: is dentrifying bacteria (also set (bactType), 0: not
C     hasSi     :: 1: uses silica (Diatom), 0: not
C     hasPIC    :: 1: calcifying, 0: set R_PICPOC to zero
C     diazo     :: 1: use molecular instead of mineral nitrogen, 0: not
C     useNH4    :: 1: can use ammonia, 0: not
C     useNO2    :: 1: can use nitrite, 0: not
C     useNO3    :: 1: can use nitrate, 0: not
C     combNO    :: 1: combined nitrite/nitrate limitation, 0: not
C Traits of each species (Le Gland, 31/03/2021)
C     traitbvol :: 1: biovolume is variable, 0: biovolume is constant
C     traittopt :: 1: optimal temperature is variable, 0: constant
C     traitparopt :: 1: optimal irradiance is variable, 0: constant
C     isPrey    :: 1: can be grazed, 0: not
C     isPred    :: 1: can graze, 0: not
C     tempMort  :: 1: mortality is temperature dependent, 0: turn dependence off
C     tempMort2 :: 1: quadratic mortality is temperature dependent, 0: turn dependence off
C     tempGraz  :: 1: grazing is temperature dependent, 0: turn dependence off
      COMMON /DARWIN_TRAITS_i/
     &    isPhoto,
     &    bactType,
     &    isAerobic,
     &    isDenit,
     &    hasSi,
     &    hasPIC,
     &    diazo,
     &    useNH4,
     &    useNO2,
     &    useNO3,
     &    combNO,
C Traits of each species (Le Gland, 31/03/2021)
     &    traitbvol,
     &    traittopt,
     &    traitparopt,
     &    isPrey,
     &    isPred,
     &    tempMort,
     &    tempMort2,
     &    tempGraz
      INTEGER isPhoto(nTrac)
      INTEGER bactType(nTrac)
      INTEGER isAerobic(nTrac)
      INTEGER isDenit(nTrac)
      INTEGER hasSi(nTrac)
      INTEGER hasPIC(nTrac)
      INTEGER diazo(nTrac)
      INTEGER useNH4(nTrac)
      INTEGER useNO2(nTrac)
      INTEGER useNO3(nTrac)
      INTEGER combNO(nTrac)
C Traits of each species (Le Gland, 31/03/2021)
      INTEGER traitbvol(nplank)
      INTEGER traittopt(nplank)
      INTEGER traitparopt(nplank)
      INTEGER isPrey(nTrac)
      INTEGER isPred(nTrac)
      INTEGER tempMort(nTrac)
      INTEGER tempMort2(nTrac)
      INTEGER tempGraz(nTrac)

C--   COMMON /DARWIN_TRAITS_r/ Per-plankton traits (generated, maybe overwritten by data.traits)
C     Xmin               :: [mmol C m^-3]              minimum abundance for mortality, respiration and exudation
C     amminhib           :: [(mmol N m^-3)^-1]         coefficient for NH4 inhibition of NO uptake
C     acclimtimescl      :: [s^-1]                     rate of chlorophyll acclimation
C
C     mort               :: [s^-1]                     linear mortality rate
C     mort2              :: [(mmol C m^-3)^-1 s^-1]    quadratic mortality coefficient
C     ExportFracMort     :: []                         fraction of linear mortality to POM
C     ExportFracMort2    :: []                         fraction of quadratic mortality to POM
C     ExportFracExude    :: []                         fraction of exudation to POM
C
C- temperature dependence:
C     phytoTempCoeff     :: []                         see :numref:`pkg_darwin_temperature_params`
C     phytoTempExp1      :: [exp(1/degrees C)]         see :numref:`pkg_darwin_temperature_params`
C     phytoTempExp2      :: []                         see :numref:`pkg_darwin_temperature_params`
C     phytoTempOptimum   :: [degrees C]                see :numref:`pkg_darwin_temperature_params`
C Le Gland, 10/12/2020
C     phytoTempTol       :: [degrees C]                see :numref:`pkg_darwin_temperature_params`
C     phytoDecayPower    :: []                         see :numref:`pkg_darwin_temperature_params`
C
C     R_NC               :: [mmol N (mmol C)^-1]       nitrogen-carbon ratio (not used with DARWIN_ALLOW_NQUOTA)
C     R_PC               :: [mmol P (mmol C)^-1]       phosphorus-carbon ratio (not used with DARWIN_ALLOW_PQUOTA)
C     R_SiC              :: [mmol Si (mmol C)^-1]      silica-carbon ratio (not used with DARWIN_ALLOW_SIQUOTA)
C     R_FeC              :: [mmol Fe (mmol C)^-1]      iron-carbon ratio (not used with DARWIN_ALLOW_FEQUOTA)
C     R_ChlC             :: [mg Chl (mmol C)^-1]       chlorophyll-carbon ratio (not used with DARWIN_ALLOW_CHLQUOTA)
C     R_PICPOC           :: [mmol PIC (mmol POC)^-1]   inorganic-organic carbon ratio
C
C     biosink            :: [m s^-1]                   sinking velocity (positive downwards)
C     bioswim            :: [m s^-1]                   upward swimming velocity (positive upwards)
C
C     respRate           :: [s^-1]                     respiration rate
C     PCmax              :: [s^-1]                     maximum carbon-specific growth rate
C
C     Qnmax              :: [mmol N (mmol C)^-1]       maximum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
C     Qnmin              :: [mmol N (mmol C)^-1]       minimum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
C     Qpmax              :: [mmol P (mmol C)^-1]       maximum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
C     Qpmin              :: [mmol P (mmol C)^-1]       minimum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
C     Qsimax             :: [mmol Si (mmol C)^-1]      maximum silica quota (only with DARWIN_ALLOW_SIQUOTA)
C     Qsimin             :: [mmol Si (mmol C)^-1]      minimum silica quota (only with DARWIN_ALLOW_SIQUOTA)
C     Qfemax             :: [mmol Fe (mmol C)^-1]      maximum iron quota (only with DARWIN_ALLOW_FEQUOTA)
C     Qfemin             :: [mmol Fe (mmol C)^-1]      minimum iron quota (only with DARWIN_ALLOW_FEQUOTA)
C
C     VmaxNH4            :: [mmol N (mmol C)^-1 s^-1]  maximum ammonia uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxNO2            :: [mmol N (mmol C)^-1 s^-1]  maximum nitrite uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxNO3            :: [mmol N (mmol C)^-1 s^-1]  maximum nitrate uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxN              :: [mmol N (mmol C)^-1 s^-1]  maximum nitrogen uptake rate for diazotrophs (only with DARWIN_ALLOW_NQUOTA)
C                        ::                            has to be >= vmaxNO3 + vmaxNO2 + vmaxNH4
C     VmaxPO4            :: [mmol P (mmol C)^-1 s^-1]  maximum phosphate uptake rate (only with DARWIN_ALLOW_PQUOTA)
C     VmaxSiO2           :: [mmol Si (mmol C)^-1 s^-1] maximum silica uptake rate (only with DARWIN_ALLOW_SIQUOTA)
C     VmaxFeT            :: [mmol Fe (mmol C)^-1 s^-1] maximum iron uptake rate (only with DARWIN_ALLOW_FEQUOTA)
C
C     ksatNH4            :: [mmol N m^-3]              half-saturation conc. for ammonia uptake/limitation
C     ksatNO2            :: [mmol N m^-3]              half-saturation conc. for nitrite uptake/limitation
C     ksatNO3            :: [mmol N m^-3]              half-saturation conc. for nitrate uptake/limitation
C     ksatPO4            :: [mmol P m^-3]              half-saturation conc. for phosphate uptake/limitation
C     ksatSiO2           :: [mmol Si m^-3]             half-saturation conc. for silica uptake/limitation
C     ksatFeT            :: [mmol Fe m^-3]             half-saturation conc. for iron uptake/limitation
C
C     kexcc              :: [s^-1]                 exudation rate for carbon
C     kexcn              :: [s^-1]                 exudation rate for nitrogen
C     kexcp              :: [s^-1]                 exudation rate for phosphorus
C     kexcsi             :: [s^-1]                 exudation rate for silica
C     kexcfe             :: [s^-1]                 exudation rate for iron
C
C- Geider
C     inhibGeider        :: []                     photo-inhibition coefficient for Geider growth
C- not Geider
C     ksatPAR            :: [(uEin m^-2 s^-1)^-1]  saturation coefficient for PAR (w/o GEIDER)
C     kinhPAR            :: [(uEin m^-2 s^-1)^-1]  inhibition coefficient for PAR (w/o GEIDER)
C     PARopt             :: [W m^-2]               optimal irradiance
C     PARchi             :: []                     photoinhibition factor
C- always defined
C     mQyield            :: [mmol C (uEin)^-1]     maximum quantum yield
C     chl2cmax           :: [mg Chl (mmol C)^-1]   maximum Chlorophyll-carbon ratio
C
C- Grazing
C     grazemax           :: [s^-1]          maximum grazing rate
C     kgrazesat          :: [mmol C m^-3]   grazing half-saturation concentration
C     palat              :: []              palatability matrix
C     asseff             :: []              assimilation efficiency matrix
C     ExportFracPreyPred :: []              fraction of unassimilated prey becoming particulate organic matter
C
C- Bacteria
C     yield              :: []              bacterial growth yield for all organic matter
C     yieldO2            :: []              bacterial growth yield for oxygen
C     yieldNO3           :: []              bacterial growth yield for nitrate
C     ksatPON            :: [mmol N m^-3]   half-saturation of PON for bacterial growth
C     ksatPOC            :: [mmol C m^-3]   half-saturation of POC for bacterial growth
C     ksatPOP            :: [mmol P m^-3]   half-saturation of POP for bacterial growth
C     ksatPOFe           :: [mmol Fe m^-3]  half-saturation of POFe for bacterial growth
C     ksatDON            :: [mmol N m^-3]   half-saturation of DON for bacterial growth
C     ksatDOC            :: [mmol C m^-3]   half-saturation of DOC for bacterial growth
C     ksatDOP            :: [mmol P m^-3]   half-saturation of DOP for bacterial growth
C     ksatDOFe           :: [mmol Fe m^-3]  half-saturation of DOFe for bacterial growth
      COMMON /DARWIN_TRAITS_r/
     &    Xmin,
     &    amminhib,
     &    acclimtimescl,
     &    mort,
     &    mort2,
     &    ExportFracMort,
     &    ExportFracMort2,
     &    ExportFracExude,
     &    phytoTempCoeff,
     &    phytoTempExp1,
     &    phytoTempExp2,
     &    phytoTempOptimum,
C Le Gland, 10/12/2020
     &    phytoTempTol,
     &    phytoDecayPower,
     &    R_NC,
     &    R_PC,
     &    R_SiC,
     &    R_FeC,
     &    R_ChlC,
     &    R_PICPOC,
     &    biosink,
     &    bioswim,
     &    respRate,
     &    PCmax,
     &    Qnmax,
     &    Qnmin,
     &    Qpmax,
     &    Qpmin,
     &    Qsimax,
     &    Qsimin,
     &    Qfemax,
     &    Qfemin,
     &    VmaxNH4,
     &    VmaxNO2,
     &    VmaxNO3,
     &    VmaxN,
     &    VmaxPO4,
     &    VmaxSiO2,
     &    VmaxFeT,
     &    ksatNH4,
     &    ksatNO2,
     &    ksatNO3,
     &    ksatPO4,
     &    ksatSiO2,
     &    ksatFeT,
     &    kexcc,
     &    kexcn,
     &    kexcp,
     &    kexcsi,
     &    kexcfe,
#ifdef DARWIN_ALLOW_GEIDER
     &    inhibGeider,
#else
     &    ksatPAR,
     &    kinhPAR,
     &    PARopt,
     &    PARchi,
#endif
#ifdef SPEAD_ALLOW_TRAITS
C Mutation rate of each species (Le Gland, 31/03/2021)
     &    numut_tr,
C Reference trait values for each species (Le Gland, 14/05/2021)
     &    ref_tr,
C Minimum and maximum trait values, maximum variance (Le Gland, 07/06/2021)
     &    min_tr,
     &    max_tr,
     &    max_vr_tr,
#endif
     &    mQyield,
     &    chl2cmax,
     &    grazemax,
     &    kgrazesat,
     &    palat,
     &    asseff,
     &    ExportFracPreyPred,
     &    yield,
     &    yieldO2,
     &    yieldNO3,
     &    ksatPON,
     &    ksatPOC,
     &    ksatPOP,
     &    ksatPOFe,
     &    ksatDON,
     &    ksatDOC,
     &    ksatDOP,
     &    ksatDOFe
      _RL Xmin(nTrac)
      _RL amminhib(nTrac)
      _RL acclimtimescl(nTrac)
      _RL mort(nTrac)
      _RL mort2(nTrac)
      _RL ExportFracMort(nTrac)
      _RL ExportFracMort2(nTrac)
      _RL ExportFracExude(nTrac)
      _RL phytoTempCoeff(nTrac)
      _RL phytoTempExp1(nTrac)
      _RL phytoTempExp2(nTrac)
      _RL phytoTempOptimum(nTrac)
C Le Gland, 10/12/2020
      _RL phytoTempTol(nTrac)
      _RL phytoDecayPower(nTrac)
      _RL R_NC(nTrac)
      _RL R_PC(nTrac)
      _RL R_SiC(nTrac)
      _RL R_FeC(nTrac)
      _RL R_ChlC(nTrac)
      _RL R_PICPOC(nTrac)
      _RL biosink(nTrac)
      _RL bioswim(nTrac)
      _RL respRate(nTrac)
      _RL PCmax(nTrac)
      _RL Qnmax(nTrac)
      _RL Qnmin(nTrac)
      _RL Qpmax(nTrac)
      _RL Qpmin(nTrac)
      _RL Qsimax(nTrac)
      _RL Qsimin(nTrac)
      _RL Qfemax(nTrac)
      _RL Qfemin(nTrac)
      _RL VmaxNH4(nTrac)
      _RL VmaxNO2(nTrac)
      _RL VmaxNO3(nTrac)
      _RL VmaxN(nTrac)
      _RL VmaxPO4(nTrac)
      _RL VmaxSiO2(nTrac)
      _RL VmaxFeT(nTrac)
      _RL ksatNH4(nTrac)
      _RL ksatNO2(nTrac)
      _RL ksatNO3(nTrac)
      _RL ksatPO4(nTrac)
      _RL ksatSiO2(nTrac)
      _RL ksatFeT(nTrac)
      _RL kexcc(nTrac)
      _RL kexcn(nTrac)
      _RL kexcp(nTrac)
      _RL kexcsi(nTrac)
      _RL kexcfe(nTrac)
#ifdef DARWIN_ALLOW_GEIDER
      _RL inhibGeider(nTrac)
#else
      _RL ksatPAR(nTrac)
      _RL kinhPAR(nTrac)
      _RL PARopt(nTrac)
      _RL PARchi(nTrac)
#endif
#ifdef SPEAD_ALLOW_TRAITS
C Mutation rate of each species (Le Gland, 31/03/2021)
      _RL numut_tr(nplank,nTrait)
C Reference trait values for each species (Le Gland, 14/05/2021)
      _RL ref_tr(nplank,nTrait)
C Minimum and maximum trait values, maximum variance (Le Gland, 07/06/2021)
      _RL min_tr(nplank,nTrait)
      _RL max_tr(nplank,nTrait)
      _RL max_vr_tr(nplank,nTrait)
#endif
      _RL mQyield(nTrac)
      _RL chl2cmax(nTrac)
      _RL grazemax(nTrac)
      _RL kgrazesat(nTrac)
      _RL palat(nTrac,nTrac)
      _RL asseff(nTrac,nTrac)
      _RL ExportFracPreyPred(nTrac,nTrac)
      _RL yield(nTrac)
      _RL yieldO2(nTrac)
      _RL yieldNO3(nTrac)
      _RL ksatPON(nTrac)
      _RL ksatPOC(nTrac)
      _RL ksatPOP(nTrac)
      _RL ksatPOFe(nTrac)
      _RL ksatDON(nTrac)
      _RL ksatDOC(nTrac)
      _RL ksatDOP(nTrac)
      _RL ksatDOFe(nTrac)

C--   COMMON /DARWIN_DEPENDENT_TRAITS_i/ Dependent and constant (not read-in) parameters
C     group  :: which group this type belongs to
C     plank  :: which species this type belongs to (Le Gland, 11/03/2021)
C     igroup :: index within group
C     jgroup :: index for topt (Le Gland, 10/12/2020)
C     jgroup is useless in the continuous model (Le Gland, 13/01/2021)
C     num_trait :: number of traits for each species (Le Gland, 26/03/2021)
C     num_cov :: number of covariances for each species (Le Gland, 26/03/2021)
C
C- Radtrans only:
C     aptype :: optical type (for absorption/scattering spectra)
      COMMON /DARWIN_DEPENDENT_TRAITS_i/
#ifdef ALLOW_RADTRANS
     &    aptype,
#endif
     &    group,
C Le Gland, 11/03/2021
     &    plank,
C Le Gland, 10/12/2020
C    &    igroup,
C    &    jgroup
C Le Gland, 09/03/2021
     &    iplank,
C Le Gland, 26/03/2021
     &    num_trait,
     &    num_cov
#ifdef ALLOW_RADTRANS
      INTEGER aptype(nTrac)
#endif
      INTEGER group(nTrac)
C Le Gland, 11/03/2021
      INTEGER plank(nTrac)
C     INTEGER igroup(nTrac)
C Le Gland, 10/12/2020
C     INTEGER jgroup(nTrac)
C Le Gland, 09/03/2021
      INTEGER iplank(nplank)
C Le Gland, 26/03/2021
      INTEGER num_trait(nplank)
      INTEGER num_cov(nplank)

C--   COMMON /DARWIN_DEPENDENT_TRAITS_r/ Dependent and constant (not read-in) parameters
C     normI            :: []                    normalization factor for non-Geider light curve
C     biovol           :: [um^3]                volume
C     qcarbon          :: [mmol C/cell]         cellular carbon content
C     biovol_bygroup   :: [um^3]                volume of types in each group
C     Topt_bygroup     :: [°C]                  optimal temperature of types in each group
C     chl2cmin         :: [mg Chl (mmol C)^-1]  minimum Chl:C ratio (function of chl2cmax and alpha_mean)
C     alpha_mean       :: [mmol C s-1 (uEin m^-2 s^-1)^-1 (mg Chl)^-1]  mean initial slope of light curve (over wavebands)
      COMMON /DARWIN_DEPENDENT_TRAITS_r/
#ifndef DARWIN_ALLOW_GEIDER
     &    normI,
#endif
     &    biovol,
     &    qcarbon,
C    &    biovol_bygroup,
C    &    Topt_bygroup,
     &    alpha_mean,
     &    chl2cmin
#ifndef DARWIN_ALLOW_GEIDER
      _RL normI(nTrac)
#endif
      _RL biovol(nTrac)
      _RL qcarbon(nTrac)
C     _RL biovol_bygroup(nTrac,ngroup)
C Le Gland, 10/12/2020
C     _RL Topt_bygroup(nTrac,ngroup)
      _RL alpha_mean(nTrac)
      _RL chl2cmin(nTrac)


#endif /* ALLOW_DARWIN */

