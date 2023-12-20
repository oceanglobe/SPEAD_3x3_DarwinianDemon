#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_GENERATE_ALLOMETRIC

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_GENERATE_ALLOMETRIC( myThid )

C !DESCRIPTION:
C     Generate parameters for plankton types using an allometric approach

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
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
C     INTEGER jpg(nGroup)
CC    INTEGER jp,jp2,jz,g,gz,l,gmin,iopt
C     INTEGER jp,jp2,jp3,jz,g,gz,l,gmin,iopt
      INTEGER jp,jz,g,gz,l,iopt
C     _RL logvol, vol, volmin
      _RL pp_opt, pp_sig, prd_pry
      _RL kappa
      _RL volmeas, dmmeas
      _RL dmint, dmac
      _RL scalefac, dmratio, slope
      _RL carpcellmeas, carpcellac
      _RL bphy_cell_type
      _RL bmean, bbmean
      _RL bbbratiomeas, bbbratioac

C In a continuous model, this subroutine only sets the traits that do not
C vary within a group (Le Gland, 28/01/2021)
C Is this cumbersome separation really necessary ?

C ======================================================================
C compute traits from trait parameters
C     DO jp=1,nplank
      DO jp=1,nTrac
        g = group(jp)

C ----------------------------------------------------------------------
C non-allometric traits (same within group)

C flags
C       isPhoto(jp)    = grp_photo(g)
C       isPrey(jp)     = grp_prey(g)
C       isPred(jp)     = grp_pred(g)
C       hasSi(jp)      = grp_hasSi(g)
C       hasPIC(jp)     = grp_hasPIC(g)
C       diazo(jp)      = grp_diazo(g)
C       useNH4(jp)     = grp_useNH4(g)
C       useNO2(jp)     = grp_useNO2(g)
C       useNO3(jp)     = grp_useNO3(g)
C       combNO(jp)     = grp_combNO(g)
C       tempMort(jp)   = grp_tempMort(g)
C       tempMort2(jp)  = grp_tempMort2(g)
C       tempGraz(jp)   = grp_tempGraz(g)

C traits
C       Xmin(jp)       = a_Xmin(g)
C       amminhib(jp)   = a_amminhib(g)
C       acclimtimescl(jp) = a_acclimtimescl(g)

C mortality
C       mort(jp) = a_mort(g)
C       mort2(jp) = a_mort2(g)
C       if 0, temperature dependent, if 1, not.
C       ExportFracMort(jp) = a_ExportFracMort(g)
C       ExportFracMort2(jp) = a_ExportFracMort2(g)
C       ExportFracExude(jp) = a_ExportFracExude(g)

C temperature function parameters
C       phytoTempCoeff(jp)   = a_phytoTempCoeff(g)
C       phytoTempExp1(jp)    = a_phytoTempExp1(g)
C       phytoTempExp2(jp)    = a_phytoTempExp2(g)
C phytoTempOptimum is now defined for each species 
C in the same fashion as biovolume
C phytoTempTol is added for the asymmetric temperature dependence
C Le Gland, 10/12/2020
C       phytoTempOptimum(jp) = a_phytoTempOptimum(g)
C       phytoTempTol(jp)     = a_phytoTempTol(g)
C       phytoDecayPower(jp)  = a_phytoDecayPower(g)

C plankton elemental ratios
C       R_NC(jp)       = a_R_NC(g)
C       R_PC(jp)       = a_R_PC(g)
C       R_SiC(jp)      = a_R_SiC(g)
C       R_FeC(jp)      = a_R_FeC(g)
C       R_ChlC(jp)     = a_R_ChlC(g)
C       R_PICPOC(jp)   = a_R_PICPOC(g)

C plankton sinking and swimming
        biosink(jp) = a_biosink(g) * biovol(jp)**b_biosink(g)
        bioswim(jp) = a_bioswim(g) * biovol(jp)**b_bioswim(g)

