#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_TEMPFUNC

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_TEMPFUNC(
     I                  Temp,
     O                  photoFun, grazFun, reminFun, mortFun, mort2Fun,
     O                  uptakeFun,
     I                  myThid)

C !DESCRIPTION: ========================================================
C     Compute temperature functions for darwin model.
C
C     DARWIN_TEMP_VERSION 1 used in Follows et al (2007) - without max of 1
C     DARWIN_TEMP_VERSION 2 used in Dutkiewicz et al (2009), Hickman et al, 
C                            Monteiro etal, Barton et al
C     DARWIN_TEMP_RANGE gives all phyto a  specific temperature range
C                if undefined, then full Eppley/Arrenhius curve used

C !USES: ===============================================================
      IMPLICIT NONE
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
      _RL Temp

C !OUTPUT PARAMETERS: ==================================================
C grazFun :: the prey entries are for quota-style grazing,
C            the predator ones for monod-style grazing
C In the continuous model, photoFun needs to be defined only for each
C group. However, derivatives are required (Le Gland, 13/01/2021)
C Derivatives will be computed numerically (Le Gland, 28/01/2021)
C     _RL photoFun(nplank)
C     _RL grazFun(nplank)
      _RL photoFun(nTrac)
      _RL grazFun(nTrac)
      _RL reminFun
      _RL mortFun
      _RL mort2Fun
      _RL uptakeFun
CEOP

#ifdef ALLOW_DARWIN

c !LOCAL VARIABLES: ====================================================
      _RL Tkel
      _RL TempAe, Tempref, TempCoeff, reminref
C     _RL phytoTempTol
      INTEGER j

#ifdef DARWIN_NOTEMP

      photoFun = 1.0 _d 0
      grazFun  = 1.0 _d 0
      reminFun = 1.0 _d 0
      mortFun  = 1.0 _d 0
      mort2Fun = 1.0 _d 0
      uptakeFun = 1.0 _d 0

#elif DARWIN_TEMP_VERSION == 1

c +++++++++++++++++++ VERSION 1 +++++++++++++++++++++++++++++++++++++++
c steph's version 1 (pseudo-Eppley)
c plankton growth function (unitless)
C Given that nothing bad happens in version 3 where nPhoto does not appear,
C I think photoFun will not be read if the species does not photosynthesize.
C (Le Gland, 28/01/2021)
C     DO j = 1, nPhoto
      DO j = 1, nTrac
cswd -- this gives Eppley curve only
        photoFun(j) = phytoTempExp1(j)**Temp
# ifdef DARWIN_TEMP_RANGE
cswd -- temperature range
        photoFun(j) = photoFun(j) *
     &      exp(-phytoTempExp2(j)*
     &           abs(Temp - phytoTempOptimum(j))**phytoDecayPower(j))
# endif
        photoFun(j) = photoFun(j) - tempnorm
        photoFun(j) = phytoTempCoeff(j)*
     &                  max(photoFun(j), 1. _d -10)
        photoFun(j) = min(photoFun(j),1. _d 0)
      ENDDO
C     DO j = 1,nplank
      DO j = 1,nTrac
c       grazFun(j) = zooTempCoeff(j)*EXP(
c    &             zooTempExp(j)*(Temp - zooTempOptimum(j)))
        grazFun(j) = 1.0 _d 0
      ENDDO
      reminFun = 1.0 _d 0
      mortFun  = 1.0 _d 0
      mort2Fun = 1.0 _d 0
      uptakeFun = 1.0 _d 0
c ++++++++++++++ END VERSION 1 +++++++++++++++++++++++++++++++++++++++

#elif DARWIN_TEMP_VERSION == 2

c +++++++++++++++++++ VERSION 2 +++++++++++++++++++++++++++++++++++++++
c steph's version 2 (pseudo-Arrenhius)
      Tkel      =   273.15 _d 0
!      TempAe    = -4000.0 _d 0
!      Tempref   =   293.15 _d 0
!      TempCoeff =     0.5882 _d 0
C     DO j = 1, nPhoto
      DO j = 1, nTrac
cswd -- this gives Arrenhius curve only
        photoFun(j) = exp(TempAeArr*(1. _d 0/(Temp+Tkel) -
     &                                  1. _d 0/(TemprefArr) ) )
# ifdef DARWIN_TEMP_RANGE
cswd -- temperature range
        photoFun(j) = photoFun(j) *
     &      exp(-phytoTempExp2(j)*
     &           abs(Temp - phytoTempOptimum(j))**phytoDecayPower(j))
# endif
        photoFun(j) = photoFun(j)
        photoFun(j) = TempCoeffArr*
     &               max(photoFun(j), 1. _d -10)
