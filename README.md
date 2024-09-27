# Question Pool Dataset(Matlab file) 
QuestionPool.mat file contains the table T (1000x7), which is a syntetic dataset consisting of 1000 questions with their attributes to be used for test (exam) design optimizations. Dataset is generated according to real-life parameters in the paper(please cite it to use the dataset): M. Aktaş, Z. Yetgin, F. Kılıç, Ö. Sünbül, "Automated test design using swarm and evolutionary intelligence algorithms", Expert Systems,39(4), 2022.

Each question in the Table has 7 attributes: ID(int), courseID(int), subjectID(int), keywordsIDs(vector of ints, variable in size), duration(real), difficulty(real),outcomeIDs(vector of ints, variable in size)

ModifiedABC.m is the application of an optimization algorithm (a variant of ABC), proposed in the paper above. Use and run it in order to learn how the dataset is used for optimization purpose. You can also use ObjectiveFun.m file for your own algorithms. Please refer and cite the paper above for detailed information. 
