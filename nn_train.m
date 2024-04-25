function nn_train()
    data = readmatrix('dataset\Train_filled.csv', 'Delimiter', ',', 'DecimalSeparator', '.');
    
    % Separar os inputs e targets
    input_matrix = data(:, 1:end-1);
    targets = data(:, end)';
    
    input_matrix = input_matrix';
    
    % Configurar para cada caso do Excel
    net = feedforwardnet(10);
    net.trainFcn = 'trainlm';
    net.layers{1}.transferFcn = 'tansig';
    %net.layers{2}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'purelin';
    
    net.divideParam.trainRatio = 0.75;
    net.divideParam.valRatio = 0.15;
    net.divideParam.testRatio = 0.15;
    
    [net, tr] = train(net, input_matrix, targets);
    out = sim(net, input_matrix);
    
    plotconfusion(targets, out);
    plotperf(tr);
    
    erro = perform(net, out, targets);
    accuracy = (1-erro) * 100;

    fprintf('Precisao global %.2f\n', accuracy)



    % Simular a rede apenas no conjunto teste
    TInput = input_matrix(:, tr.testInd);
    TTargets = targets(:, tr.testInd);

    out = sim(net, TInput);

    erro = perform(net, out, TTargets);
    accuracy = (1-erro) * 100;

    fprintf('Precisao teste %.2f\n', accuracy)

end