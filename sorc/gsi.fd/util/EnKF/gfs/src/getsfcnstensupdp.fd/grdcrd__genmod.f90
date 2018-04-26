        !COMPILER-GENERATED INTERFACE MODULE: Mon Mar 19 21:38:29 2018
        MODULE GRDCRD__genmod
          INTERFACE 
            SUBROUTINE GRDCRD(D,ND,X,NX,FLG)
              INTEGER(KIND=4), INTENT(IN) :: NX
              INTEGER(KIND=4), INTENT(IN) :: ND
              REAL(KIND=8), INTENT(INOUT) :: D(ND)
              REAL(KIND=8), INTENT(IN) :: X(NX)
              INTEGER(KIND=4), INTENT(IN) :: FLG
            END SUBROUTINE GRDCRD
          END INTERFACE 
        END MODULE GRDCRD__genmod
