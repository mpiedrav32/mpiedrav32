{
   This is the source code for the full GodSave encryption algorithm,
   version 3, under Borland Pascal 7

   Copyright 1996-1997 by TecApro International

   Unlimited permission to copy, use or adapt is hereby granted
   subject to inclusion of one of the following notices:
      "Encryption using TecApro's GodSave technology, version 3"
      "Encryption derived from TecApro's GodSave technology, version 3"

   Complete documentation can be found at different sites of Internet.
   For a list of these sites, as well for news about GodSave,
   please visit: http://www.tecapro.com/

   version 3 (july 22, 1997)
}

{$F+,O+}
{$R-,S-}

{ use the assembler implementation of the primitive scrambler functions }
{$define useAsm}

unit GodSave3;

interface

uses crt;

const
   maxSizeEncry= 1024; { max size of plaintext }
   withKeyRandom=    $1; { these 5 bits specify the encryption style }
   withTextRandom=   $2;
   withNumRounds=    $C;
   withLazyEncry=   $10;

type
   tScrambleKey= array[0..63] of byte;  { 512 bit key for the scrambler }
   tfRandomByte=function:byte; { user's random number generator }

var                     { the following two variables can be modified any
                          time, even after "declareEncryption" }
   levelEncr:word;      { level of encrypcion }
   encryStyle:word;     { style used; legal values 0..15 }

procedure declareEncryption(masterKey,userKey:string; { keys }
   levelKeyInt,              { level used to produce the working key }
   levelEncry,               { level to be used in encryption or decryption }
   levelRandomkey,           { level used in randomization of key }
   levelRandomText:word;     { level used in randomization of text }
   encryptionStyle:word;     { style to be used at encryption }
   fRandomByte:tfRandomByte);{ pseudo random generator used in randomizations}

procedure GSencrypt(
   var where;            { buffer with plaintext to be encrypted }
   sizeText:word;        { number of bytes of plaintext }
   var sizeCipher:word;  { returned size of ciphertext in bytes }
   var err:word);        { returned error code }

procedure GSdecrypt(
   var where;            { buffer with ciphertext to be decrypted }
   sizeCipher:word;      { number of bytes of ciphertext }
   var sizeText:word;    { returned size of plaintext in bytes }
   var err:word);        { returned error code }

procedure
   GSscramble(
   keyS:tScrambleKey;    { scramber key }
   var where;            { buffer to be scrambled }
   size:word;            { number of bytes to be scrambled }
   level:word;           { level to be used by the scrambler }
   var err:word);        { returned error code }

function GSrandom:byte;  { use only after calling DeclareEncryption }
var GSrandomBuf:array[0..255] of byte; { last 64 bytes: state of GSrandom
                           can be periodically modified by external caller }

procedure initRandomX;

function randomX:byte;

function hash(var source;num8s:word):longInt;

function hashX(var source;num8s:word):longInt;

implementation

const
  baseKey:array[0..447] of byte=
  { GodSave's base key; may be changed to produce non standard versions }
  (241,104,136,174,208, 73, 49,157,107,159,240,181,113,103,249, 18,
    93,222, 52,157,120,138, 15,119,  2,117, 25,201, 78,106, 67, 85,
    41,242,157,216,170, 23, 23,192,  9,171,208,241,235,243,159, 50,
   242,179,187,151,237, 37,246,148, 13, 39,101,  9, 19,132,109, 59,
   231,173,146, 85,214,211,157,162, 88,246,134,209,168,105, 64,252,
   189,185,241, 74, 90,248,181,216,238, 51, 93,199, 26,136,175, 49,
     7,151,108,226,204, 71, 10,250,124, 93,131,229,  8,253,105,129,
   191,204, 57,135,154,178, 43, 20,229,245, 89, 76,169, 48,197,212,
   228,140,119,211, 20,188,231,169,180,182,235,210, 23,  5, 41,135,
     0, 33, 80,179,122,104,204, 98,189,138,237, 60,173,254, 31,176,
    60,111,214,177,165, 96,172, 99, 55, 47,136, 33,168, 50,221, 36,
   129,202,169,223,175, 26,  4, 97,104, 48, 81,192, 41, 83,162,238,
   140,143, 77, 22, 78, 98,197,252,132,116,219,204,206,189,159, 60,
   144,107,165,220,160,203, 86,218, 32, 77, 86,165, 36,237,201, 79,
    26,233, 95,102,159, 90,122, 56,  4, 14,197, 62,241,235, 93,130,
    45,106, 48,182, 73,201,132,157,109,  8,212,116,149, 20,138,250,
    49, 83, 35,155,186, 31,152, 71, 59, 11,  2,199,111, 88,203,162,
   255,  8,155, 65, 48,202, 84,192,150,109,152, 94,220, 23, 52, 18,
   197,  5,206, 62, 59,140, 94,157,139, 84,205,250, 21, 91,174,159,
   123,207, 97,164,197,187, 47,178,132,106,172,254, 10, 38,222,247,
    39, 88,178,251, 76, 37,235,205,149, 75, 49,163,221, 66,111,159,
   113, 61, 24, 99, 99,103,188,  9,211,235,211,138, 84,210,140,219,
   241, 97, 47, 68, 61,209, 69,182,101,247,225,174, 35,137,112,238,
    15,198,143,  6,239, 54, 19,114,113,  8, 43,120,189, 10,214,180,
   207,177,134,227, 55,145,220,185,100,191, 11, 27,119,106, 88,  4,
    95,  8,154, 31, 36,236, 64,176, 13,135,194,179, 99,202, 44,132,
     6,237, 60,197,231, 76, 37,170, 95, 22, 98, 67,244,119, 59, 34,
   200, 44,223, 46,110,136, 65,244,253,177,218, 33,126,153,101,204);

  baseScrambleKey:tScrambleKey=
  { GodSave's secondary key; may be changed to produce non standard versions }
  (216,181, 87,108, 71, 24,249, 61,105,208, 71,249,235,195, 97,100,
   254,222,193, 48,147,209,156,  5, 36, 28,114,248,202,181,127,192,
   239, 46, 36, 49,196, 98, 72,159,235, 96, 91,192,115,189, 23, 33,
   191,239, 98, 53,116,208,207,207, 94,  8,132,163, 29,  2, 33, 11);

  b2bInit:array[byte] of byte=
  { used by SCRAMBLEINIT; may be changed to produce non standard versions }
  (217, 40,170,254,213,201, 98,217, 30, 78,148,253, 83,230, 22,155,
   231,150,184,234, 43,196,190,153, 38,148,213,130, 25, 19, 32, 56,
   100,239, 24,124,132,180,178,118, 47, 77,143,246, 81, 91, 84, 27,
    66,149,186, 38,127, 91,102,246,166,203, 82,116, 47,126,163,155,
    29,180, 38,202, 86,185,190,130,105,144,113,188,101,237,167,238,
   136,142,152, 97,196,110,108,209, 84,191, 17, 58,148,102, 36,188,
   184, 99,248,156,172, 88,195, 34, 69,101, 26,105, 27,157, 22, 86,
   216,178,121,224,192, 50, 60, 19, 69,196, 74, 62,174, 43, 79, 63,
    54, 93,  5,224,174, 15,206, 43,224, 42, 30,134,196,186,139,168,
   174,157,181,225, 77,206,176,213,242,171, 68,248,140,107,131,168,
   230, 52,239,143,125, 30,  3,176, 63, 86, 25,233,183, 70,196, 26,
   165,218,107,224, 61,110, 16, 18, 92, 74,184,126, 55,  0, 83, 11,
   236, 25,147, 94,241,161,229, 45,238,243,208,128, 16,142,211, 22,
   161,191,179, 64,  5,254, 40,170,179,110,196, 23,151, 69, 33,105,
    13, 67,247, 14,152,107, 71, 22,251,147,143, 95,130,251,236, 47,
   101,134,243,166,181, 44,196,164,175,  1, 48,160, 62, 88, 97, 31);

  scrSep:array[0..63] of byte=
  { used by SEPARATEHALVES; may be changed to produce non standard versions }
  (  46,244,101,173,106,129, 86,245,  7,164,160, 58,247,239,252,115,
    185, 80,205, 24, 98, 51,  6,119, 88,116,230,170,102,118, 31, 81,
     58,214,195,108, 88,  7,101,  0, 26,234, 69,102,181,131,147, 35,
    225,217,164,  3, 22,121,212,112,132, 53, 50, 25,186, 88, 31,107);


   backCicles=word(4); { each cicle has 8 bytes
                         => min. size for hash is 32 bytes }
   numScrambles=7; { number of primitive scramble functions }

type
   { type of primitive hash function }
   tFuHash=function(var source;num8s:word):longInt;
   tHowRearrange=array[1..maxSizeEncry div 16] of word;
   tCryptoKey=   array[0..255] of byte; { 2048 bit user's encryption key }
   tSimpleKey=   array[0..31] of byte;  { 256 bit key for the simple cipher }

var
   lastLI:word; { number of longInts in buffer being scrambled minus 1 }
   lastW:word;  { number of words in buffer being scrambled minus 1 }
   hashs:array[0..31] of tFuHash; { index table for the hash functions}
   hashA,hashB,hashC,hashD,hashE,hashF,hashG,hashH,hashI,hashJ:tFuHash;
      { GodSave uses these hash functions for various reasons }

   keyEncry:tCryptoKey; { internal encryption key }
   keyEncry2,keyEncry3,keyEncry4:tCryptoKey;
                        { additional internal encryption keys }
   keyS1:tScrambleKey;  { key used to randomize the encryption key }
   keyS2:tScrambleKey;  { key used to randomize the plaintext }
   keySi:tSimpleKey;    { key used to encrypt then 16 random bytes used
                               by the randomization procedures }
   levelRKey:word;      { level of key randomization }
   levelRText:word;     { level of plaintext randomization }
   getRandomByte:tfRandomByte;
                        { user's function that returns a random byte }
   howSeparate:tHowRearrange; { specifies how to separate text in two halves }
   howUnite:tHowRearrange; { specifies how to re-unite the two halves }
   { initialization values of the 32 primitive hash functions }
   ax0,ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,
   ax10,ax11,ax12,ax13,ax14,ax15,ax16,ax17,ax18,ax19,
   ax20,ax21,ax22,ax23,ax24,ax25,ax26,ax27,ax28,ax29,ax30,ax31,
   cx0,cx1,cx2,cx3,cx4,cx5,cx6,cx7,cx8,cx9,
   cx10,cx11,cx12,cx13,cx14,cx15,cx16,cx17,cx18,cx19,
   cx20,cx21,cx22,cx23,cx24,cx25,cx26,cx27,cx28,cx29,cx30,cx31,
   dx0,dx1,dx2,dx3,dx4,dx5,dx6,dx7,dx8,dx9,
   dx10,dx11,dx12,dx13,dx14,dx15,dx16,dx17,dx18,dx19,
   dx20,dx21,dx22,dx23,dx24,dx25,dx26,dx27,dx28,dx29,dx30,dx31:word;
   GSrandomProx:byte;   { points to next random byte }

{--------------- declaration of the 32 primitive hash functions ------------}

function hash0(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax0
   mov  cx, cx0
   mov  dx, dx0
   clc
@cicle:
   adc  cx,bx
   ror  cx,cl
   sub  cx,dx
   add  dx,es:[di]
   sbb  cx,dx
   sbb  cx,es:[di+2]
   sbb  ax,dx
   sub  cx,dx
   sbb  ax,es:[di+4]
   rcr  dx,cl
   sbb  dx,ax
   sbb  ax,cx
   shl  dx,1
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   sbb  ax,cx
   sub  dx,cx
   rcr  cx,cl
   adc  cx,dx
   adc  ax,bx
   rcr  ax,cl
   sbb  ax,dx
   adc  cx,es:[di]
   adc  cx,ax
   sbb  ax,es:[di+2]
   ror  ax,cl
   add  ax,es:[di+4]
   sbb  cx,dx
   sub  ax,es:[di+6]
   sub  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash1(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax1
   mov  cx, cx1
   mov  dx, dx1
   clc
@cicle:
   sbb  dx,es:[di]
   adc  dx,cx
   xor  dx,ax
   shl  ax,1
   adc  ax,cx
   sbb  ax,dx
   sbb  cx,es:[di+2]
   ror  cx,cl
   adc  cx,ax
   rcr  dx,cl
   adc  ax,cx
   sbb  cx,dx
   sbb  ax,es:[di+4]
   sub  cx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   xor  ax,bx
   xor  cx,dx
   shr  dx,1
   sbb  dx,ax
   rcr  cx,cl
   adc  ax,cx
   sbb  ax,es:[di]
   sub  cx,es:[di+2]
   sub  ax,es:[di+4]
   sbb  ax,cx
   adc  dx,cx
   adc  dx,es:[di+6]
   xor  ax,cx
   ror  dx,cl
   sub  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash2(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax2
   mov  cx, cx2
   mov  dx, dx2
   clc
@cicle:
   ror  ax,cl
   add  dx,es:[di]
   sbb  cx,es:[di+2]
   add  ax,es:[di+4]
   sbb  dx,cx
   sbb  ax,cx
   adc  cx,es:[di+6]
   adc  cx,dx
   adc  dx,cx
   sbb  cx,ax
   sub  dx,cx
   shr  ax,1
   sub  ax,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  ax,cx
   add  dx,cx
   adc  dx,es:[di]
   sbb  ax,dx
   sub  ax,cx
   rcl  cx,cl
   add  cx,bx
   add  cx,ax
   sub  ax,es:[di+2]
   rcl  ax,cl
   adc  cx,es:[di+4]
   shr  ax,1
   sbb  ax,es:[di+6]
   sub  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash3(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax3
   mov  cx, cx3
   mov  dx, dx3
   clc
@cicle:
   sub  cx,es:[di]
   add  ax,dx
   adc  dx,cx
   rol  dx,cl
   add  ax,dx
   adc  ax,es:[di+2]
   add  ax,dx
   sbb  cx,es:[di+4]
   sub  dx,cx
   sbb  cx,ax
   ror  cx,cl
   adc  dx,es:[di+6]
   adc  ax,bx
   ror  dx,cl
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   sub  ax,es:[di]
   xor  cx,ax
   shr  cx,1
   sbb  cx,bx
   rol  cx,cl
   add  cx,es:[di+2]
   add  dx,cx
   xor  cx,dx
   rcl  dx,cl
   sbb  ax,cx
   sbb  cx,es:[di+4]
   xor  cx,dx
   shr  ax,1
   add  ax,es:[di+6]
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash4(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax4
   mov  cx, cx4
   mov  dx, dx4
   clc
@cicle:
   sbb  dx,es:[di]
   ror  ax,cl
   sub  dx,ax
   sub  cx,es:[di+2]
   xor  dx,bx
   sub  ax,cx
   adc  ax,es:[di+4]
   shr  cx,1
   sbb  cx,dx
   sbb  cx,es:[di+6]
   adc  ax,cx
   sbb  cx,dx
   sbb  dx,ax
   sub  dx,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   rol  cx,cl
   rol  cx,cl
   add  dx,es:[di]
   sub  ax,es:[di+2]
   ror  dx,cl
   add  ax,cx
   xor  cx,ax
   add  dx,es:[di+4]
   adc  ax,bx
   sbb  dx,ax
   adc  dx,es:[di+6]
   add  cx,dx
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash5(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax5
   mov  cx, cx5
   mov  dx, dx5
   clc
@cicle:
   rol  cx,cl
   sub  ax,es:[di]
   sbb  ax,bx
   ror  cx,cl
   add  cx,ax
   adc  dx,es:[di+2]
   ror  cx,cl
   add  cx,es:[di+4]
   sub  ax,dx
   adc  dx,cx
   add  cx,ax
   rol  ax,cl
   add  ax,es:[di+6]
   add  dx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   sbb  cx,es:[di]
   sbb  ax,dx
   sub  ax,es:[di+2]
   shr  dx,1
   rcr  ax,cl
   rcr  cx,cl
   adc  dx,cx
   sbb  cx,es:[di+4]
   adc  ax,es:[di+6]
   xor  cx,dx
   rcl  cx,cl
   sbb  dx,ax
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash6(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax6
   mov  cx, cx6
   mov  dx, dx6
   clc
@cicle:
   sbb  cx,ax
   shr  dx,1
   adc  cx,es:[di]
   adc  ax,es:[di+2]
   sub  dx,cx
   adc  dx,es:[di+4]
   add  cx,ax
   add  dx,bx
   sub  cx,dx
   ror  ax,cl
   sbb  ax,es:[di+6]
   adc  ax,dx
   shr  dx,1
   sub  dx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  ax,cx
   sub  ax,dx
   sub  ax,es:[di]
   sbb  dx,bx
   add  cx,ax
   sbb  dx,cx
   sub  cx,es:[di+2]
   sub  cx,es:[di+4]
   shl  cx,1
   sbb  cx,ax
   sbb  cx,es:[di+6]
   rcl  cx,cl
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash7(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax7
   mov  cx, cx7
   mov  dx, dx7
   clc
@cicle:
   add  cx,es:[di]
   adc  ax,cx
   adc  cx,dx
   rcr  dx,cl
   add  dx,es:[di+2]
   adc  cx,es:[di+4]
   adc  cx,ax
   xor  dx,cx
   sub  ax,dx
   sbb  ax,bx
   ror  ax,cl
   shr  dx,1
   add  dx,es:[di+6]
   add  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   sub  cx,ax
   add  ax,es:[di]
   sbb  cx,ax
   adc  cx,bx
   add  dx,es:[di+2]
   adc  dx,es:[di+4]
   sbb  ax,cx
   rol  cx,cl
   rol  ax,cl
   rcr  cx,cl
   sbb  ax,cx
   add  ax,dx
   sbb  dx,es:[di+6]
   add  cx,ax
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash8(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax8
   mov  cx, cx8
   mov  dx, dx8
   clc
@cicle:
   add  cx,dx
   rcl  ax,cl
   sbb  cx,bx
   sub  dx,es:[di]
   sub  cx,es:[di+2]
   adc  dx,cx
   shr  cx,1
   sbb  ax,dx
   sub  dx,es:[di+4]
   sbb  cx,ax
   sbb  cx,ax
   sbb  ax,es:[di+6]
   sub  cx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  dx,cx
   add  dx,es:[di]
   adc  cx,bx
   xor  cx,ax
   rcr  cx,cl
   add  cx,es:[di+2]
   adc  cx,dx
   rol  cx,cl
   adc  ax,cx
   sbb  ax,dx
   sbb  dx,es:[di+4]
   sub  cx,es:[di+6]
   add  dx,ax
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash9(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax9
   mov  cx, cx9
   mov  dx, dx9
   clc
@cicle:
   sub  ax,es:[di]
   sbb  cx,es:[di+2]
   add  cx,bx
   adc  dx,ax
   xor  cx,ax
   shl  cx,1
   adc  cx,dx
   sbb  dx,es:[di+4]
   adc  ax,cx
   rol  ax,cl
   adc  cx,ax
   sbb  ax,dx
   xor  dx,cx
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  ax,dx
   adc  ax,dx
   sub  ax,es:[di]
   rcr  ax,cl
   adc  cx,dx
   sub  cx,es:[di+2]
   add  dx,cx
   add  dx,bx
   adc  ax,es:[di+4]
   add  dx,es:[di+6]
   adc  cx,ax
   adc  ax,cx
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash10(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax10
   mov  cx, cx10
   mov  dx, dx10
   clc
@cicle:
   sbb  dx,es:[di]
   add  cx,dx
   sbb  dx,es:[di+2]
   sbb  ax,dx
   sbb  dx,cx
   sub  ax,dx
   ror  dx,cl
   xor  cx,bx
   add  cx,ax
   add  cx,es:[di+4]
   add  cx,dx
   sub  dx,es:[di+6]
   sub  ax,dx
   rol  ax,cl
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   shr  cx,1
   add  dx,cx
   rcl  dx,cl
   sbb  cx,bx
   sub  ax,dx
   sub  dx,es:[di]
   add  cx,dx
   adc  cx,es:[di+2]
   adc  dx,es:[di+4]
   add  cx,ax
   sub  dx,cx
   adc  ax,es:[di+6]
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash11(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax11
   mov  cx, cx11
   mov  dx, dx11
   clc
@cicle:
   add  ax,cx
   ror  dx,cl
   add  cx,es:[di]
   add  dx,cx
   xor  ax,bx
   ror  cx,cl
   shl  cx,1
   sbb  cx,es:[di+2]
   adc  cx,dx
   sbb  ax,dx
   sub  dx,cx
   sub  dx,ax
   add  cx,es:[di+4]
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  cx,es:[di]
   sbb  ax,es:[di+2]
   adc  dx,es:[di+4]
   sbb  ax,dx
   ror  cx,cl
   adc  dx,cx
   xor  dx,ax
   add  dx,es:[di+6]
   sbb  ax,cx
   shr  dx,1
   rol  dx,cl
   add  cx,dx
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash12(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax12
   mov  cx, cx12
   mov  dx, dx12
   clc
@cicle:
   xor  ax,cx
   adc  dx,es:[di]
   sbb  dx,cx
   sub  cx,dx
   ror  dx,cl
   sub  dx,es:[di+2]
   add  ax,bx
   adc  ax,es:[di+4]
   sbb  cx,dx
   sub  cx,ax
   add  ax,es:[di+6]
   sbb  ax,cx
   sbb  cx,ax
   ror  cx,cl
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   add  cx,dx
   sub  cx,es:[di]
   sub  cx,dx
   add  cx,dx
   adc  cx,es:[di+2]
   sbb  dx,ax
   sub  ax,bx
   add  cx,ax
   add  ax,es:[di+4]
   ror  ax,cl
   sub  dx,es:[di+6]
   add  ax,cx
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash13(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax13
   mov  cx, cx13
   mov  dx, dx13
   clc
@cicle:
   adc  cx,es:[di]
   sbb  dx,bx
   sbb  ax,es:[di+2]
   adc  dx,es:[di+4]
   sub  ax,dx
   sub  dx,ax
   adc  cx,ax
   sbb  dx,cx
   ror  cx,cl
   sbb  ax,es:[di+6]
   adc  ax,dx
   sbb  cx,ax
   sub  dx,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   xor  ax,bx
   sub  cx,dx
   rcr  cx,cl
   sub  cx,ax
   xor  dx,ax
   adc  dx,es:[di]
   xor  ax,dx
   xor  dx,ax
   sub  cx,es:[di+2]
   adc  cx,dx
   add  cx,es:[di+4]
   rcr  dx,cl
   adc  dx,es:[di+6]
   add  dx,cx
   sub  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash14(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax14
   mov  cx, cx14
   mov  dx, dx14
   clc
@cicle:
   sub  cx,ax
   sbb  ax,cx
   sbb  dx,bx
   sub  cx,dx
   adc  cx,es:[di]
   adc  dx,ax
   add  ax,es:[di+2]
   sub  dx,cx
   adc  ax,dx
   sbb  cx,es:[di+4]
   adc  dx,es:[di+6]
   sbb  ax,dx
   sbb  ax,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   sub  di, 8
   mov  bx, backCicles
@cicle2:
   shl  ax,1
   sbb  ax,es:[di]
   shl  ax,1
   sbb  ax,dx
   adc  cx,es:[di+2]
   sbb  dx,cx
   sbb  ax,es:[di+4]
   sub  ax,es:[di+6]
   ror  cx,cl
   xor  ax,bx
   sub  cx,ax
   sub  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash15(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax15
   mov  cx, cx15
   mov  dx, dx15
   clc
@cicle:
   xor  ax,dx
   ror  dx,cl
   adc  cx,es:[di]
   add  dx,ax
   adc  cx,dx
   adc  ax,bx
   add  dx,cx
   adc  dx,es:[di+2]
   add  ax,dx
   add  cx,ax
   ror  dx,cl
   sub  ax,es:[di+4]
   add  ax,dx
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   xor  ax,es:[di]
   xor  cx,dx
   sub  ax,dx
   ror  cx,cl
   ror  dx,cl
   add  dx,ax
   rcl  dx,cl
   add  dx,es:[di+2]
   sbb  cx,dx
   adc  dx,es:[di+4]
   sub  ax,es:[di+6]
   rcl  cx,cl
   sbb  cx,bx
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash16(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax16
   mov  cx, cx16
   mov  dx, dx16
   clc
@cicle:
   add  cx,ax
   adc  ax,es:[di]
   adc  dx,es:[di+2]
   add  cx,ax
   sbb  dx,cx
   xor  cx,bx
   ror  dx,cl
   sbb  ax,cx
   shr  cx,1
   sub  cx,dx
   sbb  ax,dx
   add  dx,es:[di+4]
   sbb  cx,dx
   adc  ax,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   adc  cx,bx
   shl  cx,1
   rol  ax,cl
   add  cx,es:[di]
   add  ax,dx
   sub  dx,cx
   ror  ax,cl
   sbb  cx,es:[di+2]
   sbb  cx,ax
   add  ax,cx
   xor  cx,es:[di+4]
   ror  cx,cl
   add  cx,es:[di+6]
   adc  ax,cx
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash17(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax17
   mov  cx, cx17
   mov  dx, dx17
   clc
@cicle:
   shl  dx,1
   sbb  cx,bx
   add  dx,es:[di]
   adc  cx,dx
   sub  ax,dx
   adc  dx,es:[di+2]
   rcr  ax,cl
   adc  cx,es:[di+4]
   add  dx,cx
   adc  cx,dx
   xor  ax,es:[di+6]
   rol  ax,cl
   add  dx,ax
   adc  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sub  ax,cx
   sbb  cx,ax
   rcl  cx,cl
   add  ax,bx
   rol  dx,cl
   sbb  cx,dx
   ror  dx,cl
   add  cx,es:[di]
   adc  cx,dx
   adc  dx,es:[di+2]
   rol  cx,cl
   xor  cx,es:[di+4]
   sub  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash18(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax18
   mov  cx, cx18
   mov  dx, dx18
   clc
@cicle:
   adc  cx,ax
   sub  dx,cx
   add  cx,ax
   sub  cx,es:[di]
   add  ax,cx
   rol  cx,cl
   adc  dx,es:[di+2]
   add  cx,es:[di+4]
   adc  ax,cx
   sbb  cx,dx
   rcr  ax,cl
   adc  cx,es:[di+6]
   sbb  ax,dx
   adc  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   adc  dx,es:[di]
   sub  dx,bx
   rol  cx,cl
   xor  cx,dx
   ror  ax,cl
   sub  ax,dx
   sbb  dx,es:[di+2]
   sbb  ax,es:[di+4]
   sub  ax,cx
   sub  dx,ax
   sub  dx,es:[di+6]
   adc  cx,ax
   add  dx,cx
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash19(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax19
   mov  cx, cx19
   mov  dx, dx19
   clc
@cicle:
   sub  cx,dx
   sub  dx,ax
   sbb  dx,es:[di]
   sbb  cx,es:[di+2]
   sub  ax,es:[di+4]
   rol  ax,cl
   sub  cx,ax
   sbb  ax,cx
   sbb  ax,es:[di+6]
   shr  cx,1
   rcl  cx,cl
   sbb  dx,ax
   add  cx,bx
   adc  dx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  ax,bx
   sbb  dx,es:[di]
   sub  ax,cx
   add  cx,es:[di+2]
   add  dx,es:[di+4]
   xor  dx,ax
   add  dx,ax
   rol  ax,cl
   shl  ax,1
   sbb  cx,ax
   sbb  dx,es:[di+6]
   rol  dx,cl
   sub  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash20(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax20
   mov  cx, cx20
   mov  dx, dx20
   clc
@cicle:
   add  cx,ax
   add  ax,bx
   rol  ax,cl
   add  cx,es:[di]
   adc  ax,es:[di+2]
   xor  dx,ax
   shl  ax,1
   adc  ax,cx
   sub  ax,dx
   adc  cx,dx
   rol  ax,cl
   adc  cx,ax
   add  ax,es:[di+4]
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   add  ax,es:[di]
   rol  cx,cl
   add  dx,cx
   adc  dx,cx
   sbb  dx,es:[di+2]
   xor  ax,es:[di+4]
   rol  ax,cl
   sub  cx,bx
   sbb  cx,dx
   sub  cx,ax
   ror  ax,cl
   sbb  ax,cx
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash21(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax21
   mov  cx, cx21
   mov  dx, dx21
   clc
@cicle:
   sub  dx,ax
   xor  ax,bx
   sbb  ax,dx
   rol  dx,cl
   add  cx,es:[di]
   adc  dx,cx
   sbb  cx,dx
   sub  ax,es:[di+2]
   sbb  ax,dx
   ror  dx,cl
   sbb  dx,ax
   sub  cx,dx
   sbb  ax,es:[di+4]
   add  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   xor  ax,es:[di]
   adc  dx,ax
   sub  dx,bx
   rcl  cx,cl
   sbb  ax,cx
   sbb  ax,es:[di+2]
   sub  dx,es:[di+4]
   xor  cx,es:[di+6]
   rcr  cx,cl
   adc  ax,cx
   sbb  cx,dx
   rol  ax,cl
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash22(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax22
   mov  cx, cx22
   mov  dx, dx22
   clc
@cicle:
   xor  cx,es:[di]
   xor  ax,dx
   ror  dx,cl
   sbb  cx,dx
   adc  dx,es:[di+2]
   add  ax,cx
   sub  cx,dx
   xor  cx,bx
   add  dx,es:[di+4]
   sbb  ax,es:[di+6]
   adc  dx,ax
   ror  dx,cl
   sub  cx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  ax,es:[di]
   adc  cx,es:[di+2]
   sub  dx,ax
   sub  ax,bx
   ror  ax,cl
   add  dx,ax
   rcl  ax,cl
   add  cx,es:[di+4]
   shl  dx,1
   adc  cx,dx
   xor  ax,cx
   add  ax,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash23(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax23
   mov  cx, cx23
   mov  dx, dx23
   clc
@cicle:
   adc  dx,es:[di]
   sub  cx,ax
   sub  cx,es:[di+2]
   sub  dx,cx
   ror  cx,cl
   xor  cx,bx
   xor  cx,es:[di+4]
   add  ax,cx
   add  dx,ax
   adc  ax,cx
   sbb  ax,es:[di+6]
   sbb  cx,ax
   adc  ax,dx
   shr  dx,1
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  dx,es:[di]
   adc  cx,dx
   add  dx,cx
   rcr  dx,cl
   xor  cx,es:[di+2]
   sbb  cx,bx
   sbb  cx,ax
   ror  ax,cl
   xor  ax,es:[di+4]
   adc  ax,es:[di+6]
   adc  ax,dx
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash24(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax24
   mov  cx, cx24
   mov  dx, dx24
   clc
@cicle:
   sbb  cx,bx
   sbb  dx,es:[di]
   sbb  cx,ax
   add  dx,cx
   sub  dx,cx
   adc  ax,es:[di+2]
   sub  dx,ax
   ror  ax,cl
   adc  cx,es:[di+4]
   sub  dx,cx
   rol  cx,cl
   xor  cx,dx
   sbb  ax,es:[di+6]
   sub  ax,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   or   dx,es:[di]
   rcr  ax,cl
   rcr  ax,cl
   sbb  dx,ax
   add  dx,cx
   sbb  cx,dx
   sub  cx,dx
   shl  dx,1
   sbb  ax,es:[di+2]
   add  cx,bx
   sbb  ax,cx
   sub  ax,cx
   adc  cx,es:[di+4]
   xor  cx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash25(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax25
   mov  cx, cx25
   mov  dx, dx25
   clc
@cicle:
   adc  ax,cx
   xor  ax,bx
   xor  dx,es:[di]
   sub  cx,dx
   adc  ax,es:[di+2]
   sub  cx,ax
   sub  dx,es:[di+4]
   rol  cx,cl
   ror  dx,cl
   xor  dx,ax
   adc  cx,es:[di+6]
   adc  ax,dx
   ror  dx,cl
   add  dx,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  ax,es:[di]
   add  dx,es:[di+2]
   add  cx,dx
   sub  dx,ax
   sub  dx,ax
   sbb  dx,cx
   or   cx,bx
   ror  cx,cl
   xor  dx,es:[di+4]
   add  ax,dx
   adc  dx,cx
   sub  ax,cx
   adc  ax,dx
   add  ax,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash26(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax26
   mov  cx, cx26
   mov  dx, dx26
   clc
@cicle:
   sub  dx,ax
   adc  ax,es:[di]
   adc  cx,bx
   sbb  cx,es:[di+2]
   xor  ax,cx
   sub  dx,ax
   ror  ax,cl
   sub  cx,es:[di+4]
   adc  dx,ax
   add  cx,dx
   sub  dx,es:[di+6]
   adc  dx,cx
   ror  cx,cl
   xor  ax,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   add  cx,es:[di]
   add  cx,dx
   adc  dx,ax
   and  dx,es:[di+2]
   xor  cx,es:[di+4]
   adc  dx,cx
   and  dx,ax
   sub  cx,bx
   rol  ax,cl
   add  dx,cx
   rcl  dx,cl
   add  dx,cx
   sub  ax,cx
   sbb  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash27(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax27
   mov  cx, cx27
   mov  dx, dx27
   clc
@cicle:
   sub  dx,bx
   add  dx,es:[di]
   sbb  ax,es:[di+2]
   xor  ax,dx
   sub  ax,dx
   sbb  dx,ax
   adc  ax,es:[di+4]
   ror  cx,cl
   add  cx,dx
   sbb  cx,ax
   adc  ax,es:[di+6]
   sbb  dx,cx
   sub  cx,ax
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   ror  cx,cl
   add  ax,es:[di]
   xor  ax,bx
   adc  dx,cx
   rol  ax,cl
   adc  dx,ax
   add  dx,ax
   adc  dx,es:[di+2]
   adc  cx,ax
   xor  ax,dx
   xor  ax,cx
   adc  ax,es:[di+4]
   add  cx,es:[di+6]
   add  dx,ax
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash28(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax28
   mov  cx, cx28
   mov  dx, dx28
   clc
@cicle:
   sbb  dx,cx
   rcr  ax,cl
   adc  cx,es:[di]
   sub  dx,cx
   adc  ax,cx
   xor  cx,bx
   sub  ax,es:[di+2]
   adc  cx,es:[di+4]
   sbb  cx,ax
   sbb  ax,es:[di+6]
   sub  ax,dx
   sub  dx,ax
   ror  cx,cl
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   add  ax,es:[di]
   adc  dx,es:[di+2]
   sbb  cx,bx
   add  ax,cx
   shl  dx,1
   sbb  dx,es:[di+4]
   add  dx,ax
   ror  dx,cl
   xor  dx,cx
   sub  dx,es:[di+6]
   sbb  ax,dx
   adc  ax,dx
   add  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash29(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax29
   mov  cx, cx29
   mov  dx, dx29
   clc
@cicle:
   adc  cx,dx
   xor  ax,es:[di]
   add  cx,es:[di+2]
   rol  cx,cl
   sub  dx,es:[di+4]
   add  ax,dx
   sub  dx,es:[di+6]
   sbb  ax,bx
   ror  ax,cl
   sbb  cx,dx
   rol  cx,cl
   add  dx,ax
   ror  dx,cl
   add  ax,cx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  dx,cx
   rcl  dx,cl
   xor  cx,dx
   adc  dx,ax
   sub  ax,es:[di]
   and  dx,es:[di+2]
   add  dx,bx
   adc  cx,dx
   xor  cx,dx
   xor  dx,cx
   sub  cx,es:[di+4]
   rol  cx,cl
   xor  ax,es:[di+6]
   xor  dx,ax
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  ax,cx
end;

function hash30(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax30
   mov  cx, cx30
   mov  dx, dx30
   clc
@cicle:
   shl  ax,1
   sbb  ax,es:[di]
   adc  ax,bx
   sub  cx,ax
   rcl  ax,cl
   add  dx,cx
   adc  ax,dx
   rol  ax,cl
   xor  dx,es:[di+2]
   ror  cx,cl
   sub  ax,es:[di+4]
   sbb  cx,ax
   adc  cx,dx
   adc  dx,es:[di+6]
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   and  ax,es:[di]
   rol  dx,cl
   shr  cx,1
   sbb  ax,cx
   shl  cx,1
   or   cx,es:[di+2]
   sbb  dx,ax
   add  dx,cx
   adc  cx,bx
   adc  ax,es:[di+4]
   xor  cx,ax
   adc  dx,es:[di+6]
   sbb  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle2
end;

function hash31(var source;num8s:word):longInt;assembler;
asm
   les  di, source
   mov  bx, num8s
   mov  ax, ax31
   mov  cx, cx31
   mov  dx, dx31
   clc
@cicle:
   sbb  dx,es:[di]
   xor  cx,ax
   ror  dx,cl
   adc  dx,cx
   xor  ax,bx
   sub  ax,dx
   add  ax,es:[di+2]
   sub  dx,es:[di+4]
   sbb  dx,ax
   rcl  ax,cl
   adc  cx,es:[di+6]
   adc  dx,ax
   add  cx,dx
   add  di, 8
   dec  bx
   jnz  @cicle
   les  di, source
   mov  bx, backCicles
@cicle2:
   sbb  cx,es:[di]
   adc  cx,bx
   sbb  cx,es:[di+2]
   rol  dx,cl
   shr  cx,1
   sub  cx,ax
   sub  ax,dx
   sbb  dx,cx
   add  ax,es:[di+4]
   or   dx,es:[di+6]
   shr  cx,1
   adc  dx,cx
   xor  dx,cx
   sbb  dx,cx
   add  di, 8
   dec  bx
   jnz  @cicle2
   mov  dx,cx
end;

function hash(var source;num8s:word):longInt;
{ this is an improved hash function that can be used for any purpose }
var oax,ocx,odx:word;
   h:longInt;
begin
   oax:=ax21; ax21:=0; ocx:=cx21; cx21:=0; odx:=dx21; dx21:=0;
   h:=hash21(source,num8s);
   ax21:=oax; cx21:=ocx; dx21:=odx;
   oax:=ax30; ax30:=0; ocx:=cx30; cx30:=0; odx:=dx30; dx30:=0;
   hash:=h xor hash30(source,num8s);
   ax30:=oax; cx30:=ocx; dx30:=odx;
end;

function hashX(var source;num8s:word):longInt;
{ this is another improved hash function that can be used for any purpose }
var oax,ocx,odx:word;
   h:longInt;
begin
   oax:=ax5; ax5:=0; ocx:=cx5; cx5:=0; odx:=dx5; dx5:=0;
   h:=hash5(source,num8s);
   ax5:=oax; cx5:=ocx; dx5:=odx;
   oax:=ax25; ax25:=0; ocx:=cx25; cx25:=0; odx:=dx25; dx25:=0;
   hashX:=h xor hash25(source,num8s);
   ax25:=oax; cx25:=ocx; dx25:=odx;
end;

function hashStrong(var source;num8s:word):longInt;
{ this is a stronger hash }
begin
   hashStrong:=hash21(source,num8s) xor hash30(source,num8s);
end;

function getbits(var where;var fromBit:word;numBits:Byte):word;
{ returns "numBits" bits reading from "fromBit" onward }
const
   pot2:array[1..16] of word=
      (1,3,7,$F,$1F,$3F,$7F,$FF,$1FF,$3FF,$7FF,$FFF,$1FFF,$3FFF,$7FFF,$FFFF);
var v:array[0..10000] of byte absolute where;
   pLi:^longInt;
   w:word;
begin
   pLi:=addr(v[fromBit shr 3]);
   w:=(pLi^ shr (fromBit and $7)) and pot2[numBits];
   getbits:=w;
   inc(fromBit,numBits);
end;

procedure GSscramble(keyS:tScrambleKey;var where;size:word;level:word;var err:word);
{ main scramble functionm }
type
   tVecLIs=array[0..maxSizeEncry div 4 - 1] of longInt;
   tVecWords=array[0..maxSizeEncry div 2 - 1] of word;

procedure scramble6(var v:tVecLIs);
{ smears data 8 bytes to the left using addition of longInts }
var i:word;
begin
{$ifNdef useAsm}
   for i:=0 to lastLI-2 do
      v[i]:=v[i]+v[i+1]+v[i+2];
{$else}
   asm
      mov  cx, lastLI
      dec  cx
      les  di, v
   @cicle:
      mov  ax, es:[di+4]
      mov  dx, es:[di+6]
      add  ax, es:[di+8]
      adc  dx, es:[di+10]
      add  es:[di], ax
      adc  es:[di+2], dx
      add  di, 4
      dec  cx
      jnz  @cicle
   end;
{$endIf}
end;

procedure scramble5(var vw:tVecWords);
{ smears data 8 bytes to the left using xors and ors of words }
var i:word;
begin
{$ifNdef useAsm}
   for i:=0 to lastW-4 do
      vw[i]:=vw[i] xor (vw[i+2] or vw[i+4]);
{$else}
   asm
      les  di, vw
      mov  ax, es:[di]
      mov  bx, es:[di+4]
      mov  cx, lastW
      sub  cx, 3
      mov  dx, es:[di+6]
      mov  si, es:[di+8]
   @cicle:
      mov  ax, si
      or   ax, bx
      xor  es:[di], ax
      mov  bx, dx
      mov  dx, si
      add  di, 2
      mov  si, es:[di+8]
      dec  cx
      jnz  @cicle
   end;
{$endIf}
end;

procedure scramble4(h:longInt;var v:tVecLIs);
{ uses 24 bits of h in order to choose three positions in the text;
  xors the values of these three positions with h;
  hashes the entire text with the result }
var i:word;
  s1,s2,s3:byte;
  hh:longInt;
begin
   s1:=((h and $FF000000) shr 24) and lastLI;
   s2:=((h and $00FF0000) shr 16) and lastLI;
   s3:=((h and $0000FF00) shr 8) and lastLI;
   hh:=h xor v[s1] xor v[s2] xor v[s3];
{$ifNdef useAsm}
   for i:=0 to lastLI do v[i]:=v[i] xor hh;
{$else}
   asm
      les  di, v
      mov  ax, word ptr hh
      mov  bx, word ptr hh+2
      mov  cx, lastLI
      inc  cx
      shr  cx, 1
   @cicle:
      xor  es:[di],ax
      xor  es:[di+2],bx
      xor  es:[di+4],ax
      xor  es:[di+6],bx
      add  di, 8
      dec  cx
      jnz  @cicle
   end;
{$endIf}
end;

procedure scramble3(h:longInt;var vw:tVecWords);
{ uses 3 bits of h in order to define a number between 1 and 8;
  regarding the text as a list of bits, it then circularly rotates
  the entire text as many bits to the right }
var i,ovr0:word;
   sh1,sh2:byte;
   mask:word;
begin
   sh1:=(h and $00000700) shr 8;
   sh1:=sh1 + 1; { 1..8 }
   sh2:=16 - sh1;
   mask:=(1 shl sh1) - 1;
   ovr0:=vw[0];
{$ifNdef useAsm}
   for i:=0 to lastW-1 do
      vw[i]:=(vw[i] shr sh1) or ((vw[i+1] and mask) shl sh2);
{$else}
   asm
      les  di, vw
      mov  ch, byte ptr lastW
      mov  dl, sh1
      mov  dh, sh2
      mov  si, word ptr es:[di]
   @cicle:
      mov  ax, si
      mov  bx, word ptr es:[di+2]
      mov  si, bx
      mov  cl, dh
      shl  bx, cl
      mov  cl, dl
      shr  ax, cl
      or   ax, bx
      mov  word ptr es:[di],ax
      add  di,2
      dec  ch
      jnz  @cicle
   end;
{$endIf};
   vw[lastW]:=(vw[lastW] shr sh1) or ((ovr0 and mask) shl sh2);
end;

procedure scramble2(h:longInt;var vw:tVecWords;c2a,c2m,c2n:word;c2b:longInt);
{ uses 24 bits of h to choose 4 positions in the text;
  combines the values in these positions with 70 bits of the scramble-key
  in order to produce the 4 constants of a tipical pseudo-random
  number generator;
  then uses this generator to define how many bits each word of
  the text gets circularly rotated to the right }
var v:tVecLIs absolute vw;
   num,i:word;
   s1,s2,s3,s4:byte;
   a,n,m,iw:word;
   b:longInt;
   sh1,sh2:byte;
begin
   s1:=((h and $FC000000) shr 26) and lastLI;
   s2:=((h and $03F00000) shr 20) and lastLI;
   s3:=((h and $000FC000) shr 14) and lastLI;
   s4:=((h and $00003F00) shr 8) and lastLI;
   a:=(c2a xor v[s1]) and $000007FF;     {11 bits}
   b:=(c2b xor v[s2]) and $07FFFFFF;     {27 bits}
   m:=(c2m xor v[s3]) and $0000FFFF;     {16 bits}
   n:=(c2n xor v[s4]) and $0000FFFF;     {16 bits}

   if m<30000 then
      m:=m+30000; { avoid overflow in div }
   { improve the quality of the generator }
   m:=m or 1;
   while (m mod 3=0) or (m mod 5=0) or (m mod 7=0) or (m mod 11=0)
         or (m mod 13=0) or (m mod 17=0) or (m mod 19=0)
         or (m mod 23=0) or (m mod 29=0) or (m mod 31=0)
   do dec(m,2);

   num:=vw[n and $7F];
{$ifNdef useAsm}
   for i:=0 to (lastW+1) div 4 - 1 do { process 4 words at a time }
   begin
      n:=(longInt(a)*n+b) mod m;
      iw:=4*i;
      sh1:=n and $000F; sh2:=16-sh1;
      vw[iw]:=(vw[iw] shr sh1) or (vw[iw] shl sh2);
      inc(iw);
      sh1:=(n and $0F00) shr 8; sh2:=16-sh1;
      vw[iw]:=(vw[iw] shr sh1) or (vw[iw] shl sh2);
      inc(iw);
      sh1:=(n and $00F0) shr 4; sh2:=16-sh1;
      vw[iw]:=(vw[iw] shr sh1) or (vw[iw] shl sh2);
      inc(iw);
      sh1:=(n and $F000) shr 12; sh2:=16-sh1;
      vw[iw]:=(vw[iw] shr sh1) or (vw[iw] shl sh2);
   end;
{$else}
   asm
      les  di, vw
      mov  cx, lastW
      inc  cx
      shr  cx, 1
      shr  cx, 1
      mov  ch, cl
      mov  bx, m
      mov  dx, n
   @cicle:
      mov  ax, a
      mul  dx
      add  ax, word ptr b
      adc  dx, word ptr b+2
      div  bx { now dx = n }
      mov  ax, dx

      mov  cl, al
      ror  word ptr es:[di], cl
      mov  cl, ah
      ror  word ptr es:[di+2], cl
      mov  cl, 4
      shr  ax, cl
      mov  cl, al
      ror  word ptr es:[di+4], cl
      mov  cl, ah
      ror  word ptr es:[di+6], cl
      add  di, 8

      dec  ch
      jnz  @cicle;
   end;
{$endIf}
end;

procedure scramble1(h:longInt;var vw:tVecWords;c1a,c1m,c1n,c1v:word;c1b:longInt);
{ uses 24 bits of h in order to choose 4 positions in the text;
  combines the values in these positions with 70 bits of the
  28 byte long scramble-key to produce the 4 constants of a
  tipical pseudo-random number generator;
  it uses 4 more bits of the scrambler key and combines it with the text
  to define number of iterations;
  it uses the generator to substitute words of the text in a circular
  manner }
var v:tVecLIs absolute vw;
   num,i,times:word;
   s1,s2,s3,s4:byte;
   a,n,m,vn:word;
   b:longInt;
begin
   s1:=((h and $FC000000) shr 26) and lastLI;
   s2:=((h and $03F00000) shr 20) and lastLI;
   s3:=((h and $000FC000) shr 14) and lastLI;
   s4:=((h and $00003F00) shr 8) and lastLI;
   a:=(c1a xor v[s1]) and $000007FF;     {11 bits}
   b:=(c1b xor v[s2]) and $07FFFFFF;     {27 bits}
   m:=(c1m xor v[s3]) and $0000FFFF;     {16 bits}
   n:=(c1n xor v[s4]) and $0000FFFF;     {16 bits}
   times:=(c1v xor (v[s4] and $000F0000) shr 16);
   times:=(lastW+1) div 4 + times; { define a reasonable number of cicles }

   if m<30000 then
      m:=m+30000; { avoid overflow in div }
   { improve the quality of the generator }
   m:=m or 1;
   while (m mod 3=0) or (m mod 5=0) or (m mod 7=0) or (m mod 11=0)
         or (m mod 13=0) or (m mod 17=0) or (m mod 19=0)
         or (m mod 23=0) or (m mod 29=0) or (m mod 31=0)
   do dec(m,2);

   num:=vw[n and lastW];
{$ifNdef useAsm}
   vn:=n;
   for i:=1 to times do
   begin
      n:=(longInt(a)*n+b) mod m;
      vw[vn and lastW]:=vw[n and lastW];
      vn:=n;
   end;
{$else}
   asm
      mov  dx, n  { dx == n }
      mov  si, dx
      and  si, lastW
      shl  si, 1  { si == vn and lastW }
      mov  cx, times
      les  di, vw

@cicle:
      mov  ax, a
      mul  dx
      add  ax, word ptr b
      adc  dx, word ptr b+2
      mov  bx, m
      div  bx

      mov  bx, dx
      and  bx, lastW
      shl  bx, 1
      mov  ax, word ptr es:[di+bx]
      xchg bx, si
      mov  word ptr es:[di+bx], ax

      dec  cx
      jnz  @cicle

      mov  n, dx
   end;
{$endIf}
   vw[n and lastW]:=num;
end;

procedure scramble0(h:longInt;var vw:tVecWords;c0a,c0m,c0n:word;c0b:longInt);
{ uses 24 bits of h in order to choose 4 positions in the text;
  combines the values in these positions with 70 bits of the scramble-key
  in order to produce the 4 constants of a tipical pseudo-random
  number generator;
  then it xors all words of the text with "random" words produced with
  the generator }
var v:tVecLIs absolute vw;
   i:word;
   s1,s2,s3,s4:byte;
   a,n,m:word;
   b:longInt;
begin
   s1:=((h and $FC000000) shr 26) and lastLI;
   s2:=((h and $03F00000) shr 20) and lastLI;
   s3:=((h and $000FC000) shr 14) and lastLI;
   s4:=((h and $00003F00) shr 8) and lastLI;
   a:=(c0a xor v[s1]) and $000007FF;      {11 bits}
   b:=(c0b xor v[s2]) and $07FFFFFF;      {27 bits}
   m:=(c0m xor v[s3]) and $0000FFFF;      {16 bits}
   n:=(c0n xor v[s4]) and $0000FFFF;      {16 bits}

   if m<30000 then
      m:=m+30000; { avoid overflow in div }
   { improve the quality of the generator }
   m:=m or 1;
   while (m mod 3=0) or (m mod 5=0) or (m mod 7=0) or (m mod 11=0)
         or (m mod 13=0) or (m mod 17=0) or (m mod 19=0)
         or (m mod 23=0) or (m mod 29=0) or (m mod 31=0)
   do dec(m,2);

{$ifNdef useAsm}
   for i:=0 to lastW do
   begin
      n:=(longInt(a)*n+b) mod m;
      vw[i]:=vw[i] xor n;
   end;
{$else}
   asm
      les  di, vw
      mov  cx, lastW
      inc  cx
      mov  bx, m
      mov  dx, n
   @cicle:
      mov  ax, a
      mul  dx
      add  ax, word ptr b
      adc  dx, word ptr b+2
      div  bx

      xor  es:[di], dx
      add  di,2
      dec  cx
      jnz  @cicle;
   end;
{$endIf}
end;

procedure scrambleInit(h:longInt;var v:tVecLIs);
var buf:array[0..$FFF0] of byte absolute v;
   iBuf,lastB,posi:word;
   b2bLi:array[0..63] of longInt;
   b2b:array[byte] of byte absolute b2bLi;
begin
   move(b2bInit,b2b,sizeOf(b2bInit));
   for iBuf:=0 to 63 do b2bLi[iBuf]:=b2bLi[iBuf] xor h;

   lastB:=2*lastW+1;
   for iBuf:=1 to lastB do
   begin
      buf[iBuf]:=buf[iBuf] xor b2b[buf[iBuf-1]];
      b2b[iBuf and $FF]:=b2b[iBuf and $FF] xor buf[iBuf];
   end;
end;

procedure initConstants(
   var cCo:byte;
   var c0a,c1a,c2a:word;
   var c0b,c1b,c2b:longInt;
   var c0m,c1m,c2m:word;
   var c0n,c1n,c2n,c1v:word;
   var cInit:longInt);
var fromBit:word;
   hA,hB,hC:longInt;
   key:array[0..15] of longInt absolute keyS;
begin
   { randomize key so that every bit becomes significant}
   hA:=hashA(key,8); key[0]:=key[0] xor hA;
   hB:=hashB(key,8); key[2]:=key[2] xor hB;
   hC:=hashC(key,8); key[4]:=key[4] xor hC;
   key[6]:=key[6] xor hA;
   key[8]:=key[8] xor hB;
   key[10]:=key[10] xor hC;

   fromBit:=0;
   cCo:=getBits(keyS,fromBit,8);

   c0a:=getBits(keyS,fromBit,11);
   c0m:=getBits(keyS,fromBit,8);
   c0b:=getBits(keyS,fromBit,16);
      c0b:=c0b or (longInt(getBits(keyS,fromBit,11)) shl 16);
   c0m:=c0m or (getBits(keyS,fromBit,8) shl 8); { garantees that a,m,b<>0 }
   c0n:=getBits(keyS,fromBit,16);

   c1a:=getBits(keyS,fromBit,11);
   c1m:=getBits(keyS,fromBit,16);
   c1b:=getBits(keyS,fromBit,16);
      c1b:=c1b or (longInt(getBits(keyS,fromBit,11)) shl 16);
   c1n:=getBits(keyS,fromBit,16);

   c2a:=getBits(keyS,fromBit,11);
   c2m:=getBits(keyS,fromBit,16);
   c2b:=getBits(keyS,fromBit,16);
      c2b:=c2b or (longInt(getBits(keyS,fromBit,11)) shl 16);
   c2n:=getBits(keyS,fromBit,16);

   c1v:=getBits(keyS,fromBit,4);

   cInit:=getBits(keyS,fromBit,16);
      cInit:=cInit or (longInt(getBits(keyS,fromBit,16)) shl 16);
end;

var
   v:tVecLIs absolute where; { v and vw point to the buffer being scrambled }
   vw:tVecWords absolute where;
   scras:array[0..numScrambles-1] of word; { scramblers that have been used }
   fromBit:word; { indexes the second half of scrambler key }
   whichHa:byte; { next hash function to be used }
   h:longInt;    { result of the hash function }
   oldScra,whichScra:byte; { old and next primitive scrambler to be used }
   iteration,half,num8s,min:word;

   { the following variables are parameters for the primitive scramblers }
   cCo:byte;
   c0a,c1a,c2a:word;
   c0b,c1b,c2b:longInt;
   c0m,c1m,c2m:word;
   c0n,c1n,c2n,c1v:word;
   cInit:longInt;
begin { GSscramble }
   err:=0;
   if (size<32)or(size>maxSizeEncry)or(size mod 8<>0) then
   { size must be greater or equal to 32 and a multiple of 8 }
   begin err:=1; exit;
   end;

   if level>=20 then min:=3 else if level>=10 then min:=2 else min:=1;
   inc(level,5); { don't allow levels that are too low or too large }
   if level>100 then level:=100;

   lastW:=size div 2 - 1;
   lastLI:=size div 4 - 1;
   num8s:=size div 8;

   initConstants
      (cCo,c0a,c1a,c2a,c0b,c1b,c2b,c0m,c1m,c2m,c0n,c1n,c2n,c1v,cInit);

   { do an initial scrambling }
   h:=hashH(where,num8s); scramble0(h,vw,c0a,c0m,c0n,c0b);
   h:=hashI(where,num8s); scramble0(h,vw,c0a,c0m,c0n,c0b);
   h:=hashJ(where,num8s); scrambleInit(h xor cInit,v);

   { start recording which primitive scramblers have been used }
   fillchar(scras,sizeOf(scras),0);

   half:=level div 2;
   fromBit:=0;
   oldScra:=6;
   iteration:=1;
   while iteration<=level do { main loop }
   begin
      { choose a hash function depending on the key ... }
      if fromBit>250 then fromBit:=h and $F;
      whichHa:=getbits(keyS[32],fromBit,5);
      { ... and also, sometimes, on the contents of the buffer }
      if not odd(iteration) then
         whichHa:=whichHa xor (h and $1F);
      { apply this hash function on the entire buffer and compute next h }
      h:=hashs[whichHa](where,num8s) xor iteration;

      { half way through compute total number of iterations }
      if iteration=half then
         level:=level + ((h and $0FFFF000) shr 12) mod (level+1);

      { compute next primitive scrambler to be used }
      whichScra:=((h and $FF) xor cCo) mod numScrambles;
      if whichScra=oldScra then { try not to use the same scrambler in a row }
         whichScra:=((h and $FF0) shr 4) mod numScrambles;
      oldScra:=whichScra;
      inc(scras[whichScra]); { record scrambler }

      case whichScra of
         0:scramble0(h,vw,c0a,c0m,c0n,c0b);
         1:scramble1(h,vw,c1a,c1m,c1n,c1v,c1b);
         2:scramble2(h,vw,c2a,c2m,c2n,c2b);
         3:scramble3(h,vw);
         4:scramble4(h,v);
         5:scramble5(vw);
         6:scramble6(v);
      end;
      inc(iteration);
   end;

   { make certain that each primitive scrambler is used "min" times }
   whichScra:=0;
   while (scras[0]<min)or(scras[1]<min)or(scras[2]<min)or(scras[3]<min)or
         (scras[4]<min)or(scras[5]<min)or(scras[6]<min) do
   begin
      repeat
         if h=0 then
            whichScra:=(whichScra+1) mod numScrambles
         else
            begin whichScra:=h and 7; h:=h shr 3;
            end
      until (whichScra<numScrambles)and(scras[whichScra]<min);
      h:=hashs[whichScra](where,num8s);
      inc(scras[whichScra]);
{write(chr(65+whichScra));}
      case whichScra of
         0:scramble0(h,vw,c0a,c0m,c0n,c0b);
         1:scramble1(h,vw,c1a,c1m,c1n,c1v,c1b);
         2:scramble2(h,vw,c2a,c2m,c2n,c2b);
         3:scramble3(h,vw);
         4:scramble4(h,v);
         5:scramble5(vw);
         6:scramble6(v);
      end;
   end;
end; { GSscramble }

procedure condense(var buffer;size:byte);
{ condense the 32 bytes of the buffer into "size" bytes.
  size may be 8,16, or 24 }
var buf:array[0..31] of byte absolute buffer;
   i,j:word;
begin j:=0;
   for i:=size to 31 do
   begin
      case i mod 3 of
         0: buf[j mod size]:=byte(buf[j mod size] xor buf[i]);
         1: buf[j mod size]:=byte(buf[j mod size] + buf[i]);
         2: buf[j mod size]:=byte(buf[j mod size] - buf[i]);
      end;
      inc(j);
   end;
end;

{ basic encryption procedure }
procedure encrypt0(var where;size:word;var key:tCryptoKey);
type tVectorB=array[0..$FFF0] of byte;
var
   text:array[0..maxSizeEncry-1] of byte absolute where;
   textw:array[0..maxSizeEncry div 2 -1] of word absolute where;
   buffer:array[0..(maxSizeEncry div 2)-1] of byte;
   text1,text2:^tVectorB;
   keyS1,keyS2:^tScrambleKey;
   key1,key2:^tVectorB;
   i,half4,halfSize,mask2,minSize,err:word;
begin
   { modify first half by XORing second half }
   half4:=size div 4;
   for i:=0 to half4-1 do textw[i]:=textw[i] xor textw[i+half4];

   halfSize:=size div 2;
   minSize:=halfSize; if minSize<32 then minSize:=32;
   mask2:=halfSize-1; if mask2<31 then mask2:=31;
   text1:=addr(text);text2:=addr(text[halfSize]);
   keyS1:=addr(key[0]);keyS2:=addr(key[64]);
   key1:=addr(key[128]);key2:=addr(key[192]);

   { S1( K1,T1) xor T2 -> C2 }
   move(text1^,buffer,halfSize);
   if halfSize<32 then fillchar(buffer[halfSize],32-halfSize,0);
   for i:=0 to 63 do buffer[i and mask2]:=buffer[i and mask2] xor key1^[i];
   GSscramble(keyS1^,buffer,minSize,levelEncr,err);
   if halfSize<32 then { condense into halfSize bytes }
   begin condense(buffer,halfSize);
      fillchar(buffer[halfSize],32-halfSize,0);
   end;
   for i:=0 to halfSize-1 do buffer[i]:=buffer[i] xor text2^[i];
   move(buffer,text2^,halfSize);

   { S2( K2,C2) xor T1 -> C1 }
   for i:=0 to 63 do buffer[i and mask2]:=buffer[i and mask2] xor key2^[i];
   GSscramble(keyS2^,buffer,minSize,levelEncr,err);
   if halfSize<32 then { condense into halfSize bytes }
      condense(buffer,halfSize);
   for i:=0 to halfSize-1 do buffer[i]:=buffer[i] xor text1^[i];
   move(buffer,text1^,halfSize);
end;

{ basic decryption procedure }
procedure decrypt0(var where;size:word;var key:tCryptoKey);
type tVectorB=array[0..$FFF0] of byte;
var
   text:array[0..maxSizeEncry-1] of byte absolute where;
   textw:array[0..maxSizeEncry div 2 -1] of word absolute where;
   buffer:array[0..(maxSizeEncry div 2)-1] of byte;
   text1,text2:^tVectorB;
   keyS1,keyS2:^tScrambleKey;
   key1,key2:^tVectorB;
   i,half4,halfSize,mask2,minSize,err:word;
begin
   halfSize:=size div 2;
   minSize:=halfSize; if minSize<32 then minSize:=32;
   mask2:=halfSize-1; if mask2<31 then mask2:=31;
   text1:=addr(text);text2:=addr(text[halfSize]);
   keyS1:=addr(key[0]);keyS2:=addr(key[64]);
   key1:=addr(key[128]);key2:=addr(key[192]);

   { S2( K2,C2) xor C1 -> T1 }
   fillchar(buffer,32,0); move(text2^,buffer,halfSize);
   for i:=0 to 63 do buffer[i and mask2]:=buffer[i and mask2] xor key2^[i];
   GSscramble(keyS2^,buffer,minSize,levelEncr,err);
   if halfSize<32 then { condense into halfSize bytes }
   begin condense(buffer,halfSize);
      fillchar(buffer[halfSize],32-halfSize,0);
   end;
   for i:=0 to halfSize-1 do buffer[i]:=buffer[i] xor text1^[i];
   move(buffer,text1^,halfSize);

   { H1( K1,T1) xor C2 -> T2 }
   for i:=0 to 63 do buffer[i and mask2]:=buffer[i and mask2] xor key1^[i];
   GSscramble(keyS1^,buffer,minSize,levelEncr,err);
   if halfSize<32 then { condense into halfSize bytes }
      condense(buffer,halfSize);
   for i:=0 to halfSize-1 do buffer[i]:=buffer[i] xor text2^[i];
   move(buffer,text2^,halfSize);

   { modify first half by XORing second half }
   half4:=size div 4;
   for i:=0 to half4-1 do textw[i]:=textw[i] xor textw[i+half4];

end;

procedure doRandomizeKey(var key:tCryptoKey;var randVector;posi:byte);
{ randomize key using 16 random bytes of randVector }
var randV:array[0..15] of byte absolute randVector;
   keyS:tScrambleKey;
   err:word;
begin
   move(randV[0],key,8);              { create new encryption key }
   keyS:=keyS1;
   move(randV[8],keyS[posi],8);       { modify scrambler key }
   GSscramble(keyS,key,256,levelRKey,err); { scramble new encryption key }
end;

procedure doRandomizeText(var where; size:word; var key:tCryptoKey; var randVector);
{ randomize buffer of size bytes, using the 16 random bytes of randVector }
{ this is a symmetrical procedure; used it to recover the original text }
var text:array[0..maxSizeEncry div 4] of longInt absolute where;
   randV:array[0..15] of byte absolute randVector;
   randomText:array[0..maxSizeEncry div 4] of longInt;
   keyS:tScrambleKey;
   i,size2,err:word;
begin
   size2:=size; if size2<32 then size2:=32; { min. scramble size }

   fillchar(randomText,size2,0); { now create a random seed of 24 bytes }
   randomText[0]:=hashD(key,8);
   randomText[1]:=hashE(key,8);
   randomText[2]:=hashF(key,8);
   randomText[3]:=hashG(key,8);
   move(randV[0],randomText[4],8);
   keyS:=keyS2;
   move(randV[8],keyS[56],8); { randomize scrambler key }
   GSscramble(keyS,randomText,size2,levelRtext,err); { create random string }
   for i:=0 to (size div 4)-1 do
      text[i]:=text[i] xor randomText[i];
end;

procedure separateHalves(var where; var size:word; var how:tHowRearrange);
{ neutralizes weekness in Karn's algorithm by rearranging the text and
  modifying the text in a way unknown to an attacker:
  It rearranges "size" bytes of buffer in two halves depending of the bit
  values of "how": If the next bit of "how" is 1 then it puts the next
  byte of the buffer in the first half, otherwise it puts it in the
  second half.
  This procedure can be modified to produce a non standard version of GodSave}
label fin;
var
   buf:array[0..maxSizeEncry-1] of byte absolute where;
   firstHalf,lastHalf:array[0..maxSizeEncry div 2 -1] of byte;
   i,j,ivs,sep,iFirst,iLast,half:word;
begin
   half:=size div 2;
   iFirst:=0; iLast:=0;
   ivs:=0;
   for i:=0 to size-1 do
   begin
      if i mod 16=0 then
      begin inc(ivs); sep:=how[ivs];
      end;
      if sep and 1<>0 then
         begin firstHalf[iFirst]:=buf[i] xor scrSep[(i+iFirst) mod 64];
            inc(iFirst)
         end
      else
         begin lastHalf[iLast]:=buf[i] xor scrSep[(i+iLast) mod 64];
            inc(iLast)
         end;
      sep:=sep shr 1;
      if iFirst=half then (* fill out lastHalf *)
      begin
         for j:=1 to half-iLast do lastHalf[iLast+j-1]:=
                                   buf[i+j] xor scrSep[j mod 64];
         goto fin;
      end;
      if iLast=half then (* fill out firstHalf *)
      begin
         for j:=1 to half-iFirst do firstHalf[iFirst+j-1]:=
                                    buf[i+j] xor scrSep[j mod 64];
         goto fin;
      end;
   end;
fin:
   move(firstHalf,buf,half);
   move(lastHalf,buf[half],half);
end;

procedure uniteHalves(var where; var size:word; var how:tHowRearrange);
{ reverses effect of "separateHalves" }
var
   buf:array[0..maxSizeEncry-1] of byte absolute where;
   i,j,ivs,sep,iFirst,iLast,half:word;
   firstHalf,lastHalf:array[0..maxSizeEncry div 2 -1] of byte;
begin
   half:=size div 2;
   iFirst:=0; iLast:=0;
   move(buf,firstHalf,half);
   move(buf[half],lastHalf,half);
   ivs:=0;
   for i:=0 to size-1 do
   begin
      if i mod 16=0 then
      begin inc(ivs); sep:=how[ivs];
      end;
      if odd(sep) then
         begin buf[i]:=firstHalf[iFirst] xor scrSep[(i+iFirst) mod 64];
            inc(iFirst)
         end
      else
         begin buf[i]:=lastHalf[iLast] xor scrSep[(i+iLast) mod 64];
            inc(iLast)
         end;
      sep:=sep shr 1;
      if iFirst=half then (* fill out lastHalf *)
      begin
         for j:=1 to half-iLast do buf[i+j]:=lastHalf[iLast+j-1]
                                             xor scrSep[j mod 64];
         exit;
      end;
      if iLast=half then (* fill out firstHalf *)
      begin
         for j:=1 to half-iFirst do buf[i+j]:=firstHalf[iFirst+j-1]
                                              xor scrSep[j mod 64];
         exit;
      end;
   end;
end;

procedure createRand(var where;num:word);
var w:array[0..$FFF0] of byte absolute where;
   i:word;
begin for i:=0 to num-1 do w[i]:=getRandomByte;
end;

procedure encrypt16(var keySi:tSimpleKey;var where);
{ simple encryption algorithm that works on 16 byte blocks;
  uses Karn's method; as a hash function it simply applies
  2 of the 32 simple hash functions }
var cipher:array[0..3] of longInt absolute where;
   key:array[0..7] of longInt absolute keySi;
   buf:array[0..7] of longInt;
   whichHa:longInt;
begin
   cipher[0]:=cipher[0] xor cipher[2];
   cipher[1]:=cipher[1] xor cipher[3];

   move(key[4],buf[4],16);

   whichHa:=key[0];
   buf[0]:=key[0]; buf[1]:=key[1];
   buf[2]:=cipher[0];  buf[3]:=cipher[1];
   cipher[2]:=hashs[whichHa and $1F](buf,4) xor cipher[2]; whichHa:=whichHa shr 5;
   cipher[3]:=hashs[whichHa and $1F](buf,4) xor cipher[3];

   whichHa:=key[1];
   buf[0]:=key[2]; buf[1]:=key[3];
   buf[2]:=cipher[2];  buf[3]:=cipher[3];
   cipher[0]:=hashs[whichHa and $1F](buf,4) xor cipher[0]; whichHa:=whichHa shr 5;
   cipher[1]:=hashs[whichHa and $1F](buf,4) xor cipher[1];
end;

procedure decrypt16(var keySi:tSimpleKey;var where);
{ simple decryption algorithm that works on 16 byte blocks;
  inverts crypt16 }
var text:array[0..3] of longInt absolute where;
   key:array[0..7] of longInt absolute keySi;
   buf:array[0..7] of longInt;
   whichHa:longInt;
begin
   move(key[4],buf[4],16);

   whichHa:=key[1];
   buf[0]:=key[2]; buf[1]:=key[3];
   buf[2]:=text[2];    buf[3]:=text[3];
   text[0]:=hashs[whichHa and $1F](buf,4) xor text[0]; whichHa:=whichHa shr 5;
   text[1]:=hashs[whichHa and $1F](buf,4) xor text[1];

   whichHa:=key[0];
   buf[0]:=key[0]; buf[1]:=key[1];
   buf[2]:=text[0];    buf[3]:=text[1];
   text[2]:=hashs[whichHa and $1F](buf,4) xor text[2]; whichHa:=whichHa shr 5;
   text[3]:=hashs[whichHa and $1F](buf,4) xor text[3];

   text[0]:=text[0] xor text[2];
   text[1]:=text[1] xor text[3];
end;

{ main encryption procedure }
procedure GSencrypt(var where;sizeText:word;var sizeCipher:word;var err:word);
var text:array[0..maxSizeEncry+31] of byte absolute where;
   numRounds:byte;        { number of rounds 2, 4, 6 or 8 }
   randomizeKey:boolean;  { do randomize key }
   randomizeText:boolean; { do randomize text }
   lazy:boolean;          { do lazy encryption }
   key1,key2,key3,key4:tCryptoKey; { encryption keys for 2,4,6 and 8 rounds}
   rand16:array[0..15] of byte;
begin
   { process "encryptionStyle" }
   randomizeKey:= (encryStyle and withKeyRandom)<>0;
   randomizeText:=(encryStyle and withTextRandom)<>0;
   numRounds:=    ( (encryStyle and withNumRounds) shr 2 )*2 + 2;
   lazy:=         (encryStyle and withLazyEncry)<>0;

   err:=0;
   if (sizeText<16)or(sizeText>maxSizeEncry)or(sizeText mod 16<>0) or
      lazy and (sizeText>maxSizeEncry div 2)
   then
   { sizeText must be greater or equal to 16 and a multiple of of 16;
     when using lazy encryption, size must be less then 512 }
   begin err:=1; exit
   end;

   if lazy then
   begin
      createRand(text[sizeText],sizeText);
      sizeText:=sizeText+sizeText;
   end;

   sizeCipher:=sizeText;

   key1:=keyEncry;
   key2:=keyEncry2;
   key3:=keyEncry3;
   key4:=keyEncry4;

   if randomizeKey then
   begin { create 16 random bytes, and use them to randomize the key }
      createRand(rand16,16);
      doRandomizeKey(key1,rand16,56); { compute randomized keys }
      if numRounds>=4 then doRandomizeKey(key2,rand16,48);
      if numRounds>=6 then doRandomizeKey(key3,rand16,40);
      if numRounds=8 then doRandomizeKey(key4,rand16,32);
      { encrypt these 16 random bytes and save them in the ciphertext }
      encrypt16(keySi,rand16);
      move(rand16,text[sizeText],16);
      inc(sizeCipher,16);
   end;

   if randomizeText then
   begin { create 16 random bytes, and use them to randomize the plaintext }
      createRand(rand16,16);
      doRandomizeText(text,sizeText,key1,rand16);
      { encrypt these 16 random bytes and save them in the ciphertext }
      encrypt16(keySi,rand16);
      move(rand16,text[sizeCipher],16);
      inc(sizeCipher,16);
   end;

   if not lazy { rearrange text }
      then separateHalves(text,sizeText,howSeparate);

   encrypt0(where,sizeText,key1);
   if numRounds>=4 then encrypt0(where,sizeText,key2);
   if numRounds>=6 then encrypt0(where,sizeText,key3);
   if numRounds=8 then encrypt0(where,sizeText,key4);

   if not lazy { rearrange text }
      then uniteHalves(text,sizeText,howUnite);
end;

{ main decryption procedure }
procedure GSdecrypt(var where;sizeCipher:word;var sizeText:word;var err:word);
var text:array[0..maxSizeEncry+31] of byte absolute where;
   numRounds:byte;        { number of rounds 2, 4, 6 or 8 }
   randomizeKey:boolean;  { do randomize key }
   randomizeText:boolean; { do randomize text }
   lazy:boolean;          { do lazy encryption }
   key1,key2,key3,key4:tCryptoKey; { encryption keys for 2,4,6 and 8 rounds}
   desde:word;
   rand16:array[0..15] of byte;
begin
   { process "encryptionStyle" }
   randomizeKey:= (encryStyle and withKeyRandom)<>0;
   randomizeText:=(encryStyle and withTextRandom)<>0;
   numRounds:=    ( (encryStyle and withNumRounds) shr 2 )*2 + 2;
   lazy:=         (encryStyle and withLazyEncry)<>0;

   err:=0;
   if (sizeCipher<16)or(sizeCipher mod 16<>0)
      or randomizeKey and randomizeText and
         ((sizeCipher>maxSizeEncry+32) or (sizeCipher<=32))
      or (randomizeKey xor randomizeText) and
         ((sizeCipher>maxSizeEncry+16) or (sizeCipher<=16))
      or not randomizeKey and not randomizeText and
         ((sizeCipher>maxSizeEncry) or (sizeCipher<16))
   then { sizeCipher must be greater or iqual to 16 y a multiple of 8 }
   begin err:=1; exit
   end;

   sizeText:=sizeCipher;
   if randomizeKey then dec(sizeText,16);
   if randomizeText then dec(sizeText,16);

   key1:=keyEncry;
   key2:=keyEncry2;
   key3:=keyEncry3;
   key4:=keyEncry4;

   if randomizeKey then
   begin { fetch 16 encrypted random bytes from ciphertext and decrypt them }
      move(text[sizeText],rand16,16);
      decrypt16(keySi,rand16);
      doRandomizeKey(key1,rand16,56); { compute randomized keys}
      if numRounds>=4 then doRandomizeKey(key2,rand16,48);
      if numRounds>=6 then doRandomizeKey(key3,rand16,40);
      if numRounds=8 then doRandomizeKey(key4,rand16,32);
   end;

   if not lazy
      then separateHalves(text,sizeText,howUnite);

   if numRounds=8 then decrypt0(where,sizeText,key4);
   if numRounds>=6 then decrypt0(where,sizeText,key3);
   if numRounds>=4 then decrypt0(where,sizeText,key2);
   decrypt0(where,sizeText,key1);

   if not lazy
      then uniteHalves(text,sizeText,howSeparate);

   if randomizeText then
   begin { fetch 16 encrypted random bytes from ciphertext and decrypt them }
      if not randomizeKey then desde:=sizeText else desde:=sizeText+16;
      move(text[desde],rand16,16);
      decrypt16(keySi,rand16);
      doRandomizeText(text,sizeText,key1,rand16); { recover original text }
   end;

   if lazy then
      sizeText:=sizeText div 2;
end;

procedure initHashs;
{ initializes pointers to the hash functions }
begin
   { the following initialization may be changed to produce
     a non standard version of GodSave }
   hashs[ 0]:=hash0 ; hashs[ 1]:=hash1 ; hashs[ 2]:=hash2 ;
   hashs[ 3]:=hash3 ; hashs[ 4]:=hash4 ; hashs[ 5]:=hash5 ;
   hashs[ 6]:=hash6 ; hashs[ 7]:=hash7 ; hashs[ 8]:=hash8 ;
   hashs[ 9]:=hash9 ; hashs[10]:=hash10; hashs[11]:=hash11;
   hashs[12]:=hash12; hashs[13]:=hash13; hashs[14]:=hash14;
   hashs[15]:=hash15; hashs[16]:=hash16; hashs[17]:=hash17;
   hashs[18]:=hash18; hashs[19]:=hash19; hashs[20]:=hash20;
   hashs[21]:=hash21; hashs[22]:=hash22; hashs[23]:=hash23;
   hashs[24]:=hash24; hashs[25]:=hash25; hashs[26]:=hash26;
   hashs[27]:=hash27; hashs[28]:=hash28; hashs[29]:=hash29;
   hashs[30]:=hash30; hashs[31]:=hash31;

   { the following initialization may be changed to produce
     a non standard version of GodSave }
   fillchar(ax0,192,0);

   { the following initialization of hashA..hashJ is arbitrary and
     may be changed to produce a non standard version of GodSave }
   hashA:=hashStrong;
   hashB:=hash0;
   hashC:=hash13;
   hashD:=hash5;
   hashE:=hash10;
   hashF:=hash15;
   hashG:=hash20;
   hashH:=hashStrong;
   hashI:=hash2;
   hashJ:=hash3;
end;

procedure reassignHashs(var vRand);
{ reassigns pointers to the hash functions, depending on the 32 bytes of
  vRand which depend on both the master key and the actual encryption key;
  does not allow repeated values; produces 32!=2^117 permutations }
var v:array[0..31] of byte absolute vRand;
   fus:array[0..31] of byte;
   i,j,posi,po:integer;
   redi:array[0..31] of tFuHash;
begin
   fillchar(fus,sizeOf(fus),0);
   for i:=0 to 31 do
   begin posi:=v[i] mod (32-i);
      j:=-1; po:=-1;
      repeat inc(j);
         if fus[j]=0 then inc(po);
      until po=posi;
      fus[j]:=1;
      redi[i]:=hashs[j];
   end;
   move(redi,hashs,sizeOf(redi));
end;

procedure declareEncryption(masterKey,userKey:string;
   levelKeyInt,levelEncry,levelRandomkey,levelRandomText:word;
   encryptionStyle:word;
   fRandomByte:tfRandomByte);
var le,half,piece:byte;
   i,err:word;
   keyS:tScrambleKey;
   buffer:array[0..447] of byte;
      { space for:
        in first cicle:
           primary encryption key         (256 bytes)
           2 scrambler keys               (128 bytes)
           the key used by crypt16        (32 bytes)
           32 bytes needed for reassigning "hashs"
        in second cicle:
           secondary encryption key       (256 bytes)
           initial values of hash functions (192 bytes )
        in third cicle:
           tertiary encryption key        (256 bytes)
           "howSeparate" vector           (128 bytes)
        in fourth cicle:
           quaternary encryption key      (256 bytes)
           "howUnite" vector              (128 bytes) }
   keyEncry2seed:string;
begin

   initHashs;

   { scramble user's master key in order to produce
     the internal keys "keyEncry", "keyS1" and "keyS2" and "keyEncry2}

   { Reserve a small part of the user and master key
     and use this part to produce secondary "keyEncry2" }
   keyEncry2seed:='';
   le:=length(masterKey);
   if le>10 then
   begin piece:=length(masterKey) div 4;
      keyEncry2seed:=copy(masterKey,le-piece+1,piece);
      masterKey:=copy(masterKey,1,le-piece);
   end;
   le:=length(userKey);
   if le>10 then
   begin piece:=length(userKey) div 4;
      keyEncry2seed:=keyEncry2seed+copy(userKey,le-piece+1,piece);
      userKey:=copy(userKey,1,le-piece);
   end;

   {first combine half the user's master key with the internal key
     "baseScrambleKey" to produce the scrambler key }
   while length(masterKey)<10 do masterKey:=masterKey+' ';
   half:=length(masterKey) div 2;
   keyS:=baseScrambleKey;
   for i:=1 to half do
      keyS[i and 63]:=keyS[i and 63] xor ord(masterKey[i]);

   { then combine the other half of the user's master key, the
     user's encryption key, and the internal key "baseKey"
     to produce a buffer of 448 bytes }
   fillchar(buffer,sizeOf(buffer),0);
   move(userKey,buffer[192],length(userKey)+1);
   for i:=half+1 to length(masterKey) do
      buffer[i-half]:=buffer[i-half] xor ord(masterKey[i]);
   for i:=0 to 447 do buffer[i]:=buffer[i] xor baseKey[i];

   { first cicle:
     scramble the buffer, initialize the internal keys
                          and reassign the hash functions }
   GSscramble(keyS,buffer,448,10+levelKeyInt,err);
   move(buffer,keyEncry,256);
   move(buffer[256],keyS1,64);
   move(buffer[320],keyS2,64);
   move(buffer[384],keySi,32);
   reassignHashs(buffer[416]);

   { modify keyS in an arbitrary manner and rescramble;
     initialize values of ax0..ax31,cx0..cx31,dx0..dx31
     initialize keyEncry2 used by third and fourth rounds }
   for i:=0 to 19 do keyS[i]:=keyS[i]+keyS[20+i];
   for i:=20 to 39 do keyS[i]:=keyS[i] xor buffer[290+i];
   move(keyEncry2seed[1],buffer[0],length(keyEncry2seed));
   GSscramble(keyS,buffer,448,10+levelKeyInt,err);
   move(buffer,keyEncry2,256);
   move(buffer[256],ax0,192);

   { modify keyS in an arbitrary manner and rescramble;
     initialize keyEncry3 used by fifth and sixth rounds;
     initialize howSeparate vector }
   for i:=0 to 19 do keyS[i]:=keyS[i] xor i;
   for i:=20 to 39 do keyS[i]:=keyS[i] + buffer[i];
   GSscramble(keyS,buffer,448,10+levelKeyInt,err);
   move(buffer,keyEncry3,256);
   move(buffer[256],howSeparate,sizeOf(howSeparate));

   { modify keyS in an arbitrary manner and rescramble;
     initialize keyEncry4 used by seventh and eighth rounds }
   for i:=20 to 39 do keyS[i]:=keyS[i] + i;
   for i:=0 to 19 do keyS[i]:=keyS[i] + buffer[i];
   GSscramble(keyS,buffer,448,10+levelKeyInt,err);
   move(buffer,keyEncry4,256);
   move(buffer[256],howUnite,sizeOf(howSeparate));

   { also initialize the internal state of the
     pseudo random generator "GSrandom" }
   move(buffer[170],GSrandomBuf,256);
   GSscramble(keyS,GSrandomBuf,256,20,err);
   GSrandomProx:=192;

   { save levels and style parameters }
   levelEncr:=levelEncry;
   levelRKey:=levelRandomkey;
   levelRText:=levelRandomText;
   encryStyle:=encryptionStyle;

   { save user's random function }
   getRandomByte:=fRandomByte;
end;

function GSrandom:byte;
{ pseudo random number generator; is based on the GodSave scrambler and
  uses the same level parameter (levelEncry);
  The internal state of GSrandom is initialized by DeclareEncryption which
  must be executed before calling GSrandom. In this way, GSrandom can be
  used to build a stream cipher }
var keyS:tScrambleKey;
   i,err:word;
begin
   if GSrandomProx>=192 then
      begin move(GSrandomBuf[192],keyS,64);
         {for i:=192 to 255 do GSrandomBuf[i]:=getRandomByte;}
         fillchar(GSrandomBuf[192],64,0);
         GSscramble(keyS,GSrandomBuf,256,(levelEncr+10)*2,err);
         GSrandomProx:=0;
      end;
   GSrandom:=GSrandomBuf[GSrandomProx]; inc(GSrandomProx);
end;

{-------------------------------------------------------------------}
{ this is a very simple pseudo random number generator }

var vRandomX:array[0..70] of byte; { left on purpose uninitialized }

procedure initRandomX;
var i:word;
   li:longInt; { left on purpose uninitialized }
   lis:array[0..70] of byte; { left on purpose uninitialized }
begin
   randomize; randSeed:=randSeed xor li;
   for i:=0 to 70 do
      vRandomX[i]:=vRandomX[i] xor lis[i] xor random(256);
end;

function randomX:byte;
var i:word;
   b:byte;
begin
   i:=random($FFFF) mod 71;
   randomX:=vRandomX[i];
   vRandomX[i]:=random(256);
   if vRandomX[i] mod 11 = random($FFFF) mod 11 then
      for i:=1 to random(10) do
         b:=randomX;
end;

begin
   initHashs;
end. { end of GodSave v 3 definition }

{-------------------------------------------------------------------}

program GStest; { example of how to use GodSave v 3 }

uses GodSave3;

const
   masterKey:string='akjAf1ajAf:IGpTerG54f VkZXsWRio32IJDLFdkVfa8IEjfASfiI';

var key:string;
   level,style:byte;
   text,recoveredText:string;
   buffer:array[1..300] of byte;
   size,sizeCipher,sizeText,err,i:word;
begin
   write('please type level of encryption (0..50)=');readln(level);
   write('please type style of encryption (0..31)=');readln(style);
   write('please type your password=');readln(key);

   initRandomX;

   declareEncryption(masterkey,key,20,level,5,5,style,randomX);

   write('please type the message you wish to encrypt=');readln(text);
   size:=length(text)+1;
   move(text,buffer,size);
   while (size<16)or(size mod 16<>0) do (* size must be encryptable *)
   begin inc(size); buffer[size]:=random(255); (* fill in garbage *)
   end;

   GSencrypt(buffer,size,sizeCipher,err);
   if err<>0 then halt;
   writeln('ciphertext of ',sizeCipher,' bytes=');
   for i:=1 to sizeCipher do write(buffer[i],' ');writeln;

   (* here, it is NOT necessary to call "declareEncryption" again *)
   declareEncryption(masterkey,key,20,level,5,5,style,randomX);

   GSdecrypt(buffer,sizeCipher,sizeText,err);
   if err<>0 then halt;

   move(buffer,recoveredText,sizeText);
   writeln('recoverd text=',recoveredText);
   writeln;

   (* example of correct results:
      if you use level=10 style=8 password=hello text=123456789012345
      version 3 will produce the following ciphertext:
         4 152 207 58 47 151 187 156 32 230 216 5 189 166 149 66
   *)
end.


