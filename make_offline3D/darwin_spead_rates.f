

















C $Header: /u/gcmpack/MITgcm/model/inc/CPP_OPTIONS.h,v 1.51 2012/11/09 22:29:32 jmc Exp $
C $Name:  $


CBOP
C !ROUTINE: CPP_OPTIONS.h
C !INTERFACE:
C #include "CPP_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | main CPP options file for the model:
C | Control which optional features to compile in model/src code.
C *==================================================================*
CEOP

C CPP flags controlling particular source code features

C o Shortwave heating as extra term in external_forcing.F
C Note: this should be a run-time option

C o Include/exclude phi_hyd calculation code

C o Include/exclude call to S/R CONVECT

C o Include/exclude call to S/R CALC_DIFFUSIVITY

C o Allow full 3D specification of vertical diffusivity

C o Allow latitudinally varying BryanLewis79 vertical diffusivity

C o Include/exclude Implicit vertical advection code

C o Include/exclude AdamsBashforth-3rd-Order code

C o Include/exclude nonHydrostatic code

C o Allow to account for heating due to friction (and momentum dissipation)

C o Allow mass source or sink of Fluid in the interior
C   (3-D generalisation of oceanic real-fresh water flux)

C o Include pressure loading code

C o exclude/allow external forcing-fields load
C   this allows to read & do simple linear time interpolation of oceanic
C   forcing fields, if no specific pkg (e.g., EXF) is used to compute them.

C o Include/exclude balancing surface forcing fluxes code

C o Include/exclude balancing surface forcing relaxation code

C o Include/exclude GM-like eddy stress in momentum code

C o Use "Exact Convervation" of fluid in Free-Surface formulation
C   so that d/dt(eta) is exactly equal to - Div.Transport

C o Allow the use of Non-Linear Free-Surface formulation
C   this implies that surface thickness (hFactors) vary with time

C o Include/exclude code for single reduction Conjugate-Gradient solver

C o Choices for implicit solver routines solve_*diagonal.F
C   The following has low memory footprint, but not suitable for AD
C   The following one suitable for AD but does not vectorize

C o ALLOW isotropic scaling of harmonic and bi-harmonic terms when
C   using an locally isotropic spherical grid with (dlambda) x (dphi*cos(phi))
C *only for use on a lat-lon grid*
C   Setting this flag here affects both momentum and tracer equation unless
C   it is set/unset again in other header fields (e.g., GAD_OPTIONS.h).
C   The definition of the flag is commented to avoid interference with
C   such other header files.
C   The preferred method is specifying a value for viscAhGrid or viscA4Grid
C   in data which is then automatically scaled by the grid size;
C   the old method of specifying viscAh/viscA4 and this flag is provided
C   for completeness only (and for use with the adjoint).
C#define ISOTROPIC_COS_SCALING

C o This flag selects the form of COSINE(lat) scaling of bi-harmonic term.
C *only for use on a lat-lon grid*
C   Has no effect if ISOTROPIC_COS_SCALING is undefined.
C   Has no effect on vector invariant momentum equations.
C   Setting this flag here affects both momentum and tracer equation unless
C   it is set/unset again in other header fields (e.g., GAD_OPTIONS.h).
C   The definition of the flag is commented to avoid interference with
C   such other header files.
C#define COSINEMETH_III

C o Use "OLD" UV discretisation near boundaries (*not* recommended)
C   Note - only works with  #undef NO_SLIP_LATERAL  in calc_mom_rhs.F
C          because the old code did not have no-slip BCs

C o Use LONG.bin, LATG.bin, etc., initialization for ini_curviliear_grid.F
C   Default is to use "new" grid files (OLD_GRID_IO undef) but OLD_GRID_IO
C   is still useful with, e.g., single-domain curvilinear configurations.

C o Execution environment support options
CBOP
C     !ROUTINE: CPP_EEOPTIONS.h
C     !INTERFACE:
C     include "CPP_EEOPTIONS.h"
C
C     !DESCRIPTION:
C     *==========================================================*
C     | CPP\_EEOPTIONS.h                                         |
C     *==========================================================*
C     | C preprocessor "execution environment" supporting        |
C     | flags. Use this file to set flags controlling the        |
C     | execution environment in which a model runs - as opposed |
C     | to the dynamical problem the model solves.               |
C     | Note: Many options are implemented with both compile time|
C     |       and run-time switches. This allows options to be   |
C     |       removed altogether, made optional at run-time or   |
C     |       to be permanently enabled. This convention helps   |
C     |       with the data-dependence analysis performed by the |
C     |       adjoint model compiler. This data dependency       |
C     |       analysis can be upset by runtime switches that it  |
C     |       is unable to recoginise as being fixed for the     |
C     |       duration of an integration.                        |
C     |       A reasonable way to use these flags is to          |
C     |       set all options as selectable at runtime but then  |
C     |       once an experimental configuration has been        |
C     |       identified, rebuild the code with the appropriate  |
C     |       options set at compile time.                       |
C     *==========================================================*
CEOP


C     In general the following convention applies:
C     ALLOW  - indicates an feature will be included but it may
C     CAN      have a run-time flag to allow it to be switched
C              on and off.
C              If ALLOW or CAN directives are "undef'd" this generally
C              means that the feature will not be available i.e. it
C              will not be included in the compiled code and so no
C              run-time option to use the feature will be available.
C
C     ALWAYS - indicates the choice will be fixed at compile time
C              so no run-time option will be present

C=== Macro related options ===
C--   Control storage of floating point operands
C     On many systems it improves performance only to use
C     8-byte precision for time stepped variables.
C     Constant in time terms ( geometric factors etc.. )
C     can use 4-byte precision, reducing memory utilisation and
C     boosting performance because of a smaller working set size.
C     However, on vector CRAY systems this degrades performance.
C     Enable to switch REAL4_IS_SLOW from genmake2 (with LET_RS_BE_REAL4):

C--   Control use of "double" precision constants.
C     Use D0 where it means REAL*8 but not where it means REAL*16

C--   Enable some old macro conventions for backward compatibility

C=== IO related options ===
C--   Flag used to indicate whether Fortran formatted write
C     and read are threadsafe. On SGI the routines can be thread
C     safe, on Sun it is not possible - if you are unsure then
C     undef this option.

C--   Flag used to indicate whether Binary write to Local file (i.e.,
C     a different file for each tile) and read are thread-safe.

C--   Flag to turn off the writing of error message to ioUnit zero

C--   Alternative formulation of BYTESWAP, faster than
C     compiler flag -byteswapio on the Altix.

C--   Flag to turn on old default of opening scratch files with the
C     STATUS='SCRATCH' option. This method, while perfectly FORTRAN-standard,
C     caused filename conflicts on some multi-node/multi-processor platforms
C     in the past and has been replace by something (hopefully) more robust.

C--   Flag defined for eeboot_minimal.F, eeset_parms.F and open_copy_data_file.F
C     to write STDOUT, STDERR and scratch files from process 0 only.
C WARNING: to use only when absolutely confident that the setup is working
C     since any message (error/warning/print) from any proc <> 0 will be lost.

C=== MPI, EXCH and GLOBAL_SUM related options ===
C--   Flag turns off MPI_SEND ready_to_receive polling in the
C     gather_* subroutines to speed up integrations.

C--   Control MPI based parallel processing
CXXX We no longer select the use of MPI via this file (CPP_EEOPTIONS.h)
CXXX To use MPI, use an appropriate genmake2 options file or use
CXXX genmake2 -mpi .
CXXX #undef  1

C--   Control use of communication that might overlap computation.
C     Under MPI selects/deselects "non-blocking" sends and receives.
C--   Control use of communication that is atomic to computation.
C     Under MPI selects/deselects "blocking" sends and receives.

C--   Control XY periodicity in processor to grid mappings
C     Note: Model code does not need to know whether a domain is
C           periodic because it has overlap regions for every box.
C           Model assume that these values have been
C           filled in some way.

C--   disconnect tiles (no exchange between tiles, just fill-in edges
C     assuming locally periodic subdomain)

C--   Always cumulate tile local-sum in the same order by applying MPI allreduce
C     to array of tiles ; can get slower with large number of tiles (big set-up)

C--   Alternative way of doing global sum without MPI allreduce call
C     but instead, explicit MPI send & recv calls. Expected to be slower.

C--   Alternative way of doing global sum on a single CPU
C     to eliminate tiling-dependent roundoff errors. Note: This is slow.

C=== Other options (to add/remove pieces of code) ===
C--   Flag to turn on checking for errors from all threads and procs
C     (calling S/R STOP_IF_ERROR) before stopping.

C--   Control use of communication with other component:
C     allow to import and export from/to Coupler interface.

C--   Activate some pieces of code for coupling to GEOS AGCM


CBOP
C     !ROUTINE: CPP_EEMACROS.h
C     !INTERFACE:
C     include "CPP_EEMACROS.h"
C     !DESCRIPTION:
C     *==========================================================*
C     | CPP_EEMACROS.h
C     *==========================================================*
C     | C preprocessor "execution environment" supporting
C     | macros. Use this file to define macros for  simplifying
C     | execution environment in which a model runs - as opposed
C     | to the dynamical problem the model solves.
C     *==========================================================*
CEOP


C     In general the following convention applies:
C     ALLOW  - indicates an feature will be included but it may
C     CAN      have a run-time flag to allow it to be switched
C              on and off.
C              If ALLOW or CAN directives are "undef'd" this generally
C              means that the feature will not be available i.e. it
C              will not be included in the compiled code and so no
C              run-time option to use the feature will be available.
C
C     ALWAYS - indicates the choice will be fixed at compile time
C              so no run-time option will be present

C     Flag used to indicate which flavour of multi-threading
C     compiler directives to use. Only set one of these.
C     USE_SOLARIS_THREADING  - Takes directives for SUN Workshop
C                              compiler.
C     USE_KAP_THREADING      - Takes directives for Kuck and
C                              Associates multi-threading compiler
C                              ( used on Digital platforms ).
C     USE_IRIX_THREADING     - Takes directives for SGI MIPS
C                              Pro Fortran compiler.
C     USE_EXEMPLAR_THREADING - Takes directives for HP SPP series
C                              compiler.
C     USE_C90_THREADING      - Takes directives for CRAY/SGI C90
C                              system F90 compiler.






C--   Define the mapping for the _BARRIER macro
C     On some systems low-level hardware support can be accessed through
C     compiler directives here.

C--   Define the mapping for the BEGIN_CRIT() and  END_CRIT() macros.
C     On some systems we simply execute this section only using the
C     master thread i.e. its not really a critical section. We can
C     do this because we do not use critical sections in any critical
C     sections of our code!

C--   Define the mapping for the BEGIN_MASTER_SECTION() and
C     END_MASTER_SECTION() macros. These are generally implemented by
C     simply choosing a particular thread to be "the master" and have
C     it alone execute the BEGIN_MASTER..., END_MASTER.. sections.

CcnhDebugStarts
C      Alternate form to the above macros that increments (decrements) a counter each
C      time a MASTER section is entered (exited). This counter can then be checked in barrier
C      to try and detect calls to BARRIER within single threaded sections.
C      Using these macros requires two changes to Makefile - these changes are written
C      below.
C      1 - add a filter to the CPP command to kill off commented _MASTER lines
C      2 - add a filter to the CPP output the converts the string N EWLINE to an actual newline.
C      The N EWLINE needs to be changes to have no space when this macro and Makefile changes
C      are used. Its in here with a space to stop it getting parsed by the CPP stage in these
C      comments.
C      #define IF ( a .EQ. 1 ) THEN  IF ( a .EQ. 1 ) THEN  N EWLINE      CALL BARRIER_MS(a)
C      #define ENDIF    CALL BARRIER_MU(a) N EWLINE        ENDIF
C      'CPP = cat $< | $(TOOLSDIR)/set64bitConst.sh |  grep -v '^[cC].*_MASTER' | cpp  -traditional -P'
C      .F.f:
C      $(CPP) $(DEFINES) $(INCLUDES) |  sed 's/N EWLINE/\n/' > $@
CcnhDebugEnds

C--   Control storage of floating point operands
C     On many systems it improves performance only to use
C     8-byte precision for time stepped variables.
C     Constant in time terms ( geometric factors etc.. )
C     can use 4-byte precision, reducing memory utilisation and
C     boosting performance because of a smaller working
C     set size. However, on vector CRAY systems this degrades
C     performance.
C- Note: global_sum/max macros were used to switch to  JAM routines (obsolete);
C  in addition, since only the R4 & R8 S/R are coded, GLOBAL RS & RL macros
C  enable to call the corresponding R4 or R8 S/R.



C- Note: a) exch macros were used to switch to  JAM routines (obsolete)
C        b) exch R4 & R8 macros are not practically used ; if needed,
C           will directly call the corrresponding S/R.

C--   Control use of JAM routines for Artic network (no longer supported)
C     These invoke optimized versions of "exchange" and "sum" that
C     utilize the programmable aspect of Artic cards.
CXXX No longer supported ; started to remove JAM routines.
CXXX #ifdef LETS_MAKE_JAM
CXXX #define CALL GLOBAL_SUM_R8 ( a, b) CALL GLOBAL_SUM_R8_JAM ( a, b)
CXXX #define CALL GLOBAL_SUM_R8 ( a, b ) CALL GLOBAL_SUM_R8_JAM ( a, b )
CXXX #define CALL EXCH_XY_RS ( a, b ) CALL EXCH_XY_R8_JAM ( a, b )
CXXX #define CALL EXCH_XY_RL ( a, b ) CALL EXCH_XY_R8_JAM ( a, b )
CXXX #define CALL EXCH_XYZ_RS ( a, b ) CALL EXCH_XYZ_R8_JAM ( a, b )
CXXX #define CALL EXCH_XYZ_RL ( a, b ) CALL EXCH_XYZ_R8_JAM ( a, b )
CXXX #endif

C--   Control use of "double" precision constants.
C     Use d0 where it means REAL*8 but not where it means REAL*16

C--   Substitue for 1.D variables
C     Sun compilers do not use 8-byte precision for literals
C     unless .Dnn is specified. CRAY vector machines use 16-byte
C     precision when they see .Dnn which runs very slowly!

C--   Set the format for writing processor IDs, e.g. in S/R eeset_parms
C     and S/R open_copy_data_file. The default of I9.9 should work for
C     a long time (until we will use 10e10 processors and more)



C o Include/exclude single header file containing multiple packages options
C   (AUTODIFF, COST, CTRL, ECCO, EXF ...) instead of the standard way where
C   each of the above pkg get its own options from its specific option file.
C   Although this method, inherited from ECCO setup, has been traditionally
C   used for all adjoint built, work is in progress to allow to use the
C   standard method also for adjoint built.
c#ifdef 
c# include "ECCO_CPPOPTIONS.h"
c#endif


CBOP
C    !ROUTINE: DARWIN_OPTIONS.h
C    !INTERFACE:

C    !DESCRIPTION:
C options for darwin package
CEOP

C tracer selection

C enable (or disable) nitrogen quotas for all plankton

C enable (or disable) phosphorus quotas for all plankton

C enable (or disable) iron quotas for all plankton

C enable (or disable) silica quotas for all plankton

C enable (or disable) chlorophyll quotas for all phototrophs

C enable (or disable) a dynamic CDOM tracer

C enable (or disable) air-sea carbon exchange and Alk and O2 tracers

C optional bits

C enable (or disable) denitrification code

C enable (or disable) separate exudation of individual elements

C enable (or disable) old virtualflux code for DIC and Alk

C reduce nitrate uptake by iron limitation factor

C allow organic matter to sink into bottom (sedimentize)


C light

C compute average PAR in layer, assuming exponential decay
C (ignored when radtrans package is used)

C enable (or disable) GEIDER light code

C use rho instead of acclimated Chl:C for chlorophyll synthesis

C initialize chl as in darwin2 (with radtrans package)

C scattering coefficients are per Chlorophyll (with radtrans package)

C make diagnostics for instrinsic optical properties available


C grazing

C for quadratic grazing as in darwin2+quota

C compute palat from size ratios

C turn off grazing temperature dependence

C temperature

C turn off all temperature dependence

C select temperature version: 1, 2 or 3

C restrict phytoplankton growth to a temperature range


C iron

C restrict maximum free iron

C enable particle scavenging code

C enable variable iron sediment source

C revert to old variable iron sediment source in terms of POP

C diagnostics

C include code for per-type diagnostics


C debugging

C turn on debugging output

C compute and print global element totals

C value for unused traits


C deprecated

C base particle scavenging on POP as in darwin2


C random trait generation
C these are for darwin_generate_random
C assign traits based on random numbers as in darwin2

C set traits for darwin2 2-species setup (requires DARWIN_RANDOM_TRAITS)

C set traits for darwin2 9-species setup (requires DARWIN_RANDOM_TRAITS)

C enable diazotrophy when using (requires DARWIN_RANDOM_TRAITS)

C Traits (Le Gland, 26/03/2021)
C If defined, ntrait must be superior or equal to 1
C If defined, ntrait must be superior or equal to 2

C If defined the phytoplankton is a Darwian Demon


CBOP
C !ROUTINE: DARWIN_SPEAD_RATES
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_SPEAD_RATES(
     I     PAR,temp,
     I     myTime,myIter,myThid,
     I     DIC,NH4,NO2,NO3,PO4,SiO2,FeT,DOC,DON,DOP,DOFe,
     I     PIC,POC,PON,POP,POSi,POFe,
     O     chlout,diags,
     O     dDIC,dNH4,dNO2,dNO3,dPO4,dSiO2,dFeT,
     O     dDOC,dDON,dDOP,dDOFe,
     O     dPIC,dPOC,dPON,dPOP,dPOSi,dPOFe,
     I     iG, jG, k, dT,
     I     O2,ALK,
     O     dO2,dALK,
C    I     X,mn_bvol,mn_topt,vr_bvol_vr_topt,cv_bvto,
     I     X,
     I     mn_tr,vr_tr,
     I     cv_tr,
C    O     g00,g10,g01,g20,g02,g11,
C    O     g00,g20,g02,g11,
C    O     gcom,acom,
C    O     a00,a10,a01,a20,a02,a11)
     O     gcom,
     O     a_0,a_d1,a_d2,
     O     a_d11,
     O     coeff_KTW,
     O     acom)

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
CBOP
C     !ROUTINE: EEPARAMS.h
C     !INTERFACE:
C     include "EEPARAMS.h"
C
C     !DESCRIPTION:
C     *==========================================================*
C     | EEPARAMS.h                                               |
C     *==========================================================*
C     | Parameters for "execution environemnt". These are used   |
C     | by both the particular numerical model and the execution |
C     | environment support routines.                            |
C     *==========================================================*
CEOP

C     ========  EESIZE.h  ========================================

C     MAX_LEN_MBUF  :: Default message buffer max. size
C     MAX_LEN_FNAM  :: Default file name max. size
C     MAX_LEN_PREC  :: Default rec len for reading "parameter" files

      INTEGER MAX_LEN_MBUF
      PARAMETER ( MAX_LEN_MBUF = 512 )
      INTEGER MAX_LEN_FNAM
      PARAMETER ( MAX_LEN_FNAM = 512 )
      INTEGER MAX_LEN_PREC
      PARAMETER ( MAX_LEN_PREC = 200 )

C     MAX_NO_THREADS  :: Maximum number of threads allowed.
CC    MAX_NO_PROCS    :: Maximum number of processes allowed.
CC    MAX_NO_BARRIERS :: Maximum number of distinct thread "barriers"
      INTEGER MAX_NO_THREADS
      PARAMETER ( MAX_NO_THREADS =  4 )
c     INTEGER MAX_NO_PROCS
c     PARAMETER ( MAX_NO_PROCS   =  70000 )
c     INTEGER MAX_NO_BARRIERS
c     PARAMETER ( MAX_NO_BARRIERS = 1 )

C     Particularly weird and obscure voodoo numbers
C     lShare :: This wants to be the length in
C               [148]-byte words of the size of
C               the address "window" that is snooped
C               on an SMP bus. By separating elements in
C               the global sum buffer we can avoid generating
C               extraneous invalidate traffic between
C               processors. The length of this window is usually
C               a cache line i.e. small O(64 bytes).
C               The buffer arrays are usually short arrays
C               and are declared REAL ARRA(lShare[148],LBUFF).
C               Setting lShare[148] to 1 is like making these arrays
C               one dimensional.
      INTEGER cacheLineSize
      INTEGER lShare1
      INTEGER lShare4
      INTEGER lShare8
      PARAMETER ( cacheLineSize = 256 )
      PARAMETER ( lShare1 =  cacheLineSize )
      PARAMETER ( lShare4 =  cacheLineSize/4 )
      PARAMETER ( lShare8 =  cacheLineSize/8 )

