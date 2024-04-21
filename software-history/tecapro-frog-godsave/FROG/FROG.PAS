(*
Pascal reference implementation for the FROG symmetric block cipher
submitted by TecApro to NIST as an AES candidate algorithm. This
implementation of FROG is more flexible than the C and Java reference
implementations submitted, because it permits the use of any block size
between 8 bytes and 128 bytes.

The full FROG documentation can be found in www.tecapro.com

This code was written by Dianelos Georgoudis (email: dianelos@tecapro.com)
in June 1998.

This source code has three parts:

A. Definition of the pure FROG algorithm.

B. Implementation of the NIST specified API, including ECB, CBC,
   and CFB 1-bit modes.

C. Examples of use in ECB, CBC and CFB mode as well as code for the creation
   of the Known Answer Tests and the Monte Carlo Tests, as specified by NIST.

This algorithm is put in the public domain.

Disclaimer:
TecApro is not responsible for any damage, direct or indirect,
resulting from the use of this source code, and makes no claims about
its fitness for any particular purpose. By using this software you are
solely responsible for all consequences. *)

(* ------------------------ part A: pure FROG -------------------------*)

program frog_reference;

const
   MIN_BLOCK_SIZE   =    8; (* [bytes] = 64 bits *)
   MAX_BLOCK_SIZE   =  128; (* [bytes] = 1024 bits *)
   MIN_KEY_SIZE     =    5; (* [bytes] = 40 bits *)
   MAX_KEY_SIZE	    =  125; (* [bytes] = 1000 bits *)
   DIR_ENCRYPT =         0; (*  Are we encrypting?  *)
   DIR_DECRYPT =         1; (*  Are we decrypting?  *)

   numIter          =    8; (* number of iterations in main cycle *)
   maxInternalKeySize = numIter * (2*MAX_BLOCK_SIZE+256);

type
   tBuffer=array[0..$FFF0] of byte; (* general purpose byte array;
       will be used for plaintext, ciphertext, IV, xorBu, substPermu,
       bombPermu, etc. *)
   tBinaryKey=array[0..MAX_KEY_SIZE-1] of byte; (* type of user key *)

procedure makePermutation(var permutation;lastElem:byte);
(* receives an arbitrary byte array of (lastElem+1) elements and
   returns a permutation with values between 0 and lastElem *)
var
   permu:array[0..255] of byte absolute permutation;
   use:array[0..255] of byte;
   i,j,last:word;
begin
   for i:=0 to lastElem do use[i]:=i;
   last:=lastElem;
   j:=0;
   for i:=0 to lastElem-1 do
   begin
      j:=(j+permu[i]) mod (last+1);
      permu[i]:=use[j];
      if j<last then move(use[j+1],use[j],last-j);
      dec(last);
      if j>last then j:=0;
   end;
   permu[lastElem]:=use[0];
end;

procedure invertPermutation(var permutation;lastElem:byte);
(* receives a permutation with (lastElem+1) values and inverts it *)
var orig:array[0..255] of byte absolute permutation;
   invert:array[0..255] of byte;
   i:byte;
begin
   for i:=0 to lastElem do invert[ orig[i] ]:=i;
   move(invert,orig,lastElem+1);
end;

procedure makeInternalKey(direction:byte;var internalKey;blockSize:word);
(* receives an internalKey with arbitrary values and returns a well
   structured, valid internal key *)
var
   internKey:tBuffer absolute internalKey;
   used:array[0..MAX_BLOCK_SIZE-1] of boolean;
   ite,j,i,k,l:byte;
   change:byte;
   ikPosi:word;
   bombPermu:^tBuffer;
begin ikPosi:=0;
   for ite:=0 to numIter-1 do
   begin inc(ikPosi,blockSize);
      makePermutation(internKey[ikPosi],255);
      if direction=DIR_DECRYPT then invertPermutation(internKey[ikPosi],255);
      inc(ikPosi,256);
      bombPermu:=addr(internKey[ikPosi]);
      makePermutation(bombPermu^,blockSize-1);

      (* now make certain that bombPermu has a maximum cycle of BLOCK_SIZE *)
      fillchar(used,blockSize,false);
      j:=0;
      for i:=0 to blockSize-2 do
      begin
         if BombPermu^[j]=0 then (* smaller cycle detected *)
         begin k:=j;
            repeat k:=(k+1) mod blockSize until not used[k];
            BombPermu^[j]:=k;
            l:=k;
            while BombPermu^[l]<>k do l:=BombPermu^[l];
            BombPermu^[l]:=0;
         end;
         used[j]:=true;
         j:=BombPermu^[j];
      end;

      (* now make certain that Bomb permutation never points to next element *)
      for i:=0 to blockSize-1 do
         if BombPermu^[i]=(i+1) mod blockSize then
            bombPermu^[i]:=(i+2) mod blockSize;

      inc(ikPosi,blockSize);
   end;
