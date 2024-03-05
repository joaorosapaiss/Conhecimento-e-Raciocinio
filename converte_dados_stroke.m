data = readtable('Train.csv');

% Substitui texto por numeros para que rede neuronal consiga comprender
data.gender = replace(data.gender, 'Male', "0");
data.gender = replace(data.gender, 'Female', "1");

data.ever_married = replace(data.ever_married, 'Yes', "1");
data.ever_married = replace(data.ever_married, 'No', "0");

data.Residence_type = replace(data.Residence_type, 'Urban', "1");
data.Residence_type = replace(data.Residence_type, 'Rural', "0");

data.smoking_status = replace(data.smoking_status, 'never smoked', "0");
data.smoking_status = replace(data.smoking_status, 'formerly smoked', "1");
data.smoking_status = replace(data.smoking_status, 'smokes', "2");
data.smoking_status = replace(data.smoking_status, 'Unknown', "3");

% Escrever a tabela de volta para um novo arquivo CSV
writetable(data, 'Train_mod.csv');