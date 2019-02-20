% runs group level on the McGurk experiment and export the results corresponding to those
% published in the NIDM format

% Parametric effect of gain:
% 
% Positive effect in ventromedial PFC - for the equal indifference group
% Positive effect in ventromedial PFC - for the equal range group
% Positive effect in ventral striatum - for the equal indifference group
% Positive effect in ventral striatum - for the equal range group

% Parametric effect of loss:
% 
% Negative effect in VMPFC - for the equal indifference group
% Negative effect in VMPFC - for the equal range group
% Positive effect in amygdala - for the equal indifference group
% Positive effect in amygdala - for the equal range group

% Equal range vs. equal indifference:
% 
% Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.


%% parameters
clear
clc

machine_id = 1;% 0: container ;  1: Remi ;  2: Marco

subj_to_exclude = {
    'sub-002';...
    'sub-009'};


%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

output_dir = 'E:\ds001205\derivatives\spm12';
output_dir %#ok<NOPTS>

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr

opt = [];

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');

% Remove excluded subjects
to_remove = ismember(participants.participant_id, subj_to_exclude);
group_id(to_remove) = [];
participants.participant_id(to_remove) = [];
participants.group(to_remove) = [];
participants.gender(to_remove) = [];
participants.age(to_remove) = [];

to_remove = ismember(folder_subj, subj_to_exclude);
folder_subj(to_remove) = [];
nb_subj = numel(folder_subj);


%% figure out which GLMs to run
% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%%
cdt_ls = {...
    ' gamble_trial*bf(1) > 0'; ...
    ' gamble_trial*bf(1) < 0'; ...
    ' gamble_trialxgain^1*bf(1) > 0'; ...
    ' gamble_trialxgain^1*bf(1) < 0'; ...
    ' gamble_trialxloss^1*bf(1) > 0'; ...
    ' gamble_trialxloss^1*bf(1) < 0'; ...
    ' gamble_trialxEV^1*bf(1) > 0'; ...
    ' gamble_trialxEV^1*bf(1) < 0'; ...
    ' missed_trial*bf(1) > 0'; ...
    ' missed_trial*bf(1) < 0'; ...
    ' gamble_trial_button_press*bf(1) > 0'; ...
    ' gamble_trial_button_press*bf(1) < 0'};

contrast_ls = {...
    'gamble_trial>0'; ...
    'gamble_trial<0'; ...
    'gamble_trialxgain>0'; ...
    'gamble_trialxgain<0'; ...
    'gamble_trialxloss>0'; ...
    'gamble_trialxloss<0'; ...
    'gamble_trialxEV>0'; ...
    'gamble_trialxEV<0'; ...
    'missed_trial>0'; ...
    'missed_trial<0'; ...
    'gamble_trial_button_press>0'; ...
    'gamble_trial_button_press<0'};


%%
for iGLM = 1:size(all_GLMs)
    
    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);
    
    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg);
    grp_lvl_dir = fullfile (output_dir, 'group', analysis_dir );
    mkdir(grp_lvl_dir)
    
    contrasts_file_ls = struct('con_name', {}, 'con_file', {});

    
    %% list the fiels 
    for isubj = 1:nb_subj

%         subj_lvl_dir = fullfile ( ...
%             output_dir, folder_subj{isubj}, analysis_dir);
        
        subj_lvl_dir = fullfile ( ...
            output_dir, folder_subj{isubj});

        
        load(fullfile(subj_lvl_dir, 'SPM.mat'))
        
        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)
            
            contrasts_file_ls(isubj).con_name{iCtrst,1} = ...
                SPM.xCon(iCtrst).name;
            
            contrasts_file_ls(isubj).con_file{iCtrst,1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);
            
        end
        
    end

    
    %% EVENTS
    % paired ttest con_aud VS inc_aud
    cdts = {'con_aud_vis', 'inc_aud'};
    ctrsts = {' con_aud_vis', ' inc_aud'};
    
    subj_to_include = find_subj_to_include(cdt_ls, cdts, nb_events);
    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
        {'CON_aud', 'INC_aud'}, ...
        {'>','<','+>'});
    
    spm_jobman('run', matlabbatch)
    
    
    % ttest for all events
    ctrsts = {'all_events'};
    subj_to_include = 1:nb_subj;

    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
            {'all_events'}, ...
            {'>','<'});
    
    spm_jobman('run', matlabbatch)
    
    
    

    
    
end
