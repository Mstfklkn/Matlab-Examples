function [varargout]= vdynblksrefconfig(varargin)
%

%   Copyright 2018-2023 The MathWorks, Inc.

% Disable OpenGL warning for parsim
block = varargin{1};
maskMode = varargin{2};
varargout{1} = {};
simStopped = autoblkschecksimstopped(block) && ~(strcmp(get_param(bdroot(block),'SimulationStatus'),'updating'));
manType = get_param(block,'manType');
prevType = get_param(block,'prevType');
vehSys = bdroot(block);
manOverride = strcmp(get_param(block,'manOverride'),'on');
sim3dEnabled = strcmp(get_param(block,'engine3D'),'Enabled');
visPath = [vehSys '/Visualization'];
driverpath = [vehSys '/Driver Commands'];
scenPath =[block '/Reference Generator'];
dcsPath = [block '/Reference Generator/Drive Cycle/Drive Cycle Source'];
visHandle = getSimulinkBlockHandle(visPath);
driverHandle = getSimulinkBlockHandle(driverpath);
if (driverHandle == -1) || (visHandle == -1)
    disp('Warning: The reference generator subsystem is intended to work only with the example project and model architecture that it ships in. Functionality may therefore be limited if used in another model where the visualization, driver or environment subsystems are no longer available or different locations.')
end

file = get_param(bdroot, 'Name');
Plant = get_param([file, '/Vehicle'], 'LabelModeActiveChoice');
Trailer = get_param([file, '/Vehicle/',Plant,'/Trailer'], 'LabelModeActiveChoice');
if strcmp(Trailer, 'NoTrailer')
    set_param(block, 'Trailer', 'No Trailer');
else
    set_param(block, 'Trailer', 'One-Axle Trailer');
end