CC    MAX_VGS  :: Maximum buffer size for Global Vector Sum
c     INTEGER MAX_VGS
c     PARAMETER ( MAX_VGS = 8192 )

C     ========  EESIZE.h  ========================================

C     Symbolic values
C     precXXXX :: precision used for I/O
      INTEGER precFloat32
      PARAMETER ( precFloat32 = 32 )
      INTEGER precFloat64
      PARAMETER ( precFloat64 = 64 )

C     Real-type constant for some frequently used simple number (0,1,2,1/2):
      Real*8     zeroRS, oneRS, twoRS, halfRS
      PARAMETER ( zeroRS = 0.0D0 , oneRS  = 1.0D0 )
      PARAMETER ( twoRS  = 2.0D0 , halfRS = 0.5D0 )
      Real*8     zeroRL, oneRL, twoRL, halfRL
      PARAMETER ( zeroRL = 0.0D0 , oneRL  = 1.0D0 )
      PARAMETER ( twoRL  = 2.0D0 , halfRL = 0.5D0 )

C     UNSET_xxx :: Used to indicate variables that have not been given a value
      Real*8  UNSET_FLOAT8
      PARAMETER ( UNSET_FLOAT8 = 1.234567D5 )
      Real*4  UNSET_FLOAT4
      PARAMETER ( UNSET_FLOAT4 = 1.234567E5 )
      Real*8     UNSET_RL
      PARAMETER ( UNSET_RL     = 1.234567D5 )
      Real*8     UNSET_RS
      PARAMETER ( UNSET_RS     = 1.234567D5 )
      INTEGER UNSET_I
      PARAMETER ( UNSET_I      = 123456789  )

C     debLevX  :: used to decide when to print debug messages
      INTEGER debLevZero
      INTEGER debLevA, debLevB,  debLevC, debLevD, debLevE
      PARAMETER ( debLevZero=0 )
      PARAMETER ( debLevA=1 )
      PARAMETER ( debLevB=2 )
      PARAMETER ( debLevC=3 )
      PARAMETER ( debLevD=4 )
      PARAMETER ( debLevE=5 )

C     SQUEEZE_RIGHT      :: Flag indicating right blank space removal
C                           from text field.
C     SQUEEZE_LEFT       :: Flag indicating left blank space removal
C                           from text field.
C     SQUEEZE_BOTH       :: Flag indicating left and right blank
C                           space removal from text field.
C     PRINT_MAP_XY       :: Flag indicating to plot map as XY slices
C     PRINT_MAP_XZ       :: Flag indicating to plot map as XZ slices
C     PRINT_MAP_YZ       :: Flag indicating to plot map as YZ slices
C     commentCharacter   :: Variable used in column 1 of parameter
C                           files to indicate comments.
C     INDEX_I            :: Variable used to select an index label
C     INDEX_J               for formatted input parameters.
C     INDEX_K
C     INDEX_NONE
      CHARACTER*(*) SQUEEZE_RIGHT
      PARAMETER ( SQUEEZE_RIGHT = 'R' )
      CHARACTER*(*) SQUEEZE_LEFT
      PARAMETER ( SQUEEZE_LEFT = 'L' )
      CHARACTER*(*) SQUEEZE_BOTH
      PARAMETER ( SQUEEZE_BOTH = 'B' )
      CHARACTER*(*) PRINT_MAP_XY
      PARAMETER ( PRINT_MAP_XY = 'XY' )
      CHARACTER*(*) PRINT_MAP_XZ
      PARAMETER ( PRINT_MAP_XZ = 'XZ' )
      CHARACTER*(*) PRINT_MAP_YZ
      PARAMETER ( PRINT_MAP_YZ = 'YZ' )
      CHARACTER*(*) commentCharacter
      PARAMETER ( commentCharacter = '#' )
      INTEGER INDEX_I
      INTEGER INDEX_J
      INTEGER INDEX_K
      INTEGER INDEX_NONE
      PARAMETER ( INDEX_I    = 1,
     &            INDEX_J    = 2,
     &            INDEX_K    = 3,
     &            INDEX_NONE = 4 )

C     EXCH_IGNORE_CORNERS :: Flag to select ignoring or
C     EXCH_UPDATE_CORNERS    updating of corners during an edge exchange.
      INTEGER EXCH_IGNORE_CORNERS
      INTEGER EXCH_UPDATE_CORNERS
      PARAMETER ( EXCH_IGNORE_CORNERS = 0,
     &            EXCH_UPDATE_CORNERS = 1 )

C     FORWARD_SIMULATION
C     REVERSE_SIMULATION
C     TANGENT_SIMULATION
      INTEGER FORWARD_SIMULATION
      INTEGER REVERSE_SIMULATION
      INTEGER TANGENT_SIMULATION
      PARAMETER ( FORWARD_SIMULATION = 0,
     &            REVERSE_SIMULATION = 1,
     &            TANGENT_SIMULATION = 2 )

C--   COMMON /EEPARAMS_L/ Execution environment public logical variables.
C     eeBootError    :: Flags indicating error during multi-processing
C     eeEndError     :: initialisation and termination.
C     fatalError     :: Flag used to indicate that the model is ended with an error
C     debugMode      :: controls printing of debug msg (sequence of S/R calls).
C     useSingleCpuIO :: When useSingleCpuIO is set, MDS_WRITE_FIELD outputs from
C                       master MPI process only. -- NOTE: read from main parameter
C                       file "data" and not set until call to INI_PARMS.
C     useSingleCpuInput :: When useSingleCpuInput is set, EXF_INTERP_READ
C                       reads forcing files from master MPI process only.
C                       -- NOTE: read from main parameter file "data"
C                          and defaults to useSingleCpuInput = useSingleCpuIO
C     printMapIncludesZeros  :: Flag that controls whether character constant
C                               map code ignores exact zero values.
C     useCubedSphereExchange :: use Cubed-Sphere topology domain.
C     useCoupler     :: use Coupler for a multi-components set-up.
C     useNEST_PARENT :: use Parent Nesting interface (pkg/nest_parent)
C     useNEST_CHILD  :: use Child  Nesting interface (pkg/nest_child)
C     useNest2W_parent :: use Parent 2-W Nesting interface (pkg/nest2w_parent)
C     useNest2W_child  :: use Child  2-W Nesting interface (pkg/nest2w_child)
C     useOASIS       :: use OASIS-coupler for a multi-components set-up.
      COMMON /EEPARAMS_L/
c    &  eeBootError, fatalError, eeEndError,
     &  eeBootError, eeEndError, fatalError, debugMode,
     &  useSingleCpuIO, useSingleCpuInput, printMapIncludesZeros,
     &  useCubedSphereExchange, useCoupler,
     &  useNEST_PARENT, useNEST_CHILD,
     &  useNest2W_parent, useNest2W_child, useOASIS,
     &  useSETRLSTK, useSIGREG
      LOGICAL eeBootError
      LOGICAL eeEndError
      LOGICAL fatalError
      LOGICAL debugMode
      LOGICAL useSingleCpuIO
      LOGICAL useSingleCpuInput
      LOGICAL printMapIncludesZeros
      LOGICAL useCubedSphereExchange
      LOGICAL useCoupler
      LOGICAL useNEST_PARENT
      LOGICAL useNEST_CHILD
      LOGICAL useNest2W_parent
      LOGICAL useNest2W_child
      LOGICAL useOASIS
      LOGICAL useSETRLSTK
      LOGICAL useSIGREG

C--   COMMON /EPARAMS_I/ Execution environment public integer variables.
C     errorMessageUnit    :: Fortran IO unit for error messages
C     standardMessageUnit :: Fortran IO unit for informational messages
C     maxLengthPrt1D :: maximum length for printing (to Std-Msg-Unit) 1-D array
C     scrUnit1      :: Scratch file 1 unit number
C     scrUnit2      :: Scratch file 2 unit number
C     eeDataUnit    :: Unit # for reading "execution environment" parameter file
C     modelDataUnit :: Unit number for reading "model" parameter file.
C     numberOfProcs :: Number of processes computing in parallel
C     pidIO         :: Id of process to use for I/O.
C     myBxLo, myBxHi :: Extents of domain in blocks in X and Y
C     myByLo, myByHi :: that each threads is responsble for.
C     myProcId      :: My own "process" id.
C     myPx          :: My X coord on the proc. grid.
C     myPy          :: My Y coord on the proc. grid.
C     myXGlobalLo   :: My bottom-left (south-west) x-index global domain.
C                      The x-coordinate of this point in for example m or
C                      degrees is *not* specified here. A model needs to
C                      provide a mechanism for deducing that information
C                      if it is needed.
C     myYGlobalLo   :: My bottom-left (south-west) y-index in global domain.
C                      The y-coordinate of this point in for example m or
C                      degrees is *not* specified here. A model needs to
C                      provide a mechanism for deducing that information
C                      if it is needed.
C     nThreads      :: No. of threads
C     nTx, nTy      :: No. of threads in X and in Y
C                      This assumes a simple cartesian gridding of the threads
C                      which is not required elsewhere but that makes it easier
C     ioErrorCount  :: IO Error Counter. Set to zero initially and increased
C                      by one every time an IO error occurs.
      COMMON /EEPARAMS_I/
     &  errorMessageUnit, standardMessageUnit, maxLengthPrt1D,
     &  scrUnit1, scrUnit2, eeDataUnit, modelDataUnit,
     &  numberOfProcs, pidIO, myProcId,
     &  myPx, myPy, myXGlobalLo, myYGlobalLo, nThreads,
     &  myBxLo, myBxHi, myByLo, myByHi,
     &  nTx, nTy, ioErrorCount
      INTEGER errorMessageUnit
      INTEGER standardMessageUnit
      INTEGER maxLengthPrt1D
      INTEGER scrUnit1
      INTEGER scrUnit2
      INTEGER eeDataUnit
      INTEGER modelDataUnit
      INTEGER ioErrorCount(MAX_NO_THREADS)
      INTEGER myBxLo(MAX_NO_THREADS)
      INTEGER myBxHi(MAX_NO_THREADS)
      INTEGER myByLo(MAX_NO_THREADS)
      INTEGER myByHi(MAX_NO_THREADS)
      INTEGER myProcId
      INTEGER myPx
      INTEGER myPy
      INTEGER myXGlobalLo
      INTEGER myYGlobalLo
      INTEGER nThreads
      INTEGER nTx
      INTEGER nTy
      INTEGER numberOfProcs
      INTEGER pidIO

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***

CBOP
C    !ROUTINE: DARWIN_SIZE.h
C    !INTERFACE:
C #include DARWIN_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

C     integer nplank, nGroup, nopt
C     integer nPhoto
C     parameter(nplank=16)
C     parameter(nplank=170)
C     parameter(nGroup=5)
C     parameter(nGroup=2)
C     parameter(nopt=1)
C     parameter(nPhoto=15)
C     parameter(nPhoto=169)
C Parameters for a continuous 2-trait model (Le Gland, 28/01/2021)
C The number of traits or moments is not required here, as it is not the dimension of any tracer
C It can be introduced as a namelist parameter
C     integer nplank, nGroup, nopt, nphyp, nPhoto, nTrac
      integer nplank, nGroup, nopt, nphyp, nPhoto, nTrac, nTrait, nCov
      parameter(nGroup=2)
      parameter(nplank=2)
C     parameter(nPhoto=1)
C Number of phytoplankton species (Le Gland, 22/03/2021)
      parameter(nphyp=1)
C     parameter(nPhoto=6)
C     parameter(nTrac=7)
      parameter(nopt=1)
C 3-trait case (Le Gland, 25/03/2021)
      parameter(nPhoto=10)
      parameter(nTrac=11)
C Maximum number of traits (Le Gland, 25/03/2021)
      parameter(nTrait=3)
C     parameter(nTrait=2)
C Number of covariance corresponding to the maximum number of traits (Le Gland, 26/03/2021)
      parameter(nCov=3)
C     parameter(nCov=1)

      integer nlam
      parameter(nlam=1)

CEOP

CBOP
C    !ROUTINE: DARWIN_INDICES.h
C    !INTERFACE:
C #include DARWIN_INDICES.h

C    !DESCRIPTION:
C Contains indices into ptracer array

C these cannot be modified for now
C Replace nplank by nTrac ?
C What about nPhoto ? 1 or 6 ? (Le Gland, 29/01/2021)

      INTEGER iDIC
      INTEGER iNO3
      INTEGER iNO2
      INTEGER iNH4
      INTEGER iPO4
      INTEGER iFeT
      INTEGER iSiO2
      INTEGER iDOC
      INTEGER iDON
      INTEGER iDOP
      INTEGER iDOFe
      INTEGER iPOC
      INTEGER iPON
      INTEGER iPOP
      INTEGER iPOFe
      INTEGER iPOSi
      INTEGER iPIC
      INTEGER ic
      INTEGER eCARBON
      INTEGER eCDOM
      INTEGER ec
      INTEGER en
      INTEGER ep
      INTEGER efe
      INTEGER esi
      INTEGER eChl
      INTEGER nDarwin
      PARAMETER (iDIC   =1)
      PARAMETER (iNO3   =iDIC+1)
      PARAMETER (iNO2   =iNO3 +1)
      PARAMETER (iNH4   =iNO2 +1)
      PARAMETER (iPO4   =iNH4 +1)
      PARAMETER (iFeT   =iPO4 +1)
      PARAMETER (iSiO2  =iFeT +1)
      PARAMETER (iDOC   =iSiO2+1)
      PARAMETER (iDON   =iDOC +1)
      PARAMETER (iDOP   =iDON +1)
      PARAMETER (iDOFe  =iDOP +1)
      PARAMETER (iPOC   =iDOFe+1)
      PARAMETER (iPON   =iPOC +1)
      PARAMETER (iPOP   =iPON +1)
      PARAMETER (iPOFe  =iPOP +1)
      PARAMETER (iPOSi  =iPOFe+1)
      PARAMETER (iPIC   =iPOSi+1)
      INTEGER iALK
      INTEGER iO2
      PARAMETER (iALK   =iPIC +1)
      PARAMETER (iO2    =iALK +1)
      PARAMETER (eCARBON=iO2)
      PARAMETER (eCDOM  =eCARBON)
      PARAMETER (ic     =eCDOM+1)
C     PARAMETER (ec     =ic   +nplank-1)
      PARAMETER (ec     =ic   +nTrac-1)
      PARAMETER (en     =ec)
      PARAMETER (ep     =en)
      PARAMETER (efe    =ep)
      PARAMETER (esi    =efe)
      PARAMETER (eChl   =efe)
      PARAMETER (nDarwin=eChl)

CEOP

CBOP
C    !ROUTINE: DARWIN_DIAGS.h
C    !INTERFACE:
C #include DARWIN_DIAGS.h

C    !DESCRIPTION:
C Contains indices into diagnostics array

      integer iPP
      integer iNfix
      integer iDenit
      integer iDenitN
      integer iPPplank
      integer iGRplank
      integer iGrGn
      integer iConsDIN
      integer iConsPO4
      integer iConsSi
      integer iConsFe
      integer darwin_nDiag
      PARAMETER(iPP=     1)
      PARAMETER(iNfix=   2)
      PARAMETER(iDenit=  3)
      PARAMETER(iDenitN= 4)
      PARAMETER(iConsPO4=5)
      PARAMETER(iConsSi= 6)
      PARAMETER(iConsFe= 7)
      PARAMETER(iConsDIN=8)
      PARAMETER(iPPplank=9)
      PARAMETER(iGRplank=iPPplank+nplank)
      PARAMETER(iGrGn=iGRplank+nplank)
      PARAMETER(darwin_nDiag=iGrGn+nplank-1)

CEOP
CBOP
C    !ROUTINE: DARWIN_RADTRANS.h
C    !INTERFACE:
C #include DARWIN_RADTRANS.h
C
C    !DESCRIPTION:
C Contains radtrans-related parameters for the darwin package
C
C Requires: RADTRANS_SIZE.h
C Requires: DARWIN_SIZE.h


      COMMON /DARWIN_RT_DEPTRAITS_r/
     &    alphachl
C     Real*8 alphachl(nplank,nlam)
C nplank replaced by nTrac for consistence withh the rest of the code (Le Gland, 16/03/2021)
      Real*8 alphachl(nTrac,nlam)

CEOP

CBOP
C     !ROUTINE: DARWIN_PARAMS.h
C     !INTERFACE:
C #include DARWIN_PARAMS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C
C Requires: DARWIN_SIZE.h

      Real*8 DARWIN_UNINIT_RL
      PARAMETER(DARWIN_UNINIT_RL=-999999999D0)

C--   COMMON/darwin_forcing_params_l/ darwin parameters related to forcing
C     darwin_chlInitBalanced :: Initialize Chlorophyll to a balanced value following Geider
C     darwin_haveSurfPAR     ::
C     darwin_useSEAICE       :: whether to use ice area from seaice pkg
C     darwin_useQsw          :: whether to use model shortwave radiation
C     darwin_useEXFwind      :: whether to use wind speed from exf package
      COMMON/darwin_forcing_params_l/
     &    darwin_chlInitBalanced,
     &    darwin_haveSurfPAR,
     &    darwin_useSEAICE,
     &    darwin_useQsw,
     &    darwin_useEXFwind
      LOGICAL darwin_chlInitBalanced
      LOGICAL darwin_haveSurfPAR
      LOGICAL darwin_useSEAICE
      LOGICAL darwin_useQsw
      LOGICAL darwin_useEXFwind

C--   COMMON/darwin_forcing_params_i/ darwin parameters related to forcing
C     darwin_chlIter0 :: Iteration number when to initialize Chlorophyll
      COMMON/darwin_forcing_params_i/
     &    darwin_chlIter0
      INTEGER darwin_chlIter0

C--   COMMON /DARWIN_CONSTANTS_r/
C     rad2deg ::
      COMMON /DARWIN_CONSTANTS_r/
     &    rad2deg
      Real*8 rad2deg

C--   COMMON /CARBON_CONSTANTS_r/ Coefficients for DIC chemistry
C     Pa2Atm :: Convert pressure in Pascal to atm
C     ptr2mol :: convert ptracers (in mmol/m3) to mol/m3
C-
C     sca1 :: Schmidt no. coefficient for CO2
C     sca2 :: Schmidt no. coefficient for CO2
C     sca3 :: Schmidt no. coefficient for CO2
C     sca4 :: Schmidt no. coefficient for CO2
C-
C     sox1 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox2 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox3 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox4 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C-
C     oA0 :: Coefficient for determining saturation O2
C     oA1 :: Coefficient for determining saturation O2
C     oA2 :: Coefficient for determining saturation O2
C     oA3 :: Coefficient for determining saturation O2
C     oA4 :: Coefficient for determining saturation O2
C     oA5 :: Coefficient for determining saturation O2
C     oB0 :: Coefficient for determining saturation O2
C     oB1 :: Coefficient for determining saturation O2
C     oB2 :: Coefficient for determining saturation O2
C     oB3 :: Coefficient for determining saturation O2
C     oC0 :: Coefficient for determining saturation O2
      COMMON /CARBON_CONSTANTS_r/
     &    Pa2Atm,
     &    ptr2mol,
     &    sca1,
     &    sca2,
     &    sca3,
     &    sca4,
     &    sox1,
     &    sox2,
     &    sox3,
     &    sox4,
     &    oA0,
     &    oA1,
     &    oA2,
     &    oA3,
     &    oA4,
     &    oA5,
     &    oB0,
     &    oB1,
     &    oB2,
     &    oB3,
     &    oC0
      Real*8 Pa2Atm
      Real*8 ptr2mol
      Real*8 sca1
      Real*8 sca2
      Real*8 sca3
      Real*8 sca4
      Real*8 sox1
      Real*8 sox2
      Real*8 sox3
      Real*8 sox4
      Real*8 oA0
      Real*8 oA1
      Real*8 oA2
      Real*8 oA3
      Real*8 oA4
      Real*8 oA5
      Real*8 oB0
      Real*8 oB1
      Real*8 oB2
      Real*8 oB3
      Real*8 oC0

C     COMMON /DARWIN_PARAMS_c/ General parameters (same for all plankton)
C     darwin_pickupSuff :: pickup suffix for darwin; set to ' ' to disable reading at PTRACERS_Iter0
      COMMON /DARWIN_PARAMS_c/ darwin_pickupSuff
      CHARACTER*10 darwin_pickupSuff
