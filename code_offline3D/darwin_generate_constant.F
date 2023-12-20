#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_GENERATE_CONSTANT

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_GENERATE_CONSTANT( myThid )

C !DESCRIPTION:
C     Generate parameters for plankton types using an allometric approach

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITPARAMS.h"
#include "DARWIN_TRAITS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
C     msgBuf   :: Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
C     INTEGER jp,jp2,jpm,jps,g,nmom
C     INTEGER jp,jp2,jpm,jps,g,nmom,ntrt
      INTEGER jp,jp2,jpm,jps,jz,g,gz,l,nmom,ntrt

C In a continuous model, this subroutine only sets the traits that do not
C vary within a group (Le Gland, 28/01/2021)
C Is this cumbersome separation really necessary ?

C ======================================================================
C compute traits from trait parameters

C     WRITE(msgBuf,'(A)') 'DARWIN_GENERATE_CONSTANT: entering:'
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )
C     print*,'DARWIN_GENERATE_CONSTANT: entering:'

      jpm = 1
      jps = 1
      print*,'--------------------------------------'
      print*,'DARWIN_GENERATE_CONSTANT:'
      DO g=1,nGroup
C Flexible scheme where the number of traits can be set for each
C Species (Le Gland, 25/03/2021)
        ntrt = grp_traitbvol(g)+grp_traittopt(g)+grp_traitparopt(g)
        nmom = nint(1 + 1.5*ntrt + 0.5*ntrt**2)
        print*,'group',g,'ntrt',ntrt,'nmom',nmom
        DO jp=1,grp_nplank(g)
C Six tracers (2 traits) for phytoplankton
C One tracer (biomass) for other groups
C         IF (grp_photo(g) .NE. 0) THEN
C           nmom = 6
C         ELSE
C           nmom = 1
C         END IF
          iplank(jps) = jpm
          num_trait(jps) = ntrt
#ifdef SPEAD_ALLOW_COV
          num_cov(jps)   = nint(0.5*ntrt*(ntrt-1))
#else
          num_cov(jps)   = 0
#endif
          DO jp2=1,nmom
          print*,'group',g,'species',jps,'moment',jpm
            group(jpm) = g
C Species index "plank" is also necessary in spead_rates.F
C (Le Gland, 11/03/2021)
            plank(jpm) = jps
            jpm = jpm+1
          END DO
          jps = jps+1
        END DO
      END DO
      print*,'--------------------------------------'

      DO jp=1,nTrac
        g = group(jp)

C ----------------------------------------------------------------------
C non-allometric traits (same within group)

C flags
        isPhoto(jp)    = grp_photo(g)
        isPrey(jp)     = grp_prey(g)
        isPred(jp)     = grp_pred(g)
        hasSi(jp)      = grp_hasSi(g)
        hasPIC(jp)     = grp_hasPIC(g)
        diazo(jp)      = grp_diazo(g)
        useNH4(jp)     = grp_useNH4(g)
        useNO2(jp)     = grp_useNO2(g)
        useNO3(jp)     = grp_useNO3(g)
C Originally in DARWIN_READ_TRAITS.F (Le Gland, 12/04/2021)
#ifndef DARWIN_ALLOW_NQUOTA
        IF (diazo(jp).NE.0) THEN
          useNH4(jp) = 0
          useNO2(jp) = 0
          useNO3(jp) = 0
        ENDIF
#endif
        combNO(jp)     = grp_combNO(g)
C Originally in DARWIN_READ_TRAITS.F (Le Gland, 12/04/2021)
        IF (useNO3(jp).EQ.0 .OR. useNO2(jp).EQ.0) THEN
          combNO(jp)=0
        ENDIF
        tempMort(jp)   = grp_tempMort(g)
        tempMort2(jp)  = grp_tempMort2(g)
        tempGraz(jp)   = grp_tempGraz(g)

C traits
        Xmin(jp)       = a_Xmin(g)
        amminhib(jp)   = a_amminhib(g)
        acclimtimescl(jp) = a_acclimtimescl(g)

C mortality
        mort(jp) = a_mort(g)
        mort2(jp) = a_mort2(g)
C       if 0, temperature dependent, if 1, not.
        ExportFracMort(jp) = a_ExportFracMort(g)
        ExportFracMort2(jp) = a_ExportFracMort2(g)
        ExportFracExude(jp) = a_ExportFracExude(g)

C temperature function parameters
        phytoTempCoeff(jp)   = a_phytoTempCoeff(g)
        phytoTempExp1(jp)    = a_phytoTempExp1(g)
        phytoTempExp2(jp)    = a_phytoTempExp2(g)
        phytoTempTol(jp)     = a_phytoTempTol(g)
        phytoDecayPower(jp)  = a_phytoDecayPower(g)