switch maskMode
    case 0
        [~]=vdynblksrefconfig(block,1);
        [~]=vdynblksrefconfig(block,3);

    case 1
        switch manType
            case 'Double Lane Change'
                set_param(scenPath,'LabelModeActiveChoice','Double Lane Change');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','1');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','1');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'DLCGroup'},{'BGroup';'WOTGroup';'ISGroup';'CRGroup';'SSGroup';'SDGroup';'FHGroup';'DCGroup'});
                autoblksenableparameters(block,{'t_start','xdot_r'},{'steerDir'},[],[],true);
                if simStopped && manOverride  && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 25;
            case 'Increasing Steer'
                set_param(scenPath,'LabelModeActiveChoice','Increasing Steer');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'ISGroup'},{'DLCGroup';'CRGroup';'SSGroup';'SDGroup';'FHGroup';'DCGroup'});
                autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                if simStopped && manOverride && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 60;
            case 'Swept Sine'
                set_param(scenPath,'LabelModeActiveChoice','Swept Sine');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'SSGroup'},{'BGroup';'WOTGroup';'ISGroup';'DLCGroup';'CRGroup';'SDGroup';'FHGroup';'DCGroup'});
                autoblksenableparameters(block,[],{'steerDir','t_start','xdot_r'},[],[],true);
                if simStopped && manOverride  && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 40;
            case 'Sine with Dwell'
                set_param(scenPath,'LabelModeActiveChoice','Sine with Dwell');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'SDGroup'},{'BGroup';'WOTGroup';'ISGroup';'DLCGroup';'CRGroup';'SSGroup';'FHGroup';'DCGroup'});
                autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                if simStopped && manOverride  && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 25;
            case 'Constant Radius'
                set_param(scenPath,'LabelModeActiveChoice','Constant Radius');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','2');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','1');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'CRGroup'},{'BGroup';'WOTGroup';'DLCGroup';'ISGroup';'SSGroup';'SDGroup';'FHGroup';'DCGroup'});
                autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                if simStopped && manOverride  && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Stanley Driver');  % this in turn will also update the driver params if needed
                end
                simTime = 60;
            case 'Fishhook'
                set_param(scenPath,'LabelModeActiveChoice','Fishhook');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'FHGroup'},{'BGroup';'WOTGroup';'ISGroup';'DLCGroup';'CRGroup';'SDGroup';'SSGroup';'DCGroup'});
                autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                pFdbkChk = get_param(block,'pFdbk');
                if strcmp(pFdbkChk,'off')
                    autoblksenableparameters(block,{'tDwell1'},{'pZero'},[],[],'false')
                else
                    autoblksenableparameters(block,{'pZero'},{'tDwell1'},[],[],'false')
                end
                if simStopped && manOverride && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 40;
            case 'Drive Cycle'
                set_param(scenPath,'LabelModeActiveChoice','Drive Cycle');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','2');
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'DCGroup'},{'BGroup';'WOTGroup';'ISGroup';'CRGroup';'SSGroup';'SDGroup';'FHGroup';'DLCGroup'});
                autoblksenableparameters(block,[],{'steerDir','t_start','xdot_r'},[],[],true);
                if simStopped && manOverride && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Longitudinal Driver');
                    set_param(block,'engine3D','Disabled');
                end
                loadedCycle = get_param(dcsPath,'UserData');
                if ~isempty(loadedCycle)
                    %if workspace variable or other sources are selected
                    timeVec = loadedCycle.Time;
                    simTime = timeVec(end);
                else
                    simTime = 0;
                end
            case 'Braking'
                set_param(scenPath,'LabelModeActiveChoice','Braking');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'BGroup'},{'WOTGroup';'FHGroup';'ISGroup';'DLCGroup';'CRGroup';'SDGroup';'SSGroup';'DCGroup'});
                autoblksenableparameters(block,{'t_start','xdot_r'},[],[],[],true);
                % autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                % pFdbkChk = get_param(block,'pFdbk');
                % if strcmp(pFdbkChk,'off')
                %     autoblksenableparameters(block,{'tDwell1'},{'pZero'},[],[],'false')
                % else
                %     autoblksenableparameters(block,{'pZero'},{'tDwell1'},[],[],'false')
                % end
                if simStopped && manOverride && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Predictive Driver');
                end
                simTime = 40;
            case 'Wide Open Throttle (WOT)'
                set_param(scenPath,'LabelModeActiveChoice','WOT');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],{'WOTGroup'},{'BGroup';'FHGroup';'ISGroup';'DLCGroup';'CRGroup';'SDGroup';'SSGroup';'DCGroup'});
                autoblksenableparameters(block,{'t_start','xdot_r'},[],[],[],true);
                % autoblksenableparameters(block,{'steerDir','t_start','xdot_r'},[],[],[],true);
                if simStopped && manOverride && ~strcmp(prevType,manType) && (driverHandle == -1)
                    set_param([vehSys '/Driver Commands'],'driverType','Longitudinal Driver');
                end
                simTime = 40;
            case 'No Commands'
                set_param(scenPath,'LabelModeActiveChoice','No Commands');
                if visHandle ~= -1
                    set_param([vehSys '/Visualization/Scope Type'],'LabelModeActiveChoice','0');
                    if strcmp(Trailer,'NoTrailer')
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','0');
                    else
                        set_param([vehSys '/Visualization/Vehicle XY Plotter'],'LabelModeActiveChoice','3');
                    end
                else
                    disp('Warning: Visualization subsystem not found. Model scopes and visualizaiton aids may not function as expected.')
                end
                autoblksenableparameters(block, [], [],[],{'BGroup';'WOTGroup';'FHGroup';'ISGroup';'DLCGroup';'CRGroup';'SDGroup';'SSGroup';'DCGroup'});
                simTime = 10;
            otherwise
                simTime = 10;
        end
        % update driver sldd, and 3D initial positions
        if simStopped && manOverride && ~strcmp(prevType,manType)
            update3DScene(block,manType);
            [~] = vdynblksmdlWSconfig(block,false);
            dictionaryObj = Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
            dDataSectObj = getSection(dictionaryObj,'Design Data');
            list=VirtualAssemblyScenarioParaList(manType);
            for i=1:length(list)
                ddObj = getEntry(dDataSectObj,list{i}{1});
                setValue(ddObj,str2double(list{i}{2}));
            end

            saveChanges(dictionaryObj);
        end

        set_param(block,'simTime',num2str(simTime));

        set_param(block,'prevType',manType)
    case 2  % update time button
        switch manType
            case 'Drive Cycle'
                dt = get_param([block '/Reference Generator/Drive Cycle/Drive Cycle Source'],'dt');
                set_param([block '/Reference Generator/Drive Cycle/Drive Cycle Source'],'dt',dt); % needed to force a block update for some masking reason
                loadedCycle = get_param([block '/Reference Generator/Drive Cycle/Drive Cycle Source'],'UserData');
                timeVec = loadedCycle.Time;
                simTime = timeVec(end);
            case 'Double Lane Change'
                simTime = 25;
            case 'Increasing Steer'
                simTime = 60;
            case 'Swept Sine'
                simTime = 40;
            case 'Sine with Dwell'
                simTime = 25;
            case 'Constant Radius'
                simTime = 60;
            case 'Fishhook'
                simTime = 40;
            case 'Braking'
                simTime = 40;
            case 'Wide Open Throttle (WOT)'
                simTime = 40;
            otherwise
        end

        set_param(block,'simTime',num2str(simTime));

    case 3 % manual override button
        if manOverride
            autoblksenableparameters(block,[],[],[],{'simTimeGroup'},true);
        else
            autoblksenableparameters(block,[],[],{'simTimeGroup'},[],true);
        end
    case 4 % mask update for graphics enabling
        if sim3dEnabled
            autoblksenableparameters(block,[],[],{'engine3DSettingsGroup'},[],true);
        else
            autoblksenableparameters(block,[],[],[],{'engine3DSettingsGroup'},true);
        end

end
end
function update3DScene(block,manType)
sim3DBlkPath = block;
if strcmp(manType,'Double Lane Change')
    set_param(sim3DBlkPath,'SceneDesc','Double lane change');
else
    set_param(sim3DBlkPath,'SceneDesc','Open surface');
end
end
