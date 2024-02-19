#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_PLANKTON
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_PLANKTON(
     I     Ptr,
     U     gTr,
     O     chlout, diags,
     I     PAR, temp,
#ifdef DARWIN_DEBUG
     I     iG, jG, k, dT,
#endif
     I     myTime,myIter,myThid)

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_DIAGS.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
C Le Gland (18/12/2020) for trait diffusion -> grp_ntopt,grp_nbiovol
C No longer necessary in the continuous model (29/01/2021)
C Still necessary due to numut_bvol & numut_topt (Le Gland, 15/03/2021)
#include "DARWIN_TRAITPARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  Ptr    :: darwin model tracers
C  PAR    :: PAR in uEin/s/m2
C         :: either non-spectral (tlam=1) or waveband total
C  myTime :: current time
C  myIter :: current iteration number
C  myThid :: thread number
      _RL Ptr(nDarwin)
      _RL PAR(nlam)
C Continuous model: temperature dependance is managed within darwin_plankton (Le Gland, 14/01/2021)
C Temperature-dependent functions are set here because they vary with traits (Le Gland, 01/02/2021)
      _RL temp
      INTEGER myThid, myIter
      _RL myTime
#ifdef DARWIN_DEBUG
      INTEGER iG, jG, k
      _RL dT
#endif

C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTr    :: accumulates computed tendencies
      _RL gTr(nDarwin)

C !OUTPUT PARAMETERS: ==================================================
C  chlout :: computed acclimated chlorophyll if not dynamic
C     _RL chlout(nPhoto)
      _RL chlout(nphyp)
      _RL diags(darwin_nDiag)
CEOP

#ifdef ALLOW_DARWIN

c !LOCAL VARIABLES: ====================================================
      INTEGER j, l
      INTEGER jz, jp
C Le Gland (18/12/2020)
      INTEGER g
C Indices for traits and covariances (Le Gland, 29/03/2021)
      INTEGER jt, jt1, jt2, jt3, jt4
      INTEGER jc, jc13, jc23, jc14, jc24, jc34
C Error messages for debugging (Le Gland, 16/03/2021)
      CHARACTER*(MAX_LEN_MBUF) msgBuf

C Continuous model: temperature dependance is managed within darwin_plankton (Le Gland, 14/01/2021)
      _RL photoTempFunc(nTrac)
      _RL reminTempFunc
      _RL uptakeTempFunc
      _RL grazTempFunc(nTrac)
      _RL mortTempFunc
      _RL mort2TempFunc

      _RL DIC
      _RL NH4
      _RL NO2
      _RL NO3
      _RL PO4
      _RL SiO2
      _RL FeT
      _RL DOC
      _RL DON
      _RL DOP
      _RL DOFe
      _RL POC
      _RL PON
      _RL POP
      _RL POSi
      _RL POFe
      _RL PIC
      _RL O2
      _RL ALK

C Continuous model: time derivatives (Le Gland, 10/03/2021)
      _RL dDIC
      _RL dNH4
      _RL dNO2
      _RL dNO3
      _RL dPO4
      _RL dSiO2
      _RL dFeT
      _RL dDOC
      _RL dDON
      _RL dDOP
      _RL dDOFe
      _RL dPOC
      _RL dPON
      _RL dPOP
      _RL dPOSi
      _RL dPOFe
      _RL dPIC
      _RL dO2
      _RL dALK

C damping time for mean and variance corrections (Le Gland, 07/06/2021)
      _RL dmp_time

      _RL X(nplank)
      _RL acom(nplank)
      _RL dXdt(nplank)
C     _RL Qc(nplank)
#ifdef DARWIN_ALLOW_NQUOTA
      _RL Qn(nplank)
      _RL ancom(nplank)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
      _RL Qp(nplank)
      _RL apcom(nplank)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
      _RL Qsi(nplank)
      _RL asicom(nplank)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL Qfe(nplank)
      _RL afecom(nplank)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
      _RL QChl(nplank)
      _RL aChlcom(nplank)
#endif

C Continuous model: concentration and quotas are given with their
C derivatives with respect to trait (Le Gland, 09/03/2021)
C Could be improved by introducing a "nplank" restriced to
C photosynthetic organisms
C In the current situation, some variables are unused (09/03/2021)

#ifdef SPEAD_ALLOW_TRAITS

C Conserved tracers
C     _RL X10(nplank)
C     _RL X01(nplank)
C     _RL X20(nplank)
C     _RL X02(nplank)
C     _RL X11(nplank)
      _RL X_m1(nplank,nTrait)
      _RL X_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL X_m11(nplank,nCov)
