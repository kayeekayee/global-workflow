        !COMPILER-GENERATED INTERFACE MODULE: Mon Mar 19 21:38:15 2018
        MODULE INT21_MSK_SUB__genmod
          INTERFACE 
            SUBROUTINE INT21_MSK_SUB(A,ISLI,ALATS,ALONS,NX,NY,X,ISTYP,  &
     &LAT,LON)
              INTEGER(KIND=4), INTENT(IN) :: NY
              INTEGER(KIND=4), INTENT(IN) :: NX
              REAL(KIND=8), INTENT(IN) :: A(NX,NY)
              INTEGER(KIND=4), INTENT(IN) :: ISLI(NX,NY)
              REAL(KIND=8), INTENT(IN) :: ALATS(NX)
              REAL(KIND=8), INTENT(IN) :: ALONS(NY)
              REAL(KIND=8), INTENT(OUT) :: X
              INTEGER(KIND=4), INTENT(IN) :: ISTYP
              INTEGER(KIND=4), INTENT(IN) :: LAT
              INTEGER(KIND=4), INTENT(IN) :: LON
            END SUBROUTINE INT21_MSK_SUB
          END INTERFACE 
        END MODULE INT21_MSK_SUB__genmod
