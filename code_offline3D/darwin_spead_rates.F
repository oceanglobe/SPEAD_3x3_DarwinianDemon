#include "DARWIN_OPTIONS.h"

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
#ifdef DARWIN_DEBUG
     I     iG, jG, k, dT,
#endif
#ifdef DARWIN_ALLOW_CARBON
     I     O2,ALK,
     O     dO2,dALK,
#endif
#ifdef DARWIN_ALLOW_CDOM
     I     CDOM,
     O     dCDOM,
#endif
C    I     X,mn_bvol,mn_topt,vr_bvol_vr_topt,cv_bvto,
     I     X,
#ifdef SPEAD_ALLOW_TRAITS
     I     mn_tr,vr_tr,
#ifdef SPEAD_ALLOW_COV
     I     cv_tr,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#ifdef DARWIN_ALLOW_NQUOTA
C    I     Qn_0,Qn_bv1,Qn_to1,Qn_bv2,Qn_to2,Qn_b1t1,
C    O     ancom,an00,an10,an01,an20,an02,an11,
     I     Qn_0,
     O     ancom,
#ifdef SPEAD_ALLOW_TRAITS
     I     Qn_d1,Qn_d2,
     O     an_0,an_d1,an_d2,
#ifdef SPEAD_ALLOW_COV
     I     Qn_d11,
     O     an_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_NQUOTA */
#ifdef DARWIN_ALLOW_PQUOTA
C    I     Qp_0,Qp_bv1,Qp_to1,Qp_bv2,Qp_to2,Qp_b1t1,
C    O     apcom,ap00,ap10,ap01,ap20,ap02,ap11,
     I     Qp_0,
     O     apcom,
#ifdef SPEAD_ALLOW_TRAITS
     I     Qp_d1,Qp_d2,
     O     ap_0,ap_d1,ap_d2,
#ifdef SPEAD_ALLOW_COV
     I     Qp_d11,
     O     ap_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_PQUOTA */
#ifdef DARWIN_ALLOW_SIQUOTA
C    I     Qsi_0,Qsi_bv1,Qsi_to1,Qsi_bv2,Qsi_to2,Qsi_b1t1,
C    O     asicom,asi00,asi10,asi01,asi20,asi02,usi11,
     I     Qsi_0,
     O     asicom,
#ifdef SPEAD_ALLOW_TRAITS
     I     Qsi_d1,Qsi_d2,
     O     asi_0,asi_d1,asi_d2,
#ifdef SPEAD_ALLOW_COV
     I     Qsi_d11,
     O     asi_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_SIQUOTA */
#ifdef DARWIN_ALLOW_FEQUOTA
C    I     Qfe_0,Qfe_bv1,Qfe_to1,Qfe_bv2,Qfe_to2,Qfe_b1t1,
C    O     afecom,afe00,afe10,afe01,afe20,afe02,afe11,
     I     Qfe_0,
     O     afecom,
#ifdef SPEAD_ALLOW_TRAITS
     I     Qfe_d1,Qfe_d2,
     O     afe_0,afe_d1,afe_d2,
#ifdef SPEAD_ALLOW_COV
     I     Qfe_d11,
     O     afe_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_FEQUOTA */
#ifdef DARWIN_ALLOW_CHLQUOTA
C    I     QChl_0,QChl_bv1,QChl_to1,QChl_bv2,QChl_to2,QChl_b1t1,
C    O     aChlcom,aChl00,aChl10,aChl01,aChl20,aChl02,aChl11,
     I     QChl_0,
     O     aChlcom,
#ifdef SPEAD_ALLOW_TRAITS
     I     QChl_d1,QChl_d2,
     O     aChl_0,aChl_d1,aChl_d2,
#ifdef SPEAD_ALLOW_COV
     I     QChl_d11,
     O     aChl_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_CHLQUOTA */
C    O     g00,g10,g01,g20,g02,g11,
C    O     g00,g20,g02,g11,
C    O     gcom,acom,
C    O     a00,a10,a01,a20,a02,a11)
#ifdef SPEAD_ALLOW_TRAITS
     O     gcom,
     O     a_0,a_d1,a_d2,
#ifdef SPEAD_ALLOW_COV
     O     a_d11,
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#ifdef DARWIN_GRAZING_SWITCH
     O     coeff_KTW,
#endif
     O     acom)

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
#include "DARWIN_TRAITPARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  Ptr    :: darwin model tracers
C  PAR    :: PAR in uEin/s/m2
C         :: either non-spectral (tlam=1) or waveband total
C  myTime :: current time
C  myIter :: current iteration number
C  myThid :: thread number
C     _RL Ptr(nDarwin)
C     _RL PAR(nlam)
C Continuous model: temperature dependance is managed within darwin_plankton (Le Gland, 14/01/2021)
C     _RL photoTempFunc(nplank)
C     _RL reminTempFunc
C     _RL uptakeTempFunc
C     _RL grazTempFunc(nplank)
C     _RL mortTempFunc
C     _RL mort2TempFunc
C Continuous model: we separate mathematical manipulations (darwin_plankton.F)
C from the biogeochemistry model (spead_rates.F)
C In spead_rates.F, there are many input and output variables
      _RL PAR(nlam)
      _RL temp
      INTEGER myThid, myIter
      _RL myTime
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
      _RL PIC
      _RL POC
      _RL PON
      _RL POP
      _RL POSi
      _RL POFe
#ifdef DARWIN_DEBUG
      INTEGER iG, jG, k
      _RL dT
#endif
#ifdef DARWIN_ALLOW_CARBON
      _RL ALK
#endif
C O2 must be defined out of "ALLOW_CARBON" to avoid a bug in the bacteria code
C However its value is not set if ALLOW_CARBON is not defined
C (Le Gland, 15/03/2021)
      _RL O2
#ifdef DARWIN_ALLOW_CDOM
      _RL CDOM
#endif
      _RL X(nplank)