C respRate rate is given in terms of carbon content
        qcarbon(jp) = a_qcarbon(g) * biovol(jp)**b_qcarbon(g)
        respRate(jp) = a_respRate_c(g)
     &                 * (12. _d 9 * qcarbon(jp))**b_respRate_c(g)
     &                 / qcarbon(jp)

C parameters relating to inorganic nutrients
C       PCmax(jp)= a_PCmax(g) * biovol(jp)**b_PCmax(g)

        IF (isPhoto(jp) .NE. 0) THEN

#ifdef DARWIN_ALLOW_NQUOTA
          vmaxNH4(jp)  = a_vmaxNH4(g)  * biovol(jp)**b_vmaxNH4(g)
     &                 * grp_useNH4(g)
          vmaxNO2(jp)  = a_vmaxNO2(g)  * biovol(jp)**b_vmaxNO2(g)
     &                 * grp_useNO2(g)
          vmaxNO3(jp)  = a_vmaxNO3(g)  * biovol(jp)**b_vmaxNO3(g)
     &                 * grp_useNO3(g)
          vmaxN(jp)    = a_vmaxN(g)    * biovol(jp)**b_vmaxN(g)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
          vmaxPO4(jp)  = a_vmaxPO4(g)  * biovol(jp)**b_vmaxPO4(g)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
          IF (hasSi(jp) .NE. 0) THEN
            vmaxSiO2(jp) = a_vmaxSiO2(g) * biovol(jp)**b_vmaxSiO2(g)
          ENDIF
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
          vmaxFeT(jp)  = a_vmaxFeT(g)  * biovol(jp)**b_vmaxFeT(g)
#endif

          ksatNH4(jp)  = a_ksatNH4(g)  * biovol(jp)**b_ksatNH4(g)
          ksatNO2(jp)  = a_ksatNO2(g)  * biovol(jp)**b_ksatNO2(g)
          ksatNO3(jp)  = a_ksatNO3(g)  * biovol(jp)**b_ksatNO3(g)
          ksatPO4(jp)  = a_ksatPO4(g)  * biovol(jp)**b_ksatPO4(g)
          IF (hasSi(jp) .NE. 0) THEN
            ksatSiO2(jp) = a_ksatSiO2(g) * biovol(jp)**b_ksatSiO2(g)
          ENDIF
          ksatFeT(jp)  = a_ksatFeT(g)  * biovol(jp)**b_ksatFeT(g)


        ENDIF
                                                      
#ifdef DARWIN_ALLOW_NQUOTA
        Qnmin(jp)    = a_Qnmin(g)  * biovol(jp)**b_Qnmin(g)
        Qnmax(jp)    = a_Qnmax(g)  * biovol(jp)**b_Qnmax(g)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        Qpmin(jp)    = a_Qpmin(g)  * biovol(jp)**b_Qpmin(g)
        Qpmax(jp)    = a_Qpmax(g)  * biovol(jp)**b_Qpmax(g)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        Qsimin(jp)   = a_Qsimin(g) * biovol(jp)**b_Qsimin(g)
        Qsimax(jp)   = a_Qsimax(g) * biovol(jp)**b_Qsimax(g)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        Qfemin(jp)   = a_Qfemin(g) * biovol(jp)**b_Qfemin(g)
        Qfemax(jp)   = a_Qfemax(g) * biovol(jp)**b_Qfemax(g)
#endif

C parameters relating to quota nutrients
c EXCRETION
#ifdef DARWIN_ALLOW_EXUDE
        kexcc(jp)  = a_kexcc(g)  * biovol(jp)**b_kexcc(g)
        kexcn(jp)  = a_kexcn(g)  * biovol(jp)**b_kexcn(g)
        kexcp(jp)  = a_kexcp(g)  * biovol(jp)**b_kexcp(g)
        kexcsi(jp) = a_kexcsi(g) * biovol(jp)**b_kexcsi(g)
        kexcfe(jp) = a_kexcfe(g) * biovol(jp)**b_kexcfe(g)