C     darwin_strict_check  :: stop instead of issuing warnings
C     darwin_linFSConserve :: correct non-conservation due to linear free surface (globally)
C     darwin_read_phos     :: initial conditions for plankton biomass are in mmol P/m3
C     DARWIN_useQsw        :: use Qsw for light; if .FALSE., use DARWIN_INSOL
C--   COMMON /DARWIN_PARAMS_l/ General parameters (same for all plankton)
      COMMON /DARWIN_PARAMS_l/
     &    darwin_strict_check,
     &    darwin_linFSConserve,
     &    darwin_read_phos
      LOGICAL darwin_strict_check
      LOGICAL darwin_linFSConserve
      LOGICAL darwin_read_phos

C--   COMMON /DARWIN_PARAMS_i/ General parameters (same for all plankton)
C     darwin_seed :: seed for random number generator (for DARWIN_RANDOM_TRAITS)
C     iDEBUG      :: index in x dimension for debug prints
C     jDEBUG      :: index in y dimension for debug prints
C     kDEBUG      :: index in z dimension for debug prints
      COMMON /DARWIN_PARAMS_i/
     &    darwin_seed,
     &    iDEBUG,
     &    jDEBUG,
     &    kDEBUG
      INTEGER darwin_seed
      INTEGER iDEBUG
      INTEGER jDEBUG
      INTEGER kDEBUG

C--   COMMON /DARWIN_PARAMS_r/ General parameters (same for all plankton)
C     katten_w          :: [1/m]            atten coefficient water
C     katten_chl        :: [m2/mg Chl]      atten coefficient chl
C
C     parfrac           :: []               fraction Qsw that is PAR
C     parconv           :: [uEin/s/W]       conversion from W/m2 to uEin/m2/s
C     tempnorm          :: []               set temperature function (was 1.0)
C     TempAeArr         :: [K]              slope for pseudo-Arrhenius (TEMP_VERSION 2)
C     TemprefArr        :: [K]              reference temp for pseudo-Arrhenius (TEMP_VERSION 2)
C     TempCoeffArr      :: []               pre-factor for pseudo-Arrhenius (TEMP_VERSION 2)
C
C- Iron parameters
C     alpfe             :: []                 solubility of Fe dust
C     scav              :: [1/s]              fixed iron scavenging rate
C     ligand_tot        :: [mol/m3]           total ligand concentration
C     ligand_stab       :: [m3/mol]           ligand stability rate ratio
C     freefemax         :: [mol/m3]           max concentration of free iron
C     scav_rat          :: [1/s]              rate of POM-based iron scavenging
C     scav_inter        :: []                 intercept of scavenging power law
C     scav_exp          :: []                 exponent of scavenging power law
C     scav_R_POPPOC     :: [mmol P / mmol C]  POP:POC ratio for DARWIN_PART_SCAV_POP
C     depthfesed        :: [m]                depth above which to add sediment source (was -1000)
C     fesedflux         :: [mmol Fe /m2/s]    fixed iron flux from sediment
C     fesedflux_pcm     :: [mmol Fe / mmol C] iron input per POC sinking into bottom for DARWIN_IRON_SED_SOURCE_VARIABLE
C     fesedflux_min     :: [mmol Fe /s]       min iron input rate subtracted from fesedflux_pcm*wc_sink*POC
C     R_CP_fesed        :: [mmol C / mmol P]  POC:POP conversion for DARWIN_IRON_SED_SOURCE_POP
C
C     Knita             :: [1/s]              ammonia oxidation rate
C     Knitb             :: [1/s]              nitrite oxidation rate
C     PAR_oxi           :: [uEin/m2/s]        critical light level after which oxidation starts
C
C     Kdoc              :: [1/s] DOC remineralization rate
C     Kdop              :: [1/s] DON remineralization rate
C     Kdon              :: [1/s] DOP remineralization rate
C     KdoFe             :: [1/s] DOFe remineralization rate
C     KPOC              :: [1/s] POC remineralization rate
C     KPON              :: [1/s] PON remineralization rate
C     KPOP              :: [1/s] POP remineralization rate
C     KPOFe             :: [1/s] POFe remineralization rate
C     KPOSi             :: [1/s] POSi remineralization rate
C
C     wC_sink           :: [m/s] sinking velocity for POC
C     wN_sink           :: [m/s] sinking velocity for PON
C     wP_sink           :: [m/s] sinking velocity for POP
C     wFe_sink          :: [m/s] sinking velocity for POFe
C     wSi_sink          :: [m/s] sinking velocity for POSi
C     wPIC_sink         :: [m/s] sinking velocity for PIC
C     Kdissc            :: [1/s] dissolution rate for PIC
C
C- Carbon chemistry parameters
C     R_OP              :: [mmol O2 / mmol P] O:P ratio for respiration and consumption
C     R_OC              :: [mmol O2 / mmol C] NOT USED
C     m3perkg           :: [m3/kg]        constant for converting per kg to per m^3
C     surfSaltMinInit   :: [ppt]          limits for carbon solver input at initialization
C     surfSaltMaxInit   :: [ppt]          ...
C     surfTempMinInit   :: [degrees C]
C     surfTempMaxInit   :: [degrees C]
C     surfDICMinInit    :: [mmol C m^-3]
C     surfDICMaxInit    :: [mmol C m^-3]
C     surfALKMinInit    :: [meq m^-3]
C     surfALKMaxInit    :: [meq m^-3]
C     surfPO4MinInit    :: [mmol P m^-3]
C     surfPO4MaxInit    :: [mmol P m^-3]
C     surfSiMinInit     :: [mmol Si m^-3]
C     surfSiMaxInit     :: [mmol Si m^-3]
C     surfSaltMin       :: [ppt]           limits for carbon solver input during run
C     surfSaltMax       :: [ppt]           ...
C     surfTempMin       :: [degrees C]
C     surfTempMax       :: [degrees C]
C     surfDICMin        :: [mmol C m^-3]
C     surfDICMax        :: [mmol C m^-3]
C     surfALKMin        :: [meq m^-3]
C     surfALKMax        :: [meq m^-3]
C     surfPO4Min        :: [mmol P m^-3]
C     surfPO4Max        :: [mmol P m^-3]
C     surfSiMin         :: [mmol Si m^-3]
C     surfSiMax         :: [mmol Si m^-3]
C
C     diaz_ini_fac      :: reduce tracer concentrations by this factor on initialization
C
C- Denitrification
C     O2crit            :: [mmol O2 m-3]      critical oxygen for O2/NO3 remineralization
C     denit_NP          :: [mmol N / mmol P]  ratio of n to p in denitrification process
C     denit_NO3         :: [mmol N / mmol P]  ratio of NO3 uptake to phos remineralization in denitrification
C     NO3crit           :: [mmol N m-3]       critical nitrate below which no denit (or remin) happens
C
C- These should probably be traits
C     PARmin            :: [uEin/m2/s]        minimum light for photosynthesis; for non-Geider: 1.0
C     chl2nmax          :: [mg Chl / mmol N]  max Chl:N ratio for Chl synthesis following Moore 2002
C     synthcost         :: [mmol C / mmol N]  cost of biosynthesis
C     palat_min         :: []                 min non-zero palatability, smaller palat are set to 0 (was 1D-4 in quota)
C     inhib_graz        :: [(mmol C m-3)-1]   inverse decay scale for grazing inhibition
C     inhib_graz_exp    :: []                 exponent for grazing inhibition (0 to turn off inhibition)
C     hillnumUptake     :: []                 exponent for limiting quota uptake in nutrient uptake
C     hillnumGraz       :: []                 exponent for limiting quota uptake in grazing
C     hollexp           :: []                 grazing exponential 1= "Holling 2", 2= "Holling 3"
C     phygrazmin        :: [mmol C m-3]       minimum total prey conc for grazing to occur
C
C- Bacteria
C     pmaxDIN           :: [1/s]           max DIN uptake rate for denitrifying bacteria
C     pcoefO2           :: [m3/mmol O2/s]  max O2-specific O2 uptake rate for aerobic bacteria
C     ksatDIN           :: [mmol N m-3]    half-saturation conc of dissolved inorganic nitrogen
C     alpha_hydrol      :: []              increase in POM needed due to hydrolysis
C     yod               :: []              organic matter yield of aerobic bacteria
C     yoe               :: []              energy yield of aerobic bacteria
C     ynd               :: []              organic matter yield of denitrifying bacteria
C     yne               :: []              energy yield of denitrifying bacteria
C     fnh4              :: []              not implemented (for ammonia-oxidizing bacteria)
C     ynh4              :: []              not implemented (for ammonia-oxidizing bacteria)
C     yonh4             :: []              not implemented (for ammonia-oxidizing bacteria)
C     fno2              :: []              not implemented (for nitrite-oxidizing bacteria)
C     yno2              :: []              not implemented (for nitrite-oxidizing bacteria)
C     yono2             :: []              not implemented (for nitrite-oxidizing bacteria)
C
C- To be implemented
C     depthdenit        :: [m]             not implemented (depth for denitrification relaxation to start)
      COMMON /DARWIN_PARAMS_r/
     &    katten_w,
     &    katten_chl,
     &    parfrac,
     &    parconv,
     &    tempnorm,
     &    TempAeArr,
     &    TemprefArr,
     &    TempCoeffArr,
     &    alpfe,
     &    scav,
     &    ligand_tot,
     &    ligand_stab,
     &    freefemax,
     &    scav_rat,
     &    scav_inter,
     &    scav_exp,
     &    scav_R_POPPOC,
     &    depthfesed,
     &    fesedflux,
     &    fesedflux_pcm,
     &    fesedflux_min,
     &    R_CP_fesed,
     &    Knita,
     &    Knitb,
     &    PAR_oxi,
     &    Kdoc,
     &    Kdop,
     &    Kdon,
     &    KdoFe,
     &    KPOC,
     &    KPON,
     &    KPOP,
     &    KPOFe,
     &    KPOSi,
     &    wC_sink,
     &    wN_sink,
     &    wP_sink,
     &    wFe_sink,
     &    wSi_sink,
     &    wPIC_sink,
     &    Kdissc,
     &    R_OP,
     &    R_OC,
     &    m3perkg,
     &    surfSaltMinInit,
     &    surfSaltMaxInit,
     &    surfTempMinInit,
     &    surfTempMaxInit,
     &    surfDICMinInit,
     &    surfDICMaxInit,
     &    surfALKMinInit,
     &    surfALKMaxInit,
     &    surfPO4MinInit,
     &    surfPO4MaxInit,
     &    surfSiMinInit,
     &    surfSiMaxInit,
     &    surfSaltMin,
     &    surfSaltMax,
     &    surfTempMin,
     &    surfTempMax,
     &    surfDICMin,
     &    surfDICMax,
     &    surfALKMin,
     &    surfALKMax,
     &    surfPO4Min,
     &    surfPO4Max,
     &    surfSiMin,
     &    surfSiMax,
     &    diaz_ini_fac,
     &    O2crit,
     &    denit_NP,
     &    denit_NO3,
     &    NO3crit,
     &    PARmin,
     &    chl2nmax,
     &    synthcost,
     &    palat_min,
     &    inhib_graz,
     &    inhib_graz_exp,
     &    hillnumUptake,
     &    hillnumGraz,
     &    hollexp,
     &    phygrazmin,
     &    pcoefO2,
     &    pmaxDIN,
     &    ksatDIN,
     &    alpha_hydrol,
     &    yod,
     &    yoe,
     &    ynd,
     &    yne,
C     &    fnh4,
C     &    ynh4,
C     &    yonh4,
C     &    fno2,
C     &    yno2,
C     &    yono2,
     &    depthdenit
      Real*8 katten_w
      Real*8 katten_chl
      Real*8 parfrac
      Real*8 parconv
      Real*8 tempnorm
      Real*8 TempAeArr
      Real*8 TemprefArr
      Real*8 TempCoeffArr
      Real*8 alpfe
      Real*8 scav
      Real*8 ligand_tot
      Real*8 ligand_stab
      Real*8 freefemax
      Real*8 scav_rat
      Real*8 scav_inter
      Real*8 scav_exp
      Real*8 scav_R_POPPOC
      Real*8 depthfesed
      Real*8 fesedflux
      Real*8 fesedflux_pcm
      Real*8 fesedflux_min
      Real*8 R_CP_fesed
      Real*8 Knita
      Real*8 Knitb
      Real*8 PAR_oxi
      Real*8 Kdoc
      Real*8 Kdop
      Real*8 Kdon
      Real*8 KdoFe
      Real*8 KPOC
      Real*8 KPON
      Real*8 KPOP
      Real*8 KPOFe
      Real*8 KPOSi
      Real*8 wC_sink
      Real*8 wN_sink
      Real*8 wP_sink
      Real*8 wFe_sink
      Real*8 wSi_sink
      Real*8 wPIC_sink
      Real*8 Kdissc
      Real*8 R_OP
      Real*8 R_OC
      Real*8 m3perkg
      Real*8 surfSaltMinInit
      Real*8 surfSaltMaxInit
      Real*8 surfTempMinInit
      Real*8 surfTempMaxInit
      Real*8 surfDICMinInit
      Real*8 surfDICMaxInit
      Real*8 surfALKMinInit
      Real*8 surfALKMaxInit
      Real*8 surfPO4MinInit
      Real*8 surfPO4MaxInit
      Real*8 surfSiMinInit
      Real*8 surfSiMaxInit
      Real*8 surfSaltMin
      Real*8 surfSaltMax
      Real*8 surfTempMin
      Real*8 surfTempMax
      Real*8 surfDICMin
      Real*8 surfDICMax
      Real*8 surfALKMin
      Real*8 surfALKMax
      Real*8 surfPO4Min
      Real*8 surfPO4Max
      Real*8 surfSiMin
      Real*8 surfSiMax
      Real*8 diaz_ini_fac
      Real*8 O2crit
      Real*8 denit_NP
      Real*8 denit_NO3
      Real*8 NO3crit
      Real*8 PARmin
      Real*8 chl2nmax
      Real*8 synthcost
      Real*8 palat_min
      Real*8 inhib_graz
      Real*8 inhib_graz_exp
      Real*8 hillnumUptake
      Real*8 hillnumGraz
      Real*8 hollexp
      Real*8 phygrazmin
      Real*8 pcoefO2
      Real*8 pmaxDIN
      Real*8 ksatDIN
      Real*8 alpha_hydrol
      Real*8 yod
      Real*8 yoe
      Real*8 ynd
      Real*8 yne
C      Real*8 fnh4
C      Real*8 ynh4
C      Real*8 yonh4
C      Real*8 fno2
C      Real*8 yno2
C      Real*8 yono2
      Real*8 depthdenit


C--   COMMON /DARWIN_DEPENDENT_PARAMS_i/
C     laCDOM    :: index of reference waveband for CDOM absorption spectrum
C     kMinFeSed :: minimum level index for iron sedimentation
C     kMaxFeSed :: maximum level index for iron sedimentation
      COMMON /DARWIN_DEPENDENT_PARAMS_i/
     &    darwin_dependent_i_dummy,
     &    kMinFeSed,
     &    kMaxFeSed
      INTEGER darwin_dependent_i_dummy
      INTEGER kMinFeSed
      INTEGER kMaxFeSed




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
     &    ksatPAR,
     &    kinhPAR,
     &    PARopt,
     &    PARchi,
C Mutation rate of each species (Le Gland, 31/03/2021)
     &    numut_tr,
C Reference trait values for each species (Le Gland, 14/05/2021)
     &    ref_tr,
C Minimum and maximum trait values, maximum variance (Le Gland, 07/06/2021)
     &    min_tr,
     &    max_tr,
     &    max_vr_tr,
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
      Real*8 Xmin(nTrac)
      Real*8 amminhib(nTrac)
      Real*8 acclimtimescl(nTrac)
      Real*8 mort(nTrac)
      Real*8 mort2(nTrac)
      Real*8 ExportFracMort(nTrac)
      Real*8 ExportFracMort2(nTrac)
      Real*8 ExportFracExude(nTrac)
      Real*8 phytoTempCoeff(nTrac)
      Real*8 phytoTempExp1(nTrac)
      Real*8 phytoTempExp2(nTrac)
      Real*8 phytoTempOptimum(nTrac)
C Le Gland, 10/12/2020
      Real*8 phytoTempTol(nTrac)
      Real*8 phytoDecayPower(nTrac)
      Real*8 R_NC(nTrac)
      Real*8 R_PC(nTrac)
      Real*8 R_SiC(nTrac)
      Real*8 R_FeC(nTrac)
      Real*8 R_ChlC(nTrac)
      Real*8 R_PICPOC(nTrac)
      Real*8 biosink(nTrac)
      Real*8 bioswim(nTrac)
      Real*8 respRate(nTrac)
      Real*8 PCmax(nTrac)
      Real*8 Qnmax(nTrac)
      Real*8 Qnmin(nTrac)
      Real*8 Qpmax(nTrac)
      Real*8 Qpmin(nTrac)
      Real*8 Qsimax(nTrac)
      Real*8 Qsimin(nTrac)
      Real*8 Qfemax(nTrac)
      Real*8 Qfemin(nTrac)
      Real*8 VmaxNH4(nTrac)
      Real*8 VmaxNO2(nTrac)
      Real*8 VmaxNO3(nTrac)
      Real*8 VmaxN(nTrac)
      Real*8 VmaxPO4(nTrac)
      Real*8 VmaxSiO2(nTrac)
      Real*8 VmaxFeT(nTrac)
      Real*8 ksatNH4(nTrac)
      Real*8 ksatNO2(nTrac)
      Real*8 ksatNO3(nTrac)
      Real*8 ksatPO4(nTrac)
      Real*8 ksatSiO2(nTrac)
      Real*8 ksatFeT(nTrac)
      Real*8 kexcc(nTrac)
      Real*8 kexcn(nTrac)
      Real*8 kexcp(nTrac)
      Real*8 kexcsi(nTrac)
      Real*8 kexcfe(nTrac)
      Real*8 ksatPAR(nTrac)
      Real*8 kinhPAR(nTrac)
      Real*8 PARopt(nTrac)
      Real*8 PARchi(nTrac)
C Mutation rate of each species (Le Gland, 31/03/2021)
      Real*8 numut_tr(nplank,nTrait)
C Reference trait values for each species (Le Gland, 14/05/2021)
      Real*8 ref_tr(nplank,nTrait)
C Minimum and maximum trait values, maximum variance (Le Gland, 07/06/2021)
      Real*8 min_tr(nplank,nTrait)
      Real*8 max_tr(nplank,nTrait)
      Real*8 max_vr_tr(nplank,nTrait)
      Real*8 mQyield(nTrac)
      Real*8 chl2cmax(nTrac)
      Real*8 grazemax(nTrac)
      Real*8 kgrazesat(nTrac)
      Real*8 palat(nTrac,nTrac)
      Real*8 asseff(nTrac,nTrac)
      Real*8 ExportFracPreyPred(nTrac,nTrac)
      Real*8 yield(nTrac)
      Real*8 yieldO2(nTrac)
      Real*8 yieldNO3(nTrac)
      Real*8 ksatPON(nTrac)
      Real*8 ksatPOC(nTrac)
      Real*8 ksatPOP(nTrac)
      Real*8 ksatPOFe(nTrac)
      Real*8 ksatDON(nTrac)
      Real*8 ksatDOC(nTrac)
      Real*8 ksatDOP(nTrac)
      Real*8 ksatDOFe(nTrac)

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
     &    normI,
     &    biovol,
     &    qcarbon,
C    &    biovol_bygroup,
C    &    Topt_bygroup,
     &    alpha_mean,
     &    chl2cmin
      Real*8 normI(nTrac)
      Real*8 biovol(nTrac)
      Real*8 qcarbon(nTrac)
C     Real*8 biovol_bygroup(nTrac,ngroup)
C Le Gland, 10/12/2020
C     Real*8 Topt_bygroup(nTrac,ngroup)
      Real*8 alpha_mean(nTrac)
      Real*8 chl2cmin(nTrac)



C Le Gland (18/12/2020) for trait diffusion -> grp_ntopt,grp_nbiovol

CBOP
C     !ROUTINE: DARWIN_TRAITPARAMS.h
C     !INTERFACE:
C #include DARWIN_TRAITPARAMS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C the parameters in this file are used to generate traits
C
C Requires: DARWIN_SIZE.h

C--   COMMON /DARWIN_RANDOM_PARAMS_l/ For darwin_allometric_random
C     oldTwoGrazers :: old defaults for 2 grazers
      COMMON /DARWIN_RANDOM_PARAMS_l/
     &    oldTwoGrazers
      LOGICAL oldTwoGrazers

