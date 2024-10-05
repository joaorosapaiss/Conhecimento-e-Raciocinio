% Definir o diretório onde os arquivos .mat estão salvos
folder = 'redes/';

% Obter a lista de todos os arquivos .mat
files = dir(fullfile(folder, '*.mat'));
if isempty(files)
    error('Nenhum arquivo .mat encontrado no diretório especificado.');
end

% Inicializar variáveis para armazenar as melhores redes como um array de estruturas vazio
bestNetworks = struct('file', {}, 'combinedAccuracy', {});

for i = 1:length(files)
    % Carregar cada rede e sua precisão global
    data = load(fullfile(folder, files(i).name));
    if isfield(data, 'bestGlobalAccuracy') && isfield(data, 'bestTestAccuracy')
        % Calcular precisão combinada
        combinedAccuracy = 0.7 * data.bestGlobalAccuracy + 0.3 * data.bestTestAccuracy;
        % Adicionar nova estrutura ao array de estruturas existente
        bestNetworks(end+1) = struct('file', files(i).name, 'combinedAccuracy', combinedAccuracy);
    end
end

if isempty(bestNetworks)
    error('Nenhuma precisão global encontrada nos arquivos.');
end

% Ordenar as redes pela precisão combinada, do maior para o menor
[~, idx] = sort([bestNetworks.combinedAccuracy], 'descend');
bestNetworks = bestNetworks(idx);

% Selecionar os três melhores, se houver suficientes
numTopNetworks = min(3, numel(bestNetworks));
topNetworks = bestNetworks(1:numTopNetworks);

% remover arquivos que não estão no top 3
for i = 1:length(files)
    if ~ismember(files(i).name, {topNetworks.file})
        delete(fullfile(folder, files(i).name)); % Descomente para deletar
        fprintf('Arquivo fora do  top 3 para remover: %s\n', files(i).name);
    end
end

% Renomear os arquivos top 3
for i = 1:numTopNetworks
    newName = fullfile(folder, sprintf('best%d.mat', i));
    if ~strcmp(topNetworks(i).file, newName)  % Verificar se já não está com o nome correto
        movefile(fullfile(folder, topNetworks(i).file), newName);
        fprintf('Renomeado: %s para %s\n', topNetworks(i).file, newName);
    end
end

% Mostrar os resultados dos três melhores
disp({topNetworks.file});
disp([topNetworks.combinedAccuracy]);

