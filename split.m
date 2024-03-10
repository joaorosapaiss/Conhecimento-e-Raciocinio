% Carregar o dataset
data = readtable('Train.csv');

% Separar os dados completos e os dados com valores faltantes (NA)
complete_data = data(~any(ismissing(data), 2), :);
incomplete_data = data(any(ismissing(data), 2), :);

% Definir o threshold para a função retrieve
threshold = 0.5; 

% Aplicar retrieve
[retrieved_indexes, similarities, new_case] = retrieve(complete_data, incomplete_data, threshold);

% Juntar os datasets completos e incompletos novamente
combined_data = [complete_data; incomplete_data];
disp(retrieved_indexes);

% Salvar o novo dataset completo
%writetable(combined_data, 'dataset_filled.csv');

% Imprimir o dataset combinado após as alterações
disp(combined_data);
