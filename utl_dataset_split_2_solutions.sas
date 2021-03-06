Split dataset by area code or "Finding Like Values and Assigning them to a DATASET"

    WORKING CODE ( Two solutions)

    1. DOSUBL

      DOSUBL Compile time get area codes

          select distinct quote(one) into :xcg separated by ","
          from have group by one having count(one) gt 1

       MAINLINE

          do xch=&xcg;
            call symputx('xgn',xch);

       DOSUBL

          data p&xgn;
            set have(where=(one=symget("xgn")));
          run;quit;
          %let obs=&sqlobs;

       MAINLINE

           if symget('obs') eq '0' then putlog "table P" xch " created  sucessfully";
           else do;
           putlog "table P" sfx " was not crated";

    2. HASH

          declare hash h();
            h.definekey('k');
            h.definedata('two','tre');
            h.definedone();
          do k = 1 by 1 until ( last.one ) ;
             set have;
             by one notsorted;
             h.add();
          end;
          h.output(dataset:'p' || put(one,3.));


see
https://goo.gl/Eczw2f
https://communities.sas.com/t5/Base-SAS-Programming/
Finding-Like-Values-and-Assigning-them-to-a-DATASET/m-p/395082

 This should be very fast but the SAS compliler/interpreter needs work?
 There arae only about 900 possible.

HAVE
====

  WORK.HAVE total obs=8          RULES

   Obs    ONE    TWO    TRE

    1     631    555    5555   Create dataset P631
    2     631    666    6666

    3     516    999    9999   Create dataset P516
    4     516    888    8888

    5     212    444    4444   Create dataset P212
    6     212    444    5555

    7     213    444    5555   Do not create P213 because only one record

    8     214    444    5555   Do not create P213 because only one record


WANT
====

P631 total obs=2

Obs    ONE    TWO    TRE

 1     631    555    5555
 2     631    666    6666

P516 total obs=2

Obs    ONE    TWO    TRE

 1     516    999    9999
 2     516    888    8888

P212 total obs=2

Obs    ONE    TWO    TRE

 1     212    444    4444
 2     212    444    5555

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have(index=(one));
input one$ two$ tre$;
cards4;
631 555 5555
631 666 6666
516 999 9999
516 888 8888
212 444 4444
212 444 5555
213 444 5555
214 444 5555
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%symdel xcg /  nowarn;
data _null_;
    if _n_=0 then do;
      %let rc=%sysfunc(dosubl('
        proc sql;
          select distinct quote(one) into :xcg separated by ","
          from have group by one having count(one) gt 1
        ;quit;
      '));
    end;
    * do not remove trailing blanks in do elements;
    do xch=&xcg;
      call symputx('xgn',xch);
      rc=dosubl('
          data p&xgn;
            set have(where=(one=symget("xgn")));
          run;quit;
      ');
    end;
run;quit;

*_               _
| |__   __ _ ___| |__
| '_ \ / _` / __| '_ \
| | | | (_| \__ \ | | |
|_| |_|\__,_|___/_| |_|

;

data _null_;
  if 0 then set have;
  declare hash h();
    h.definekey('k');
    h.definedata('two','tre');
    h.definedone();
  do k = 1 by 1 until ( last.one ) ;
     set have;
     by one notsorted;
     h.add();
  end;
  h.output(dataset:'p' || put(one,3.));
run;

