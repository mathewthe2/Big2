program big2;
uses wincrt;
type card = array[1..13] of integer;
var cards : array[1..52] of string[2];
    symbols : string;
    snakeheads : array[1..13] of boolean;
    mixtures : array [1..5] of string;
    numcards : array[1..4] of integer;
    {play//}
    pass, rounds, turn : integer;
    havepass, havesay : boolean;
    player:card;
    {play//}
    history : array[1..5] of string;
    current_combo, current_cards : string;
    pcards : array[1..4] of card;

procedure inpdeck;
var deck : text;
    count, i: integer;
    cc : array[1..4] of string[2];
begin
     assign(deck, 'deck.txt');
     reset(deck);
     {d = diamonds, c : clubs, h : hearts, s : spades}
     for count := 1 to 13 do
     begin
          readln(deck, cc[1], cc[2], cc[3], cc[4] );
          for i := 1 to 4 do     
          cards[(count-1)*4+i] := cc[i]
     end;
     close(deck)
end;

procedure shuffle;
var count, temp : integer;
    p : array[1..4] of integer;
    skip : boolean;
begin
     for count := 1 to 4 do
     p[count] := 0;
     {Randomly send the cards to the players}
     randomize;
     for count := 1 to 52 do
     begin
          skip := false;
          temp := (((random(100) mod 16) mod 8 )mod 4) +1;
          case temp of
          1 : if p[1] < 13
              then begin
                        p[1]:= p[1]+1;
                        pcards[1, p[1]] := count
                   end
              else skip := true; {skip task if p1 have all the cards}
          2 : if p[2] < 13
              then begin
                        p[2] := p[2]+1;
                        pcards[2, p[2]] := count
                   end
              else skip := true;
          3 : if p[3] < 13
              then begin
                        p[3] := p[3]+1;
                        pcards[3, p[3]] := count
                   end
              else skip := true;
          4 : if p[4] < 13
              then begin
                        p[4] := p[4]+1;
                        pcards[4, p[4]] := count
                   end
              else skip := true;
          end;
          if skip
          then count := count-1;
          end;
     {record the numbers of cards players have}
     for count := 1 to 4 do
     numcards[count] := p[count]
end;

function indexcard(indexnum : integer) : string; {player must be assigned initially}
begin
     if cards[indexnum, 1] = '0'
     then indexcard := '1' + cards[indexnum]
     else indexcard := cards[indexnum]
end;

function indexnum(checkindex : string) : integer; {checkindex cannot contain string with 3 digits eg 10c}
var temp : integer;
begin
     temp := 1;
     while checkindex <> cards[temp] do
     temp := temp+1;
     indexnum := temp;
end;

function compareone(a , b : string) : boolean;
begin
     { if a > b then this function returns a true value}
      if indexnum(a) > indexnum(b)
      then compareone := true
      else compareone := false
end;

function checkcard(ccard : string) : boolean;
var havecard : boolean;
    i : integer;
    player : card;
begin
     checkcard := true;

     player := pcards[turn];
     havecard := false;
     for i := 1 to numcards[turn] do
     if indexnum(ccard) = player[i]  
     then havecard := true;

     if not havepass
     then checkcard := not((not havesay) and ((not havecard) or
                       (not compareone(ccard, current_cards)))); 
end;

procedure ThrowCards(card, combo : string; numofcards : integer);
var i, j, position : integer;
begin
     current_cards := card;
     current_combo := combo;
     numcards[turn] := numcards[turn] -numofcards;
     for i := 1 to numofcards do
         begin
	      {find the position of the card of the player}
	      position := 1;
	      player := pcards[turn];
	      while indexnum(card) <> player[position]  do
	            position := position+1;
	      for j :=  position to numcards[turn] do
	          pcards[turn, j] := pcards[turn, (j+1)]
	 end
				
end;

procedure NextTurn;
var i : integer;
    mycards : string;
begin
     clrscr;
     writeln('Rounds:', rounds);
     writeln('Turn: Player', turn);
     havepass := false;
     if havesay
     then writeln('Ability to throw any card: Yes')
     else writeln('Ability to throw any card: No');
     {writeln('Number of cards of players');
     writeln('P1:', p1numcards);writeln('P2:', p2numcards);writeln('P3:', p3numcards);}
     writeln;
     writeln('History');
     for i := 1 to 5 do
     writeln(i, '. ', history[i]);
     writeln;
     
     player:= pcards[turn];
     mycards := '';
     for i := 1 to numcards[turn] do
     mycards := mycards + '[' + indexcard(player[i]) + ']';
     writeln('Your cards :', mycards);
end;

function formatcheck(var inp : string): boolean;
var i : integer;
    done, dtwo : string;
    onebool, twobool : boolean;
begin
     done :=  '34567890JQKA2';
     dtwo :=  'hsdc';
     onebool := false;
     twobool := false;
     for i := 1 to length(done) do
     if inp[1] = done[i]
     then onebool := true;
     for i := 1 to length(dtwo) do
     if inp[2] = dtwo[i]
     then twobool := true;
     formatcheck := onebool and twobool
end;

procedure formatcard(var inp : string);
begin
     if inp[1] = '1'        {double digit prob of 10}
     then inp := '0' + inp[3]
     else if inp[1] in ['h', 's', 'd', 'c', 'H', 'S', 'D', 'C'] {invertion}
          then if inp[3] = '0'
               then inp := '0' + inp[1]
	       else inp := inp[2] + inp[1];
     {capitalization}
     if inp[1] in ['j', 'q', 'k', 'a'] 
     then inp[1] := chr(ord(inp[1])-32);
     if inp[2] in ['H', 'S', 'D', 'C']
     then inp[2] := chr(ord(inp[2])+32)
end;

procedure Singles;
var inp : string;
    notok : boolean;
begin
	write('Which card?');readln(inp);
	formatcard(inp);
	while not (formatcheck(inp)) do
	begin
		writeln('Please specify the card');
		readln(inp);
	end;
        notok := not checkcard(inp);  {blockage of runtime error in checkcard}
        while (not(inp[1] in ['X', 'x']) and (notok or not formatcheck(inp)))
              or (havesay and (inp[1] in ['x', 'X'])) do
        begin
	     if notok
	     then writeln('You should type in a card you have');
	     if not havesay
	     then writeln('*You can also input x now to pass!');
	     readln(inp);
             if not (formatcheck(inp))
             then writeln('Please specify the card')
             else notok := not checkcard(inp);
             if not (inp[1] in ['x', 'X'])
             then formatcard(inp)
             else if havesay
                  then writeln('You cannot pass!')
                  else havepass := true
             end;                            
                        if not havepass
			then begin
					pass := 0; 
					ThrowCards(inp, 'singles', 1);
				end
end;

procedure Doubles;
var inp:string;
begin
end;

procedure Play(playername : string);
var i : integer;
    win: boolean;
    inp, inp2, rub : string;
begin
     shuffle;          {shuffles deck of cards}
     rounds := 1;
     turn := 1;
     havesay := true;
     win := false;
     while not win do
     begin
           if pass = 3
           then havesay := true
           else if turn <> 1
                then havesay := false;
           NextTurn;

           writeln('What is your option?');
           writeln('1. Use a card');
           writeln('X. Pass');
           readln(inp);
           while not (inp[1] in ['1', 'X', 'x']) do
           begin
                write(' Please reinput');readln(inp)
           end;
           while (inp[1] in ['X', 'x'] ) and (havesay) do
           begin
                write('You cannot pass! *You have the ability to throw any card');readln(inp)
           end;
             case inp[1] of
             '1' : Singles;
             'X', 'x' : havepass := true
             end;
             for i := 5 downto 2 do
             history[i] := history[i-1];
             str(turn, rub);
             if havepass
             then begin
                       pass := pass + 1;
                       history[1] := 'Player' + rub + ' passed!'
                  end
             else begin
                       {currently current_cards cannot display 10}
                       history[1] := 'Player ' + rub + ' threw out ' +
                                     current_cards + '__' + current_combo;                   
                  end;
             if numcards[turn] = 0
             then begin
                       win := true;
                       writeln('Player ', turn, ' has won!!')
                  end
             else begin
                       if turn = 4
                       then rounds := rounds + 1;
                       turn := turn mod 4 +1 {4 players}
                  end 
            end     
end;

procedure menu;
const indent = 20;
var a, b, inp : string;
    count : integer;
begin
     writeln;writeln;writeln;
     write('':indent);writeln('[    Big 2    ]');
     write('':indent);writeln('Welcome, guest!');
     write('':indent);writeln('1. Login');
     write('':indent);writeln('2. Register');
     write('':indent);writeln('3. Quick play as guest');
     write('':indent);writeln('4. Options');

     readln(inp);
     while not (inp[1]  in ['1', '2', '3', '4']) do
     begin
          write('Please reinput an option : 1-4');readln(inp)
     end;

     case inp[1] of
     {'1' :                  
     '2' :}
     '3' : Play('Guest'); 
     {'4' :}
     end;

     {write('choose two cards');readln(a);readln(b);
     if compareone(a,b)
     then writeln(a, ' is bigger')
     else writeln(b, ' is bigger')}

     {checksnake(pone);
     for count := 1 to 7 do
     if snakeheads[count]
     then writeln('There is a snake!');}  
end;

{main}
begin
     inpdeck;
     {showcards;}
     menu;
end.          
