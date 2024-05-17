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


