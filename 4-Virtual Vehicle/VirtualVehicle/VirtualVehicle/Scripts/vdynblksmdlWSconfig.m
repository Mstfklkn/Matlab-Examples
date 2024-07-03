function [varargout]= vdynblksmdlWSconfig(varargin)
%script for updating the 3d scene configuration block

%   Copyright 2018-2022 The MathWorks, Inc.
block = varargin{1};
if nargin >1
    userDef = varargin{2};
else
    userDef = true;
end
varargout{1} = {};
simStopped = autoblkschecksimstopped(block,true);
if simStopped


    defaultStatus = get_param(block,'defaultPos');
    if strcmp(defaultStatus,'Recommended for scene')||~userDef

        paramStruct = vdynblks3Dsceneconfig(block);
        if(~isempty(paramStruct))
            dictionaryObj = Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
            dDataSectObj = getSection(dictionaryObj,'Design Data');
            PlntVehInitLongPosObj = getEntry(dDataSectObj,'PlntVehInitLongPos');
            changedFlag = false;
            if getValue(PlntVehInitLongPosObj) ~= paramStruct.X_o
                setValue(PlntVehInitLongPosObj,paramStruct.X_o);
                changedFlag = true;
            end
            PlntVehInitLatPosObj = getEntry(dDataSectObj,'PlntVehInitLatPos');
            if getValue(PlntVehInitLatPosObj)~=paramStruct.Y_o
                setValue(PlntVehInitLatPosObj,paramStruct.Y_o);
                changedFlag = true;
            end
            PlntVehInitVertPosObj = getEntry(dDataSectObj,'PlntVehInitVertPos');
            if getValue(PlntVehInitVertPosObj)~=paramStruct.Z_o
                setValue(PlntVehInitVertPosObj,paramStruct.Z_o);
                changedFlag = true;
            end
            PlntVehInitRollAngObj = getEntry(dDataSectObj,'PlntVehInitRollAng');
            if getValue(PlntVehInitRollAngObj)~=paramStruct.phi_o
                setValue(PlntVehInitRollAngObj,paramStruct.phi_o);
                changedFlag = true;
            end
            PlntVehInitPitchAngObj = getEntry(dDataSectObj,'PlntVehInitPitchAng');
            if getValue(PlntVehInitPitchAngObj)~=paramStruct.theta_o
                setValue(PlntVehInitPitchAngObj,paramStruct.theta_o);
                changedFlag = true;
            end
            PlntVehInitYawAngObj = getEntry(dDataSectObj,'PlntVehInitYawAng');
            if getValue(PlntVehInitYawAngObj)~=paramStruct.psi_o
                setValue(PlntVehInitYawAngObj,paramStruct.psi_o);
                changedFlag = true;
            end
            if changedFlag
                saveChanges(dictionaryObj);
                %disp('Data dictionary updated.')
            end
        end
    end
    if strcmp(defaultStatus,'Recommended for scene')
  
        maskObj = get_param(block,'MaskObject');
        Xo = maskObj.getParameter('X_o');
        Xo.Enabled='off';
        Yo = maskObj.getParameter('Y_o');
        Yo.Enabled='off';
        Zo = maskObj.getParameter('Z_o');
        Zo.Enabled='off';
        phio = maskObj.getParameter('phi_o');
        phio.Enabled='off';
        thetao = maskObj.getParameter('theta_o');
        thetao.Enabled='off';
        psio = maskObj.getParameter('psi_o');
        psio.Enabled='off';
    else
        maskObj = get_param(block,'MaskObject');
        Xo = maskObj.getParameter('X_o');
        Xo.Enabled='on';
        Yo = maskObj.getParameter('Y_o');
        Yo.Enabled='on';
        Zo = maskObj.getParameter('Z_o');
        Zo.Enabled='on';
        phio = maskObj.getParameter('phi_o');
        phio.Enabled='on';
        thetao = maskObj.getParameter('theta_o');
        thetao.Enabled='on';
        psio = maskObj.getParameter('psi_o');
        psio.Enabled='on';
    end
end