C--   COMMON /DARWIN_RANDOM_PARAMS_r/ For darwin_allometric_random
      COMMON /DARWIN_RANDOM_PARAMS_r/
     &    phymin,
     &    Smallgrow,
     &    Biggrow,
     &    Smallgrowrange,
     &    Biggrowrange,
     &    diaz_growfac,
     &    cocco_growfac,
     &    diatom_growfac,
     &    Smallmort,
     &    Bigmort,
     &    Smallmortrange,
     &    Bigmortrange,
     &    Smallexport,
     &    Bigexport,
     &    tempcoeff1,
     &    tempcoeff2_small,
     &    tempcoeff2_big,
     &    tempcoeff3,
     &    tempmax,
     &    temprange,
     &    tempdecay,
     &    val_R_NC,
     &    val_R_NC_diaz,
     &    val_R_PC,
     &    val_R_SiC_diatom,
     &    val_R_FeC,
     &    val_R_FeC_diaz,
     &    val_R_PICPOC,
     &    val_R_ChlC,
     &    val_R_NC_zoo,
     &    val_R_PC_zoo,
     &    val_R_SiC_zoo,
     &    val_R_FeC_zoo,
     &    val_R_PICPOC_zoo,
     &    val_R_ChlC_zoo,
     &    SmallSink,
     &    BigSink,
     &    SmallPsat,
     &    BigPsat,
     &    ProcPsat,
     &    UniDzPsat,
     &    CoccoPsat,
     &    SmallPsatrange,
     &    BigPsatrange,
     &    ProcPsatrange,
     &    UniDzPsatrange,
     &    CoccoPsatrange,
     &    ksatNH4fac,
     &    ksatNO2fac,
     &    val_amminhib,
     &    val_ksatsio2,
     &    smallksatpar,
     &    smallksatparstd,
     &    smallkinhpar,
     &    smallkinhparstd,
     &    Bigksatpar,
     &    Bigksatparstd,
     &    Bigkinhpar,
     &    Bigkinhparstd,
     &    LLProkinhpar,
     &    Coccokinhpar,
     &    inhibcoef_geid_val,
     &    smallmQyield,
     &    smallmQyieldrange,
     &    BigmQyield,
     &    BigmQyieldrange,
     &    smallchl2cmax,
     &    smallchl2cmaxrange,
     &    Bigchl2cmax,
     &    Bigchl2cmaxrange,
     &    aphy_chl_ave,
     &    val_acclimtimescl,
     &    GrazeFast,
     &    GrazeSlow,
     &    ZooexfacSmall,
     &    ZooexfacBig,
     &    ZoomortSmall,
     &    ZoomortBig,
     &    ZoomortSmall2,
     &    ZoomortBig2,
     &    ExGrazfracbig,
     &    ExGrazfracsmall,
     &    palathi,
     &    palatlo,
     &    diatomgraz,
     &    coccograz,
     &    olargegraz,
     &    GrazeEfflow,
     &    GrazeEffmod,
     &    GrazeEffhi,
     &    GrazeRate,
     &    ExGrazfrac,
     &    val_palat,
     &    val_ass_eff,
     &    kgrazesat_val,
     &    Zoomort,
     &    Zoomort2,
     &    Zooexfac,
     &    ZooDM
      Real*8 phymin
      Real*8 Smallgrow
      Real*8 Biggrow
      Real*8 Smallgrowrange
      Real*8 Biggrowrange
      Real*8 diaz_growfac
      Real*8 cocco_growfac
      Real*8 diatom_growfac
      Real*8 Smallmort
      Real*8 Bigmort
      Real*8 Smallmortrange
      Real*8 Bigmortrange
      Real*8 Smallexport
      Real*8 Bigexport
      Real*8 tempcoeff1
      Real*8 tempcoeff2_small
      Real*8 tempcoeff2_big
      Real*8 tempcoeff3
      Real*8 tempmax
      Real*8 temprange
      Real*8 tempdecay
      Real*8 val_R_NC
      Real*8 val_R_NC_diaz
      Real*8 val_R_PC
      Real*8 val_R_SiC_diatom
      Real*8 val_R_FeC
      Real*8 val_R_FeC_diaz
      Real*8 val_R_PICPOC
      Real*8 val_R_ChlC
      Real*8 val_R_NC_zoo
      Real*8 val_R_PC_zoo
      Real*8 val_R_SiC_zoo
      Real*8 val_R_FeC_zoo
      Real*8 val_R_PICPOC_zoo
      Real*8 val_R_ChlC_zoo
      Real*8 SmallSink
      Real*8 BigSink
      Real*8 SmallPsat
      Real*8 BigPsat
      Real*8 ProcPsat
      Real*8 UniDzPsat
      Real*8 CoccoPsat
      Real*8 SmallPsatrange
      Real*8 BigPsatrange
      Real*8 ProcPsatrange
      Real*8 UniDzPsatrange
      Real*8 CoccoPsatrange
      Real*8 ksatNH4fac
      Real*8 ksatNO2fac
      Real*8 val_amminhib
      Real*8 val_ksatsio2
      Real*8 smallksatpar
      Real*8 smallksatparstd
      Real*8 smallkinhpar
      Real*8 smallkinhparstd
      Real*8 Bigksatpar
      Real*8 Bigksatparstd
      Real*8 Bigkinhpar
      Real*8 Bigkinhparstd
      Real*8 LLProkinhpar
      Real*8 Coccokinhpar
      Real*8 inhibcoef_geid_val
      Real*8 smallmQyield
      Real*8 smallmQyieldrange
      Real*8 BigmQyield
      Real*8 BigmQyieldrange
      Real*8 smallchl2cmax
      Real*8 smallchl2cmaxrange
      Real*8 Bigchl2cmax
      Real*8 Bigchl2cmaxrange
      Real*8 aphy_chl_ave
      Real*8 val_acclimtimescl
      Real*8 GrazeFast
      Real*8 GrazeSlow
      Real*8 ZooexfacSmall
      Real*8 ZooexfacBig
      Real*8 ZoomortSmall
      Real*8 ZoomortBig
      Real*8 ZoomortSmall2
      Real*8 ZoomortBig2
      Real*8 ExGrazfracbig
      Real*8 ExGrazfracsmall
      Real*8 palathi
      Real*8 palatlo
      Real*8 diatomgraz
      Real*8 coccograz
      Real*8 olargegraz
      Real*8 GrazeEfflow
      Real*8 GrazeEffmod
      Real*8 GrazeEffhi
      Real*8 GrazeRate
      Real*8 ExGrazfrac
      Real*8 val_palat
      Real*8 val_ass_eff
      Real*8 kgrazesat_val
      Real*8 Zoomort
      Real*8 Zoomort2
      Real*8 Zooexfac
      Real*8 ZooDM

C--   COMMON /DARWIN_TRAIT_PARAMS_l/ Used in darwin_generate_allometric
C     darwin_sort_biovol    :: whether to sort type by volume rather than group first
C     darwin_effective_ksat :: compute effective half-saturation for non-quota elements
      COMMON /DARWIN_TRAIT_PARAMS_l/
     &    darwin_sort_biovol,
     &    darwin_effective_ksat
      LOGICAL darwin_sort_biovol
      LOGICAL darwin_effective_ksat

C--   COMMON /DARWIN_TRAIT_PARAMS_c/ Used in darwin_generate_allometric
C     grp_names :: names of functional groups
      COMMON /DARWIN_TRAIT_PARAMS_c/
     &    grp_names
      CHARACTER*80 grp_names(nGroup)

C--   COMMON /DARWIN_TRAIT_PARAMS_i/ Used in darwin_generate_allometric
C     darwin_select_kn_allom :: 1: use Ward et al formulation, 2: use Follett et al
C     logvol0ind             :: first index in volume list used by this group
C     grp_nplank             :: number of plankton types in this group
C     grp_nbiovol            :: number of plankton size classes in this group
C     grp_ntopt              :: number of plankton optimal temperatures in this group
C     grp_photo              :: -> isPhoto
C     grp_bacttype           :: -> bactType
C     grp_aerobic            :: -> isAerobic
C     grp_denit              :: -> isDenit
C     grp_pred               :: -> isPred
C     grp_prey               :: -> isPrey
C     grp_hasSi              :: -> hasSi
C     grp_hasPIC             :: -> hasPIC
C     grp_diazo              :: -> diazo
C     grp_useNH4             :: -> useNH4
C     grp_useNO2             :: -> useNO2
C     grp_useNO3             :: -> useNO3
C     grp_combNO             :: -> combNO
C Traits of each group (Le Gland, 25/03/2021)
C     grp_traitbvol          :: -> traitbvol
C     grp_traittopt          :: -> traittopt
C     grp_traitparopt        :: -> traitparopt
C     grp_aptype             :: -> aptype
C     grp_tempMort           :: -> tempMort
C     grp_tempMort2          :: -> tempMort2
C     grp_tempGraz           :: -> tempGraz
      COMMON /DARWIN_TRAIT_PARAMS_i/
     &    darwin_select_kn_allom,
C    &    logvol0ind,
     &    grp_nplank,
C    &    grp_nbiovol,
C    &    grp_ntopt,
     &    grp_photo,
     &    grp_bacttype,
     &    grp_aerobic,
     &    grp_denit,
     &    grp_pred,
     &    grp_prey,
     &    grp_hasSi,
     &    grp_hasPIC,
     &    grp_diazo,
     &    grp_useNH4,
     &    grp_useNO2,
     &    grp_useNO3,
     &    grp_combNO,
C Traits of each group (Le Gland, 25/03/2021)
     &    grp_traitbvol,
     &    grp_traittopt,
     &    grp_traitparopt,
     &    grp_aptype,
     &    grp_tempMort,
     &    grp_tempMort2,
     &    grp_tempGraz
      INTEGER darwin_select_kn_allom
C     INTEGER logvol0ind(nGroup)
      INTEGER grp_nplank(nGroup)
C     INTEGER grp_nbiovol(nGroup)
C     INTEGER grp_ntopt(nGroup)
      INTEGER grp_photo(nGroup)
      INTEGER grp_bacttype(nGroup)
      INTEGER grp_aerobic(nGroup)
      INTEGER grp_denit(nGroup)
      INTEGER grp_pred(nGroup)
      INTEGER grp_prey(nGroup)
      INTEGER grp_hasSi(nGroup)
      INTEGER grp_hasPIC(nGroup)
      INTEGER grp_diazo(nGroup)
      INTEGER grp_useNH4(nGroup)
      INTEGER grp_useNO2(nGroup)
      INTEGER grp_useNO3(nGroup)
      INTEGER grp_combNO(nGroup)
C Traits of each group (Le Gland, 25/03/2021)
      INTEGER grp_traitbvol(nGroup)
      INTEGER grp_traittopt(nGroup)
      INTEGER grp_traitparopt(nGroup)
      INTEGER grp_aptype(nGroup)
      INTEGER grp_tempMort(nGroup)
      INTEGER grp_tempMort2(nGroup)
      INTEGER grp_tempGraz(nGroup)

C--   COMMON /DARWIN_TRAIT_PARAMS_r/ Used in darwin_generate_allometric
C     logvolbase             :: []    log-10 base for list of volumes
C     logvolinc              :: []    log-10 increment for list of volumes
C     biovol0                :: [um3] volume of smallest type in group
C     biovolfac              :: []    factor by which each type is bigger than previous
C     grp_logvolind          :: []    indices into volume list for type in this group
C     grp_biovol             :: [um3] volumes of types in each group
C Le Gland, 10/12/2020
C     Topt0                  :: [°C]  Optimal temperature of coldest type in group
C     Toptfac                :: [°C]  Increase in optimal temperature from type to type
C     grp_Topt               :: [°C]  Optimal temperatures of types in each group
C Light-related traits (Le Gland, 30/03/2021)
C     PARopt0                :: [W.m-2]
C     PARchi0                :: []
C Le Gland, 18/12/2020
C     numut_bvol             :: [log(um3)2]    Trait diffusion parameter for biovolume
C     numut_topt             :: [°C2]  Trait diffusion parameter for optimal temperature
C Le Gland, 25/03/2021
C     numut_paropt           :: [log(W m-2)2]  Trait diffusion parameter for optimal irradiance
C Le Gland, 27/08/2021       :: [] Kill The Winner Parameter (1 = no switching)
C     a_KTW
C
C- Allometric parameters
C     a_* b_* :: param = a_param*V^b_param
C
C- Predator prey preference distribution parameters
C     a_pp_sig               :: standard deviation of predator-prey volume ratio for palatability
C     a_pp_opt               :: a for optimal predator-prey volume ratio
C     b_pp_opt               :: b for optimal predator-prey volume ratio
C
C     a_respRate_c           :: Note function of cellular C --> aC^b
C     a_respRate_c_denom     :: Note function of cellular C --> aC^b
C     b_respRate_c           :: Note function of cellular C --> aC^b
C
C     a_ksatNO2fac           :: only used for darwin_effective_ksat
C     a_ksatNH4fac           :: only used for darwin_effective_ksat
C
      COMMON /DARWIN_TRAIT_PARAMS_r/
C Only biovol0 and Topt0 are required in the continuous model (Le Gland, 13/01/2021)
C    &    logvolbase,
C    &    logvolinc,
     &    biovol0,
C    &    biovolfac,
C    &    grp_logvolind,
C    &    grp_biovol,
     &    Topt0,
C    &    Toptfac,
C    &    grp_Topt,
C Light-related traits (Le Gland, 30/03/2021)
     &    PARopt0,
     &    PARchi0,
C Le Gland, 18/12/2020
     &    numut_bvol,
     &    numut_topt,
C Le Gland, 25/03/2021
     &    numut_paropt,
C Le Gland, 27/08/2021
     &    a_KTW,
     &    a_Xmin,
     &    a_R_NC,
     &    a_R_PC,
     &    a_R_SiC,
     &    a_R_FeC,
     &    a_R_ChlC,
     &    a_R_PICPOC,
     &    a_ExportFracMort,
     &    a_ExportFracMort2,
     &    a_ExportFracExude,
     &    a_mort,
     &    a_mort2,
     &    a_phytoTempCoeff,
     &    a_phytoTempExp2,
     &    a_phytoTempExp1,
C    &    a_phytoTempOptimum,
C Le Gland, 10/12/2020
     &    a_phytoTempTol,
     &    a_phytoDecayPower,
     &    a_ksatPAR,
     &    a_kinhPAR,
     &    a_amminhib,
     &    a_acclimtimescl,
     &    a_acclimtimescl_denom,
     &    a_ksatPON,
     &    a_ksatDON,
     &    a_grazemax,
     &    a_grazemax_denom,
     &    b_grazemax,
     &    a_kgrazesat,
     &    b_kgrazesat,
C Palatability allometry (Le Gland, 10/06/2021)
     &    a_palat,
     &    b_palat,
     &    a_biosink,
     &    a_biosink_denom,
     &    b_biosink,
     &    a_bioswim,
     &    a_bioswim_denom,
     &    b_bioswim,
     &    a_ppSig,
     &    a_ppOpt,
     &    b_ppOpt,
     &    a_PCmax,
     &    a_PCmax_denom,
     &    b_PCmax,
C Unimodal growth rate (Le Gland, 10/06/2021)
C    &    b1_PCmax,
C    &    b2_PCmax,
C    &    c_PCmax,
     &    a_qcarbon,
     &    b_qcarbon,
     &    a_respRate_c,
     &    a_respRate_c_denom,
     &    b_respRate_c,
     &    a_kexcC,
     &    b_kexcC,
     &    a_vmaxNO3,
     &    a_vmaxNO3_denom,
     &    b_vmaxNO3,
     &    a_ksatNO3,
     &    b_ksatNO3,
     &    a_Qnmin,
     &    b_Qnmin,
     &    a_Qnmax,
     &    b_Qnmax,
     &    a_kexcN,
     &    b_kexcN,
     &    a_vmaxNO2,
     &    a_vmaxNO2_denom,
     &    b_vmaxNO2,
     &    a_ksatNO2,
     &    b_ksatNO2,
     &    a_ksatNO2fac,
     &    a_vmaxNH4,
     &    a_vmaxNH4_denom,
     &    b_vmaxNH4,
     &    a_ksatNH4,
     &    b_ksatNH4,
     &    a_ksatNH4fac,
     &    a_vmaxN,
     &    a_vmaxN_denom,
     &    b_vmaxN,
     &    a_vmaxPO4,
     &    a_vmaxPO4_denom,
     &    b_vmaxPO4,
     &    a_ksatPO4,
     &    b_ksatPO4,
     &    a_Qpmin,
     &    b_Qpmin,
     &    a_Qpmax,
     &    b_Qpmax,
     &    a_kexcP,
     &    b_kexcP,
     &    a_vmaxSiO2,
     &    a_vmaxSiO2_denom,
     &    b_vmaxSiO2,
     &    a_ksatSiO2,
     &    b_ksatSiO2,
     &    a_Qsimin,
     &    b_Qsimin,
     &    a_Qsimax,
     &    b_Qsimax,
     &    a_kexcSi,
     &    b_kexcSi,
     &    a_vmaxFeT,
     &    a_vmaxFeT_denom,
     &    b_vmaxFeT,
     &    a_ksatFeT,
     &    b_ksatFeT,
     &    a_Qfemin,
     &    b_Qfemin,
     &    a_Qfemax,
     &    b_Qfemax,
     &    a_kexcFe,
     &    b_kexcFe,
C Absolute minima added to prevent:
C 1) phytoplankton from being smaller than Prochlorococcus
C 2) large species (opportunists) from having a low Iopt
     &    a_biovolmin,
     &    a_PARoptmin,
     &    b_PARoptmin,
     &    grp_ExportFracPreyPred,
     &    grp_ass_eff
C Only biovol0 and Topt0 are required in the continuous model (Le Gland, 13/01/2021)
C     Real*8 logvolbase
C     Real*8 logvolinc
      Real*8 biovol0(nGroup)
C     Real*8 biovolfac(nGroup)
      Real*8 Topt0(nGroup)
C     Real*8 Toptfac(nGroup)
C     Real*8 grp_logvolind(nPlank,nGroup)
C     Real*8 grp_biovol(nPlank,nGroup)
C     Real*8 grp_Topt(nPlank,nGroup)
C Light-related traits (Le Gland, 30/03/2021)
      Real*8 PARopt0(nGroup)
      Real*8 PARchi0(nGroup)
C Le Gland, 18/12/2020
      Real*8 numut_bvol(nGroup)
      Real*8 numut_topt(nGroup)
C Le Gland, 15/03/2020
C     Real*8 numut_bvol(nplank)
C     Real*8 numut_topt(nplank)
C Le Gland, 25/03/2021
      Real*8 numut_paropt(nGroup)
C Le Gland, 27/08/2021
      Real*8 a_KTW
      Real*8 a_Xmin(nGroup)
      Real*8 a_R_NC(nGroup)
      Real*8 a_R_PC(nGroup)
      Real*8 a_R_SiC(nGroup)
      Real*8 a_R_FeC(nGroup)
      Real*8 a_R_ChlC(nGroup)
      Real*8 a_R_PICPOC(nGroup)
      Real*8 a_ExportFracMort(nGroup)
      Real*8 a_ExportFracMort2(nGroup)
      Real*8 a_ExportFracExude(nGroup)
      Real*8 a_mort(nGroup)
      Real*8 a_mort2(nGroup)
      Real*8 a_phytoTempCoeff(nGroup)
      Real*8 a_phytoTempExp2(nGroup)
      Real*8 a_phytoTempExp1(nGroup)
C     Real*8 a_phytoTempOptimum(nGroup)
C Le Gland, 10/12/2020
      Real*8 a_phytoTempTol(nGroup)
      Real*8 a_phytoDecayPower(nGroup)
      Real*8 a_ksatPAR(nGroup)
      Real*8 a_kinhPAR(nGroup)
      Real*8 a_amminhib(nGroup)
      Real*8 a_acclimtimescl(nGroup)
      Real*8 a_acclimtimescl_denom(nGroup)
      Real*8 a_ksatPON(nGroup)
      Real*8 a_ksatDON(nGroup)
      Real*8 a_grazemax(nGroup)
      Real*8 a_grazemax_denom(nGroup)
      Real*8 b_grazemax(nGroup)
      Real*8 a_kgrazesat(nGroup)
      Real*8 b_kgrazesat(nGroup)
C Palatability allometry (Le Gland, 10/06/2021)
      Real*8 a_palat(nGroup,nGroup)
      Real*8 b_palat(nGroup,nGroup)
      Real*8 a_biosink(nGroup)
      Real*8 a_biosink_denom(nGroup)
      Real*8 b_biosink(nGroup)
      Real*8 a_bioswim(nGroup)
      Real*8 a_bioswim_denom(nGroup)
      Real*8 b_bioswim(nGroup)
      Real*8 a_ppSig(nGroup)
      Real*8 a_ppOpt(nGroup)
      Real*8 b_ppOpt(nGroup)
      Real*8 a_PCmax(nGroup)
      Real*8 a_PCmax_denom(nGroup)
      Real*8 b_PCmax(nGroup)
