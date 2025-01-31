
clear;
clc;
close all;

tic
global NFE;
NFE = 0 ;
ii = 1; % If you want to extend the calculation you can utilize a for loop.

ga;

BestCost = sprintf('BestCost%d',ii);
Cost = BestSol.Cost;
save(BestCost,'Cost');
 
BestLocation = sprintf('BestLocation%d',ii);
Position=BestSol.Position;
save(BestLocation,'Position');
 
figure = sprintf('Figure%d',ii);
savefig(figure);
 
nfe = sprintf('nfe%d',ii);
save(nfe,'NFE');
 
Time = toc;
time = sprintf('Time%d',ii);
save(time,'Time');


