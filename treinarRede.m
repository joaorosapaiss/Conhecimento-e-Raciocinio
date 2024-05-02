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
    numberOfRuns = 100; 

    % app.OutputTextArea.Value = 'A treinar...';

    for k = 1:numberOfRuns 
        net.trainParam.showWindow = false; % para nao exibir as janelas
        [net, tr] = train(net, input_matrix, targets);
        trainTime = tr.best_perf;
        sumTrainTime = sumTrainTime  + trainTime;
        out = sim(net, input_matrix);

        %plotconfusion(targets, out);
        %plotperf(tr);


        erro = perform(net, out, targets);
        globalAccuracy = (1-erro) * 100;
        sumGlobalAccuracy = sumGlobalAccuracy + globalAccuracy;

        % Simular a rede apenas no conjunto teste
        TInput = input_matrix(:, tr.testInd);
        TTargets = targets(:, tr.testInd);

        out = sim(net, TInput);

        erro = perform(net, out, TTargets);
        testAccuracy = (1-erro) * 100;
        sumTestAccuracy = sumTestAccuracy + testAccuracy;

        sumTestTime = sumTestTime + tr.best_tperf;
        %fprintf("Teste %dº\n",k);
        %fprintf('Precisao global %.2f\n', globalAccuracy);
        %fprintf('Precisao teste %.2f\n', testAccuracy);
        %fprintf("Tempo de treino: %f\n", tr.best_perf);
        %fprintf("Tempo de teste: %f\n", tr.best_tperf);
        %fprintf('\n')
    end

    % Atualizar a interface com os resultados
    app.OutputTextArea.Value = sprintf(['Média precisão global: %.2f\n' ...
        'Média precisão teste: %.2f\n' ...
        'Média tempo de treino: %.4f segundos\n'...
        'Média tempo de teste: %.4f segundos'], ...
           sumGlobalAccuracy / numberOfRuns, ...
           sumTestAccuracy / numberOfRuns, ...
           sumTrainTime / numberOfRuns, ...
           sumTestTime / numberOfRuns);

end