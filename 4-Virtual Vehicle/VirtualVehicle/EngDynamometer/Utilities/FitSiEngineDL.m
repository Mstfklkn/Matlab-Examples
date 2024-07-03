function [neuralODE,airflowerror,torqueerror,maperror,egterror,EngineType]=FitSiEngineDL(EngineDataTable,maxEpochs,downsampleRatio,fparent)

% Function fits a Deep Learning model to measured data or data from SiDynamometer
%
%
% Copyright 2016-2022 The MathWorks, Inc.

%Check available licenses
if ~(dig.isProductInstalled('Deep Learning Toolbox')&&dig.isProductInstalled('Statistics and Machine Learning Toolbox')&&license('test','neural_network_toolbox')&&license('test','statistics_toolbox'))
    errordlg('Statistics and Machine Learning Toolbox and Deep Learning Toolbox install and license are required for Deep Learning Engine Model Generation','Toolbox Support')
end

options=struct;

% Overall, among all the data available, 50% is used for training, 20%
% is used for validation (for eary stopping), and the remaining 30% is
% used for testing. This can be adjusted as needed.
options.Validation_data_pct = 0.08333;

% There are about 800 iterations per epoch. Validation Frequence is
% based on the number of iterations.
options.ValidationFrequency = 2400; % validate once every x iterations
options.ValidationPatience = 5; % how many validation loss increases before terminate the training

%Pre-processing options
options.dataPreProcessingOptions.smoothData=true;
options.dataPreProcessingOptions.smoothingWindowSize=10;
options.dataPreProcessingOptions.downsampleData=true;
options.dataPreProcessingOptions.downsampleRatio=1;
options.dataPreProcessingOptions.standardizeData=true;
options.dataPreProcessingOptions.addDithering=false;
options.dataPreProcessingOptions.ditheringNoiseLevel=0.001;

options.useAugmentation=true;
options.augmentationSize=5;

% options for the NARX-like model
options.useTappedDelay=false;
options.inputDelays=1:4;
options.outputDelays=[];

% Optimizer options
options.initialLearnRate=0.01;
options.learnRateDropFactor=0.99;
options.learnRateDropPeriod=1;

%Gradient options
options.l2Regularization = 0.0001;
options.gradientThresholdMethod = "global-l2norm";% mustBeMember(gradientThresholdMethod,["global-l2norm","absolute-value"])
options.gradientThreshold = 2;

% Specify training epochs and mini batch size
options.miniBatchSize=128;
options.maxEpochs=80;

% time limit for training
options.timeLimit=12*3600; % seconds

% create and initialize deep learning network
options.hiddenUnits=100;
options.numFullyConnectedLayers=3;
options.actfunName="sigmoid";

%Set up Deep Learning data

DataSetChecked=false;

%Translate transient data into a form useable by existing DL functionality
if isfield(EngineDataTable.Properties.UserData,'Ts')
    Ts=EngineDataTable.Properties.UserData.Ts;
else
    errordlg('Engine dataset must contain Ts sampling time in table UserData');
    DataSetChecked=false;
end

if isempty(setdiff({'Speed','Throttle','Wastegate','IntCamPhs','ExhCamPhs','SpkDelta','Lambda','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','%','degCrkAdv','degCrkRet','degCrk','-','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Turbo DIVCP application
    EngInputs=[EngineDataTable.Throttle EngineDataTable.Wastegate EngineDataTable.Speed EngineDataTable.IntCamPhs EngineDataTable.ExhCamPhs EngineDataTable.SpkDelta EngineDataTable.Lambda];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=1:7;

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','IntCamPhs','ExhCamPhs','SpkDelta','Lambda','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrkAdv','degCrkRet','degCrk','-','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated DIVCP application

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.IntCamPhs EngineDataTable.ExhCamPhs EngineDataTable.SpkDelta EngineDataTable.Lambda];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,2);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','IntCamPhs','SpkDelta','Lambda','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrkAdv','degCrk','-','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated ICP-only application

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.IntCamPhs EngineDataTable.SpkDelta EngineDataTable.Lambda];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 5]);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','SpkDelta','Lambda','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrk','-','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated no cam-phaser application

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.SpkDelta EngineDataTable.Lambda];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 4 5]);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','IntCamPhs','ExhCamPhs','Lambda','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrkAdv','degCrkRet','-','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated DIVCP application at as-calibrated spark
    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.IntCamPhs EngineDataTable.ExhCamPhs EngineDataTable.Lambda];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 6]);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','IntCamPhs','ExhCamPhs','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrkAdv','degCrkRet','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated DIVCP application at as-calibrated spark and  Lambda

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.IntCamPhs EngineDataTable.ExhCamPhs];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 6 7]);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated no cam-phaser application at as-calibrated spark and Lambda

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 4 5 6 7]);

    DataSetChecked=true;

