function L = generate_lists(rec_list,reg_group)
% generate list_files and list_regions based on recording list and region
% group

if strcmp(rec_list,'CORONAL')
    list_files = {'20190225_SD025_P202_R_nlab';'20190226_SD025_P101_R_nlab';'20190226_SD025_P201_R_nlab';'20190226_SD025_P301_R_nlab';'20190226_SD025_P302_R_nlab';
        '20190226_SD025_P401_R_nlab';'20190227_SD025_P102_R_nlab';'20190227_SD025_P201_R_nlab';'20190227_SD025_P202_R_nlab';'20190227_SD025_P501_R_nlab';
        '20190306_SD025_P301_R_nlab';'20190306_SD025_P401_R_nlab';'20190415_SD032_P201_R_nlab';'20190415_SD032_P202_R_nlab';'20190415_SD032_P301_R_nlab';
        '20190415_SD032_P302_R_nlab';'20190416_SD032_P102_R_nlab';'20190416_SD032_P201_R_nlab';'20190416_SD032_P202_R_nlab';'20190416_SD032_P203_R_nlab';
        '20190416_SD032_P301_R_nlab';'20190416_SD032_P302_R_nlab';'20190416_SD032_P303_R_nlab';'20190416_SD032_P402_R_nlab';'20190417_SD032_P102_R_nlab';
        '20190417_SD032_P103_R_nlab';'20190417_SD032_P202_R_nlab';'20190417_SD032_P203_R_nlab';'20190417_SD032_P301_R_nlab';'20190417_SD032_P302_R_nlab';
        '20190417_SD032_P303_R_nlab';'20190417_SD032_P401_R_nlab';'20190417_SD032_P402_R_nlab';'20190417_SD032_P403_R_nlab';'20190418_SD032_P102_R_nlab';
        '20190418_SD032_P103_R_nlab';'20190418_SD032_P201_R_nlab';'20190418_SD032_P202_R_nlab';'20190418_SD032_P203_R_nlab';'20190710_SD041_P201_R_nlab';
        '20190710_SD041_P301_R_nlab';'20190710_SD041_P401_R_nlab';'20190710_SD041_P402_R_nlab';'20190710_SD041_P501_R_nlab';'20190711_SD041_P103_R_nlab';
        '20190711_SD041_P401_R_nlab';'20190711_SD041_P402_R_nlab';'20190716_SD041_P201_R_nlab';'20190716_SD041_P203_R_nlab';'20190716_SD041_P301_R_nlab';
        '20190716_SD041_P302_R_nlab';'20190717_SD041_P103_R_nlab';'20190717_SD041_P104_R_nlab';'20190717_SD041_P201_R_nlab';'20190717_SD041_P401_R_nlab';
        '20190718_SD041_P201_R_nlab';'20190718_SD041_P202_R_nlab';'20190718_SD041_P302_R_nlab'};

elseif strcmp(rec_list,'SAGITTAL')
    list_files = {'20190228_SD025_P301_R_nlab';'20190228_SD025_P302_R_nlab';'20190301_SD025_P401_R_nlab';'20190301_SD025_P402_R_nlab';'20190418_SD032_P301_R_nlab';
        '20190418_SD032_P302_R_nlab';'20190418_SD032_P303_R_nlab';'20190418_SD032_P401_R_nlab';'20190419_SD032_P201_R_nlab';'20190419_SD032_P202_R_nlab';
        '20190419_SD032_P301_R_nlab';'20190419_SD032_P302_R_nlab';'20190419_SD032_P401_R_nlab';'20190419_SD032_P402_R_nlab'};
elseif strcmp(rec_list,'ALL')
    list_files = {'20190225_SD025_P202_R_nlab';'20190226_SD025_P101_R_nlab';'20190226_SD025_P201_R_nlab';'20190226_SD025_P301_R_nlab';'20190226_SD025_P302_R_nlab';
        '20190226_SD025_P401_R_nlab';'20190227_SD025_P102_R_nlab';'20190227_SD025_P201_R_nlab';'20190227_SD025_P202_R_nlab';'20190227_SD025_P501_R_nlab';
        '20190228_SD025_P301_R_nlab';'20190228_SD025_P302_R_nlab';'20190301_SD025_P401_R_nlab';'20190301_SD025_P402_R_nlab';'20190306_SD025_P301_R_nlab';
        '20190306_SD025_P401_R_nlab';'20190415_SD032_P201_R_nlab';'20190415_SD032_P202_R_nlab';'20190415_SD032_P301_R_nlab';'20190415_SD032_P302_R_nlab';
        '20190416_SD032_P102_R_nlab';'20190416_SD032_P201_R_nlab';'20190416_SD032_P202_R_nlab';'20190416_SD032_P203_R_nlab';'20190416_SD032_P301_R_nlab';
        '20190416_SD032_P302_R_nlab';'20190416_SD032_P303_R_nlab';'20190416_SD032_P402_R_nlab';'20190417_SD032_P102_R_nlab';'20190417_SD032_P103_R_nlab';
        '20190417_SD032_P202_R_nlab';'20190417_SD032_P203_R_nlab';'20190417_SD032_P301_R_nlab';'20190417_SD032_P302_R_nlab';'20190417_SD032_P303_R_nlab';
        '20190417_SD032_P401_R_nlab';'20190417_SD032_P402_R_nlab';'20190417_SD032_P403_R_nlab';'20190418_SD032_P102_R_nlab';'20190418_SD032_P103_R_nlab';
        '20190418_SD032_P201_R_nlab';'20190418_SD032_P202_R_nlab';'20190418_SD032_P203_R_nlab';'20190418_SD032_P301_R_nlab';'20190418_SD032_P302_R_nlab';
        '20190418_SD032_P303_R_nlab';'20190418_SD032_P401_R_nlab';'20190419_SD032_P201_R_nlab';'20190419_SD032_P202_R_nlab';'20190419_SD032_P301_R_nlab';
        '20190419_SD032_P302_R_nlab';'20190419_SD032_P401_R_nlab';'20190419_SD032_P402_R_nlab';'20190710_SD041_P201_R_nlab';'20190710_SD041_P301_R_nlab';
        '20190710_SD041_P401_R_nlab';'20190710_SD041_P402_R_nlab';'20190710_SD041_P501_R_nlab';'20190711_SD041_P103_R_nlab';'20190711_SD041_P401_R_nlab';
        '20190711_SD041_P402_R_nlab';'20190716_SD041_P201_R_nlab';'20190716_SD041_P203_R_nlab';'20190716_SD041_P301_R_nlab';'20190716_SD041_P302_R_nlab';
        '20190717_SD041_P103_R_nlab';'20190717_SD041_P104_R_nlab';'20190717_SD041_P201_R_nlab';'20190717_SD041_P401_R_nlab';'20190718_SD041_P201_R_nlab';
        '20190718_SD041_P202_R_nlab';'20190718_SD041_P302_R_nlab'};
