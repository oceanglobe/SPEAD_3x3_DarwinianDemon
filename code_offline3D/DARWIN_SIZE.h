#ifdef ALLOW_DARWIN

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

#ifndef ALLOW_RADTRANS
      integer nlam
      parameter(nlam=1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