elseif isempty(setdiff({'Speed','Throttle','IntCamPhs','Torque','MAP','ExhTemp','AirMassFlw','WeightFactor'},EngineDataTable.Properties.VariableNames))&&...
        isempty(setdiff({'rev/min','%','degCrkAdv','N*m','Pa','K','kg/s','-'},EngineDataTable.Properties.VariableUnits))

    %Naturally Aspirated intake phaser application at MBT spark and as-calibrated Lambda

    EngInputs=[EngineDataTable.Throttle EngineDataTable.Speed EngineDataTable.IntCamPhs];
    EngOutputs=[EngineDataTable.AirMassFlw EngineDataTable.Torque EngineDataTable.MAP EngineDataTable.ExhTemp EngineDataTable.WeightFactor];

    EngineType=setdiff(1:7,[2 5 6 7]);

    DataSetChecked=true;

else
    errordlg('Engine dataset must contain compatible data names and units');
    DataSetChecked=false;
end

if DataSetChecked
    options.maxEpochs=maxEpochs;
    options.dataPreProcessingOptions.downsampleRatio=downsampleRatio;
    options.Ts=Ts;
    options.dataPreProcessingOptions.downsampleData=true;

    neuralODE=autoblkssidlfit(EngInputs,EngOutputs,options,fparent{1});
    if ~isempty(neuralODE)

        %Set engine shutdown initial condition definition
        neuralODE.data.Y0=([0. 0. 101325. 293.15]'-neuralODE.data.muY')./neuralODE.data.sigY';

        %Plot DoE
        PlotDoE(EngineDataTable,EngineType,options.Validation_data_pct);

        %Plot Validation
        [~,~,~,airflowerror,torqueerror,maperror,egterror]=ValidateODENN(EngInputs,EngOutputs,Ts,EngineType,neuralODE,options,fparent);

        %Set up calibration parameters of DL model for export to Simulink
        neuralODE=rmfield(neuralODE,'dlmodel');  %Temporarily remove dlmodel NN object from Simulink export
    else
        airflowerror=[];
        torqueerror=[];
        maperror=[];
        egterror=[];
    end
else
    neuralODE=[];

end

end



%DoE plots
function PlotDoE(EngineDataTable,EngineType,Validation_data_pct)

AllInputNames={'Throttle','Wastegate','Speed','IntCamPhs','ExhCamPhs','SpkDelta','Lambda'};

InputNames=AllInputNames(EngineType);

%Get data table data in the correct column order
for i=1:length(InputNames)
    [~,IA]=intersect(EngineDataTable.Properties.VariableNames,InputNames{i});
    DataInds(i)=IA;
end

Data=EngineDataTable.Variables;
Inputs=Data(:,DataInds);

Type=true(size(Inputs,1),1); %Set train = true
Type((round(size(Type,1)/2)+1):end)=false; %Set test = false

TrainInputs=Inputs(1:round(size(Inputs,1)/2),:);
TrainType=Type(1:round(size(Type,1)/2),:);

TestStartIndex = (round(size(Type,1)/2)+1+round(size(Type,1)*Validation_data_pct));
TestInputs=Inputs(TestStartIndex:end,:);
TestType=Type(TestStartIndex:end,:);

X=[TrainInputs;TestInputs];
Type=[TrainType;TestType];

color=lines(2);
group = categorical(Type,[true false],{'Train','Test'});

h=figure;
[~,~] = gplotmatrix(X,[],group,color,[],[],[],'variable',InputNames,'o');
set(h,'Name','Overlay of Test vs Train Steady-State Input Targets','NumberTitle','off', 'WindowStyle', 'Docked');
title('Overlay of Test vs Train Steady-State Input Targets');

end


%Validation plots
function [usim,ysim,yhatsim,airflowerror,torqueerror,maperror,egterror]=ValidateODENN(EngInputs,EngOutputs,Ts,EngineType,neuralODE,options,fparent)

muu=neuralODE.data.muU;
muy=neuralODE.data.muY;
sigu=neuralODE.data.sigU;
sigy=neuralODE.data.sigY;

u=EngInputs;
x=EngOutputs(:,1:end-1); %Remove weights column at end, it is not an output

nrows=round(size(u,1)/2); %reduce resulting 100ms dataset by a factor of 2 - training will be done on the first 1/2th of the dataset
Validation_data_pct = options.Validation_data_pct;
TestStartIndex = (nrows+1+round(size(u,1)*Validation_data_pct));
u=u(TestStartIndex:end,:);
x=x(TestStartIndex:end,:);

% output is same as states
y=x;

%Scale the training data
uscaled=(u-muu)./sigu;
yscaled=(y-muy)./sigy;

%Set up data for training
Uscaled=uscaled';
Yscaled=yscaled';

X=Yscaled;

T=Ts*((1:size(Uscaled,2))-1);

if options.useAugmentation

    X0=X(:,1);
    nx=size(X0,1);

    % augment states
    Xsim(:,1)=cat(1,X0,zeros(options.augmentationSize,1));

else

    Xsim(:,1)=X(:,1);

end

%ODE1 integration
for i=2:size(Uscaled,2)

    uin=Uscaled(:,i);
    xin=Xsim(:,i-1);
    dxdt=odeModel_fcn(uin,xin,neuralODE.model,neuralODE.trainingOptions.actfunName);
    Xsim(:,i)=xin+dxdt*Ts;

end

