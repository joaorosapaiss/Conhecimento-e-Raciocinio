function treinarRede(app)
    fich = app.DatasetDropDown.Value;

    switch fich
        case 'Test'
            datasetPath = 'dataset\Test.csv';
        case 'Start'
            datasetPath = 'dataset\Start.csv';
        case 'Train'
            datasetPath = 'dataset\Train_filled.csv';
    end

    % Ler dados
    data = readmatrix(datasetPath, 'Delimiter', ';', 'DecimalSeparator', '.');
    
    % Separar os inputs e targets
    input_matrix = data(:, 2:end-1);
    targets = data(:, end)';

    input_matrix = input_matrix';

    % obter arquitetura através da tabela e do slider
    numCamadas = app.NCamadasSlider.Value;
    neuronios = zeros(1, numCamadas);
    for i = 1:numCamadas
        neuronios(i) = app.UITable.Data{i, 2}; 
    end

    % configurar rede
    net = feedforwardnet(neuronios);

    % treino e ativacao
    net.trainFcn = app.TreinoDropDown.Value;
    for i = 1:numCamadas
        net.layers{i}.transferFcn = app.UITable.Data{i, 3}; % Função de Ativação da tabela
    end
    net.layers{i+1}.transferFcn = app.AtivacaoDropDown.Value;


    net.divideParam.trainRatio = app.TreinoEditField.Value;
    net.divideParam.valRatio = app.ValidacaoEditField.Value;
    net.divideParam.testRatio = app.TesteEditField.Value;

    sumGlobalAccuracy = 0;
    sumTestAccuracy = 0;
    sumTrainTime = 0;
    sumTestTime = 0;
    numberOfRuns = app.NumerodeExecuesEditField.Value; 

    % app.OutputTextArea.Value = 'A treinar...';
    bestNet = [];
    bestGlobalAccuracy = 0;

    for k = 1:numberOfRuns 
        net.trainParam.showWindow = false; % para nao exibir as janelas
        [net, tr] = train(net, input_matrix, targets);
        trainTime = tr.best_perf;
        sumTrainTime = sumTrainTime  + trainTime;
        out = sim(net, input_matrix);
        out_norm = mapminmax(out, 0, 1);
        out_norm = out_norm >= 0.5;
        %plotconfusion(targets, out);
        %plotperf(tr);


        erro = perform(net, out_norm, targets);
        globalAccuracy = (1-erro) * 100;
        sumGlobalAccuracy = sumGlobalAccuracy + globalAccuracy;

        % Simular a rede apenas no conjunto teste
        TInput = input_matrix(:, tr.testInd);
        TTargets = targets(:, tr.testInd);

        out = sim(net, TInput);
        out_norm = mapminmax(out, 0, 1);
        out_norm = out_norm >= 0.5;

        erro = perform(net, out_norm, TTargets);
        testAccuracy = (1-erro) * 100;
        sumTestAccuracy = sumTestAccuracy + testAccuracy;

        sumTestTime = sumTestTime + tr.best_tperf;
        % fprintf("Teste %dº\n",k);
        % fprintf('Precisao global %.2f\n', globalAccuracy);
        % fprintf('Precisao teste %.2f\n', testAccuracy);
        % fprintf("Tempo de treino: %f\n", tr.best_perf);
        % fprintf("Tempo de teste: %f\n", tr.best_tperf);
        % fprintf('\n')

        if globalAccuracy >= bestGlobalAccuracy
            bestGlobalAccuracy = globalAccuracy;
            bestTestAccuracy = testAccuracy;
            bestTrainTime = tr.best_perf;
            bestTestTime = tr.best_tperf;
            bestNet = net;
        end

    end

    % Atualizar a interface com os resultados
    app.OutputTextArea.Value = sprintf(['Média precisão global: %.2f\n' ...
        'Média precisão teste: %.2f\n' ...
        'Média tempo de treino: %.4f segundos\n'...
        'Média tempo de teste: %.4f segundos'], ...
        'Melhor precisão global %.2f', ...
           sumGlobalAccuracy / numberOfRuns, ...
           sumTestAccuracy / numberOfRuns, ...
           sumTrainTime / numberOfRuns, ...
           sumTestTime / numberOfRuns, ...
           bestGlobalAccuracy);

    app.gRedeTreinada = bestNet;

    % Contar arquivos .mat no diretório 'redes' e determinar o próximo índice
    files = dir(fullfile('redes', '*.mat'));
    nextIndex = length(files) + 1;
    fprintf("%d\n", nextIndex);
    net = bestNet;

    disp('teste execucao');
    % Salvar cada rede treinada com um índice único
    filename = sprintf('redes/network_%d.mat', nextIndex);  
    fprintf("%s\n", filename);
    save(filename, 'net', 'bestGlobalAccuracy', 'bestTestAccuracy', 'bestTrainTime', 'bestTestTime');

    
end