C plankton elemental ratios
        R_NC(jp)       = a_R_NC(g)
        R_PC(jp)       = a_R_PC(g)
        R_SiC(jp)      = a_R_SiC(g)
        R_FeC(jp)      = a_R_FeC(g)
        R_ChlC(jp)     = a_R_ChlC(g)
        R_PICPOC(jp)   = a_R_PICPOC(g)
C Originally in DARWIN_READ_TRAITS.F (Le Gland, 12/04/2021)
C       Silicate parameters to zero for non-diatoms
        IF (hasSi(jp) .EQ. 0) THEN
          vmaxSiO2(jp) = 0.0 _d 0
          ksatSiO2(jp) = 0.0 _d 0
          R_SiC(jp) = 0.0 _d 0
        ENDIF
C       only Coccolithophores have PIC
        IF (hasPIC(jp) .EQ. 0) THEN
          R_PICPOC(jp) = 0.0 _d 0
        ENDIF

C parameters for bacteria

C flags
        bactType(jp)  = grp_bacttype(g)
        isAerobic(jp) = grp_aerobic(g)
        isDenit(jp)   = grp_denit(g)


C real parameters
        yieldO2(jp) = 1.0
        yieldNO3(jp) = 1.0
        IF (isAerobic(jp) .NE. 0) THEN
          yield(jp) = yod
          yieldO2(jp) = yoe
        ELSEIF (isDenit(jp) .NE. 0) THEN
          yield(jp) = ynd
          yieldNO3(jp) = yne
        ENDIF

        ksatPON(jp)  = a_ksatPON(g)
        ksatDON(jp)  = a_ksatDON(g)
        ksatPOC(jp)  = ksatPON(jp)/R_NC(jp)
        ksatPOP(jp)  = ksatPON(jp)/R_NC(jp)*R_PC(jp)
        ksatPOFe(jp) = ksatPON(jp)/R_NC(jp)*R_FeC(jp)
        ksatDOC(jp)  = ksatDON(jp)/R_NC(jp)
        ksatDOP(jp)  = ksatDON(jp)/R_NC(jp)*R_PC(jp)
        ksatDOFe(jp) = ksatDON(jp)/R_NC(jp)*R_FeC(jp)

C Default value when a trait is set constant (Le Gland, 30/03/2021)
        biovol(jp) = biovol0(g)
        phytoTempOptimum(jp) = Topt0(g)

#ifdef DARWIN_ALLOW_GEIDER
        mQyield(jp) = a_mQyield(g)
        chl2cmax(jp) = a_chl2cmax(g)
        inhibGeider(jp) = a_inhibGeider(g)
#else
C These traits are variable in the 3-trait model (Le Gland, 25/03/2021)
C       ksatPAR(jp) = a_ksatPAR(g)
C       kinhPAR(jp) = a_kinhPAR(g)
        PARchi(jp)  = PARchi0(g)
        ksatPAR(jp) = LOG(1+PARchi0(g)) 
     &              / (11.574*PARopt0(g)/2.5)
C    &              / (darwin_inscal_PAR*PARopt0(g)/2.5)
        kinhPAR(jp) = ksatPAR(jp) / PARchi0(g) 
#endif /* DARWIN_ALLOW_GEIDER */

      ENDDO

C Generate a first set of traits for checking (Le Gland, 12/04/2021)
      CALL DARWIN_GENERATE_ALLOMETRIC(myThid)

C Mutation rates matrix (Le Gland, 31/03/2021)
C Reference are added to reset mean trait when concentration 
C is zero (Le Gland, 14/05/2021)
      DO jp = 1, nplank
        g = group(iplank(jp))
        jpm = 1
        IF (grp_traitbvol(g) .NE. 0) THEN
          traitbvol(jp) = 1
          numut_tr(jp,jpm) = numut_bvol(g)
          ref_tr(jp,jpm) = LOG(biovol0(g))
C Minimum and maximum values for traits and their variances 
C (Le Gland,07/06/2021)
          min_tr(jp,jpm) = -3.0  _d 0
          max_tr(jp,jpm) =  12.0 _d 0
