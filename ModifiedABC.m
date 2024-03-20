%Copyright (c) 2023, Muhammet Aktaþ and Zeki Yetgin
%All rights reserved.
%Redistribution and use in source and binary forms, with or without modification, are permitted provided that the source paper is cited:
%Please cite the following source paper
%M. Aktaþ, Z. Yetgin, F. Kýlýç, Ö. Sünbül, "Automated test design using swarm and evolutionary intelligence algorithms", Expert Systems,39(4), 2022.

%The question pool, denoted by T, is loaded from QuestionPool.mat file 
%Change problem definition and Modified ABC settings for different test cases 

clc;
clear;
close all;

load QuestionPool.mat %contains T : the question pool of 1000 questions

global pop;
global poolIndexes

%% Problem Definition
dim=50; 		 %dimension=number of questions in the test
difficulty=70;   %test difficulty in percent
duration=120;    %test duration in minutes


%% Modified ABC Settings
MaxIt=5000;              % Maximum Number of Iterations
popSize=50;      			%population size
nFoods=floor(popSize/2);    % Number of Foods
L=dim*nFoods;  				% Abandonment Limit Parameter (Trial Limit)

% save frequent variables
poolIndexes=1:height(T);

% Initialize Best Solution Ever Found
BestSol.Cost=inf;

% Create Initial Population
empty_bee.Position=[]; % Empty Bee Structure
empty_bee.Cost=[];

% Initialize Population Array
pop=repmat(empty_bee,nFoods,1);
for i=1:nFoods
    pop(i).Position=randsample(poolIndexes,dim);
    pop(i).Cost=ObjectiveFun(pop(i).Position,T,difficulty,duration);
    if pop(i).Cost<BestSol.Cost
        BestSol=pop(i);
    end
    
end

% Abandonment Counter
C=zeros(nFoods,1);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% ABC Main Loop
for it=1:MaxIt
    
    % Worker Phase
    for i=1:nFoods       
        xi=pop(i).Position;
		costxi=pop(i).Cost;
        % New Bee Position
        vi=LocalSearch(xi);
        % Evaluation
        costvi=ObjectiveFun(vi,T,difficulty,duration);  
        % Comparision
        if costvi<costxi
            pop(i).Position=vi;
			pop(i).Cost=costvi;
            C(i)=0;         
        else
            C(i)=C(i)+1;
        end
        
    end
   
	allcosts = [pop.Cost];
	allcosts = allcosts+1;
	allfits = 1./allcosts; % Convert Cost to Fitness
    P=allfits/sum(allfits);
	CP=cumsum(P); 		  %For Roulette Wheel Selection 
    
	% Onlooker Phase
    for m=1:nFoods     
        i=find(rand<=CP,1,'first');  %Roulette Wheel Selection 
		
        xi=pop(i).Position;
		costxi=pop(i).Cost;
        % New Bee Position
        vi=LocalSearch(xi);
        % Evaluation
        costvi=ObjectiveFun(vi,T,difficulty,duration);  
        % Comparision
        if costvi<costxi
            pop(i).Position=vi;
			pop(i).Cost=costvi;
            C(i)=0;         
        else
            C(i)=C(i)+1;
        end     
    end
       
    % Scout Bees
    for i=1:nFoods
        if C(i)>L
            pop(i).Position=randsample(poolIndexes,dim);
            pop(i).Cost=ObjectiveFun(pop(i).Position,T,difficulty,duration);        
            C(i)=0;
        end
        if pop(i).Cost<BestSol.Cost
            BestSol=pop(i);
        end

    end
      
    % Store Best Cost Ever Found
    BestCost(it)=BestSol.Cost;
    
    % Display Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end
   

x=BestSol.Position;
Tx=T(x,:);

fprintf("Mean difficulty of the optimal test: "+mean(Tx.difficulty)+"\n");
fprintf("Duration of the optimal test:"+sum(Tx.duration)+"\n");


%% Results

figure;
%plot(BestCost,'LineWidth',2);
semilogy(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;



%%Local Search 
function vi = LocalSearch(xi)
global pop
global poolIndexes ;

k=randi(length(pop));
xk=pop(k,:);

n = length(xi);
pm=randi(ceil(n/2));    %the number of questions that are transferred from xk 

ix=false([1 n]);
ixk=randsample(1:n,pm); %get the indexes of the pm number of questions randomly
ix(ixk)=true;
xkPart=xk.Position(ix); 
xiPart=xi(~ix);
vi=[xiPart, xkPart];    %form the alternative solution, some from xi, some from xk
[xort,vix]=intersect(xkPart,xiPart,'stable');
n2=length(xort);
if n2>0  %n2 number of questions are shared..replace them from the pool
  virange=setdiff(poolIndexes,vi);
  news=randsample(virange,n2);
  xkPart(vix)=news;
  vi=[xiPart, xkPart];
end
  
end