C Unimodal growth rate (Le Gland, 10/06/2021)
C     Real*8 b1_PCmax(nGroup)
C     Real*8 b2_PCmax(nGroup)
C     Real*8 c_PCmax(nGroup)
      Real*8 a_qcarbon(nGroup)
      Real*8 b_qcarbon(nGroup)
      Real*8 a_respRate_c(nGroup)
      Real*8 a_respRate_c_denom(nGroup)
      Real*8 b_respRate_c(nGroup)
      Real*8 a_kexcC(nGroup)
      Real*8 b_kexcC(nGroup)
      Real*8 a_vmaxNO3(nGroup)
      Real*8 a_vmaxNO3_denom(nGroup)
      Real*8 b_vmaxNO3(nGroup)
      Real*8 a_ksatNO3(nGroup)
      Real*8 b_ksatNO3(nGroup)
      Real*8 a_Qnmin(nGroup)
      Real*8 b_Qnmin(nGroup)
      Real*8 a_Qnmax(nGroup)
      Real*8 b_Qnmax(nGroup)
      Real*8 a_kexcN(nGroup)
      Real*8 b_kexcN(nGroup)
      Real*8 a_vmaxNO2(nGroup)
      Real*8 a_vmaxNO2_denom(nGroup)
      Real*8 b_vmaxNO2(nGroup)
      Real*8 a_ksatNO2(nGroup)
      Real*8 b_ksatNO2(nGroup)
      Real*8 a_ksatNO2fac(nGroup)
      Real*8 a_vmaxNH4(nGroup)
      Real*8 a_vmaxNH4_denom(nGroup)
      Real*8 b_vmaxNH4(nGroup)
      Real*8 a_ksatNH4(nGroup)
      Real*8 b_ksatNH4(nGroup)
      Real*8 a_ksatNH4fac(nGroup)
      Real*8 a_vmaxN(nGroup)
      Real*8 a_vmaxN_denom(nGroup)
      Real*8 b_vmaxN(nGroup)
      Real*8 a_vmaxPO4(nGroup)
      Real*8 a_vmaxPO4_denom(nGroup)
      Real*8 b_vmaxPO4(nGroup)
      Real*8 a_ksatPO4(nGroup)
      Real*8 b_ksatPO4(nGroup)
      Real*8 a_Qpmin(nGroup)
      Real*8 b_Qpmin(nGroup)
      Real*8 a_Qpmax(nGroup)
      Real*8 b_Qpmax(nGroup)
      Real*8 a_kexcP(nGroup)
      Real*8 b_kexcP(nGroup)
      Real*8 a_vmaxSiO2(nGroup)
      Real*8 a_vmaxSiO2_denom(nGroup)
      Real*8 b_vmaxSiO2(nGroup)
      Real*8 a_ksatSiO2(nGroup)
      Real*8 b_ksatSiO2(nGroup)
      Real*8 a_Qsimin(nGroup)
      Real*8 b_Qsimin(nGroup)
      Real*8 a_Qsimax(nGroup)
      Real*8 b_Qsimax(nGroup)
      Real*8 a_kexcSi(nGroup)
      Real*8 b_kexcSi(nGroup)
      Real*8 a_vmaxFeT(nGroup)
      Real*8 a_vmaxFeT_denom(nGroup)
      Real*8 b_vmaxFeT(nGroup)
      Real*8 a_ksatFeT(nGroup)
      Real*8 b_ksatFeT(nGroup)
      Real*8 a_Qfemin(nGroup)
      Real*8 b_Qfemin(nGroup)
      Real*8 a_Qfemax(nGroup)
      Real*8 b_Qfemax(nGroup)
      Real*8 a_kexcFe(nGroup)
      Real*8 b_kexcFe(nGroup)
C Absolute minima added to prevent:
C 1) phytoplankton from being smaller than Prochlorococcus
C 2) large species (opportunists) from having a low Iopt
      Real*8 a_biovolmin(nGroup)
      Real*8 a_PARoptmin(nGroup)
      Real*8 b_PARoptmin(nGroup)
      Real*8 grp_ExportFracPreyPred(nGroup,nGroup)
      Real*8 grp_ass_eff(nGroup,nGroup)



C !INPUT PARAMETERS: ===================================================
C  Ptr    :: darwin model tracers
C  PAR    :: PAR in uEin/s/m2
C         :: either non-spectral (tlam=1) or waveband total
C  myTime :: current time
C  myIter :: current iteration number
C  myThid :: thread number
C     Real*8 Ptr(nDarwin)
C     Real*8 PAR(nlam)
C Continuous model: temperature dependance is managed within darwin_plankton (Le Gland, 14/01/2021)
C     Real*8 photoTempFunc(nplank)
C     Real*8 reminTempFunc
C     Real*8 uptakeTempFunc
C     Real*8 grazTempFunc(nplank)
C     Real*8 mortTempFunc
C     Real*8 mort2TempFunc
C Continuous model: we separate mathematical manipulations (darwin_plankton.F)
C from the biogeochemistry model (spead_rates.F)
C In spead_rates.F, there are many input and output variables
      Real*8 PAR(nlam)
      Real*8 temp
      INTEGER myThid, myIter
      Real*8 myTime
      Real*8 DIC
      Real*8 NH4
      Real*8 NO2
      Real*8 NO3
      Real*8 PO4
      Real*8 SiO2
      Real*8 FeT
      Real*8 DOC
      Real*8 DON
      Real*8 DOP
      Real*8 DOFe
      Real*8 PIC
      Real*8 POC
      Real*8 PON
      Real*8 POP
      Real*8 POSi
      Real*8 POFe
      INTEGER iG, jG, k
      Real*8 dT
      Real*8 ALK
C O2 must be defined out of "ALLOW_CARBON" to avoid a bug in the bacteria code
C However its value is not set if ALLOW_CARBON is not defined
C (Le Gland, 15/03/2021)
      Real*8 O2
      Real*8 X(nplank)
C     Real*8 mn_bvol(nplank)
C     Real*8 mn_topt(nplank)
C     Real*8 vr_bvol(nplank)
C     Real*8 vr_topt(nplank)
C     Real*8 cv_bvto(nplank)
      Real*8 mn_tr(nplank,nTrait)
      Real*8 vr_tr(nplank,nTrait)
      Real*8 cv_tr(nplank,nCov)

C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTr    :: accumulates computed tendencies
C     Real*8 gTr(nDarwin)

C !OUTPUT PARAMETERS: ==================================================
C  chlout :: computed acclimated chlorophyll if not dynamic
C Something will have to be done with chlout and diags (Le Gland, 10/03/2021)
C     Real*8 chlout(nPhoto)
      Real*8 chlout(nphyp)
      Real*8 diags(darwin_nDiag)
      Real*8 dDIC
      Real*8 dNH4
      Real*8 dNO2
      Real*8 dNO3
      Real*8 dPO4
      Real*8 dSiO2
      Real*8 dFeT
      Real*8 dDOC
      Real*8 dDON
      Real*8 dDOP
      Real*8 dDOFe
      Real*8 dPIC
      Real*8 dPOC
      Real*8 dPON
      Real*8 dPOP
      Real*8 dPOSi
      Real*8 dPOFe
      Real*8 dO2
      Real*8 dALK
C     Real*8 g00(nplank)
C     Real*8 g20(nplank)
C     Real*8 g02(nplank)
C     Real*8 g11(nplank)
      Real*8 gcom(nplank)
      Real*8 acom(nplank)
C     Real*8 a00(nplank)
C     Real*8 a10(nplank)
C     Real*8 a01(nplank)
C     Real*8 a20(nplank)
C     Real*8 a02(nplank)
C     Real*8 a11(nplank)
      Real*8 a_0(nplank)
      Real*8 a_d1(nplank,nTrait)
      Real*8 a_d2(nplank,nTrait)
      Real*8 a_d11(nplank,nCov)
      Real*8 coeff_KTW(nplank)
CEOP


c !LOCAL VARIABLES: ====================================================
      INTEGER j, l
C     INTEGER jz, jp
C More indices are necessary in the general multi-trait model
C (Le Gland, 31/03/2021)
      INTEGER jz, jp, jp1, jp2, jp3, jt, jt1, jt2
C Le Gland (18/12/2020)
      INTEGER g
C Error messages for debugging (Le Gland, 16/03/2021)
      CHARACTER*(MAX_LEN_MBUF) msgBuf
C From DARWIN_INIT_FIXED, as species traits are now variable and can
C no longer be initialized there (Le Gland, 18/03/2021)
      integer iUnit, oUnit1, oUnit2

C Trait steps to estimate derivatives (Le Gland, 10/03/2021)
      Real*8 dbv
      Real*8 dto
C Step for optimum irradiance (Le Gland, 26/03/2021)
      Real*8 dpo
C Weight of each tracer (Le Gland, 15/03/2021)
      Real*8 wght_drv(nTrac)

C Continuous model: temperature dependance is managed within
C darwin_plankton (Le Gland, 14/01/2021)
      Real*8 photoTempFunc(nTrac)
      Real*8 reminTempFunc
      Real*8 uptakeTempFunc
      Real*8 grazTempFunc(nTrac)
      Real*8 mortTempFunc
      Real*8 mort2TempFunc

C Minimum value for optimal irradiance at a given cell volume
C (Le Gland, 15/04/2021)
      Real*8 PARoptmin

C Parameter of the steepness of the limitation by light
C following Edward et al 2015; Boris Sauterey 22/08/2023
      Real*8 alpha
C Intermediate variables related to unimodal growth rate (Le Gland, 10/06/2021)
      Real*8 biovol_norm
      Real*8 alpha1
      Real*8 alpha2

C Continuous model: deriv. from one tracer only (Le Gland, 11/03/2021)
      Real*8 a_1t(nTrac)
      Real*8 Qn(nTrac)
      Real*8 Qp(nTrac)
      Real*8 Qsi(nTrac)
      Real*8 Qfe(nTrac)

C Trait value for each tracer and each variable trait (Le Gland, 31/03/2021)
      Real*8 vl_tr(nTrac,nTrait)
      Real*8 step_tr(nTrait)

      Real*8 regQ

      Real*8 limitpCO2
      Real*8 limitNH4
C Le Gland (26/05/2021)
      Real*8 limitNO
      Real*8 limitNO2
      Real*8 limitNO3
      Real*8 fracNH4
      Real*8 fracNO2
      Real*8 fracNO3
      Real*8 limitn
      Real*8 limitp
      Real*8 limitsi
      Real*8 limitfe
      Real*8 limitnut
      Real*8 limitI
      Real*8 ngrow

      Real*8 muPON
      Real*8 muPOC
      Real*8 muPOP
      Real*8 muPOFe
      Real*8 muDON
      Real*8 muDOC
      Real*8 muDOP
      Real*8 muDOFe
      Real*8 muO
      Real*8 mu

      Real*8 uptakeDIC
      Real*8 uptakeNH4
      Real*8 uptakeNO2
      Real*8 uptakeNO3
      Real*8 uptakeN
      Real*8 uptakePO4
      Real*8 uptakeSiO2
      Real*8 uptakeFeT
      Real*8 consumDIC
      Real*8 consumDIC_PIC
      Real*8 consumNH4
      Real*8 consumNO2
      Real*8 consumNO3
      Real*8 consumPO4
      Real*8 consumSiO2
      Real*8 consumFeT

      Real*8 uptakePON
      Real*8 uptakePOP
      Real*8 uptakePOC
      Real*8 uptakePOFe
      Real*8 uptakeDON
      Real*8 uptakeDOP
      Real*8 uptakeDOC
      Real*8 uptakeDOFe
      Real*8 uptakeO2

      Real*8 respPON
      Real*8 respPOP
      Real*8 respPOC
      Real*8 respPOFe
      Real*8 respPOSi
      Real*8 respDON
      Real*8 respDOP
      Real*8 respDOC
      Real*8 respDOFe

      Real*8 hydrolPON
      Real*8 hydrolPOP
      Real*8 hydrolPOC
      Real*8 hydrolPOFe
      Real*8 solubilPON
      Real*8 solubilPOP
      Real*8 solubilPOC
      Real*8 solubilPOFe

      Real*8 consumPON
      Real*8 consumPOP
      Real*8 consumPOC
      Real*8 consumPOFe
      Real*8 consumPOSi
      Real*8 consumDON
      Real*8 consumDOP
      Real*8 consumDOC
      Real*8 consumDOFe
      Real*8 consumO2

C Le Gland (26/05/2021)
      Real*8 ntot
      Real*8 inhibNH4

      Real*8 alpha_I
      Real*8 alpha_I_growth
      Real*8 PCm
      Real*8 PC
      Real*8 acclim
      Real*8 chl2c
      Real*8 growth
      Real*8 rhochl
      Real*8 Ek
      Real*8 EkoverE

      Real*8 synthChl

      Real*8 reminDOC
      Real*8 reminDON
      Real*8 reminDOP
      Real*8 reminDOFe
      Real*8 reminPOC
      Real*8 reminPON
      Real*8 reminPOP
      Real*8 reminPOSi
      Real*8 reminPOFe
      Real*8 disscPIC

      Real*8 prodNO2
      Real*8 prodNO3

      Real*8 PARtot

      Real*8 tmp



C for grazing

      Real*8 regQc, regQn, regQp, regQfe
      Real*8 sumprey, sumpref, grazphy

      Real*8 preygraz   (nTrac)
      Real*8 preygrazexp(nTrac)
      Real*8 predgrazc  (nTrac)

      Real*8 predexpc, predexpn, predexpp, predexpfe
      Real*8 graz2OC, graz2ON, graz2OP, graz2OFe
      Real*8 graz2POC, graz2PON, graz2POP, graz2POSi, graz2POFe
      Real*8 graz2PIC

      Real*8 expfrac

      Real*8 Xe
      Real*8 mortX
      Real*8 mortX2

      Real*8 exude_DOC
      Real*8 exude_DON
      Real*8 exude_DOP
      Real*8 exude_DOFe

      Real*8 exude_PIC
      Real*8 exude_POC
      Real*8 exude_PON
      Real*8 exude_POP
      Real*8 exude_POSi
      Real*8 exude_POFe

      Real*8 mort_c(nTrac)

      Real*8 respir
      Real*8 respir_c


C Derivatives computed numerically to reduce code complexity
C The number of call to the biogeochemical model is equal to the number of tracers

C Total growth and death rates might actually be more useful than value at average point (?)
C In darwin_plankton.F, I use the value at average trait for better legibility
C For cost efficiency, the cross-derivatives are computed with a non-centered scheme.
C This is not a big problem if the steps are small enough

C-----------------------------------------------------------------------
C Step 1: set master traits and dependent traits of all "tracers"
C (Le Gland, 10/03/2021)
C-----------------------------------------------------------------------

C     WRITE(msgBuf,'(A)') 'DARWIN_SPEAD_RATES: variables declared:'
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )
C     print*,'DARWIN_SPEAD_RATES: variables declared'

C Steps to compute numerical trait derivatives
      dbv = 0.01
      dto = 0.1
      dpo = 0.001

      PARtot = SUM(PAR)

C Traits used to compute trait derivatives
      DO j = 1, nplank

C       biovol(iplank(j)) = EXP(mn_bvol(j))
C       phytoTempOptimum(iplank(j)) = mn_topt(j)

C Weights in the deriv. of non-living tracers
C Avoid explicitly manipulating derivatives of tracer fluxes
C with respect to trait (Le Gland, 11/03/2021)
C Also used to secure mass conservation
        wght_drv(iplank(j)) = 1.0

C quotas (Le Gland, 11/03/2021)

C       IF (isPhoto(iplank(j)) .NE. 0) THEN

C         biovol(iplank(j)+1) = EXP(mn_bvol(j) - dbv)
C         biovol(iplank(j)+2) = EXP(mn_bvol(j) + dbv)
C         biovol(iplank(j)+3) = EXP(mn_bvol(j)      )
C         biovol(iplank(j)+4) = EXP(mn_bvol(j)      )
C         biovol(iplank(j)+5) = EXP(mn_bvol(j) + dbv)

C         phytoTempOptimum(iplank(j)+1) = mn_topt(j)
C         phytoTempOptimum(iplank(j)+2) = mn_topt(j)
C         phytoTempOptimum(iplank(j)+3) = mn_topt(j) - dto
C         phytoTempOptimum(iplank(j)+4) = mn_topt(j) + dto
C         phytoTempOptimum(iplank(j)+5) = mn_topt(j) + dto

CC        wght_drv(iplank(j)) = 1.0 - vr_bvol(j)/(dbv**2)
CC   &                      - vr_topt(j)/(dto**2) + cv_bvto(j)/(dbv*dto)
C         wght_drv(iplank(j)+1) = (1.0/2.0) * vr_bvol(j)/(dbv**2)
C         wght_drv(iplank(j)+2) = (1.0/2.0) * vr_bvol(j)/(dbv**2)
C    &                            - cv_bvto(j)/(dbv*dto)
C         wght_drv(iplank(j)+3) = (1.0/2.0) * vr_topt(j)/(dto**2)
C         wght_drv(iplank(j)+4) = (1.0/2.0) * vr_topt(j)/(dto**2)
C    &                            - cv_bvto(j)/(dbv*dto)
C         wght_drv(iplank(j)+5) = cv_bvto(j)/(dbv*dto)
C         wght_drv(iplank(j)) = 1.0
C    &                        - SUM(wght_drv(iplank(j)+1:iplank(j)+5))


        jt = 1
        IF (traitbvol(j) .NE. 0) THEN
          vl_tr(iplank(j),jt) = mn_tr(j,jt)
          step_tr(jt) = dbv
          jt = jt + 1
        ENDIF
        IF (traittopt(j) .NE. 0) THEN
          vl_tr(iplank(j),jt) = mn_tr(j,jt)
          step_tr(jt) = dto
          jt = jt + 1
        ENDIF
        IF (traitparopt(j) .NE. 0) THEN
          vl_tr(iplank(j),jt) = mn_tr(j,jt)
          step_tr(jt) = dpo
        ENDIF

        jt = iplank(j) + 1
        DO jp = 1, num_trait(j)
          vl_tr(jt,jp)   = mn_tr(j,jp) - step_tr(jp)
          vl_tr(jt+1,jp) = mn_tr(j,jp) + step_tr(jp)
          DO jp2 = 1, num_trait(j)
            IF (jp2 .NE. jp) THEN
              vl_tr(jt,jp2)   = mn_tr(j,jp2)
              vl_tr(jt+1,jp2) = mn_tr(j,jp2)
            ENDIF
          END DO
          wght_drv(jt) = (1./2.) * vr_tr(j,jp)/(step_tr(jp)**2)
          wght_drv(jt+1) = wght_drv(jt)
          jt = jt + 2
        ENDDO

        jp1 = 1
        jp2 = 2
        DO jp = 1, num_cov(j)
C         jp1 = icov(j,jp,1)
C         jp2 = icov(j,jp,2)
          vl_tr(jt,jp1) = mn_tr(j,jp1) + step_tr(jp1)
          vl_tr(jt,jp2) = mn_tr(j,jp2) + step_tr(jp2)
          DO jp3 = 1, num_trait(j)
            IF (jp3 .NE. jp1 .AND. jp3 .NE. jp2) THEN
              vl_tr(jt,jp3) = mn_tr(j,jp3)
            ENDIF
          ENDDO
          wght_drv(jt) = cv_tr(j,jp)/(step_tr(jp1)*step_tr(jp2))
          jt1 = iplank(j) + 2*jp1
          jt2 = iplank(j) + 2*jp2
          wght_drv(jt1) = wght_drv(jt1) - wght_drv(jt)
          wght_drv(jt2) = wght_drv(jt2) - wght_drv(jt)
          jt = jt + 1
          IF (jp2 < num_trait(j)) THEN
            jp2 = jp2 + 1
          ELSE
            jp1 = jp1 + 1
            jp2 = jp1 + 1
          ENDIF
        ENDDO

          wght_drv(iplank(j)) = 1.0 - SUM(wght_drv(iplank(j)+1:jt-1))

        DO jp = iplank(j), iplank(j)+2*num_trait(j)+num_cov(j)
          jt = 1
          IF (traitbvol(j) .NE. 0) THEN
            biovol(jp) = EXP(vl_tr(jp,jt))
            jt = jt + 1
          ENDIF
          IF (traittopt(j) .NE. 0) THEN
            phytoTempOptimum(jp) = vl_tr(jp,jt)
            jt = jt + 1
          ENDIF
          IF (traitparopt(j) .NE. 0) THEN
            PARopt(jp) = EXP(vl_tr(jp,jt))
           
