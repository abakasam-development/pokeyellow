DisplayPCMainMenu:: ; 213c8 (8:5378)
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	call SaveScreenTilesToBuffer2
	ld a, [wNumHoFTeams]
	and a
	jr nz, .leaguePCAvailable
	ld a, [wd74b]
	bit 5, a
	jr z, .noOaksPC
	ld a, [wNumHoFTeams]
	and a
	jr nz, .leaguePCAvailable
	coord hl, 0, 0
	lb bc, 8, 14
	jr .next
.noOaksPC
	coord hl, 0, 0
	lb bc, 6, 14
	jr .next
.leaguePCAvailable
	coord hl, 0, 0
	lb bc, 10, 14
.next
	call TextBoxBorder
	call UpdateSprites
	ld a, 3
	ld [wMaxMenuItem], a
	ld a, [wd7f1]
	bit 0, a
	jr nz, .metBill
	coord hl, 2, 2
	ld de, SomeonesPCText
	jr .next2
.metBill
	coord hl, 2, 2
	ld de, BillsPCText
.next2
	call PlaceString
	coord hl, 2, 4
	ld de, wPlayerName
	call PlaceString
	ld l, c
	ld h, b
	ld de, PlayersPCText
	call PlaceString
	ld a, [wd74b]
	bit 5, a
	jr z, .noOaksPC2
	coord hl, 2, 6
	ld de, OaksPCText
	call PlaceString
	ld a, [wNumHoFTeams]
	and a
	jr z, .noLeaguePC
	ld a, 4
	ld [wMaxMenuItem], a
	coord hl, 2, 8
	ld de, PKMNLeaguePCText
	call PlaceString
	coord hl, 2, 10
	ld de, LogOffPCText
	jr .next3
.noLeaguePC
	coord hl, 2, 8
	ld de, LogOffPCText
	jr .next3
.noOaksPC2
	ld a, $2
	ld [wMaxMenuItem], a
	coord hl, 2, 6
	ld de, LogOffPCText
.next3
	call PlaceString
	ld a, A_BUTTON | B_BUTTON
	ld [wMenuWatchedKeys], a
	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

SomeonesPCText:   db "SOMEONE's PC@"
BillsPCText:      db "BILL's PC@"
PlayersPCText:    db "'s PC@"
OaksPCText:       db "PROF.OAK's PC@"
PKMNLeaguePCText: db $4a, "LEAGUE@"
LogOffPCText:     db "LOG OFF@"

BillsPC_:: ; 2146f (8:546f)
	ld hl, wd730
	set 6, [hl]
	xor a
	ld [wParentMenuItem], a
	inc a               ; MONSTER_NAME
	ld [wNameListType], a
	call LoadHpBarAndStatusTilePatterns
	ld a, [wListScrollOffset]
	push af
	ld a, [wFlags_0xcd60]
	bit 3, a ; accessing Bill's PC through another PC?
	jr nz, BillsPCMenu
; accessing it directly
	ld a, $99
	call PlaySound
	ld hl, SwitchOnText
	call PrintText

BillsPCMenu: ; 21495 (8:5495)
	ld a, [wParentMenuItem]
	ld [wCurrentMenuItem], a
	ld hl, vChars2 + $780
	ld de, PokeballTileGraphics
	lb bc, BANK(PokeballTileGraphics), $01
	call CopyVideoData
	call LoadScreenTilesFromBuffer2DisableBGTransfer
	coord hl, 0, 12
	lb bc, 4, 18
	call TextBoxBorder
	coord hl, 0, 0
	lb bc, 12, 12
	call TextBoxBorder
	call UpdateSprites
	coord hl, 2, 2
	ld de, BillsPCMenuText
	call PlaceString
	ld hl, wTopMenuItemY
	ld a, 2
	ld [hli], a ; wTopMenuItemY
	dec a
	ld [hli], a ; wTopMenuItemX
	inc hl
	inc hl
	ld a, 5
	ld [hli], a ; wMaxMenuItem
	ld a, A_BUTTON | B_BUTTON
	ld [hli], a ; wMenuWatchedKeys
	xor a
	ld [hli], a ; wLastMenuItem
	ld [hli], a ; wPartyAndBillsPCSavedMenuItem
	ld hl, wListScrollOffset
	ld [hli], a ; wListScrollOffset
	ld [hl], a ; wMenuWatchMovingOutOfBounds
	ld [wPlayerMonNumber], a
	coord hl, 9, 14
	lb bc, 2, 9
	call TextBoxBorder
	ld a, [wCurrentBoxNum]
	and $7f
	cp 9
	jr c, .singleDigitBoxNum
