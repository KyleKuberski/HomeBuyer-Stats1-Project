/* Generated Code (IMPORT) */
/* Source File: train.csv */
/* Source Path: /home/u62927206/sasuser.v94/My New Data */
/* Code generated on: 8/2/23, 7:40 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u62927206/sasuser.v94/My New Data/train.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=houses;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=houses; RUN;


%web_open_table(houses);

proc print data= houses;
run;

/* Step 1: Filter the data to include only the specified neighborhoods */
data filtered_houses;
    set houses;
    where Neighborhood in ("NAmes", "Edwards", "BrkSide");
run;

/* Step 2: Create a new variable 'GrLivArea_100' for GrLivArea in increments of 100 sq. ft. */
data filtered_houses;
    set filtered_houses;
    GrLivArea_100 = floor(GrLivArea / 100) * 100;
run;

/* Step 3: Set "NAmes" as the reference level for the 'Neighborhood' variable */
proc glm data=filtered_houses plots=all;
    class Neighborhood(ref="NAmes"); /* Set "NAmes" as the reference level */
    model SalePrice = GrLivArea_100 Neighborhood / solution;
run;