C Maximum growth rate depends on optimal irradiance
C An optimal irradiance lower than 2.5 W/m2 is impossible
C (cf Edwards et al., 2015)
C (Le Gland, 05/04/2021)
            g = group(jp)
            
C The following code evaluated the optimal size as a function of
C nutrient concentrations. It works ONLY if the allometric exponents
C for the Ksats are the same for the nutrients    
C           print*, 'biovol of ', jp, 'before DD =', biovol(jp)
C           print*, 'limiting factors: N = ', a_ksatNO3(g)/(NO3+NO2+NH4)
C     &     , '; P =', a_ksatPO4(g)/PO4, '; F =', a_ksatFeT(g)/FeT

            IF (a_ksatNO3(g)/(NO3+NO2+NH4) .EQ. 
     &      MAX(a_ksatNO3(g)/(NO3+NO2+NH4),
     &      a_ksatPO4(g)/PO4,a_ksatFeT(g)/FeT)) THEN
              IF((NO3+NO2+NH4) .GT. 0D0) THEN
              biovol(jp) = ((NO3+NO2+NH4)*b_PCmax(g)/(a_ksatNO3(g)*
     &        (b_ksatNO3(g)-b_PCmax(g))))**(1/b_ksatNO3(g))
              ENDIF
            ELSEIF (a_ksatPO4(g)/PO4 .EQ. 
     &      MAX(a_ksatNO3(g)/(NO3+NO2+NH4),
     &      a_ksatPO4(g)/PO4,a_ksatFeT(g)/FeT)) THEN
              IF(PO4 .GT. 0D0) THEN
              biovol(jp) = ((PO4)*b_PCmax(g)/(a_ksatPO4(g)*
     &        (b_ksatPO4(g)-b_PCmax(g))))**(1/b_ksatPO4(g))
              ENDIF
            ELSE
              IF(FeT .GT. 0D0) THEN
              biovol(jp) = ((FeT)*b_PCmax(g)/(a_ksatFeT(g)*
     &        (b_ksatFeT(g)-b_PCmax(g))))**(1/b_ksatFeT(g))
              ENDIF
            ENDIF

C           print*, 'biovol of ', jp, 'after DD =', biovol(jp)

C biovolmin is the absolute minimum for cell size
C PARoptmin is the minimum possible value of Iopt for a given cell volume
C (Le Gland, 15/04/2021)
C In an attempt to avoid bugs with some advection/diffusion schemes, I
C now impose that PCmax must be positve (Le Gland, 01/06/2021)
            PARoptmin = a_PARoptmin(g) * biovol(jp)**b_PARoptmin(g)
            
            PARopt(jp) = PARoptmin + SQRT(PARoptmin**2 + 
     &      (3.2-2)*PARtot*PARoptmin + PARtot)

            ksatPAR(jp) = LOG(1+PARchi(jp))
     &                  / (11.574*PARopt(jp)/2.5)
C    &                  / (darwin_inscal_PAR*PARopt(jp)/2.5)
            kinhPAR(jp) = ksatPAR(jp) / PARchi(jp)

            
            PCmax(jp) = MAX(0., a_PCmax(g) * biovol(jp)**b_PCmax(g)
     &                * (1.0 - PARoptmin/PARopt(jp)))
C     &                * (1.0 - (a_biovolmin(g)/biovol(jp)) ) )
C    &         * (1.0 - (a_biovolmin(g)/biovol(jp))**(1+b_PCmax(g)) ) )
CC   &                 * (1.0 - EXP(2.0)/PARopt(jp))
C PCmax for unimodal distribution (Le Gland, 10/06/2021)
C Only works if there is a maximum (b1 and b2 of opposite sign)
C           biovol_norm = biovol(jp) / c_PCmax(g)
C           alpha1 = - b2_PCmax(g) / (b1_PCmax(g) - b2_PCmax(g))
C           alpha2 = + b1_PCmax(g) / (b1_PCmax(g) - b2_PCmax(g))
C           PARoptmin = 2 * 5.0 / (biovol_norm**-0.125 + 1)
C           PARoptmin = 2 * 6.25 / (biovol_norm**-0.20 + 1)
C           PARoptmin = 2 * 5.0 / (biovol_norm**-0.20 + 1)
C           PARoptmin = 2 * 7.5 / (biovol_norm**-0.20 + 1)
C           PARoptmin = 2 * 5.0 / (biovol_norm**-0.20 +
C    &                             biovol_norm**-0.05)
C           PARoptmin = 2 * 6.0 / (biovol_norm**-0.16 + 1)
C           PARoptmin = 2 * 6.0 / (biovol_norm**-0.125 + 1)
C           PCmax(jp) = MAX(0., a_PCmax(g) /
CC   &                      (alpha1 * EXP(-biovol_norm*b1_PCmax(g)) +
CC   &                       alpha2 * EXP(-biovol_norm*b2_PCmax(g)) )
C    &                      (alpha1 * biovol_norm**(-b1_PCmax(g)) +
C    &                       alpha2 * biovol_norm**(-b2_PCmax(g)) )
C    &                      * (1.0 - PARoptmin/PARopt(jp))
C    &                      * (1.0 - (a_biovolmin(g)/biovol(jp)) ) )
          ELSE
C           g = group(jp)
C           PCmax(jp) = MAX(0., a_PCmax(g) /
C    &                      (alpha1 * EXP(-biovol_norm*b1_PCmax(g)) +
C    &                       alpha2 * EXP(-biovol_norm*b2_PCmax(g)) )
C    &                      * (1.0 - (a_biovolmin(g)/biovol(jp)) ) )
            PCmax(jp) = MAX(0., a_PCmax(g) * biovol(jp)**b_PCmax(g) )
          ENDIF
C Smooth change from small to large species (Le Gland, 16/06/2021)
C         ksatNH4(jp)  = 2 * 4.2 * 0.1
C    &                   / (biovol_norm**-0.4 + biovol_norm**-0.05)
C         ksatNH4(jp)  = 2 * 4.2 * 0.085
C    &                   / (biovol_norm**-0.4 + biovol_norm**-0.00)
C         ksatNH4(jp)  = 2 * 3.8 * 1.5 * 0.085
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         ksatNO2(jp)  = 2 * 3.8 * 1.5 *0.17
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         ksatNO3(jp)  = 2 * 3.8 * 1.5 * 0.17
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         ksatPO4(jp)  = 2 * 3.8 * 1.5 * 0.026
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         IF (hasSi(jp) .NE. 0) THEN
C         ksatSiO2(jp) = 2 * 3.8 * 1.5 * 0.024
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         ENDIF
C         ksatFeT(jp)  = 2 * 3.8 * 1.5 * 0.00008
C    &                   / (biovol_norm**-0.375 + biovol_norm**-0.00)
C         IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C           print*, 'species', j, 'tracer', jp, 'trait', jt,
C    &              'biovol', biovol(jp), 'topt', phytoTempOptimum(jp),
C    &              'ksatPAR', ksatPAR(jp), 'kinhPAR', kinhPAR(jp)
CC          print*, 'biovol_norm', biovol_norm, 'alpha1', alpha1,
CC   &              'alpha2', alpha2, 'a_PCmax', a_PCmax(g), 'b1_PCmax',
CC   &              b1_PCmax(g), 'b2_PCmax', b2_PCmax(g), 'PCmax',
CC   &              PCmax(jp), 'PARoptmin', PARoptmin, 'biovolmin',
CC   &              a_biovolmin(g)
C         ENDIF
        END DO







C       END IF

      END DO

C     IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C       print*,'Weight_derivatives', wght_drv, SUM(wght_drv(1:10)),
C    &         SUM(wght_drv(11:20))
C     ENDIF

C Assign quotas when they are constant (Le Gland, 15/03/2021)
      DO j = 1, nTrac
        Qn(j) = R_NC(j)
        Qp(j) = R_PC(j)
        Qsi(j) = R_SiC(j)
        Qfe(j) = R_FeC(j)
      ENDDO

      CALL DARWIN_TEMPFUNC(temp,
     &         photoTempFunc, grazTempFunc, reminTempFunc,
     &         mortTempFunc, mort2TempFunc,
     &         uptakeTempFunc, myThid)

C Continuous model: As traits now vary even for the same species,
C DARWIN_GENRATE_ALLOMETRIC must be called here and not in
C DARWIN_INIT_FIXED (Le Gland, 18/03/2021)

      CALL DARWIN_GENERATE_ALLOMETRIC(myThid)

C Code originally called in DARWIN_INIT_FIXED and executed after
C DARWIN_GENERATE_ALLOMETRIC (Le Gland, 18/03/2021)

C ======================================================================
C read (overrides generated) and write trait namelists

C     WRITE(msgBuf,'(A)') 'DARWIN_SPEAD_RATES: opening data.traits'
C     CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
C    &                   SQUEEZE_RIGHT , 1)

C     CALL MDSFINDUNIT( iUnit, myThid )
CC    CALL OPEN_COPY_DATA_FILE(
C     CALL OPEN_COPY_DATA_FILE_SILENT(
C    I                   'data.traits', 'DARWIN_SPEAD_RATES',
C    O                   iUnit,
C    I                   myThid )

C     IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
C       CALL MDSFINDUNIT( oUnit1, mythid )
C       open(oUnit1,file='darwin_traits.txt',status='unknown')
C     ELSE
C       oUnit1 = -1
C     ENDIF

C     CALL DARWIN_READ_TRAITS(iUnit, oUnit1, myThid)

C     IF ( oUnit1 .GE. 0 ) THEN
C       close(oUnit1)
C     ENDIF
C     CLOSE(iUnit,STATUS='DELETE')

C     WRITE(msgBuf,'(A)') ' ==================================='
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )

C ======================================================================
C deprecation checks

C Continuous model, ExportFracExude is now a property defined for each
C tracer (Le Gland, 18/03/2021)
CC    DO jp = 1, nPlank
C     DO jp = 1, nTrac
C      IF (ExportFracExude(jp) .NE. DARWIN_UNINIT_RL) THEN
C       WRITE(msgBuf,'(2A)')'ExportFracExude can only be used with ',
C    &     'DARWIN_ALLOW_EXUDE.'
C       CALL PRINT_ERROR( msgBuf, myThid )
C       WRITE(msgBuf,'(2A)')'Use ExportFracMort and ExportFracMort2 ',
C    &     'for export due to mortality.'
C       CALL PRINT_ERROR( msgBuf, myThid )
C       STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
C      ENDIF
C     ENDDO

C ======================================================================
C write some traits to files



C-----------------------------------------------------------------------
C End step 1
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 2: Compute time derivatives of all state variables
C (e.g. planton growth, DIC uptake ...) (Le Gland, 11/03/2021)
C-----------------------------------------------------------------------

C     WRITE(msgBuf,'(A)') 'DARWIN_SPEAD_RATES: step 1 completed:'
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )

      consumDIC  = 0.0
      consumDIC_PIC = 0.0
      consumNH4  = 0.0
      consumNO2  = 0.0
      consumNO3  = 0.0
      consumPO4  = 0.0
      consumSiO2 = 0.0
      consumFeT  = 0.0
      consumPON  = 0.0
      consumPOP  = 0.0
      consumPOC = 0.0
      consumPOFe  = 0.0
      consumPOSi  = 0.0
      consumDON  = 0.0
      consumDOP  = 0.0
      consumDOC = 0.0
      consumDOFe  = 0.0
      consumO2 = 0.0
      reminPON  = 0.0
      reminPOP  = 0.0
      reminPOC = 0.0
      reminPOFe  = 0.0
      reminPOSi  = 0.0
      reminDON  = 0.0
      reminDOP  = 0.0
      reminDOC = 0.0
      reminDOFe  = 0.0
      solubilPON  = 0.0
      solubilPOP  = 0.0
      solubilPOC = 0.0
      solubilPOFe  = 0.0
      prodNO2 = 0.0
      prodNO3 = 0.0

C Initialize time derivatives (Le Gland, 11/03/2021)
      dDIC = 0.0
      dNH4 = 0.0
      dNO2 = 0.0
      dNO3 = 0.0
      dPO4 = 0.0
      dSiO2 = 0.0
      dFeT = 0.0
      dDOC = 0.0
      dDON = 0.0
      dDOP = 0.0
      dDOFe = 0.0
      dPIC = 0.0
      dPOC = 0.0
      dPON = 0.0
      dPOP = 0.0
      dPOSi = 0.0
      dPOFe = 0.0
      dO2 = 0.0
      dALK = 0.0

      DO j = 1, nTrac
        a_1t(j) = 0.0D0
      ENDDO


      DO j = 1, nplank
        gcom(j) = 0.0D0
        acom(j) = 0.0D0
        coeff_KTW(j) = 0D0
      ENDDO

C     DO j = 1, nPhoto
      DO j = 1, nphyp
        chlout(j) = 0.0D0
      ENDDO

      DO l=1,darwin_nDiag
        diags(l) = 0.0
      ENDDO


C=======================================================================
C==== phytoplankton ====================================================

      DO j = 1, nPhoto
       IF (isPhoto(j) .NE. 0) THEN
C fixed carbon quota, for now 1.0 (may change later)
C other elements: get quota from corresponding ptracer or set to fixed
c ratio if not variable.

C==== uptake and nutrient limitation ===================================
C       for quota elements, growth is limiteed by available quota,
C       for non-quota elements, by available nutrients in medium

C       to not use PO4, ..., set ksatPO4=0 and vmaxPO4=0 (if DARWIN_ALLOW_PQUOTA)
C       or R_PC=0 (if not)
C       the result will be limitp = 1, uptakePO4 = 0

c phosphorus
        IF (ksatPO4(j) .GT. 0D0) THEN
          limitp = PO4/(PO4 + ksatPO4(j))
        ELSE
          limitp = 1D0
        ENDIF

c silica
        IF (ksatSiO2(j) .GT. 0D0) THEN
          limitsi = SiO2/(SiO2 + ksatSiO2(j))
        ELSE
          limitsi = 1D0
        ENDIF

c iron
        IF (ksatFeT(j) .GT. 0D0) THEN
          limitfe = FeT/(FeT + ksatFeT(j))
        ELSE
          limitfe = 1D0
        ENDIF

c nitrogen
C       inhibNH4 = EXP(-amminhib(j)*NH4)
        limitNH4 = useNH4(j)*NH4/(NH4 + ksatNH4(j))
C inhibNH4 parameterization of Vallina et al. 2008 (Le Gland, 25/03/2021)
C       inhibNH4 = 1 - limitNH4
C       limitNO2 = useNO2(j)*NO2/
C    &   (NO2 + combNO(j)*(NO3 + ksatNO3(j) - ksatNO2(j)) + ksatNO2(j))*
C    &   inhibNH4
C       limitNO3 = useNO3(j)*NO3/
C    &   (combNO(j)*NO2 + NO3 + ksatNO3(j))*inhibNH4
C       limitn = limitNH4 + limitNO2 + limitNO3
C New scheme to ensure that all sizes have the same limiting nutrient
C when all nutrients share the same allometric coefficient
C (Le Gland, 26/05/2021)
        ntot = useNH4(j) * NH4 / ksatNH4(j)
     &       + useNO2(j) * NO2 / ksatNO2(j)
     &       + useNO3(j) * NO3 / ksatNO3(j)
        limitn = ntot / (1 + ntot)
        limitNO = limitn - limitNH4
C Can be zero if both NO2 and NO3 are zero. I add the condition to avoid
C this case (Le Gland, 28/05/2021)
        IF (NO2 .GT. 0D0) THEN
          limitNO2 = limitNO * useNO2(j)*NO2
     &             / (NO2 + useNO3(j)*NO3*ksatNO2(j)/ksatNO3(j))
        ELSE
          limitNO2 = 0D0
        ENDIF
        limitNO3 = limitNO - limitNO2
C       normalize to sum 1
        IF (limitn .GT. 0D0) THEN
          fracNH4 = limitNH4/limitn
          fracNO2 = limitNO2/limitn
          fracNO3 = limitNO3/limitn
        ELSE
          fracNH4 = 0D0
          fracNO2 = 0D0
          fracNO3 = 0D0
        ENDIF
C if diazo, all fracN* == 0 but want no N limitation
        limitn = MIN(1.0, limitn + diazo(j))
c        IF (limitn .GT. 0.0) THEN
c          ngrow = ((10*4+2)/(10*4 + 2*limitNH4/limitn +
c     &                       8*limitNO2/limitn + 10*limitNO3/limitn))
c        ELSE
        ngrow = 1.0
c        ENDIF

        limitnut = MIN(limitn, limitp, limitsi)
        limitnut = MIN(limitnut, limitfe)

        limitpCO2 = 1.

C==== growth ===========================================================

        IF (PARtot .GT. PARmin) THEN
C         only 1 waveband without DARWIN_ALLOW_GEIDER
C         limitI = (1.0D0 - EXP(-PARtot*ksatPAR(j)))*
C     &             EXP(-PARtot*kinhPAR(j)) * normI(j)
          ! Light limitation from Edward et al. 2015; Boris Sauterey 22/08/2023
          ! Carefull /!\ in the model unit of irradiance contrary to Guillaume
          alpha  = 3.2/PARopt(j) !Boris Saterey (2023-11-13)
          limitI = PARtot/(PARtot**2/(alpha*PARopt(j)**2)+(1-2/
     &             (alpha*PARopt(j)))*PARtot+1/alpha)
          PC = PCmax(j)*limitnut*limitI*photoTempFunc(j)*limitpCO2
        ELSE
          PC = 0.0D0
        ENDIF
        synthChl = 0.0


C       growth(j) = PC*ngrow*X(j)
        growth = PC*ngrow*X(plank(j))

        uptakeDIC = growth

C non-quota elements are taken up with fixed stoichiometry
        uptakeN = growth*R_NC(j)
        uptakeNH4 = uptakeN*fracNH4
        uptakeNO2 = uptakeN*fracNO2
        uptakeNO3 = uptakeN*fracNO3
        uptakePO4 = growth*R_PC(j)
        uptakeSiO2 = growth*R_SiC(j)
        uptakeFeT = growth*R_FeC(j)

C==== chlorophyll ======================================================
C=======================================================================
C       consumDIC_PIC = consumDIC_PIC + uptakeDIC*R_PICPOC(j)
C       consumDIC  = consumDIC  + uptakeDIC
C       consumNH4  = consumNH4  + uptakeNH4
C       consumNO2  = consumNO2  + uptakeNO2
C       consumNO3  = consumNO3  + uptakeNO3
C       consumPO4  = consumPO4  + uptakePO4
C       consumSiO2 = consumSiO2 + uptakeSiO2
C       consumFeT  = consumFeT  + uptakeFeT
        consumDIC_PIC = consumDIC_PIC+uptakeDIC*R_PICPOC(j)*wght_drv(j)
        consumDIC  = consumDIC  + uptakeDIC*wght_drv(j)
        consumNH4  = consumNH4  + uptakeNH4*wght_drv(j)
        consumNO2  = consumNO2  + uptakeNO2*wght_drv(j)
        consumNO3  = consumNO3  + uptakeNO3*wght_drv(j)
        consumPO4  = consumPO4  + uptakePO4*wght_drv(j)
        consumSiO2 = consumSiO2 + uptakeSiO2*wght_drv(j)
        consumFeT  = consumFeT  + uptakeFeT*wght_drv(j)

C       diags(iPP) = diags(iPP) + growth
        diags(iPP) = diags(iPP) + growth*wght_drv(j)
C       diags(iPPplank+j-1) = diags(iPPplank+j-1) + growth
        diags(iPPplank+plank(j)-1) = diags(iPPplank+plank(j)-1)
     &                             + growth*wght_drv(j)
        IF (diazo(j) .GT. 0.0D0) THEN
C        diags(iNfix)=diags(iNfix)+uptakeN-uptakeNH4-uptakeNO2-uptakeNO3
         diags(iNfix)=diags(iNfix)
     &   +(uptakeN-uptakeNH4-uptakeNO2-uptakeNO3)*wght_drv(j)
        ENDIF

C=======================================================================

C       gTr(ic+j-1)=gTr(ic+j-1)  + uptakeDIC
        a_1t(j) = a_1t(j) + uptakeDIC
        acom(plank(j)) = acom(plank(j)) + uptakeDIC*wght_drv(j)
        gcom(plank(j)) = gcom(plank(j)) + uptakeDIC*wght_drv(j)

C       IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
CC        print*,'j', j, 'plank(j)', plank(j), 'uptakeDIC', uptakeDIC,
C         print*,'j', j, 'plank(j)', plank(j),
C    &   'a_1t(j)', a_1t(j), 'acom(plank(j))', acom(plank(j)),
C    &   'gcom(plank(j))', gcom(plank(j))

