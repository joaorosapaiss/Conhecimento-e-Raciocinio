function stroke()
     tic;
     data = readmatrix('dataset\Start.csv', 'Delimiter', ';', 'DecimalSeparator', '.');

    % Separar os inputs e targets
    input_matrix = data(:, 1:end-1);
    target = data(:, end)';

    input_matrix = input_matrix';

    net = feedforwardnet(10);
    net.layers{end}.transferFcn = 'tansig'; 
    net.trainFcn = 'traingdx'; 
    net.trainParam.epochs = 100;

    net = train(net, input_matrix, target);

    % Visualizar a rede neural
    %view(net)

    % Fazer previsões com a rede treinada usando os propios dados do start
    % A partida acerta sempre visto que foi treinado com mesmo dados lol
    teste1 = [1 0 67 0 1 1 1 228.69 36.6 1]; % devia dar 1 e da 1
    teste2 = [8 0 53 0 0 1 1 211.03 34.2 1]; % devia dar 0 e da
    teste2 = teste2';
    y = sim(net,teste2);
    y = (y >= 0.5);

    disp(y);
    
   erro = perform(net,target,y); 
   fprintf("Erro %f\n",erro);
   fprintf("Precisao %f\n", (1-erro) * 100)
   tempo_execucao = toc;
   fprintf("Tempo de execução: %f segundos\n", tempo_execucao);

   save('nn_stroke.mat','net');
end