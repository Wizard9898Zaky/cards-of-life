#!/usr/bin/bash
dir=$HOME/cards_of_life
[ ! -d $dir ] && mkdir $dir
[ -f $HOME/setup_cards.sh ] && mv $HOME/setup_cards.sh $dir
BIN=`echo $BASH | sed 's/\/bash//'`
file2=$BIN/cards
file3=$dir/data
file4=$dir/lifepath-calculator.yab
solardeck=( 00 AH 2H 3H 4H 5H 6H 7H 8H 9H TH JH QH KH AC 2C 3C 4C 5C 6C 7C 8C 9C TC JC QC KC AD 2D 3D 4D 5D 6D 7D 8D 9D TD JD QD KD AS 2S 3S 4S 5S 6S 7S 8S 9S TS JS QS KS )
tempfile() {
cd $dir
local num="1"
local card="0"
filename=$dir/cardnum
while [ $num -lt "53" ]; do
  if [ ! -f "$dir/${solardeck[$num]}" ]; then
    echo $num > $filename
    clear
    echo "This will take a L O N G time..."
    echo "Please wait..."
    echo "Calculating and saving all lifepath info for ${solardeck[$num]}."
    echo "(DONE/TOTAL)"
    echo "($card/52)"
    yabasic $file4
  fi
  (( num++ ))
  (( card++ ))
done
echo "100" > $filename
[ `cat $filename` == 100 ] && rm $file4
}
apt-get update
wh=`which yabasic`
[ -z "$wh" ] && apt-get install yabasic -y
wh=`which less`
[ -z "$wh" ] && apt-get install less -y
apt-get upgrade -y
cat > $file2 <<- EOM
#!/usr/bin/yabasic
on interrupt continue
dir\$="$dir/"
EOM
cat >> $file2 <<- 'EOF'
open dir$+"cardnum" for reading as #1
input #1 a
close #1
if a<>100 then
  clear screen
  print "Before the Cards of Life program can be used, you must first finish setting it up."
  print "Please run setup-cards.sh again to finish the setup."
  print "Press a key . . ."
  gosub in_key
  goto done
fi
data "January",31,0,"February",28,31,"March",31,60,"April",30,91,"May",31,121,"June",30,152,"July",31,182,"August",31,213,"September",30,244,"October",31,274,"November",30,305,"December",31,335
data "A","2","3","4","5","6","7","8","9","T","J","Q","K","H","C","D","S"
data "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
clear screen
label def_arrays
dim rsif$(17)
dim spot$(13)
dim suit$(4)
dim month_name$(12)
dim max_month_days(12)
dim julian_date_starts(12)
dim a$(52)
dim b$(52)
dim tablet$(90)
dim stack$(9)
dim cutcard$(2)
dim weekday$(7)
dim agecard$(90)
dim mercury$(9)
dim venus$(8)
dim mars$(8)
dim jupiter$(8)
dim saturn$(8)
dim sun$(8)
dim moon$(8)
dim week_card$(90,52)
dim weekday_card$(90,52,7)
dim week_spread$(90,52)
dim weekday_spread$(90,52)
dim period(9)
dim day_card$(90,366)
dim age_spread$(90)
dim quad_age$(90)
dim quad_week$(90,52)
dim quad_weekday$(90,52,7)
dim quad_day$(90,366)
dim period_card$(90,7)
dim quad_period$(90,8)
dim card$(52)
dim wds(90)
dim pstart$(90,7,7)
dim pfinish$(90,7,7)
dim pdate$(90,7,2)
dim wdate$(90,52,2)
dim weekdate$(90,52,7)
for month=1 to 12
  read month_name$(month)
  read max_month_days(month)
  read julian_date_starts(month)
next month
label calculate_holy_tablets
for count=1 to 17
  read rsif$(count)
next count
c=0
for a=1 to 13
  spot$(a)=rsif$(a)
next a
for a=1 to 4
  suit$(a)=rsif$(a+13)
next a
for b=1 to 4
  for a=1 to 13
    c=c+1
    a$(c)=spot$(a)+suit$(b)
  next a
next b
label weekday_names
for count=0 to 6
  read weekday$(count)
next count
goto birthyear
label pre_birthyear
clear screen
gosub birth_info
x=1:y=0
print @(x,y) "*"
gosub basic_layout
print "Are you wanting to change your birthday?"
print "(y/n)"
gosub in_key
if g$="y" goto birthyear
if g$="n" then
  indicator=2
  goto layout
fi
goto pre_birthyear
label birthyear
clear screen
maxx=peek("screenwidth")-1
maxy=peek("screenheight")-3
birthyear$="":birthmonth$="":birthday$=""
bdx=int((maxx-22)/2)+14
midx=int(maxx/2)
sdx=int((maxx-16)/3)
label year
gosub birth_info
gosub basic_layout
print @(0,maxy-3) "What is your year of birth (YYYY)?"
print @(0,0) "(*)BIRTH - YEAR";
gosub in_put
birthyear$=g$
if len(birthyear$)<>4 then
  clear screen
  birthyear$=""
  print @(0,maxy-1) "Incorrect year! Try again..."
  goto year
fi
birthyear=val(birthyear$)
year$=str$(birthyear)
gosub check_leapyear
clear screen
label birthmonth
gosub basic_layout
gosub birth_info
print @(1,0) "*"
for count=1 to 6
  print @(0,count+1) str$(count)+" = "+month_name$(count)
next count
for count=7 to 12
  print @(26,count-5) str$(count)+" = "+month_name$(count)
next count
print @(maxx-5,maxy) "(b)ack"
print @(0,maxy-3) "What is your month of birth?"
print @(bdx,0) "MONTH";
gosub in_put
if g$="b" goto birthyear
birthmonth$=g$
birthmonth=val(birthmonth$)
if !(birthmonth>0 and birthmonth<13) then
  clear screen
  birthmonth$=""
  print @(0,maxy-1) "You must enter a number between 1 and 12!"
  goto birthmonth
fi
if len(birthmonth$)=1 birthmonth$="0"+birthmonth$
clear screen
label birthday
gosub basic_layout
gosub birth_info
print @(1,0) "*"
print @(maxx-5,maxy) "(b)ack"
print @(0,maxy-3) month_name$(birthmonth)+" has "+str$(max_month_days(birthmonth))+" days in it."
print "Which day of "+month_name$(birthmonth)+" were you born on?"
print @(maxx-6,0) "DAY";
gosub in_put
if g$="b" goto birthmonth
if len(g$)=1 then birthday$="0"+g$ else birthday$=g$:fi
b=val(g$):b$=g$
if !(b>0 and b<=max_month_days(birthmonth)) then
  birthday$=""
  clear screen
  gosub basic_layout
  gosub birth_info
  print @(1,0) "*"
  print @(0,maxy-1) "You must enter a number between 1 and "+str$(max_month_days(birthmonth))+"."
  goto birthday
fi
label sunrise
clear screen
gosub basic_layout
gosub birth_info
print @(1,0) "*"
print @(0,maxy-3) "Were you born before or after sunrise on"
print month_name$(birthmonth)+", "+b$+" (b or a)?"
gosub in_key
if !(g$="b" or g$="a") then
  print @(0,maxy-2) "b=before & a=after"
  print "Enter either the letter b or the letter a."
  goto sunrise
fi
clear screen
gosub basic_layout
gosub birth_info
print @(1,0) "*"
print @(maxx-5,maxy) "(b)ack"
if g$="b" then
  birthday=b-1
  gosub new_birthday
  birthday$=str$(birthday)
  if len(birthday$)=1 birthday$="0"+birthday$
  clear screen
  gosub basic_layout
  gosub birth_info
  print @(maxx-5,maxy) "(b)ack"
  print @(1,0) "*"
  print @(0,1) "Because you were born before sunrise, as"
  print "far as the playing cards go, your"
  print "birthday is actually on the day before"
  print "your legal birthday. i.e. "+month_name$(birthmonth)+" "+str$(birthday)
  print "The reason for this is that sunrise is"
  print "traditionally the beginning of a new day."
  print @(0,maxy-3) "Press a key. . ."
  gosub in_key
  if g$="b" goto sunrise
  goto birthcard
fi
if g$="a" then
  birthday=b
  birthday$=str$(birthday)
  if len(birthday$)=1 birthday$="0"+birthday$
  goto birthcard
fi
label new_birthday
if birthday=0 then
  birthmonth=birthmonth-1
  birthday=max_month_days(birthmonth)
  birthmonth$=str$(birthmonth)
  if len(birthmonth$)=1 birthmonth$="0"+birthmonth$
fi
if birthmonth=0 goto birthcard_joker
return
label birth_info
print @(0,0) "( )BIRTH - YEAR:"+birthyear$
print @(bdx,0) "MONTH:"+birthmonth$
print @(maxx-6,0) "DAY:"+birthday$
return
label birthcard
year$=birthyear$
gosub check_leapyear
julian_birthday=julian_date_starts(birthmonth)+birthday
birthcard=55-((birthmonth*2)+birthday)
if (birthcard=0 or (birthmonth=12 and birthday=31)) goto birthcard_joker
birthcard$=a$(birthcard)
goto current_date
label birthcard_joker
print @(0,maxy) "Your birthcard is the Joker!!! Nothing more can be obtained for your birthcard with this particular program. We appologize."
label done
print @(0,maxy+1) "Exiting. . ."
print @(maxx-15,maxy+1) "Please wait. . ."
wait 2
exit
label spread2card
for count=1 to 52
  card$(count)=mid$(spread$,(count*2)-1,2)
next count
return
label basic_layout
for count=0 to maxx
  print @(count,maxy-4) "_"
  print @(count,maxy) "_"
next count
print @(0,maxy) "(q)uit"
return
label check_leapyear
leapyear=0
for count=0 to 96 step 4
  if val(right$(year$,2))=count leapyear=1
next count
max_month_days(2)=28+leapyear
if (julian_birthday=60 and leapyear=0) then
  birthday=28
elsif (julian_birthday=60 and leapyear=1) then
  birthday=29
fi
max_julian_date=337+max_month_days(2)
return
label print_spread
gosub contra_indications
clear screen
print start$
print @(maxx-len(stop$),0) stop$
for count=2 to 8
  print @(0,count) a$(count-1)
  print @(maxx-6,count) b$(count-1)
next count
z=midx-6
card_number=1
for count=1 to 3
  print @(z,1) mid$(crown$,(count*2)-1,2)
  z=z+5
next count
z=midx-16
for count=7 to 1 step -1
  print @(z,2) mercury$(count)
  print @(z,3) venus$(count)
  print @(z,4) mars$(count)
  print @(z,5) jupiter$(count)
  print @(z,6) saturn$(count)
  print @(z,7) sun$(count)
  print @(z,8) moon$(count)
  z=z+5
next count
z=midx-7
ty=1
gosub get_data
gosub print_brackets
goto scan_spread
label print_brackets
print @(z,ty) "["
z=z+3
print @(z,ty) "]"
return
label print_bracket
print @(x,y) "["
x=x+3
print @(x,y) "]"
return
label erase_brackets
print @(z,ty) " "
z=z-3
print @(z,ty) " "
return
label erase_bracket
print @(x,y) " "
x=x-3
print @(x,y) " "
return
label scan_spread
gosub basic_layout
print @(maxx-10,maxy) "(m)ain menu"
if card_number>1 print @(0,maxy-4) "(p)revious"
if card_number<52 print @(maxx-5,maxy-4) "(n)ext"
gosub print_card_data
gosub in_key
if g$="" goto scan_spread
if g$="m" then
  card_number=0
  goto layout
fi
if (card_number<52 and (g$="n" or g$=chr$(21))) then
  gosub erase_brackets
  z=z+5
  card_number=card_number+1
  if card_number=1 then
    z=midx-7
    ty=1
  fi
  if (card_number=4 or card_number=11 or card_number=18 or card_number=25 or card_number=32 or card_number=39 or card_number=46) then
    z=midx-17
    ty=ty+1
  fi
  gosub print_brackets
  gosub get_data
fi
if (card_number>1 and (g$="p" or g$=chr$(8))) then
  gosub erase_brackets
  z=z-5
  card_number=card_number-1
  if card_number=3 then
    z=midx+3
    ty=1
  fi
  if (card_number=10 or card_number=17 or card_number=24 or card_number=31 or card_number=38 or card_number=45) then
    z=midx+13
    ty=ty-1
  fi
  gosub print_brackets
  gosub get_data
