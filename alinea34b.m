data = readmatrix('dataset\Train_filled.csv', 'Delimiter', ';', 'DecimalSeparator', '.');

% Separar os inputs e targets
input_matrix = data(:, 2:end-1);
targets = data(:, end)';

input_matrix = input_matrix';

% Configurar para cada caso do Excel
%net = feedforwardnet(10);
%net = feedforwardnet([5,5]);
net = feedforwardnet([10,10]);
% net = feedforwardnet([5,10,5]);
%net = feedforwardnet([10,10,10]);

net.trainFcn = 'trainlm';
% net.layers{1}.transferFcn = 'tansig';
% net.layers{2}.transferFcn = 'tansig';
% net.layers{3}.transferFcn = 'tansig';
% net.layers{4}.transferFcn = 'purelin';
net.layers{1}.transferFcn = 'logsig';
net.layers{2}.transferFcn = 'logsig';
net.layers{3}.transferFcn = 'purelin';

net.divideParam.trainRatio = 0.9;
net.divideParam.valRatio = 0.05;
net.divideParam.testRatio = 0.05;

sumGlobalAccuracy = 0;
sumTestAccuracy = 0;
bestGlobalAccuracy = 0;
bestTestAccuracy = 0;
sumTrainTime = 0;
sumTestTime = 0;
numberOfRuns = 100; 



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
    out = mapminmax(output,0,1);
    out = (out >= 0.5);


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

    if globalAccuracy >= bestGlobalAccuracy
        bestGlobalAccuracy = globalAccuracy;
        bestTestAccuracy = testAccuracy;
        bestTrainTime = tr.best_perf;
        bestTestTime = tr.best_tperf;
        bestNet = net;
    end

end

fprintf('Media precisao global %.2f\n', sumGlobalAccuracy / numberOfRuns);
fprintf('Media precisao teste %.2f\n', sumTestAccuracy / numberOfRuns);
fprintf("Media de tempo para o treino: %f\n", sumTrainTime / numberOfRuns);
fprintf("Media de tempo para o teste: %f\n", sumTestTime / numberOfRuns);

% Contar arquivos .mat no diretório 'redes' e determinar o próximo índice
files = dir(fullfile('redes', '*.mat'));
nextIndex = length(files) + 1;

net = bestNet;
% Salvar cada rede treinada com um índice único
filename = sprintf('redes/network_%d.mat', nextIndex);
% save(filename, 'net', 'bestGlobalAccuracy', 'bestTestAccuracy', 'bestTrainTime', 'bestTestTime');