C
      ENDDO
      reminFun = exp(TempAeArr*(1.0 _d 0/(Temp+Tkel) -
      reminFun = TempCoeffArr*
     &               max(reminFun, 1. _d -10)
C     DO j = 1, nplank
      DO j = 1, nTrac
        grazFun(j) = reminFun
c       grazFun(j) = 1. _d 0
      ENDDO
c     reminFun = 1. _d 0
      mortFun = reminFun
      mort2Fun = reminFun
c      mortFun = 1.0 _d 0
c      mort2Fun = 1.0 _d 0
      uptakeFun = 1.0 _d 0
c ++++++++++++++ END VERSION 2 +++++++++++++++++++++++++++++++++++++++

#elif DARWIN_TEMP_VERSION == 3

c +++++++++++++++++++ VERSION 3 +++++++++++++++++++++++++++++++++++++++
c ben's version 3 from quota model
      TempAe    =   0.05 _d 0
      Tempref   =  20.0 _d 0
      reminFun = MAX(1 _d -10, EXP(TempAe*(Temp-Tempref)))
C     DO j = 1, nplank
      DO j = 1, nTrac
        photoFun(j) = MAX(1 _d -10, EXP(TempAe*(Temp-Tempref)))
        grazFun(j) = reminFun
      ENDDO
      mortFun = reminFun
      mort2Fun = reminFun
      uptakeFun = reminFun
c ++++++++++++++ END VERSION 3 +++++++++++++++++++++++++++++++++++++++

#elif DARWIN_TEMP_VERSION == 4

c +++++++++++++++++++ VERSION 4 +++++++++++++++++++++++++++++++++++++++
c Le Gland version 4: different value for auto- and heterotrophic 
      TempAe    =   0.092 _d 0
      Tempref   =  20.0 _d 0
cswd -- Eppley curve
      reminFun = MAX(1 _d -10, EXP(TempAe*(Temp-Tempref)))
C     DO j = 1, nplank
      DO j = 1, nTrac
        photoFun(j) = MAX(1 _d -10, EXP(phytoTempExp1(j)*(Temp-Tempref)))
        grazFun(j) = reminFun
      ENDDO
      mortFun = reminFun
      mort2Fun = reminFun
      uptakeFun = reminFun
c ++++++++++++++ END VERSION 4 +++++++++++++++++++++++++++++++++++++++

#elif DARWIN_TEMP_VERSION == 5

c +++++++++++++++++++ VERSION 5 +++++++++++++++++++++++++++++++++++++++
c Le Gland version 5: symmetric response to temperature (phytoplankton)
      TempAe    =   0.092 _d 0
      Tempref   =  20.0 _d 0
cswd -- Eppley curve
      reminFun = MAX(1 _d -10, EXP(TempAe*(Temp-Tempref)))
C     DO j = 1, nplank
      DO j = 1, nTrac
C       photoFun(j) = MAX(1 _d -10, EXP(phytoTempExp1(j)*(Temp-Tempref)))
        photoFun(j) = MAX(1 _d -10, EXP(phytoTempExp1(j)*
     &                (phytoTempOptimum(j)-Tempref)))
        grazFun(j) = reminFun
# ifdef DARWIN_TEMP_RANGE
cswd -- temperature range
        photoFun(j) = photoFun(j) *
     &      exp(-phytoTempExp2(j)*
     &           abs(Temp - phytoTempOptimum(j))**phytoDecayPower(j))
# endif
      ENDDO
      mortFun = reminFun
      mort2Fun = reminFun
      uptakeFun = reminFun
c ++++++++++++++ END VERSION 5 +++++++++++++++++++++++++++++++++++++++

#elif DARWIN_TEMP_VERSION == 6

c +++++++++++++++++++ VERSION 6 +++++++++++++++++++++++++++++++++++++++
c Le Gland version 6: asymmetric responde to temperature (phytoplankton)
c     TempAe    =   0.092 _d 0
C More moderate heterotrophic response to temperature (Le Gland,
C 10/09/2021)
      TempAe       = 0.069 _d 0  ! Value from Le Gland et al. 2021
      Tempref      = 20.0 _d 0
      phytoTempTol = 5.0 _d 0
cswd -- Eppley curve
      reminFun = MAX(1 _d -10, EXP(TempAe*(Temp-Tempref)))
C     DO j = 1, nplank
      DO j = 1, nTrac
        grazFun(j) = reminFun
# ifdef DARWIN_TEMP_RANGE
cswd -- temperature range
# ifdef DARWINIAN_DEMON_TEMP
        phytoTempOptimum(j) = (Temp * (0.056*5. - 1.) - 0.056*(5.)**2.)
     &      /(0.056*5. - 1.)
# endif 
C Correction in the order of parentheses to prevent photoFun from
C being negative (Le Gland, 10/05/2021)
        photoFun(j) = MAX(1 _d -10, EXP(phytoTempExp1(j)*
C    &      (phytoTempOptimum(j)-Tempref))) *
     &      (phytoTempOptimum(j)-Tempref)) *
     &      EXP((Temp-phytoTempOptimum(j))/phytoTempTol(j)) *
C    &      ((phytoTempOptimum(j)+phytoTempTol(j)-Temp)/phytoTempTol(j))
     &      (phytoTempOptimum(j)+phytoTempTol(j)-Temp)/phytoTempTol(j))
# else
        photoFun(j) = MAX(1 _d -10, EXP(phytoTempExp1(j)*(Temp-Tempref)))
# endif
      ENDDO
      mortFun = reminFun
      mort2Fun = reminFun
      uptakeFun = reminFun
c ++++++++++++++ END VERSION 6 +++++++++++++++++++++++++++++++++++++++

#else
#error "DARWIN_TEMP_VERSION must be 1, 2, 3, 4, 5 or 6.  Define in DARWIN_OPTIONS.h"
#endif

#ifdef DARWIN_NOZOOTEMP
C     DO j = 1, nplank
      DO j = 1, nTrac
       grazFun(j) = 1.0 _d 0
      ENDDO
#endif

#endif  /* ALLOW_DARWIN */

      RETURN
      END SUBROUTINE