fi
gosub print_card_data2
goto scan_spread
label print_card_data
if start_data+2<max_data print @((sdx*2)+9,maxy-4) "(d)own"
if start_data>1 print @(sdx+9,maxy-4) "(u)p"
print @(0,maxy-3) card$(start_data)
print @(0,maxy-2) card$(start_data+1)
print @(0,maxy-1) card$(start_data+2)
return
label print_card_data2
if (start_data+2<max_data and (g$="d" or g$=chr$(10))) then
  start_data=start_data+1
  gosub clear_box
fi
if (start_data>1 and (g$="u" or g$=chr$(11))) then
  start_data=start_data-1
  gosub clear_box
fi
return
label get_data
start_data=1
max_data=1
for count=1 to 52
  card$(count)=""
next count
if card_number=1 then
  spread$="AFFECTS"
  target$="YOU"
  gosub open_file
  spread$="crown_data"
  target$=left$(crown$,2)
fi
if card_number=3 then
  spread$="LIKLY"
  target$="RESPONSE"
  gosub open_file
  spread$="crown_data"
  target$=right$(crown$,2)
fi
if card_number=2 then
  spread$="BIRTH"
  target$="CARD"
  gosub open_file
  spread$="birthcard_data"
  target$=birthcard$
fi
if (card_number>3 and card_number<11) then
  spread$="mercury_data"
  target$=mercury$(11-card_number)
fi
if (card_number>10 and card_number<18) then
  spread$="venus_data"
  target$=venus$(18-card_number)
fi
if (card_number>17 and card_number<25) then
  spread$="mars_data"
  target$=mars$(25-card_number)
fi
if (card_number>24 and card_number<32) then
  spread$="jupiter_data"
  target$=jupiter$(32-card_number)
fi
if (card_number>31 and card_number<39) then
  spread$="saturn_data"
  target$=saturn$(39-card_number)
fi
if (card_number>38 and card_number<46) then
  spread$="sun_data"
  target$=sun$(46-card_number)
fi
if card_number>45 then
  spread$="moon_data"
  target$=moon$(53-card_number)
fi
if card_number=0 then
  spread$="SPREAD"
  target$="RULER"
  gosub open_file
  spread$="crown_data"
  target$=ruler$
fi
label open_file
open dir$+"data" for reading as 1
do
  input #1 f$
  if f$=spread$ break
loop
do
  input #1 f$
  if f$=target$ break
loop
do
  input #1 f$
  if f$=":" break
  if len(card$(max_data)+" "+f$)>maxx max_data=max_data+1
  if card$(max_data)<>"" then card$(max_data)=card$(max_data)+" "+f$ else card$(max_data)=f$:fi
loop
close 1
label clear_box
for count=0 to maxx
  print @(count,maxy-3) " "
  print @(count,maxy-2) " "
  print @(count,maxy-1) " "
next count
return
label current_date
current_weekday=val(left$(date$,1))
current_month=val(mid$(date$,3,2))
current_day=val(mid$(date$,6,2))
current_year=val(mid$(date$,9,4))
year$=str$(current_year)
gosub check_leapyear
current_julian_date=julian_date_starts(current_month)+current_day
command$="bash "+dir$+"weekday.sh "+birthyear$+" "+birthmonth$+" "+birthday$
weekday=val(system$(command$))
birth_weekday=weekday
birth_weekday$=weekday$(weekday)
clear screen
gosub birth_info
gosub basic_layout
print @(maxx-5,maxy) "(b)ack"
print @(0,2) "Your birthcard is the "+birthcard$+"."
print "You were born on a "+birth_weekday$+"."
print @(0,maxy-3) "Press a key..."
gosub in_key
if g$="b" goto birthday
clear screen
gosub birth_info
file$=dir$+birthcard$
open file$ for reading as #1
for age=0 to 89
  print @(0,1) "Extracting Data:"+str$(age)+"%"
  input #1 target$
  gosub split_info
  agecard$(age)=target$
  quad_age$(age)=spread$
  for period=1 to 7
    input #1 target$
    gosub split_info
    period_card$(age,period)=target$
    quad_period$(age,period)=spread$
  next period
  for week=1 to 52
    input #1 target$
    gosub split_info
    week_card$(age,week)=target$
    quad_week$(age,week)=spread$
    for weekday=1 to 7
      input #1 target$
      gosub split_info
      weekday_card$(age,week,weekday)=target$
      quad_weekday$(age,week,weekday)=spread$
    next weekday
  next week
  for day=0 to 365
    input #1 target$
    gosub split_info
    day_card$(age,day)=target$
    quad_day$(age,day)=spread$
  next day
next age
close 1
print @(16,1) "100%"
print @(0,2) "Done"
goto cal_max_lifedays
label layout
if year<birthyear year=birthyear
if year>max_year year=max_year
if (year=birthyear and month<birthmonth) month=birthmonth
if (year=max_year and month>max_month) month=max_month
if (year=birthyear and month=birthmonth and day<birthday) day=birthday
if (year=max_year and month=max_month and day>max_day) day=max_day
if day>max_month_days(month) day=max_month_days(month)
age=val(mid$(lifeday$(year,month,day),1,2))
week$=mid$(lifeday$(year,month,day),3,2)
week=val(week$)
p=val(mid$(lifeday$(year,month,day),5,1))
pcard=val(mid$(lifeday$(year,month,day),6,2))
wdn=val(mid$(lifeday$(year,month,day),8,1))
weekday=val(mid$(lifeday$(year,month,day),9,1))
d=val(mid$(lifeday$(year,month,day),10,3))
year$=str$(year)
gosub check_leapyear
if len(str$(month))=1 then month$="0"+str$(month) else month$=str$(month):fi
if len(str$(day))=1 then day$="0"+str$(day) else day$=str$(day):fi
label spread_layout
clear screen
start$=""
stop$=""
for count=1 to 7
  a$(count)=""
  b$(count)=""
next count
gosub birth_info
print @(0,1) "TARGET - ( )YEAR:"+year$
print @(bdx-2,1) "( )MONTH:"+month$
print @(maxx-8,1) "( )DAY:"+day$
print @(0,2) "Available Spreads:"
print @(maxx-12,2) "Ruling Card:"
for count=0 to maxx-4
  print @(count,3) "_"
  print @(count,4) "_"
next count
print @(0,3) "1 - Age:"+str$(age)
print @(0,4) "2 - Day:#"+str$(d)
print @(maxx-2,3) agecard$(age)
print @(maxx-2,4) day_card$(age,d)
print @(0,8) "Please choose:"
print @(16,8) "1 or 2":
if p=0 max_indicator=6
if p<>0 then
  for count=0 to maxx-4
    print @(count,5) "_"
    print @(count,6) "_"
    print @(count,7) "_"
  next count
  print @(0,5) "3 - 7-Week/52-Day:#"+str$(p)
  print @(0,6) "4 - Week:#"+week$
  print @(0,7) "5 - Weekday:"+weekday$(weekday)
  print @(maxx-2,5) period_card$(age,p)
  print @(maxx-2,6) week_card$(age,week)
  print @(maxx-2,7) weekday_card$(age,week,wdn)
  print @(16,8) "1 - 2 - 3 - 4 - 5"
  max_indicator=9
fi
gosub if_indicator
label spread_menu
if indicator>1 print @(0,maxy-4) "(p)revious"
if indicator<max_indicator print @(maxx-5,maxy-4) "(n)ext"
if indicator>4 then
  print @(maxx-12,maxy) "(s)how spread"
  gosub print_bracket
else print @(x,y) "*"
fi
label main_menu
if indicator>4 gosub print_card_data
gosub in_key
if (indicator<max_indicator and (g$="n" or g$=chr$(21))) then
  if indicator<5 print @(x,y) " "
  if indicator>4 gosub erase_bracket
  indicator=indicator+1
  gosub if_indicator
  goto spread_menu
fi
if (indicator>1 and (g$="p" or g$=chr$(8))) then
  if indicator<5 print @(x,y) " "
  if indicator>4 gosub erase_bracket
  indicator=indicator-1
  gosub if_indicator
  goto spread_menu
fi
gosub print_card_data2
if (g$="1" or g$="2" or g$="3" or g$="4" or g$="5") goto see_spread
if indicator>4 then
  if g$="s" then
    g$=str$(card)
    goto see_spread
  fi
fi
if indicator=2 then
  if ((g$="u" or g$=chr$(11)) and year<max_year) then
    year=year+1
    goto layout
  fi
  if ((g$="d" or g$=chr$(10)) and year>birthyear) then
    year=year-1
    goto layout
  fi
fi
if indicator=3 then
  if (year=birthyear and month=birthmonth) goto plus_month
  if (g$="d" or g$=chr$(10)) then
    month=month-1
    if month=0 then
      year=year-1
      month=12
    fi
    goto layout
  fi
label plus_month
  if (year=max_year and month=max_month) goto main_menu
  if (g$="u" or g$=chr$(11)) then
    month=month+1
    if month=13 then
      year=year+1
      month=1
    fi
    goto layout
  fi
fi
if indicator=4 then
  if (year=birthyear and month=birthmonth and day=birthday) goto plus_day
  if (g$="d" or g$=chr$(10)) then
    day=day-1
    if day=0 then
      month=month-1
      if month=0 then
        year=year-1
        month=12
      fi
      day=max_month_days(month)
    fi
    goto layout
  fi
label plus_day
  if (year=max_year and month=max_month and day=max_day) goto layout
  if (g$="u" or g$=chr$(11)) then
    day=day+1
    if day>max_month_days(month) then
      month=month+1
      day=1
    fi
    if month=13 then
      year=year+1
      month=1
    fi
    goto layout
  fi
fi
goto main_menu
label check_weekday
if weekday<0 then
  do
    weekday=weekday+7
    if weekday>-1 return
  loop
elsif weekday>6 then
  do
    weekday=weekday-7
    if weekday<7 return
  loop
fi
return
label change_date
for m=1 to 11
  if (julian_date>julian_date_starts(m) and julian_date<=julian_date_starts(m+1)) month=m
next m
if julian_date>julian_date_starts(12) month=12
day=julian_date-julian_date_starts(month)
return
label cal_max_lifedays
max_year=birthyear+90
year$=str$(max_year)
gosub check_leapyear
julian_date=julian_birthday-1
gosub change_date
max_month=month
max_day=day
day_before_birthday$=left$(month_name$(month),3)+" "+str$(day)
dim lifeday$(max_year,12,31)
montha=birthmonth
monthb=12
daya=birthday
for count=0 to 6
  period(count+1)=(count*52)+1
next count
for year=birthyear to max_year
  year$=str$(year)
  gosub check_leapyear
  if year=max_year monthb=max_month
  for month=montha to monthb
    dayb=max_month_days(month)
    if (year=max_year and month=max_month) dayb=max_day
    for day=daya to dayb
      if (year=birthyear and month=birthmonth and day=birthday) then
        year$=str$(year)
        gosub check_leapyear
        weekday=birth_weekday
        age=-1
        week=0
      fi
      if (month=birthmonth and day=birthday) then
        d=0
        p=0
        wndate=0
        age=age+1
        print @(0,3) "Compiling data:"+str$(age)+"%"
      fi
      if d=1 wds(age)=weekday
      if (d=1 or d=53 or d=105 or d=157 or d=209 or d=261 or d=313 or d=365) then
        p=p+1
        if p=8 p=0
        pcard=1
      fi
      if p=0 pcard=0
      p$=str$(p)
      for count=0 to 51
        if d=(count*7)+1 then
          week=week+1
          wndate=1
        fi
      next count
      if (d=365 or d=0) then
        week=0
        wdn=0
      fi
      if len(str$(week))=1 then week$="0"+str$(week) else week$=str$(week):fi
      wdn$=str$(wdn)
      if len(str$(month))=1 then month$="0"+str$(month) else month$=str$(month):fi
      if len(str$(day))=1 then day$="0"+str$(day) else day$=str$(day):fi
      if len(str$(age))=1 then age$="0"+str$(age) else age$=str$(age):fi
      if len(str$(d))=1 d$="00"+str$(d)
      if len(str$(d))=2 d$="0"+str$(d)
      if len(str$(d))=3 d$=str$(d)
      if len(str$(pcard))=1 then pcard$="0"+str$(pcard) else pcard$=str$(pcard):fi
      if (wndate>0 and wndate<8) weekdate$(age,week,wndate)=left$(month_name$(month),3)+" "+day$
      if pcard=1 then
        pdate$(age,p,1)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,1)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=7 then
        pfinish$(age,p,1)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,2)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=14 then
        pfinish$(age,p,2)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,3)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=22 then
        pfinish$(age,p,3)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,4)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=29 then
        pfinish$(age,p,4)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,5)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=37 then
        pfinish$(age,p,5)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,6)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=44 then
        pfinish$(age,p,6)=left$(month_name$(month),3)+" "+day$
        pstart$(age,p,7)=left$(month_name$(month),3)+" "+day$
      fi
      if pcard=52 then
        pfinish$(age,p,7)=left$(month_name$(month),3)+" "+day$
        pdate$(age,p,2)=left$(month_name$(month),3)+" "+day$
      fi
      if wdn=1 wdate$(age,week,1)=left$(month_name$(month),3)+" "+day$
      if wdn=7 wdate$(age,week,2)=left$(month_name$(month),3)+" "+day$
      lifeday$(year,month,day)=age$+week$+p$+pcard$+wdn$+str$(weekday)+d$
      wdn=wdn+1
      wndate=wndate+1
      if wdn=8 wdn=1
      d=d+1
      pcard=pcard+1
      weekday=weekday+1
      gosub check_weekday
    next day
    daya=1
  next month
  montha=1
  julian_date=1