C Maximum variance is that of uniform distribution: (1/12) (max-min)**2 
C (Le Gland, 07/06/2021)
          max_vr_tr(jp,jpm) = 18.7 _d 0
          jpm = jpm + 1
        ENDIF
        IF (grp_traittopt(g) .NE. 0) THEN
          traittopt(jp) = 1
          numut_tr(jp,jpm) = numut_topt(g)
          ref_tr(jp,jpm) = Topt0(g)
          min_tr(jp,jpm) = 0.0  _d 0
          max_tr(jp,jpm) = 35.0 _d 0
          max_vr_tr(jp,jpm) = 102.0 _d 0
          jpm = jpm + 1
        ENDIF
        IF (grp_traitparopt(g) .NE. 0) THEN
          traitparopt(jp) = 1
          numut_tr(jp,jpm) = numut_paropt(g)
          ref_tr(jp,jpm) = LOG(PARchi0(g))
          min_tr(jp,jpm) = 2.0 _d 0
          max_tr(jp,jpm) = 5.0 _d 0
          max_vr_tr(jp,jpm) = 0.75 _d 0
        ENDIF
        DO jp2 = jpm+1, num_trait(jp)
          numut_tr(jp,jp2) = DARWIN_UNUSED
          ref_tr(jp,jp2) = DARWIN_UNUSED
        ENDDO
      ENDDO

      print*, 'DARWIN_GENERATE_CONSTANT traits',
     &         biovol, phytoTempOptimum, ksatPAR,
     &        '--------------------------------'

C Originally in DARWIN_READ_TRAITS (Le Gland, 12/04/2021)
C Zero out unused traits
      DO jp=1,nTrac
#ifndef DARWIN_ALLOW_NQUOTA
       vmaxNH4(jp) = DARWIN_UNUSED
       vmaxNO2(jp) = DARWIN_UNUSED
       vmaxNO3(jp) = DARWIN_UNUSED
       vmaxN(jp) = DARWIN_UNUSED
       Qnmax(jp) = DARWIN_UNUSED
       Qnmin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_PQUOTA
       vmaxPO4(jp) = DARWIN_UNUSED
       Qpmax(jp) = DARWIN_UNUSED
       Qpmin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
       vmaxSiO2(jp) = DARWIN_UNUSED
       Qsimax(jp) = DARWIN_UNUSED
       Qsimin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
       vmaxFeT(jp) = DARWIN_UNUSED
       Qfemax(jp) = DARWIN_UNUSED
       Qfemin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_EXUDE
       kexcc(jp) = DARWIN_UNUSED
       kexcn(jp) = DARWIN_UNUSED
       kexcp(jp) = DARWIN_UNUSED
       kexcsi(jp) = DARWIN_UNUSED
       kexcfe(jp) = DARWIN_UNUSED
#endif
       IF (jp.GT.nPhoto) THEN
        diazo(jp) = DARWIN_UNUSED
        useNH4(jp) = DARWIN_UNUSED
        useNO2(jp) = DARWIN_UNUSED
        useNO3(jp) = DARWIN_UNUSED
        combNO(jp) = DARWIN_UNUSED
        amminhib(jp) = DARWIN_UNUSED
        acclimtimescl(jp) = DARWIN_UNUSED

        phytoTempCoeff(jp) = DARWIN_UNUSED
        phytoTempExp1(jp) = DARWIN_UNUSED
        phytoTempExp2(jp) = DARWIN_UNUSED
        phytoTempOptimum(jp) = DARWIN_UNUSED
        phytoDecayPower(jp) = DARWIN_UNUSED

        vmaxNH4(jp) = DARWIN_UNUSED
        vmaxNO2(jp) = DARWIN_UNUSED
        vmaxNO3(jp) = DARWIN_UNUSED
        vmaxPO4(jp) = DARWIN_UNUSED
        vmaxSiO2(jp) = DARWIN_UNUSED
        vmaxFeT(jp) = DARWIN_UNUSED

        ksatNH4(jp) = DARWIN_UNUSED
        ksatNO2(jp) = DARWIN_UNUSED
        ksatNO3(jp) = DARWIN_UNUSED
        ksatPO4(jp) = DARWIN_UNUSED
        ksatSiO2(jp) = DARWIN_UNUSED
        ksatFeT(jp) = DARWIN_UNUSED

#ifdef DARWIN_ALLOW_GEIDER
        inhibGeider(jp) = DARWIN_UNUSED
#else
        ksatPAR(jp) = DARWIN_UNUSED
        kinhPAR(jp) = DARWIN_UNUSED
        PARopt(jp) = DARWIN_UNUSED
        PARchi(jp) = DARWIN_UNUSED
        normI(jp) = DARWIN_UNUSED
#endif
        mQyield(jp) = DARWIN_UNUSED
        chl2cmax(jp) = DARWIN_UNUSED
        chl2cmin(jp) = DARWIN_UNUSED
        DO l=1,nlam
         alphachl(jp,l) = DARWIN_UNUSED
        ENDDO
        alpha_mean(jp) = DARWIN_UNUSED
       ENDIF
      ENDDO