#endif

        IF (darwin_effective_ksat) THEN
C Only case where Qnmin and Qnmaw are necessary but DARWIN_ALLOW_NQUOTA
C is not defined (Le Gland, 12/04/2021)
C----------------------------------------------------------
        Qnmin(jp)    = a_Qnmin(g)  * biovol(jp)**b_Qnmin(g)
        Qnmax(jp)    = a_Qnmax(g)  * biovol(jp)**b_Qnmax(g)
C----------------------------------------------------------
c        compute effective half sat for uptake of non-quota elements
C        we compute it for NO3 and scale for others
         IF (darwin_select_kn_allom.EQ.1) THEN
C         following Ward et al.
          kappa=(ksatNO3(jp)*PCmax(jp)*Qnmin(jp)*(Qnmax(jp)-Qnmin(jp)))/
     &          (vmaxNO3(jp)*Qnmax(jp) +
     &                       PCmax(jp)*Qnmin(jp)*(Qnmax(jp)-Qnmin(jp)))
         ELSEIF (darwin_select_kn_allom.EQ.2) THEN
C         following Follett et al.
          kappa = (ksatNO3(jp)*PCmax(jp)*Qnmin(jp))/vmaxNO3(jp)
         ELSE
          WRITE(msgBuf,'(2A)')'DARWIN_GENERATE_ALLOMETRIC: ',
     &      'illegal value for darwin_select_kn_allom'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
         ENDIF
#ifndef DARWIN_ALLOW_NQUOTA
         ksatNO3(jp) = kappa
         ksatNO2(jp) = kappa*a_ksatNO2fac(g)
         ksatNH4(jp) = kappa*a_ksatNH4fac(g)
#endif
#ifndef DARWIN_ALLOW_PQUOTA
         ksatPO4(jp) = kappa/R_NC(jp)*R_PC(jp)
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
         ksatSiO2(jp) = kappa/R_NC(jp)*R_SiC(jp)
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
         ksatFeT(jp) = kappa/R_NC(jp)*R_FeC(jp)
#endif
        ENDIF

C parameters for bacteria

C flags
C       bactType(jp)  = grp_bacttype(g)
C       isAerobic(jp) = grp_aerobic(g)
C       isDenit(jp)   = grp_denit(g)

C real parameters
C       yieldO2(jp) = 1.0
C       yieldNO3(jp) = 1.0
C       IF (isAerobic(jp) .NE. 0) THEN
C         yield(jp) = yod
C         yieldO2(jp) = yoe
C       ELSEIF (isDenit(jp) .NE. 0) THEN
C         yield(jp) = ynd
C         yieldNO3(jp) = yne
C       ENDIF

C       ksatPON(jp)  = a_ksatPON(g)
C       ksatDON(jp)  = a_ksatDON(g)
C       ksatPOC(jp)  = ksatPON(jp)/R_NC(jp)
C       ksatPOP(jp)  = ksatPON(jp)/R_NC(jp)*R_PC(jp)
C       ksatPOFe(jp) = ksatPON(jp)/R_NC(jp)*R_FeC(jp)
C       ksatDOC(jp)  = ksatDON(jp)/R_NC(jp)
C       ksatDOP(jp)  = ksatDON(jp)/R_NC(jp)*R_PC(jp)
C       ksatDOFe(jp) = ksatDON(jp)/R_NC(jp)*R_FeC(jp)

#ifdef DARWIN_ALLOW_GEIDER
C       mQyield(jp) = a_mQyield(g)
C       chl2cmax(jp) = a_chl2cmax(g)
C       inhibGeider(jp) = a_inhibGeider(g)
#else
C       ksatPAR(jp) = a_ksatPAR(g)
C       kinhPAR(jp) = a_kinhPAR(g)
#endif /* DARWIN_ALLOW_GEIDER */