#endif
C Trait distribution moments, deduced from the conserved tracers
C     _RL mn_bvol(nplank)
C     _RL mn_topt(nplank)
C     _RL vr_bvol(nplank)
C     _RL vr_topt(nplank)
C     _RL cv_bvto(nplank)
      _RL mn_tr(nplank,nTrait)
      _RL vr_tr(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL cv_tr(nplank,nCov)
C     _RL cv_unbounded
#endif
C Diagnostic variables derived from the trait distribution moments
C     _RL sd_bvol(nplank)
C     _RL sd_topt(nplank)
C     _RL cr_bvto(nplank)
      _RL sd_tr(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL cr_tr(nplank,nCov)
#endif
C Growth and net growth rates (Le Gland, 10/03/2021)
      _RL gcom(nplank)
C     _RL a00(nplank)
C     _RL a10(nplank)
C     _RL a01(nplank)
C     _RL a20(nplank)
C     _RL a02(nplank)
C     _RL a11(nplank)
      _RL a_0(nplank)
      _RL a_d1(nplank,nTrait)
      _RL a_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL a_d11(nplank,nCov)
#endif
C Time derivatives (Le Gland, 10/03/2021)
C     _RL dmbdt(nplank)
C     _RL dmtdt(nplank)
C     _RL dvbdt(nplank)
C     _RL dvtdt(nplank)
C     _RL dcbtdt(nplank)
      _RL dmndt(nplank,nTrait)
      _RL dvrdt(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dcvdt(nplank,nCov)
#endif

#ifdef DARWIN_ALLOW_NQUOTA
C     _RL Qn00(nplank)
C     _RL Qn10(nplank)
C     _RL Qn01(nplank)
C     _RL Qn20(nplank)
C     _RL Qn02(nplank)
C     _RL Qn11(nplank)
      _RL Qn_m0(nplank)
      _RL Qn_m1(nplank,nTrait)
      _RL Qn_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qn_m11(nplank,nCov)
#endif
C     _RL Qn_bv1(nplank)
C     _RL Qn_to1(nplank)
C     _RL Qn_bv2(nplank)
C     _RL Qn_to2(nplank)
C     _RL Qn_b1t1(nplank)
      _RL Qn_d1(nplank,nTrait)
      _RL Qn_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qn_d11(nplank,nCov)
#endif
C     _RL an00(nplank)
C     _RL an10(nplank)
C     _RL an01(nplank)
C     _RL an20(nplank)
C     _RL an02(nplank)
C     _RL an11(nplank)
      _RL an_0(nplank)
      _RL an_d1(nplank,nTrait)
      _RL an_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL an_d11(nplank,nCov)
#endif
C     _RL dQn00(nplank)
C     _RL dQn10(nplank)
C     _RL dQn01(nplank)
C     _RL dQn20(nplank)
C     _RL dQn02(nplank)
C     _RL dQn11(nplank)
      _RL dQn_m0(nplank)
      _RL dQn_m1(nplank,nTrait)
      _RL dQn_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dQn_m11(nplank,nCov)
#endif
#endif /* DARWIN_ALLOW_NQUOTA */
#ifdef DARWIN_ALLOW_PQUOTA
C     _RL Qp00(nplank)
C     _RL Qp10(nplank)
C     _RL Qp01(nplank)
C     _RL Qp20(nplank)
C     _RL Qp02(nplank)
C     _RL Qp11(nplank)
      _RL Qp_m0(nplank)
      _RL Qp_m1(nplank,nTrait)
      _RL Qp_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qp_m11(nplank,nCov)
#endif
C     _RL Qp_bv1(nplank)
C     _RL Qp_to1(nplank)
C     _RL Qp_bv2(nplank)
C     _RL Qp_to2(nplank)
C     _RL Qp_b1t1(nplank)
      _RL Qp_d1(nplank,nTrait)
      _RL Qp_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qp_d11(nplank,nCov)
#endif
C     _RL ap00(nplank)
C     _RL ap10(nplank)
C     _RL ap01(nplank)
C     _RL ap20(nplank)
C     _RL ap02(nplank)
C     _RL ap11(nplank)
      _RL ap_0(nplank)
      _RL ap_d1(nplank,nTrait)
      _RL ap_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL ap_d11(nplank,nCov)
#endif
C     _RL dQp00(nplank)
C     _RL dQp10(nplank)
C     _RL dQp01(nplank)
C     _RL dQp20(nplank)
C     _RL dQp02(nplank)
C     _RL dQp11(nplank)
      _RL dQp_m0(nplank)
      _RL dQp_m1(nplank,nTrait)
      _RL dQp_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dQp_m11(nplank,nCov)
#endif
#endif /* DARWIN_ALLOW_PQUOTA */
#ifdef DARWIN_ALLOW_SIQUOTA
C     _RL Qsi00(nplank)
C     _RL Qsi10(nplank)
C     _RL Qsi01(nplank)
C     _RL Qsi20(nplank)
C     _RL Qsi02(nplank)
C     _RL Qsi11(nplank)
      _RL Qsi_m0(nplank)
      _RL Qsi_m1(nplank,nTrait)
      _RL Qsi_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qsi_m11(nplank,nCov)
#endif
C     _RL Qsi_bv1(nplank)
C     _RL Qsi_to1(nplank)
C     _RL Qsi_bv2(nplank)
C     _RL Qsi_to2(nplank)
C     _RL Qsi_b1t1(nplank)
      _RL Qsi_d1(nplank,nTrait)
      _RL Qsi_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qsi_d11(nplank,nCov)
#endif
C     _RL asi00(nplank)
C     _RL asi10(nplank)
C     _RL asi01(nplank)
C     _RL asi20(nplank)
C     _RL asi02(nplank)
C     _RL asi11(nplank)
      _RL asi_0(nplank)
      _RL asi_d1(nplank,nTrait)
      _RL asi_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL asi_d11(nplank,nCov)
#endif
C     _RL dQsi00(nplank)
C     _RL dQsi10(nplank)
C     _RL dQsi01(nplank)
C     _RL dQsi20(nplank)
C     _RL dQsi02(nplank)
C     _RL dQsi11(nplank)
      _RL dQsi_m0(nplank)
      _RL dQsi_m1(nplank,nTrait)
      _RL dQsi_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dQsi_m11(nplank,nCov)
#endif
#endif /* DARWIN_ALLOW_SIQUOTA */
#ifdef DARWIN_ALLOW_FEQUOTA
C     _RL Qfe00(nplank)
C     _RL Qfe10(nplank)
C     _RL Qfe01(nplank)
C     _RL Qfe20(nplank)
C     _RL Qfe02(nplank)
C     _RL Qfe11(nplank)
      _RL Qfe_m0(nplank)
      _RL Qfe_m1(nplank,nTrait)
      _RL Qfe_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qfe_m11(nplank,nCov)
#endif
C     _RL Qfe_bv1(nplank)
C     _RL Qfe_to1(nplank)
C     _RL Qfe_bv2(nplank)
C     _RL Qfe_to2(nplank)
C     _RL Qfe_b1t1(nplank)
      _RL Qfe_d1(nplank,nTrait)
      _RL Qfe_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qfe_d11(nplank,nCov)
#endif
C     _RL afe00(nplank)
C     _RL afe10(nplank)
C     _RL afe01(nplank)
C     _RL afe20(nplank)
C     _RL afe02(nplank)
C     _RL afe11(nplank)
      _RL afe_0(nplank)
      _RL afe_d1(nplank,nTrait)
      _RL afe_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL afe_d11(nplank,nCov)
#endif
C     _RL dQfe00(nplank)
C     _RL dQfe10(nplank)
C     _RL dQfe01(nplank)
C     _RL dQfe20(nplank)
C     _RL dQfe02(nplank)
C     _RL dQfe11(nplank)
      _RL dQfe_m0(nplank)
      _RL dQfe_m1(nplank,nTrait)
      _RL dQfe_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dQfe_m11(nplank,nCov)
#endif
#endif /* DARWIN_ALLOW_FEQUOTA */
#ifdef DARWIN_ALLOW_CHLQUOTA
C     _RL QChl00(nplank)
C     _RL QChl10(nplank)
C     _RL QChl01(nplank)
C     _RL QChl20(nplank)
C     _RL QChl02(nplank)
C     _RL QChl11(nplank)
      _RL QChl_m0(nplank)
      _RL QChl_m1(nplank,nTrait)
      _RL QChl_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL QChl_m11(nplank,nCov)
#endif
C     _RL QChl_bv1(nplank)
C     _RL QChl_to1(nplank)
C     _RL QChl_bv2(nplank)
C     _RL QChl_to2(nplank)
C     _RL QChl_b1t1(nplank)
      _RL QChl_d1(nplank,nTrait)
      _RL QChl_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL QChl_d11(nplank,nCov)
#endif
C     _RL aChl00(nplank)
C     _RL aChl10(nplank)
C     _RL aChl01(nplank)
C     _RL aChl20(nplank)
C     _RL aChl02(nplank)
C     _RL aChl11(nplank)
      _RL aChl_0(nplank)
      _RL aChl_d1(nplank,nTrait)
      _RL aChl_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL aChl_d11(nplank,nCov)
#endif
C     _RL dQChl00(nplank)
C     _RL dQChl10(nplank)
C     _RL dQChl01(nplank)
C     _RL dQChl20(nplank)
C     _RL dQChl02(nplank)
C     _RL dQChl11(nplank)
      _RL dQChl_m0(nplank)
      _RL dQChl_m1(nplank,nTrait)
      _RL dQChl_m2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL dQChl_m11(nplank,nCov)
#endif
#endif /* DARWIN_ALLOW_CHLQUOTA */

#endif /* SPEAD_ALLOW_TRAITS */

#ifdef DARWIN_GRAZING_SWITCH
      _RL coeff_KTW(nplank)
#endif

C-----------------------------------------------------------------------
C Step 1: define non-living tracers
C Identical to discrete model (Le Gland, 18/01/2021)
C-----------------------------------------------------------------------
C==== precompute a few things ==========================================

C==== make all bio fields non-negative and compute quotas ==============

C     print*,'DARWIN_PLANKTON: step 1 starting:'

      DIC  = MAX(0., Ptr(iDIC))
      NH4  = MAX(0., Ptr(iNH4))
      NO2  = MAX(0., Ptr(iNO2))
      NO3  = MAX(0., Ptr(iNO3))
      PO4  = MAX(0., Ptr(iPO4))
      SiO2 = MAX(0., Ptr(iSiO2))
      FeT  = MAX(0., Ptr(iFeT))

      DOC  = MAX(0., Ptr(iDOC))
      DON  = MAX(0., Ptr(iDON))
      DOP  = MAX(0., Ptr(iDOP))
      DOFe = MAX(0., Ptr(iDOFe))

      PIC  = MAX(0., Ptr(iPIC))
      POC  = MAX(0., Ptr(iPOC))
      PON  = MAX(0., Ptr(iPON))
      POP  = MAX(0., Ptr(iPOP))
      POSi = MAX(0., Ptr(iPOSi))
      POFe = MAX(0., Ptr(iPOFe))
#ifdef DARWIN_ALLOW_CARBON
      O2   = MAX(0., Ptr(iO2))
      ALK  = MAX(0., Ptr(iALK))
#endif
#ifdef DARWIN_ALLOW_CDOM
      CDOM = MAX(0., Ptr(iCDOM))
#endif

#ifdef DARWIN_DEBUG
      IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C        print*,'Concentrations',myiter,k,j,
        print*,'Concentrations:  ',
     &     DIC,
     &     NH4,
     &     NO2,
     &     NO3,
     &     DOC,
     &     DON,
     &     PIC,
     &     POC,
     &     PON,
#ifdef DARWIN_ALLOW_CARBON
     &     O2,
     &     ALK,
#endif
     &     ''
        print*,'Indices:  ',
     &     'DIC', iDIC,
     &     'NH4', iNH4,
     &     'NO2', iNO2,
     &     'NO3', iNO3,
     &     'DOC', iDOC,
     &     'DON', iDON,
     &     'PIC', iPIC,
     &     'POC', iPOC,
     &     'PON', iPON,
#ifdef DARWIN_ALLOW_CARBON
     &     'O2',  iO2,
     &     'ALK', iALK,
#endif
     &     ''
        print*,'Concentrations:  ',
     &     Ptr(iDIC),
     &     Ptr(iNH4),
     &     Ptr(iNO2),
     &     Ptr(iNO3),
     &     Ptr(iDOC),
     &     Ptr(iDON),
     &     Ptr(iPIC),
     &     Ptr(iPOC),
     &     Ptr(iPON),
#ifdef DARWIN_ALLOW_CARBON
     &     Ptr(iO2),
     &     Ptr(iALK),
#endif
     &     ''
      ENDIF
#endif

C-----------------------------------------------------------------------
C-------------------------- End Step 1 ---------------------------------
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 2: define plankton concentration, traits and quotas (Le Gland, 18/01/2021)
C-----------------------------------------------------------------------

C Recall time (I think this should be equal to the time step)
C (Le Gland, 07/06/2021)
      dmp_time = 3600.0 _d 0
C     dmp_time = 10800.0 _d 0
C     dmp_time = 10800000000.0 _d 0

      DO j = 1, nplank
C fixed carbon quota, for now 1.0 (may change later)
C       Qc(j) = 1.0
C       X(j) = MAX(0., Ptr(ic+iplank(j)-1))/Qc(j)
        X(j) = MAX(0., Ptr(ic+iplank(j)-1))
#ifdef SPEAD_ALLOW_TRAITS
C       IF(isPhoto(iplank(j)) .NE. 0) THEN
C Mean traits, variances and covariances
C         X10(j) = MAX(0., Ptr(ic+iplank(j)))
C         mn_bvol(j) = X10(j)/X(j)
C         X01(j) = MAX(0., Ptr(ic+iplank(j)+1))
C         mn_topt(j) = X01(j)/X(j)
C         X20(j) = MAX(0., Ptr(ic+iplank(j)+2))
C         vr_bvol(j) = X20(j)/X(j) - mn_bvol(j)**2
C         sd_bvol(j) = sqrt(vr_bvol(j))
C         X02(j) = MAX(0., Ptr(ic+iplank(j)+3))
C         vr_topt(j) = X02(j)/X(j) - mn_topt(j)**2
C         sd_topt(j) = sqrt(vr_topt(j))
C         X11(j) = MAX(0., Ptr(ic+iplank(j)+4))
C         cv_bvto(j) = X11(j)/X(j) - mn_bvol(j)*mn_topt(j)
C         cr_bvto(j) = cv_bvto(j)/(sd_bvol(j)*sd_topt(j))
C       ELSE
C Standard values for zooplankton. To be improved by using namelists.
C (Le Gland, 19/03/2021)
C         mn_bvol(j) = 9.0
C         mn_topt(j) = 24.0
C         vr_bvol(j) = 0.0
C         vr_topt(j) = 0.0
C         cv_bvto(j) = 0.0
C       END IF
C There are redundant variables. Is it possible to optimize?
C (Le Gland, 26/03/2021)
C       idx = ic + iplank(j) + 2*num_trait(j)
        DO jp = 1, num_trait(j)
C         X_m1(j,jp)  = MAX(0., Ptr(ic+iplank(j)-1+jp))
          X_m1(j,jp)  = Ptr(ic+iplank(j)-1+jp)
          IF (X(j) .GT. 0) THEN
            mn_tr(j,jp) = X_m1(j,jp)/X(j)
C damping term (Le Gland, 27/05/2021)
C           dmndt(j,jp) = MIN( 35.0 - mn_tr(j,jp), MAX( 0.0, -3.0 -
C    &                    mn_tr(j,jp) ) ) / 86400.0
C           mn_tr(j,jp) = MIN( 35.0, MAX( -3.0, mn_tr(j,jp) ) )
          ELSE
            mn_tr(j,jp) = ref_tr(j,jp)
            dmndt(j,jp) = 0 _d 0
          ENDIF
C         X_m2(j,jp)  = MAX(0., Ptr(ic+iplank(j)-1+num_trait(j)+jp))
C         vr_tr(j,jp) = X_m2(j,jp)/X(j) - mn_tr(j,jp)**2
          X_m2(j,jp)  = Ptr(ic+iplank(j)-1+num_trait(j)+jp)
          IF (X(j) .GT. 0) THEN
            vr_tr(j,jp) = X_m2(j,jp)/X(j) - mn_tr(j,jp)**2
             

C damping term (Le Gland, 27/05/2021)
C           dvrdt(j,jp) = MIN( 700.0 - vr_tr(j,jp), MAX( 0.0, 1.0 _d -6
C    &                    + 2*numut_tr(j,jp) - vr_tr(j,jp) ) ) / 86400.0
C           vr_tr(j,jp) = MIN ( 700.0, MAX(0., vr_tr(j,jp) ) )
            dmndt(j,jp) = MIN( max_tr(j,jp) - mn_tr(j,jp), MAX( 0.0,
     &                   min_tr(j,jp) -  mn_tr(j,jp) ) ) / dmp_time
            mn_tr(j,jp) = MIN( max_tr(j,jp), MAX( min_tr(j,jp),
     &                          mn_tr(j,jp) ) )
C            vr_tr(j,jp) = MIN ( max_vr_tr(j,jp) , MAX( 1.0 _d -40 *
C     &                    max_vr_tr(j,jp) + 2*numut_tr(j,jp),
C     &                    vr_tr(j,jp) ) )
C            dvrdt(j,jp) = MIN( max_vr_tr(j,jp) - vr_tr(j,jp), MAX( 0.0,
C     &                    0.0 _d -40 * max_vr_tr(j,jp) 
C     &                    +2*numut_tr(j,jp)- vr_tr(j,jp) ) ) / dmp_time
            dvrdt(j,jp) = 0 _d 0

     
C Supposedly makes variance stay at zero when set to zero (Boris 15/11/23)
            vr_tr(j,jp) = MAX(0 _d 0 ,MIN(max_vr_tr(j,jp),vr_tr(j,jp)))
            IF(vr_tr(j,jp) /= vr_tr(j,jp)) THEN 
             vr_tr(j,jp) = 0 _d 0
            ENDIF
            
C            IF(vr_tr(j,jp) .LE. max_vr_tr(j,jp)*1.0 _d -7) THEN 
C             vr_tr(j,jp) = 0 _d 0
C            ENDIF
            
c            IF(vr_tr(j,jp) /= 0) THEN
c                IF (jp .EQ. 2) THEN
c                    print*
c     &                ,'Starts with vr = Nan... Time', myIter 
c     &                ,'iG', iG
c     &                ,'jG', jG
c     &                ,'k', k
c     &                ,'X_m2', X_m2(j,jp)   
c     &                ,'X', X(j)             
c     &                ,'trait', jp
c     &                ,'dvrdt', dvrdt(j,jp)
c     &                ,'vr_tr 1', vr_tr(j,jp)
c     &                ,'numut_tr', numut_tr(j,jp)
c                ENDIF
c            ENDIF   
      
          ELSE
            vr_tr(j,jp) = 0 _d 0
            dvrdt(j,jp) = 0 _d 0
          ENDIF
          sd_tr(j,jp) = sqrt(vr_tr(j,jp))
C         IF (myIter .EQ. 1) THEN
C           print*, 'X_m1 index:', ic+iplank(j)-1+jp, 'value: ',
C    &              X_m1(j,jp)
C           print*, 'X_m2 index:', ic+iplank(j)+num_trait(j)-1+jp,
C    &              'value: ', X_m2(j,jp)
C         ENDIF
C         DO jz = jp+1, num_trait(j)
C           X_m11(j,) = MAX(0., Ptr(idx))
C           cv_tr(j,) = X_m2(j,jp,jz)/X(j)-mn_tr(j,jp)*mn_tr(j,jz)
C           cr_tr(j,) = cv_tr(jp,jp,jz) / (sd_tr(j,jp)*sd_tr(j,jz))
C           idx = idx + 1
C         END DO
        END DO
#ifdef SPEAD_ALLOW_COV
        jt1 = 1
        jt2 = 2
        DO jp = 1, num_cov(j)
C         IF (myIter .EQ. 1) THEN
C           print*, 'check indices:    ', 'jt1', jt1, 'jt2', jt2,
C    &              'jp', jp
C         ENDIF
          X_m11(j,jp) = Ptr(ic+iplank(j)-1+2*num_trait(j)+jp)
          IF (X(j) .GT. 0 _d 0) THEN
C           cv_tr(j,jp) = X_m11(j,jp)/X(j) - mn_tr(j,jt1)*mn_tr(j,jt2)
            cv_tr(j,jp) = X_m11(j,jp)/X(j) - X_m1(j,jt1)*X_m1(j,jt2) /
     &                    X(j)**2
          ELSE
            cv_tr(j,jp) = 0 _d 0
          ENDIF
C Recall terms (Le Gland, 27/05/2021)
          dcvdt(j,jp) = MIN( 0.99*sd_tr(j,jt1)*sd_tr(j,jt2) -
     &    cv_tr(j,jp), MAX(0., -0.99*sd_tr(j,jt1)*sd_tr(j,jt2) -
C    &    cv_tr(j,jp)) ) / 86400.0
     &    cv_tr(j,jp)) ) / dmp_time
C Force cv_tr to stay within boundaries
          cv_tr(j,jp) = MIN( 0.99*sd_tr(j,jt1)*sd_tr(j,jt2),
     &            MAX(cv_tr(j,jp),-0.99*sd_tr(j,jt1)*sd_tr(j,jt2)) )
          cr_tr(j,jp) = cv_tr(j,jp) / (sd_tr(j,jt1)*sd_tr(j,jt2))
C         IF (myIter .EQ. 1) THEN
C           print*, 'X_m11 index:', ic+iplank(j)-1+2*num_trait(j)+jp,
C    &              'value: ', X_m11(j,jp)
C         ENDIF
          IF (jt2 < num_trait(j)) THEN
            jt2 = jt2 + 1
          ELSE
            jt1 = jt1 + 1
            jt2 = jt1 + 1
          ENDIF
        END DO
#endif
#endif /* SPEAD_ALLOW_TRAITS */

C If quotas are defined, their derivatives with respect to traits have
C to be computed as tracers (Le Gland, 18/01/2021)
#ifdef DARWIN_ALLOW_NQUOTA
C       IF (X(j) .GT. 0 _d 0) THEN
C This is mean Qn. I need Qn at mean trait value
C dQn(xmean(t),t)/dt = dQn/dt (xmean) + dxmean/dt * dQn/dx
C But what about mixing ? Is there a conservative form ?
C Qn total is conservative
C Use moments normalized by N, P, Si, Fe ?
C Yes, if I assume a parabolic distribution of quotas
C Complicated for something I might never use
C Need more work in a formal mathematic software for the 3-trait case
C Very difficult to check and maintain
C         Qn00(j) = MAX(0 _d 0, Ptr(in+iplank(j)))/X(j)
C       IF (isPhoto(j) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
        IF (isPhoto(iplank(j)) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
          Qn00(j) = MAX(0., Ptr(in+iplank(j)-1))
          Qn10(j) = MAX(0., Ptr(in+iplank(j))) - mn_bvol(j)*Qn00(j)
          Qn01(j) = MAX(0., Ptr(in+iplank(j)+1)) - mn_topt(j)*Qn00(j)
          Qn_bv1(j) = (Qn10(j) - cr_bvto(j)*Qn01(j)) / (X(j)*vr_bvol(j)
     &                *(1-cr_bvto(j)**2))
          Qn_to1(j) = (Qn01(j) - cr_bvto(j)*Qn10(j)) / (X(j)*vr_topt(j)
     &                *(1-cr_bvto(j)**2))
          Qn20(j) = MAX(0., Ptr(in+iplank(j)+2)) - 2*mn_bvol(j)*Qn10(j)
     &              - (mn_bvol(j)**2)*Qn00(j)
          Qn02(j) = MAX(0., Ptr(in+iplank(j)+3)) - 2*mn_topt(j)*Qn01(j)
     &              - (mn_topt(j)**2)*Qn00(j)
          Qn11(j) = MAX(0., Ptr(in+iplank(j)+4)) - mn_topt(j)*Qn10(j)
     &            - mn_bvol(j)*Qn01(j) - (mn_bvol(j)*mn_topt(j))*Qn00(j)
          rs = cr_bvto(j)**2
          rsm1 = 1 - rs
        C Qn(j) is Qn at mean trait
          Qn(j) = 1/(2*X(j))*(4*Qn00(j) - Qn20(j)/(vr_bvol(j)*rsm1)
     &            - Qn02(j)/(vr_topt(j)*rsm1)
     &            + 2*rs*Qn11(j)/(cv_bvto(j)*rsm1))
          Qn_bv2(j) = 1/(X(j)*vr_bvol(j))*(-Qn00(j)/rsm1 + Qn20(j)/
     &    (vr_bvol(j)*rsm1**2) + rs*Qn02(j)/(vr_topt(j)*rsm1**2)
     &    - 2*rs**2*Qn11(j)/(rsm1**2))
          Qn_to2(j) = 1/(X(j)*vr_topt(j))*(-Qn00(j)/rsm1 + Qn02(j)/
     &    (vr_topt(j)*rsm1**2) + rs*Qn20(j)/(vr_bvol(j)*rsm1**2)
     &    - 2*rs**2*Qn11(j)/(rsm1**2))
          Qn_b1t1(j) = (rs**2)/(X(j)*cv_bvto(j))*(Qn00(j)/rsm1
     &    - Qn20(j)/(rsm1**2) - Qn02(j)/(rsm1**2)
     &    + (rs**2+1)*Qn11(j)/(rsm1**2))
        ELSE
          Qn_bv1(j) = 0
          Qn_to1(j) = 0
          Qn_bv2(j) = 0
          Qn_to2(j) = 0
          Qn_b1t1(j) = 0
          IF (isPhoto(iplank(j)) .NE. 0) THEN
            Qn(j) = Qnmax(iplank(j))
          ELSEIF (X(j) .GT. 0 _d 0) THEN
            Qn(j) = MAX(0 _d 0, Ptr(in+iplank(j)-1)/X(j)
          ELSE
            Qn(j) = Qnmax(iplank(j))
          ENDIF
        ENDIF
#else
C       Qn(j) = R_NC(iplank(j))
#endif

#ifdef DARWIN_ALLOW_PQUOTA
        IF (isPhoto(iplank(j)) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
          Qp00(j) = MAX(0 _d 0, Ptr(ip+iplank(j)-1))/X(j)
          Qp10(j) = MAX(0., Ptr(ip+iplank(j))) - mn_bvol(j)*Qp00(j)
          Qp01(j) = MAX(0., Ptr(ip+iplank(j)+1)) - mn_topt(j)*Qp00(j)
          Qp_bv1(j) = (Qp10(j) - cr_bvto(j)*Qp01(j)) / (X(j)*vr_bvol(j)
     &                *(1-cr_bvto(j)**2))
          Qp_to1(j) = (Qp01(j) - cr_bvto(j)*Qp10(j)) / (X(j)*vr_topt(j)
     &                *(1-cr_bvto(j)**2))
          Qp20(j) = MAX(0., Ptr(ip+iplank(j)+2)) - 2*mn_bvol(j)*Qp10(j)
     &              - (mn_bvol(j)**2)*Qp00(j)
          Qp02(j) = MAX(0., Ptr(ip+iplank(j)+3)) - 2*mn_topt(j)*Qp01(j)
     &              - (mn_topt(j)**2)*Qp00(j)
          Qp11(j) = MAX(0., Ptr(ip+iplank(j)+4)) - mn_topt(j)*Qp10(j)
     &            - mn_bvol(j)*Qp01(j) - (mn_bvol(j)*mn_topt(j))*Qp00(j)
          rs = cr_bvto(j)**2
          rsm1 = 1 - rs
          Qp(j) = 1/(2*X(j))*(4*Qp00(j) - Qp20(j)/(vr_bvol(j)*rsm1)
     &            - Qp02(j)/(vr_topt(j)*rsm1)
     &            + 2*rs*Qp11(j)/(cv_bvto(j)*rsm1))
          Qp_bv2(j) = 1/(X(j)*vr_bvol(j))*(-Qp00(j)/rsm1 + Qp20(j)/
     &    (vr_bvol(j)*rsm1**2) + rs*Qp02(j)/(vr_topt(j)*rsm1**2)
     &    - 2*rs**2*Qp11(j)/(rsm1**2))
          Qp_to2(j) = 1/(X(j)*vr_topt(j))*(-Qp00(j)/rsm1 + Qp02(j)/
     &    (vr_topt(j)*rsm1**2) + rs*Qp20(j)/(vr_bvol(j)*rsm1**2)
     &    - 2*rs**2*Qp11(j)/(rsm1**2))
          Qp_b1t1(j) = (rs**2)/(X(j)*cv_bvto(j))*(Qp00(j)/rsm1
     &    - Qp20(j)/(rsm1**2) - Qp02(j)/(rsm1**2)
     &    + (rs**2+1)*Qp11(j)/(rsm1**2))
        ELSE
          Qp_bv1(j) = 0
          Qp_to1(j) = 0
          Qp_bv2(j) = 0
          Qp_to2(j) = 0
          Qp_b1t1(j) = 0
          IF (isPhoto(iplank(j)) .NE. 0) THEN
            Qp(j) = Qpmax(iplank(j))
          ELSEIF (X(j) .GT. 0 _d 0) THEN
            Qp(j) = MAX(0 _d 0, Ptr(ip+iplank(j)-1)/X(j)
          ELSE
            Qp(j) = Qpmax(iplank(j))
          ENDIF
        ENDIF
#else
C       Qp(j) = R_PC(iplank(j))
#endif

#ifdef DARWIN_ALLOW_SIQUOTA
        IF (isPhoto(iplank(j)) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
          Qsi00(j) = MAX(0 _d 0, Ptr(isi+iplank(j)-1))/X(j)
          Qsi10(j) = MAX(0., Ptr(isi+iplank(j)))-mn_bvol(j)*Qsi00(j)
          Qsi01(j) = MAX(0., Ptr(isi+iplank(j)+1))-mn_topt(j)*Qsi00(j)
          Qsi_bv1(j) = (Qsi10(j)-cr_bvto(j)*Qsi01(j)) / (X(j)*vr_bvol(j)
     &                *(1-cr_bvto(j)**2))
          Qsi_to1(j) = (Qsi01(j)-cr_bvto(j)*Qsi10(j)) / (X(j)*vr_topt(j)
     &                *(1-cr_bvto(j)**2))
          Qsi20(j) = MAX(0., Ptr(isi+iplank(j)+2))-2*mn_bvol(j)*Qsi10(j)
     &              - (mn_bvol(j)**2)*Qsi00(j)
          Qsi02(j) = MAX(0., Ptr(isi+iplank(j)+3))-2*mn_topt(j)*Qsi01(j)
     &              - (mn_topt(j)**2)*Qsi00(j)
          Qsi11(j) = MAX(0., Ptr(isi+iplank(j)+4)) - mn_topt(j)*Qsi10(j)
     &          - mn_bvol(j)*Qsi01(j) - (mn_bvol(j)*mn_topt(j))*Qsi00(j)
          rs = cr_bvto(j)**2
          rsm1 = 1 - rs
          Qsi(j) = 1/(2*X(j))*(4*Qsi00(j) - Qsi20(j)/(vr_bvol(j)*rsm1)
     &            - Qsi02(j)/(vr_topt(j)*rsm1)
     &            + 2*rs*Qsi11(j)/(cv_bvto(j)*rsm1))
          Qsi_bv2(j) = 1/(X(j)*vr_bvol(j))*(-Qsi00(j)/rsm1 + Qsi20(j)/
     &    (vr_bvol(j)*rsm1**2) + rs*Qsi02(j)/(vr_topt(j)*rsm1**2)
     &    - 2*rs**2*Qsi11(j)/(rsm1**2))
          Qsi_to2(j) = 1/(X(j)*vr_topt(j))*(-Qsi00(j)/rsm1 + Qsi02(j)/
     &    (vr_topt(j)*rsm1**2) + rs*Qsi20(j)/(vr_bvol(j)*rsm1**2)
     &    - 2*rs**2*Qsi11(j)/(rsm1**2))
          Qsi_b1t1(j) = (rs**2)/(X(j)*cv_bvto(j))*(Qsi00(j)/rsm1
     &    - Qsi20(j)/(rsm1**2) - Qsi02(j)/(rsm1**2)
     &    + (rs**2+1)*Qsi11(j)/(rsm1**2))
        ELSE
          Qsi_bv1(j) = 0
          Qsi_to1(j) = 0
          Qsi_bv2(j) = 0
          Qsi_to2(j) = 0
          Qsi_b1t1(j) = 0
          IF (isPhoto(iplank(j)) .NE. 0) THEN
            Qsi(j) = Qsimax(iplank(j))
          ELSEIF (X(j) .GT. 0 _d 0) THEN
            Qsi(j) = MAX(0 _d 0, Ptr(isi+iplank(j)-1)/X(j)
          ELSE
            Qsi(j) = Qsimax(iplank(j))
          ENDIF
        ENDIF
#else
C       Qsi(j) = R_SiC(iplank(j))
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
        IF (isPhoto(iplank(j)) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
          Qfe00(j) = MAX(0 _d 0, Ptr(ife+iplank(j)-1))/X(j)
          Qfe10(j) = MAX(0., Ptr(ife+iplank(j)))-mn_bvol(j)*Qfe00(j)
          Qfe01(j) = MAX(0., Ptr(ife+iplank(j)+1))-mn_topt(j)*Qfe00(j)
          Qfe_bv1(j) = (Qfe10(j)-cr_bvto(j)*Qfe01(j)) / (X(j)*vr_bvol(j)
     &                *(1-cr_bvto(j)**2))
          Qfe_to1(j) = (Qfe01(j)-cr_bvto(j)*Qfe10(j)) / (X(j)*vr_topt(j)
     &                *(1-cr_bvto(j)**2))
          Qfe20(j) = MAX(0., Ptr(ife+iplank(j)+2))-2*mn_bvol(j)*Qfe10(j)
     &              - (mn_bvol(j)**2)*Qfe00(j)
          Qfe02(j) = MAX(0., Ptr(ife+iplank(j)+3))-2*mn_topt(j)*Qfe01(j)
     &              - (mn_topt(j)**2)*Qfe00(j)
          Qfe11(j) = MAX(0., Ptr(ife+iplank(j)+4)) - mn_topt(j)*Qfe10(j)
     &          - mn_bvol(j)*Qfe01(j) - (mn_bvol(j)*mn_topt(j))*Qfe00(j)
          rs = cr_bvto(j)**2
          rsm1 = 1 - rs
          Qfe(j) = 1/(2*X(j))*(4*Qfe00(j) - Qfe20(j)/(vr_bvol(j)*rsm1)
     &            - Qfe02(j)/(vr_topt(j)*rsm1)
     &            + 2*rs*Qfe11(j)/(cv_bvto(j)*rsm1))
          Qfe_bv2(j) = 1/(X(j)*vr_bvol(j))*(-Qfe00(j)/rsm1 + Qfe20(j)/
     &    (vr_bvol(j)*rsm1**2) + rs*Qfe02(j)/(vr_topt(j)*rsm1**2)
     &    - 2*rs**2*Qfe11(j)/(rsm1**2))
          Qfe_to2(j) = 1/(X(j)*vr_topt(j))*(-Qfe00(j)/rsm1 + Qfe02(j)/
     &    (vr_topt(j)*rsm1**2) + rs*Qfe20(j)/(vr_bvol(j)*rsm1**2)
     &    - 2*rs**2*Qfe11(j)/(rsm1**2))
          Qfe_b1t1(j) = (rs**2)/(X(j)*cv_bvto(j))*(Qfe00(j)/rsm1
     &    - Qfe20(j)/(rsm1**2) - Qfe02(j)/(rsm1**2)
     &    + (rs**2+1)*Qfe11(j)/(rsm1**2))
        ELSE
          Qfe_bv1(j) = 0
          Qfe_to1(j) = 0
          Qfe_bv2(j) = 0
          Qfe_to2(j) = 0
          Qfe_b1t1(j) = 0
          IF (isPhoto(iplank(j)) .NE. 0) THEN
            Qfe(j) = Qfemax(iplank(j))
          ELSEIF (X(j) .GT. 0 _d 0) THEN
            Qfe(j) = MAX(0 _d 0, Ptr(ife+iplank(j)-1)/X(j)
          ELSE
            Qfe(j) = Qfemax(iplank(j))
          ENDIF
        ENDIF
#else
C       Qfe(j) = R_FeC(iplank(j))
#endif

#ifdef DARWIN_ALLOW_CHLQUOTA
        IF (isPhoto(iplank(j)) .NE. 0 .AND. X(j) .GT. 0 _d 0) THEN
          QChl00(j) = MAX(0 _d 0, Ptr(iChl+iplank(j)-1))/X(j)
          QChl10(j) = MAX(0.,Ptr(iChl+iplank(j)))-mn_bvol(j)*QChl00(j)
          QChl01(j) = MAX(0.,Ptr(iChl+iplank(j)+1))-mn_topt(j)*QChl00(j)
          QChl_bv1(j) = (QChl10(j)-cr_bvto(j)*QChl01(j)) /
     &                (X(j)*vr_bvol(j)*(1-cr_bvto(j)**2))
          QChl_to1(j) = (QChl01(j)-cr_bvto(j)*QChl10(j)) /
     &                (X(j)*vr_topt(j)*(1-cr_bvto(j)**2))
          QChl20(j) = MAX(0., Ptr(iChl+iplank(j)+2))
     &              - 2*mn_bvol*QChl10(j) - (mn_bvol(j)**2)*QChl00(j)
          QChl02(j) = MAX(0., Ptr(iChl+iplank(j)+3))
     &              - 2*mn_topt*QChl01(j) - (mn_topt(j)**2)*QChl00(j)
          QChl11(j) = MAX(0., Ptr(iChl+iplank(j)+4))
     &                - mn_topt(j)*QChl10(j) - mn_bvol(j)*QChl01(j)
     &                - (mn_bvol(j)*mn_topt(j))*QChl00(j)
          rs = cr_bvto(j)**2
          rsm1 = 1 - rs
          QChl(j) = 1/(2*X(j))*(4*QChl00(j)-QChl20(j)/(vr_bvol(j)*rsm1)
     &            - QChl02(j)/(vr_topt(j)*rsm1)
     &            + 2*rs*QChl11(j)/(cv_bvto(j)*rsm1))
          QChl_bv2(j) = 1/(X(j)*vr_bvol(j))*(-QChl00(j)/rsm1+QChl20(j)/
     &    (vr_bvol(j)*rsm1**2) + rs*QChl02(j)/(vr_topt(j)*rsm1**2)
     &    - 2*rs**2*QChl11(j)/(rsm1**2))
          QChl_to2(j) = 1/(X(j)*vr_topt(j))*(-QChl00(j)/rsm1+QChl02(j)/
     &    (vr_topt(j)*rsm1**2) + rs*QChl20(j)/(vr_bvol(j)*rsm1**2)
     &    - 2*rs**2*QChl11(j)/(rsm1**2))
          QChl_b1t1(j) = (rs**2)/(X(j)*cv_bvto(j))*(QChl00(j)/rsm1
     &    - QChl20(j)/(rsm1**2) - QChl02(j)/(rsm1**2)
     &    + (rs**2+1)*QChl11(j)/(rsm1**2))
        ELSE
          QChl_bv1(j) = 0
          QChl_to1(j) = 0
          QChl_bv2(j) = 0
          QChl_to2(j) = 0
          QChl_b1t1(j) = 0
          IF (isPhoto(iplank(j)) .NE. 0) THEN
            QChl(j) = chl2cmax(iplank(j))
          ELSEIF (X(j) .GT. 0 _d 0) THEN
            QChl(j) = MAX(0 _d 0, Ptr(iChl+iplank(j)-1)/X(j)
          ELSE
            QChl(j) = chl2cmax(iplank(j))
          ENDIF
        ENDIF
#else
C       QChl(j) = R_ChlC(iplank(j))
#endif

      ENDDO

C-----------------------------------------------------------------------
C-------------------------- End Step 2 ---------------------------------
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 3: Compute uptake, growth, death and their derivatives with
C respect to trait (Le Gland, 22/01/2021)
C-----------------------------------------------------------------------

C Check that no NaN is present (Le Gland, 13/05/2021)
      DO j=1,nplank
        IF (X(j) /= X(j)) THEN
#ifdef DARWIN_DEBUG
          WRITE(msgBuf,'(2A,2I6,A,3I6)') 'DARWIN_PLANKTON: ',
     &    'X(j) has NaN value', j, myIter, ' Location:', iG, jG, k
#else
          WRITE(msgBuf,'(2A,2I6)') 'DARWIN_PLANKTON: ',
     &    'X(j) has NaN value', j, myIter
#endif
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_PLANKTON'
        ENDIF
      ENDDO

C Technically, all functions are analytical and their derivatives with
C respect to traits are known. However, computing all the exact derivatives
C would make the code hardly readable and any change in one parameterisation
C (for instance reaction to temperature) would require many changes in the
C code and many risks of error. Hence numerical derivatives are to be prefered.
C I do not know which is cheaper, but the difference must be small.
C (Le Gland, 22/01/2021)

C trait diffusion is computed based on growth "g" only
C "a" is the net growth rate
C "an" is the net uptake of nitrogen, mmolN/(mmolC.d)
C Alternatively, DIC to CDOM could be read within SPEAD_RATES
C     WRITE(msgBuf,'(A)') 'DARWIN_PLANKTON: step 2 completed:'
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )
C     print*,'DARWIN_PLANKTON: step 2 completed:'
C     print*,'X:', X, 'mn_bvol:', mn_bvol, 'mn_topt:', mn_topt,
C    &       'vr_bvol:', vr_bvol, 'vr_topt:', vr_topt,
C    &       'cv_bvto:', cv_bvto
#ifdef DARWIN_DEBUG
C     IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C       print*,'Plankton concentrations', X
C       print*,'Mean traits:', mn_tr(1:2,:)
C       print*,'Trait variances:', vr_tr(1:2,:)
C       print*,'Trait covariances:', cv_tr(1:2,:)
C       print*,'Trait correlations:', cr_tr(1:2,:)
C     ENDIF
#endif
      CALL DARWIN_SPEAD_RATES(
     I           PAR,temp,
     I           myTime,myIter,myThid,
     I           DIC,NH4,NO2,NO3,PO4,SiO2,FeT,DOC,DON,DOP,DOFe,
     I           PIC,POC,PON,POP,POSi,POFe,
     O           chlout, diags,
     O           dDIC,dNH4,dNO2,dNO3,dPO4,dSiO2,dFeT,
     O           dDOC,dDON,dDOP,dDOFe,
     O           dPIC,dPOC,dPON,dPOP,dPOSi,dPOFe,
#ifdef DARWIN_DEBUG
     I           iG, jG, k, dT,
#endif
#ifdef DARWIN_ALLOW_CARBON
     I           O2,ALK,
     O           dO2,dALK,
#endif
#ifdef DARWIN_ALLOW_CDOM
     I           CDOM,
     I           dCDOM,
#endif
C    I           X,mn_bvol,mn_topt,vr_bvol_vr_topt,cv_bvto,
     I           X,
#ifdef SPEAD_ALLOW_TRAITS
     I           mn_tr,vr_tr,
#ifdef SPEAD_ALLOW_COV
     I           cv_tr,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#ifdef DARWIN_ALLOW_NQUOTA
C    I           Qn,Qn_bv1,Qn_to1,Qn_bv2,Qn_to2,Qn_b1t1,
C    O           ancom,an00,an10,an01,an20,an02,an11,
     I           Qn,
     O           ancom,
#ifdef SPEAD_ALLOW_TRAITS
     I           Qn_d1,Qn_d2,
     O           an_0,an_d1,an_d2,
#ifdef SPEAD_ALLOW_COV
     I           Qn_d11,
     O           an_d11
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_NQUOTA */
#ifdef DARWIN_ALLOW_PQUOTA
C    I           Qp_0,Qp_bv1,Qp_to1,Qp_bv2,Qp_to2,Qp_b1t1,
C    O           apcom,ap00,ap10,ap01,ap20,ap02,ap11,
     I           Qp,
     O           apcom,
#ifdef SPEAD_ALLOW_TRAITS
     I           Qp_d1,Qp_d2,
     O           ap_0,ap_d1,ap_d2,
#ifdef SPEAD_ALLOW_COV
     I           Qp_d11,
     O           ap_d11
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_PQUOTA */
#ifdef DARWIN_ALLOW_SIQUOTA
C    I           Qsi_0,Qsi_bv1,Qsi_to1,Qsi_bv2,Qsi_to2,Qsi_b1t1,
C    O           asicom,asi00,asi10,asi01,asi20,asi02,usi11,
     I           Qsi,
     O           asicom,
#ifdef SPEAD_ALLOW_TRAITS
     I           Qsi_d1,Qsi_d2,
     O           asi_0,asi_d1,asi_d2,
#ifdef SPEAD_ALLOW_COV
     I           Qsi_d11,
     O           asi_d11
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_SIQUOTA */
#ifdef DARWIN_ALLOW_FEQUOTA
C    I           Qfe_0,Qfe_bv1,Qfe_to1,Qfe_bv2,Qfe_to2,Qfe_b1t1,
C    O           afecom,afe00,afe10,afe01,afe20,afe02,afe11,
     I           Qfe,
     O           afecom,
#ifdef SPEAD_ALLOW_TRAITS
     I           Qfe_d1,Qfe_d2,
     O           afe_0,afe_d1,afe_d2,
#ifdef SPEAD_ALLOW_COV
     I           Qfe_d11,
     O           afe_d11
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_FEQUOTA */
#ifdef DARWIN_ALLOW_CHLQUOTA
C    I           QChl_0,QChl_bv1,QChl_to1,QChl_bv2,QChl_to2,QChl_b1t1,
C    O           aChlcom,aChl00,aChl10,aChl01,aChl20,aChl02,aChl11,
     I           QChl,
     O           aChlcom,
#ifdef SPEAD_ALLOW_TRAITS
     I           QChl_d1,QChl_d2,
     O           aChl_0,aChl_d1,aChl_d2,
#ifdef SPEAD_ALLOW_COV
     I           QChl_d11,
     O           aChl_d11
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_CHLQUOTA */
C    O           g00,g10,g01,g20,g02,g11,
C    O           g00,g20,g02,g11,
C    O           gcom,acom,
C    O           a00,a10,a01,a20,a02,a11)
#ifdef SPEAD_ALLOW_TRAITS
     O           gcom,
     O           a_0,a_d1,a_d2,
#ifdef SPEAD_ALLOW_COV
     O           a_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#ifdef DARWIN_GRAZING_SWITCH
     O           coeff_KTW,
#endif
     O           acom)

#ifdef DARWIN_DEBUG
      IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C        print*,'Concentration derivatives',myiter,k,j,
        print*,'Concentration derivatives',
     &     dDIC,
     &     dNH4,
     &     dNO2,
     &     dNO3,
     &     dDOC,
     &     dDON,
     &     dPIC,
     &     dPOC,
     &     dPON,
#ifdef DARWIN_ALLOW_CARBON
     &     dO2,
     &     dALK,
#endif
     &     ''
      ENDIF
#endif

#ifdef DARWIN_DEBUG
C     IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C       print*,'myTime',myTime,'myIter',myIter
C       print*,'gcom:', gcom(1:4), 'acom:', acom(1:4),'a_0:',a_0(1:4)
C       print*,'a_d1:', a_d1(1:1,:)
C       print*,'a_d2:', a_d2(1:1,:)
C       print*,'a_d11:', a_d11(1:1,:)
CC   &         'a_0:', a_0, 'a_d1:', a_d1, 'a_d2:', a_d2, 'a_d11', a_d11
CC   &         'a00:', a00, 'a10:', a10, 'a01:', a01,
CC   &         'a20:', a20, 'a02:', a02, 'a11:', a11
CC      print*,'alternative acom:', a_0(1)+(1./2.)*vr_tr(1,1)*a_d2(1,1)
CC   &         + (1./2.)*vr_tr(1,2)*a_d2(1,2) + cv_tr(1,1)*a_d11(1,1)
C       print*,'alternative acom:', a_0(1)+(1./2.)*vr_tr(1,1)*a_d2(1,1)
C    &         + (1./2.)*vr_tr(1,2)*a_d2(1,2) + cv_tr(1,1)*a_d11(1,1)
C    &         + (1./2.)*vr_tr(1,3)*a_d2(1,3) + cv_tr(1,2)*a_d11(1,2)
C    &         + cv_tr(1,3)*a_d11(1,3)
CC      print*,'alternative acom:', a00(1) + (1./2.)*vr_bvol(1)*a20(1)
CC   &         + (1./2.)*vr_topt(1)*a02(1) + cv_bvto(1)*a11(1)
C       print*,'a_KTW', a_KTW, 'coeff_KTW', coeff_KTW
C     ENDIF
#endif

C-----------------------------------------------------------------------
C-------------------------- End Step 3 ---------------------------------
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 4: Compute time derivatives of all variables (Le Gland, 22/01/2021)
C-----------------------------------------------------------------------

C These equations are intrinsic to the aggregate (continuous) approach
C They do not depend on the physical or ecological model
C At some point, mass consrvation will absolutely need to be verified

C The quota thing is a nightmare, I will do it later if requested

      gTr(iDIC ) = gTr(iDIC ) + dDIC
      gTr(iNH4 ) = gTr(iNH4 ) + dNH4
      gTr(iNO2 ) = gTr(iNO2 ) + dNO2
      gTr(iNO3 ) = gTr(iNO3 ) + dNO3
      gTr(iPO4 ) = gTr(iPO4 ) + dPO4
      gTr(iSiO2) = gTr(iSiO2) + dSiO2
      gTr(iFeT ) = gTr(iFeT ) + dFeT
      gTr(iDOC ) = gTr(iDOC ) + dDOC
      gTr(iDON ) = gTr(iDON ) + dDON
      gTr(iDOP ) = gTr(iDOP ) + dDOP
      gTr(iDOFe) = gTr(iDOFe) + dDOFe
      gTr(iPIC ) = gTr(iPIC ) + dPIC
      gTr(iPOC ) = gTr(iPOC ) + dPOC
      gTr(iPON ) = gTr(iPON ) + dPON
      gTr(iPOP ) = gTr(iPOP ) + dPOP
      gTr(iPOSi) = gTr(iPOSi) + dPOSi
      gTr(iPOFe) = gTr(iPOFe) + dPOFe
#ifdef DARWIN_ALLOW_CARBON
      gTr(iO2) = gTr(iO2) + dO2
      gTr(iALK) = gTr(iALK) + dALK
#endif

      DO j = 1, nplank

C       gcom(j) = g00(j) + (1/2)*vr_bvol(j)*g20(j)
C    &            + (1/2)*vr_topt(j)*g02(j) + cv_bvto(j)*g11(j)

C       dXdt(j) = (a00(j) + (1/2)*vr_bvol(j)*a20(j)
C    &          + (1/2)*vr_topt(j)*a02(j) + cv_bvto(j)*a11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dXdt(j) = acom(j)*X(j)
        gTr(ic+iplank(j)-1) = gTr(ic+iplank(j)-1) + dXdt(j)

C       IF(isPhoto(iplank(j)) .NE. 0) THEN
C         dmbdt(j) = a10(j)*vr_bvol(j) + a01(j)*cv_bvto(j)
C         gTr(ic+iplank(j)) = gTr(ic+iplank(j)) + dmbdt(j)*X(j)
C    &                         + mn_bvol(j)*dXdt(j)

C         dmtdt(j) = a01(j)*vr_topt(j) + a10(j)*cv_bvto(j)
C         gTr(ic+iplank(j)+1) = gTr(ic+iplank(j)+1) + dmtdt(j)*X(j)
C    &                         + mn_topt(j)*dXdt(j)

C         dvbdt(j) = a20(j)*(vr_bvol(j)**2)
C    &             + 2*a11(j)*vr_bvol(j)*cv_bvto(j)
C    &             + a02(j)*(cv_bvto(j)**2)
C    &             + 2*gcom(j)*numut_bvol(j)
C         gTr(ic+iplank(j)+2) = gTr(ic+iplank(j)+2) + dvbdt(j)*X(j)
C    &                 + dXdt(j)*vr_bvol(j) + 2*mn_bvol(j)*dmbdt(j)*X(j)
C    &                 + dXdt(j)*(mn_bvol(j)**2)

C         dvtdt(j) = a02(j)*(vr_topt(j)**2)
C    &             + 2*a11(j)*vr_topt(j)*cv_bvto(j)
C    &             + a20(j)*(cv_bvto(j)**2)
C    &             + 2*gcom(j)*numut_topt(j)
C         gTr(ic+iplank(j)+3) = gTr(ic+iplank(j)+3) + dvtdt(j)*X(j)
C    &                 + dXdt(j)*vr_topt(j) + 2*mn_topt(j)*dmtdt(j)*X(j)
C    &                 + dXdt(j)*(mn_topt(j)**2)

C         dcbtdt(j) = a20(j)*vr_bvol(j)*cv_bvto(j)
C    &             + a11(j)*(vr_bvol(j)*vr_topt(j)+cv_bvto(j)**2)
C    &             + a02(j)*vr_topt(j)*cv_bvto(j)
C         gTr(ic+iplank(j)+4) = gTr(ic+iplank(j)+4) + dcbtdt(j)*X(j)
C    &                 + dXdt(j)*cv_bvto(j) + mn_bvol(j)*dmtdt(j)*X(j)
C    &                 + mn_topt(j)*dmbdt(j)*X(j)
C    &                 + dXdt(j)*(mn_bvol(j)*mn_topt(j))
C       ENDIF

#ifdef SPEAD_ALLOW_TRAITS
        DO jp = 1, num_trait(j)
          dmndt(j,jp) = dmndt(j,jp) + a_d1(j,jp)*vr_tr(j,jp)
C         dvrdt(j,jp) = a_d2(j,jp)*(vr_tr(j,jp)**2)
          dvrdt(j,jp) = dvrdt(j,jp) + a_d2(j,jp)*(vr_tr(j,jp)**2)
     &                + 2*gcom(j)*numut_tr(j,jp)     
        END DO
#ifdef SPEAD_ALLOW_COV
C Terms occurring when num_trait(j) > 2
C       DO jc = 1,num_cov(j)
C         dcvdt(j,jc) = 0.0
C       ENDDO
        DO jt1 = 1, num_trait(j)-1
          DO jt2 = jt1+1, num_trait(j)
            jc = (jt1-1)*nint(num_trait(j)-jt1/2.0) + jt2 - jt1
CC          jc = icov(j,jt1,jt2)
C           IF (myIter .EQ. 1) THEN
C             print*, 'check indices:    ', 'jt1', jt1, 'jt2', jt2,
C    &                'jc', jc
C           ENDIF
            dmndt(j,jt1) = dmndt(j,jt1) + a_d1(j,jt2)*cv_tr(j,jc)
            dmndt(j,jt2) = dmndt(j,jt2) + a_d1(j,jt1)*cv_tr(j,jc)
            dvrdt(j,jt1) = dvrdt(j,jt1)
     &                   + 2*a_d11(j,jc)*vr_tr(j,jt1)*cv_tr(j,jc)
     &                   + a_d2(j,jt2)*(cv_tr(j,jc)**2)
            dvrdt(j,jt2) = dvrdt(j,jt2)
     &                   + 2*a_d11(j,jc)*vr_tr(j,jt2)*cv_tr(j,jc)
     &                   + a_d2(j,jt1)*(cv_tr(j,jc)**2)

C           print*,'jc:', jc, 'dcvdt(1,jc):', dcvdt(1,jc)

C           cv_unbounded = X_m11(j,jc)/X(j) - mn_tr(j,jt1)*mn_tr(j,jt2)
            dcvdt(j,jc)  = dcvdt(j,jc)
     &                   + a_d2(j,jt1)*vr_tr(j,jt1)*cv_tr(j,jc)
C    &                   + a_d2(j,jt1)*vr_tr(j,jt1)*cv_unbounded
CC          dcvdt(j,jc)  = a_d2(j,jt1)*vr_tr(j,jt1)*cv_tr(j,jc)
     &                   + a_d2(j,jt2)*vr_tr(j,jt2)*cv_tr(j,jc)
C    &                   + a_d2(j,jt2)*vr_tr(j,jt2)*cv_unbounded
     &      + a_d11(j,jc)*(vr_tr(j,jt1)*vr_tr(j,jt2)+(cv_tr(j,jc)**2))

C           print*,'jc:', jc, 'dcvdt(1,jc):', dcvdt(1,jc),
C    &             'Term 11:',a_d2(j,jt1)*vr_tr(j,jt1)*cv_tr(j,jc),
C    &             'Term 22:',a_d2(j,jt2)*vr_tr(j,jt2)*cv_tr(j,jc),
C    &             'Term 12:',a_d11(j,jc)*(vr_tr(j,jt1)*vr_tr(j,jt2)
C    &                        +(cv_tr(j,jc)**2))

C Terms occurring when num_trait(j) > 3
            DO jt3 = jt2+1, num_trait(j)
              jc13 = jc + jt3 - jt2
              jc23 = jc13
     &             + nint((jt2-jt1)*(num_trait(j)-(jt1+jt2+1)/2.))
C             IF (myIter .EQ. 1) THEN
C               print*, 'check indices:    ', 'jt1', jt1, 'jt2', jt2,
C    &                  'jt3', jt3, 'jc', jc, 'jc13', jc13, 'jc23', jc23
C             ENDIF
CC            jc13 = icov(j,jt1,jt3)
CC            jc23 = icov(j,jt2,jt3)
              dvrdt(j,jt1) = dvrdt(j,jt1)
     &                     + 2*a_d11(j,jc23)*cv_tr(j,jc)*cv_tr(j,jc13)
              dvrdt(j,jt2) = dvrdt(j,jt2)
     &                     + 2*a_d11(j,jc13)*cv_tr(j,jc)*cv_tr(j,jc23)
              dvrdt(j,jt3) = dvrdt(j,jt3)
     &                     + 2*a_d11(j,jc)*cv_tr(j,jc13)*cv_tr(j,jc23)
CC            dcvdt(j,jc) = 0
              dcvdt(j,jc)  = dcvdt(j,jc)
     &                 + a_d11(j,jc13) * ( vr_tr(j,jt1)*cv_tr(j,jc23)
     &                                   + cv_tr(j,jc)*cv_tr(j,jc13) )
     &                 + a_d11(j,jc23) * ( vr_tr(j,jt2)*cv_tr(j,jc13)
     &                                   + cv_tr(j,jc)*cv_tr(j,jc23) )
     &                 + a_d2(j,jt3) * cv_tr(j,jc13) * cv_tr(j,jc23)
     
c                IF(dvrdt(j,jt1) /= dvrdt(j,jt1)) THEN
c                    print*
c     &                ,'After second cov dvr = Nan... Time', myIter 
c     &                ,'iG', iG
c     &                ,'jG', jG
c     &                ,'k', k
c     &                ,'X_m2', X_m2(j,jt1)   
c     &                ,'X', X(j)             
c     &                ,'trait', jt1
c     &                ,'dvrdt', dvrdt(j,jt1)
c     &                ,'a_d2', a_d2(j,jt1)
c     &                ,'vr_tr 1', vr_tr(j,jt1)
c     &                ,'gcom', gcom(j)
c     &                ,'numut_tr', numut_tr(j,jt1)
c                ENDIF

C             print*,'jc:', jc, 'dcvdt(1,jc):', dcvdt(1,jc),
C    &         'Term 13:',a_d11(j,jc13) * ( vr_tr(j,jt1)*cv_tr(j,jc23)
C    &                                  + cv_tr(j,jc)*cv_tr(j,jc13) ),
C    &         'Term 23:',a_d11(j,jc23) * ( vr_tr(j,jt2)*cv_tr(j,jc13)
C    &                                  + cv_tr(j,jc)*cv_tr(j,jc23) ),
C    &         'Term 33:',a_d2(j,jt3) * cv_tr(j,jc13) * cv_tr(j,jc23)

              dcvdt(j,jc13)  = dcvdt(j,jc13)
     &                 + a_d11(j,jc)   * ( vr_tr(j,jt1)*cv_tr(j,jc23)
     &                                   + cv_tr(j,jc13)*cv_tr(j,jc) )
     &                 + a_d11(j,jc23) * ( vr_tr(j,jt3)*cv_tr(j,jc)
     &                                   + cv_tr(j,jc13)*cv_tr(j,jc23) )
     &                 + a_d2(j,jt2) * cv_tr(j,jc) * cv_tr(j,jc23)

C             print*,'jc:', jc13, 'dcvdt(1,jc):', dcvdt(1,jc13),
C    &         'Term 13:',a_d11(j,jc)   * ( vr_tr(j,jt1)*cv_tr(j,jc23)
C    &                                  + cv_tr(j,jc13)*cv_tr(j,jc) ),
C    &         'Term 23:',a_d11(j,jc23) * ( vr_tr(j,jt3)*cv_tr(j,jc)
C    &                                + cv_tr(j,jc13)*cv_tr(j,jc23) ),
C    &         'Term 33:',a_d2(j,jt2) * cv_tr(j,jc) * cv_tr(j,jc23)

              dcvdt(j,jc23)  = dcvdt(j,jc23)
     &                 + a_d11(j,jc13) * ( vr_tr(j,jt3)*cv_tr(j,jc)
     &                                 + cv_tr(j,jc13)*cv_tr(j,jc23) )
     &                 + a_d11(j,jc) * ( vr_tr(j,jt2)*cv_tr(j,jc13)
     &                                   + cv_tr(j,jc)*cv_tr(j,jc23) )
     &                 + a_d2(j,jt1) * cv_tr(j,jc13) * cv_tr(j,jc)

C             print*,'jc:', jc23, 'dcvdt(1,jc23):', dcvdt(1,jc23),
C    &         'Term 13:',a_d11(j,jc13) * ( vr_tr(j,jt3)*cv_tr(j,jc)
C    &                              + cv_tr(j,jc13)*cv_tr(j,jc23) ),
C    &         'Term 23:',a_d11(j,jc) * ( vr_tr(j,jt2)*cv_tr(j,jc13)
C    &                                + cv_tr(j,jc)*cv_tr(j,jc23) ),
C    &         'Term 33:',a_d2(j,jt1) * cv_tr(j,jc13) * cv_tr(j,jc)

C Terms occurring when num_trait(j) > 4
C             DO jt4 = jt3+1, num_trait(j)
C               jc14 = jc   + jt4 - jt1
C               jc24 = jc23 + jt4 - jt3
C               jc34 = jc24
C    &               + nint((jt3-jt2)*(num_trait(j)-(jt2+jt3+1)/2.))
CC              jc14 = icov(j,jt1,jt4)
CC              jc24 = icov(j,jt2,jt4)
CC              jc34 = icov(j,jt3,jt4)
C               dcvdt(j,jc) = dcvdt(j,jc)
C    &               + a_d11(j,jc34) * ( cv_tr(j,jc13)*cv_tr(j,jc24)
C    &                                 + cv_tr(j,jc14)*cv_tr(j,jc23) )
C               dcvdt(j,jc13) = dcvdt(j,jc13)
C    &               + a_d11(j,jc24) * ( cv_tr(j,jc)  *cv_tr(j,jc34)
C    &                                 + cv_tr(j,jc14)*cv_tr(j,jc23) )
C               dcvdt(j,jc14) = dcvdt(j,jc14)
C    &               + a_d11(j,jc23) * ( cv_tr(j,jc)  *cv_tr(j,jc34)
C    &                                 + cv_tr(j,jc13)*cv_tr(j,jc24) )
C               dcvdt(j,jc23) = dcvdt(j,jc14)
C    &               + a_d11(j,jc14) * ( cv_tr(j,jc)  *cv_tr(j,jc34)
C    &                                 + cv_tr(j,jc13)*cv_tr(j,jc24) )
C               dcvdt(j,jc24) = dcvdt(j,jc24)
C    &               + a_d11(j,jc13) * ( cv_tr(j,jc)  *cv_tr(j,jc34)
C    &                                 + cv_tr(j,jc14)*cv_tr(j,jc23) )
C               dcvdt(j,jc34) = dcvdt(j,jc34)
C    &               + a_d11(j,jc)   * ( cv_tr(j,jc13)*cv_tr(j,jc24)
C    &                                 + cv_tr(j,jc14)*cv_tr(j,jc23) )
C             ENDDO
            ENDDO
            jc = jc + 1
          ENDDO
        ENDDO
#endif
        
C Parameterization of Kill The Winner (KTW) preferential grazing (Le Gland, 27/08/2021)
#ifdef DARWIN_GRAZING_SWITCH
        DO jp = 1, num_trait(j)
          dvrdt(j,jp) = dvrdt(j,jp) + coeff_KTW(j)*vr_tr(j,jp)
        ENDDO
        DO jc = 1, num_cov(j)
          dcvdt(j,jc) = dcvdt(j,jc) + coeff_KTW(j)*cv_tr(j,jc)
        ENDDO
#endif

c        DO jp = 1, num_trait(j)
c            IF(dvrdt(j,jp) /= 0) THEN
c                IF (jp .EQ. 2) THEN
c                    print*
c     &                ,'Ends with dvrdt > 0... Time', myIter 
c     &                ,'iG', iG
c     &                ,'jG', jG
c     &                ,'k', k
c     &                ,'X_m2', X_m2(j,jp)   
c     &                ,'X', X(j)             
c     &                ,'trait', jp
c     &                ,'dvrdt', dvrdt(j,jp)
c     &                ,'vr_tr 1', vr_tr(j,jp)
c     &                ,'numut_tr', numut_tr(j,jp)
c                ENDIF
c            ENDIF 
c        ENDDO 
c       print*, 'gTr:', gTr(ic:ic+nTrac-1)

C Trends of conserved tracers
        jt = ic + iplank(j)
        DO jp = 1, num_trait(j)
          gTr(jt) = gTr(jt) + dmndt(j,jp)*X(j) + mn_tr(j,jp)*dXdt(j)
          jt = jt + 1
        ENDDO
        DO jp = 1, num_trait(j)
          gTr(jt) = gTr(jt) + dvrdt(j,jp)*X(j) + vr_tr(j,jp)*dXdt(j)
     &            + 2*mn_tr(j,jp)*dmndt(j,jp)*X(j)
     &            + (mn_tr(j,jp)**2)*dXdt(j)
          jt = jt + 1
        ENDDO
        jt1 = 1
        jt2 = 2
        DO jc = 1, num_cov(j)
C         IF (myIter .EQ. 1) THEN
C           print*, 'check indices:    ', 'jt', jt, 'jt1', jt1,
C    &              'jt2', jt2, 'jc', jc, 'species(j)', j
C         ENDIF
          gTr(jt) = gTr(jt) + dcvdt(j,jc)*X(j) + cv_tr(j,jc)*dXdt(j)
     &            + mn_tr(j,jt1)*dmndt(j,jt2)*X(j)
     &            + mn_tr(j,jt2)*dmndt(j,jt1)*X(j)
     &            + mn_tr(j,jt1)*mn_tr(j,jt2)*dXdt(j)
          jt = jt + 1
          IF (jt2 < num_trait(j)) THEN
            jt2 = jt2 + 1
          ELSE
            jt1 = jt1 + 1
            jt2 = jt1 + 1
          ENDIF
        ENDDO

#endif /* SPEAD_ALLOW_TRAITS */


#ifdef DARWIN_ALLOW_NQUOTA
C The effect of mutation rates is only introduced at the last stage
C I fear that using growth might lead to mass conservation violation if dt > 0 (rounding errors)
C We should ensure that at the end the variation in total nitrogen is zero
C Solution: compute directly the derivatives of the tracers (Le Gland, 27/01/2021)
C       dQn00(j) = (an00(j) + (1/2)*vr_bvol(j)*an20(j)
C    &          + (1/2)*vr_topt(j)*an02(j) + cv_bvto(j)*an11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dQn00(j) = ancom(j)*X(j)
        gTr(in+iplank(j)-1) = gTr(in+iplank(j)-1) + dQn00(j)

        IF(isPhoto(iplank(j)) .NE. 0) THEN
          dQn10(j) = mn_bvol(j)*dQn00(j)
     &             + (vr_bvol(j)*an10(j) + cv_bvto(j)*an01(j))*X(j)
          gTr(in+iplank(j)) = gTr(in+iplank(j)) + dQn10(j)

          dQn01(j) = mn_topt(j)*dQn00(j)
     &             + (vr_topt(j)*an01(j) + cv_bvto(j)*an10(j))*X(j)
          gTr(in+iplank(j)+1) = gTr(in+iplank(j)+1) + dQn01(j)

          dQn20(j) = (vr_bvol(j)*an00(j)
     &         + (3.0/2.0)*(vr_bvol(j)**2)*an20(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*an02(j)
     &         + 3*(vr_bvol(j)*cv_bvto(j))*an11(j))*X(j)
     &         + 2*mn_bvol(j)*dQn10(j) - (mn_bvol(j)**2)*dQn00(j)
     &         + 2*gcom(j)*numut_bvol(j)*Qn00(j)
          gTr(in+iplank(j)+2) = gTr(in+iplank(j)+2) + dQn20(j)

          dQn02(j) = (vr_topt(j)*an00(j)
     &         + (3.0/2.0)*(vr_topt(j)**2)*an02(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*an20(j)
     &         + 3*(vr_topt(j)*cv_bvto(j))*an11(j))*X(j)
     &         + 2*mn_topt(j)*dQn01(j) - (mn_topt(j)**2)*dQn00(j)
     &         + 2*gcom(j)*numut_topt(j)*Qn00(j)
          gTr(in+iplank(j)+3) = gTr(in+iplank(j)+3) + dQn02(j)

          dQn11(j) = (cv_bvto(j)*an00(j)
     &         + (3.0/2.0)*(vr_bvol(j)*cv_bvto(j))*an20(j)
     &         + (3.0/2.0)*(vr_topt(j)*cv_bvto(j))*an02(j)
     &         + (vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*an11(j))*X(j)
     &         + mn_bvol(j)*dQn01(j) + mn_topt(j)*dQn10(j)
     &         - mn_bvol(j)*mn_topt(j)*dQn00(j)
          gTr(in+iplank(j)+4) = gTr(in+iplank(j)+4) + dQn11(j)
        ENDIF
#endif

#ifdef DARWIN_ALLOW_PQUOTA
C       dQp00(j) = (ap00(j) + (1/2)*vr_bvol(j)*ap20(j)
C    &          + (1/2)*vr_topt(j)*ap02(j) + cv_bvto(j)*ap11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dQp00(j) = apcom(j)*X(j)
        gTr(ip+iplank(j)-1) = gTr(ip+iplank(j)-1) + dQp00(j)

        IF(isPhoto(iplank(j)) .NE. 0) THEN
          dQp10(j) = mn_bvol(j)*dQp00(j)
     &             + (vr_bvol(j)*ap10(j) + cv_bvto(j)*ap01(j))*X(j)
          gTr(ip+iplank(j)) = gTr(ip+iplank(j)) + dQp10(j)

          dQp01(j) = mn_topt(j)*dQp00(j)
     &             + (vr_topt(j)*ap01(j) + cv_bvto(j)*ap10(j))*X(j)
          gTr(ip+iplank(j)+1) = gTr(ip+iplank(j)+1) + dQp01(j)

          dQp20(j) = (vr_bvol(j)*ap00(j)
     &         + (3.0/2.0)*(vr_bvol(j)**2)*ap20(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*ap02(j)
     &         + 3*(vr_bvol(j)*cv_bvto(j))*ap11(j))*X(j)
     &         + 2*mn_bvol(j)*dQp10(j) - (mn_bvol(j)**2)*dQp00(j)
     &         + 2*gcom(j)*numut_bvol(j)*Qp00(j)
          gTr(ip+iplank(j)+2) = gTr(ip+iplank(j)+2) + dQp20(j)

          dQp02(j) = (vr_topt(j)*ap00(j)
     &         + (3.0/2.0)*(vr_topt(j)**2)*ap02(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*ap20(j)
     &         + 3*(vr_topt(j)*cv_bvto(j))*ap11(j))*X(j)
     &         + 2*mn_topt(j)*dQp01(j) - (mn_topt(j)**2)*dQp00(j)
     &         + 2*gcom(j)*numut_topt(j)*Qp00(j)
          gTr(ip+iplank(j)+3) = gTr(ip+iplank(j)+3) + dQp02(j)

          dQp11(j) = (cv_bvto(j)*ap00(j)
     &         + (3.0/2.0)*(vr_bvol(j)*cv_bvto(j))*ap20(j)
     &         + (3.0/2.0)*(vr_topt(j)*cv_bvto(j))*ap02(j)
     &         + (vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*ap11(j))*X(j)
     &         + mn_bvol(j)*dQp01(j) + mn_topt(j)*dQp10(j)
     &         - mn_bvol(j)*mn_topt(j)*dQp00(j)
          gTr(ip+iplank(j)+4) = gTr(ip+iplank(j)+4) + dQp11(j)
        ENDIF
#endif


#ifdef DARWIN_ALLOW_SIQUOTA
C       dQsi00(j) = (asi00(j) + (1/2)*vr_bvol(j)*asi20(j)
C    &          + (1/2)*vr_topt(j)*asi02(j) + cv_bvto(j)*asi11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dQsi00(j) = asicom(j)*X(j)
        gTr(isi+iplank(j)-1) = gTr(isi+iplank(j)-1) + dQsi00(j)

        IF(isPhoto(iplank(j)) .NE. 0) THEN
          dQsi10(j) = mn_bvol(j)*dQsi00(j)
     &             + (vr_bvol(j)*asi10(j) + cv_bvto(j)*asi01(j))*X(j)
          gTr(isi+iplank(j)) = gTr(isi+iplank(j)) + dQsi10(j)

          dQsi01(j) = mn_topt(j)*dQsi00(j)
     &             + (vr_topt(j)*asi01(j) + cv_bvto(j)*asi10(j))*X(j)
          gTr(isi+iplank(j)+1) = gTr(isi+iplank(j)+1) + dQsi01(j)

          dQsi20(j) = (vr_bvol(j)*asi00(j)
     &       + (3.0/2.0)*(vr_bvol(j)**2)*asi20(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*asi02(j)
     &       + 3*(vr_bvol(j)*cv_bvto(j))*asi11(j))*X(j)
     &       + 2*mn_bvol(j)*dQsi10(j) - (mn_bvol(j)**2)*dQsi00(j)
     &       + 2*gcom(j)*numut_bvol(j)*Qsi00(j)
          gTr(isi+iplank(j)+2) = gTr(isi+iplank(j)+2) + dQsi20(j)

          dQsi02(j) = (vr_topt(j)*asi00(j)
     &       + (3.0/2.0)*(vr_topt(j)**2)*asi02(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*asi20(j)
     &       + 3*(vr_topt(j)*cv_bvto(j))*asi11(j))*X(j)
     &       + 2*mn_topt(j)*dQsi01(j) - (mn_topt(j)**2)*dQsi00(j)
     &       + 2*gcom(j)*numut_topt(j)*Qsi00(j)
          gTr(isi+iplank(j)+3) = gTr(isi+iplank(j)+3) + dQsi02(j)

          dQsi11(j) = (cv_bvto(j)*asi00(j)
     &       + (3.0/2.0)*(vr_bvol(j)*cv_bvto(j))*asi20(j)
     &       + (3.0/2.0)*(vr_topt(j)*cv_bvto(j))*asi02(j)
     &       + (vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*asi11(j))*X(j)
     &       + mn_bvol(j)*dQsi01(j) + mn_topt(j)*dQsi10(j)
     &       - mn_bvol(j)*mn_topt(j)*dQsi00(j)
          gTr(isi+iplank(j)+4) = gTr(isi+iplank(j)+4) + dQsi11(j)
        ENDIF
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
C       dQfe00(j) = (afe00(j) + (1/2)*vr_bvol(j)*afe20(j)
C    &          + (1/2)*vr_topt(j)*afe02(j) + cv_bvto(j)*afe11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dQfe00(j) = afecom(j)*X(j)
        gTr(ife+iplank(j)-1) = gTr(ife+iplank(j)-1) + dQfe00(j)

        IF(isPhoto(iplank(j)) .NE. 0) THEN
          dQfe10(j) = mn_bvol(j)*dQfe00(j)
     &             + (vr_bvol(j)*afe10(j) + cv_bvto(j)*afe01(j))*X(j)
          gTr(ife+iplank(j)) = gTr(ife+iplank(j)) + dQfe10(j)

          dQfe01(j) = mn_topt(j)*dQfe00(j)
     &             + (vr_topt(j)*afe01(j) + cv_bvto(j)*afe10(j))*X(j)
          gTr(ife+iplank(j)+1) = gTr(ife+iplank(j)+1) + dQfe01(j)

          dQfe20(j) = (vr_bvol(j)*afe00(j)
     &       + (3.0/2.0)*(vr_bvol(j)**2)*afe20(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*afe02(j)
     &       + 3*(vr_bvol(j)*cv_bvto(j))*afe11(j))*X(j)
     &       + 2*mn_bvol(j)*dQfe10(j) - (mn_bvol(j)**2)*dQfe00(j)
     &       + 2*gcom(j)*numut_bvol(j)*Qfe00(j)
          gTr(ife+iplank(j)+2) = gTr(ife+iplank(j)+2) + dQfe20(j)

          dQfe02(j) = (vr_topt(j)*afe00(j)
     &       + (3.0/2.0)*(vr_topt(j)**2)*afe02(j)
     &    + (1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*afe20(j)
     &       + 3*(vr_topt(j)*cv_bvto(j))*afe11(j))*X(j)
     &       + 2*mn_topt(j)*dQfe01(j) - (mn_topt(j)**2)*dQfe00(j)
     &       + 2*gcom(j)*numut_topt(j)*Qfe00(j)
          gTr(ife+iplank(j)+3) = gTr(ife+iplank(j)+3) + dQfe02(j)

          dQfe11(j) = (cv_bvto(j)*afe00(j)
     &       + (3.0/2.0)*(vr_bvol(j)*cv_bvto(j))*afe20(j)
     &       + (3.0/2.0)*(vr_topt(j)*cv_bvto(j))*afe02(j)
     &       + (vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*afe11(j))*X(j)
     &       + mn_bvol(j)*dQfe01(j) + mn_topt(j)*dQfe10(j)
     &       - mn_bvol(j)*mn_topt(j)*dQfe00(j)
          gTr(ife+iplank(j)+4) = gTr(ife+iplank(j)+4) + dQfe11(j)
        ENDIF
#endif

#ifdef DARWIN_ALLOW_CHLQUOTA
C       dQChl00(j) = (aChl00(j) + (1/2)*vr_bvol(j)*aChl20(j)
C    &        + (1/2)*vr_topt(j)*aChl02(j) + cv_bvto(j)*aChl11(j))*X(j)
C Equivalent, but easier to check mass conservation (Le Gland, 15/03/2021)
        dQChl00(j) = aChlcom(j)*X(j)
        gTr(iChl+iplank(j)-1) = gTr(iChl+iplank(j)-1) + dQChl00(j)

        IF(isPhoto(iplank(j)) .NE. 0) THEN
          dQChl10(j) = mn_bvol(j)*dQChl00(j)
     &             + (vr_bvol(j)*aChl10(j) + cv_bvto(j)*aChl01(j))*X(j)
          gTr(iChl+iplank(j)) = gTr(iChl+iplank(j)) + dQChl10(j)

          dQChl01(j) = mn_topt(j)*dQChl00(j)
     &             + (vr_topt(j)*aChl01(j) + cv_bvto(j)*aChl10(j))*X(j)
          gTr(iChl+iplank(j)+1) = gTr(iChl+iplank(j)+1) + dQChl01(j)

          dQChl20(j) = (vr_bvol(j)*aChl00(j)
     &       + (3.0/2.0)*(vr_bvol(j)**2)*aChl20(j)
     &    +(1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*aChl02(j)
     &       + 3*(vr_bvol(j)*cv_bvto(j))*aChl11(j))*X(j)
     &       + 2*mn_bvol(j)*dQChl10(j) - (mn_bvol(j)**2)*dQChl00(j)
     &       + 2*gcom(j)*numut_bvol(j)*QChl00(j)
          gTr(iChl+iplank(j)+2) = gTr(iChl+iplank(j)+2) + dQChl20(j)

          dQChl02(j) = (vr_topt(j)*aChl00(j)
     &       + (3.0/2.0)*(vr_topt(j)**2)*aChl02(j)
     &    +(1.0/2.0)*(vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*aChl20(j)
     &       + 3*(vr_topt(j)*cv_bvto(j))*aChl11(j))*X(j)
     &       + 2*mn_topt(j)*dQChl01(j) - (mn_topt(j)**2)*dQChl00(j)
     &       + 2*gcom(j)*numut_topt(j)*QChl00(j)
          gTr(iChl+iplank(j)+3) = gTr(iChl+iplank(j)+3) + dQChl02(j)

          dQChl11(j) = (cv_bvto(j)*aChl00(j)
     &       + (3.0/2.0)*(vr_bvol(j)*cv_bvto(j))*aChl20(j)
     &       + (3.0/2.0)*(vr_topt(j)*cv_bvto(j))*aChl02(j)
     &       + (vr_bvol(j)*vr_topt(j)+2*(cv_bvto(j)**2))*aChl11(j))*X(j)
     &       + mn_bvol(j)*dQChl01(j) + mn_topt(j)*dQChl10(j)
     &       - mn_bvol(j)*mn_topt(j)*dQChl00(j)
          gTr(iChl+iplank(j)+4) = gTr(iChl+iplank(j)+4) + dQChl11(j)
        ENDIF
#endif

      ENDDO
#ifdef DARWIN_DEBUG
C     IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C       print*, 'dX:', dXdt
C       print*, 'dmndt', dmndt(1:2,:)
C       print*, 'dvrdt', dvrdt(1:2,:)
C       print*, 'dcvdt:', dcvdt(1:2,:)
C       print*, 'Ptr:', Ptr(ic:ic+nTrac-2)
C       print*, 'gTr:', gTr(ic:ic+nTrac-2)
C       print*,'-------------------------------------------------------'
C     ENDIF
#endif

C Check that no NaN is present (Le Gland, 13/05/2021)
      DO j=1,nplank
        IF (acom(j) /= acom(j) .AND. myIter > 1) THEN
C       IF (dNO2 /= dNO2 .AND. myIter > 1) THEN
#ifdef DARWIN_DEBUG
          WRITE(msgBuf,'(2A,2I6,A,3I6,A,2F20.6,4(A,3F20.6))')
     &    'DARWIN_PLANKTON: ',
     &    'acom(j) has NaN value', j, myIter, ' Location:', iG,jG,k,
#else
          WRITE(msgBuf,'(2A,2I6,A,2F20.6,4(A,3F20.6))')
     &    'DARWIN_PLANKTON: ',
     &    'acom(j) has NaN value', j, myIter,
#endif
     &    '  Concentrations:', X(j), X(j+1),
     &    '  Mean trait values:', mn_tr(j,1), mn_tr(j,2), mn_tr(j,3),
     &    '  Reference trait values:', ref_tr(j,1), ref_tr(j,2),
     &    ref_tr(j,3),
     &    '  Trait variances:', vr_tr(j,1), vr_tr(j,2), vr_tr(j,3),
     &    '  Trait covariances:', cv_tr(j,1), cv_tr(j,2), cv_tr(j,3)
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_PLANKTON'
        ENDIF
      ENDDO

C Moment derivatives (Le Gland, 16/06/2022)
#ifdef SPEAD_DIAG_MD
      DO jp = 1,nphyp
        jc = 1
        DO jt1 = 1,nTrait
          diags(iDmnt+(jp-1)*nTrait+jt1-1) = dmndt(jp,jt1)
          diags(iDvrt+(jp-1)*nTrait+jt1-1) = dvrdt(jp,jt1)
          diags(iDvrs+(jp-1)*nTrait+jt1-1) = 2*gcom(jp)*numut_tr(jp,jt1)
     &                                     + coeff_KTW(jp)*vr_tr(jp,jt1)
            
          DO jt2 = jt1+1,nTrait
            diags(iDcvt+(jp-1)*nCov+jc-1) = dcvdt(jp,jc)
            diags(iDcvs+(jp-1)*nCov+jc-1) = coeff_KTW(jp)*cv_tr(jp,jc)
            jc = jc + 1
          ENDDO
        ENDDO
      ENDDO
#endif

C-----------------------------------------------------------------------
C-------------------------- End Step 4 ---------------------------------
C-----------------------------------------------------------------------

#endif /* ALLOW_DARWIN */

      RETURN
      END SUBROUTINE