C     _RL mn_bvol(nplank)
C     _RL mn_topt(nplank)
C     _RL vr_bvol(nplank)
C     _RL vr_topt(nplank)
C     _RL cv_bvto(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL mn_tr(nplank,nTrait)
      _RL vr_tr(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL cv_tr(nplank,nCov)
#endif
#endif
#ifdef DARWIN_ALLOW_NQUOTA
      _RL Qn_0(nplank)
C     _RL Qn_bv1(nplank)
C     _RL Qn_to1(nplank)
C     _RL Qn_bv2(nplank)
C     _RL Qn_to2(nplank)
C     _RL Qn_b1t1(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL Qn_d1(nplank,nTrait)
      _RL Qn_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qn_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_NQUOTA */
#ifdef DARWIN_ALLOW_PQUOTA
      _RL Qp_0(nplank)
C     _RL Qp_bv1(nplank)
C     _RL Qp_to1(nplank)
C     _RL Qp_bv2(nplank)
C     _RL Qp_to2(nplank)
C     _RL Qp_b1t1(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL Qp_d1(nplank,nTrait)
      _RL Qp_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qp_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_PQUOTA */
#ifdef DARWIN_ALLOW_SIQUOTA
      _RL Qsi_0(nplank)
C     _RL Qsi_bv1(nplank)
C     _RL Qsi_to1(nplank)
C     _RL Qsi_bv2(nplank)
C     _RL Qsi_to2(nplank)
C     _RL Qsi_b1t1(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL Qsi_d1(nplank,nTrait)
      _RL Qsi_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qsi_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_SIQUOTA */
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL Qfe_0(nplank)
C     _RL Qfe_bv1(nplank)
C     _RL Qfe_to1(nplank)
C     _RL Qfe_bv2(nplank)
C     _RL Qfe_to2(nplank)
C     _RL Qfe_b1t1(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL Qfe_d1(nplank,nTrait)
      _RL Qfe_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL Qfe_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_FEQUOTA */
#ifdef DARWIN_ALLOW_CHLQUOTA
      _RL QChl_0(nplank)
C     _RL QChl_bv1(nplank)
C     _RL QChl_to1(nplank)
C     _RL QChl_bv2(nplank)
C     _RL QChl_to2(nplank)
C     _RL QChl_b1t1(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL QChl_d1(nplank,nTrait)
      _RL QChl_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL QChl_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_CHLQUOTA */

C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTr    :: accumulates computed tendencies
C     _RL gTr(nDarwin)

C !OUTPUT PARAMETERS: ==================================================
C  chlout :: computed acclimated chlorophyll if not dynamic
C Something will have to be done with chlout and diags (Le Gland, 10/03/2021)
C     _RL chlout(nPhoto)
      _RL chlout(nphyp)
      _RL diags(darwin_nDiag)
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
      _RL dPIC
      _RL dPOC
      _RL dPON
      _RL dPOP
      _RL dPOSi
      _RL dPOFe
#ifdef DARWIN_ALLOW_CARBON
      _RL dO2
      _RL dALK
#endif
#ifdef DARWIN_ALLOW_CDOM
      _RL dCDOM
#endif
#ifdef DARWIN_ALLOW_NQUOTA
      _RL ancom(nplank)
C     _RL an00(nplank)
C     _RL an10(nplank)
C     _RL an01(nplank)
C     _RL an20(nplank)
C     _RL an02(nplank)
C     _RL an11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL an_0(nplank)
      _RL an_d1(nplank,nTrait)
      _RL an_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL an_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_NQUOTA */
#ifdef DARWIN_ALLOW_PQUOTA
      _RL apcom(nplank)
C     _RL ap00(nplank)
C     _RL ap10(nplank)
C     _RL ap01(nplank)
C     _RL ap20(nplank)
C     _RL ap02(nplank)
C     _RL ap11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL ap_0(nplank)
      _RL ap_d1(nplank,nTrait)
      _RL ap_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL ap_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_PQUOTA */
#ifdef DARWIN_ALLOW_SIQUOTA
      _RL asicom(nplank)
C     _RL asi00(nplank)
C     _RL asi10(nplank)
C     _RL asi01(nplank)
C     _RL asi20(nplank)
C     _RL asi02(nplank)
C     _RL asi11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL asi_0(nplank)
      _RL asi_d1(nplank,nTrait)
      _RL asi_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL asi_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_SIQUOTA */
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL afecom(nplank)
C     _RL afe00(nplank)
C     _RL afe10(nplank)
C     _RL afe01(nplank)
C     _RL afe20(nplank)
C     _RL afe02(nplank)
C     _RL afe11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL afe_0(nplank)
      _RL afe_d1(nplank,nTrait)
      _RL afe_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL afe_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_TRAITS */
#endif /* DARWIN_ALLOW_FEQUOTA */
#ifdef DARWIN_ALLOW_CHLQUOTA
      _RL aChlcom(nplank)
C     _RL aChl00(nplank)
C     _RL aChl10(nplank)
C     _RL aChl01(nplank)
C     _RL aChl20(nplank)
C     _RL aChl02(nplank)
C     _RL aChl11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL aChl_0(nplank)
      _RL aChl_d1(nplank,nTrait)
      _RL aChl_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL aChl_d11(nplank,nCov)
#endif
#endif /* SPEAD_ALLOW_COV */
#endif /* DARWIN_ALLOW_CHLQUOTA */
C     _RL g00(nplank)
C     _RL g20(nplank)
C     _RL g02(nplank)
C     _RL g11(nplank)
      _RL gcom(nplank)
      _RL acom(nplank)
C     _RL a00(nplank)
C     _RL a10(nplank)
C     _RL a01(nplank)
C     _RL a20(nplank)
C     _RL a02(nplank)
C     _RL a11(nplank)
#ifdef SPEAD_ALLOW_TRAITS
      _RL a_0(nplank)
      _RL a_d1(nplank,nTrait)
      _RL a_d2(nplank,nTrait)
#ifdef SPEAD_ALLOW_COV
      _RL a_d11(nplank,nCov)
#endif
#endif
#ifdef DARWIN_GRAZING_SWITCH
      _RL coeff_KTW(nplank)
#endif
CEOP

#ifdef ALLOW_DARWIN

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
      _RL dbv
      _RL dto
C Step for optimum irradiance (Le Gland, 26/03/2021)
      _RL dpo
C Weight of each tracer (Le Gland, 15/03/2021)
      _RL wght_drv(nTrac)

C Continuous model: temperature dependance is managed within
C darwin_plankton (Le Gland, 14/01/2021)
      _RL photoTempFunc(nTrac)
      _RL reminTempFunc
      _RL uptakeTempFunc
      _RL grazTempFunc(nTrac)
      _RL mortTempFunc
      _RL mort2TempFunc

C Minimum value for optimal irradiance at a given cell volume
C (Le Gland, 15/04/2021)
      _RL PARoptmin

C Parameter of the steepness of the limitation by light
C following Edward et al 2015; Boris Sauterey 22/08/2023
      _RL alpha
C Intermediate variables related to unimodal growth rate (Le Gland, 10/06/2021)
      _RL biovol_norm
      _RL alpha1
      _RL alpha2

C Continuous model: deriv. from one tracer only (Le Gland, 11/03/2021)
      _RL a_1t(nTrac)
      _RL Qn(nTrac)
#ifdef DARWIN_ALLOW_NQUOTA
      _RL an_1t(nTrac)
#endif
      _RL Qp(nTrac)
#ifdef DARWIN_ALLOW_PQUOTA
      _RL ap_1t(nTrac)
#endif
      _RL Qsi(nTrac)
#ifdef DARWIN_ALLOW_SIQUOTA
      _RL asi_1t(nTrac)
#endif
      _RL Qfe(nTrac)
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL afe_1t(nTrac)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
      _RL QChl(nPhoto)
      _RL aChl_1t(nPhoto)
#endif

C Trait value for each tracer and each variable trait (Le Gland, 31/03/2021)
#ifdef SPEAD_ALLOW_TRAITS
      _RL vl_tr(nTrac,nTrait)
      _RL step_tr(nTrait)
#endif

      _RL regQ

      _RL limitpCO2
      _RL limitNH4
C Le Gland (26/05/2021)
      _RL limitNO
      _RL limitNO2
      _RL limitNO3
      _RL fracNH4
      _RL fracNO2
      _RL fracNO3
      _RL limitn
      _RL limitp
      _RL limitsi
      _RL limitfe
      _RL limitnut
      _RL limitI
      _RL ngrow

      _RL muPON
      _RL muPOC
      _RL muPOP
      _RL muPOFe
      _RL muDON
      _RL muDOC
      _RL muDOP
      _RL muDOFe
      _RL muO
      _RL mu

      _RL uptakeDIC
      _RL uptakeNH4
      _RL uptakeNO2
      _RL uptakeNO3
      _RL uptakeN
      _RL uptakePO4
      _RL uptakeSiO2
      _RL uptakeFeT
      _RL consumDIC
      _RL consumDIC_PIC
      _RL consumNH4
      _RL consumNO2
      _RL consumNO3
      _RL consumPO4
      _RL consumSiO2
      _RL consumFeT

      _RL uptakePON
      _RL uptakePOP
      _RL uptakePOC
      _RL uptakePOFe
      _RL uptakeDON
      _RL uptakeDOP
      _RL uptakeDOC
      _RL uptakeDOFe
      _RL uptakeO2

      _RL respPON
      _RL respPOP
      _RL respPOC
      _RL respPOFe
      _RL respPOSi
      _RL respDON
      _RL respDOP
      _RL respDOC
      _RL respDOFe

      _RL hydrolPON
      _RL hydrolPOP
      _RL hydrolPOC
      _RL hydrolPOFe
      _RL solubilPON
      _RL solubilPOP
      _RL solubilPOC
      _RL solubilPOFe

      _RL consumPON
      _RL consumPOP
      _RL consumPOC
      _RL consumPOFe
      _RL consumPOSi
      _RL consumDON
      _RL consumDOP
      _RL consumDOC
      _RL consumDOFe
      _RL consumO2

C Le Gland (26/05/2021)
      _RL ntot
      _RL inhibNH4

      _RL alpha_I
      _RL alpha_I_growth
      _RL PCm
      _RL PC
      _RL acclim
      _RL chl2c
      _RL growth
      _RL rhochl
      _RL Ek
      _RL EkoverE

      _RL synthChl

      _RL reminDOC
      _RL reminDON
      _RL reminDOP
      _RL reminDOFe
      _RL reminPOC
      _RL reminPON
      _RL reminPOP
      _RL reminPOSi
      _RL reminPOFe
      _RL disscPIC

      _RL prodNO2
      _RL prodNO3

      _RL PARtot

      _RL tmp

#ifdef DARWIN_ALLOW_CDOM
      _RL CDOM
      _RL reminPOC_CDOM
      _RL reminPON_CDOM
      _RL reminPOP_CDOM
      _RL reminPOFe_CDOM
      _RL degrCDOM_DOC
      _RL degrCDOM_DON
      _RL degrCDOM_DOP
      _RL degrCDOM_DOFe
#endif

#ifdef DARWIN_ALLOW_DENIT
      _RL denit, denitNH4
#endif

C for grazing

      _RL regQc, regQn, regQp, regQfe
      _RL sumprey, sumpref, grazphy

      _RL preygraz   (nTrac)
      _RL preygrazexp(nTrac)
      _RL predgrazc  (nTrac)
#ifdef DARWIN_ALLOW_NQUOTA
      _RL predgrazn  (nplank)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
      _RL predgrazp  (nplank)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL predgrazfe (nplank)
#endif

      _RL predexpc, predexpn, predexpp, predexpfe
      _RL graz2OC, graz2ON, graz2OP, graz2OFe
      _RL graz2POC, graz2PON, graz2POP, graz2POSi, graz2POFe
      _RL graz2PIC

      _RL expfrac

      _RL Xe
      _RL mortX
      _RL mortX2

      _RL exude_DOC
      _RL exude_DON
      _RL exude_DOP
      _RL exude_DOFe

      _RL exude_PIC
      _RL exude_POC
      _RL exude_PON
      _RL exude_POP
      _RL exude_POSi
      _RL exude_POFe

      _RL mort_c(nTrac)

      _RL respir
      _RL respir_c

#ifdef DARWIN_ALLOW_CDOM
      _RL graz2CDOM, exude_CDOM
#endif

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
#ifdef DARWIN_ALLOW_NQUOTA
        Qn(iplank(j)) = Qn_0(j)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        Qp(iplank(j)) = Qp_0(j)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        Qsi(iplank(j)) = Qsi_0(j)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        Qfe(iplank(j)) = Qfe_0(j)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
        QChl(iplank(j)) = QChl_0(j)
#endif

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

#ifdef SPEAD_ALLOW_TRAITS

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

#ifdef SPEAD_ALLOW_COV
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
#endif

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

#ifdef DARWINIAN_DEMON_SIZE          
            IF (a_ksatNO3(g)/(NO3+NO2+NH4) .EQ. 
     &      MAX(a_ksatNO3(g)/(NO3+NO2+NH4),
     &      a_ksatPO4(g)/PO4,a_ksatFeT(g)/FeT)) THEN
              IF((NO3+NO2+NH4) .GT. 0 _d 0) THEN
              biovol(jp) = ((NO3+NO2+NH4)*b_PCmax(g)/(a_ksatNO3(g)*
     &        (b_ksatNO3(g)-b_PCmax(g))))**(1/b_ksatNO3(g))
              ENDIF
            ELSEIF (a_ksatPO4(g)/PO4 .EQ. 
     &      MAX(a_ksatNO3(g)/(NO3+NO2+NH4),
     &      a_ksatPO4(g)/PO4,a_ksatFeT(g)/FeT)) THEN
              IF(PO4 .GT. 0 _d 0) THEN
              biovol(jp) = ((PO4)*b_PCmax(g)/(a_ksatPO4(g)*
     &        (b_ksatPO4(g)-b_PCmax(g))))**(1/b_ksatPO4(g))
              ENDIF
            ELSE
              IF(FeT .GT. 0 _d 0) THEN
              biovol(jp) = ((FeT)*b_PCmax(g)/(a_ksatFeT(g)*
     &        (b_ksatFeT(g)-b_PCmax(g))))**(1/b_ksatFeT(g))
              ENDIF
            ENDIF
#endif

C           print*, 'biovol of ', jp, 'after DD =', biovol(jp)

C biovolmin is the absolute minimum for cell size
C PARoptmin is the minimum possible value of Iopt for a given cell volume
C (Le Gland, 15/04/2021)
C In an attempt to avoid bugs with some advection/diffusion schemes, I
C now impose that PCmax must be positve (Le Gland, 01/06/2021)
            PARoptmin = a_PARoptmin(g) * biovol(jp)**b_PARoptmin(g)
            
#ifdef DARWINIAN_DEMON_LIGHT
            PARopt(jp) = PARoptmin + SQRT(PARoptmin**2 + 
     &      (3.2-2)*PARtot*PARoptmin + PARtot)
#endif 

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
#ifdef DARWIN_DEBUG
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
#endif
        END DO

#ifdef DARWIN_ALLOW_NQUOTA
          Qn(iplank(j)+1) = Qn_0(j) - dbv*Qn_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qn_bv2(j)
          Qn(iplank(j)+2) = Qn_0(j) + dbv*Qn_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qn_bv2(j)
          Qn(iplank(j)+3) = Qn_0(j) - dto*Qn_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qn_to2(j)
          Qn(iplank(j)+4) = Qn_0(j) + dto*Qn_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qn_to2(j)
          Qn(iplank(j)+5) = Qn_0(j) + dbv*Qn_bv1(j) + dto*Qn_to1(j)
     &    + (1.0/2.0)*(dbv**2)*Qn_bv2(j) + (1.0/2.0)*(dto**2)*Qn_to2(j)
     &    + dbv*dto*Qn_b1t1(j)
#endif

#ifdef DARWIN_ALLOW_PQUOTA
          Qp(iplank(j)+1) = Qp_0(j) - dbv*Qp_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qp_bv2(j)
          Qp(iplank(j)+2) = Qp_0(j) + dbv*Qp_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qp_bv2(j)
          Qp(iplank(j)+3) = Qp_0(j) - dto*Qp_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qp_to2(j)
          Qp(iplank(j)+4) = Qp_0(j) + dto*Qp_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qn_to2(j)
          Qp(iplank(j)+5) = Qp_0(j) + dbv*Qp_bv1(j) + dto*Qp_to1(j)
     &    + (1.0/2.0)*(dbv**2)*Qp_bv2(j) + (1.0/2.0)*(dto**2)*Qp_to2(j)
     &    + dbv*dto*Qp_b1t1(j)
#endif

#ifdef DARWIN_ALLOW_SIQUOTA
          Qsi(iplank(j)+1) = Qsi_0(j) - dbv*Qsi_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qsi_bv2(j)
          Qsi(iplank(j)+2) = Qsi_0(j) + dbv*Qsi_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qsi_bv2(j)
          Qsi(iplank(j)+3) = Qsi_0(j) - dto*Qsi_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qsi_to2(j)
          Qsi(iplank(j)+4) = Qsi_0(j) + dto*Qsi_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qsi_to2(j)
          Qsi(iplank(j)+5) = Qsi_0(j) + dbv*Qsi_bv1(j) + dto*Qsi_to1(j)
     &        + (1.0/2.0)*(dbv**2)*Qsi_bv2(j)
     &        + (1.0/2.0)*(dto**2)*Qsi_to2(j)
     &        + dbv*dto*Qsi_b1t1(j)
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
          Qfe(iplank(j)+1) = Qfe_0(j) - dbv*Qfe_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qfe_bv2(j)
          Qfe(iplank(j)+2) = Qfe_0(j) + dbv*Qfe_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*Qfe_bv2(j)
          Qfe(iplank(j)+3) = Qfe_0(j) - dto*Qfe_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qfe_to2(j)
          Qfe(iplank(j)+4) = Qfe_0(j) + dto*Qfe_to1(j)
     &                      + (1.0/2.0)*(dto**2)*Qfe_to2(j)
          Qfe(iplank(j)+5) = Qfe_0(j) + dbv*Qfe_bv1(j) + dto*Qfe_to1(j)
     &        + (1.0/2.0)*(dbv**2)*Qfe_bv2(j)
     &        + (1.0/2.0)*(dto**2)*Qfe_to2(j)
     &        + dbv*dto*Qfe_b1t1(j)
#endif

#ifdef DARWIN_ALLOW_CHLQUOTA
          QChl(iplank(j)+1) = QChl_0(j) - dbv*QChl_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*QChl_bv2(j)
          QChl(iplank(j)+2) = QChl_0(j) + dbv*QChl_bv1(j)
     &                      + (1.0/2.0)*(dbv**2)*QChl_bv2(j)
          QChl(iplank(j)+3) = QChl_0(j) - dto*QChl_to1(j)
     &                      + (1.0/2.0)*(dto**2)*QChl_to2(j)
          QChl(iplank(j)+4) = QChl_0(j) + dto*QChl_to1(j)
     &                      + (1.0/2.0)*(dto**2)*QChl_to2(j)
          QChl(iplank(j)+5) = QChl_0(j)
     &        + dbv*QChl_bv1(j) + dto*QChl_to1(j)
     &        + (1.0/2.0)*(dbv**2)*QChl_bv2(j)
     &        + (1.0/2.0)*(dto**2)*QChl_to2(j)
     &        + dbv*dto*QChl_b1t1(j)
#endif

#endif /* DARWIN_ALLOW_TRAITS */

C       END IF

      END DO

#ifdef DARWIN_DEBUG
C     IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C       print*,'Weight_derivatives', wght_drv, SUM(wght_drv(1:10)),
C    &         SUM(wght_drv(11:20))
C     ENDIF
#endif

C Assign quotas when they are constant (Le Gland, 15/03/2021)
      DO j = 1, nTrac
#ifndef DARWIN_ALLOW_NQUOTA
        Qn(j) = R_NC(j)
#endif
#ifndef DARWIN_ALLOW_PQUOTA
        Qp(j) = R_PC(j)
#endif
#ifndef DARWIN_ALLOW_NQUOTA
        Qsi(j) = R_SiC(j)
#endif
#ifndef DARWIN_ALLOW_NQUOTA
        Qfe(j) = R_FeC(j)
#endif
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
#ifdef SINGLE_DISK_IO
C     CLOSE(iUnit)
#else
C     CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

C     WRITE(msgBuf,'(A)') ' ==================================='
C     CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C    &                    SQUEEZE_RIGHT, myThid )

C ======================================================================
C deprecation checks

#ifndef DARWIN_ALLOW_EXUDE
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
#endif

C ======================================================================
C write some traits to files

#ifdef ALLOW_RADTRANS

C     IF ( myProcId.EQ.0 ) THEN


C set spectra for individual plankton according to optical type
C file for aptypes assigned via coin flips
C     CALL MDSFINDUNIT( oUnit1, myThid )
C     OPEN(oUnit1,file='p-ini-char-aptype.dat',status='unknown')
C     CALL MDSFINDUNIT( oUnit2, myThid )
C     OPEN(oUnit2,file='p_ini_char_aptype_nohead.dat',status='unknown')
C     WRITE(oUnit1,*)'np   aptype'
C     DO jp = 1,nPhoto
C       WRITE(oUnit1,'(2I5)') jp, aptype(jp)
C       WRITE(oUnit2,'(2I5)') jp, aptype(jp)
C     ENDDO
C     CLOSE(oUnit1)
C     CLOSE(oUnit2)

c file of total absorption spectra
c rows = pwaves, columns = jp
C     open(oUnit1,file='p-ini-char-apspec.dat',status='unknown')
C     open(oUnit2,file='p_ini_char_aspec_nohead.dat',status='unknown')
C     write(oUnit1,*)'Rows = pwaves. Columns = jp'
C     write(oUnit1,*)'pwaves found in pwaves-check.dat'
C     write(oUnit1,*)'col_1 to col_<nPhoto>'
C     write(oUnit1,*)'is absorption aphy_chl (m-2 mg chla-1)'
C     do l=1,nlam
C      write(oUnit1,9999)(aphy_chl(jp,l),jp=1,nPhoto)
C      write(oUnit2,9999)(aphy_chl(jp,l),jp=1,nPhoto)
C     enddo
c make sure outfile is defined above with the correct size
C     close(oUnit1)
C     close(oUnit2)

c file for absorption spectra of PS's only
c rows = pwaves, columns = jp
C     open(oUnit1,file='p-ini-char-apspec-psc.dat',status='unknown')
C     open(oUnit2,file='p_ini_char_aspec_psc_nohead.dat',
C    &     status='unknown')
C     write(oUnit1,*)'Rows = pwaves. Columns = jp'
C     write(oUnit1,*)'pwaves found in pwaves-check.dat'
C     write(oUnit1,*)'Is absoprtion by photosynthetic'
C     write(oUnit1,*)'pigments only aphy_chl_ps (m-2 mg chla-1)'
C     do l=1,nlam
C      write(oUnit1,9999)(aphy_chl_ps(jp,l),jp=1,nPhoto)
C      write(oUnit2,9999)(aphy_chl_ps(jp,l),jp=1,nPhoto)
C     enddo
C     close(oUnit1)
C     close(oUnit2)

c file of total scattering spectra
c rows = pwaves, columns = jp
C     open(oUnit1,file='p-ini-char-btspec.dat',status='unknown')
C     open(oUnit2,file='p_ini_char_btspec_nohead.dat',status='unknown')
C     write(oUnit1,*)'Rows = pwaves. Columns = jp'
C     write(oUnit1,*)'pwaves found in pwaves-check.dat'
C     write(oUnit1,*)'col_1 to col_<nPlank>'
C     write(oUnit1,*)'is total scattering bphy_mgC (m-2 mg C-1)'
C     do l=1,nlam
C      write(oUnit1,9999)(bphy_mgC(jp,l),jp=1,nplank)
C      write(oUnit2,9999)(bphy_mgC(jp,l),jp=1,nplank)
C     enddo
c make sure outfile is defined above with the correct size
C     close(oUnit1)
C     close(oUnit2)

c file of total scattering spectra
c rows = pwaves, columns = jp
C     open(oUnit1,file='p-ini-char-bbspec.dat',status='unknown')
C     open(oUnit2,file='p_ini_char_bbspec_nohead.dat',status='unknown')
C     write(oUnit1,*)'Rows = pwaves. Columns = jp'
C     write(oUnit1,*)'pwaves found in pwaves-check.dat'
C     write(oUnit1,*)'col_1 to col_<nPlank>'
C     write(oUnit1,*)'is backscattering bphy_mgC*1e4 (m-2 mg C-1)'
C     do l=1,nlam
C      write(oUnit1,9999)(bbphy_mgC(jp,l)*1e4,jp=1,nplank)
C      write(oUnit2,9999)(bbphy_mgC(jp,l)*1e4,jp=1,nplank)
C     enddo
c make sure outfile is defined above with the correct size
C     close(oUnit1)
C     close(oUnit2)

C9999  format(9999f10.4)

CC    IF ( myProcId.EQ.0 ) THEN
C     ENDIF

#endif /* ALLOW_RADTRANS */


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
#ifdef DARWIN_ALLOW_CARBON
      dO2 = 0.0
      dALK = 0.0
#endif
#ifdef DARWIN_ALLOW_CDOM
      dCDOM = 0.0
#endif

      DO j = 1, nTrac
        a_1t(j) = 0.0 _d 0
#ifdef DARWIN_ALLOW_NQUOTA
        an_1t(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        ap_1t(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        asi_1t(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        afe_1t(j) = 0.0 _d 0
#endif
      ENDDO

#ifdef DARWIN_ALLOW_CHLQUOTA
      DO j = 1, nPhoto
        aChl_1t(j) = 0.0 _d 0
      ENDDO
#endif

      DO j = 1, nplank
        gcom(j) = 0.0 _d 0
        acom(j) = 0.0 _d 0
#ifdef DARWIN_ALLOW_NQUOTA
        ancom(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        apcom(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        asicom(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        afecom(j) = 0.0 _d 0
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
        aChlcom(j) = 0.0 _d 0
#endif
#ifdef DARWIN_GRAZING_SWITCH
        coeff_KTW(j) = 0 _d 0
#endif
      ENDDO

C     DO j = 1, nPhoto
      DO j = 1, nphyp
        chlout(j) = 0.0 _d 0
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
        IF (ksatPO4(j) .GT. 0 _d 0) THEN
          limitp = PO4/(PO4 + ksatPO4(j))
        ELSE
          limitp = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_PQUOTA
        regQ = MAX(0., MIN(1., (Qpmax(j)-Qp(j))/
     &                         (Qpmax(j)-Qpmin(j)) ))
        regQ = regQ**hillnumUptake
        uptakePO4 = vmaxPO4(j) * limitp * regQ *
     &                       uptakeTempFunc * X(plank(j))
C    &                       uptakeTempFunc * X(j)
c       normalized Droop limitation
        limitp = MIN(1., (1.0-Qpmin(j)/MAX(Qpmin(j), Qp(j)))/
     &                   (1.0-Qpmin(j)/Qpmax(j)))
#endif

c silica
        IF (ksatSiO2(j) .GT. 0 _d 0) THEN
          limitsi = SiO2/(SiO2 + ksatSiO2(j))
        ELSE
          limitsi = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_SIQUOTA
        regQ = MAX(0., MIN(1., (Qsimax(j) - Qsi(j))/
     &                         (Qsimax(j) - Qsimin(j)) ))
        regQ = regQ**hillnumUptake
        uptakeSiO2 = vmaxSiO2(j) * limitsi * regQ *
     &                                 uptakeTempFunc * X(plank(j))
C    &                                 uptakeTempFunc * X(j)

c       linear limitation
        limitsi = MAX(0., MIN(1., (Qsi(j) - Qsimin(j))/
     &                         (Qsimax(j) - Qsimin(j)) ))
#endif

c iron
        IF (ksatFeT(j) .GT. 0 _d 0) THEN
          limitfe = FeT/(FeT + ksatFeT(j))
        ELSE
          limitfe = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_FEQUOTA
        regQ = MAX(0., MIN(1., (Qfemax(j)-Qfe(j))/
     &                         (Qfemax(j)-Qfemin(j)) ))
        regQ = regQ**hillnumUptake
        uptakeFeT = vmaxFeT(j) * limitfe * regQ *
     &                       uptakeTempFunc * X(plank(j))
C    &                       uptakeTempFunc * X(j)

c       normalized Droop limitation
        limitfe = MIN(1., (1.0-Qfemin(j)/MAX(Qfemin(j), Qfe(j)))/
     &                    (1.0-Qfemin(j)/Qfemax(j)))
#endif

c nitrogen
#ifdef DARWIN_ALLOW_NQUOTA
c       have nitrogen quota
        inhibNH4 = EXP(-amminhib(j)*NH4)
        limitNH4 = NH4/(NH4 + ksatNH4(j))
C inhibNH4 parameterization of Vallina et al. 2008 (Le Gland, 25/03/2021)
C       inhibNH4 = 1 - limitNH4
        limitNO2 = NO2/(NO2 + ksatNO2(j))*inhibNH4
        limitNO3 = NO3/(NO3 + ksatNO3(j))*inhibNH4
        regQ = MAX(0., MIN(1., (Qnmax(j)-Qn(j))/
     &                         (Qnmax(j)-Qnmin(j)) ))
        regQ = regQ**hillnumUptake
C       uptakeNH4 = vmaxNH4(j)*limitNH4*regQ*uptakeTempFunc*X(j)
C       uptakeNO2 = vmaxNO2(j)*limitNO2*regQ*uptakeTempFunc*X(j)
C       uptakeNO3 = vmaxNO3(j)*limitNO3*regQ*uptakeTempFunc*X(j)
        uptakeNH4 = vmaxNH4(j)*limitNH4*regQ*uptakeTempFunc*X(plank(j))
        uptakeNO2 = vmaxNO2(j)*limitNO2*regQ*uptakeTempFunc*X(plank(j))
        uptakeNO3 = vmaxNO3(j)*limitNO3*regQ*uptakeTempFunc*X(plank(j))
#ifdef DARWIN_ALLOW_FEQUOTA
#ifdef DARWIN_NITRATE_FELIMIT
        uptakeNO3 = uptakeNO3 * limitfe
#endif
#endif
        uptakeN = MAX(uptakeNH4 + uptakeNO2 + uptakeNO3,
     &                vmaxN(j)*regQ*uptakeTempFunc*X(plank(j))*diazo(j))
C    &                vmaxN(j)*regQ*uptakeTempFunc*X(j)*diazo(j))

c       linear limitation
        limitn = MAX(0., MIN(1., (Qn(j) - Qnmin(j))/
     &                        (Qnmax(j) - Qnmin(j)) ))
#else /* not DARWIN_ALLOW_NQUOTA */
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
        IF (NO2 .GT. 0 _d 0) THEN
          limitNO2 = limitNO * useNO2(j)*NO2
     &             / (NO2 + useNO3(j)*NO3*ksatNO2(j)/ksatNO3(j))
        ELSE
          limitNO2 = 0 _d 0
        ENDIF
        limitNO3 = limitNO - limitNO2
C       normalize to sum 1
        IF (limitn .GT. 0 _d 0) THEN
          fracNH4 = limitNH4/limitn
          fracNO2 = limitNO2/limitn
          fracNO3 = limitNO3/limitn
        ELSE
          fracNH4 = 0 _d 0
          fracNO2 = 0 _d 0
          fracNO3 = 0 _d 0
        ENDIF
C if diazo, all fracN* == 0 but want no N limitation
        limitn = MIN(1.0, limitn + diazo(j))
#endif /* DARWIN_ALLOW_NQUOTA */
c        IF (limitn .GT. 0.0) THEN
c          ngrow = ((10*4+2)/(10*4 + 2*limitNH4/limitn +
c     &                       8*limitNO2/limitn + 10*limitNO3/limitn))
c        ELSE
        ngrow = 1.0
c        ENDIF

        limitnut = MIN(limitn, limitp, limitsi)
#ifndef DARWIN_ALLOW_FEQUOTA
        limitnut = MIN(limitnut, limitfe)
#endif

        limitpCO2 = 1.

C==== growth ===========================================================
#ifdef DARWIN_ALLOW_GEIDER

        alpha_I = 0 _d 0
        DO l = 1, nlam
          alpha_I = alpha_I + alphachl(j,l)*PAR(l)
        ENDDO
C       NB: for quota, PCmax(j) = Vmax_c(j)
        PCm = PCmax(j)*limitnut*photoTempFunc(j)*limitpCO2

        IF (PCm .GT. 0.0) THEN
          acclim = MAX(chl2cmin(j), MIN(chl2cmax(j),
     &             chl2cmax(j)/(1+(chl2cmax(j)*alpha_I)/(2*PCm)) ))
        ELSE
          acclim = chl2cmin(j)
        ENDIF

#ifdef DARWIN_ALLOW_CHLQUOTA
C       quotas are already relative to carbon
        chl2c = QChl(j)
#else
        chl2c = acclim
#endif

        alpha_I_growth = alpha_I
C a la quota
#ifdef DARWIN_ALLOW_FEQUOTA
        alpha_I_growth = alpha_I_growth*limitfe
#endif

C       carbon-specific growth rate
C       PC = PCm*(1-EXP(-alpha_I_growth*chl2c/MAX(EPS, PCm)))
        IF (PCm .GT. 0.0 .AND. PARtot .GT. PARmin) THEN
          PC = PCm*(1-EXP(-alpha_I_growth*chl2c/PCm))
        ELSE
          PC = 0.0 _d 0
        ENDIF

        IF (inhibGeider(j) .GT. 0.0) THEN
C         "total" PAR:
          tmp = alpha_I/alpha_mean(j)
          Ek = PCm/(chl2c*alpha_mean(j))
          EkoverE = Ek / tmp
          IF (tmp .GE. Ek) THEN
            PC = PC*EkoverE*inhibGeider(j)
          ENDIF
        ENDIF

#else /* not DARWIN_ALLOW_GEIDER */

        IF (PARtot .GT. PARmin) THEN
C         only 1 waveband without DARWIN_ALLOW_GEIDER
C         limitI = (1.0 _d 0 - EXP(-PARtot*ksatPAR(j)))*
C     &             EXP(-PARtot*kinhPAR(j)) * normI(j)
          ! Light limitation from Edward et al. 2015; Boris Sauterey 22/08/2023
          ! Carefull /!\ in the model unit of irradiance contrary to Guillaume
          alpha  = 3.2/PARopt(j) !Boris Saterey (2023-11-13)
          limitI = PARtot/(PARtot**2/(alpha*PARopt(j)**2)+(1-2/
     &             (alpha*PARopt(j)))*PARtot+1/alpha)
          PC = PCmax(j)*limitnut*limitI*photoTempFunc(j)*limitpCO2
        ELSE
          PC = 0.0 _d 0
        ENDIF
        synthChl = 0.0

#endif /* DARWIN_ALLOW_GEIDER */

C       growth(j) = PC*ngrow*X(j)
        growth = PC*ngrow*X(plank(j))

        uptakeDIC = growth

C non-quota elements are taken up with fixed stoichiometry
#ifndef DARWIN_ALLOW_NQUOTA
        uptakeN = growth*R_NC(j)
        uptakeNH4 = uptakeN*fracNH4
        uptakeNO2 = uptakeN*fracNO2
        uptakeNO3 = uptakeN*fracNO3
#endif
#ifndef DARWIN_ALLOW_PQUOTA
        uptakePO4 = growth*R_PC(j)
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
        uptakeSiO2 = growth*R_SiC(j)
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
        uptakeFeT = growth*R_FeC(j)
#endif

C==== chlorophyll ======================================================
#ifdef DARWIN_ALLOW_GEIDER
# ifdef DARWIN_ALLOW_CHLQUOTA
#  ifdef DARWIN_ALLOW_NQUOTA
C       Geider 1998
        IF (PARtot .GT. PARmin) THEN
         IF (alpha_I*chl2c .GT. 0.0 _d 0) THEN
C          rhochl = Chl2Nmax/(alpha_I*chl2c)*ngrow ???
          rhochl = Chl2Nmax*PC*ngrow/(alpha_I*chl2c)
         ELSE
          rhochl = Chl2Nmax
         ENDIF
         synthChl = rhochl*uptakeN
        ELSE
         synthChl = 0 _d 0
        ENDIF
CTODO: this seems wrong!  Should only happen when PARtot.GT.PARmin
        uptakeDIC = uptakeDIC - synthcost*uptakeN
#  else /* not DARWIN_ALLOW_NQUOTA */
#   ifdef DARWIN_GEIDER_RHO_SYNTH
        IF (alpha_I .GT. 0.0 _d 0 .AND. acclim .GT. 0.0 _d 0) THEN
          rhochl = Chl2Cmax(j)*PC*ngrow/(alpha_I*acclim)
        ELSE
          rhochl = 0.0 _d 0    ! should be Chl2Cmax(j) ?????
        ENDIF
        synthChl = rhochl*growth +
     &                      acclimtimescl(j)*(acclim-chl2c)*X(plank(j))
C    &                      acclimtimescl(j)*(acclim-chl2c)*X(j)
#   else
        synthChl = acclim*growth +
     &                      acclimtimescl(j)*(acclim-chl2c)*X(plank(j))
C    &                      acclimtimescl(j)*(acclim-chl2c)*X(j)
#   endif
#  endif /* not DARWIN_ALLOW_NQUOTA */
# else /* not DARWIN_ALLOW_CHLQUOTA */
C       chlout(j) = X(j)*Qc(j)*chl2c
C Could be done out of the loop if chl2c is a constant (Le Gland, 22/03/2021)
        chlout(plank(j)) = chlout(plank(j))
     &                   + X(plank(j))*chl2c*wght_drv(j)
        synthChl = 0.0
# endif /* DARWIN_ALLOW_CHLQUOTA */
#endif /* DARWIN_ALLOW_GEIDER */
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
#ifdef DARWIN_DIAG_PERTYPE
C       diags(iPPplank+j-1) = diags(iPPplank+j-1) + growth
        diags(iPPplank+plank(j)-1) = diags(iPPplank+plank(j)-1)
     &                             + growth*wght_drv(j)
#endif
        IF (diazo(j) .GT. 0.0 _d 0) THEN
C        diags(iNfix)=diags(iNfix)+uptakeN-uptakeNH4-uptakeNO2-uptakeNO3
         diags(iNfix)=diags(iNfix)
     &   +(uptakeN-uptakeNH4-uptakeNO2-uptakeNO3)*wght_drv(j)
        ENDIF

C=======================================================================

C       gTr(ic+j-1)=gTr(ic+j-1)  + uptakeDIC
        a_1t(j) = a_1t(j) + uptakeDIC
        acom(plank(j)) = acom(plank(j)) + uptakeDIC*wght_drv(j)
        gcom(plank(j)) = gcom(plank(j)) + uptakeDIC*wght_drv(j)

#ifdef DARWIN_DEBUG
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
#endif




#ifdef DARWIN_ALLOW_NQUOTA
C       gTr(in+j-1)=gTr(in+j-1)  + uptakeN
        an_1t(j) = an_1t(j) + uptakeN
        ancom(plank(j)) = ancom(plank(j)) + uptakeN*wght_drv(j)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C       gTr(ip+j-1)=gTr(ip+j-1)  + uptakePO4
        ap_1t(j) = ap_1t(j) + uptakePO4
        apcom(plank(j)) = apcom(plank(j)) + uptakePO4*wght_drv(j)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
C       gTr(isi+j-1)=gTr(isi+j-1) + uptakeSiO2
        asi_1t(j) = asi_1t(j) + uptakeSiO2
        asicom(plank(j)) = asicom(plank(j)) + uptakeSiO2*wght_drv(j)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C       gTr(ife+j-1)=gTr(ife+j-1) + uptakeFeT
        afe_1t(j) = afe_1t(j) + uptakeFeT
        afecom(plank(j)) = afecom(plank(j)) + uptakeFeT*wght_drv(j)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
C       gTr(iChl+j-1)=gTr(iChl+j-1) + synthChl
        aChl_1t(j) = aChl_1t(j) + synthChl
        aChlcom(plank(j)) = aChlcom(plank(j)) + synthChl*wght_drv(j)
#endif

#ifdef DARWIN_DEBUG
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
#endif

#endif
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
        IF (gcom(j) /= gcom(j) .OR. gcom(j) .LT. -1.0 _d -6
     & .OR. dDIC /= dDIC) THEN
#ifdef DARWIN_DEBUG
CC        IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C           print*,'SPEAD is buggy (NaN): all derivatives are set to',
C    &             ' zero to prevent failure', 'coordinates', iG, jG, k,
C    &             ' gcom: ', gcom(j)
CC        ENDIF
#endif
          chlout = 0 _d 0
          diags = 0 _d 0
          dDIC  = 0 _d 0
          dNH4  = 0 _d 0
          dNO2  = 0 _d 0
          dNO3  = 0 _d 0
          dPO4  = 0 _d 0
          dSiO2 = 0 _d 0
          dFeT  = 0 _d 0
          dDOC  = 0 _d 0
          dDON  = 0 _d 0
          dDOP  = 0 _d 0
          dDOFe = 0 _d 0
          dPIC  = 0 _d 0
          dPOC  = 0 _d 0
          dPON  = 0 _d 0
          dPOP  = 0 _d 0
          dPOSi = 0 _d 0
          dPOFe = 0 _d 0
#ifdef DARWIN_ALLOW_CARBON
          dO2 = 0 _d 0
          dALK = 0 _d 0
#endif
#ifdef DARWIN_ALLOW_CDOM
          dCDOM = 0 _d 0
#endif
          gcom = 0 _d 0
          a_0  = 0 _d 0
          a_d1 = 0 _d 0
          a_d2 = 0 _d 0
#ifdef SPEAD_ALLOW_COV
          a_d11 = 0 _d 0
#endif
          acom = 0 _d 0
        ENDIF
      ENDDO
C=======================================================================
C==== bacteria =========================================================

      DO j = 1, nplank
       IF (bactType(j) .NE. 0) THEN

        uptakeO2  = 0. _d 0
        uptakeNO3 = 0. _d 0
        uptakePOC = 0. _d 0
        uptakePON = 0. _d 0
        uptakePOP = 0. _d 0
        uptakePOFe = 0. _d 0
        uptakeDOC = 0. _d 0
        uptakeDON = 0. _d 0
        uptakeDOP = 0. _d 0
        uptakeDOFe = 0. _d 0
        hydrolPOC = 0. _d 0
        hydrolPON = 0. _d 0
        hydrolPOP = 0. _d 0
        hydrolPOFe = 0. _d 0
        respPOC = 0. _d 0
        respPON = 0. _d 0
        respPOP = 0. _d 0
        respPOFe = 0. _d 0
        respDOC = 0. _d 0
        respDON = 0. _d 0
        respDOP = 0. _d 0
        respDOFe = 0. _d 0
C       growth(j) = 0. _d 0
        growth = 0. _d 0

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

#ifdef DARWIN_DIAG_PERTYPE
C       diags(iPPplank+j-1) = diags(iPPplank+j-1) + growth(j)
        diags(iPPplank+plank(j)-1) = diags(iPPplank+plank(j)-1)
     &                             + growth*wght_drv(j)
#endif

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

#ifdef DARWIN_ALLOW_CARBON
      consumO2  = consumO2  + respDOP*R_OP
#ifndef DARWIN_ALLOW_CDOM
      consumO2  = consumO2  + respPOP*R_OP
#endif
#endif

      disscPIC = Kdissc*PIC

c nitrogen chemistry
c NH4 -> NO2 -> NO3 by bacterial action, parameterized
c Should this depend on temperature ? (Le Gland, 03/06/2021)
      prodNO2 = knita*NH4
      prodNO3 = knitb*NO2
      IF (PAR_oxi .NE. 0.0 _d 0) THEN
        prodNO2 = prodNO2*MAX(0.0, 1.0 - PARtot/PAR_oxi)
        prodNO3 = prodNO3*MAX(0.0, 1.0 - PARtot/PAR_oxi)
      ENDIF

#ifdef DARWIN_ALLOW_CDOM
      reminPOP_CDOM = fracCDOM*reminPOP
      reminPOC_CDOM = R_CP_CDOM*reminPOP_CDOM
      reminPON_CDOM = R_NP_CDOM*reminPOP_CDOM
      reminPOFe_CDOM = R_FeP_CDOM*reminPOP_CDOM
c degradation of  CDOM - high when bleached by light
      degrCDOM_DOP = reminTempFunc*CDOM*
     &     (CDOMdegrd+CDOMbleach*MIN(1.0 _d 0, PARtot/PARCDOM))
      degrCDOM_DOC  = R_CP_CDOM  * degrCDOM_DOP
      degrCDOM_DON  = R_NP_CDOM  * degrCDOM_DOP
      degrCDOM_DOFe = R_FeP_CDOM * degrCDOM_DOP
#endif

#ifdef DARWIN_ALLOW_DENIT
      IF (O2 .LT. O2crit .AND. NO3 .LT. NO3crit) THEN
        consumDOC = 0. _d 0
        consumDOP  = 0. _d 0
        consumDON  = 0. _d 0
        consumDOFe = 0. _d 0
        consumPOC = 0. _d 0
        consumPOP  = 0. _d 0
        consumPON  = 0. _d 0
        consumPOFe = 0. _d 0
        reminDOC = 0. _d 0
        reminDOP  = 0. _d 0
        reminDON  = 0. _d 0
        reminDOFe = 0. _d 0
        reminPOC = 0. _d 0
        reminPOP  = 0. _d 0
        reminPON  = 0. _d 0
        reminPOFe = 0. _d 0
#ifdef DARWIN_ALLOW_CDOM
        reminPOC_cdom = 0. _d 0
        reminPOP_cdom  = 0. _d 0
        reminPON_cdom  = 0. _d 0
        reminPOFe_cdom = 0. _d 0
        degrCDOM_DOP = reminTempFunc*CDOM*
     &                 CDOMbleach*MIN(1.0 _d 0, PARtot/PARCDOM)
        degrCDOM_DON  = R_NP_CDOM  * degrCDOM_DOP
        degrCDOM_DOFe = R_FeP_CDOM * degrCDOM_DOP
        degrCDOM_DOC  = R_CP_CDOM  * degrCDOM_DOP
#endif
      ENDIF
#endif /* DARWIN_ALLOW_DENIT */

C==== apply tendencies =================================================

#ifdef DARWIN_ALLOW_CARBON
c production of O2 by photosynthesis
C     gTr(iO2  )=gTr(iO2  ) + R_OP*consumPO4
      dO2 = dO2 + R_OP*consumPO4
c loss of O2 by remineralization
      IF (O2 .GT. O2crit) THEN
C       gTr(iO2)=gTr(iO2) - consumO2
        dO2 = dO2 - consumO2
      ENDIF

C     gTr(iALK)=gTr(iALK) - (prodNO3 - consumNO3)
C    &                    - 2.0 _d 0*(consumDIC_PIC - disscPIC)
      dALK = dALK - (prodNO3 - consumNO3)
     &                    - 2.0 _d 0*(consumDIC_PIC - disscPIC)
#endif /* DARWIN_ALLOW_CARBON */

C     gTr(iDIC )=gTr(iDIC ) + reminDOC + disscPIC
C     gTr(iNH4 )=gTr(iNH4 ) + reminDON - prodNO2
C     gTr(iNO2 )=gTr(iNO2 ) + prodNO2 - prodNO3
C     gTr(iNO3 )=gTr(iNO3 ) + prodNO3
      dDIC = dDIC + reminDOC + disscPIC
      dNH4 = dNH4 + reminDON - prodNO2
      dNO2 = dNO2 + prodNO2 - prodNO3
      dNO3 = dNO3 + prodNO3
      diags(iDenitN) = 0.0
#ifdef DARWIN_ALLOW_DENIT
      IF (O2 .LT. O2crit) THEN
        denitNH4 = reminDON
        denit = denit_NP*reminDOP
#ifndef DARWIN_ALLOW_CDOM
        denitNH4 = denitNH4 + reminPON
        denit = denit + denit_NP*reminPOP
#endif
        diags(iDenit) = denit
C       gTr(iNH4)=gTr(iNH4) - denitNH4
C       gTr(iNO3)=gTr(iNO3) - denit_NO3/denit_np*denit
C       gTr(iALK)=gTr(iALK) + denit_NO3/denit_np*denit
        dNH4 = dNH4 - denitNH4
        dNO3 = dNO3 - denit_NO3/denit_np*denit
        dALK = dALK + denit_NO3/denit_np*denit
        diags(iDenitN) = denitNH4 + denit_NO3/denit_np*denit
      ENDIF
#endif /* DARWIN_ALLOW_DENIT */

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

#ifdef DARWIN_ALLOW_CDOM
C     gTr(iDOC )=gTr(iDOC ) + reminPOC  - reminPOC_CDOM  + degrCDOM_DOC
C     gTr(iDON )=gTr(iDON ) + reminPON  - reminPON_CDOM  + degrCDOM_DON
C     gTr(iDOP )=gTr(iDOP ) + reminPOP  - reminPOP_CDOM  + degrCDOM_DOP
C     gTr(iDOFe)=gTr(iDOFe) + reminPOFe - reminPOFe_CDOM + degrCDOM_DOFe
      dDOC  = dDOC  + reminPOC  - reminPOC_CDOM  + degrCDOM_DOC
      dDON  = dDON  + reminPON  - reminPON_CDOM  + degrCDOM_DON
      dDOP  = dDOP  + reminPOP  - reminPOP_CDOM  + degrCDOM_DOP
      dDOFe = dDOFe + reminPOFe - reminPOFe_CDOM + degrCDOM_DOFe

C     gTr(iCDOM)=gTr(iCDOM) + reminPOP_CDOM - degrCDOM_DOP
      dCDOM = dCDOM + reminPOP_CDOM - degrCDOM_DOP
#else
C     gTr(iDIC )=gTr(iDIC ) + reminPOC
C     gTr(iNH4 )=gTr(iNH4 ) + reminPON
C     gTr(iPO4 )=gTr(iPO4 ) + reminPOP
C     gTr(iFeT )=gTr(iFeT ) + reminPOFe
      dDIC = dDIC + reminPOC
      dNH4 = dNH4 + reminPON
      dPO4 = dPO4 + reminPOP
      dFeT = dFeT + reminPOFe
#endif /* DARWIN_ALLOW_CDOM */

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
#ifdef DARWIN_ALLOW_NQUOTA
       predgrazn(j)  = 0.0
#endif
#ifdef DARWIN_ALLOW_PQUOTA
       predgrazp(j)  = 0.0
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
       predgrazfe(j) = 0.0
#endif
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
        regQc = 1.0 _d 0
#ifdef DARWIN_ALLOW_NQUOTA
        regQn = MAX(0., MIN(1., (Qnmax(jz)-Qn(jz))/
     &                          (Qnmax(jz)-Qnmin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQn)
        regQn = regQn**hillnumGraz
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        regQp = MAX(0., MIN(1., (Qpmax(jz)-Qp(jz))/
     &                          (Qpmax(jz)-Qpmin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQp)
        regQp = regQp**hillnumGraz
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        regQfe= MAX(0., MIN(1., (Qfemax(jz)-Qfe(jz))/
     &                          (Qfemax(jz)-Qfemin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQfe)
        regQfe=regQfe**hillnumGraz
#endif
        regQc = regQc**hillnumGraz

CC wght_drv was lacking in several lines in the grazing part (Le Gland, 23/03/2021)
        sumprey = 0.0
        sumpref = 0.0
C       DO jp = 1, nplank
        DO jp = 1, nTrac
        IF (palat(jp,jz).NE.0 _d 0) THEN
C        sumprey = sumprey + palat(jp,jz)*X(jp)
CC       sumprey = sumprey + palat(jp,jz)*X(plank(jp))
         sumprey = sumprey + palat(jp,jz)*X(plank(jp))*wght_drv(jp)
#ifdef DARWIN_GRAZING_SWITCH
C        sumpref = sumpref + palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)
C        sumpref = sumpref + palat(jp,jz)*palat(jp,jz)
C    &             *X(plank(jp))*X(plank(jp))*wght_drv(jp)
C Enable Kill The Winner (KTW) different from 2 (Le Gland, 27/08/2021)
         sumpref = sumpref + (palat(jp,jz)**a_KTW)
     &             * (X(plank(jp))**a_KTW) * wght_drv(jp)
CC   &             *X(plank(jp))*X(plank(jp))
#else
C        sumpref = sumpref + palat(jp,jz)*X(jp)
CC       sumpref = sumpref + palat(jp,jz)*X(plank(jp))
         sumpref = sumpref + palat(jp,jz)*X(plank(jp))*wght_drv(jp)
C        sumpref = sumpref
C    &           + palat(jp,jz)*(X(plank(jp))**1.2)*wght_drv(jp)
#endif
        ENDIF
        ENDDO
        sumprey = MAX(0.0, sumprey - phygrazmin)
        sumpref = MAX(phygrazmin, sumpref)
C       tmp = grazemax(jz)*grazTempFunc(jz)**tempGraz(jz)*X(jz)*
        tmp = grazemax(jz)*grazTempFunc(jz)**tempGraz(jz)*X(plank(jz))*
     &    (sumprey**hollexp/(sumprey**hollexp+kgrazesat(jz)**hollexp))*
     &    (1.0 - EXP(-inhib_graz*sumprey))**inhib_graz_exp

        predexpc  = 0.0 _d 0
        predexpn  = 0.0 _d 0
        predexpp  = 0.0 _d 0
        predexpfe = 0.0 _d 0
C       DO jp = 1, nplank
        DO jp = 1, nTrac
         IF (palat(jp,jz).NE.0 _d 0) THEN
#ifdef DARWIN_GRAZING_SWITCH
C         grazphy = tmp*palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)/sumpref
C         grazphy = tmp*palat(jp,jz)*palat(jp,jz)
C    &              *X(plank(jp))*X(plank(jp))/sumpref
C Enable Kill The Winner (KTW) different from 2 (Le Gland, 27/08/2021)
          grazphy = tmp*((palat(jp,jz)*X(plank(jp)))**a_KTW)/sumpref
#else
C         grazphy = tmp*palat(jp,jz)*X(jp)/sumpref
          grazphy = tmp*palat(jp,jz)*X(plank(jp))/sumpref
C KTW formulation with an alpha coefficient of 1.2 (Le Gland, 03/08/2021)
C (See Vallina et al., 2014)
C         grazphy = tmp*palat(jp,jz)*(X(plank(jp))**1.2)/sumpref
#endif

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
#ifdef DARWIN_ALLOW_NQUOTA
C         predgrazn(jz) = predgrazn(jz) + grazphy*asseff(jp,jz)*
C    &                                    regQn*Qn(jp)
C         predexpn = predexpn + expFrac*grazphy*asseff(jp,jz)*
C    &                                    regQn*Qn(jp)
          predgrazn(jz) = predgrazn(jz) + grazphy*asseff(jp,jz)*
     &                                 regQn*Qn(jp)*wght_drv(jp)
          predexpn = predexpn + expFrac*grazphy*asseff(jp,jz)*
     &                  regQn*Qn(jp)*wght_drv(jp)*wght_drv(jz)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C         predgrazp(jz) = predgrazp(jz) + grazphy*asseff(jp,jz)*
C    &                                    regQp*Qp(jp)
C         predexpp = predexpp + expFrac*grazphy*asseff(jp,jz)*
C    &                                  regQp*Qp(jp)
          predgrazp(jz) = predgrazp(jz) + grazphy*asseff(jp,jz)*
     &                                 regQp*Qp(jp)*wght_drv(jp)
          predexpp = predexpp + expFrac*grazphy*asseff(jp,jz)*
     &                  regQp*Qp(jp)*wght_drv(jp)*wght_drv(jz)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C         predgrazfe(jz) = predgrazfe(jz) + grazphy*asseff(jp,jz)*
C    &                                      regQfe*Qfe(jp)
C         predexpfe = predexpfe + expFrac*grazphy*asseff(jp,jz)*
C    &                                    regQfe*Qfe(jp)
          predgrazfe(jz) = predgrazfe(jz) + grazphy*asseff(jp,jz)*
     &                                 regQfe*Qfe(jp)*wght_drv(jp)
          predexpfe = predexpfe + expFrac*grazphy*asseff(jp,jz)*
     &                  regQfe*Qfe(jp)*wght_drv(jp)*wght_drv(jz)
#endif
#ifdef DARWIN_DEBUG
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
#endif
         ENDIF
        ENDDO

C organic-matter gain will be total preygraz - predgraz
C       graz2OC   = graz2OC  - predgrazc(jz)
        graz2OC   = graz2OC  - predgrazc(jz)*wght_drv(jz)
        graz2POC  = graz2POC - predexpc

#ifdef DARWIN_ALLOW_NQUOTA
C       graz2ON   = graz2ON  - predgrazn(jz)
        graz2ON   = graz2ON  - predgrazn(jz)*wght_drv(jz)
        graz2PON  = graz2PON - predexpn
#else
C       graz2ON   = graz2ON  - predgrazc(jz)*Qn(jz)
        graz2ON   = graz2ON  - predgrazc(jz)*Qn(jz)*wght_drv(jz)
        graz2PON  = graz2PON - predexpc     *Qn(jz)
#endif

#ifdef DARWIN_ALLOW_PQUOTA
C       graz2OP   = graz2OP  - predgrazp(jz)
        graz2OP   = graz2OP  - predgrazp(jz)*wght_drv(jz)
        graz2POP  = graz2POP - predexpp
#else
C       graz2OP   = graz2OP  - predgrazc(jz)*Qp(jz)
        graz2OP   = graz2OP  - predgrazc(jz)*Qp(jz)*wght_drv(jz)
        graz2POP  = graz2POP - predexpc     *Qp(jz)
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
C       graz2OFe  = graz2OFe  - predgrazfe(jz)
        graz2OFe  = graz2OFe  - predgrazfe(jz)*wght_drv(jz)
        graz2POFe = graz2POFe - predexpfe
#else
C       graz2OFe  = graz2OFe  - predgrazc(jz)*Qfe(jz)
        graz2OFe  = graz2OFe  - predgrazc(jz)*Qfe(jz)*wght_drv(jz)
        graz2POFe = graz2POFe - predexpc     *Qfe(jz)
#endif

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
#ifdef DARWIN_ALLOW_CARBON
C         graz2PIC = graz2PIC + preygraz(jp)*R_PICPOC(jp)
          graz2PIC = graz2PIC + preygraz(jp)*R_PICPOC(jp)*wght_drv(jp)
#endif

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
#ifdef DARWIN_ALLOW_CARBON
C     gTr(iPIC )=gTr(iPIC ) + graz2PIC
      dPIC = dPIC + graz2PIC
#endif
#ifdef DARWIN_ALLOW_CDOM
      graz2CDOM = fracCDOM*(graz2OP - graz2POP)
C     gTr(iCDOM)=gTr(iCDOM) + graz2CDOM
C     gTr(iDOC )=gTr(iDOC )             - R_CP_CDOM*graz2CDOM
C     gTr(iDON )=gTr(iDON )             - R_NP_CDOM*graz2CDOM
C     gTr(iDOP )=gTr(iDOP ) - graz2CDOM
C     gTr(iDOFe)=gTr(iDOFe)             - R_FeP_CDOM*graz2CDOM
      dCDOM = dCDOM + graz2CDOM
      dDOC  = dDOC              - R_CP_CDOM*graz2CDOM
      dDON  = dDON              - R_NP_CDOM*graz2CDOM
      dDOP  = dDOP  - graz2CDOM
      dDOFe = dDOFe             - R_FeP_CDOM*graz2CDOM
#endif

C     DO jp = 1, nplank
      DO jp = 1, nTrac
      IF (isPrey(jp).NE.0) THEN
C      gTr(ic+jp-1)= gTr(ic+jp-1) - preygraz(jp)
       a_1t(jp) = a_1t(jp) - preygraz(jp)
       acom(plank(jp)) = acom(plank(jp)) - preygraz(jp)*wght_drv(jp)
#ifdef DARWIN_GRAZING_SWITCH
C I Added the conditions on X>0 to avoid Nans (Boris 07/01/24)
        IF (X(plank(jp)) .GT. 0) THEN
           coeff_KTW(plank(jp)) = coeff_KTW(plank(jp)) + preygraz(jp)
     &             *(1 _d 0 - (1 _d 0)/a_KTW)*wght_drv(jp)/X(plank(jp))
        ELSE
           coeff_KTW(plank(jp)) = coeff_KTW(plank(jp)) + 0 _d 0
        ENDIF
        
#ifdef DARWIN_DEBUG
C       IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C         print*, 'coeff_KTW', coeff_KTW(plank(jp)), 'preygraz',
C    &            preygraz(jp), 'a_KTW', a_KTW, '1-1/a',
C    &            (1 _d 0 - (1 _d 0)/a_KTW), 'wght_drv', wght_drv(jp),
C    &            'X', X(plank(jp)), 'added coeff_KTW', preygraz(jp)*
C    &            (1 _d 0 - (1 _d 0)/a_KTW)*wght_drv(jp)/X(plank(jp))
C       ENDIF
#endif
#endif
#ifdef DARWIN_ALLOW_NQUOTA
C      gTr(in+jp-1)=gTr(in+jp-1) - preygraz(jp)*Qn(jp)
       an_1t(jp) = an_1t(jp) - preygraz(jp)*Qn(jp)
       ancom(plank(jp)) = ancom(plank(jp))
     &                  - preygraz(jp)*Qn(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C      gTr(ip+jp-1)=gTr(ip+jp-1) - preygraz(jp)*Qp(jp)
       ap_1t(jp) = ap_1t(jp) - preygraz(jp)*Qp(jp)
       apcom(plank(jp)) = apcom(plank(jp))
     &                  - preygraz(jp)*Qp(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
C      gTr(isi+jp-1)=gTr(isi+jp-1) - preygraz(jp)*Qsi(jp)
       asi_1t(jp) = asi_1t(jp) - preygraz(jp)*Qsi(jp)
       asicom(plank(jp)) = asicom(plank(jp))
     &                   - preygraz(jp)*Qsi(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C      gTr(ife+jp-1)=gTr(ife+jp-1) - preygraz(jp)*Qfe(jp)
       afe_1t(jp) = afe_1t(jp) - preygraz(jp)*Qfe(jp)
       afecom(plank(jp)) = afecom(plank(jp))
     &                   - preygraz(jp)*Qfe(jp)*wght_drv(jp)
#endif
      ENDIF
      ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
      DO jp = 1, nPhoto
      IF (isPrey(jp).NE.0) THEN
C      gTr(iChl+jp-1)=gTr(iChl+jp-1) - preygraz(jp)*QChl(jp)
       aChl_1t(jp) = aChl_1t(jp) - preygraz(jp)*QChl(jp)
       aChlcom(plank(jp)) = aChlcom(plank(jp))
     &                   - preygraz(jp)*QChl(jp)*wght_drv(jp)
      ENDIF
      ENDDO
#endif

C     DO jz = 1, nplank
      DO jz = 1, nTrac
      IF (isPred(jz).NE.0) THEN
C      gTr(ic+jz-1)=gTr(ic+jz-1) + predgrazc(jz)
       a_1t(jz) = a_1t(jz) + predgrazc(jz)
       acom(plank(jz)) = acom(plank(jz)) + predgrazc(jz)*wght_drv(jz)
       gcom(plank(jz)) = gcom(plank(jz)) + predgrazc(jz)*wght_drv(jz)
#ifdef DARWIN_ALLOW_NQUOTA
C      gTr(in+jz-1)=gTr(in+jz-1) + predgrazn(jz)
       an_1t(jz) = an_1t(jz) + predgrazn(jz)
       ancom(plank(jz)) = ancom(plank(jz)) + predgrazn(jz)*wght_drv(jz)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C      gTr(ip+jz-1)=gTr(ip+jz-1) + predgrazp(jz)
       ap_1t(jz) = ap_1t(jz) + predgrazp(jz)
       apcom(plank(jz)) = apcom(plank(jz)) + predgrazp(jz)*wght_drv(jz)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C      gTr(ife+jz-1)=gTr(ife+jz-1) + predgrazfe(jz)
       afe_1t(jz) = afe_1t(jz) + predgrazfe(jz)
       afecom(plank(jz)) = afecom(plank(jz))
     &                   + predgrazfe(jz)*wght_drv(jz)
#endif
      ENDIF
      ENDDO

#ifdef DARWIN_DIAG_PERTYPE
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
#endif

C==== mortality ========================================================
      exude_DOC  = 0.0 _d 0
      exude_POC  = 0.0 _d 0
      exude_DON  = 0.0 _d 0
      exude_PON  = 0.0 _d 0
      exude_DOFe = 0.0 _d 0
      exude_POFe = 0.0 _d 0
      exude_DOP  = 0.0 _d 0
      exude_POP  = 0.0 _d 0
      exude_POSi = 0.0 _d 0
      exude_PIC  = 0.0 _d 0
      respir     = 0.0 _d 0

C     DO jp = 1, nplank
      DO jp = 1, nTrac
C       Xe = MAX(0 _d 0, X(jp) - Xmin(jp))
        Xe = MAX(0 _d 0, X(plank(jp)) - Xmin(jp))
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
#ifdef DARWIN_ALLOW_NQUOTA
C       gTr(in+jp-1)=gTr(in+jp-1)  - mort_c(jp)*Qn(jp)
        an_1t(jp) = an_1t(jp) - mort_c(jp)*Qn(jp)
        ancom(plank(jp)) = ancom(plank(jp))
     &                   - mort_c(jp)*Qn(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C       gTr(ip+jp-1)=gTr(ip+jp-1)  - mort_c(jp)*Qp(jp)
        ap_1t(jp) = ap_1t(jp) - mort_c(jp)*Qp(jp)
        apcom(plank(jp)) = apcom(plank(jp))
     &                   - mort_c(jp)*Qp(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
C       gTr(isi+jp-1)=gTr(isi+jp-1) - mort_c(jp)*Qsi(jp)
        asi_1t(jp) = asi_1t(jp) - mort_c(jp)*Qsi(jp)
        asicom(plank(jp)) = asicom(plank(jp))
     &                    - mort_c(jp)*Qsi(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C       gTr(ife+jp-1)=gTr(ife+jp-1) - mort_c(jp)*Qfe(jp)
        afe_1t(jp) = afe_1t(jp) - mort_c(jp)*Qfe(jp)
        afecom(plank(jp)) = afecom(plank(jp))
     &                    - mort_c(jp)*Qfe(jp)*wght_drv(jp)
#endif

#ifdef DARWIN_ALLOW_EXUDE
C       exude_DOC =
C    &  exude_DOC + (1.-ExportFracExude(jp))*kexcc(jp)*Xe
        exude_DOC = exude_DOC
     &  + (1.-ExportFracExude(jp))*kexcc(jp)*Xe*wght_drv(jp)
C       exude_POC =
C    &  exude_POC +     ExportFracExude(jp) *kexcc(jp)*Xe
        exude_POC = exude_POC
     &  +     ExportFracExude(jp) *kexcc(jp)*Xe*wght_drv(jp)
C       exude_DON =
C    &  exude_DON + (1.-ExportFracExude(jp))*kexcn(jp)*Xe*Qn(jp)
        exude_DON = exude_DON
     &  + (1.-ExportFracExude(jp))*kexcn(jp)*Xe*Qn(jp)*wght_drv(jp)
C       exude_PON =
C    &  exude_PON +     ExportFracExude(jp) *kexcn(jp)*Xe*Qn(jp)
        exude_PON = exude_PON
     &  +     ExportFracExude(jp) *kexcn(jp)*Xe*Qn(jp)*wght_drv(jp)
C       exude_DOP =
C    &  exude_DOP + (1.-ExportFracExude(jp))*kexcp(jp)*Xe*Qp(jp)
        exude_DOP = exude_DOP
     &  + (1.-ExportFracExude(jp))*kexcp(jp)*Xe*Qp(jp)*wght_drv(jp)
C       exude_POP =
C    &  exude_POP +     ExportFracExude(jp) *kexcp(jp)*Xe*Qp(jp)
        exude_POP = exude_POP
     &  +     ExportFracExude(jp) *kexcp(jp)*Xe*Qp(jp)*wght_drv(jp)
C       exude_DOFe =
C    &  exude_DOFe + (1.-ExportFracExude(jp))*kexcfe(jp)*Xe*Qfe(jp)
        exude_DOFe = exude_DOFe
     &  + (1.-ExportFracExude(jp))*kexcfe(jp)*Xe*Qfe(jp)*wght_drv(jp)
C       exude_POFe =
C    &  exude_POFe +     ExportFracExude(jp) *kexcfe(jp)*Xe*Qfe(jp)
        exude_POFe = exude_POFe
     &  +     ExportFracExude(jp) *kexcfe(jp)*Xe*Qfe(jp)*wght_drv(jp)
C       exude_POSi =
C    &  exude_POSi + kexcsi(jp)*Xe*Qsi(jp)
        exude_POSi = exude_POSi
     &             + kexcsi(jp)*Xe*Qsi(jp)*wght_drv(jp)

C       gTr(ic+jp-1)=gTr(ic+jp-1)   - kexcc(jp)*Xe
        a_1t(jp) = a_1t(jp) - kexcc(jp)*Xe
        acom(plank(jp)) = acom(plank(jp)) - kexcc(jp)*Xe*wght_drv(jp)
#ifdef DARWIN_ALLOW_NQUOTA
C       gTr(in+jp-1)=gTr(in+jp-1)   - kexcn(jp)*Xe*Qn(jp)
        an_1t(jp) = an_1t(jp) - kexcn(jp)*Xe*Qn(jp)
        ancom(plank(jp)) = ancom(plank(jp))
     &                   - kexcn(jp)*Xe*Qn(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
C       gTr(ip+jp-1)=gTr(ip+jp-1)   - kexcp(jp)*Xe*Qp(jp)
        ap_1t(jp) = ap_1t(jp) - kexcp(jp)*Xe*Qp(jp)
        apcom(plank(jp)) = apcom(plank(jp))
     &                   - kexcp(jp)*Xe*Qp(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
C       gTr(isi+jp-1)=gTr(isi+jp-1) - kexcsi(jp)*Xe*Qsi(jp)
        asi_1t(jp) = asi_1t(jp) - kexcsi(jp)*Xe*Qsi(jp)
        asicom(plank(jp)) = asicom(plank(jp))
     &                   - kexcsi(jp)*Xe*Qsi(jp)*wght_drv(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
C       gTr(ife+jp-1)=gTr(ife+jp-1) - kexcfe(jp)*Xe*Qfe(jp)
        afe_1t(jp) = afe_1t(jp) - kexcfe(jp)*Xe*Qfe(jp)
        afecom(plank(jp)) = afecom(plank(jp))
     &                   - kexcfe(jp)*Xe*Qfe(jp)*wght_drv(jp)
#endif
#endif
#ifdef DARWIN_DEBUG
C       IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
C         print*, 'tracer', jp, 'species', plank(jp), 'a_1t', a_1t(jp),
C    &            'acom', acom(plank(jp)), 'mort_c', mort_c(jp),
C    &            'mortX', mortX, 'mortX2', mortX2, 'mort', mort(jp),
C    &            'mort2', mort2(jp), 'mortTempFunc', mortTempFunc,
C    &            'mort2TempFunc', mort2TempFunc, 'respir_c',
C    &            respir_c, 'kexcc', kexcc(jp), 'Xe', Xe,
C    &            'respRate', respRate(jp)
C       ENDIF
#endif
      ENDDO

#ifdef DARWIN_ALLOW_CHLQUOTA
      DO jp = 1, nPhoto
        gTr(iChl+jp-1)=gTr(iChl+jp-1) - mort_c(jp)*QChl(jp)
        aChl_1t(jp) = aChl_1t(jp) - mort_c(jp)*QChl(jp)
        aChlcom(plank(jp)) = aChlcom(plank(jp))
     &                     - mort_c(jp)*QChl(jp)*wght_drv(jp)
      ENDDO
#endif

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

#ifdef DARWIN_ALLOW_CDOM
      exude_CDOM = fracCDOM*exude_DOP
C     gTr(iCDOM)=gTr(iCDOM) + exude_CDOM
C     gTr(iDOC )=gTr(iDOC )              - R_CP_CDOM*exude_CDOM
C     gTr(iDON )=gTr(iDON )              - R_NP_CDOM*exude_CDOM
C     gTr(iDOP )=gTr(iDOP ) - exude_CDOM
C     gTr(iDOFe)=gTr(iDOFe)              - R_FeP_CDOM*exude_CDOM
      dCDOM = dCDOM + exude_CDOM
      dDOC  = dDOC               - R_CP_CDOM*exude_CDOM
      dDON  = dDON               - R_NP_CDOM*exude_CDOM
      dDOP  = dDOP  - exude_CDOM
      dDOFe = dDOFe              - R_FeP_CDOM*exude_CDOM
#endif

C-----------------------------------------------------------------------
C End step 2
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C Step 3: Tranform time derivatives into rates (per unit biomass) and
C rates for different trait values into derivatives with respect to
C trait (Le Gland, 15/03/2021)
C-----------------------------------------------------------------------

      DO j = 1, nTrac
        IF ( X(plank(j)) .GT. 0 _d 0 ) THEN
          a_1t(j) = a_1t(j) / X(plank(j))
#ifdef DARWIN_ALLOW_NQUOTA
          an_1t(j) = an_1t(j) / X(plank(j))
#endif
#ifdef DARWIN_ALLOW_PQUOTA
          ap_1t(j) = ap_1t(j) / X(plank(j))
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
          asi_1t(j) = asi_1t(j) / X(plank(j))
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
          afe_1t(j) = afe_1t(j) / X(plank(j))
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
          aChl_1t(j) = aChl_1t(j) / X(plank(j))
#endif
        ENDIF
      ENDDO

      DO j = 1, nplank
C       IF ( X(plank(j)) .GT. 0 _d 0 ) THEN
        IF ( X(j) .GT. 0 _d 0 ) THEN
          gcom(j) = gcom(j) / X(j)
          acom(j) = acom(j) / X(j)
#ifdef DARWIN_ALLOW_NQUOTA
          ancom(j) = ancom(j) / X(j)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
          apcom(j) = apcom(j) / X(j)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
          asicom(j) = asicom(j) / X(j)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
          afecom(j) = afecom(j) / X(j)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
          aChlcom(j) = aChlcom(j) / X(j)
#endif
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

#ifdef SPEAD_ALLOW_TRAITS
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
#ifdef SPEAD_ALLOW_COV
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
#endif

#ifdef DARWIN_ALLOW_NQUOTA
C       an10 = (anp0 - anm0) / (2*dbv)
C       an01 = (an0p - an0m) / (2*dto)
C       an20 = (anp0 + anm0 - 2*an00) / (dbv**2)
C       an02 = (an0p + an0m - 2*an00) / (dto**2)
C       an11 = (anpp + an00 - anp0 - an0p) / (dbv*dto)
        an00(j) = an_1t(iplank(j))
        IF (isPhoto(iplank(j)) .NE. 0) THEN
          an10(j) = (an_1t(iplank(j)+2) - an_1t(iplank(j)+1)) / (2*dbv)
          an01(j) = (an_1t(iplank(j)+4) - an_1t(iplank(j)+3)) / (2*dto)
          an20(j) = (an_1t(iplank(j)+2) + an_1t(iplank(j)+1)
     &          - 2*an_1t(iplank(j))) / (dbv**2)
          an02(j) = (an_1t(iplank(j)+4) + an_1t(iplank(j)+3)
     &          - 2*an_1t(iplank(j))) / (dto**2)
          an11(j) = (an_1t(iplank(j)+5) + an_1t(iplank(j))
     &          - an_1t(iplank(j)+2) - an_1t(iplank(j)+4)) / (dbv*dto)
        ELSE
          an10(j) = 0.0
          an01(j) = 0.0
          an20(j) = 0.0
          an02(j) = 0.0
          an11(j) = 0.0
        ENDIF
#endif

#ifdef DARWIN_ALLOW_PQUOTA
C       ap10 = (app0 - apm0) / (2*dbv)
C       ap01 = (ap0p - ap0m) / (2*dto)
C       ap20 = (app0 + apm0 - 2*up00) / (dbv**2)
C       ap02 = (ap0p + ap0m - 2*up00) / (dto**2)
C       ap11 = (appp + ap00 - app0 - ap0p) / (dbv*dto)
        ap00(j) = ap_1t(iplank(j))
        IF (isPhoto(iplank(j)) .NE. 0) THEN
          ap10(j) = (ap_1t(iplank(j)+2) - ap_1t(iplank(j)+1)) / (2*dbv)
          ap01(j) = (ap_1t(iplank(j)+4) - ap_1t(iplank(j)+3)) / (2*dto)
          ap20(j) = (ap_1t(iplank(j)+2) + ap_1t(iplank(j)+1)
     &          - 2*ap_1t(iplank(j))) / (dbv**2)
          ap02(j) = (ap_1t(iplank(j)+4) + ap_1t(iplank(j)+3)
     &          - 2*ap_1t(iplank(j))) / (dto**2)
          ap11(j) = (ap_1t(iplank(j)+5) + ap_1t(iplank(j))
     &          - ap_1t(iplank(j)+2) - ap_1t(iplank(j)+4)) / (dbv*dto)
        ELSE
          ap10(j) = 0.0
          ap01(j) = 0.0
          ap20(j) = 0.0
          ap02(j) = 0.0
          ap11(j) = 0.0
        ENDIF
#endif

#ifdef DARWIN_ALLOW_SIQUOTA
C       asi10 = (asip0 - asim0) / (2*dbv)
C       asi01 = (asi0p - asi0m) / (2*dto)
C       asi20 = (asip0 + asim0 - 2*asi00) / (dbv**2)
C       asi02 = (asi0p + asi0m - 2*asi00) / (dto**2)
C       asi11 = (asipp + asi00 - asip0 - asi0p) / (dbv*dto)
        asi00(j) = asi_1t(iplank(j))
        IF (isPhoto(iplank(j)) .NE. 0) THEN
          asi10(j) = (asi_1t(iplank(j)+2)-asi_1t(iplank(j)+1)) / (2*dbv)
          asi01(j) = (asi_1t(iplank(j)+4)-asi_1t(iplank(j)+3)) / (2*dto)
          asi20(j) = (asi_1t(iplank(j)+2) + asi_1t(iplank(j)+1)
     &          - 2*asi_1t(iplank(j))) / (dbv**2)
          asi02(j) = (asi_1t(iplank(j)+4) + asi_1t(iplank(j)+3)
     &          - 2*asi_1t(iplank(j))) / (dto**2)
          asi11(j) = (asi_1t(iplank(j)+5) + asi_1t(iplank(j))
     &          - asi_1t(iplank(j)+2) - asi_1t(iplank(j)+4)) / (dbv*dto)
        ELSE
          asi10(j) = 0.0
          asi01(j) = 0.0
          asi20(j) = 0.0
          asi02(j) = 0.0
          asi11(j) = 0.0
        ENDIF
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
C       afe10 = (afep0 - afem0) / (2*dbv)
C       afe01 = (afe0p - afe0m) / (2*dto)
C       afe20 = (afep0 + afem0 - 2*ufe00) / (dbv**2)
C       afe02 = (afe0p + afe0m - 2*ufe00) / (dto**2)
C       afe11 = (afepp + afe00 - afep0 - afe0p) / (dbv*dto)
        afe00(j) = afe_1t(iplank(j))
        IF (isPhoto(iplank(j)) .NE. 0) THEN
          afe10(j) = (afe_1t(iplank(j)+2)-afe_1t(iplank(j)+1)) / (2*dbv)
          afe01(j) = (afe_1t(iplank(j)+4)-afe_1t(iplank(j)+3)) / (2*dto)
          afe20(j) = (afe_1t(iplank(j)+2) + afe_1t(iplank(j)+1)
     &          - 2*afe_1t(iplank(j))) / (dbv**2)
          afe02(j) = (afe_1t(iplank(j)+4) + afe_1t(iplank(j)+3)
     &          - 2*afe_1t(iplank(j))) / (dto**2)
          afe11(j) = (afe_1t(iplank(j)+5) + afe_1t(iplank(j))
     &          - afe_1t(iplank(j)+2) - afe_1t(iplank(j)+4)) / (dbv*dto)
        ELSE
          afe10(j) = 0.0
          afe01(j) = 0.0
          afe20(j) = 0.0
          afe02(j) = 0.0
          afe11(j) = 0.0
        ENDIF
#endif

#ifdef DARWIN_ALLOW_CHLQUOTA
        aChl00(j) = aChl_1t(iplank(j))
        IF (isPhoto(iplank(j)) .NE. 0) THEN
          aChl10(j) = (aChl_1t(iplank(j)+2) - aChl_1t(iplank(j)+1))
     &                / (2*dbv)
          aChl01(j) = (aChl_1t(iplank(j)+4) - aChl_1t(iplank(j)+3))
     &                / (2*dto)
          aChl20(j) = (aChl_1t(iplank(j)+2) + aChl_1t(iplank(j)+1)
     &        - 2*aChl_1t(iplank(j))) / (dbv**2)
          aChl02(j) = (aChl_1t(iplank(j)+4) + aChl_1t(iplank(j)+3)
     &        - 2*aChl_1t(iplank(j))) / (dto**2)
          aChl11(j) = (aChl_1t(iplank(j)+5) + aChl_1t(iplank(j))
     &        - aChl_1t(iplank(j)+2) - aChl_1t(iplank(j)+4)) / (dbv*dto)
        ELSE
          aChl10(j) = 0.0
          aChl01(j) = 0.0
          aChl20(j) = 0.0
          aChl02(j) = 0.0
          aChl11(j) = 0.0
        ENDIF
#endif

      END DO

C-----------------------------------------------------------------------
C End step 3
C-----------------------------------------------------------------------

#endif /* ALLOW_DARWIN */

      RETURN
      END SUBROUTINE