else
    list_files = [];
end
L.list_files = list_files;

% list_regions
if strcmp(reg_group,'GROUPS')
    list_regions = {'SomatoSensoryCtx';'VisualCtx';'AuditoryCtx';'PiriformCtx';'MotorCtx';
        'OrbitalCtx';'RhinalCtx';'CingulateCtx';'LimbicCtx';'InsularCtx';
        'ParietalCtx';'AssociationCtx';'RetrosplenialCtx';'DentateGyrus';'CA1';'CA2';'CA3';
        'Thalamus';'SubstantiaNigra';'MammillaryNuclei';'OlfactoryNuclei';'ZonaIncerta';
        'PAG';'PosteriorAmygdala';'AnteriorAmygdala';'CaudatePutamen';'GlobusPallidus';'BasalGanglia';'SuperiorColliculus';
        'PretectalNuclei';'GeniculateNuclei';'PreopticArea';'SeptalNuclei';'Hypothalamus'};
    
elseif strcmp(reg_group,'LEFT-GROUPS')
    list_regions = {'SomatoSensoryCtx-L';'VisualCtx-L';'AuditoryCtx-L';'PiriformCtx-L';'MotorCtx-L';
        'OrbitalCtx-L';'RhinalCtx-L';'CingulateCtx-L';'LimbicCtx-L';'InsularCtx-L';
        'ParietalCtx-L';'AssociationCtx-L';'RetrosplenialCtx-L';'DentateGyrus-L';'CA1-L';'CA2-L';'CA3-L';
        'Thalamus-L';'SubstantiaNigra-L';'MammillaryNuclei-L';'OlfactoryNuclei-L';'ZonaIncerta-L';
        'PAG-L';'PosteriorAmygdala-L';'AnteriorAmygdala-L';'CaudatePutamen-L';'GlobusPallidus-L';'BasalGanglia-L';'SuperiorColliculus-L';
        'PretectalNuclei-L';'GeniculateNuclei-L';'PreopticArea-L';'SeptalNuclei-L';'Hypothalamus-L'};
    
elseif strcmp(reg_group,'RIGHT-GROUPS')
    list_regions = {'SomatoSensoryCtx-R';'VisualCtx-R';'AuditoryCtx-R';'PiriformCtx-R';'MotorCtx-R';
        'OrbitalCtx-R';'RhinalCtx-R';'CingulateCtx-R';'LimbicCtx-R';'InsularCtx-R';
        'ParietalCtx-R';'AssociationCtx-R';'RetrosplenialCtx-R';'DentateGyrus-R';'CA1-R';'CA2-R';'CA3-R';
        'Thalamus-R';'SubstantiaNigra-R';'MammillaryNuclei-R';'OlfactoryNuclei-R';'ZonaIncerta-R';
        'PAG-R';'PosteriorAmygdala-R';'AnteriorAmygdala-R';'CaudatePutamen-R';'GlobusPallidus-R';'BasalGanglia-R';'SuperiorColliculus-R';
        'PretectalNuclei-R';'GeniculateNuclei-R';'PreopticArea-R';'SeptalNuclei-R';'Hypothalamus-R'};
    
elseif strcmp(reg_group,'VESSEL-GROUPS')
    %list_regions = {'Ventricules';'Vessels';'ach';'acer';'mcer';'basalvessel';'vessel';'lhia'};
    list_regions = {'Ventricules-L';'Ventricules-R';...
        'ach-L';'ach-R';'acer-L';'acer-R';'mcer-L';'mcer-R';...
        'basalvessel-L';'basalvessel-R';'vessel-L';'vessel-R';'lhia-L';'lhia-R'};

else
    list_regions = [];
end
L.list_regions = list_regions;

end