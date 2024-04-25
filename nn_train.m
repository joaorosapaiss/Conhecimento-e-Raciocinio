function nn_train()

    data = readmatrix('dataset\Train_filled.csv', 'Delimiter', ',', 'DecimalSeparator', '.');
    
    % Separar os inputs e targets
    input_matrix = data(:, 1:end-1);
    targets = data(:, end)';
    
    input_matrix = input_matrix';
    
    % Configurar para cada caso do Excel
    net = feedforwardnet([10]);
    %net = feedforwardnet([5,5]);
    %net = feedforwardnet([10,10]);
    %net = feedforwardnet([5,10,5]);
    %net = feedforwardnet([10,10,10]);

    net.trainFcn = 'trainlm';
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'purelin';
    %net.layers{3}.transferFcn = 'tansig';
    %net.layers{4}.transferFcn = 'purelin';
    
    net.divideParam.trainRatio = 0.75;
    net.divideParam.valRatio = 0.15;
    net.divideParam.testRatio = 0.15;
 
    sumGlobalAccuracy = 0;
    sumTestAccuracy = 0;
    sumTrainTime = 0;
    sumTestTime = 0;
    numberOfRuns = 10; 

    for k = 1:numberOfRuns 
        [net, tr] = train(net, input_matrix, targets);
        trainTime = tr.best_perf;
        sumTrainTime = sumTrainTime  + trainTime;
        out = sim(net, input_matrix);
    
        plotconfusion(targets, out);
        plotperf(tr);
       
     
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
        fprintf("Teste %dº\n",k);
        fprintf('Precisao global %.2f\n', globalAccuracy);
        fprintf('Precisao teste %.2f\n', testAccuracy);
        fprintf("Tempo de treino: %f\n", tr.best_perf);
        fprintf("Tempo de teste: %f\n", tr.best_tperf);
        fprintf('\n')
    end

    fprintf('Media precisao global %.2f\n', sumGlobalAccuracy / numberOfRuns);
    fprintf('Media precisao teste %.2f\n', sumTestAccuracy / numberOfRuns);
    fprintf("Media de tempo para o treino: %f segundos\n", sumTrainTime / numberOfRuns);
 



   
    
    

end