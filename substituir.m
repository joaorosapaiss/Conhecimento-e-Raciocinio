% Supondo que os dados possam ter um delimitador específico como ';' e tratando dados ausentes
filename = 'dataset/Train.csv';
delimiter = ';';
formatSpec = '%f %f %f %f %f %f %f %f %f %C %f ';

data = readtable(filename, 'Delimiter', delimiter, 'Format', formatSpec);

% Separar os dados completos e os dados com valores faltantes (NA)
complete_data = data(~any(ismissing(data), 2), :);
incomplete_data = data(any(ismissing(data), 2), :);

% Definir o threshold para a função retrieve
%threshold = 0.9;

%disp(incomplete_data);

% Aplicar retrieve
for i = 1:height(incomplete_data)
    new_case.gender = incomplete_data.gender(i);
    new_case.age = incomplete_data.age(i);
    new_case.hypertension = incomplete_data.hypertension(i);
    new_case.heart_disease = incomplete_data.heart_disease(i);
    new_case.ever_married = incomplete_data.ever_married(i);
    new_case.Residence_type = incomplete_data.Residence_type(i);
    new_case.avg_glucose_level = incomplete_data.avg_glucose_level(i);
    new_case.bmi = incomplete_data.bmi(i);
    new_case.smoking_status = incomplete_data.smoking_status(i);

    %new_case = incomplete_data(i, :);

    [most_similar_index, highest_similarity] = retrieve(complete_data, new_case);
    %disp(new_case);

    % Escolher o caso mais semelhante 
    similar_case = complete_data(most_similar_index, :);
    %disp(similar_case);
        
    % Preencher os valores faltantes no caso incompleto
    incomplete_data{i, "stroke"} = similar_case{1, "stroke"};
    %disp(incomplete_data(i,:));
    
end
disp(incomplete_data);

% Juntar os datasets completos e incompletos novamente
combined_data = [complete_data; incomplete_data];
%combined_data = sortrows(combined_data, "id");

% Salvar o novo dataset completo
%writetable(combined_data, 'dataset\Train_filled.csv', 'Delimiter', ';');

combined_data = sortrows(combined_data, "age");
writetable(combined_data, 'dataset\Train_filled2.csv', 'Delimiter', ';');
% Imprimir o dataset combinado após as alterações
%disp(combined_data);
%disp(incomplete_data);