C         print*,'PC', PC, 'PCmax(j)', PCmax(j), 'limitnut', limitnut,
C    &   'limitI', limitI, 'photoTempFunc(j)', photoTempFunc(j),
C    &   'limitpCO2', limitpCO2

C         print*,'limitn', limitn, 'limitNH4', limitNH4, 'limitNO',
C    &    limitNO, 'limitNO2', limitNO2, 'limitNO3', limitNO3,
C    &   'limitp', limitp, 'limitsi', limitsi,
C    &   'limitfe', limitfe, 'normI(j)', normI(j)

C         print*, 'ksatNH4(j)',ksatNH4(j),'ksatNO2(j)',ksatNO2(j),
C    &    'ksatNO3(j)',ksatNO3(j),'ksatPO4',ksatPO4(j),
C    &    'ksatSiO2(j)',ksatSiO2(j),'ksatPAR(j)',ksatPAR(j),
C    &    'ksatFeT(j)',ksatFeT(j)
C       ENDIF





        IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
         print*,'uptake',myiter,k,j,
     &     uptakeDIC,
     &     uptakeNH4,
     &     uptakeNO2,
     &     uptakeNO3,
     &     uptakeN,
     &     uptakePO4,
     &     uptakeSiO2,
     &     uptakeFeT
        ENDIF

C      isPhoto(j)
       ENDIF

C     j
      ENDDO

C If extreme mean traits occur, growth rate should be zero. If NaNs
C occur, all derivatives should be forced to be zero to prevent failure
C If this is all created by transport, future transport may solve it
C (Le Gland, 28/05/2021)
C Change position in the code to still allow for mortality, grazing,
C and chemical reactions (Le Gland, 01/06/2021)
      DO j = 1, nplank
        IF (gcom(j) /= gcom(j) .OR. gcom(j) .LT. -1.0D-6
     & .OR. dDIC /= dDIC) THEN
CC        IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C           print*,'SPEAD is buggy (NaN): all derivatives are set to',
C    &             ' zero to prevent failure', 'coordinates', iG, jG, k,
C    &             ' gcom: ', gcom(j)
CC        ENDIF
          chlout = 0D0
          diags = 0D0
          dDIC  = 0D0
          dNH4  = 0D0
          dNO2  = 0D0
          dNO3  = 0D0
          dPO4  = 0D0
          dSiO2 = 0D0
          dFeT  = 0D0
          dDOC  = 0D0
          dDON  = 0D0
          dDOP  = 0D0
          dDOFe = 0D0
          dPIC  = 0D0
          dPOC  = 0D0
          dPON  = 0D0
          dPOP  = 0D0
          dPOSi = 0D0
          dPOFe = 0D0
          dO2 = 0D0
          dALK = 0D0
          gcom = 0D0
          a_0  = 0D0
          a_d1 = 0D0
          a_d2 = 0D0
          a_d11 = 0D0
          acom = 0D0
        ENDIF
      ENDDO
C=======================================================================
C==== bacteria =========================================================

      DO j = 1, nplank
       IF (bactType(j) .NE. 0) THEN

        uptakeO2  = 0.D0
        uptakeNO3 = 0.D0
        uptakePOC = 0.D0
        uptakePON = 0.D0
        uptakePOP = 0.D0
        uptakePOFe = 0.D0
        uptakeDOC = 0.D0
        uptakeDON = 0.D0
        uptakeDOP = 0.D0
        uptakeDOFe = 0.D0
        hydrolPOC = 0.D0
        hydrolPON = 0.D0
        hydrolPOP = 0.D0
        hydrolPOFe = 0.D0
        respPOC = 0.D0
        respPON = 0.D0
        respPOP = 0.D0
        respPOFe = 0.D0
        respDOC = 0.D0
        respDON = 0.D0
        respDOP = 0.D0
        respDOFe = 0.D0
C       growth(j) = 0.D0
        growth = 0.D0

        IF (isAerobic(j) .NE. 0) THEN
          muO = yieldO2(j)*pcoefO2*O2
        ELSEIF (isDenit(j) .NE. 0) THEN
          muO = yieldNO3(j)*pmaxDIN*NO3/(NO3 + ksatDIN)*reminTempFunc
        ENDIF

C       POM-consuming (particle-associated)
        IF (bactType(j) .EQ. 1) THEN

          PCm = yield(j)*PCmax(j)*reminTempFunc
          muPON  = PCm*PON/(PON + ksatPON(j))
          muPOC  = PCm*POC/(POC + ksatPOC(j))
          muPOP  = PCm*POP/(POP + ksatPOP(j))
          muPOFe = PCm*POFe/(POFe + ksatPOFe(j))
          mu = MIN(muPON, muPOC, muPOP, muPOFe, muO)

C         growth(j) = mu*X(j)
          growth = mu*X(plank(j))

C         uptakePOC = alpha_hydrol*growth(j)/yield(j)
          uptakePOC = alpha_hydrol*growth/yield(j)
          uptakePON  = uptakePOC*R_NC(j)
          uptakePOP  = uptakePOC*R_PC(j)
          uptakePOFe = uptakePOC*R_FeC(j)
C         O2/NO3 is only used for the part of POC that is metabolized:
C         uptakeO2 = isAerobic(j)*growth(j)/yieldO2(j)
C         uptakeNO3 = isDenit(j)*growth(j)/yieldNO3(j)
          uptakeO2 = isAerobic(j)*growth/yieldO2(j)
          uptakeNO3 = isDenit(j)*growth/yieldNO3(j)

C         This is the part of POM that is hydrolized into DOM:
C         hydrolPOC = (alpha_hydrol-1)*growth(j)/yield(j)
          hydrolPOC = (alpha_hydrol-1)*growth/yield(j)
          hydrolPON  = hydrolPOC*R_NC(j)
          hydrolPOP  = hydrolPOC*R_PC(j)
          hydrolPOFe = hydrolPOC*R_FeC(j)

C         These are the bacteria products for remineralization of POM:
C         respPOC = growth(j)*(1/yield(j)-1)
          respPOC = growth*(1/yield(j)-1)
          respPON  = respPOC*R_NC(j)
          respPOP  = respPOC*R_PC(j)
          respPOFe = respPOC*R_FeC(j)

C       DOM-consuming (free-living):
        ELSEIF (bactType(j) .EQ. 2) THEN

          PCm = yield(j)*PCmax(j)*reminTempFunc
          muDON  = PCm*DON/(DON + ksatDON(j))
          muDOC  = PCm*DOC/(DOC + ksatDOC(j))
          muDOP  = PCm*DOP/(DOP + ksatDOP(j))
          muDOFe = PCm*DOFe/(DOFe + ksatDOFe(j))
          mu = MIN(muDON, muDOC, muDOP, muDOFe, muO)

C         growth(j) = mu*X(j)
          growth = mu*X(plank(j))

C         uptakeDOC = growth(j)/yield(j)
          uptakeDOC = growth/yield(j)
          uptakeDON  = uptakeDOC*R_NC(j)
          uptakeDOP  = uptakeDOC*R_PC(j)
          uptakeDOFe = uptakeDOC*R_FeC(j)
C         uptakeO2 = isAerobic(j)*growth(j)/yieldO2(j)
C         uptakeNO3 = isDenit(j)*growth(j)/yieldNO3(j)
          uptakeO2 = isAerobic(j)*growth/yieldO2(j)
          uptakeNO3 = isDenit(j)*growth/yieldNO3(j)

C         DOC respired to DIC
C         respDOC = growth(j)*(1/yield(j)-1)
          respDOC = growth*(1/yield(j)-1)
          respDON  = respDOC*R_NC(j)
          respDOP  = respDOC*R_PC(j)
          respDOFe = respDOC*R_FeC(j)

        ENDIF

C       diags(iPPplank+j-1) = diags(iPPplank+j-1) + growth(j)
        diags(iPPplank+plank(j)-1) = diags(iPPplank+plank(j)-1)
     &                             + growth*wght_drv(j)

C       gTr(ic+j-1)=gTr(ic+j-1) + growth(j)
        a_1t(j) = a_1t(j) + growth
        acom(plank(j)) = acom(plank(j)) + growth*wght_drv(j)
        gcom(plank(j)) = gcom(plank(j)) + growth*wght_drv(j)

C==== Cumulative consum, remin, and prod ===============================
C       consumNO3  = consumNO3  + uptakeNO3
        consumNO3  = consumNO3  + uptakeNO3*wght_drv(j)

C       add B consum and accumulating remin, and prod:
C       consumO2 = consumO2 + uptakeO2
        consumO2 = consumO2 + uptakeO2*wght_drv(j)

C       consumDOC = consumDOC + uptakeDOC
C       consumDON = consumDON + uptakeDON
C       consumDOP = consumDOP + uptakeDOP
C       consumDOFe = consumDOFe + uptakeDOFe
        consumDOC = consumDOC + uptakeDOC*wght_drv(j)
        consumDON = consumDON + uptakeDON*wght_drv(j)
        consumDOP = consumDOP + uptakeDOP*wght_drv(j)
        consumDOFe = consumDOFe + uptakeDOFe*wght_drv(j)

C       consumPOC = consumPOC + uptakePOC
C       consumPON = consumPON + uptakePON
C       consumPOP = consumPOP + uptakePOP
C       consumPOFe = consumPOFe + uptakePOFe
        consumPOC = consumPOC + uptakePOC*wght_drv(j)
        consumPON = consumPON + uptakePON*wght_drv(j)
        consumPOP = consumPOP + uptakePOP*wght_drv(j)
        consumPOFe = consumPOFe + uptakePOFe*wght_drv(j)

C       reminPOC = reminPOC + respPOC
C       reminPON = reminPON + respPON
C       reminPOP = reminPOP + respPOP
C       reminPOFe = reminPOFe + respPOFe
        reminPOC = reminPOC + respPOC*wght_drv(j)
        reminPON = reminPON + respPON*wght_drv(j)
        reminPOP = reminPOP + respPOP*wght_drv(j)
        reminPOFe = reminPOFe + respPOFe*wght_drv(j)

C       solubilPOC = solubilPOC + hydrolPOC
C       solubilPON = solubilPON + hydrolPON
C       solubilPOP = solubilPOP + hydrolPOP
C       solubilPOFe = solubilPOFe + hydrolPOFe
        solubilPOC = solubilPOC + hydrolPOC*wght_drv(j)
        solubilPON = solubilPON + hydrolPON*wght_drv(j)
        solubilPOP = solubilPOP + hydrolPOP*wght_drv(j)
        solubilPOFe = solubilPOFe + hydrolPOFe*wght_drv(j)

C       reminDOC = reminDOC + respDOC
C       reminDON = reminDON + respDON
C       reminDOP = reminDOP + respDOP
C       reminDOFe = reminDOFe + respDOFe
        reminDOC = reminDOC + respDOC*wght_drv(j)
        reminDON = reminDON + respDON*wght_drv(j)
        reminDOP = reminDOP + respDOP*wght_drv(j)
        reminDOFe = reminDOFe + respDOFe*wght_drv(j)

       ENDIF
C     j loop end
      ENDDO

C=======================================================================
C=======================================================================

C     gTr(iDIC )=gTr(iDIC ) - consumDIC - consumDIC_PIC
C     gTr(iNH4 )=gTr(iNH4 ) - consumNH4
C     gTr(iNO2 )=gTr(iNO2 ) - consumNO2
C     gTr(iNO3 )=gTr(iNO3 ) - consumNO3
C     gTr(iPO4 )=gTr(iPO4 ) - consumPO4
C     gTr(iSiO2)=gTr(iSiO2) - consumSiO2
C     gTr(iFeT )=gTr(iFeT ) - consumFeT

      dDIC  = dDIC  - consumDIC - consumDIC_PIC
      dNH4  = dNH4  - consumNH4
      dNO2  = dNO2  - consumNO2
      dNO3  = dNO3  - consumNO3
      dPO4  = dPO4  - consumPO4
      dSiO2 = dSiO2 - consumSiO2
      dFeT  = dFeT  - consumFeT

C     print*,'dDIC', dDIC, 'consumDIC', consumDIC, 'consumDIC_PIC',
C    & consumDIC_PIC

C parameterized remineralization; want to set all K except KPOSi to zero
C if running with bacteria
      respDOC  = reminTempFunc*KDOC *DOC
      respDON  = reminTempFunc*KDON *DON
      respDOP  = reminTempFunc*KDOP *DOP
      respDOFe = reminTempFunc*KDOFe*DOFe
      respPOC  = reminTempFunc*KPOC *POC
      respPON  = reminTempFunc*KPON *PON
      respPOP  = reminTempFunc*KPOP *POP
      respPOSi = reminTempFunc*KPOSi*POSi
      respPOFe = reminTempFunc*KPOFe*POFe

      consumDOC  = consumDOC  + respDOC
      consumDON  = consumDON  + respDON
      consumDOP  = consumDOP  + respDOP
      consumDOFe = consumDOFe + respDOFe
      consumPOC  = consumPOC  + respPOC
      consumPON  = consumPON  + respPON
      consumPOP  = consumPOP  + respPOP
      consumPOSi = consumPOSi + respPOSi
      consumPOFe = consumPOFe + respPOFe

      reminDOC  = reminDOC  + respDOC
      reminDON  = reminDON  + respDON
      reminDOP  = reminDOP  + respDOP
      reminDOFe = reminDOFe + respDOFe
      reminPOC  = reminPOC  + respPOC
      reminPON  = reminPON  + respPON
      reminPOP  = reminPOP  + respPOP
      reminPOSi = reminPOSi + respPOSi
      reminPOFe = reminPOFe + respPOFe

      consumO2  = consumO2  + respDOP*R_OP
      consumO2  = consumO2  + respPOP*R_OP

      disscPIC = Kdissc*PIC

c nitrogen chemistry
c NH4 -> NO2 -> NO3 by bacterial action, parameterized
c Should this depend on temperature ? (Le Gland, 03/06/2021)
      prodNO2 = knita*NH4
      prodNO3 = knitb*NO2
      IF (PAR_oxi .NE. 0.0D0) THEN
        prodNO2 = prodNO2*MAX(0.0, 1.0 - PARtot/PAR_oxi)
        prodNO3 = prodNO3*MAX(0.0, 1.0 - PARtot/PAR_oxi)
      ENDIF



C==== apply tendencies =================================================

c production of O2 by photosynthesis
C     gTr(iO2  )=gTr(iO2  ) + R_OP*consumPO4
      dO2 = dO2 + R_OP*consumPO4
c loss of O2 by remineralization
      IF (O2 .GT. O2crit) THEN
C       gTr(iO2)=gTr(iO2) - consumO2
        dO2 = dO2 - consumO2
      ENDIF

C     gTr(iALK)=gTr(iALK) - (prodNO3 - consumNO3)
C    &                    - 2.0D0*(consumDIC_PIC - disscPIC)
      dALK = dALK - (prodNO3 - consumNO3)
     &                    - 2.0D0*(consumDIC_PIC - disscPIC)

C     gTr(iDIC )=gTr(iDIC ) + reminDOC + disscPIC
C     gTr(iNH4 )=gTr(iNH4 ) + reminDON - prodNO2
C     gTr(iNO2 )=gTr(iNO2 ) + prodNO2 - prodNO3
C     gTr(iNO3 )=gTr(iNO3 ) + prodNO3
      dDIC = dDIC + reminDOC + disscPIC
      dNH4 = dNH4 + reminDON - prodNO2
      dNO2 = dNO2 + prodNO2 - prodNO3
      dNO3 = dNO3 + prodNO3
      diags(iDenitN) = 0.0

C     gTr(iPO4 )=gTr(iPO4 ) + reminDOP
C     gTr(iFeT )=gTr(iFeT ) + reminDOFe
C     gTr(iSiO2)=gTr(iSiO2)             + reminPOSi
      dPO4  = dPO4  + reminDOP
      dFeT  = dFeT  + reminDOFe
      dSiO2 = dSiO2 + reminPOSi

C     DOC is created by #4 PA-assoc solubilization and consumed by #5
C     gTr(iDOC )=gTr(iDOC ) + solubilPOC - consumDOC
C     gTr(iDON )=gTr(iDON ) + solubilPON - consumDON
C     gTr(iDOP )=gTr(iDOP ) + solubilPOP - consumDOP
C     gTr(iDOFe)=gTr(iDOFe) + solubilPOFe - consumDOFe
      dDOC  = dDOC  + solubilPOC - consumDOC
      dDON  = dDON  + solubilPON - consumDON
      dDOP  = dDOP  + solubilPOP - consumDOP
      dDOFe = dDOFe + solubilPOFe - consumDOFe

C     gTr(iPIC )=gTr(iPIC ) - disscPIC
C     gTr(iPOC )=gTr(iPOC ) - consumPOC
C     gTr(iPON )=gTr(iPON ) - consumPON
C     gTr(iPOP )=gTr(iPOP ) - consumPOP
C     gTr(iPOFe)=gTr(iPOFe) - consumPOFe
C     gTr(iPOSi)=gTr(iPOSi) - consumPOSi
      dPIC  = dPIC  - disscPIC
      dPOC  = dPOC  - consumPOC
      dPON  = dPON  - consumPON
      dPOP  = dPOP  - consumPOP
      dPOFe = dPOFe - consumPOFe
      dPOSi = dPOSi - consumPOSi

C     gTr(iDIC )=gTr(iDIC ) + reminPOC
C     gTr(iNH4 )=gTr(iNH4 ) + reminPON
C     gTr(iPO4 )=gTr(iPO4 ) + reminPOP
C     gTr(iFeT )=gTr(iFeT ) + reminPOFe
      dDIC = dDIC + reminPOC
      dNH4 = dNH4 + reminPON
      dPO4 = dPO4 + reminPOP
      dFeT = dFeT + reminPOFe

      diags(iConsDIN) = consumNH4 + consumNO2 + consumNO3
      diags(iConsPO4) = consumPO4
      diags(iConsSi)  = consumSiO2
      diags(iConsFe)  = consumFeT

C     print*,'dDIC', dDIC, 'reminDOC', reminDOC, 'disscPIC',
C    & disscPIC, 'reminPOC', reminPOC

C Rates that depend on the traits of all plankton groups (e.g. grazing losses/gains)
C Complex but far less cost expensive than the discrete approach

C==== grazing ==========================================================

      DO j = 1, nTrac
       preygraz(j)   = 0.0
       preygrazexp(j) = 0.0
       predgrazc(j)  = 0.0
      ENDDO
      graz2POC  = 0.0
      graz2PON  = 0.0
      graz2POP  = 0.0
      graz2POSI = 0.0
      graz2POFE = 0.0
      graz2OC   = 0.0
      graz2ON   = 0.0
      graz2OP   = 0.0
      graz2OFE  = 0.0
      graz2PIC  = 0.0

      regQn  = 1.0
      regQp  = 1.0
      regQfe = 1.0
      regQc  = 1.0

C=======================================================================
C     DO jz = 1, nplank
      DO jz = 1, nTrac
       IF (isPred(jz).NE.0) THEN

C       regulate grazing near full quota
        regQc = 1.0D0
        regQc = regQc**hillnumGraz

CC wght_drv was lacking in several lines in the grazing part (Le Gland, 23/03/2021)
        sumprey = 0.0
        sumpref = 0.0
C       DO jp = 1, nplank
        DO jp = 1, nTrac
        IF (palat(jp,jz).NE.0D0) THEN
C        sumprey = sumprey + palat(jp,jz)*X(jp)
CC       sumprey = sumprey + palat(jp,jz)*X(plank(jp))
         sumprey = sumprey + palat(jp,jz)*X(plank(jp))*wght_drv(jp)
C        sumpref = sumpref + palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)
C        sumpref = sumpref + palat(jp,jz)*palat(jp,jz)
C    &             *X(plank(jp))*X(plank(jp))*wght_drv(jp)
C Enable Kill The Winner (KTW) different from 2 (Le Gland, 27/08/2021)
         sumpref = sumpref + (palat(jp,jz)**a_KTW)
     &             * (X(plank(jp))**a_KTW) * wght_drv(jp)
CC   &             *X(plank(jp))*X(plank(jp))
        ENDIF
        ENDDO
        sumprey = MAX(0.0, sumprey - phygrazmin)
        sumpref = MAX(phygrazmin, sumpref)
C       tmp = grazemax(jz)*grazTempFunc(jz)**tempGraz(jz)*X(jz)*
        tmp = grazemax(jz)*grazTempFunc(jz)**tempGraz(jz)*X(plank(jz))*
     &    (sumprey**hollexp/(sumprey**hollexp+kgrazesat(jz)**hollexp))*
     &    (1.0 - EXP(-inhib_graz*sumprey))**inhib_graz_exp

        predexpc  = 0.0D0
        predexpn  = 0.0D0
        predexpp  = 0.0D0
        predexpfe = 0.0D0