end;

procedure encryptFrog(var plainText;var internalKey;var cipherText;blockSize:byte);
(* uses internalKey to encrypt plainText of blockSize bytes and leaves
   result in cipherText; plainText and cipherText can point to the same
   position *)
var
   cipherTe:tBuffer absolute cipherText;
   internKey:tBuffer absolute internalKey;
   ite,ib:byte;
   xorBu,substPermu,bombPermu:^tBuffer;
   ikPosi:word;
begin
   move(plainText,cipherTe,blockSize);
   ikPosi:=0;
   for ite:=0 to numIter-1 do
   begin
      xorBu:=addr(internKey[ikPosi]);      inc(ikPosi,blockSize);
      substPermu:=addr(internKey[ikPosi]); inc(ikPosi,256);
      bombPermu:=addr(internKey[ikPosi]);  inc(ikPosi,blockSize);
      for ib:=0 to blockSize-1 do
      begin
         cipherTe[ib]:=cipherTe[ib] xor xorBu^[ib];
         cipherTe[ib]:=SubstPermu^[cipherTe[ib]];
         if ib<blockSize-1
            then cipherTe[ib+1]:=cipherTe[ib+1] xor cipherTe[ib]
            else cipherTe[0]:=cipherTe[0] xor cipherTe[ib];
         cipherTe[BombPermu^[ib]]:=
            cipherTe[BombPermu^[ib]] xor cipherTe[ib];
      end;
   end;
end;

procedure decryptFrog(var cipherText;var internalKey;var plainText;blockSize:byte);
(* uses internalKey to decrypt cipherText of blockSize bytes and leaves
   result in plainText; cipherText and plainText can point to the same
   position *)
var
   plainTe:tBuffer absolute plainText;
   internKey:tBuffer absolute internalKey;
   ite,ib:byte;
   xorBu,substPermu,bombPermu:^tBuffer;
   ikPosi:word;
begin
   move(cipherText,plainTe,blockSize);
   ikPosi:=8*(2*blockSize+256); (* size of internal key *)
   for ite:=numIter-1 downto 0 do
   begin
      dec(ikPosi,blockSize); bombPermu:=addr(internKey[ikPosi]);
      dec(ikPosi,256);       substPermu:=addr(internKey[ikPosi]);
      dec(ikPosi,blockSize); xorBu:=addr(internKey[ikPosi]);
      for ib:=blockSize-1 downto 0 do
      begin
         plainTe[BombPermu^[ib]]:=
            plainTe[BombPermu^[ib]] xor plainTe[ib];
         if ib<blockSize-1
            then plainTe[ib+1]:=plainTe[ib+1] xor plainTe[ib]
            else plainTe[0]:=plainTe[0] xor plainTe[blockSize-1];
         plainTe[ib]:=SubstPermu^[plainTe[ib]];
         plainTe[ib]:=plainTe[ib] xor xorBu^[ib];
      end;
   end;
end;

procedure hashKey(var binaryKey:tBinaryKey;keyLen:byte;var randomKey;blockSize:byte);
(* uses binaryKey to fill randomKey with values that have good random
   statistical properties *)
const
(* The values of randomSeed were computed as the modulo 256 of the
   first 251 groups of random digits in the RAND tables. This initialization
   of randomSeed can be substituted by other values, to produce non standard
   versions of FROG that are as strong as the standard version *)
   randomSeed:array[0..250] of byte=(
      113, 21,232, 18,113, 92, 63,157,124,193,166,197,126, 56,229,229,
      156,162, 54, 17,230, 89,189, 87,169,  0, 81,204,  8, 70,203,225,
      160, 59,167,189,100,157, 84, 11,  7,130, 29, 51, 32, 45,135,237,
      139, 33, 17,221, 24, 50, 89, 74, 21,205,191,242, 84, 53,  3,230,
      231,118, 15, 15,107,  4, 21, 34,  3,156, 57, 66, 93,255,191,  3,
       85,135,205,200,185,204, 52, 37, 35, 24, 68,185,201, 10,224,234,
        7,120,201,115,216,103, 57,255, 93,110, 42,249, 68, 14, 29, 55,
      128, 84, 37,152,221,137, 39, 11,252, 50,144, 35,178,190, 43,162,
      103,249,109,  8,235, 33,158,111,252,205,169, 54, 10, 20,221,201,
      178,224, 89,184,182, 65,201, 10, 60,  6,191,174, 79, 98, 26,160,
      252, 51, 63, 79,  6,102,123,173, 49,  3,110,233, 90,158,228,210,
      209,237, 30, 95, 28,179,204,220, 72,163, 77,166,192, 98,165, 25,
      145,162, 91,212, 41,230,110,  6,107,187,127, 38, 82, 98, 30, 67,
      225, 80,208,134, 60,250,153, 87,148, 60, 66,165, 72, 29,165, 82,
      211,207,  0,177,206, 13,  6, 14, 92,248, 60,201,132, 95, 35,215,
      118,177,121,180, 27, 83,131, 26, 39, 46, 12);