#ifdef ALLOW_RADTRANS
        aptype(jp) = grp_aptype(g)
        iopt = aptype(jp)
        IF (1 .LE. iopt .AND. iopt .LE. nOpt) THEN
         IF (darwin_allomSpectra) THEN

c FOR ABSORPTION
c in terms of volume
           volmeas = PI / 6. _d 0 * asize(iopt)**3
           scalefac = (biovol(jp)/volmeas)**darwin_absorpSlope
c size specific absorption spectra
           DO l = 1, nlam
             aphy_chl(jp,l) = aphy_chl_type(iopt,l)*scalefac
             aphy_chl_ps(jp,l) = aphy_chl_ps_type(iopt,l)*scalefac
           ENDDO

c TOTAL SCATTER
c in terms of diameter
           volmeas = PI / 6. _d 0 * bsize(iopt)**3
           dmmeas = bsize(iopt)
           dmac = (6. _d 0 * biovol(jp)/PI)**(1. _d 0 / 3. _d 0)
           dmratio = dmac/dmmeas
           carpcellmeas = darwin_aCarCell*volmeas**darwin_bCarCell
           carpcellac = darwin_aCarCell*biovol(jp)**darwin_bCarCell
c size specific scattering spectra
           DO l = 1, nlam
c convert scatter spectrum from m2/mgC to m2/celll
             bphy_cell_type = bphy_mgC_type(iopt,l)*carpcellmeas
             dmint = 10.0 _d 0 ** darwin_scatSwitchSizeLog(l)
             IF (dmmeas.GE.dmint) THEN
               slope = darwin_scatSlopeLarge(l)
             ELSE
               slope = darwin_scatSlopeSmall(l)
             ENDIF
             bphy_mgC(jp,l) = bphy_cell_type*dmratio**slope/carpcellac
           ENDDO

c BACK SCATTER
c calculate mean scatter
           bmean = 0. _d 0
           bbmean = 0. _d 0
           DO l = 1, nlam
             bmean = bmean + bphy_mgC_type(iopt,l)*RT_wbWidths(l)
             bbmean = bbmean + bbphy_mgC_type(iopt,l)*RT_wbWidths(l)
           ENDDO
           bmean = bmean/RT_wbTotalWidth
           bbmean = bbmean/RT_wbTotalWidth
c scale mean backscattering ratio
           bbbratiomeas = bbmean/bmean
           bbbratioac = bbbratiomeas*dmratio**darwin_bbbSlope
           DO l = 1, nlam
             bbphy_mgC(jp,l) = bphy_mgC(jp,l)*bbbratioac
           ENDDO
cc
         ELSE
c OR use read in absorbtion spectra
          DO l = 1, nlam
           aphy_chl(jp,l) = aphy_chl_type(iopt,l)
           aphy_chl_ps(jp,l) = aphy_chl_ps_type(iopt,l)
           bphy_mgC(jp,l) = bphy_mgC_type(iopt,l)
           bbphy_mgC(jp,l) = bbphy_mgC_type(iopt,l)
          ENDDO
         ENDIF
        ELSEIF (jp .LE. nPhoto) THEN
          WRITE(msgBuf,'(A,2I4)')'invalid optical phyto type:',jp,iopt
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
#endif

C     jp
      ENDDO

C Originally from DARWIN_READ_TRAITS.F (Le Gland, 12/04/2021)
C-----------------------------------------------------------
#ifdef ALLOW_RADTRANS

      DO jp = 1, nPhoto
       alpha_mean(jp) = 0.0 _d 0
       DO l = 1, nlam
        alphachl(jp,l) = mQyield(jp) * aphy_chl_ps(jp,l)
        alpha_mean(jp) = alpha_mean(jp) + RT_wbWidths(l)*alphachl(jp,l)
       ENDDO
       alpha_mean(jp) = alpha_mean(jp)/RT_wbTotalWidth
      ENDDO
