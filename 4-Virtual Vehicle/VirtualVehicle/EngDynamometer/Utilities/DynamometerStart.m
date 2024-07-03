function DynamometerStart(Block, Mode)
%
% Copyright 2016-2022 The MathWorks, Inc.

%% Setup
ModelName = bdroot(Block);
DynoCtrlBlk = [ModelName,'/Dynamometer Control'];
ResultsBlkName = [ModelName,'/Performance Monitor'];
nomsk = endsWith(Mode,'NoMsk');
if nomsk
    Mode = erase(Mode,'NoMsk');
end

%% Set variant
switch Mode
    case 'CalThrWg'
        set_param(DynoCtrlBlk, 'LabelModeActiveChoice', 'CalThrWg');
        set_param(DynoCtrlBlk, 'BackgroundColor', 'magenta');
    case 'Dynamic'
        set_param(DynoCtrlBlk, 'LabelModeActiveChoice', 'Dynamic');
        set_param(DynoCtrlBlk, 'BackgroundColor', 'cyan');
    case 'SteadyState'
        set_param(DynoCtrlBlk, 'LabelModeActiveChoice', 'SteadyState');
        set_param(DynoCtrlBlk, 'BackgroundColor', 'green');
    case 'CalCtrl'
        set_param(DynoCtrlBlk, 'LabelModeActiveChoice', 'CalCtrl');
        set_param(DynoCtrlBlk, 'BackgroundColor', 'magenta');
end

%% Run simulation
pause(0.01)
if nomsk
    sistsimout = 'SteadyDynoSimOut';
    sidynsimout = 'DynamicDynoSimOut';
    cistsimout = 'CISteadyDynoSimOut';
    cidynsimout = 'CIDynamicDynoSimOut';
    setsimout(ModelName,ResultsBlkName,Mode,'CalThrWg',...
        'SteadyWsVarName',sistsimout); % SI Eng Static Results
    setsimout(ModelName,ResultsBlkName,Mode,'CalThrWg',...
        'DynWsVarName',sidynsimout); % SI Eng Dynamic Results
    setsimout(ModelName,ResultsBlkName,Mode,'CalCtrl',...
        'SteadyWsVarName',cistsimout); % CI Eng Static Results
    setsimout(ModelName,ResultsBlkName,Mode,'CalCtrl',...
        'DynWsVarName',cidynsimout); % CI Eng Dynamic Results
    mdlin = Simulink.SimulationInput(ModelName);
    out = sim(mdlin);
    if strcmp(Mode,'CalThrWg') % SI Engines
        SteadyDynoSimOut = get(out,sistsimout);
        DynamicDynoSimOut = get(out,sidynsimout);
        assignin('base',sistsimout,SteadyDynoSimOut);
        assignin('base',sidynsimout,DynamicDynoSimOut);
        RecalibrateSIController(ResultsBlkName,'ApplyCal')
    elseif strcmp(Mode,'CalCtrl') % CI Engines
        SteadyDynoSimOut = get(out,cistsimout);
        DynamicDynoSimOut = get(out,cidynsimout);
        assignin('base',cistsimout,SteadyDynoSimOut);
        assignin('base',cidynsimout,DynamicDynoSimOut);
        RecalibrateCIController(ResultsBlkName,'ApplyCal')
    end
else
    h = waitbar(0.5, 'Rebuilding models, please wait...');
    h.Tag = 'RebuildModelWaitbarFig';
    set_param(ModelName, 'SimulationCommand', 'start');
    % Close waitbar
    h = findall(0, 'Type', 'figure', 'Tag', 'RebuildModelWaitbarFig');
    if ~isempty(h)
        delete(h(1))
    end
end
end

function setsimout(modelname,resultsblkname,mode,modename,mskparmname,mskparm)
simoutname = get_param(resultsblkname,mskparmname);
if strcmp(mode,modename) && ~strcmp(simoutname,mskparm)
    set_param(resultsblkname,mskparmname,mskparm);
end
end