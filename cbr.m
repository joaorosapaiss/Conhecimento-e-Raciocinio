function [] = cbr()

    similarity_threshold = 0.9;
    
    formatSpec = '%f %f %f %f %f %f %f %f %f %C %f ';

    case_library = readtable('dataset/Train.csv', ...
        'Delimiter', ';', ...
        'Format', formatSpec);
    
    % New case data
    % new_case.holiday_type = 'Active';
     
    new_case.gender = 0;
    new_case.age = 67;
    new_case.hypertension = 0;
    new_case.ever_married = 1;
    new_case.Residence_type = 1;
    new_case.avg_glucose_level = 228.69;
    new_case.bmi = 36.6;
    new_case.smoking_status = '1';
    % 
    %new_case.stroke = 1;

    %new_case = case_library(1, :);

    fprintf('\nStarting retrieve phase...\n\n');
    [retrieved_indexes, similarities, new_case] = retrieve(case_library, new_case, similarity_threshold);
    
    retrieved_cases = case_library(retrieved_indexes, :);
    
    retrieved_cases.Similarity = similarities';

        fprintf('\nRetrieve phase completed...\n\n');
    
    disp(retrieved_cases);
    
    % fprintf('\nStarting reuse phase...\n\n');

    %if isfield(new_case,'price') && isfield(new_case,'duration') && isfield(new_case,'number_persons')
     %   new_price = reuse(retrieved_cases, new_case);
      %  fprintf('\nStarting revise phase...\n\n');
        
       % fprintf('\n\nReuse phase completed...\n');
    %else
     %   new_price = -1;
    %end
            

    % [journey, new_case] = revise(retrieved_cases, new_case, new_price);
    
    % final_index = find(case_library{:,1} == journey);
    
    % fprintf('\nRevise phase completed...\n');
    
    % fprintf('\nStarting retain phase...\n\n');

    % case_library = retain(case_library, new_case, final_index);
    
    % fprintf('\nRetain phase completed...\n\n');
    
    % disp(case_library(size(case_library,1), :));

end