; two digit box num
	sub 9
	coord hl, 17, 16
	ld [hl], "1"
	add "0"
	jr .next
.singleDigitBoxNum
	add "1"
.next
	Coorda 18, 16
	coord hl, 10, 16
	ld de, BoxNoPCText
	call PlaceString
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Delay3
	call HandleMenuInput
	bit 1, a
	jp nz, ExitBillsPC ; b button
	call PlaceUnfilledArrowMenuCursor
	ld a, [wCurrentMenuItem]
	ld [wParentMenuItem], a
	and a
	jp z, BillsPCWithdraw ; withdraw
	cp $1
	jp z, BillsPCDeposit ; deposit
	cp $2
	jp z, BillsPCRelease ; release
	cp $3
	jp z, BillsPCChangeBox ; change box
	cp $4
	jp z, BillsPCPrintBox
	
ExitBillsPC: ; 2153e (8:553e)
	ld a, [wFlags_0xcd60]
	bit 3, a ; accessing Bill's PC through another PC?
	jr nz, .next
; accessing it directly
	call LoadTextBoxTilePatterns
	ld a, $9a
	call PlaySound
	call WaitForSoundToFinish
.next
	ld hl, wFlags_0xcd60
	res 5, [hl]
	call LoadScreenTilesFromBuffer2
	pop af
	ld [wListScrollOffset], a
	ld hl, wd730
	res 6, [hl]
	ret

BillsPCPrintBox: ; 21562 (8:5562)
	callab Func_e8d35
	jp BillsPCMenu

BillsPCDeposit: ; 2156d (8:556d)
	ld a, [wPartyCount]
	dec a
	jr nz, .partyLargeEnough
	ld hl, CantDepositLastMonText
	call PrintText
	jp BillsPCMenu
.partyLargeEnough
	ld a, [W_NUMINBOX]
	cp MONS_PER_BOX
	jr nz, .boxNotFull
	ld hl, BoxFullText
	call PrintText
	jp BillsPCMenu
.boxNotFull
	ld hl, wPartyCount
	call DisplayMonListMenu
	jp c, BillsPCMenu
	callab Func_fce18
	jr nc, .asm_215ad
	call Func_154a
	jr z, .asm_215ad
	ld hl, SleepingPikachuText2
	call PrintText
	jp BillsPCMenu
.asm_215ad
	call DisplayDepositWithdrawMenu
	jp nc, BillsPCMenu
	callab Func_fce18
	jr nc, .asm_215c9
	ld e, $1b
	callab Func_f0000
	jr .asm_215cf
.asm_215c9
	ld a, [wcf91]
	call PlayCry
.asm_215cf
	callabd_Func_f430a $7
	ld a, PARTY_TO_BOX
	ld [wMoveMonType], a
	call MoveMon
	xor a
	ld [wRemoveMonFromBox], a
	call RemovePokemon
	call WaitForSoundToFinish
	ld hl, wBoxNumString
	ld a, [wCurrentBoxNum]
	and $7f
	cp 9
	jr c, .singleDigitBoxNum
	sub 9
	ld [hl], "1"
	inc hl
	add "0"
	jr .next
.singleDigitBoxNum
	add "1"
.next
	ld [hli], a
	ld [hl], $50
	ld hl, MonWasStoredText
	call PrintText
	jp BillsPCMenu

SleepingPikachuText2: ; 2160e (8:560e)
	TX_FAR _SleepingPikachuText2
	db "@"

BillsPCWithdraw: ; 21613 (8:5613)
	ld a, [W_NUMINBOX]
	and a
	jr nz, .boxNotEmpty
	ld hl, NoMonText
	call PrintText
	jp BillsPCMenu
.boxNotEmpty
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr nz, .partyNotFull
	ld hl, CantTakeMonText
	call PrintText
	jp BillsPCMenu
.partyNotFull
	ld hl, W_NUMINBOX
	call DisplayMonListMenu
	jp c, BillsPCMenu
	call DisplayDepositWithdrawMenu
	jp nc, BillsPCMenu
	ld a, [wWhichPokemon]
	ld hl, wBoxMonNicks
	call GetPartyMonName
	callab Func_fce0d
	jr nc, .asm_21660
	ld e, $22
	callab Func_f0000
	jr .asm_21666
