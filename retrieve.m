function [most_similar_index, highest_similarity] = retrieve(case_library, new_case)

    weighting_factors = [0.2 0.3 0.6 0.8 0.4 0.3 0.6 0.7 0.8]; 
    
    smoking_type_sim = get_smoking_status_similarities();
    
    max_values = get_max_values(case_library);
    
    %retrieved_indexes = [];
    %similarities = [];
    highest_similarity = -1; 
    most_similar_index = -1;

    lista = {'gender', 'age', 'hypertension','heart_disease' ,'ever_married', 'Residence_type', 'avg_glucose_level','bmi', 'smoking_status'}
    for i = 1:length(lista)
        if ~isfield(new_case, lista{i})
            weighting_factors(i) = 0;
        end   
    end

    
    for i=1:size(case_library,1)
        distances = zeros(1,9);

        if isfield(new_case, 'gender')
            distances(1, 1) = calculate_linear_distance(case_library{i,'gender'} / max_values('gender'),new_case.gender / max_values('gender'));
        end
        
        if isfield(new_case, 'age')
            distances(1, 2) = calculate_linear_distance(case_library{i, 'age'} / max_values('age'), new_case.age / max_values('age'));
        end
        
        if isfield(new_case, 'hypertension')
            distances(1, 3) = calculate_linear_distance(case_library{i,'hypertension'} / max_values('hypertension'),new_case.hypertension / max_values('hypertension'));
        end
        
        if isfield(new_case, 'heart_disease')
             distances(1, 4) = calculate_linear_distance(case_library{i,'heart_disease'} / max_values('heart_disease'),new_case.heart_disease / max_values('heart_disease'));
        end
        
        if isfield(new_case, 'ever_married')
            distances(1,  5) = calculate_linear_distance(case_library{i,'ever_married'} / max_values('ever_married'),new_case.ever_married / max_values('ever_married'));
        end
        
        if isfield(new_case, 'Residence_type')
            distances(1, 6) = calculate_linear_distance(case_library{i,'Residence_type'} / max_values('Residence_type'),new_case.Residence_type / max_values('Residence_type'));
        end
        
        if isfield(new_case, 'avg_glucose_level')
            distances(1, 7) = calculate_euclidean_distance(case_library{i, 'avg_glucose_level'} / max_values('avg_glucose_level'), new_case.avg_glucose_level / max_values('avg_glucose_level'));
        end
        
        if isfield(new_case, 'bmi')
            distances(1, 8) = calculate_euclidean_distance(case_library{i, 'bmi'} / max_values('bmi'), new_case.bmi / max_values('bmi'));
        end
        
        if isfield(new_case, 'smoking_status')
            distances(1, 9) = calculate_local_distance(smoking_type_sim,case_library{i,'smoking_status'}, new_case.smoking_status);
            %distances(1, 9) = calculate_linear_distance(case_library{i, 'smoking_status'} / max_values('smoking_status'), new_case.smoking_status / max_values('smoking_status'));
        end
       
        DG = (distances * weighting_factors')/sum(weighting_factors);                     
        final_similarity = 1-DG;
        
        if final_similarity >= highest_similarity
            highest_similarity = final_similarity;
            most_similar_index = i;
        end
        
       %fprintf('Case %d out of %d has a similarity of %.2f%%...\n', i, size(case_library,1), final_similarity*100);
    end

end


function [max_values] = get_max_values(case_library)

    key_set = {'gender','age', 'hypertension', 'heart_disease','ever_married','Residence_type','avg_glucose_level','bmi'};
    value_set = {max(case_library{:,'gender'}),...
                 max(case_library{:,'age'}),...
                 max(case_library{:,'hypertension'}),...
                 max(case_library{:,'heart_disease'}),...
                 max(case_library{:,'ever_married'}),...
                 max(case_library{:,'Residence_type'}),...
                 max(case_library{:,'avg_glucose_level'}),...
                 max(case_library{:,'bmi'})};
    max_values = containers.Map(key_set, value_set);
end

function [res] = calculate_local_distance(sim, val1, val2)
    i1 = find(sim.categories == categorical(val1));
    i2 = find(sim.categories == categorical(val2));
    res = 1 - sim.similarities(i1, i2);
end

function [smoking_status_sim] = get_smoking_status_similarities()
    %'Never smoked', 'formerly smoked', 'Smokes', 'Unknown'}
    smoking_status_sim.categories = categorical([0, 1, 2, 3]);

    smoking_status_sim.similarities = [
        % Never smoked | formerly smoked | Smokes | Unknown
              1.0,              0.3,         0.0,     0.5;    % Never smoked
              0.3,              1.0,         0.5,     0.4;    % Formerly smoked
              0.0,              0.5,         1.0,     0.2;    % Smokes
              0.5,              0.4,         0.2,     1.0     % Unknown
    ];
end

function [res] = calculate_linear_distance(val1, val2)
  res = abs(val1-val2);
end

function [res] = calculate_euclidean_distance(val1, val2)
    res = sqrt((val1-val2)^2);
end




