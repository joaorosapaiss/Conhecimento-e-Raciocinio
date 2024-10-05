tic;
data = readmatrix('dataset\Start.csv', 'Delimiter', ';', 'DecimalSeparator', '.');

% Separar os inputs e targets
input_matrix = data(:, 2:end-1);
target = data(:, end)';

input_matrix = input_matrix';

net = feedforwardnet(10);
net.trainFcn = 'trainlm'; 
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'purelin';
net.divideFcn = 'dividetrain';

net = train(net, input_matrix, target);

% Visualizar a rede neural
out = sim(net, input_matrix);
out_norm = mapminmax(out, 0, 1);
out_norm = out_norm >= 0.5;


erro = perform(net, target, out); 
fprintf("Erro %f\n",erro);
fprintf("Precisao %f\n", (1-erro) * 100)
tempo_execucao = toc;
fprintf("Tempo de execução: %f segundos\n", tempo_execucao);

