function [retrieved_indexes, similarities, new_case] = retrieve(case_library, new_case, threshold)

    weighting_factors = [0.3 0.2 0.1 0.3 0.3 0.2 0.1 0.1 0.3];  % Adjust weighting factors as needed
    
    smoking_type_sim = get_smoking_status_similarities();
    %transportation_sim = get_transportation_similarities();
    %accommodation_sim = get_accommodation_similarities();
    
    max_values = get_max_values(case_library);
    
    retrieved_indexes = [];
    similarities = [];

    lista ={'gender', 'age', 'hypertension','heart_disease' ,'ever_married', 'Residence_type', 'avg_glucose_level','bmi', 'smoking_status'}
    for i=1;i<length(lista);
          if ~isfield(new_case,lista(i))
              weighting_factors(i) = 0;
          end    
    end

    % Chegue ate aqio

    
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
            distances(1,  5) = calculate_linear_distance(case_library{i,'ever_married'} / max_values('ever_married'),new_case.ever_married / max_values('heart_disease'));
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
        
        %if isfield(new_case, 'stroke')
        %    distances(1, 10) = calculate_linear_distance(case_library{i,'stroke'} / max_values('stroke'),new_case.stroke / max_values('stroke'));
        %end

        DG = (distances * weighting_factors')/sum(weighting_factors);                     
        final_similarity = 1-DG;
        
        if final_similarity >= threshold
            retrieved_indexes = [retrieved_indexes i];
            similarities = [similarities final_similarity];
        end
        
       %fprintf('Case %d out of %d has a similarity of %.2f%%...\n', i, size(case_library,1), final_similarity*100);
    end

    % Ordenar os resultados por similaridade
    [similarities, sortIndex] = sort(similarities, 'descend');  % Ordena em ordem decrescente
    retrieved_indexes = retrieved_indexes(sortIndex);  % Reordena os índices de acordo com as similaridades

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
    i1 = find(sim.categories == val1);
    i2 = find(sim.categories == val2);
    res = 1-sim.similarities(i1,i2);
end

function [smoking_status_sim] = get_smoking_status_similarities()
    %'Never smoked', 'formerly smoked', 'Smokes', 'Unknown'}
    smoking_status_sim.categories = categorical({'0', '1', '2', '3'});

    smoking_status_sim.similarities = [
        % Never smoked formerly smoked Smokes Unknown
           1.0           0.2             0.0    0.5    % Never smoked
           0.2           1.0             0.3    0.6    % formerly smoked
           0.0           0.3             1.0    0.2    % Smokes
           0.5           0.6             0.2    1.0    % Unknown
    ];
end

function [res] = calculate_linear_distance(val1, val2)
  res = abs(val1-val2);
end

function [res] = calculate_euclidean_distance(val1, val2)
    res = sqrt((val2-val2)^2);
end

function [res] = calculate_haversine_distance(latlon1, latlon2)
    
    lat1 = latlon1(1);
    lon1 = latlon1(2);

    if lat1 == 0 && lon1 == 0
        res = -1;
        return;
    end
        
    lat2 = latlon2(1);
    lon2 = latlon2(2);
    
    if lat2 == 0 && lon2 == 0
        res = -1;
        return;
    end
    
    % Adapted from https://www.mathworks.com/matlabcentral/fileexchange/38812-latlon-distance
    radius = 6371;
    lat1 = lat1 * pi/180;
    lat2 = lat2 * pi/180;
    lon1 = lon1 * pi/180;
    lon2 = lon2 * pi/180;
    delta_lat = lat2 - lat1;
    delta_lon = lon2 - lon1;
    a = sin((delta_lat)/2)^2 + cos(lat1)*cos(lat2) * sin(delta_lon/2)^2;
    c = 2 * atan2(sqrt(a),sqrt(1-a));
    distance = radius * c;
    
    % Earth circumference is used as known maximum to normalize the distance
     res = distance/40975;
end