C Originally in DARWIN_READ_TRAITS (Le Gland, 12/04/2021)
C re-compute isPrey and isPred to speed up grazing loops
      DO jp=1,nTrac
       isPrey(jp) = 0
       isPred(jp) = 0
      ENDDO
      DO jp=1,nTrac
       DO jz=1,nTrac
        IF (palat(jp,jz) .NE. 0.) THEN
         isPrey(jp) = 1
         isPred(jz) = 1
        ENDIF
       ENDDO
      ENDDO

C Constants and initial values of traits related to grazing
C (Le Gland, 12/04/2021)
      DO jz=1,nTrac
        gz = group(jz)
        IF (isPred(jz) .EQ. 0) THEN
          grazemax(jz)  = DARWIN_UNUSED
          kgrazesat(jz) = DARWIN_UNUSED
        ENDIF
        DO jp=1,nTrac
          g = group(jp)
          palat(jp,jz) = 0. _d 0
          IF (grp_pred(gz).GT.0 .AND. grp_prey(g).GT.0) THEN
            asseff(jp,jz) = grp_ass_eff(g,gz)
            ExportFracPreyPred(jp,jz) = grp_ExportFracPreyPred(g,gz)
          ELSE
            asseff(jp,jz) = DARWIN_UNUSED
            ExportFracPreyPred(jp,jz) = DARWIN_UNUSED
          ENDIF
        ENDDO
      ENDDO

C Originally in DARWIN_READ_TRAITS (Le Gland, 12/04/2021)
      DO jp=1,nTrac

       IF (isPhoto(jp) .NE. 0) THEN
        IF (jp.GT.nPhoto) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_GENERATE_CONSTANT: ERROR: ',
     &    'isPhoto set for type outside of photo range: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_CONSTANT'
        ENDIF
#ifdef DARWIN_ALLOW_CHLQUOTA
        IF (jp.GT.nPhoto) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_GENERATE_CONSTANT: ERROR: ',
     &    'isPhoto set for type outside of Chl range: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_CONSTANT'
        ENDIF
#endif
       ELSE
        IF (bacttype(jp) .EQ. 0) THEN
         PCmax(jp) = 0 _d 0
        ENDIF
        vmaxPO4(jp) = 0 _d 0
        vmaxNO3(jp) = 0 _d 0
        vmaxNO2(jp) = 0 _d 0
        vmaxNH4(jp) = 0 _d 0
        vmaxFeT(jp) = 0 _d 0
        vmaxSiO2(jp) = 0 _d 0
       ENDIF

       IF (bactType(jp) .NE. 0) THEN
        IF (isAerobic(jp).NE.0 .AND. isDenit(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_GENERATE_CONSTANT: ERROR: ',
     &    'isAerobic and isDenit both set: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_CONSTANT'
        ENDIF
       ELSE
        IF (isAerobic(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_GENERATE_CONSTANT: ERROR: ',
     &    'isAerobic set for non-bacteria type: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_CONSTANT'
        ENDIF
        IF (isDenit(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_GENERATE_CONSTANT: ERROR: ',
     &    'isDenit set for non-bacteria type: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_CONSTANT'
        ENDIF
       ENDIF

C Cannot worked if palat is not defined beforehand
C This is why I need to call a first DARWIN_GENERATE_ALLOMETRIC before
C (Le Gland, 12/04/2021)
       DO jz=1,nTrac
        IF (palat(jp,jz) .NE. 0.) THEN
         IF (isPrey(jp) .EQ. 0) THEN
         WRITE(msgBuf,'(2A,2I4)') 'DARWIN_GENERATE_CONSTANT: WARNING: ',
     &    'palat set for type outside of prey range: ', jp, jz
          CALL PRINT_ERROR( msgBuf , 1)
          IF (darwin_strict_check) THEN
           STOP 'palat set outside of prey range'
          ELSE
           palat(jp,jz) = 0. _d 0
          ENDIF
         ENDIF
         IF (isPred(jz) .EQ. 0) THEN
         WRITE(msgBuf,'(2A,2I4)') 'DARWIN_GENERATE_CONSTANT: WARNING: ',
     &    'palat set for type outside of predator range: ', jp, jz
          CALL PRINT_ERROR( msgBuf , 1)
          IF (darwin_strict_check) THEN
           STOP 'palat set outside of predator range'
          ELSE
           palat(jp,jz) = 0. _d 0
          ENDIF
         ENDIF
        ENDIF
       ENDDO

      ENDDO

#endif  /*ALLOW_DARWIN*/

      RETURN
      END