var buffer:array[0..MAX_BLOCK_SIZE-1] of byte;
   simpleKey:array[0..maxinternalKeySize-1] of byte;
   randKey:tBuffer absolute randomKey;
   last,iSeed,iKey,keyLen1:byte;
   i,j,size,internalKeySize:word;
begin
   internalKeySize:=8*(2*blockSize+256);

   (* build initial internalKey *)
   iSeed:=0;iKey:=0;keyLen1:=keyLen-1;
   for i:=0 to internalKeySize-1 do
   begin
      SimpleKey[i]:=randomSeed[iSeed] xor binaryKey[iKey];
      if iSeed<250 then inc(iSeed) else iSeed:=0;
      if iKey<keyLen1 then inc(iKey) else iKey:=0;
   end;
   makeInternalKey(DIR_ENCRYPT,simpleKey,blockSize);

   (* build plaintext buffer *)
   fillchar(buffer,blockSize,0);
   last:=keyLen1;
   if last>=blockSize then last:=blockSize-1;
   for i:=0 to last do buffer[i]:=buffer[i] xor binaryKey[i];
   buffer[0]:=buffer[0] xor keyLen;

   (* produce hashed randomKey using CBC encryptions *)
   i:=0;
   repeat
      encryptFrog(buffer,simpleKey,buffer,blockSize);
      size:=internalKeySize-i;
      if size>blockSize then size:=blockSize;
      move(buffer,randKey[i],size);
      inc(i,size);
   until i=internalKeySize;
end;

(* ------------------------ part B: NIST API -------------------------*)

(* for legibility no error messages are included *)

const
   MODE_ECB    =         1;    (*  Are we ciphering in ECB mode?   *)
   MODE_CBC    =         2;    (*  Are we ciphering in CBC mode?   *)
   MODE_CFB1   =         3;    (*  Are we ciphering in 1-bit CFB mode? *)

type
   tMaxInternalKey=array[0..maxInternalKeySize-1] of byte;
   tMaxBuffer=array[0..MAX_BLOCK_SIZE-1] of byte;
   keyInstance =
      record
         direction:byte;         (* encryption or decryption *)
         keyLen:byte;            (* length of key in bytes *)
         keyMaterial:tBinaryKey; (* original user key *)
         internalKey:tMaxInternalKey;
         blockSize:byte;         (* in bytes *)
      end;

   cipherInstance=
      record
         mode: byte;     (* MODE_ECB, MODE_CBC, or MODE_CFB1 *)
         IV: tMaxBuffer; (* Initialization Vector *)
      end;

procedure makeKey(var key:keyInstance; direction:byte; keyLen:byte;
                      keyMaterial:tBinaryKey; blockSize:byte);
(* Computes internal key.
   Inputs:
      Cipher direction (DIR_ENCRYPT or DIR_DECRYPT).
      KeyMaterial, a binary array that holds the user's key.
      KeyLen, the binary key's length in bytes. (For example for a 128
          bit long key, keyLen = 16.) Legal values: 5..125
      BlockSize, the size of the blocks to be encrypted or decrypted.
          Legal values: 8..128.
   Returns:
      key instance that holds the internal key.

   When decrypting in CFB1 mode, makeKey must be called with
   direction set to DIR_ENCRYPT!  *)
begin
   key.direction:=   direction;
   key.keyLen:=      keyLen;
   key.keyMaterial:= keyMaterial;

   hashKey(keyMaterial,keyLen,key.internalKey,blockSize);
   makeInternalKey(direction,key.internalKey,blockSize);
end;

procedure cipherInit(var cipher:cipherInstance; mode:byte; var IV; blockSize:byte);
(* initializes the cipher instance *)
begin
   cipher.mode:=mode;
   move(IV,cipher.IV,blockSize);
end;

procedure shift1bitLeft(var buffer; blockSize:word);
(* moves an entire block of BLOCK_SIZE bytes 1 bit to the left,
   i.e. towards the most significant position *)
var i:byte;
   buf:tBuffer absolute buffer;
begin
   for i:=blockSize-1 downto 0 do
   begin
      buf[i]:=buf[i] shl 1;
      if i>0 then buf[i]:=buf[i] or (buf[i-1] shr 7);
   end;
end;

procedure blockEncrypt(var cipher:cipherInstance; var key:keyInstance;
                       var inpBuffer; inputLen:byte; var outBuffer);
