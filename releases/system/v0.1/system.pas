{===========================================================================
	Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
	--------------------------------------------------------------------------
	Copyright (C) 2013 - Luciano L. Goncalez
	--------------------------------------------------------------------------
	a.k.a.: Master Lucky
	eMail : master.lucky.br@gmail.com
	Home  : http://lucky-labs.blogspot.com.br
============================================================================
	Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
	sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
	Software Foundation; na versao 2 da	Licenca.

	Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
	GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
	ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
	Geral GNU para obter mais detalhes.

	Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
	este programa; se nao, escreva para a Free Software Foundation, Inc., 59
	Temple Place, Suite 330, Boston, MA	02111-1307, USA. Ou acesse o site do
	GNU e obtenha sua licenca: http://www.gnu.org/
============================================================================
	Unit System.pas
	--------------------------------------------------------------------------
	Unit principal do compilador, crosscompiler, que substitui a RTL normal.
	--------------------------------------------------------------------------
	Versao: 0.1
	Data: 07/05/2013
	--------------------------------------------------------------------------
	Compilar: Compilavel FPC
	> fpc system.pas
	------------------------------------------------------------------------
	Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit System;

interface

type
	HResult = LongWord;
	DWord = LongWord;

	PByte = ^Byte;
	PWord = ^Word;
	PDWord = ^DWord;


	procedure Move(const Src; var Dest; Count : LongInt);

	procedure FillChar(var X; Count : LongInt; Value : Char);
	procedure FillByte(var X; Count : LongInt; Value : Byte);
	procedure FillWord(var X; Count : LongInt; Value : Word);
	procedure FillDWord(var X; Count : LongInt; Value : DWord);


implementation


procedure Move(const Src; var Dest; Count : LongInt); alias : 'FPC_MOVE';
var
	PSrc, PDest, PEnd : PByte;
begin
	if (Count > 0) and (@Src <> @Dest) then
	begin
		if (@Dest < @Src) or ((@Src + Count) < @Dest) then
		begin
			// copia crescente
			PSrc := @Src;
			PDest := @Dest;
			PEnd := PSrc + Count;

			while (PSrc < PEnd) do
			begin
				PDest^ := PSrc^;
				Inc(PSrc);
				Inc(PDest);
			end;

		end
		else
		begin
			// copia decrescente
			PSrc := @Src + Count - 1;
			PDest := @Dest + Count - 1;
			PEnd := @Src;

			while (PSrc >= PEnd) do
			begin
				PDest^ := PSrc^;
				Dec(PSrc);
				Dec(PDest);
			end;
		end;
	end;
end;

procedure FillChar(var X; Count : LongInt; Value : Char);
begin
	FillByte(X, Count, Byte(Value));
end;

procedure FillByte(var X; Count : LongInt; Value : Byte);
var
	PDestD : PDWord;
	PDestB : PByte;
	vBlocks : LongInt;
	vRest : Byte;
	vTemp : DWord;

begin
	if (Count > 0) then
	begin
		// otimiza para gravar 32 bits (4 Bytes por bloco)
		PDestD := @X;
		vBlocks := Count div 4;
		vRest := Count mod 4;

		if (vBlocks > 0) then
		begin
			vTemp := (Value shl 8) or Value;
			vTemp := (vTemp shl 16) or vTemp;

			repeat
				PDestD^ := vTemp;
				Inc(PDestD);
				Dec(vBlocks);
			until vBlocks = 0;
		end;

		PDestB := Pointer(PDestD);

		// grava o resto
		while (vRest > 0)	 do
		begin
			PDestB^ := Value;
			Inc(PDestB);
			Dec(vRest);
		end;
	end;
end;

procedure FillWord(var X; Count : LongInt; Value : Word);
var
	PDestD : PDWord;
	PDestW : PWord;
	vBlocks : LongInt;
	vRest : Byte;
	vTemp : DWord;

begin
	if (Count > 0) then
	begin
		// otimiza para gravar 32 bits (2 words por bloco)
		PDestD := @X;
		vBlocks := Count div 2;
		vRest := Count mod 2;

		if (vBlocks > 0) then
		begin
			vTemp := (Value shl 16) or Value;

			repeat
				PDestD^ := vTemp;
				Inc(PDestD);
				Dec(vBlocks);
			until vBlocks = 0;
		end;

		PDestW := Pointer(PDestD);

		// grava o resto
		while (vRest > 0) do
		begin
			PDestW^ := Value;
			Inc(PDestW);
			Dec(vRest);
		end;
	end;
end;

procedure FillDWord(var X; Count : LongInt; Value : DWord);
var
	PDestD : PDWord;

begin
	if (Count > 0) then
	begin
		PDestD := @X;

		while (Count > 0) do
		begin
			PDestD^ := Value;
			Inc(PDestD);
			Dec(Count);
		end;
	end;
end;


end.
