function [result] = ObjectiveFun(x,T,targetDifficulty, targetDuration)
%Copyright (c) 2023, Muhammet Aktaþ and Zeki Yetgin
%All rights reserved.
%Redistribution and use in source and binary forms, with or without modification, are permitted provided that the source paper is cited:
%Please cite the following source paper
%M. Aktaþ, Z. Yetgin, F. Kýlýç, Ö. Sünbül, "Automated test design using swarm and evolutionary intelligence algorithms", Expert Systems,39(4), 2022.

%Inputs:
%x is the solution vector (one test design), elements of which are question IDs, index to the Question Pool, T
%T is the question pool as Table where each row describe a question and coloumns shows attributes of the question
%Question pool,T, is given as mat file (QuestionPool.mat), and must be loaded it into your workspace.
% targetDifficulty is the difficulty percent of the exam, e.g 70 to mean 70%.
% targetDuration is the duration of the exam in minute, e.g 120 min.

%Output is a positive real value where small value shows better solution (test design)

Tx=T(x,:);   %Tx,Table, which is the current test design corresponding to x 
eval_difficulty=sum(abs(sum(Tx.difficulty)-targetDifficulty*size(Tx,1))); %e1 metric in the paper
eval_duration=sum(abs(sum(Tx.duration)-targetDuration));   %e2 metric in the paper

eval_keywords=KeywordsDiversity(Tx);  %e3 metric in the paper
eval_subject=SubjectDiversity(Tx);    %e4 metric in the paper
eval_outcome=OutcomeDiversity(Tx);    %e5 metric in the paper

result=eval_difficulty+eval_duration+eval_keywords+eval_subject+eval_outcome;

end

function [result] = SubjectDiversity(T)

G1=groupsummary(T,{'courseID','subjectID'});
G2=groupsummary(G1,'courseID','var','GroupCount');

result=sum(G2.var_GroupCount./G2.GroupCount);

end

function [result] = KeywordsDiversity(T)

G=groupsummary(T,'courseID',@(x){StrMerge(x)},'keywordsIDs');
N=height(G);
vars=zeros(N,1);
for i=1:N
    cat = G.fun1_keywordsIDs{i,1};
    [counts,cats]=groupcounts(cat');
    vars(i)=var(counts)/length(cats); 
end

result=sum(vars);
end

function [result] = OutcomeDiversity(T)

G=groupsummary(T,'courseID',@(x1){StrMerge(x1)},'outcomeIDs');
N=height(G);
vars=zeros(N,1);
for i=1:N
    outcome = G.fun1_outcomeIDs{i,1};
    [counts,outcomes]=groupcounts(outcome');
    vars(i)=var(counts)/length(outcomes); 
end

result=sum(vars);
end

function [T] = StrMerge(x)
T=[];
z=cell2mat(x');
T=[T ,z ];
end