(* Receives the cipher instance, the key instance, the input plaintext,
   its length in bytes. Encrypts the plaintext in ECB, CBC or CFB 1 bit
   mode and returns the ciphertext in outBuffer *)
var i:byte;
   inpBuf:tBuffer absolute inpBuffer;
   outBuf:tBuffer absolute outBuffer;
begin with cipher,key do begin
   blockSize:=inputLen;

   case mode of
      MODE_ECB: encryptFrog(inpBuf,internalKey,outBuf,blockSize);
      MODE_CBC:
         begin
            for i:=0 to blockSize-1 do
               outBuf[i]:=inpBuf[i] xor IV[i];
            encryptFrog(outBuf,internalKey,outBuf,blockSize);
            move(outBuf,IV,blockSize);
         end;
      MODE_CFB1:
         (* Receives plaintext bit in most significant position of input and
            returns ciphertext bit in most significant position of outBuffer *)
         begin
            encryptFrog(IV,internalKey,IV,blockSize);
            outBuf[blockSize-1]:=IV[blockSize-1] xor
                                     inpBuf[blockSize-1];
            shift1bitLeft(IV,blockSize);
            IV[0]:=IV[0] or (outBuf[blockSize-1] shr 7);
         end;
   end;
end;end;

procedure blockDecrypt(var cipher:cipherInstance; var key:keyInstance;
                       var inpBuffer; inputLen:byte; var outBuffer);
(* Receives the cipher instance, the key instance, the input ciphertext,
   its length in bytes. Decrypts the ciphertext in ECB, CBC or CFB 1 bit
   mode and returns the plaintext in outBuffer *)
var i:byte;
   inpBuf:tBuffer absolute inpBuffer;
   outBuf:tBuffer absolute outBuffer;
begin with cipher,key do begin
   blockSize:=inputLen;

   case mode of
      MODE_ECB: decryptFrog(inpBuf,internalKey,outBuf,blockSize);
      MODE_CBC:
         begin
            decryptFrog(inpBuf,internalKey,outBuf,blockSize);
            for i:=0 to blockSize-1 do
               outBuf[i]:=outBuf[i] xor IV[i];
            move(inpBuf,IV,blockSize);
         end;
      MODE_CFB1:
         (* Receives cipher bit in most significant position of input and
            returns plaintext bit in most significant position of outBuffer.
            When decrypting in CFB1 mode, makeKey must be called with
            direction set to DIR_ENCRYPT! *)
         begin
            encryptFrog(IV,internalKey,IV,blockSize);
            outBuf[blockSize-1]:=IV[blockSize-1] xor
                                     inpBuf[blockSize-1];
            shift1bitLeft(IV,blockSize);
            IV[0]:=IV[0] or (inpBuf[blockSize-1] shr 7);
         end;
   end;
end;end;

(* --------------------- part C: Examples and Tests -----------------------*)

procedure FROGexamples;
(* Demonstrates the use of FROG in ECB, CBC and CFB 1 bit mode, using
   then NIST specified API *)
var cipher:cipherInstance;
   
   text0,text1,cipher0,cipher1,text0B,text1B,IV:tMaxBuffer; (* reserve the
   maximum size possible (128 bytes) for plaintext and ciphertext buffers *)
   key:keyInstance;
   binaryKey:tBinaryKey;
   keyLen,blockSize,shouldBe:byte;
   i:word;
   CFBresult:array[0..99] of byte;
begin
   keyLen:=20;    (* Key length in bytes; any value between 5 and 125
                     can be used *)
   blockSize:=35; (* Block size in bytes; any value between 8 and 128
                     can be used *)