C       DO jp = 1, nplank
        DO jp = 1, nTrac
         IF (palat(jp,jz).NE.0D0) THEN
C         grazphy = tmp*palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)/sumpref
C         grazphy = tmp*palat(jp,jz)*palat(jp,jz)
C    &              *X(plank(jp))*X(plank(jp))/sumpref
C Enable Kill The Winner (KTW) different from 2 (Le Gland, 27/08/2021)
          grazphy = tmp*((palat(jp,jz)*X(plank(jp)))**a_KTW)/sumpref

          expFrac = ExportFracPreyPred(jp,jz)

C         preygraz(jp) = preygraz(jp) + grazphy
C         preygrazexp(jp) = preygrazexp(jp) + expFrac*grazphy
          preygraz(jp) = preygraz(jp) + grazphy*wght_drv(jz)
          preygrazexp(jp) = preygrazexp(jp)
     &                    + expFrac*grazphy*wght_drv(jz)

C         predgrazc(jz) = predgrazc(jz) + grazphy*asseff(jp,jz)*regQc
C         predexpc = predexpc + expFrac*grazphy*asseff(jp,jz)*regQc
          predgrazc(jz) = predgrazc(jz)
     &                  + grazphy*asseff(jp,jz)*wght_drv(jp)
          predexpc = predexpc + expFrac*grazphy*asseff(jp,jz)
     &               *wght_drv(jp)*wght_drv(jz)
C         IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C           print*, 'predator', jz, 'prey', jp, 'palat', palat(jp,jz),
C    &              'sumprey', sumprey, 'grazemax(jz)', grazemax(jz),
C    &              'grazTempFunc(jz)', grazTempFunc(jz), 'tmp', tmp,
C    &              'grazphy', grazphy, 'preygraz(jp)', preygraz(jp),
C    &              'predgrazc(jz)', predgrazc(jz), 'Temperature', temp,
C    &              'hollexp', hollexp, 'kgrazesat(jz)', kgrazesat(jz),
C    &              'inhib_graz', inhib_graz, 'inhib_graz_exp',
C    &              inhib_graz_exp, 'pred. conc.', X(plank(jz))
C         ENDIF
         ENDIF
        ENDDO

C organic-matter gain will be total preygraz - predgraz
C       graz2OC   = graz2OC  - predgrazc(jz)
        graz2OC   = graz2OC  - predgrazc(jz)*wght_drv(jz)
        graz2POC  = graz2POC - predexpc

C       graz2ON   = graz2ON  - predgrazc(jz)*Qn(jz)
        graz2ON   = graz2ON  - predgrazc(jz)*Qn(jz)*wght_drv(jz)
        graz2PON  = graz2PON - predexpc     *Qn(jz)

C       graz2OP   = graz2OP  - predgrazc(jz)*Qp(jz)
        graz2OP   = graz2OP  - predgrazc(jz)*Qp(jz)*wght_drv(jz)
        graz2POP  = graz2POP - predexpc     *Qp(jz)

C       graz2OFe  = graz2OFe  - predgrazc(jz)*Qfe(jz)
        graz2OFe  = graz2OFe  - predgrazc(jz)*Qfe(jz)*wght_drv(jz)
        graz2POFe = graz2POFe - predexpc     *Qfe(jz)

       ENDIF
C     end predator loop
      ENDDO

C     DO jp = 1, nplank
      DO jp = 1, nTrac
       IF (isPrey(jp).NE.0) THEN
C         graz2OC  = graz2OC  + preygraz(jp)
C         graz2ON  = graz2ON  + preygraz(jp)*Qn (jp)
C         graz2OP  = graz2OP  + preygraz(jp)*Qp (jp)
C         graz2POSi = graz2POSi + preygraz(jp)*Qsi(jp)
C         graz2OFe = graz2OFe + preygraz(jp)*Qfe(jp)
          graz2OC  = graz2OC  + preygraz(jp)*wght_drv(jp)
          graz2ON  = graz2ON  + preygraz(jp)*Qn(jp)*wght_drv(jp)
          graz2OP  = graz2OP  + preygraz(jp)*Qp(jp)*wght_drv(jp)
          graz2POSi = graz2POSi + preygraz(jp)*Qsi(jp)*wght_drv(jp)
          graz2OFe = graz2OFe + preygraz(jp)*Qfe(jp)*wght_drv(jp)
C         graz2PIC = graz2PIC + preygraz(jp)*R_PICPOC(jp)
          graz2PIC = graz2PIC + preygraz(jp)*R_PICPOC(jp)*wght_drv(jp)

C         graz2POC  = graz2POC  + preygrazexp(jp)
C         graz2PON  = graz2PON  + preygrazexp(jp)*Qn (jp)
C         graz2POP  = graz2POP  + preygrazexp(jp)*Qp (jp)
C         graz2POFe = graz2POFe + preygrazexp(jp)*Qfe(jp)
          graz2POC  = graz2POC  + preygrazexp(jp)*wght_drv(jp)
          graz2PON  = graz2PON  + preygrazexp(jp)*Qn(jp)*wght_drv(jp)
          graz2POP  = graz2POP  + preygrazexp(jp)*Qp(jp)*wght_drv(jp)
          graz2POFe = graz2POFe + preygrazexp(jp)*Qfe(jp)*wght_drv(jp)
       ENDIF
      ENDDO

C==== tendencies =======================================================

C     gTr(iDOC )=gTr(iDOC ) + graz2OC  - graz2POC
C     gTr(iDON )=gTr(iDON ) + graz2ON  - graz2PON
C     gTr(iDOP )=gTr(iDOP ) + graz2OP  - graz2POP
C     gTr(iDOFe)=gTr(iDOFe) + graz2OFe - graz2POFe
C     gTr(iPOC )=gTr(iPOC ) + graz2POC
C     gTr(iPON )=gTr(iPON ) + graz2PON
C     gTr(iPOP )=gTr(iPOP ) + graz2POP
C     gTr(iPOSi)=gTr(iPOSi) + graz2POSi
C     gTr(iPOFe)=gTr(iPOFe) + graz2POFe
      dDOC  = dDOC  + graz2OC  - graz2POC
      dDON  = dDON  + graz2ON  - graz2PON
      dDOP  = dDOP  + graz2OP  - graz2POP
      dDOFe = dDOFe + graz2OFe - graz2POFe
      dPOC  = dPOC  + graz2POC
      dPON  = dPON  + graz2PON
      dPOP  = dPOP  + graz2POP
      dPOSi = dPOSi + graz2POSi
      dPOFe = dPOFe + graz2POFe
C     gTr(iPIC )=gTr(iPIC ) + graz2PIC
      dPIC = dPIC + graz2PIC

C     DO jp = 1, nplank
      DO jp = 1, nTrac
      IF (isPrey(jp).NE.0) THEN
C      gTr(ic+jp-1)= gTr(ic+jp-1) - preygraz(jp)
       a_1t(jp) = a_1t(jp) - preygraz(jp)
       acom(plank(jp)) = acom(plank(jp)) - preygraz(jp)*wght_drv(jp)
C I Added the conditions on X>0 to avoid Nans (Boris 07/01/24)
        IF (X(plank(jp)) .GT. 0) THEN
           coeff_KTW(plank(jp)) = coeff_KTW(plank(jp)) + preygraz(jp)
     &             *(1D0 - (1D0)/a_KTW)*wght_drv(jp)/X(plank(jp))
        ELSE
           coeff_KTW(plank(jp)) = coeff_KTW(plank(jp)) + 0D0
        ENDIF
        
C       IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C         print*, 'coeff_KTW', coeff_KTW(plank(jp)), 'preygraz',
C    &            preygraz(jp), 'a_KTW', a_KTW, '1-1/a',
C    &            (1D0 - (1D0)/a_KTW), 'wght_drv', wght_drv(jp),
C    &            'X', X(plank(jp)), 'added coeff_KTW', preygraz(jp)*
C    &            (1D0 - (1D0)/a_KTW)*wght_drv(jp)/X(plank(jp))
C       ENDIF
      ENDIF
      ENDDO

C     DO jz = 1, nplank
      DO jz = 1, nTrac
      IF (isPred(jz).NE.0) THEN
C      gTr(ic+jz-1)=gTr(ic+jz-1) + predgrazc(jz)
       a_1t(jz) = a_1t(jz) + predgrazc(jz)
       acom(plank(jz)) = acom(plank(jz)) + predgrazc(jz)*wght_drv(jz)
       gcom(plank(jz)) = gcom(plank(jz)) + predgrazc(jz)*wght_drv(jz)
      ENDIF
      ENDDO

C     DO jp = 1, nplank
      DO jp = 1, nTrac
C       diags(iGRplank+jp-1) = preygraz(jp)
C       diags(iGRplank+plank(jp)-1) = preygraz(jp)*wght_drv(jp)
        diags(iGRplank+plank(jp)-1) = diags(iGRplank+plank(jp)-1)
     &                              + preygraz(jp)*wght_drv(jp)
      ENDDO
C     DO jz = 1, nplank
      DO jz = 1, nTrac
C       diags(iGrGn+jz-1) = predgrazc(jz)
C       diags(iGrGn+plank(jz)-1) = predgrazc(jz)*wght_drv(jz)
        diags(iGrGn+plank(jz)-1) = diags(iGrGn+plank(jz)-1)
     &                           + predgrazc(jz)*wght_drv(jz)
      ENDDO

C==== mortality ========================================================
      exude_DOC  = 0.0D0
      exude_POC  = 0.0D0
      exude_DON  = 0.0D0
      exude_PON  = 0.0D0
      exude_DOFe = 0.0D0
      exude_POFe = 0.0D0
      exude_DOP  = 0.0D0
      exude_POP  = 0.0D0
      exude_POSi = 0.0D0
      exude_PIC  = 0.0D0
      respir     = 0.0D0

C     DO jp = 1, nplank
      DO jp = 1, nTrac
C       Xe = MAX(0D0, X(jp) - Xmin(jp))
        Xe = MAX(0D0, X(plank(jp)) - Xmin(jp))
        mortX = mort(jp)*Xe*mortTempFunc**tempMort(jp)
        mortX2= mort2(jp)*Xe*Xe*mort2TempFunc**tempMort2(jp)

        mort_c(jp) = mortX + mortX2

C       exude_DOC = exude_DOC + (1.-ExportFracMort(jp)) *mortX
C    &                        + (1.-ExportFracMort2(jp))*mortX2
C       exude_POC = exude_POC +     ExportFracMort(jp)  *mortX
C    &                        +     ExportFracMort2(jp) *mortX2
        exude_DOC = exude_DOC
     &            + (1.-ExportFracMort(jp)) *mortX *wght_drv(jp)
     &            + (1.-ExportFracMort2(jp))*mortX2*wght_drv(jp)
        exude_POC = exude_POC
     &            + ExportFracMort(jp) *mortX *wght_drv(jp)
     &            + ExportFracMort2(jp)*mortX2*wght_drv(jp)

C       exude_DON = exude_DON + (1.-ExportFracMort(jp)) *mortX *Qn(jp)
C    &                        + (1.-ExportFracMort2(jp))*mortX2*Qn(jp)
C       exude_PON = exude_PON +     ExportFracMort(jp)  *mortX *Qn(jp)
C    &                        +     ExportFracMort2(jp) *mortX2*Qn(jp)
        exude_DON = exude_DON
     &            + (1.-ExportFracMort(jp)) *mortX *Qn(jp)*wght_drv(jp)
     &            + (1.-ExportFracMort2(jp))*mortX2*Qn(jp)*wght_drv(jp)
        exude_PON = exude_PON
     &            + ExportFracMort(jp) *mortX *Qn(jp)*wght_drv(jp)
     &            + ExportFracMort2(jp)*mortX2*Qn(jp)*wght_drv(jp)

C       exude_DOP = exude_DOP + (1.-ExportFracMort(jp)) *mortX *Qp(jp)
C    &                        + (1.-ExportFracMort2(jp))*mortX2*Qp(jp)
C       exude_POP = exude_POP +     ExportFracMort(jp)  *mortX *Qp(jp)
C    &                        +     ExportFracMort2(jp) *mortX2*Qp(jp)
        exude_DOP = exude_DOP
     &            + (1.-ExportFracMort(jp)) *mortX *Qp(jp)*wght_drv(jp)
     &            + (1.-ExportFracMort2(jp))*mortX2*Qp(jp)*wght_drv(jp)
        exude_POP = exude_POP
     &            + ExportFracMort(jp) *mortX *Qp(jp)*wght_drv(jp)
     &            + ExportFracMort2(jp)*mortX2*Qp(jp)*wght_drv(jp)

C       exude_DOFe= exude_DOFe+ (1.-ExportFracMort(jp)) *mortX *Qfe(jp)
C    &                        + (1.-ExportFracMort2(jp))*mortX2*Qfe(jp)
C       exude_POFe= exude_POFe+     ExportFracMort(jp)  *mortX *Qfe(jp)
C    &                        +     ExportFracMort2(jp) *mortX2*Qfe(jp)
        exude_DOFe = exude_DOFe
     &           + (1.-ExportFracMort(jp)) *mortX *Qfe(jp)*wght_drv(jp)
     &           + (1.-ExportFracMort2(jp))*mortX2*Qfe(jp)*wght_drv(jp)
        exude_POFe = exude_POFe
     &           + ExportFracMort(jp) *mortX *Qfe(jp)*wght_drv(jp)
     &           + ExportFracMort2(jp)*mortX2*Qfe(jp)*wght_drv(jp)

C       exude_POSi = exude_POSi + mort_c(jp)*Qsi(jp)
        exude_POSi = exude_POSi + mort_c(jp)*Qsi(jp)*wght_drv(jp)

C       exude_PIC = exude_PIC + mort_c(jp)*R_PICPOC(jp)
        exude_PIC = exude_PIC + mort_c(jp)*R_PICPOC(jp)*wght_drv(jp)

        respir_c = respRate(jp)*Xe*reminTempFunc
C       respir = respir + respir_c
        respir = respir + respir_c*wght_drv(jp)

C       print*,'jp', jp, 'plank(jp)', plank(jp), 'respir', respir,
C    &  'respir_c', respir_c, 'respRate(jp)', respRate(jp), 'Xe',
C    &  Xe, 'reminTempFunc', reminTempFunc

C       gTr(ic+jp-1)=gTr(ic+jp-1)  - mort_c(jp) - respir_c
        a_1t(jp) = a_1t(jp) - mort_c(jp) - respir_c
        acom(plank(jp)) = acom(plank(jp))
     &                  - (mort_c(jp) + respir_c) * wght_drv(jp)

C       IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C         print*, 'tracer', jp, 'species', plank(jp), 'a_1t', a_1t(jp),
C    &            'acom', acom(plank(jp)), 'mort_c', mort_c(jp),
C    &            'mortX', mortX, 'mortX2', mortX2, 'mort', mort(jp),
C    &            'mort2', mort2(jp), 'mortTempFunc', mortTempFunc,
C    &            'mort2TempFunc', mort2TempFunc, 'respir_c',
C    &            respir_c, 'kexcc', kexcc(jp), 'Xe', Xe,
C    &            'respRate', respRate(jp)
C       ENDIF
      ENDDO


C     gTr(iDIC )=gTr(iDIC ) + respir
      dDIC = dDIC + respir

C     print*,'dDIC', dDIC, 'respir', respir

C     gTr(iDOC )=gTr(iDOC ) + exude_DOC
C     gTr(iDON )=gTr(iDON ) + exude_DON
C     gTr(iDOP )=gTr(iDOP ) + exude_DOP
C     gTr(iDOFe)=gTr(iDOFe) + exude_DOFe
      dDOC  = dDOC  + exude_DOC
      dDON  = dDON  + exude_DON
      dDOP  = dDOP  + exude_DOP
      dDOFe = dDOFe + exude_DOFe

C     gTr(iPIC )=gTr(iPIC ) + exude_PIC
C     gTr(iPOC )=gTr(iPOC ) + exude_POC
C     gTr(iPON )=gTr(iPON ) + exude_PON
C     gTr(iPOP )=gTr(iPOP ) + exude_POP
C     gTr(iPOSi)=gTr(iPOSi) + exude_POSi
C     gTr(iPOFe)=gTr(iPOFe) + exude_POFe
      dPIC  = dPIC  + exude_PIC
      dPOC  = dPOC  + exude_POC
      dPON  = dPON  + exude_PON
      dPOP  = dPOP  + exude_POP
      dPOSi = dPOSi + exude_POSi
      dPOFe = dPOFe + exude_POFe


C-----------------------------------------------------------------------
C End step 2
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 3: Tranform time derivatives into rates (per unit biomass) and
C rates for different trait values into derivatives with respect to
C trait (Le Gland, 15/03/2021)
C-----------------------------------------------------------------------

      DO j = 1, nTrac
        IF ( X(plank(j)) .GT. 0D0 ) THEN
          a_1t(j) = a_1t(j) / X(plank(j))
        ENDIF
      ENDDO

      DO j = 1, nplank
C       IF ( X(plank(j)) .GT. 0D0 ) THEN
        IF ( X(j) .GT. 0D0 ) THEN
          gcom(j) = gcom(j) / X(j)
          acom(j) = acom(j) / X(j)
        ENDIF
      ENDDO

      DO j = 1, nplank

C Compute central values and deriv. of all rates (Le Gland, 11/03/2021)
C I could check that acom = a00 + (1/2)*vr_bvol*a20 + (1/2)*vr_topt*a02
C + cv_bvto*a11 (Le Gland, 15/03/2021)

C       a00(j) = a_1t(iplank(j))
        a_0(j) = a_1t(iplank(j))
C       IF (isPhoto(iplank(j)) .NE. 0) THEN
C         a10(j) = (a_1t(iplank(j)+2) - a_1t(iplank(j)+1)) / (2*dbv)
C         a01(j) = (a_1t(iplank(j)+4) - a_1t(iplank(j)+3)) / (2*dto)
C         a20(j) = (a_1t(iplank(j)+2) + a_1t(iplank(j)+1)
C    &          - 2*a_1t(iplank(j))) / (dbv**2)
C         a02(j) = (a_1t(iplank(j)+4) + a_1t(iplank(j)+3)
C    &          - 2*a_1t(iplank(j))) / (dto**2)
C         a11(j) = (a_1t(iplank(j)+5) + a_1t(iplank(j))
C    &          - a_1t(iplank(j)+2) - a_1t(iplank(j)+4)) / (dbv*dto)
C       ELSE
C         a10(j) = 0.0
C         a01(j) = 0.0
C         a20(j) = 0.0
C         a02(j) = 0.0
C         a11(j) = 0.0
C       ENDIF

        jt = iplank(j) + 1
        DO jp = 1, num_trait(j)
          a_d1(j,jp) = (a_1t(jt+1) - a_1t(jt)) / (2*step_tr(jp))
          a_d2(j,jp) = (a_1t(jt+1) + a_1t(jt) - 2*a_1t(iplank(j)))
     &               / (step_tr(jp)**2)
          a_d2(j,jp) = MIN(0., a_d2(j,jp))
          jt = jt + 2
        ENDDO
        DO jp = num_trait(j)+1, nTrait
          a_d1(j,jp) = 0.
          a_d2(j,jp) = 0.
        ENDDO
        jp1 = 1
        jp2 = 2
        DO jp = 1, num_cov(j)
        jt1 = iplank(j) + 2*jp1
        jt2 = iplank(j) + 2*jp2
C         IF (myIter .EQ. 1) THEN
C           print*, 'DARWIN_SPEAD_RATES derivatives indices:    ',
C    &              'jp1', jp1, 'jp2', jp2, 'jt1', jt1, 'jt2', jt2,
C    &              'jp', jp, 'jt', jt
C         ENDIF
          a_d11(j,jp) = ( a_1t(jt) + a_1t(iplank(j))
     &                - a_1t(jt1) - a_1t(jt2) )
     &                 / (step_tr(jp1)*step_tr(jp2))
          IF (jp2 < num_trait(j)) THEN
            jp2 = jp2 + 1
          ELSE
            jp1 = jp1 + 1
            jp2 = jp1 + 1
          ENDIF
          jt = jt + 1
        ENDDO
        DO jp = num_cov(j)+1, nCov
          a_d11(j,jp) = 0.
        ENDDO






      END DO

C-----------------------------------------------------------------------
C End step 3
C-----------------------------------------------------------------------


      RETURN
      END SUBROUTINE