.asm_21660
	ld a, [wcf91]
	call PlayCry
.asm_21666
	xor a ; BOX_TO_PARTY
	ld [wMoveMonType], a
	call MoveMon
	ld a, 1
	ld [wRemoveMonFromBox], a
	call RemovePokemon
	call WaitForSoundToFinish
	ld hl, MonIsTakenOutText
	call PrintText
	jp BillsPCMenu

BillsPCRelease: ; 21690 (8:5690)
	ld a, [W_NUMINBOX]
	and a
	jr nz, .loop
	ld hl, NoMonText
	call PrintText
	jp BillsPCMenu
.loop
	ld hl, W_NUMINBOX
	call DisplayMonListMenu
	jp c, BillsPCMenu
	callab Func_fce0d
	jr c, .asm_216cb
	ld hl, OnceReleasedText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .loop
	inc a
	ld [wRemoveMonFromBox], a
	call RemovePokemon
	call WaitForSoundToFinish
	ld a, [wcf91]
	call PlayCry
	ld hl, MonWasReleasedText
	call PrintText
	jp BillsPCMenu

.asm_216cb
	ld a, [wWhichPokemon]
	ld hl, wBoxMonNicks
	call GetPartyMonName
	ld e, $27
	callab Func_f0000
	ld hl, PikachuUnhappyText
	call PrintText
	jp BillsPCMenu
	
BillsPCChangeBox: ; 216e7 (8:56e7)
	callba ChangeBox
	jp BillsPCMenu

DisplayMonListMenu: ; 216f2 (8:56f2)
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	xor a
	ld [wPrintItemPrices], a
	ld [wListMenuID], a
	inc a                ; MONSTER_NAME
	ld [wNameListType], a
	ld a, [wPartyAndBillsPCSavedMenuItem]
	ld [wCurrentMenuItem], a
	call DisplayListMenuID
	ld a, [wCurrentMenuItem]
	ld [wPartyAndBillsPCSavedMenuItem], a
	ret

BillsPCMenuText: ; 21715 (8:5715)
	db   "WITHDRAW ", $4a
	next "DEPOSIT ",  $4a
	next "RELEASE ",  $4a
	next "CHANGE BOX"
	next "PRINT BOX"
	next "SEE YA!"
	db "@"

BoxNoPCText: ; 21751 (8:5751)
	db "BOX No.@"

KnowsHMMove:: ; 21759 (8:5759)
; returns whether mon with party index [wWhichPokemon] knows an HM move
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2 - wPartyMon1
	jr .next
; unreachable
	ld hl, wBoxMon1Moves
	ld bc, wBoxMon2 - wBoxMon1
.next
	ld a, [wWhichPokemon]
	call AddNTimes
	ld b, NUM_MOVES
.loop
	ld a, [hli]
	push hl
	push bc
	ld hl, HMMoveArray
	ld de, 1
	call IsInArray
	pop bc
	pop hl
	ret c
	dec b
	jr nz, .loop
	and a
	ret

HMMoveArray: ; 21783 (8:5783)
	db CUT
	db FLY
	db SURF
	db STRENGTH
	db FLASH
	db $ff

DisplayDepositWithdrawMenu: ; 21789 (8:5789)
	coord hl, 9, 10
	lb bc, 6, 9
	call TextBoxBorder
	ld a, [wParentMenuItem]
	and a ; was the Deposit or Withdraw item selected in the parent menu?
	ld de, DepositPCText
	jr nz, .next
	ld de, WithdrawPCText
.next
	coord hl, 11, 12
	call PlaceString
	coord hl, 11, 14
	ld de, StatsCancelPCText
	call PlaceString
	ld hl, wTopMenuItemY
	ld a, 12
	ld [hli], a ; wTopMenuItemY
	ld a, 10
	ld [hli], a ; wTopMenuItemX
	xor a
	ld [hli], a ; wCurrentMenuItem
	inc hl
	ld a, 2
	ld [hli], a ; wMaxMenuItem
	ld a, A_BUTTON | B_BUTTON
	ld [hli], a ; wMenuWatchedKeys
	xor a
	ld [hl], a ; wLastMenuItem
	ld hl, wListScrollOffset
	ld [hli], a ; wListScrollOffset
	ld [hl], a ; wMenuWatchMovingOutOfBounds
	ld [wPlayerMonNumber], a
	ld [wPartyAndBillsPCSavedMenuItem], a
