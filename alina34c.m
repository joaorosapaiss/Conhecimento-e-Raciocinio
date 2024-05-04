% Script aliena c)
data = readmatrix('dataset/Test.csv', 'Delimiter', ';', 'DecimalSeparator','.');

input_matrix = data(:, 2:end-1);
targets = data(:, end)';

input_matrix = input_matrix';

files = dir(fullfile('redes', '*.mat'));
nets = struct();

for i = 1:length(files)
    netName = files(i).name;
    % remover .mat para evitar conflito
    fieldName = erase(netName, '.mat');
    loadedData = load(fullfile('redes', netName));

    if isfield(loadedData, 'net')
        nets.(fieldName) = loadedData.net;
    else
        error('Nenhuma rede encontrada no arquivo %s.', netName);
    end
end


results = struct();

for netName = fieldnames(nets)'
    net = nets.(netName{1});
    outputs = sim(net, input_matrix);
    norm_output = outputs > 0.5;
    results.(netName{1}).outputs = outputs;
    results.(netName{1}).norm_outputs = norm_output;
    results.(netName{1}).accuracy = sum(norm_output == targets) / length(targets) * 100;
    results.(netName{1}).comparisons = [norm_output; targets; norm_output == targets];
end

% for netName = fieldnames(results)'
%     fprintf('\n%s: Precisão = %.2f%%\n', netName{1}, results.(netName{1}).accuracy);
%     fprintf('Output - Target - Correto\n');
%     disp(results.(netName{1}).comparisons');
% end

for netName = fieldnames(results)'
    fprintf('\n%s: Precisão = %.2f%%\n', netName{1}, results.(netName{1}).accuracy);
    T = table(results.(netName{1}).comparisons(1,:)', results.(netName{1}).comparisons(2,:)', results.(netName{1}).comparisons(3,:)',...
              'VariableNames', {'Output', 'Target', 'Correto'});
    disp(T);
end
