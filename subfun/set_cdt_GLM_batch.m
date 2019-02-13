function matlabbatch = set_cdt_GLM_batch(matlabbatch, idx, irun, cdt)

if ~isempty(cdt.onsets)
    
    if ~isfield(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun), 'cond')
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond = [];
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end+1).name = cdt.name;
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).duration = 0;
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).tmod = 0;

    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).onset = ...
        cdt.onsets ;
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod = ...
        struct('name',{},'param',{}, 'poly', {});
    
end

end