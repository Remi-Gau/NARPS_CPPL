% This script uses the report from fMRIprep (bold) identify maximum value
% for several metrics for each run / subject and then uses robust 
% statistics (interquartile range) to flag outliers.
% https://fmriprep.readthedocs.io/en/stable/outputs.html

clear
clc


%% Load fMRIprep confound reports
% stores only the FD values and separates them into 2 groups

machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');

maximums = [];
file_lists = cell(2,1);

for i_group = 0:1 %loop through each group
    
    group_idx = find(group_id==i_group); % index of each subject
    
    col = 1;
    
    for i_subj = 1:numel(group_idx)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) }; %ID
        
        fprintf('\nLoading %i', group_idx(i_subj))
        files_2_load = spm_select('FPList', ...
            fullfile(code_dir, 'inputs', 'fmriprep'), ...
            ['^' subject '.*.tsv$']); % list all the confounds files
        
        for i_file = 1:size(files_2_load)
            
            file_lists{i_group+1}(end+1,:) = files_2_load(i_file, :);
            
            % load each event file
            data = spm_load(files_2_load(i_file, :));
            
            maximums(i_group+1,1).FD(col,1) =  ...
                nanmax(data.FramewiseDisplacement); %#ok<*SAGROW>
            maximums(i_group+1,1).stdDVARS(col,1) =  ...
                nanmax(abs(1-data.stdDVARS));
            maximums(i_group+1,1).non0x2DstdDVARS(col,1) =  ...
                nanmax(data.non0x2DstdDVARS);
            maximums(i_group+1,1).vx0x2DwisestdDVARS(col,1) =  ...
                nanmax(abs(1-data.vx0x2DwisestdDVARS));
            
            col = col + 1;
            
        end
        
    end
    
end


%%  plot maximum of each run/subject for each metric for each group
close all

metrics = fieldnames(maximums);

for i_group = 1:2
    
    if i_group==1
        group_name = 'equal indifference';
    else
        group_name = 'equal range';
    end

    all_outliers = [];
    
    for metric = 1:numel(metrics)
        
        metric_name = metrics{metric};
        max_2_plot = getfield(maximums, metric_name);
        
        outliers = iqr_method(max_2_plot, 0);
        all_outliers(:,end+1) = outliers;
        
        %%
        figure('name', [metric_name ' - ' group_name])
        
        hold on
        
        bar(1.5:216.5, max_2_plot)
        plot(find(outliers), max_2_plot(logical(outliers)), ' or')
        
        title(group_name)
        xlabel('subject')
        ylabel(metric_name)
        
        x_tick_label = char(participants.participant_id(group_id==(i_group-1)));
        x_tick_label = x_tick_label(:,5:end);
        
        set(gca, 'xtick', 1:4:size(max_2_plot,1), ...
            'xticklabel', x_tick_label, ...
            'fontsize', 8)
        
    end
    
    file_lists{i_group}(any(all_outliers,2), :)
end