### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	P76.agc
## Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
##		build 072.  This is for the Command Module's (CM) 
##		Apollo Guidance Computer (AGC), we believe for 
##		Apollo 15-17.
## Assembler:	yaYUL
## Contact:	Hartmuth Gutsche <hgutsche@xplornet.com>
## Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
## Mod history:	2009-09-20 HG	Adapted from corresponding Comanche 055 file.
## 		2009-09-21 JL	Fixed minor typos. 

## Page 513
# 1) PROGRAM NAME - TARGET DELTA V PROGRAM (P76).
# 2) FUNCTIONAL DESCRIPTION - UPON ENTRY BY ASTRONAUT ACTION, P76 FLASHES DSKY REQUESTS TO THE ASTRONAUT
#	TO PROVIDE VIA DSKY (1) THE DELTA V TO BE APPLIED TO THE OTHER VEHICLE STATE VECTOR AND (2) THE
#	TIME (TIG) AT WHICH THE OTHER VEHICLE VELOCITY WAS CHANGED BY  EXECUTION OF A THRUSTING MANEUVER. THE
#	OTHER VEHICLE STATE VECTOR IS INTEGRATED TO TIG AND UPDATED BY THE ADDITION OF DELTA V (DELTA V HAVING
#	BEEN TRANSFORMED FROM LV TO REF COSYS). USING INTEGRVS, THE PROGRAM THEN INTEGRATES THE OTHER
# 	VEHICLE STATE VECTOR TO THE STATE VECTOR OF THIS VEHICLE, THUS INSURING THAT THE W-MATRIX AND BOTH VEHICLE
# 	STATES CORRESPOND TO THE SAME TIME.
# 3) ERASABLE INITIALIZATION REQUIRED - NONE.
# 4) CALLING SEQUENCES AND EXIT MODES - CALLED BY ASTRONAUT REQUEST THRU DSKY V 37 E 76 E.
#	EXITS BY TCF ENDOFJOB.
# 5) OUTPUT - OTHER VEHICLE STATE VECTOR INTEGRATED TO TIG AND INCREMENTED BY DELTA V IN REF COSYS.
#	THE PUSHLIST CONTAINS THE MATRIX BY WHICH THE INPUT DELTA V MUST BE POST-MULTIPLIED TO CONVERT FROM LV
#	TO REF COSYS.
# 6) DEBRIS - OTHER VEHICLE STATE VECTOR.
# 7) SUBROUTINES CALLED - BANKCALL,GOXDSPF,CSMPREC (OR LEMPREC),ATOPCSM (OR ATOPLEM),INTSTALL,INTWAKE, PHASCHNG
#	INTPRET, INTEGRVS, AND MINIRECT.
# 8) FLAG USE - MOONFLAG,CMOONFLG,INTYPFLG,RASFLAG, AND MARKCTR.

		SETLOC	P76LOC
		BANK

		COUNT*	$$/P7677
		EBANK=	TIG

P76ER77		CA	MODREG
		MASK	BIT1
		TS	OPTFLAG		# OPTFLAG = 0  LM (P76)
		EXTEND			#	  = 1 CSM (P77)
		DCA	NOMTIG
		DXCH	TIG

		CAF	V06N33          
		TC      BANKCALL        # AND WAIT FOR KEYBOARD ACTION.
		CADR    GOFLASH
		TCF     ENDP76	
		TC	+2		# PROCEED
		TC	-5		# STORE DATA AND REPEAT FLASHING
		TC	PHASCHNG
		OCT	04024
		INDEX	OPTFLAG
		CAF	V06N84		# FLASH V06 N84 OR N81
		TC	BANKCALL	# AND WAIT FOR KEYBOARD ACTION.
		CADR	GOFLASH
		TCF	ENDP76
		TC	+2
		TC	-6		# STORE DATA AND REPEAT FLASHING
		TC	INTPRET		# RETURN TO INTERPRETIVE CODE
		DLOAD	SET             # SET D(MPAC)=TIG IN CSEC B28
## Page 514
			TIG
			NODOFLAG	# DISALLOW V37
		STORE	TDEC1
		CCALL	
			OPTFLAG
			INTADR
COMPMAT		VLOAD	UNIT
			RATT
		VCOMP			# U(-R)
		STORE	24D		# U(-R) TO 24D
		VXV	UNIT		# U(-R)XV = U(VXR)
			VATT
		STORE	18D
		VXV	UNIT		# U(VXR)XU(-R) = U((RXV)XR)
			24D
		STORE	12D
		SLOAD	BHIZ
			OPTFLAG
			+4
		VLOAD	GOTO
			DELVLVC		# FROM CSM
			DVTRANS
		VLOAD
			DELVOV		# FROM LM
DVTRANS		VXM	VSL1		# V(MPAC)=DELTA-V IN REFCOSYS
			12D
		VAD
			VATT
		STORE	6		# V(PD6)=VATT + DELTA V
		CALL			# PREVENT WOULD-BE USER OF ORBITAL
			INTSTALL	# INTEG FROM INTERFERING WITH UPDATING
		CALL
			P76SUB1
		VLOAD	VSR*
			6
			0,2
		STOVL	VCV
			RATT
		VSR*
			0,2
		STODL	RCV
			TIG
		STORE	TET
		CLEAR	DLOAD
			INTYPFLG
			TETTHIS
INTOTHIS	STCALL	TDEC1
			INTEGRVS
		CALL
			INTSTALL
## Page 515
		CALL
			P76SUB1         # SET/CLEAR MOONFLAG
		VLOAD
			RATT1
		STORE	RRECT
		STODL	RCV
			TAT
		STOVL	TET
			VATT1
		CALL
			MINIRECT
		EXIT
		TC	PHASCHNG
		OCT	04024

		TC	INPRET
		SET	CCALL
			REINTFLAG
			OPTFLAG
			UPDATADR
		CALL
			INTWAKE0	# PERMIT USE OF ORBITAL INTEGRATION
OUT		CLEAR	EXIT		# ALLOW V37, NO NEED TO CLEAR NODOFLAG AT
			NODOFLAG	#  ENDP76 SINCE FLAG NOT SET WHEN DISPLAY
					#  RESPONSES TRANSFER THERE FROM P76+.
		CAF	NEGONE
		TS	MRKBUF1
		TCF	MNKGOPOO

ENDP76		CAF	NEGONE
		TS	MRKBUF1		# INVALIDATE MARK BUFFER

		TCF	GOTOPOOH

V06N84		NV	0684
		NV	0681		# MUST BE EQUAL TO V06N84 + 1
INTADR		CADR	OTHPREC
		CADR	THISPREC	# MUST BE EQUAL TO INTADR + 1
LPDATADR	CADR	ATOPOTH
		CADR	ATOPTHIS	# MUST BE EQUAL TO UPDATADR + 1
P76SUB1		CLEAR   SLOAD
			MOONFLAG        
			X2
		BHIZ    SET             # X2=0...CLEAR MOONFLAG
			+2              #   =2.....SET MOONFLAG
			MOONFLAG
		RVQ 
