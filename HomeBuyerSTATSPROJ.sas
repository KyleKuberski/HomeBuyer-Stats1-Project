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
/*____________________________________________________________________________ */
/*View data */
proc print data= houses;
run;

/* Filtering the data to include only needed neighborhoods*/
data filtered_houses;
    set houses;
    where Neighborhood in ("NAmes", "Edwards", "BrkSide");
run;

/* Start by plotting the data */
proc sort data=filtered_houses;
by Neighborhood;
run;

proc sgplot data=filtered_houses;
    title "Scatter Plot of SalePrice vs GrLivArea by Neighborhood";
    scatter x=GrLivArea y=SalePrice / group=Neighborhood;
    xaxis label="Living Area SqFt";
    yaxis label="Sales Price";
    by Neighborhood;
run;

proc sgscatter data = filtered_houses;
by Neighborhood;
matrix SalePrice GrLivArea;
run;

data loghouses;
set filtered_houses;
logGrLiv = log(GrLivArea);
logSalePrice = log(SalePrice);
;

proc sgscatter data = loghouses;
by Neighborhood;
matrix logSalePrice logGrLiv;
run;

/* Fit the model */
proc glm data = loghouses plots=all;
class Neighborhood;
model logSalePrice = logGrLiv Neighborhood / solution clparm;
run;


/* Creating a new variable 'GrLivArea_100' for GrLivArea in increments of 100 sq. ft. */
data filtered_houses;
    set filtered_houses;
    GrLivArea_100 = floor(GrLivArea / 100) * 100;
run;

/* Fit a multiple linear regression model with interaction term */
proc glm data=filtered_houses plots=all;
    class Neighborhood;
    model SalePrice = GrLivArea_100 Neighborhood GrLivArea_100*Neighborhood / solution;
run;

/*We see some points with massive leverage, outliers in residuals, and influence around ~350 on our Cook's D */
	/*Due to this we are going to attempt some log transformations*/

/* Creating a new variable for the log transformation of GrLivArea (GrLivArea_log) */
data filtered_houses;
    set filtered_houses;
    GrLivArea_log = log(GrLivArea);
run;

/* multiple linear regression model with the log-transformed GrLivArea */
proc glm data=filtered_houses plots=all;
    class Neighborhood;
    model SalePrice = GrLivArea_log Neighborhood GrLivArea_log*Neighborhood / solution;
run;

/*Still seeing similar results, lets try a log transformation on just the salesprice*/
data filtered_houses;
    set filtered_houses;
    SalePrice_log = log(SalePrice);
run;

/* multiple linear regression model with the log-transformed GrLivArea */
proc glm data=filtered_houses plots=all;
    class Neighborhood;
    model SalePrice_log = GrLivArea Neighborhood GrLivArea*Neighborhood / solution;
run;

/*Still seeing similar results, lets try a log-log transformation */

/* multiple linear regression model with the log-log data*/
proc glm data=filtered_houses plots=all;
    class Neighborhood;
    model SalePrice_log = GrLivArea_log Neighborhood GrLivArea_log*Neighborhood / solution;
run;



/* chat gpt*/
/* Step 2: Create a new variable 'GrLivArea_100' for GrLivArea in increments of 100 sq. ft. */
data filtered_houses;
    set filtered_houses;
    GrLivArea_100 = floor(GrLivArea / 100) * 100;
run;

/* Step 3: Fit the multiple linear regression model with interaction term */
proc glm data=filtered_houses plots=all;
    class Neighborhood; /* No need to set a reference level */
    model SalePrice = GrLivArea_100 Neighborhood GrLivArea_100*Neighborhood / solution;
run;
