program lab10;

{
  File F1 contains arbitrary text. Words in the text are separated by spaces
  and punctuation marks. File F2 contains up to 40 words, separated by commas.
  These words form pairs: each first word is considered replaceable, and each
  second word is considered its replacement. Find all replaceable words in file
  F1 and replace them with their corresponding replacements. Write the result to
  file G.
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils;

const
  AvailableWordSymbols = ['a'..'z', 'A'..'Z'];
  LowerCaseWordSymbols = ['a'..'z'];
  UpperCaseWordSymbols = ['A'..'Z'];

type
  TReplaceWordsElement = array[1..2] of string;
  TReplaceWordsArray = array [1..1000] of TReplaceWordsElement;

var
  F1, F2, G: TextFile;
  Line, GLine, Word: string;
  ReplaceWords: TReplaceWordsArray;
  i, Index, WordsAmount: Integer;
  // F1, F2, G - varaibles for needed files
  // Line - single sile of the file
  // Word - single word of the file
  // ReplaceWords - array of array of string that in first columns contains
  //                word that need to replace and in the second - word
  //                to replace the first word
  // i - iterator for cycles
  // Index - index of element found by binary search
  // WordsAmount - amount pairs of words that need to replce


// Procedure for sorting elements lexicographically by first elements
procedure QuickSort(var AArray: TReplaceWordsArray; ALeft, ARight: Integer);
var
  I, J: Integer;
  Pivot, Temp: TReplaceWordsElement;
begin
  I := ALeft;
  J := ARight;
  Pivot := AArray[(ALeft + ARight) div 2];

  while I <= J do
  begin
    while CompareStr(AArray[I][1], Pivot[1]) < 0 do
      Inc(I);

    while CompareStr(AArray[J][1], Pivot[1]) > 0 do
      Dec(J);

    if I <= J then
    begin
      Temp := AArray[I];
      AArray[I] := AArray[J];
      AArray[J] := Temp;
      Inc(I);
      Dec(J);
    end;
  end;

  if ALeft < J then
    QuickSort(AArray, ALeft, J);

  if I < ARight then
    QuickSort(AArray, I, ARight);
end;

// Binary find for finding first element in replace array
function BinarySearchFirst(const AArray: TReplaceWordsArray; ALeft, ARight: Integer;
  const AValue: string): Integer;
var
  Mid: Integer;
begin
  Result := -1;

  while (ALeft <= ARight) and (Result = -1) do
  begin
    Mid := (ALeft + ARight) div 2;

    if (AArray[Mid][1] = AValue) then
      Result := Mid
    else
      if AArray[Mid][1] < AValue then
        ALeft := Mid + 1
      else
        ARight := Mid - 1;
  end;
end;

// Main
begin

  // Opening files
  AssignFile(F1, 'D:\����\����\���� � ��������\2 ���\lab10\F1.txt');
  AssignFile(F2, 'D:\����\����\���� � ��������\2 ���\lab10\F2.txt');
  AssignFile(G, 'D:\����\����\���� � ��������\2 ���\lab10\G.txt');
  Reset(F1);
  Reset(F2);
  Rewrite(G);

  // Reading replace and replacement words from F2
  WordsAmount := 0;
  while not Eof(F2) do
  begin
    Readln(F2, Line);
    Line := Line + '.';

    // Assigning starting values
    Word := '';
    i := 1;
    while i <= Length(Line) do
    begin
      if Line[i] in AvailableWordSymbols then
        Word := Word + Line[i]
      else
        if Word <> '' then
        begin
          // Writing found word in raplacement array considering
          // place in array for new element
          inc(WordsAmount);
          if WordsAmount mod 2 <> 0 then
            ReplaceWords[WordsAmount div 2 + WordsAmount mod 2][1] := Word
          else
            ReplaceWords[WordsAmount div 2 + WordsAmount mod 2][2] := Word;
          Word := '';
        end;

      inc(i);
    end;
  end;

  // Sorting elements lexicographically by first elements
  QuickSort(ReplaceWords, 1, WordsAmount div 2);

  // Reading and rewriting F1 to G
  while not Eof(F1) do
  begin
    Readln(F1, Line);
    Line := Line + '.';

    // Assigning starting values
    GLine := '';
    Word := '';
    i := 1;
    while i <= Length(Line) do
    begin
      if Line[i] in AvailableWordSymbols then
      begin
        // Forming word
        Word := Word + Line[i];
      end
      else
      begin
        if Word <> '' then
        begin
          // Trying to find word in replacement array and
          // forming line for G file
          Index := BinarySearchFirst(ReplaceWords, Low(ReplaceWords),
            WordsAmount div 2, Word);
          if Index <> -1 then
            GLine := GLine + ReplaceWords[Index][2]
          else
            GLine := GLine + Word;
          Word := '';
        end;

        GLine := GLine + Line[i];
      end;

      inc(i);
    end;

    WriteLn(G, GLine);
  end;

  // Closing files
  CloseFile(F1);
  CloseFile(F2);
  CloseFile(G);
end.