#else
      DO jp = 1, nPhoto
       alphachl(jp,1) = mQyield(jp) * aphy_chl_ave
       alpha_mean(jp) = alphachl(jp,1)
      ENDDO
#endif /* ALLOW_RADTRANS */

#ifdef ALLOW_RADTRANS
C     DO jp = 1, nplank
      DO jp = 1, nTrac
       IF (pcmax(jp) .GT. 0 _d 0) THEN
         chl2cmin(jp)=chl2cmax(jp)/
     &     (1+(chl2cmax(jp)* alpha_mean(jp) *2000. _d 0)/(2*pcmax(jp)))
       ELSE
         chl2cmin(jp) = 0 _d 0
       ENDIF
      ENDDO
#else
      DO jp = 1, nPhoto
       chl2cmin(jp) = 0. _d 0
      ENDDO
#endif

#ifndef DARWIN_ALLOW_GEIDER
C     DO jp = 1, nplank
C     DO jp = 1, nTrac
      DO jp = 1, nPhoto
       IF (ksatPAR(jp)*kinhPAR(jp) .GT. 0.0) THEN
        normI(jp) = 1.0/(ksatPAR(jp)/(ksatPAR(jp)+kinhPAR(jp))*
     &    EXP(kinhPAR(jp)/ksatPAR(jp)*
     &        LOG(kinhPAR(jp)/(ksatPAR(jp)+kinhPAR(jp)))))
       ELSE
        normI(jp) = 1.0
       ENDIF
      ENDDO
#endif
C-----------------------------------------------------------

C ======================================================================
C grazing

C     DO jz=1,nplank
      DO jz=1,nTrac
        gz = group(jz)
        IF (grp_pred(gz) .GT. 0) THEN
C       maximum grazing rate
          grazemax(jz) = a_grazemax(gz) * biovol(jz)**b_grazemax(gz)
C       grazing half-saturation
          kgrazesat(jz) = a_kgrazesat(gz) * biovol(jz)**b_kgrazesat(gz)
        ENDIF
C       DO jp=1,nplank
        DO jp=1,nTrac
          g = group(jp)
          IF (grp_pred(gz).GT.0 .AND. grp_prey(g).GT.0) THEN
#ifdef DARWIN_ALLOMETRIC_PALAT
C assign grazing preference according to predator/prey radius ratio
C           grazing size preference ratio
            pp_opt = a_ppOpt(gz) * biovol(jz)**b_ppOpt(gz)
C           standard deviation of size preference
            pp_sig = a_ppSig(gz)
            prd_pry = biovol(jz) / biovol(jp)
            palat(jp,jz) =
     &        EXP(-(LOG(prd_pry/pp_opt)**2) / (2*pp_sig**2))
     &        / pp_sig/2. _d 0
            IF (palat(jp,jz).LT.palat_min) THEN
              palat(jp,jz) = 0. _d 0
            ENDIF
#else
C           palat(jp,jz) = 0.0 _d 0
C palat is no longer set in data.traits, it has to be set here
C provisionally (Le Gland, 14/04/2021)
C           palat(jp,jz) = 1.0 _d 0
C Allometric palatability for all predator/prey pairs (Le Gland, 10/06/2021)
            palat(jp,jz) = a_palat(g,gz) * biovol(jp)**b_palat(g,gz)
#endif
C           asseff(jp,jz) = grp_ass_eff(g,gz)
C           ExportFracPreyPred(jp,jz) = grp_ExportFracPreyPred(g,gz)
C These quantities will be set to DARWIN_UNUSED during the initialization
C of constants (Le Gland, 12/04/2021)
C         ELSE
C           palat(jp,jz) = 0. _d 0
C           asseff(jp,jz) = 0. _d 0
C           ExportFracPreyPred(jp,jz) = 0. _d 0
          ENDIF
        ENDDO
      ENDDO

#endif  /*ALLOW_DARWIN*/

      RETURN
      END
