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


proc glm data = loghouses plots=all;
class Neighborhood (REF = "BrkSide");
model logSalePrice = logGrLiv | Neighborhood / solution clparm;
run;


/*Unrestricted MODEL*/
proc glm data = loghouses plots=all;
class Neighborhood (REF = "BrkSide");
model logSalePrice = logGrLiv Neighborhood logGrLiv*Neighborhood / solution clparm;
run;

/*Conf/Pred Plots */
proc reg data=loghouses outest=cooks;
  by Neighborhood;
  model logSalePrice = logGrLiv / stb clb;
run;
/*Influential Points DFBeta plots */
proc reg data=loghouses plots(only)=DFBetas;
  by Neighborhood;
  model logSalePrice = logGrLiv / stb clb;
run;
/* CV Press non-restricted*/
proc glmselect data= loghouses;
class Neighborhood;
model logSalePrice = logGrLiv
/selection = forward(stop=CV) cvmethod=random(5) stats= adjrsq;
run;



/*Set Restriction on dataset*/
data restricted_data;
  set loghouses;
  where GrLivArea >= 1000 and GrLivArea <= 3250;
  where SalePrice >= 75000 and SalePrice <= 150000;
run;

data loghouses;
set filtered_houses;
logGrLiv = log(GrLivArea);
logSalePrice = log(SalePrice);
;
/*Restricted Model*/
proc glm data = restricted_data plots=all;
class Neighborhood (REF = "BrkSide");
model logSalePrice = logGrLiv Neighborhood logGrLiv*Neighborhood / solution clparm;
run;
/*Influential Points DFBeta plots (restricted)*/
proc reg data=restricted_data plots(only)=DFBetas;
  by Neighborhood;
  model logSalePrice = logGrLiv / stb clb;
run;
/*Scatter for restricted data*/
proc sgscatter data = restricted_data;
by Neighborhood;
matrix logSalePrice logGrLiv;
run;

/* CV Press restricted*/
proc glmselect data= restricted_data;
class Neighborhood;
model logSalePrice = logGrLiv
/selection = forward(stop=CV) cvmethod=random(5) stats= adjrsq;
run;