(* --------------------- FROG in ECB mode -----------------------*)
   (* declare mode and block size, IV will not be used *)
   cipherInit(cipher,MODE_ECB,IV,blockSize);
   (* define arbitrary binary user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+1;
   (* compute internal key that corresponds to encryption *)
   makeKey(key,DIR_ENCRYPT,keyLen,binaryKey,blockSize);
   (* initialize arbitrary plaintext *)
   for i:=0 to blockSize-1 do text0[i]:=i;
   (* encrypt plaintext and produce ciphertext *)
   blockEncrypt(cipher,key,text0,blockSize,cipher0);

   (* declare mode and block size, IV will not be used *)
   cipherInit(cipher,MODE_ECB,IV,blockSize);
   (* define user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+1;
   (* compute internal key that corresponds to decryption *)
   makeKey(key,DIR_DECRYPT,keyLen,binaryKey,blockSize);
   (* decrypt previous ciphertext and produce plaintext *)
   blockDecrypt(cipher,key,cipher0,blockSize,text0B);

   (* check if plaintext produced previously is identical to original *)
   for i:=0 to blockSize-1 do
      if text0[i]<>text0B[i] then
      begin write('error ECB ');readln;halt;
      end;

(* --------------------- FROG in CBC mode -----------------------*)
   (* initialize IV with arbitrary values; these need not be secret *)
   for i:=0 to blockSize-1 do IV[i]:=i+11;
   (* declare mode, block size and IV *)
   cipherInit(cipher,MODE_CBC,IV,blockSize);
   (* define arbitrary binary user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+4;
   (* compute internal key that corresponds to encryption *)
   makeKey(key,DIR_ENCRYPT,keyLen,binaryKey,blockSize);
   (* initialize several arbitrary plaintexts *)
   for i:=0 to blockSize-1 do text0[i]:=i;
   for i:=0 to blockSize-1 do text1[i]:=i+i;
   (* now sequentially encrypt all plaintexts *)
   blockEncrypt(cipher,key,text0,blockSize,cipher0);
   blockEncrypt(cipher,key,text1,blockSize,cipher1);

   (* initialize IV with original values *)
   for i:=0 to blockSize-1 do IV[i]:=i+11;
   (* declare mode, block size and IV *)
   cipherInit(cipher,MODE_CBC,IV,blockSize);
   (* define user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+4;
   (* compute internal key that corresponds to decryption *)
   makeKey(key,DIR_DECRYPT,keyLen,binaryKey,blockSize);
   (* now sequentially decrypt all ciphertexts *)
   blockDecrypt(cipher,key,cipher0,blockSize,text0B);
   blockDecrypt(cipher,key,cipher1,blockSize,text1B);

   (* check if plaintexts produced are identical to the original ones *)
   for i:=0 to blockSize-1 do
      if (text0[i]<>text0B[i])or(text1[i]<>text1B[i]) then
      begin write('error CBC');readln;halt;
      end;

(* --------------------- FROG in 1 bit CFB mode -----------------------*)
   (* initialize IV with arbitrary values; these need not be secret *)
   for i:=0 to blockSize-1 do IV[i]:=i+5;
   (* declare mode, block size and IV. Here only one bit will be encrypted,
      so the minimum possible blockSize (=8) will give faster results *)
   cipherInit(cipher,MODE_CFB1,IV,blockSize);
   (* define arbitrary binary user key *)
   (* define arbitrary binary user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+7;
   (* compute internal key that corresponds to encryption *)
   makeKey(key,DIR_ENCRYPT,keyLen,binaryKey,blockSize);
   (* FROG receives the bit to be encrypted as the most significan bit of
      the plaintext (all other bits are ignored) and returns the encrypted
      bit as the most significant bit of the ciphertext. In this example
      a sequence of 100 alternating 0's and 1's will be encrypted and the
      one bit ciphertexts will be saved in the array of bytes CFBresult. *)
   for i:=0 to 99 do
   begin
      (* initialize most significant bit *)
      if odd(i)
         then text0[blockSize-1]:=$80
         else text0[blockSize-1]:=0;
      (* encrypt this bit - the result is the msb of cipher0 *)
      blockEncrypt(cipher,key,text0,blockSize,cipher0);
      (* save encrypted bit in CFBresult *)
      if cipher0[blockSize-1] and $80=0 (* most sign. bit = 0 *)
         then CFBresult[i]:=0
         else CFBresult[i]:=1;
   end;

   (* initialize IV with original values *)
   for i:=0 to blockSize-1 do IV[i]:=i+5;
   (* declare mode, block size and IV. *)
   cipherInit(cipher,MODE_CFB1,IV,blockSize);
   (* compute internal key. BEWARE: always use DIR_ENCRYPT, even if you
      intend to start decrypting *)
   (* define user key *)
   for i:=0 to keyLen-1 do binaryKey[i]:=i+7;
   makeKey(key,DIR_ENCRYPT,keyLen,binaryKey,blockSize);
   for i:=0 to 99 do
   begin
      (* initialize next encrypted bit *)
      if CFBresult[i]=0
         then cipher0[blockSize-1]:=0
         else cipher0[blockSize-1]:=$80;
      (* decrypt one bit *)
      blockDecrypt(cipher,key,cipher0,blockSize,text0b);
      (* check if bit decrypted is correct *)
      if odd(i) then shouldBe:=$80 else shouldBe:=0;
      if (text0b[blockSize-1] and $80)<>shouldBe then
      begin write('error CFB1 ');readln;halt;
      end;
   end;

end;

(* ------- what follows is code to generate the NIST specified files -----*)

procedure binaryToHexString(var binaryV;var hexString:string;binLength:byte);
(* Inputs a binary vector and returns a string with a hex presentation. The
   first (leftmost) character of this string represents the 4 most
   significant bits of the binary vector, and so on. *)
const bin2hex:array[0..15] of char=
   ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
var iBin,iHex,val:byte;
   binary:array[0..1000] of byte absolute binaryV;
begin hexString[0]:=chr(binLength*2);
   iHex:=1;
   for iBin:=binLength-1 downto 0 do
   begin val:=(binary[iBin] and $f0) shr 4;
      hexString[iHex]:=bin2hex[val]; inc(iHex);
      val:=binary[iBin] and $0f;
      hexString[iHex]:=bin2hex[val]; inc(iHex);
   end;
end;

procedure hexStringToBinary(hexString:string;
                            var binary:tBinaryKey;keyLen:byte);
(* Inverts previous procedure. It is not really needed here, and is
   included only as a general purpose tool *)
   function hexToByte(hex:char):byte;
   begin
      if (hex>='0')and(hex<='9')
         then hexToByte:=ord(hex)-ord('0')
         else hexToByte:=ord(hex)-ord('a')+10;
   end;
var iBin,iHex:byte;
begin iHex:=1;
   for iBin:=keyLen-1 downto 0 do
   begin
      binary[iBin]:= (hexToByte(hexString[iHex]) shl 4) or
                     hexToByte(hexString[iHex+1]);
      inc(iHex,2)
   end;
end;

procedure ECB_VK;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   PT,CT,PT2:tMaxBuffer;
   iLe,keyLen,blockSize,iByte,iBit,i:byte;
   bitPosi:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
begin blockSize:=16;
   assign(fOut,'ecb_vk.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "ecb_vk.txt"');
   writeln(fOut);
   writeln(fOut,'Electronic Codebook (ECB) Mode');
   writeln(fOut,'Variable Key Known Answer Tests');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: TecApro');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   fillchar(PT,blockSize,0);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      binaryToHexString(PT,s,blockSize);
      writeln(fOut,'PT=',s);writeln(fOut);

      bitPosi:=0;
      for iByte:=keyLen-1 downto 0{keyLen-2} do
         for iBit:=7 downto 0 do
         begin write(iByte,' ');
            inc(bitPosi); writeln(fOut,'I=',bitPosi);
            fillchar(binKey,keyLen,0);
            binKey[iByte]:=1 shl iBit;
            binaryToHexString(binKey,s,keyLen);
            writeln(fOut,'KEY=',s);

            cipherInit(cipherInst,MODE_ECB,IV,blockSize);
            makeKey(keyInst,DIR_ENCRYPT,keyLen,binKey,blockSize);
            blockEncrypt(cipherInst,keyInst,PT,blockSize,CT);
            binaryToHexString(CT,s,blockSize);
            writeln(fOut,'CT=',s);writeln(fOut);

            cipherInit(cipherInst,MODE_ECB,IV,blockSize);
            makeKey(keyInst,DIR_DECRYPT,keyLen,binKey,blockSize);
            blockDecrypt(cipherInst,keyInst,CT,blockSize,PT2);
            for i:=0 to blockSize-1 do
               if PT[i]<>PT2[i] then
               begin writeln('error decry ');readln;halt;
               end;
         end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

procedure ECB_VT;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   PT,CT,PT2:tMaxBuffer;
   iLe,keyLen,blockSize,iByte,iBit,i:byte;
   bitPosi:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
begin blockSize:=16;
   assign(fOut,'ecb_vt.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "ecb_vt.txt"');
   writeln(fOut);
   writeln(fOut,'Electronic Codebook (ECB) Mode');
   writeln(fOut,'Variable Text Known Answer Tests');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: TecApro');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      fillchar(binKey,keyLen,0);
      binaryToHexString(binKey,s,keyLen);
      writeln(fOut,'KEY=',s);writeln(fOut);

      bitPosi:=0;
      for iByte:=blockSize-1 downto 0{BLOCK_SIZE-2} do
         for iBit:=7 downto 0 do
         begin write(iByte,' ');
            inc(bitPosi); writeln(fOut,'I=',bitPosi);
            fillchar(PT,blockSize,0);
            PT[iByte]:=1 shl iBit;
            binaryToHexString(PT,s,blockSize);
            writeln(fOut,'PT=',s);

            cipherInit(cipherInst,MODE_ECB,IV,blockSize);
            makeKey(keyInst,DIR_ENCRYPT,keyLen,binKey,blockSize);
            blockEncrypt(cipherInst,keyInst,PT,blockSize,CT);
            binaryToHexString(CT,s,blockSize);
            writeln(fOut,'CT=',s);writeln(fOut);

            cipherInit(cipherInst,MODE_ECB,IV,blockSize);
            makeKey(keyInst,DIR_DECRYPT,keyLen,binKey,blockSize);
            blockDecrypt(cipherInst,keyInst,CT,blockSize,PT2);
            for i:=0 to blockSize-1 do
               if PT[i]<>PT2[i] then
               begin writeln('error decry ');readln;halt;
               end;
         end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

procedure ECB_E_M;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   PT,CT,PT2,CT9998:tMaxBuffer;
   iLe,keyLen,blockSize:byte;
   i,j,k:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
   CTexpanded:tBinaryKey;
begin blockSize:=16;
   assign(fOut,'ecb_e_m.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "ecb_e_m.txt"');
   writeln(fOut);
   writeln(fOut,'Electronic Codebook (ECB) Mode - ENCRYPTION');
   writeln(fOut,'Monte Carlo Test');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: TecApro');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      fillchar(binKey,sizeOf(binKey),0);
      fillchar(PT,blockSize,0);

      for i:=0 to 399 do
      begin
         write(i,' ');
         writeln(fOut,'I=',i);
         binaryToHexString(binKey,s,keyLen);
         writeln(fOut,'KEY=',s);
         binaryToHexString(PT,s,blockSize);
         writeln(fOut,'PT=',s);

         cipherInit(cipherInst,MODE_ECB,IV,blockSize);
         makeKey(keyInst,DIR_ENCRYPT,keyLen,binKey,blockSize);
         for j:=0 to 9999 do
         begin
            blockEncrypt(cipherInst,keyInst,PT,blockSize,CT);
            PT:=CT;
            if j=9998 then CT9998:=CT;
         end;
         binaryToHexString(CT,s,blockSize);
         writeln(fOut,'CT=',s);writeln(fOut);

         for k:=0 to blockSize-1 do CTexpanded[k]:=CT[k];
         if keyLen=24 then
            for k:=0 to 7 do CTexpanded[blockSize+k]:=CT9998[k];
         if keyLen=32 then
            for k:=0 to 15 do CTexpanded[blockSize+k]:=CT9998[k];
         for k:=0 to keyLen do binKey[k]:=binKey[k] xor CTexpanded[k];
         PT:=CT;
      end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

procedure ECB_D_M;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   PT,CT,PT2,PT9998:tMaxBuffer;
   iLe,keyLen,blockSize:byte;
   i,j,k:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
   PTexpanded:tBinaryKey;
begin blockSize:=16;
   assign(fOut,'ecb_d_m.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "ecb_d_m.txt"');
   writeln(fOut);
   writeln(fOut,'Electronic Codebook (ECB) Mode - DECRYPTION');
   writeln(fOut,'Monte Carlo Test');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: TecApro');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      fillchar(binKey,sizeOf(binKey),0);
      fillchar(CT,blockSize,0);

      for i:=0 to 399 do
      begin
         write(i,' ');
         writeln(fOut,'I=',i);
         binaryToHexString(binKey,s,keyLen);
         writeln(fOut,'KEY=',s);
         binaryToHexString(CT,s,blockSize);
         writeln(fOut,'CT=',s);

         cipherInit(cipherInst,MODE_ECB,IV,blockSize);
         makeKey(keyInst,DIR_DECRYPT,keyLen,binKey,blockSize);
         for j:=0 to 9999 do
         begin
            blockDecrypt(cipherInst,keyInst,CT,blockSize,PT);
            CT:=PT;
            if j=9998 then PT9998:=PT;
         end;
         binaryToHexString(PT,s,blockSize);
         writeln(fOut,'PT=',s);writeln(fOut);

         for k:=0 to blockSize-1 do PTexpanded[k]:=PT[k];
         if keyLen=24 then
            for k:=0 to 7 do PTexpanded[blockSize+k]:=PT9998[k];
         if keyLen=32 then
            for k:=0 to 15 do PTexpanded[blockSize+k]:=PT9998[k];
         for k:=0 to keyLen do binKey[k]:=binKey[k] xor PTexpanded[k];
         CT:=PT;
      end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

procedure CBC_E_M;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   CTlast,CV,PT,CT,PT2,CT9998:tMaxBuffer;
   iLe,keyLen,blockSize:byte;
   i,j,k:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
   CTexpanded:tBinaryKey;
begin blockSize:=16;
   assign(fOut,'cbc_e_m.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "cbc_e_m.txt"');
   writeln(fOut);
   writeln(fOut,'Cipher Block Chaining (CBC) Mode - ENCRYPTION');
   writeln(fOut,'Monte Carlo Test');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: TecApro');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      fillchar(binKey,sizeOf(binKey),0);
      fillchar(PT,blockSize,0);
      fillchar(IV,blockSize,0);

      for i:=0 to 399 do
      begin
         if i=0 then CV:=IV;
         write(i,' ');
         writeln(fOut,'I=',i);
         binaryToHexString(binKey,s,keyLen);
         writeln(fOut,'KEY=',s);
         binaryToHexString(CV,s,blockSize);
         writeln(fOut,'IV=',s);
         binaryToHexString(PT,s,blockSize);
         writeln(fOut,'PT=',s);

         cipherInit(cipherInst,MODE_ECB,IV,blockSize);
         makeKey(keyInst,DIR_ENCRYPT,keyLen,binKey,blockSize);
         for j:=0 to 9999 do
         begin
            for k:=0 to blockSize-1 do PT[k]:=PT[k] xor CV[k];
            blockEncrypt(cipherInst,keyInst,PT,blockSize,CT);
            if j=0 then PT:=CV else PT:=CTlast;
            CTlast:=CT;
            CV:=CT;
            if j=9998 then CT9998:=CT;
         end;
         binaryToHexString(CT,s,blockSize);
         writeln(fOut,'CT=',s);writeln(fOut);

         for k:=0 to blockSize-1 do CTexpanded[k]:=CT[k];
         if keyLen=24 then
            for k:=0 to 7 do CTexpanded[blockSize+k]:=CT9998[k];
         if keyLen=32 then
            for k:=0 to 15 do CTexpanded[blockSize+k]:=CT9998[k];
         for k:=0 to keyLen do binKey[k]:=binKey[k] xor CTexpanded[k];
         PT:=CT9998;
         CV:=CT;
      end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

procedure CBC_D_M;
const keyLengths:array[1..3] of word=(128,192,256);
var hexKey,hexKey2:string;
   binKey:tBinaryKey;
   fOut:text;
   OB,CV,PT,CT,PT2,PT9998:tMaxBuffer;
   iLe,keyLen,blockSize:byte;
   i,j,k:word;
   s:string;
   cipherInst:cipherInstance;
   IV:tMaxBuffer;
   keyInst:keyInstance;
   PTexpanded:tBinaryKey;
begin blockSize:=16;
   assign(fOut,'cbc_d_m.txt');rewrite(fOut);
   writeln(fOut);
   writeln(fOut,'=========================');
   writeln(fOut);
   writeln(fOut,'FILENAME:  "cbc_d_m.txt"');
   writeln(fOut);
   writeln(fOut,'Cipher Block Chaining (CBC) Mode - DECRYPTION');
   writeln(fOut,'Monte Carlo Test');
   writeln(fOut);
   writeln(fOut,'Algorithm Name: FROG');
   writeln(fOut,'Principal Submitter: Dianelos Georges Georgoudis');
   writeln(fOut);
   writeln(fOut,'==========');
   writeln(fOut);

   for iLe:=1 to 3 do
   begin
      keyLen:=keyLengths[iLe] div 8;

      writeln(fOut,'KEYSIZE=',keyLengths[iLe]);writeln(fOut);
      fillchar(binKey,sizeOf(binKey),0);
      fillchar(CT,blockSize,0);
      fillchar(IV,blockSize,0);

      for i:=0 to 399 do
      begin
         if i=0 then CV:=IV;
         write(i,' ');
         writeln(fOut,'I=',i);
         binaryToHexString(binKey,s,keyLen);
         writeln(fOut,'KEY=',s);
         binaryToHexString(CV,s,blockSize);
         writeln(fOut,'IV=',s);
         binaryToHexString(CT,s,blockSize);
         writeln(fOut,'CT=',s);

         cipherInit(cipherInst,MODE_ECB,IV,blockSize);
         makeKey(keyInst,DIR_DECRYPT,keyLen,binKey,blockSize);
         for j:=0 to 9999 do
         begin
            blockDecrypt(cipherInst,keyInst,CT,blockSize,OB);
            for k:=0 to blockSize-1 do PT[k]:=OB[k] xor CV[k];
            CV:=CT;
            if j<9999 then CT:=PT;
            if j=9998 then PT9998:=PT;
         end;
         binaryToHexString(PT,s,blockSize);
         writeln(fOut,'PT=',s);writeln(fOut);

         for k:=0 to blockSize-1 do PTexpanded[k]:=PT[k];
         if keyLen=24 then
            for k:=0 to 7 do PTexpanded[blockSize+k]:=PT9998[k];
         if keyLen=32 then
            for k:=0 to 15 do PTexpanded[blockSize+k]:=PT9998[k];
         for k:=0 to keyLen do binKey[k]:=binKey[k] xor PTexpanded[k];
         CV:=CT;
         CT:=PT;
      end;
      writeln(fout,'==========');writeln(fout);
   end;
   close(fOut);
end;

begin (* main *)
   FROGexamples;

   (* Known Answer Tests as specified by NIST. *)
   ECB_VK;
   ECB_VT;
   (* Monte Carlo Tests, as specified by NIST. *)
   ECB_E_M;
   ECB_D_M;
   CBC_E_M;
   CBC_D_M;
end.