next year
print @(15,3) "100%"
print @(0,4) "Done."
day=current_day:year=current_year
month=current_month:x=10:y=1
card_number=0:card=0:indicator=2
goto layout
label if_indicator
if indicator=1 goto pre_birthyear
if indicator=2 then
  x=10:y=1
  print @(x,y) "*"
  gosub basic_layout
  if year<max_year print @(sdx+9,maxy-4) "(u)p"
  if year>birthyear print @((sdx*2)+9,maxy-4) "(d)own"
fi
if indicator=3 then
  x=bdx-1:y=1
  print @(x,y) "*"
  gosub basic_layout
  if (year<max_year or (year=max_year and month<max_month)) print @(sdx+9,maxy-4) "(u)p"
  if (year>birthyear or (year=birthyear and month>birthmonth)) print @((sdx*2)+9,maxy-4) "(d)own"
fi
if indicator=4 then
  x=maxx-7:y=1:card=0
  print @(x,y) "*"
  gosub basic_layout
  if (year<max_year or (year=max_year and month<max_month) or (year=max_year and month=max_month and day<max_day)) print @(sdx+9,maxy-4) "(u)p"
  if (year>birthyear or (year=birthyear and month>birthmonth) or (year=birthyear and month=birthmonth and day>birthday)) print @((sdx*2)+9,maxy-4) "(d)own"
  gosub clear_box
fi
if indicator=5 then
  x=maxx-3:y=3:card=1
  gosub spread_menu_card
  gosub get_data
  gosub basic_layout
fi
if indicator=6 then
  x=maxx-3:y=4:card=2
  gosub spread_menu_card
  gosub get_data
  gosub basic_layout
fi
if indicator=7 then
  x=maxx-3:y=5:card=3
  gosub spread_menu_card
  gosub get_data
  gosub basic_layout
fi
if indicator=8 then
  x=maxx-3:y=6:card=4
  gosub spread_menu_card
  gosub get_data
  gosub basic_layout
fi
if indicator=9 then
  x=maxx-3:y=7:card=5
  gosub spread_menu_card
  gosub get_data
  gosub basic_layout
fi
return
label see_spread
if g$="1" then
  spread$=quad_age$(age)
  if (birthmonth<month or (birthmonth=month and birthday<day)) then
    start$=pdate$(age,1,1)+", "+str$(year)
    stop$=pdate$(age,7,2)+", "+str$(year+1)
  fi
  if (birthmonth>month or (birthmonth=month and birthday>=day)) then
    start$=pdate$(age,1,1)+", "+str$(year-1)
    stop$=pdate$(age,7,2)+", "+str$(year)
  fi
  if (birthday=1 and birthmonth=1) then
    start$=pdate$(age,1,1)+", "+str$(year)
    stop$=pdate$(age,7,2)+", "+str$(year)
  fi
  for count=1 to 7
    a$(count)=pdate$(age,count,1)
    b$(count)=pdate$(age,count,2)
  next count
  goto print_spread
fi
if g$="2" then
  spread$=quad_day$(age,d)
  goto print_spread
fi
if p<>0 then
  if g$="3" then
    start$="From:"+pdate$(age,p,1)
    stop$="To:"+pdate$(age,p,2)
    spread$=quad_period$(age,p)
    if p=1 wkn=0
    if p=2 wkn=7
    if p=3 wkn=15
    if p=4 wkn=22
    if p=5 wkn=30
    if p=6 wkn=38
    if p=7 wkn=45
    for count=1 to 7
      a$(count)=pstart$(age,p,count)
      b$(count)=pfinish$(age,p,count)
    next count
    goto print_spread
  fi
  if g$="4" then
    for count=0 to 6
      wd=wds(age)+count
      if wd>6 wd=wd-7
      a$(count+1)=left$(weekday$(wd),3)
      b$(count+1)=weekdate$(age,week,count+1)
    next count
    start$="From:"+a$(1)+", "+wdate$(age,week,1)
    stop$="To:"+a$(7)+", "+wdate$(age,week,2)
    spread$=quad_week$(age,week)
    goto print_spread
  fi
  if g$="5" then
    spread$=quad_weekday$(age,week,wdn)
    goto print_spread
  fi
fi
goto spread_menu
label spread_menu_card
if card=1 ruler$=agecard$(age)
if card=2 ruler$=day_card$(age,d)
if card=3 ruler$=period_card$(age,p)
if card=4 ruler$=week_card$(age,week)
if card=5 ruler$=weekday_card$(age,week,wdn)
return
label contra_indications
crown$=left$(spread$,6)
for count=4 to 52
  f$=mid$(spread$,(count*2)-1,2)
  if count<11 mercury$(count-3)=f$
  if (count>10 and count<18) venus$(count-10)=f$
  if (count>17 and count<25) mars$(count-17)=f$
  if (count>24 and count<32) jupiter$(count-24)=f$
  if (count>31 and count<39) saturn$(count-31)=f$
  if (count>38 and count<46) sun$(count-38)=f$
  if (count>45 and count<53) moon$(count-45)=f$
next count
mercury$(0)="00":mercury$(8)="00":contra$=""
for count=1 to 7
  if mercury$(count)="6H" then
    for a=1 to 7
      if mercury$(a)="5H" mercury$(a)="00"
    next a
  fi
  if mercury$(count)="TC" then
    if (mercury$(count-1)="7C" or mercury$(count-1)="9C") mercury$(count-1)="00"
    if (mercury$(count+1)="7C" or mercury$(count+1)="9C") mercury$(count+1)="00"
  fi
  if mercury$(count)="6D" contra$=contra$+"5D"
  if mercury$(count)="7S" contra$=contra$+"8S"
  if venus$(count)="6D" then
    for a=1 to 7
      if (venus$(a)="5H" or venus$(a)="5D") venus$(a)="00"
    next a
  fi
  if (venus$(count)="8D" or venus$(count)="TD") then
    for a=1 to 7
      if venus$(a)="9D" venus$(a)="00"
    next a
  fi
  if venus$(count)="7S" contra$=contra$+"7H"
  if mars$(count)="4D" contra$=contra$+"5D7D"
  if mars$(count)="6D" then
    for a=1 to 7
      if (mars$(a)="5D" or mars$(a)="7D") mars$(a)="00"
    next a
  fi
  if mars$(count)="4S" contra$=contra$+"5S7S"
  if jupiter$(count)="6S" then
    for a=1 to 7
      if (left$(jupiter$(a),1)="5" or left$(jupiter$(a),1)="7") jupiter$(a)="00"
    next a
  fi
  if saturn$(count)="6D" contra$=contra$+"5D7D"
  if saturn$(count)="4S" then
    for a=1 to 7
      if saturn$(a)="7S" saturn$(a)="00"
    next a
  fi
  if saturn$(count)="TS" contra$=contra$+"9S"
  if sun$(count)="6C" contra$=contra$+"5C"
  if sun$(count)="6D" contra$=contra$+"5D5S"
  if moon$(count)="6C" then
    if left$(mercury$(count),1)="5" mercury$(count)="00"
  fi
  if moon$(count)="9C" contra$=contra$+"TC"
  if moon$(count)="6D" then
    b=0
    for a=1 to 7
      if left$(moon$(a),1)="5" b=b+1
    next a
    if b=1 then
      for a=1 to 7
        if left$(moon$(a),1)="5" moon$(a)="00"
      next a
    fi
  fi
  if moon$(count)="7D" contra$=contra$+"8D"
  if moon$(count)="6S" contra$=contra$+"5S7S"
next count
if contra$<>"" then
  b=len(contra$)/2
  for count=1 to 7
    for a=1 to b
      f$=mid$(contra$,(a*2)-1,2)
      if mercury$(count)=f$ mercury$(count)="00"
      if venus$(count)=f$ venus$(count)="00"
      if mars$(count)=f$ mars$(count)="00"
      if jupiter$(count)=f$ jupiter$(count)="00"
      if saturn$(count)=f$ saturn$(count)="00"
      if sun$(count)=f$ sun$(count)="00"
      if moon$(count)=f$ moon$(count)="00"
    next a
  next count