% Discard augmentation
if options.useAugmentation
    Xsim(nx+1:end,:)=[];
end

Ysim=Xsim;

Ysim=Ysim.*repmat(sigy',1,size(Ysim,2));

yhatsim=(Ysim+repmat(muy',1,size(Ysim,2)))';

ysim=y;
usim=u;
tsim=T;

h1=figure;

AllInputNames={'Throttle','Wastegate','Speed','IntCamPhs','ExhCamPhs','SpkDelta','Lambda'};
AllLabelNames={'Throttle Position (%)','Wastegate Area (%)','Engine Speed (RPM)','Intake Cam Phase (deg)','Exhaust Cam Phase (deg)','Spark Delta (deg)','Lambda (-)'};
InputNames=AllInputNames(EngineType);
InputLabelNames=AllLabelNames(EngineType);

set(h1,'NumberTitle','off', 'WindowStyle', 'Docked');

title('Engine Inputs and Outputs');

for i=1:min(length(InputNames),4)
    ax1(i)=subplot(min(length(InputNames),4),1,i);
    plot(tsim,usim(:,i));
    grid on
    ylabel(InputLabelNames{i});
end

linkaxes(ax1,'x');

if length(InputNames)<=4
    set(h1,'Name','Test Inputs');
else
    set(h1,'Name','Test Inputs 1-4');
    h2=figure;
    set(h2,'NumberTitle','off', 'WindowStyle', 'Docked');
    for i=i+1:length(InputNames)
        ax2(i-4)=subplot(length(InputNames)-4,1,i-4);
        plot(tsim,usim(:,i));
        grid on
        ylabel(InputLabelNames{i});
    end
    linkaxes(ax2,'x');
    set(h2,'Name',['Test Inputs 5-' num2str(length(InputNames))]);
end

h3=figure;
set(h3,'Name','Test Responses','NumberTitle','off', 'WindowStyle', 'Docked');
ax3(1)=subplot(4,1,1);
plot(tsim,[ysim(:,1) yhatsim(:,1)]);
grid on
ylabel('Airflow (kg/s)');

ax3(2)=subplot(4,1,2);
plot(tsim,[ysim(:,2) yhatsim(:,2)]);
grid on
ylabel('Torque (Nm)');

ax3(3)=subplot(4,1,3);
plot(tsim,[ysim(:,3) yhatsim(:,3)]);
grid on
ylabel('Intake Manifold Pressure (Pa)');

ax3(4)=subplot(4,1,4);
plot(tsim,[ysim(:,4) yhatsim(:,4)]);
grid on
ylabel('Exhaust Gas Temperature (K)');
xlabel('Time (sec)');

linkaxes(ax3,'x');

%Plot error distribution for dynamic responses

h4=figure;
set(h4,'Name','Model Test Results','NumberTitle','off', 'WindowStyle', 'Docked');
subplot(2,2,1)
airflowerror=100*(yhatsim(:,1)-ysim(:,1))./ysim(:,1);
histogram(airflowerror,100,'BinLimits',[-20,20]);
grid on
xlabel('Airflow Error Under Dynamic Conditions (%)');
ylabel('Samples');

subplot(2,2,2)
torqueerror=100*(yhatsim(:,2)-ysim(:,2))./ysim(:,2);
histogram(torqueerror,100,'BinLimits',[-20,20]);
grid on
xlabel('Torque Error Under Dynamic Conditions (%)');
ylabel('Samples');

subplot(2,2,3)
maperror=100*(yhatsim(:,3)-ysim(:,3))./ysim(:,3);
histogram(maperror,100,'BinLimits',[-20,20]);
grid on
xlabel('Intake Manifold Pressure Error Under Dynamic Conditions (%)');
ylabel('Samples');

subplot(2,2,4)
egterror=100*(yhatsim(:,4)-ysim(:,4))./ysim(:,4);
histogram(egterror,100,'BinLimits',[-20,20]);
grid on
xlabel('Exhaust Gas Temperature Error Under Dynamic Conditions (K)');
ylabel('Samples');

end


function y=odeModel_fcn(u,x,params,actFun)

% calculate outputs for each time point (y is a vector of values)
dxdt=[x;u];

% activation function
switch actFun
    case "tanh"
        actfun = @tanh;
    case "sigmoid"
        actfun = @sigmoid;
    otherwise
        error("Other functions will be added later")
end

% Forward calculation
tmp = cell(1,params.numFullyConnectedLayers-1);
% FullyConnectedLayer1 output
tmp{1} = actfun(params.("fc"+1).Weights*dxdt + params.("fc"+1).Bias);
% intermediate FullyConnectedLayer
for k = 2:params.numFullyConnectedLayers-1
    % FC layer output and activation function
    tmp{k} = actfun(params.("fc"+k).Weights*tmp{k-1} + params.("fc"+k).Bias);
end
% last FullyConnectedLayer output
y = params.("fc"+params.numFullyConnectedLayers).Weights*tmp{params.numFullyConnectedLayers-1} + params.("fc"+params.numFullyConnectedLayers).Bias;

end

function y = sigmoid(x)
y = 1./(1+exp(-x));
end