.loop
	call HandleMenuInput
	bit 1, a ; pressed B?
	jr nz, .exit
	ld a, [wCurrentMenuItem]
	and a
	jr z, .choseDepositWithdraw
	dec a
	jr z, .viewStats
.exit
	and a
	ret
.choseDepositWithdraw
	scf
	ret
.viewStats
	call SaveScreenTilesToBuffer1
	ld a, [wParentMenuItem]
	and a
	ld a, PLAYER_PARTY_DATA
	jr nz, .next2
	ld a, BOX_DATA
.next2
	ld [wMonDataLocation], a
	predef StatusScreen
	predef StatusScreen2
	call LoadScreenTilesFromBuffer1
	call ReloadTilesetTilePatterns
	call RunDefaultPaletteCommand
	call LoadGBPal
	jr .loop

DepositPCText:  db "DEPOSIT@"
WithdrawPCText: db "WITHDRAW@"
StatsCancelPCText:
	db   "STATS"
	next "CANCEL@"

SwitchOnText: ; 21826 (8:5826)
	TX_FAR _SwitchOnText
	db "@"

WhatText: ; 2182b (8:582b)
	TX_FAR _WhatText
	db "@"

DepositWhichMonText: ; 21830 (8:5830)
	TX_FAR _DepositWhichMonText
	db "@"

MonWasStoredText: ; 21835 (8:5835)
	TX_FAR _MonWasStoredText
	db "@"

CantDepositLastMonText: ; 2183a (8:583a)
	TX_FAR _CantDepositLastMonText
	db "@"

BoxFullText: ; 2183f (8:583f)
	TX_FAR _BoxFullText
	db "@"

MonIsTakenOutText: ; 21844 (8:5844)
	TX_FAR _MonIsTakenOutText
	db "@"

NoMonText: ; 21849 (8:5849)
	TX_FAR _NoMonText
	db "@"

CantTakeMonText: ; 2184e (8:584e)
	TX_FAR _CantTakeMonText
	db "@"

PikachuUnhappyText: ; 21853 (8:5853)
	TX_FAR _PikachuUnhappyText
	db "@"

ReleaseWhichMonText: ; 21858 (8:5858)
	TX_FAR _ReleaseWhichMonText
	db "@"
	
OnceReleasedText: ; 2185d (8:585d)
	TX_FAR _OnceReleasedText
	db "@"

MonWasReleasedText: ; 21862 (8:5862)
	TX_FAR _MonWasReleasedText
	db "@"

CableClubLeftGameboy:: ; 21867 (8:5867)
	ld a, [hSerialConnectionStatus]
	cp USING_EXTERNAL_CLOCK
	ret z
	ld a, [wSpriteStateData1 + 9] ; player's sprite facing direction
	cp SPRITE_FACING_RIGHT
	ret nz
	ld a, [W_CURMAP]
	cp TRADE_CENTER
	ld a, LINK_STATE_START_TRADE
	jr z, .next
	inc a ; LINK_STATE_START_BATTLE
.next
	ld [wLinkState], a
	call EnableAutoTextBoxDrawing
	tx_pre_jump JustAMomentText

CableClubRightGameboy:: ; 21887 (8:5887)
	ld a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	ret z
	ld a, [wSpriteStateData1 + 9] ; player's sprite facing direction
	cp SPRITE_FACING_LEFT
	ret nz
	ld a, [W_CURMAP]
	cp TRADE_CENTER
	ld a, LINK_STATE_START_TRADE
	jr z, .next
	inc a ; LINK_STATE_START_BATTLE
.next
	ld [wLinkState], a
	call EnableAutoTextBoxDrawing
	tx_pre_jump JustAMomentText

JustAMomentText:: ; 218a7 (8:58a7)
	TX_FAR _JustAMomentText
	db "@"

	ld a, [wSpriteStateData1 + 9] ; player's sprite facing direction
	cp SPRITE_FACING_UP
	ret nz
	call EnableAutoTextBoxDrawing
	tx_pre_jump OpenBillsPCText

OpenBillsPCText:: ; 218ba (8:58ba)
	db $FD ; FuncTX_BillsPC