fi
return
label in_key
g$=inkey$
g$=lower$(g$)
if lower$(g$)="q" goto done
return
label in_put
input ":" g$
g$=lower$(g$)
if g$="q" goto done
return
goto done
label split_info
spread$=right$(target$,104)
target$=left$(target$,2)
return
EOF
chmod +x $file2
cat > $file3 <<- 'EOF'
SPREAD RULER The card that occupys this space is the card that rules the entire spread. This card sets the main theme (and shows the main lesson) for this chosen time period. :
AFFECTS YOU The card that occupys this space, shows the overall affect that this spread has on you for the selected time period. :
BIRTH CARD The card that occupys this space is your birthcard which is the :
LIKLY RESPONSE The card that occupys this space, shows the most likly way that you respond to this spread for the selected time period. :
birthcard_data AH ~Ace of Hearts~ : 2H ~Two of Hearts~ : 3H ~Three of Hearts~ : 4H ~Four of Hearts~ : 5H ~Five of Hearts~ : 6H ~Six of Hearts~ : 7H ~Seven of Hearts~ : 8H ~Eight of Hearts~ : 9H ~Nine of Hearts~ : TH ~Ten of Hearts~ : JH ~Jack of Hearts~ : QH ~Queen of Hearts~ : KH ~King of Hearts~ : AC ~Ace of Clubs~ : 2C ~Two of Clubs~ : 3C ~Three of Clubs~ : 4C ~Four of Clubs~ : 5C ~Five of Clubs~ : 6C ~Six of Clubs~ : 7C ~Seven of Clubs~ : 8C ~Eight of Clubs~ : 9C ~Nine of Clubs~ : TC ~Ten of Clubs~ : JC ~Jack of Clubs~ : QC ~Queen of Clubs~ : KC ~King of Clubs~ : AD ~Ace of Diamonds~ : 2D ~Two of Diamonds~ : 3D ~Three of Diamonds~ : 4D ~Four of Diamonds~ : 5D ~Five of Diamonds~ : 6D ~Six of Diamonds~ : 7D ~Seven of Diamonds~ : 8D ~Eight of Diamonds~ : 9D ~Nine of Diamonds~ : TD ~Ten of Diamonds~ : JD ~Jack of Diamonds~ : QD ~Queen of Diamonds~ : KD ~King of Diamonds~ : AS ~Ace of Spades~ : 2S ~Two of Spades~ : 3S ~Three of Spades~ : 4S ~Four of Spades~ : 5S ~Five of Spades~ : 6S ~Six of Spades~ : 7S ~Seven of Spades~ : 8S ~Eight of Spades~ : 9S ~Nine of Spades~ : TS ~Ten of Spades~ : JS ~Jack of Spades~ : QS ~Queen of Spades~ : KS ~King of Spades~ :
crown_data AH ~Ace of Hearts~ This card represents a new beginning, such as a new relationship, marriage, or some good news. : 2H ~Two of Hearts~ This card suggests that it's time to spend some quality time with your loved ones. : 3H ~Three of Hearts~ This card indicates indecision or a lack of commitment in a relationship. : 4H ~Four of Hearts~ This card shows a stable, secure, and committed relationship or marriage. : 5H ~Five of Hearts~ This card indicates that a major change is coming to you, your home, or your family. This change could be a possible divorce, or a loved one moving away, or even a change of residence i.e. a new home. : 6H ~Six of Hearts~ This card generally shows a time of peace and harmony where you can work well with others to achieve your goals and overcome obstacles. : 7H ~Seven of Hearts~ This is a somewhat lonely card which usually represents a partner or friend who is undependable and will let you down. : 8H ~Eight of Hearts~ This is the 'friends' card, but it can also indicate an upcoming social event which can provide you with important business and/or romantic connections. : 9H ~Nine of Hearts~ This card generally shows wishing for more out of a relationship, like maybe having a baby or even taking your relationship to the next level. : TH ~Ten of Hearts~ This card usually shows that good news is coming, or it can indicate that there will be a large gathering of people at a party or perhaps even a wedding. : JH ~Jack of Hearts~ This card usually represents your lover or best friend. It can also signify a couple when paired with the Queen of Hearts. : QH ~Queen of Hearts~ This card represents a female lover or fantasy which is sometimes an indication of marriage. It may also represent a mother or even a pregnant woman. : KH ~King of Hearts~ This card usually represents an influential man who is romantic and affectionate but also emotional. It could indicate a father. : AC ~Ace of Clubs~ This card shows a thirst for knowledge, but can also indicate a special talent that you have. : 2C ~Two of Clubs~ This card serves as a reminder of the importance of communication to avoid confrontations and disappointment. : 3C ~Three of Clubs~ This card shows immense creativity, but can also reference the stress that is often associated with the creative process. It can also indicate confusion. : 4C ~Four of Clubs~ This card shows mental stability that may lead you on a great adventure. : 5C ~Five of Clubs~ This card serves as an indication that it's time to make a change and learn something new like a new hobby or sport. : 6C ~Six of Clubs~ This card shows that your intuition is on point and that you need to trust it in order to receive great benefits. : 7C ~Seven of Clubs~ This card represents feeling confined or trapped, usually in regards to a romantic relationship. : 8C ~Eight of Clubs~ This card indicates a time of confusion that can lead to significant problems in your relationships if things are not resolved. : 9C ~Nine of Clubs~ This card represents the completion of a project or phase of your life. : TC ~Ten of Clubs~ This card shows a great possibility of traveling in the near future. : JC ~Jack of Clubs~ This card represents an honest and trustworthy person who may be your friend. : QC ~Queen of Clubs~ This card represents a charismatic woman who is in a position of power. : KC ~King of Clubs~ This card represents a man of integrity who is a generous and loyal friend. : AD ~Ace of Diamonds~ This card is an indication of an important message that is coming which usually relates to your love life or to business. : 2D ~Two of Diamonds~ This card shows that good news regarding your finances or investments will be coming soon. : 3D ~Three of Diamonds~ This card shows indecisiveness regarding money which could lead to arguments and possible legal issues. : 4D ~Four of Diamonds~ This card reminds you that financial responsibility is necessary in order to achieve stability and prosperity. : 5D ~Five of Diamonds~ This card shows that a financial change is coming. This may be a positive change (i.e. getting a new job), or a negative one (i.e. an unexpected expense). : 6D ~Six of Diamonds~ This card indicates a need to assume financial responsibility over your cashflow in all areas. : 7D ~Seven of Diamonds~ This card is usually a warning to be careful with your investments. It shows financial troubles are coming. : 8D ~Eight of Diamonds~ This card is an indicator of unexpected financial gains coming to you. It would be wise to consider a budget or even plan for savings. : 9D ~Nine of Diamonds~ This card shows an upcoming expense i.e. repairs, bills, or maybe a large purchase. : TD ~Ten of Diamonds~ This card is considered a great sign, and usually represents a big financial success coming to you. : JD ~Jack of Diamonds~ This card represents someone who will be the bearer of bad news. : QD ~Queen of Diamonds~ This card represents a sophisticated woman who loves to party and gossip. : KD ~King of Diamonds~ This card represents a powerful and successful businessman. : AS ~Ace of Spades~ This card shows a time of significant change. Something will end in order to make room for something else. : 2S ~Two of Spades~ This card shows a difficult situation or decision which may cause a division between you and a loved one or friend. : 3S ~Three of Spades~ This card indicates tears which are a reaction to a stressful situation involving bad news, fear, indecision, or your job. : 4S ~Four of Spades~ This card is an indication that stability will soon return to your workplace or to your health. It shows that the troubling times are almost over. : 5S ~Five of Spades~ This card indicates that you will be moving on soon, and leaving behind what you currently know; such as a new job, a relocation, or the end of a relationship. : 6S ~Six of Spades~ This card is usually a warning that fate will soon strike and impact either you, your work, or your finances. : 7S ~Seven of Spades~ This card shows the loss of a significant person in your life due to a disagreement or problem. : 8S ~Eight of Spades~ This card indicates that obstacles may soon put you at a crossroad where you will need to make an important decision. : 9S ~Nine of Spades~ This card is a sign that there will be a loss or an ending in your life, possibly even the death of someone close to you. IMPORTANT: If this card is found next to your birth card and either the Seven of Spades or the Seven of Hearts is found on the other side of your birthcard then be EXTREMELY careful because it could be sign of your death! : TS ~Ten of Spades~ This card shows worry and grief which might have come from health problems, fear, or bad news. : JS ~Jack of Spades~ This card represents a negative person in your life who may betray you or hold you back. : QS ~Queen of Spades~ This card represents a cruel woman who is extremely manipulative and malicious. : KS ~King of Spades~ This card represents an authoritative man who may create trouble in a relationship. :
mercury_data AH ~Ace of Hearts~ This card shows a wish for warm love, or longing for affection from the opposite sex. It can also mean news from a friend near at hand. Or even a telegram or a telephone message. : 2H ~Two of Hearts~ This card shows a sudden passion for one of the opposite sex or meeting an old friend unexpectedly. It can also show a friendly offer or proposal. Or even an invitation to a party. : 3H ~Three of Hearts~ This card shows an indecision of mind regarding love or matrimony or even two lovers at one time. This card can also show perplexity regarding your friends or an indecision in relation to a visit. : 4H ~Four of Hearts~ This card shows satisfaction and success in love or a sudden and unexpected happiness. It can also mean pleasure in making new friends or pleasure and happiness at home. : 5H ~Five of Hearts~ This card shows a sudden change in life or a change in feelings. It usually represents the removal of one's home somewhat unexpectedly or a short journey to the home of friends. : 6H ~Six of Hearts~ This card shows an even temper and dispassionate qualities or can indicate things currently running smoothy in life with few (if any) changes. : 7H ~Seven of Hearts~ This card shows a sudden and generally unexpected trouble but lasting only for a short time. It can also indicate a sudden cooling of a friendship or even a fever but of a short duration. : 8H ~Eight of Hearts~ This card shows sudden power which gets quickly expended or it can mean power in the development of love. It can also indicate gatherings of friends or societies; dancing parties, the theater, etc. : 9H ~Nine of Hearts~ This card shows a sudden disappointment soon over and gone. It can also mean the overturning of plans by a trusted friend or employee. Or even a love disappointment. : TH ~Ten of Hearts~ This card shows a sudden success, or success in love and friendship. It can also mean the rapid gaining of friends or strong affection. If it's paired with a queen then it's success of a lady friend. : JH ~Jack of Hearts~ This card represents a lover, a very close friend, or even an affectionate and impulsive young person. It can also symbolize a friend who is in sudden need, and in some cases, it may indicate a sibling or an offspring. : QH ~Queen of Hearts~ This card shows a flighty, merry, lighthearted maiden, who loves parties, picnics, balls, etc. Sometimes it indicates a female flirt, in other cases it shows a sweetheart. : KH ~King of Hearts~ This card shows a middle-aged or elderly gentleman, but one who is good tempered and of a kindly disposition. This person is a friend to you. : AC ~Ace of Clubs~ This card indicates a wish that is suddenly formed, or an aspiration for knowledge. It can also indicate a letter containing a secret, or a piece of news from a short distance. : 2C ~Two of Clubs~ This card shows a dispute with a hotheaded person or can indicate a sudden meeting with a person whom you've had prior dealing with. When paired with an ace, it can mean either a letter or telegram. : 3C ~Three of Clubs~ This card shows an indecision which is relative to a short journey, or being undecided as to two lines of study. It can also mean that two ways open up to you, or that you are needed in two places at the same time. : 4C ~Four of Clubs~ This card shows happiness but only lasting for a short time. It can also mean that a pleasant companion or even a good book is in your company and/or possession, but for a short time only. : 5C ~Five of Clubs~ This card usually indicates a sudden change in feelings, or a change in knowledge and mentality. It can also signal a journey to a place nearby, or sudden news which is received. : 6C ~Six of Clubs~ This card shows unchangeableness or monotony but only lasting for a few days. It can also mean steadfast confidence and esteem for friends, or remaining quiet at home. : 7C ~Seven of Clubs~ This card shows a trouble that comes suddenly, or an opposition to your projects. It can also show an inharmony of feelings, or an obstacle to gaining knowledge. It can also indicate bad news that comes from a distance. : 8C ~Eight of Clubs~ This card shows a rapid development or growth, such as a rapid gaining of knowledge. It also shows strength and courage, and can signify the overcoming of obstacles to advancement. It can also indicate meetings for purposes of advancement. : 9C ~Nine of Clubs~ This card shows a sudden disappointment and bad news, or even knowledge of a dissatisfying nature. It can also indicate a sudden dislike, or a discouragement caused by some sort of antagonism. : TC ~Ten of Clubs~ This card shows a sudden and sometimes unexpected success or good news. It can be an indication of success in gaining knowledge. : JC ~Jack of Clubs~ This card shows a quick-witted and intelligent young person; in some cases, a rival, in other cases, a lawyer friend. If this card has an odd diamond card on both sides of it then it indicates a business rival. : QC ~Queen of Clubs~ This card shows a smart, lively lady who is both intelligent and quick witted; most likely a rapid reader. This card represents a lady who possesses knowledge of an unusual character. : KC ~King of Clubs~ This card shows a quick tempered, smart, lively, and witty man. One who is quick to grasp a point. Kings generally represent either married men, or men who are of middle or advanced age. : AD ~Ace of Diamonds~ This card shows a wish to make money rapidly, or a sudden aspiration connected with money. It can also indicate a telegram or letter regarding financial matters. : 2D ~Two of Diamonds~ This card shows a business arrangement very suddenly concluded, a business interview or message. It can also indicate an unexpected pecuniary offer. : 3D ~Three of Diamonds~ This card shows a sudden indecision regarding a pecuniary matter, or doubt and distrust regarding business. It can show a feeling of uneasy insecurity, or it can be an indication of two business ways opening at once. : 4D ~Four of Diamonds~ This card has several possible meanings. It can indicate satisfaction in a pecuniary affair, or a sudden receipt of money when hardly expected. It can show that an indecision finally comes to an end, or even mean that your hopes will be suddenly realized. : 5D ~Five of Diamonds~ This card shows a sudden and unexpected change which affects your financial status or arrangements, or that of someone connected in a business way. : 6D ~Six of Diamonds~ This card indicates that financial matters will settle down soon. It can also mean that you will not make a business journey at this chosen time. : 7D ~Seven of Diamonds~ This card can show an unexpected call for money, or trouble regarding a financial matter. It can also indicate a sudden and unexpected loss of money or property of some kind. : 8D ~Eight of Diamonds~ This card shows a sudden accession of power, or a rapid gaining of ends sought when related to money matters. Whatever trouble that may be indicated by the Seven of Diamonds, this card indicates that you overcome it. : 9D ~Nine of Diamonds~ This card shows financial disappointment, generally coming suddenly or connected with some speculation. It can also mean disappointment in regards to a short journey. : TD ~Ten of Diamonds~ This card shows financial success coming suddenly, i.e. a streak of good fortune. It can also indicate success in a speculation, or even the success of a short journey. : JD ~Jack of Diamonds~ This card represents a young person who spends money freely and makes money easily. Usually this person is connected to something rapid i.e. a railroad man. : QD ~Queen of Diamonds~ This card represents a lady who loves excitement i.e. parties, operas, every place where wealth is displayed. She loves money and luxury. : KD ~King of Diamonds~ This card represents a sharp, quick, active, money-making business man. It shows a man who makes money fluctuating. Sometimes a speculator. : AS ~Ace of Spades~ This card shows a secret; such as a secret wish, a secret knowledge, a secret resolution, or even a secret society. : 2S ~Two of Spades~ This card shows a sudden union, or an agreement to work for another. It can also indicate an unexpected offer of a piece of work, or even a pressing engagement. : 3S ~Three of Spades~ This card shows two offers of some kind relating to work, or two ways open up to you. It can also indicate a case that arises suddenly where you must decide between two courses of action. : 4S ~Four of Spades~ This card shows satisfaction, but of a limited duration, or the realization of expectations coming suddenly. It can also indicate unlooked for success in some piece of work, or a case that is suddenly decided. : 5S ~Five of Spades~ This card can signify a sudden journey, a change in employment, or a change in business methods. It can also indicate news of a distant transaction. : 6S ~Six of Spades~ This card counteracts any changes shown in this line, and signifies a settlement of difficulties. It can also indicate an end to worry, or steady and satisfactory employment. : 7S ~Seven of Spades~ This card shows trouble in some matter connected with your work, or possibly a sudden accident and/or illness. It could also just indicate a headache and severe throbbing. : 8S ~Eight of Spades~ This card shows an ability to succeed against antagonistic circumstances, or the overcoming of an obstacle. It can also indicate a rapid accomplishment of work, or the power to control and carry on a profession or labor. : 9S ~Nine of Spades~ This card shows a bitter disappointment, but one that will soon pass, or a dissatisfaction with labor. It can also indicate a sudden illness or accident; i.e. an injury to some person. : TS ~Ten of Spades~ This card can show professional success, successful labor, or even success in some speculation. It can also indicate a quick return for labor performed, or success in a business that is connected with rapid transportation. : JS ~Jack of Spades~ This card shows an industrious young person, or someone who is engaged in a line of work that requires quickness and skill; a successful person in most cases. : QS ~Queen of Spades~ This card shows an industrious lady who is quick of motion and hurries about her work. One who is generally quite nervous in temperament. : KS ~King of Spades~ This card shows an energetic business man, or a quick tempered, hardworking, rushing man. One who employs many workers in some cases. :
venus_data AH ~Ace of Hearts~ This card shows a wish for love, friendship, and affection, or a desire for harmony. It can also indicate a love letter, a letter of friendship, proposal of marriage by letter, or even an invitation to a party. : 2H ~Two of Hearts~ This card shows a union of hearts, such as the meeting of dear friends or lovers. If this card is paired with the Eight of Hearts it indicates a wedding. If it is between the Queen of Hearts and Jack of Hearts it shows a marriage engagement. : 3H ~Three of Hearts~ This card shows perplexity of the heart, or an indecision regarding love. It can be a strong indication of having two lovers at the same time, or just simply mean that one is undecided as to attending a place of amusement or instruction. : 4H ~Four of Hearts~ This card can show contentment or satisfaction in love and friendship, or indicate a happy home. If this card is followed by the Eight of Clubs and Ten of Hearts, it shows satisfaction and success with unseen forces, influences, and friends. : 5H ~Five of Hearts~ This card shows a change in love or friendship, or the parting of friends. It can also indicate a journey to another city or town. If this card falls between the King and Queen of Hearts, it means a separation or a divorce. : 6H ~Six of Hearts~ This card shows contentment for a season; i.e. love and friendship running smoothly and without much variety, or it can indicate married happiness. : 7H ~Seven of Hearts~ This card shows an unfaithful friend or lover, or a heartache caused by a friend. It can also indicate a trouble which is easily overcome, or even the illness of some friend. : 8H ~Eight of Hearts~ This card shows spiritual force, power and development, or advancement in soul force. It can also indicate social and religious gatherings, or an increase in friendship and love. : 9H ~Nine of Hearts~ This card can show disappointment in love, disappointment in some friend, a heart that is longing remains unsatisfied, a misunderstanding, or disapprobation with the conduct of a friend. : TH ~Ten of Hearts~ This card shows success, triumph and happiness in friendship and love. It can also indicate a successful love affair, or signify true love from one of the opposite sex for yourself. : JH ~Jack of Hearts~ This card can represent a warm friend or lover, a kind-hearted young person, or an amiable person who is also a true friend. Sometimes, it signifies a young relative. : QH ~Queen of Hearts~ This card represents a warm-hearted, loving, faithful woman with the disposition of kindness and self-sacrifice, or an affectionate sweetheart. : KH ~King of Hearts~ This card represents a mild mannered, kindly, warm-hearted man. He is a good friend, or in some cases a near relative by blood or marriage. It can also indicate a kind and affectionate husband. : AC ~Ace of Clubs~ This card shows a love of knowledge, or a gratified wish. It can also indicate a letter when in conjunction with twos. Good news in a letter or telegram. : 2C ~Two of Clubs~ This card can show unions of acquaintances, an introduction of a lady of intelligence, joining in study of two persons, or information regarding a subject of study. : 3C ~Three of Clubs~ This card shows indecision or doubt in an affair of friendship with a woman, or undecided news or doubt regarding a lady friend. It can also show two ways opening up to you. : 4C ~Four of Clubs~ This card shows a happy home life, comfort and joy, or knowledge of a comforting nature. It can also indicate the enjoyment of spiritual or mental privileges. : 5C ~Five of Clubs~ This card can show a sudden change in friendship (which can be either way), a change of mind regarding a female friend, or the company of an entertaining friend. : 6C ~Six of Clubs~ This card can show uniform and unchanging friendship, knowledge and surroundings remain the same, a lack of news, or the quiet monotony of life. : 7C ~Seven of Clubs~ This card shows unfulfilled hopes, or some kind of trouble or quarrel with a woman. It can also be an indication of an opposition to some belief held by you, or a rejected favor or request. : 8C ~Eight of Clubs~ This card can show spiritual development or psychic powers, feminine advancement in favor of gaining knowledge, or it can represent female schools or gatherings. : 9C ~Nine of Clubs~ This card can show disappointment regarding a personal friend (usually a female),a disappointment in gaining knowledge, or a friendly antagonism to your projects. : TC ~Ten of Clubs~ This card can show success in friendship, success in uniting with others in gaining some kind of knowledge or mental growth, or it can indicate/predict good news. : JC ~Jack of Clubs~ This card represents one who is full of life such as a sharp, bold-eyed person or a jealous young person. With females, this card indicates a suitor. : QC ~Queen of Clubs~ This card represents an intelligent, accomplished woman of strong religious or psychic proclivities; sometimes a beautiful singer or musician. : KC ~King of Clubs~ This card represents a man of middle age. A kind-hearted and even tempered gentleman; usually one who is learned or following a learned profession. : AD ~Ace of Diamonds~ This card can show a desire for money in order to use it for a kindly purpose, a wish to do good with wealth, or an unselfish wish for wealth. If this card is paired with a ten, the wish will be gratified. : 2D ~Two of Diamonds~ This card can show a business arrangement wherein at least one party is female, a co-partnership with a friend, or an introduction to a lady of means. : 3D ~Three of Diamonds~ This card shows indecision relating to or regarding money affairs and a certain friend (usually a lady). It can also indicate a choice between two propositions. : 4D ~Four of Diamonds~ This card shows satisfaction regarding a money affair and a lady, but in some cases she is a dear friend. It can also indicate adjustment of financial difficulties, or just show a general satisfaction of mind in regards to money. : 5D ~Five of Diamonds~ This card shows a change in love or friendship cause by some pecuniary considerations, or it can be a financial change with a woman or dear friend. If this card is followed by the Ten of Diamonds then the change is a good one. : 6D ~Six of Diamonds~ this card shows money affairs moving strongly in monotonous way, and no particular change with friends. : 7D ~Seven of Diamonds~ This card shows money paid or given to a woman, or it can indicate trouble connected with money and a friend or near relative. If this card is paired with the Eight of Hearts it indicates money given out for some pleasure. : 8D ~Eight of Diamonds~ This card shows the power of gaining property through the ability to make friends. It can also indicate female financial ability, or money that's made through the use of psychic gifts. : 9D ~Nine of Diamonds~ This card shows the disappointment of a lady connected in some way with money. It can also be an indication of a love affair that goes wrong on account of finances. : TD ~Ten of Diamonds~ This card shows success in friends and money, or a wealthy acquaintance (in some aspects, a wealthy marriage). It can also indicate kind of help from a friend. : JD ~Jack of Diamonds~ This card can represents a person with a good income, a generous person, or a free-hearted lover or young friend. In some cases, it can indicate a clerk in a business house. : QD ~Queen of Diamonds~ This card represents a warm-hearted, charitable lady who has considerable means, or in some cases, a wealthy lady friend. It can also indicate an actress or singer. : KD ~King of Diamonds~ This card represents a business man with a kind heart who makes a lot of money. It can also indicate a wealthy lover, a wealthy friend, or an actor or musician. : AS ~Ace of Spades~ This card can show a secret love, a secret wish, a secret friend, a secret or occult society or order, a secret present, or even a letter containing a secret. : 2S ~Two of Spades~ This card can show a joining of forces, a proposal of a business nature, a union with a woman in some kind of work, or a co-partnership with a relative or near friend. : 3S ~Three of Spades~ This card can show an undesided bargain with a friend, an indecision regarding a home, or an indecision regarding a matter of work or health connected with a woman. : 4S ~Four of Spades~ This card can show contentment of the soul, a happy home life, working for others because of a love for them, loving what you do, or finding satisfaction in your labors. : 5S ~Five of Spades~ This card can show a change in the labor of a female, a visit from a female, a short journey, a journey of a woman by land, or the removal of a home or habitation. : 6S ~Six of Spades~ This card can show quietness and comfort for women, matters moving smoothly, or a quiet and uneventful life as it pertains to one's self, intimate friends, or surroundings. : 7S ~Seven of Spades~ This card shows an illness caused by overdoing, late hours, or too much excitement. It can also indicate a love trouble, or an illness of a dear friend. : 8S ~Eight of Spades~ This card can show power in overcoming obstacles, female power/strength of will, a labor of love, female organizations, or meetings of females for purposes of work in some cause. : 9S ~Nine of Spades~ This card can show an illness caused by powerful emotions, the illness of a lady friend or relative by marriage, or the disappointment of a wish or aspiration to succeed. : TS ~Ten of Spades~ This card shows success and happiness in one's labor, home life, and general surroundings (indications are especially strong for females), or success in business where females are largely employed. : JS ~Jack of Spades~ This card represents an industrious person who is engaged in some occupation that is clean and light which requires keen perceptions and the ability to make and keep friends. : QS ~Queen of Spades~ This card represents an affectionate, faithful, and industrious wife or mother. However, it can also indicate a single woman, but one who is of the same disposition. : KS ~King of Spades~ This card represents a man who is of a kindly disposition though usually not very wealthy, but one who is kind to his family and a hard worker. In some cases, it can represent the head of a concern employing females. :
mars_data AH ~Ace of Hearts~ This card can show a wish to be of help to some friend, news of a friend in trouble, or a desire to stand well with some person of strong mind and disposition. : 2H ~Two of Hearts~ This card shows the meeting of lovers followed by a coldness or quarrel which ends quickly and all is serene. If this card is followed by a Jack then it indicates a visit from a male friend. : 3H ~Three of Hearts~ This card can show trouble in making up your mind, or a proposal of marriage which perplexes you. It can also show two friends quarreling in regards to something connected with yourself. : 4H ~Four of Hearts~ This card can show satisfaction in friendly conversation with someone who is of the same gender, or it can show satisfaction gained through law (if law-suit is shown elsewhere). : 5H ~Five of Hearts~ This card can show the parting from male friends, a journey with a male, change of feelings towards a man, or removal for reasons connected with some man. : 6H ~Six of Hearts~ This card shows the monotony of life and male forces or strength. In some cases, it can indicate a long marriage engagement. : 7H ~Seven of Hearts~ This card can show a trouble that last some weeks, a broken marriage engagement in some cases, a friend in trouble, or even a lawsuit. : 8H ~Eight of Hearts~ This card shows strong power and force of will. It can indicate gatherings or meetings where males predominant, or even parties where the music is either loud or live. : 9H ~Nine of Hearts~ This card can show a lovers' misunderstanding, the jealousy of another person, a disappointment of a male friend, or even an injury to a friend or relative. : TH ~Ten of Hearts~ This card shows success in a friendly negotiation, or the reunion of old friends. It can also indicate the triumphs of a friend in some sort of law case. : JH ~Jack of Hearts~ This card represents an amiable, good-hearted young person who is usually very religious or who has a deeply spiritual nature with strong feelings. Sometimes, it can also indicate someone who is engaged to be married. : QH ~Queen of Hearts~ This card can represent a faithful, warm-hearted wife or mother, a woman who has some male characteristics regarding business matters, or sometimes a strong and healthy young girl. : KH ~King of Hearts~ This card represents a good-hearted man (usually married) who is a great talker and reasoner. Although, sometimes, he is a little quick in temper, he also gets over it pretty fast too. In some cases, this card can indicate an old military man. : AC ~Ace of Clubs~ This card shows a desire for knowledge (i.e. inquisitiveness). It can also indicate a desire for occult communication, or a love of power. If this card is paired with a two then it indicates a letter from a male. : 2C ~Two of Clubs~ This card shows an interview with a person of business or with a reporter. It can also indicate a dispute between two males, a quarrel, or even a lawsuit. : 3C ~Three of Clubs~ This card can show knowledge of an undecided character, indecision regarding a transaction with a male, or doubtful news. If this card is paired with an a ace, then the news comes by letter. : 4C ~Four of Clubs~ This card can show pleasant (or improving) conversations with others (especially males), a happy married life, pleasant home surroundings, or good news from home. : 5C ~Five of Clubs~ This card can show a slight quarrel, a misunderstanding which causes a change in one life, or a change of opinion regarding a male. It indicates news of a change in affairs when it's paired with the two of clubs. : 6C ~Six of Clubs~ This card shows study and improvement continuing on steadily. It also indicates the absence of trouble, quarrels, or changes affecting males mostly. : 7C ~Seven of Clubs~ This card shows trouble in gaining certain knowledge, or an antagonism to your wishes and projects. It also indicates opposition from a male, a quarrel, or a lawsuit. : 8C ~Eight of Clubs~ This card can show male strength and power, debates, or psychic unfoldment and advancement. It can represent male schools or gatherings of men for political or similar reasons. : 9C ~Nine of Clubs~ This card shows dislike, distaste, disbelief of some person or thing that you are bought into contact with, or a disappointment caused by lack of knowledge. In some cases, it can also indicate a lawsuit. : TC ~Ten of Clubs~ This card shows general success in professional advocations, success in married life, or in study at home. However, this applies more particularly to males. : JC ~Jack of Clubs~ This card represents a quarrelsome person, or one who is plotting against some person or people who are closely connected with you. It can also indicate an attorney at law. : QC ~Queen of Clubs~ This card represents a smart female of strong will force and power, but rather quick tempered, and can have a somewhat masculine disposition or appearance. : KC ~King of Clubs~ This card can represent a loud talking overbearing man, a smart office holder, an active politician, a military man, or a man who leads or commands. : AD ~Ace of Diamonds~ This card can represent a money letter from a man, a wish for money connected in someway with the law, or an aspiration to succeed in some branch of law. : 2D ~Two of Diamonds~ This card can show a union of business interests, a business meeting, a letter regarding money, a financial bargain with a male, or a consultation with a lawyer. : 3D ~Three of Diamonds~ This card can show an undecided financial affair with a male, doubt regarding a financial transaction, a lawsuit in a state of uncertainty, or an uncertain trouble that arises. : 4D ~Four of Diamonds~ This card can show satisfaction regarding money and a man, the termination of a law case, or the happy ending of some trouble. : 5D ~Five of Diamonds~ This card can show a transaction which changes because of the interference of some man who is in the same business. It can also show a change happening to a man, or even indicate a business journey. : 6D ~Six of Diamonds~ This card affects the money matters of males principally. It can indicate the settlement of financial difficulties, or the smooth moving of financial arrangements. : 7D ~Seven of Diamonds~ This card generally indicates trouble connected with money; such as the loss of money through the law, money paid out to a man, or (in some cases) a lawsuit (especially when it's paired with the seven of clubs). : 8D ~Eight of Diamonds~ This card can show strength financially and commercially. It can indicate power which is gained through numbers, or a meeting of males for the financial consideration of questions. : 9D ~Nine of Diamonds~ This card can show financial dissatisfaction and trouble, the disappointment of a man in some financial way, or (under certain aspects) the loss of money by a lawsuit. : TD ~Ten of Diamonds~ This card can show success in a lawsuit or the financial success of some man who is connected to you. In some cases, it represents money gained through matrimony. : JD ~Jack of Diamonds~ This card usually represents a young married person, but sometimes it represents a middle-aged single person. It can also represent an attorney at law, a law clerk, a bank clerk, or a cashier. : QD ~Queen of Diamonds~ This card usually represents a married woman who spends money freely. She is fond of dress and generally quite pleased with the admiration of the opposite sex. : KD ~King of Diamonds~ This card represents a man of strong money-making power. It can also represent a wealthy husband, a well-to-do lawyer, or one who owns or controls mines and minerals. : AS ~Ace of Spades~ This card can be an indication of a conspiracy or plot. It can also show a secret wish, a marriage secret, a secret that is shared by a male, a secret communication, or even represent a letter containing bad news. : 2S ~Two of Spades~ This card can show work in conjunction with a man, a union of male forces in some kind of labor, a letter from a man, a consultation with a lawyer, or even be an indication of some sort of combination or plot. : 3S ~Three of Spades~ This card can show an undecided business matter, or a business indecision. It can also indicate two ways open in business both which require much work, or an indecision regarding a law case. : 4S ~Four of Spades~ This card can show strength in labor of love for males, married happiness for females, or satisfactory labor at home. : 5S ~Five of Spades~ This card can show a change in one's usual life or home surroundings, a journey connected with business or one's labor, a visit of a male from a city, or a change in the employment of a male. : 6S ~Six of Spades~ This card shows the absents of change or excitement generally, but can also indicate the settlement of lawsuits, quarrels, or anything of that kind. : 7S ~Seven of Spades~ This card can be an indication of chills, cold hands and feet, or an illness caused by excitement, drinking, late hours, passion, or severe labor. It represents trouble for males, or trouble caused by a male or males for females. : 8S ~Eight of Spades~ This card can indicate the overcoming of obstacles, the development of power, power gained through the concentration of forces, or organizations which are composed primarily of males. : 9S ~Nine of Spades~ This card can show ill success in some undertaking, a lawsuit, a loss which happens because of an illness, a disappointment caused by a man, or (in some cases) a secret disclosure. : TS ~Ten of Spades~ This card is an indication of general success (especially for males). It can show that one has the strength needed to bear trouble and to labor for some greater good, or it even predicts success in a lawsuit. : JS ~Jack of Spades~ This card can represent a person who is connected with the law, or someone whose trade requires either strong will force and power or manly strength. : QS ~Queen of Spades~ This card can represent a hard-working woman who is inclined towards a masculine bearing, a quarrelsome woman, or a woman who speaks badly about her neighbors. : KS ~King of Spades~ This card usually denotes an industrious, professional man. However, it can also represent an attorney at law, a judge, some office holder, or the head of a concern employing primarily male help. :
jupiter_data AH ~Ace of Hearts~ This card can show a desire for money to be used for an unselfish purpose, or a wish to help friends financially. It can also indicate a letter from a friend regarding some monetary favor, or even a telegram regarding money. : 2H ~Two of Hearts~ This card can be an indication of two old friends meeting, or a happy visit that is soon ended. If this card is paired with a queen then the visit is from a female. If it's paired with a jack or a king then the visit is from a male. : 3H ~Three of Hearts~ This card can show help that is given to a friend but regretted afterwards. It can also be an indication of perplexity regarding a money matter connected to someone that you esteem or love, or that two ways open up to you at the same time. : 4H ~Four of Hearts~ This card shows a love of fine surroundings, or satisfaction in costly items; i.e. fine clothes, a fine house, etc. If it's paired with the ten of hearts, it shows a love for your new work. If it's with the ten of diamonds, it shows pleasure in making money. : 5H ~Five of Hearts~ This card can show change in the circumstances of a friend or close relative, or it can indicate a business journey. If it's paired with the ace and two of clubs then it shows news of a change which you receive by letter. : 6H ~Six of Hearts~ This card show long continuation of existing financial affairs, monotony, or slow moving life. If a co-partnership is shown, it will be long continued. : 7H ~Seven of Hearts~ This card can show anxiety caused by money trouble, or illness caused by anxiety. It can also indicate a loss through a friend, or a friend in some financial trouble. : 8H ~Eight of Hearts~ This card shows power or strength of expression. It can indicate meetings of friends or fraternal societies, financial power, or the consideration of financial questions. : 9H ~Nine of Hearts~ This card can indicate either the loss of time in the pursuit of love, or the disappointment of strong hopes connected with the financial affairs of yourself or those of near friends. : TH ~Ten of Hearts~ This card indicates power, success, triumph, and happiness. It can show strength of love and friendship, help and confidence of friends, or business success based on friendly influences. : JH ~Jack of Hearts~ This card can represent someone of strong affection and soul powers, a kind friend, or one who is of assistance to you in a financial way. : QH ~Queen of Hearts~ This card represents a warm-hearted woman of some pecuniary ability and power (a friend). If paired with a king then she is married. : KH ~King of Hearts~ This card represents a professional man or merchant of much power and force of character (one who is a friend to you), or it can show a man who has great power in gaining friends. : AC ~Ace of Clubs~ This card shows money or property possessions. It indicates a desire for knowledge that may lead to power or preferment. If it's paired with a 2 or 5 then it indicates a business proposition. : 2C ~Two of Clubs~ This card shows joinings and co-partnerships. It can indicate a business proposition, introduction to a person of business, or an interview with someone on a pecuniary or business affair. : 3C ~Three of Clubs~ This card shows knowledge regarding a financial transaction which is held in doubt, or being undecided in mind relative to a certain bargain or proposition. : 4C ~Four of Clubs~ This card shows business contentment or a satisfactory state of money matters. It can indicate satisfactory knowledge of financial affairs, or a good financial transaction. : 5C ~Five of Clubs~ This card shows a change in financial affairs. It can indicate a change in the circumstances of a debtor causes a change in one's calculations. If this card is paired with a 10 then the change will be for the better. : 6C ~Six of Clubs~ This card shows monotony in business matters. It can indicate pecuniary affairs being at a standstill whether good or bad, or a lack of news regarding a business transaction. : 7C ~Seven of Clubs~ This card can show bad news regarding a merchantile firm or corporation, antagonism from some business firm, or trouble on account of some business transaction. : 8C ~Eight of Clubs~ This card can show power and knowledge applied to some money making scheme, or indicate councils and meetings for financial consideration of questions. : 9C ~Nine of Clubs~ This card can show discontent with one's pecuniary affairs, or news of money matters that is disappointing to you. If it's paired with the 7 of diamonds then it indicates a loss of property by the disappointment. : TC ~Ten of Clubs~ This card shows success through learning and mind force. It can indicate success and contentment in merchantile or business advocations, or advanced knowledge in your business. : JC ~Jack of Clubs~ This card represents a person who makes money through their peculiar knowledge regarding a certain line of business. It can sometimes represent a business rival. : QC ~Queen of Clubs~ This card represents a lady of strong powers and force of character. Generally, one who makes her own way in the world. A business woman. : KC ~King of Clubs~ This card shows generally a man of "power"; such as, an intelligent reasoner and powerful speaker. Though, in some cases, it can represent a physician or lawyer. If this card is found amongst strong diamonds, then it can represent a merchant. : AD ~Ace of Diamonds~ This card can show a wish connected with a large business transaction, a strong aspiration for success in business, or an important message on business. : 2D ~Two of Diamonds~ This card can show a financial co-partnership, a union of monied interests, a business meeting, a business consultation, or a combination. : 3D ~Three of Diamonds~ This card can show uncertainty and doubt, an undecided business investment, indecision connected with a large transaction, or two way open at the same time in financial affairs. : 4D ~Four of Diamonds~ This card expresses general good business. It can indicate satisfaction obtained connected with money, a good business, or an investment which turns out satisfactorily. : 5D ~Five of Diamonds~ This card can show a financial change, a change of business, the change of an investment, a business journey, or sometimes indicate a financial cross to bear. : 6D ~Six of Diamonds~ This card expresses general lack of excitement. It can show the settlements of accounts, or indicate that business matters continue slowly along and remain unchanged whether good or bad. : 7D ~Seven of Diamonds~ Use care when this card appears! It can show the loss off money in a trade, or indicate an investment of money in some place where you will not see it again soon. : 8D ~Eight of Diamonds~ This card shows power and ability to make money. It can indicate meetings of stockholders, companies, corporations, and/or societies. Sometimes, it can represent quite a large pecuniary transaction. : 9D ~Nine of Diamonds~ This card can show loss of money through some mercantile transaction, or investment of money that will bring no return in cash or property. : TD ~Ten of Diamonds~ This card shows general success in financial matters. It indicates the planets to be favorable for pecuniary enterprises of any and all kinds unless this card is aspected against. : JD ~Jack of Diamonds~ This card represents a well-to-do person or someone who handles considerable amounts of money. It can also indicate a merchant, a salesperson, a banker, a cashier, a broker, or someone of that nature. : QD ~Queen of Diamonds~ This card represents a wealthy lady, or one who is closely connected with someone who handles money i.e. a business person or banker. : KD ~King of Diamonds~ This card represents a wealthy, money-making, proud, "self-made" man who "loves his maker". In some cases, it can indicate a banker, a wholesale dealer or a manufacturer. : AS ~Ace of Spades~ This card can show a secret mercantile business, a speculative transaction, a secret order, a secret personal business letter, or just an important letter. : 2S ~Two of Spades~ This card can show a transaction between two persons, an interview with a businessman relating to work, or a letter regarding a piece of work. : 3S ~Three of Spades~ This card can show an indecision regarding a cash transaction, or two kinds of business open up for you (both requiring a lot of cash to conduct). : 4S ~Four of Spades~ This card can show satisfactory labor, or reasonable compensation for labor and satisfaction gained thereby. : 5S ~Five of Spades~ This card can show a change in pecuniary affairs, a financial change in one's labor, a journey on business, or news of a business nature. : 6S ~Six of Spades~ This card can show business moving smoothly, or monotony in one's business or professional life. : 7S ~Seven of Spades~ This card can show considerable trouble and care, illness caused by business worry, sleeplessness, a headache, or pain in the loins and back. : 8S ~Eight of Spades~ This card can show power and strength in numbers, or power represented by organizations; such as manufacturing companies, railroad corporations, and labor organizations. : 9S ~Nine of Spades~ This card can show financial loss, disappointment, trouble, failure, or bankruptcy. According to other factors in the same spread, it can indicate the default of employee and kindred troubles. : TS ~Ten of Spades~ This is a strong card, and it shows general financial success in mercantile pursuits, professional undertakings, and manufacturing enterprises. : JS ~Jack of Spades~ This card can represent a powerful worker who is steady and industrious, or an active young person who is engaged in some mercantile or professional pursuit. : QS ~Queen of Spades~ This card can represent a business woman, a woman who loves to transact business and handle money, or (in some cases) a woman who is employed in some mercantile institution. : KS ~King of Spades~ This card can represent a self-made man, a man of influence, a business rusher, a manufacturer, or a man who employs a great deal of labor. :
saturn_data AH ~Ace of Hearts~ This card can show a desire to aid the afflicted, a wish to help some friend in sickness, news of the sickness of a friend, or a letter announcing the death of a friend. : 2H ~Two of Hearts~ This card shows a visit to a sick friend. If it's followed by an ace then it indicates a letter from a friend who is ill, if by the 8 of clubs then it means influence from an unseen friend, and if it's preceded by the 7 and 9 of spades then it shows a meeting at a funeral. : 3H ~Three of Hearts~ This card shows trouble and concern, worry and indecision caused by illness of self or friends. It can also indicate a wish to leave home but can not do so. : 4H ~Four of Hearts~ This card can show pleasure derived from kindness to the sick, a recovery from illness by self or friends, or satisfaction with visits from unseen friends. : 5H ~Five of Hearts~ This card can indicate a journey caused by ill health, or a change of surroundings caused by sickness of friends. If it's preceded by the 7 and 9 of spades then death is the cause of the change. : 6H ~Six of Hearts~ This card shows that sickness of friends or relatives or any other condition under Saturn remain the same. If there is any change then it is very little. : 7H ~Seven of Hearts~ This card can show a deep and lasting trouble, illness caused by overwork, illness of some dear friend, a secret, or the concealment of a bodily infirmity. : 8H ~Eight of Hearts~ This card can show power in overcoming disease, circles and meetings for psychic investigation, or meetings of physicians or societies of like nature. : 9H ~Nine of Hearts~ This card shows misfortune, trouble and disappointment caused by either imprudence, jealousy, a lovers' quarrel, or illness of self or friends. : TH ~Ten of Hearts~ This card shows overcoming evil influences, and can indicate power over sickness, sorrow, death, trouble, disappointment, machinations of enemies, scandals, and heartburnings. : JH ~Jack of Hearts~ This card represents a good conscientious and true-hearted person who is in trouble and overcome by bad influences or ill health. : QH ~Queen of Hearts~ This card represents an affectionate and warm-hearted female who is most likely a widow though in some cases she is divorced, but not through her own fault, and is usually in poor health unless contraindicated. : KH ~King of Hearts~ This card represents a good and kindly dispositioned friend who is usually a physician or in some manner associated with sickness and death, but with strong psychic powers. : AC ~Ace of Clubs~ This card can show a wish which will not be gratified, a longing for the unattainable, bad news from a sick friend, or a letter containing bad news especially if it's paired with the two and seven of spades. : 2C ~Two of Clubs~ This card can show a bargain with a professional man, an interview with a physician or lawyer, a conversation with a person who is ill, or a quarrel under some aspects. : 3C ~Three of Clubs~ This card can show knowledge of a doubtful character from two places, or indecision, doubt and distrust of the future caused by bad influences or ill health. : 4C ~Four of Clubs~ This card shows goodness and virtue. It can indicate a happy and contented person in ill health, or good news received from a person who is ill. : 5C ~Five of Clubs~ This card shows discontent. It can indicate a change of plans caused by the ill health of self or others, or a short trip/journey for health reasons or to see a someone who is sick. : 6C ~Six of Clubs~ This card can show either uniform health or the contrary; both of which depend upon preceding conditions. It usually indicates a lack of change in the sick, but with physicians, can generally mean uniformity in business. : 7C ~Seven of Clubs~ This card can show a scandal, backbiting, ill remarks, gossip, illness caused by worry or overstudy, or it can indicate the overthrowing of your plans for advancement in knowledge. : 8C ~Eight of Clubs~ This card represents power in overcoming illness or trouble through knowledge and development. It can indicate receiving good news from a sick aquaintance, or even show the recovery of a friend who has been ill. : 9C ~Nine of Clubs~ This card can show a disappointment (sometimes in regards to gaining knowledge), a discontent, or some other disquieting feeling which is usually caused by an illness of either yourself or that of someone who is connected with you. : TC ~Ten of Clubs~ This card represents the overcoming of bad influences through knowledge. It can be an indication of attaining strength, power, and success against the evil effects of the planet Saturn. : JC ~Jack of Clubs~ This card can represent a rather dissolute young person who keeps late hours, or in some cases, a person whom you should beware of. If this card is paired with the seven and eight of clubs then it shows a studious young person who is in poor health. : QC ~Queen of Clubs~ This card represents an intelligent female who has experienced much sickness and trouble, or it can indicate a jealous woman. : KC ~King of Clubs~ This card usually represents an older well-learned male physician who is rather hard-hearted and inclined to be cross, exacting, and not sympathetic. : AD ~Ace of Diamonds~ This card can show either a wish to succeed (which is destined to be disappointed unless there are strong indications to the contrary), or it can indicate a letter or telegram regarding the illness of someone. : 2D ~Two of Diamonds~ This card can show an unlucky financial affair, a demand for money, a bill, a dunning letter, or an interview with a physician. If this card is paired with a 7 of any suit, it indicates bad news of some kind. : 3D ~Three of Diamonds~ This card can show uncertainty caused by illness or death, or indicate a feeling of insecurity regarding a future financial transaction. : 4D ~Four of Diamonds~ This card shows lost money that gets restored. It can also indicate either a recovery of health which causes satisfaction in a financial way, or be an indication of a will in your favor; especially when it follows a 7 of Spades. : 5D ~Five of Diamonds~ This card can show either a change of business, location or even an adventure through sickness, misfortune or death. : 6D ~Six of Diamonds~ This card shows sameness or wanting a change in financial affairs. It can also indicate a monotonous life which is quite apt to lead to either feelings of dissatisfaction stemming from a lack of excitement, or to an illness. : 7D ~Seven of Diamonds~ This card shows misfortune or the bad acts of another. It can be an indication of a loss of money through illness of either one's self or some other person. If it's followed by the 7 and 10 of Spades then it's by the death of someone. : 8D ~Eight of Diamonds~ This card shows power and financial ability connected with illness and death. In most cases it represents gain by what is lost to others. It can also indicate a meeting of physicians, doctors, healers, etc. : 9D ~Nine of Diamonds~ This card shows disappointment of hopes regarding financial matters usually caused by an illness but, in some cases, it's by death. It indicates an investment in some losing enterprise. : TD ~Ten of Diamonds~ This card can be an indication of some success in money matters, but the success does not last long. It shows success being impeded by an illness, bad health or by the death of some other person. : JD ~Jack of Diamonds~ This card represents someone who has fine business qualities but is hampered by ill health. It can also indicate a wild, dissipated person. : QD ~Queen of Diamonds~ This card represents a woman with money or business ability but is hampered by ill health. In some cases, she is a physician. This card is actually excellent for physicians. : KD ~King of Diamonds~ This card can represent a man of wealth who is an ill health, a rich man who is very close with his money, or a miserly man. : AS ~Ace of Spades~ This card can show a secret that is kept from you, a concealed trouble, a concealed disappointment, a secret disease, a secret communication, or bad news by letter. : 2S ~Two of Spades~ This card can show a letter announcing the illness of the person you are interested in, news regarding a sick friend, a consultation with a physician, or a business call on the sick. : 3S ~Three of Spades~ This card can show an indecision caused by a death or illness. It can also indicate a lingering illness, and undecided case of illness, or in some cases an unsettled bill. : 4S ~Four of Spades~ This card can show the recovery from an illness, or the satisfactory ending of a trouble or a disappointment. : 5S ~Five of Spades~ This card can show a change of employment caused by illness of one's self or of friends. It can also indicate a journey or a removal caused by an illness, and in some cases, it represents an unfortunate journey. : 6S ~Six of Spades~ This card counteracts changes and troubles shown in this line, and it can indicate the recovery from an illness (if an illness has been indicated elsewhere). If this card is followed by the 4 of Diamonds then it shows steady and satisfactory employment. : 7S ~Seven of Spades~ This card shows illness and trouble connected with one's reproductive organs, genitals, and other areas that are ruled by Scorpio. If it's followed by the 4 of Diamonds then it indicates a will in your favor. : 8S ~Eight of Spades~ This card shows power in overcoming illness and other obstacles to advancement, and can indicate a recovery from illness if such exists during the time of this reading. : 9S ~Nine of Spades~ This card shows an illness of yourself or close friend. If it's paired with the 7 of Spades then it indicates a fatal termination. : TS ~Ten of Spades~ This card shows success in the practice of medicine, healing and other kindred pursuits, and can indicate the recovery from an illness if such has been shown elsewhere. : JS ~Jack of Spades~ : QS ~Queen of Spades~ : KS ~King of Spades~ :
sun_data AH ~Ace of Hearts~ : 2H ~Two of Hearts~ : 3H ~Three of Hearts~ : 4H ~Four of Hearts~ : 5H ~Five of Hearts~ : 6H ~Six of Hearts~ : 7H ~Seven of Hearts~ : 8H ~Eight of Hearts~ : 9H ~Nine of Hearts~ : TH ~Ten of Hearts~ : JH ~Jack of Hearts~ : QH ~Queen of Hearts~ : KH ~King of Hearts~ : AC ~Ace of Clubs~ : 2C ~Two of Clubs~ : 3C ~Three of Clubs~ : 4C ~Four of Clubs~ : 5C ~Five of Clubs~ : 6C ~Six of Clubs~ : 7C ~Seven of Clubs~ : 8C ~Eight of Clubs~ : 9C ~Nine of Clubs~ : TC ~Ten of Clubs~ : JC ~Jack of Clubs~ : QC ~Queen of Clubs~ : KC ~King of Clubs~ : AD ~Ace of Diamonds~ : 2D ~Two of Diamonds~ : 3D ~Three of Diamonds~ : 4D ~Four of Diamonds~ : 5D ~Five of Diamonds~ : 6D ~Six of Diamonds~ : 7D ~Seven of Diamonds~ : 8D ~Eight of Diamonds~ : 9D ~Nine of Diamonds~ : TD ~Ten of Diamonds~ : JD ~Jack of Diamonds~ : QD ~Queen of Diamonds~ : KD ~King of Diamonds~ : AS ~Ace of Spades~ : 2S ~Two of Spades~ : 3S ~Three of Spades~ : 4S ~Four of Spades~ : 5S ~Five of Spades~ : 6S ~Six of Spades~ : 7S ~Seven of Spades~ : 8S ~Eight of Spades~ : 9S ~Nine of Spades~ : TS ~Ten of Spades~ : JS ~Jack of Spades~ : QS ~Queen of Spades~ : KS ~King of Spades~ :
moon_data AH ~Ace of Hearts~ : 2H ~Two of Hearts~ : 3H ~Three of Hearts~ : 4H ~Four of Hearts~ : 5H ~Five of Hearts~ : 6H ~Six of Hearts~ : 7H ~Seven of Hearts~ : 8H ~Eight of Hearts~ : 9H ~Nine of Hearts~ : TH ~Ten of Hearts~ : JH ~Jack of Hearts~ : QH ~Queen of Hearts~ : KH ~King of Hearts~ : AC ~Ace of Clubs~ : 2C ~Two of Clubs~ : 3C ~Three of Clubs~ : 4C ~Four of Clubs~ : 5C ~Five of Clubs~ : 6C ~Six of Clubs~ : 7C ~Seven of Clubs~ : 8C ~Eight of Clubs~ : 9C ~Nine of Clubs~ : TC ~Ten of Clubs~ : JC ~Jack of Clubs~ : QC ~Queen of Clubs~ : KC ~King of Clubs~ : AD ~Ace of Diamonds~ : 2D ~Two of Diamonds~ : 3D ~Three of Diamonds~ : 4D ~Four of Diamonds~ : 5D ~Five of Diamonds~ : 6D ~Six of Diamonds~ : 7D ~Seven of Diamonds~ : 8D ~Eight of Diamonds~ : 9D ~Nine of Diamonds~ : TD ~Ten of Diamonds~ : JD ~Jack of Diamonds~ : QD ~Queen of Diamonds~ : KD ~King of Diamonds~ : AS ~Ace of Spades~ : 2S ~Two of Spades~ : 3S ~Three of Spades~ : 4S ~Four of Spades~ : 5S ~Five of Spades~ : 6S ~Six of Spades~ : 7S ~Seven of Spades~ : 8S ~Eight of Spades~ : 9S ~Nine of Spades~ : TS ~Ten of Spades~ : JS ~Jack of Spades~ : QS ~Queen of Spades~ : KS ~King of Spades~ :
00 The effects of the card that DID occupy this space have been nullified by other factors in the spread and no longer apply. :
EOF
cat > $dir/weekday.sh <<- 'EOF'
#!/usr/bin/bash
day_of_week() {
local year=$(( 10#$1 ))
local month=$(( 10#$2 ))
local day=$(( 10#$3 ))
local a=$(( ( 14 - month ) / 12 ))
local y=$(( year - a ))
local m=$(( month + 12*a - 2 ))
echo $(( ( day + y + y/4 - y/100 + y/400 + (31*m)/12) % 7 ))
}
day_of_week $@
EOF
chmod +x $dir/weekday.sh
cat > $file4 <<- 'EOF'
#!/usr/bin/yabasic
on interrupt continue
data "A","2","3","4","5","6","7","8","9","T","J","Q","K","H","C","D","S"
label def_arrays
dim rsif$(17)
dim card$(13)
dim suit$(4)
dim a$(52)
dim b$(52)
dim tablet$(90)
dim stack$(9)
dim cutcard$(2)
dim bc$(53)
dim bc_spread$(53)
dim bc_age_spread$(53,90)
dim bc_age_card$(53,90)
dim bc_age_quad$(53,90)
dim bc_period_card$(53,90,8)
dim bc_period_quad$(53,90,8)
dim bc_week_spread$(53,90)
dim bc_week_card$(53,90,53)
dim bc_week_quad$(53,90,53)
dim bc_weekday_spread$(53,90,53)
dim bc_weekday_card$(53,90,53,8)
dim bc_weekday_quad$(53,90,53,8)
dim bc_day_card$(53,90,366)
dim bc_day_quad$(53,90,366)
percent=0
label calculate_holy_tablets
for count=1 to 17
  read rsif$(count)
next count
c=0
for a=1 to 13
  card$(a)=rsif$(a)
next a
for a=1 to 4
  suit$(a)=rsif$(a+13)
next a
for b=1 to 4
  for a=1 to 13
    c=c+1
    a$(c)=card$(a)+suit$(b)
  next a
next b
for a=0 to 89
  gosub quadrate
  for c=1 to 52
    tablet$(a)=tablet$(a)+b$(c)
    a$(c)=b$(c)
  next c
next a
goto save
label done
exit
label cut2card
a=0:cutcard$(0)="":cutcard$(1)=""
for count=1 to 52
  f$=mid$(spread$,(count*2)-1,2)
  if f$=target$ a=1
  cutcard$(a)=cutcard$(a)+f$
next count
spread$=cutcard$(1)+cutcard$(0)
target=0
return
label cards2stack
for count=1 to 8
  stack$(count)=mid$(spread$,(count*2)-1,2)
next count
return
label stack_cards
a=0:stack$(0)=""
for count=1 to 52
  f$=mid$(spread$,(count*2)-1,2)
  if f$=stack$(1) then a=1:stack$(a)=""
  elsif f$=stack$(2) then a=2:stack$(a)=""
  elsif f$=stack$(3) then a=3:stack$(a)=""
  elsif f$=stack$(4) then a=4:stack$(a)=""
  elsif f$=stack$(5) then a=5:stack$(a)=""
  elsif f$=stack$(6) then a=6:stack$(a)=""
  elsif f$=stack$(7) then a=7:stack$(a)=""
  elsif f$=stack$(8) then a=8:stack$(a)=""
  fi
  stack$(a)=stack$(a)+f$
next count
stack$(a)=stack$(a)+stack$(0):spread$=""
for count=1 to 8
  spread$=spread$+stack$(count)
next count
return
label prep_quad
for count=1 to 52
  a$(count)=mid$(spread$,(count*2)-1,2)
next count
label quadrate
b$(1)=a$(3):b$(2)=a$(14):b$(3)=a$(25):b$(4)=a$(49):b$(5)=a$(18):b$(6)=a$(29):b$(7)=a$(40):b$(8)=a$(7):b$(9)=a$(33):b$(10)=a$(44):b$(11)=a$(11):b$(12)=a$(22):b$(13)=a$(48)
b$(14)=a$(2):b$(15)=a$(13):b$(16)=a$(39):b$(17)=a$(6):b$(18)=a$(17):b$(19)=a$(28):b$(20)=a$(50):b$(21)=a$(21):b$(22)=a$(32):b$(23)=a$(43):b$(24)=a$(10):b$(25)=a$(36):b$(26)=a$(47)
b$(27)=a$(1):b$(28)=a$(27):b$(29)=a$(38):b$(30)=a$(5):b$(31)=a$(16):b$(32)=a$(42):b$(33)=a$(9):b$(34)=a$(20):b$(35)=a$(31):b$(36)=a$(51):b$(37)=a$(24):b$(38)=a$(35):b$(39)=a$(46)
b$(40)=a$(15):b$(41)=a$(26):b$(42)=a$(37):b$(43)=a$(4):b$(44)=a$(30):b$(45)=a$(41):b$(46)=a$(8):b$(47)=a$(19):b$(48)=a$(45):b$(49)=a$(12):b$(50)=a$(23):b$(51)=a$(34):b$(52)=a$(52)
spread$=""
for count=1 to 52
  spread$=spread$+b$(count)
next count
return
label back1
cutcard$(0)=right$(spread$,2)
cutcard$(1)=left$(spread$,102)
spread$=cutcard$(0)+cutcard$(1)
return
label forward1
cutcard$(1)=left$(spread$,2)
cutcard$(0)=right$(spread$,102)
spread$=cutcard$(0)+cutcard$(1)
return
label save
open "cardnum" for reading as #1
input #1 bc
close #1
if bc=100 goto done
bc$(bc)=mid$(tablet$(89),(bc*2)-1,2)
target$=bc$(bc)
spread$=tablet$(0)
gosub cut2card
gosub cards2stack
spread$=tablet$(89)
gosub stack_cards
bc_spread$(bc)=spread$
for age=0 to 89
  spread$=bc_spread$(bc)
  bc_age_card$(bc,age)=mid$(spread$,(age*2)+1,2)
  target$=bc_age_card$(bc,age)
  gosub cut2card
  gosub prep_quad
  target$=bc$(bc)
  gosub cut2card
  gosub back1
  bc_age_quad$(bc,age)=spread$
  spread$=tablet$(age)
  target$=bc_age_card$(bc,age)
  gosub cut2card
  gosub cards2stack
  for count=0 to 7
    bc_period_card$(bc,age,count)=stack$(count+1)
  next count
  spread$=bc_spread$(bc)
  gosub stack_cards
  bc_age_spread$(bc,age)=spread$
  for period=1 to 7
    target$=bc_period_card$(bc,age,period)
    spread$=bc_age_spread$(bc,age)
    gosub cut2card
    gosub prep_quad
    target$=bc$(bc)
    gosub cut2card
    gosub back1
    bc_period_quad$(bc,age,period)=spread$
  next period
  target$=bc$(bc)
  spread$=tablet$(age)
  gosub cut2card
  gosub cards2stack
  spread$=tablet$(89)
  gosub stack_cards
  bc_week_spread$(bc,age)=spread$
  day=0
  for week=1 to 52
    bc_week_card$(bc,age,week)=mid$(bc_week_spread$(bc,age),(week*2)-1,2)
    target$=bc_week_card$(bc,age,week)
    spread$=bc_week_spread$(bc,age)
    gosub cut2card
    gosub prep_quad
    target$=bc$(bc)
    gosub cut2card
    gosub back1
    bc_week_quad$(bc,age,week)=spread$
    tablet=age+week
    do
      if tablet<90 break
      tablet=tablet-90
    loop
    target$=bc_week_card$(bc,age,week)
    spread$=tablet$(tablet)
    gosub cut2card
    gosub cards2stack
    for count=1 to 7
      bc_weekday_card$(bc,age,week,count)=stack$(count+1)
    next count
    spread$=bc_week_spread$(bc,age)
    gosub stack_cards
    bc_weekday_spread$(bc,age,week)=spread$
    for day=1 to 7
      target$=bc_weekday_card$(bc,age,week,day)
      spread$=bc_weekday_spread$(bc,age,week)
      gosub cut2card
      gosub prep_quad
      target$=bc$(bc)
      gosub cut2card
      gosub back1
      bc_weekday_quad$(bc,age,week,day)=spread$
    next day
  next week
  for day=0 to 365
    d=day
    do
      if d<52 break
      d=d-52
    loop
    bc_day_card$(bc,age,day)=mid$(bc_age_spread$(bc,age),(d*2)+1,2)
    tablet=age+day
    do
      if tablet<90 break
      tablet=tablet-90
    loop
    spread$=tablet$(tablet)
    target$=bc_day_card$(bc,age,day)
    gosub cut2card
    gosub cards2stack
    spread$=bc_age_spread$(bc,age)
    gosub stack_cards
    gosub prep_quad
    target$=bc$(bc)
    gosub cut2card
    gosub back1
    bc_day_quad$(bc,age,day)=spread$
  next day
next age
open bc$(bc) for writing as #1
for age=0 to 89
  print #1 combine$(bc_age_card$(bc,age),bc_age_quad$(bc,age))
  for period=1 to 7
    print #1 combine$(bc_period_card$(bc,age,period),bc_period_quad$(bc,age,period))
  next period
  for week=1 to 52
    print #1 combine$(bc_week_card$(bc,age,week),bc_week_quad$(bc,age,week))
    for weekday=1 to 7
      print #1 combine$(bc_weekday_card$(bc,age,week,weekday),bc_weekday_quad$(bc,age,week,weekday))
    next weekday
  next week
  for day=0 to 365
    print #1 combine$(bc_day_card$(bc,age,day),bc_day_quad$(bc,age,day))
  next day
next age
close #1
goto done
sub combine$(t1$,t2$)
  return t1$+t2$
end sub
EOF
chmod +x $file4
tempfile && exit
