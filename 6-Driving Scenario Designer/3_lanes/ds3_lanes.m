function [allData, scenario, sensors] = ds3_lanes()
%ds3_lanes - Returns sensor detections
%    allData = ds3_lanes returns sensor detections in a structure
%    with time for an internally defined scenario and sensor suite.
%
%    [allData, scenario, sensors] = ds3_lanes optionally returns
%    the drivingScenario and detection generator objects.

% Generated by MATLAB(R) 24.1 (R2024a) and Automated Driving Toolbox 24.1 (R2024a).
% Generated on: 29-Jun-2024 22:04:38

% Create the drivingScenario object and ego car
[scenario, egoVehicle] = createDrivingScenario;

% Create all the sensors
[sensors, numSensors] = createSensors(scenario);

allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {}, 'PointClouds', {}, 'INSMeasurements', {});
running = true;
while running

    % Generate the target poses of all actors relative to the ego vehicle
    poses = targetPoses(egoVehicle);
    % Get the state of the ego vehicle
    actorState = state(egoVehicle);
    time  = scenario.SimulationTime;

    objectDetections = {};
    laneDetections   = [];
    ptClouds = {};
    insMeas = {};
    isValidTime = false(1, numSensors);
    isValidLaneTime = false(1, numSensors);
    isValidPointCloudTime = false(1, numSensors);
    isValidINSTime = false(1, numSensors);

    % Generate detections for each sensor
    for sensorIndex = 1:numSensors
        sensor = sensors{sensorIndex};
        % Generate the ego vehicle lane boundaries
        if isa(sensor, 'visionDetectionGenerator')
            maxLaneDetectionRange = min(500,sensor.MaxRange);
            lanes = laneBoundaries(egoVehicle, 'XDistance', linspace(-maxLaneDetectionRange, maxLaneDetectionRange, 101));
        end
        type = getDetectorOutput(sensor);
        if strcmp(type, 'Objects only')
            if isa(sensor,'ultrasonicDetectionGenerator')
                [objectDets, isValidTime(sensorIndex)] = sensor(poses, time);
                numObjects = length(objectDets);
            else
                [objectDets, numObjects, isValidTime(sensorIndex)] = sensor(poses, time);
            end
            objectDetections = [objectDetections; objectDets(1:numObjects)]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes only')
            [laneDets, ~, isValidTime(sensorIndex)] = sensor(lanes, time);
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes and objects')
            [objectDets, numObjects, isValidTime(sensorIndex), laneDets, ~, isValidLaneTime(sensorIndex)] = sensor(poses, lanes, time);
            objectDetections = [objectDetections; objectDets(1:numObjects)]; %#ok<AGROW>
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes with occlusion')
            [laneDets, ~, isValidLaneTime(sensorIndex)] = sensor(poses, lanes, time);
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        elseif strcmp(type, 'PointCloud')
            if sensor.HasRoadsInputPort
                rdmesh = roadMesh(egoVehicle,min(500,sensor.MaxRange));
                [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, rdmesh, time);
            else
                [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, time);
            end
            ptClouds = [ptClouds; ptCloud]; %#ok<AGROW>
        elseif strcmp(type, 'INSMeasurement')
            insMeasCurrent = sensor(actorState, time);
            insMeas = [insMeas; insMeasCurrent]; %#ok<AGROW>
            isValidINSTime(sensorIndex) = true;
        end
    end

    % Aggregate all detections into a structure for later use
    if any(isValidTime) || any(isValidLaneTime) || any(isValidPointCloudTime) || any(isValidINSTime)
        allData(end + 1) = struct( ...
            'Time',       scenario.SimulationTime, ...
            'ActorPoses', actorPoses(scenario), ...
            'ObjectDetections', {objectDetections}, ...
            'LaneDetections', {laneDetections}, ...
            'PointClouds',   {ptClouds}, ... %#ok<AGROW>
            'INSMeasurements',   {insMeas}); %#ok<AGROW>
    end

    % Advance the scenario one time step and exit the loop if the scenario is complete
    running = advance(scenario);
end

% Restart the driving scenario to return the actors to their initial positions.
restart(scenario);

% Release all the sensor objects so they can be used again.
for sensorIndex = 1:numSensors
    release(sensors{sensorIndex});
end

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% Units used in createSensors and createDrivingScenario
% Distance/Position - meters
% Speed             - meters/second
% Angles            - degrees
% RCS Pattern       - dBsm

function [sensors, numSensors] = createSensors(scenario)
% createSensors Returns all sensor objects to generate detections

% Assign into each sensor the physical and radar profiles for all actors
profiles = actorProfiles(scenario);
sensors{1} = visionDetectionGenerator('SensorIndex', 1, ...
    'SensorLocation', [3.7 0], ...
    'MaxRange', 100, ...
    'DetectorOutput', 'Objects only', ...
    'Intrinsics', cameraIntrinsics([1814.81018227767 1814.81018227767],[320 240],[480 640]), ...
    'ActorProfiles', profiles);
sensors{2} = ultrasonicDetectionGenerator('SensorIndex', 2, ...
    'UpdateRate', 100, ...
    'MountingLocation', [-1 0 0.2], ...
    'MountingAngles', [-180 0 0], ...
    'FieldOfView', [70 50], ...
    'Profiles', profiles);
sensors{3} = lidarPointCloudGenerator('SensorIndex', 3, ...
    'SensorLocation', [1.5 0], ...
    'ActorProfiles', profiles);
sensors{4} = drivingRadarDataGenerator('SensorIndex', 4, ...
    'MountingLocation', [2.8 0.9 0.2], ...
    'MountingAngles', [90 0 0], ...
    'RangeLimits', [0 50], ...
    'TargetReportFormat', 'Detections', ...
    'FieldOfView', [90 5], ...
    'Profiles', profiles);
sensors{5} = drivingRadarDataGenerator('SensorIndex', 5, ...
    'MountingLocation', [2.8 -0.9 0.2], ...
    'MountingAngles', [-90 0 0], ...
    'RangeLimits', [0 50], ...
    'TargetReportFormat', 'Detections', ...
    'FieldOfView', [90 5], ...
    'Profiles', profiles);
sensors{6} = insSensor('TimeInput', true, ...
    'MountingLocation', [0.95 0 0]);
numSensors = 6;

function [scenario, egoVehicle] = createDrivingScenario
% createDrivingScenario Returns the drivingScenario defined in the Designer

% Construct a drivingScenario object.
scenario = drivingScenario;

% Add all road segments
roadCenters = [-1.97 -66.7 0;
    106.1 -39.3 0;
    105 80.4 0;
    -9.7 80.4 0;
    -9.3 0.4 0;
    85.4 0.8 0;
    85.6 50.3 0;
    20.4 50.6 0];
laneSpecification = lanespec(3, 'Width', 4);
road(scenario, roadCenters, 'Lanes', laneSpecification, 'Name', 'Road');

% Add the barriers
barrierCenters = [20.68 56.17 0;
    24.46 47.03 0];
barrier(scenario, barrierCenters, ...
    'ClassID', 6, ...
    'Width', 0.433, ...
    'Mesh', driving.scenario.guardrailMesh, 'PlotColor', [0.55 0.55 0.55], 'Name', 'Guardrail');

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [2.77301653433419 -70.7494400929541 0], ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'Car');
waypoints = [2.77301653433419 -70.7494400929541 0;
    22.39 -70.67 0.01;
    38.1 -69.7 0;
    58 -66.6 0;
    79.8 -60.6 0;
    92 -54.2 0;
    106.1 -44.8 0;
    113.1 -37 0;
    121.1 -28 0;
    127.7 -14.9 0;
    132.5 -1.3 0;
    134.5 11.5 0;
    134.5 21.3 0;
    133.5 33.1 0;
    130.3 46.3 0;
    126.5 58.6 0;
    116 74.9 0;
    106.1 85.8 0;
    93.9 95.5 0;
    81.1 102.8 0;
    68.6 108 0;
    58.8 109.3 0;
    49.4 110.6 0;
    41.2 110.7 0;
    32.3 109.1 0;
    21.6 106.9 0;
    13 103.2 0;
    2.1 96.7 0;
    -4.6 90.2 0;
    -13.8 81.4 0;
    -21 71.4 0;
    -25.5 58.3 0;
    -28.4 38 0;
    -26.4 26.7 0;
    -22.1 13.8 0;
    -15.5 1.8 0;
    -8.4 -7 0;
    1.2 -15.6 0;
    14.7 -22.8 0;
    27 -26.1 0;
    42.8 -27.2 0;
    57 -24.7 0;
    71.1 -18.2 0;
    83 -8.9 0;
    91.6 4.1 0;
    96.9 15.6 0;
    98.6 27.1 0;
    96.9 40.6 0;
    88.3 54.2 0;
    78 61.3 0;
    68.2 64.9 0;
    56 64.9 0;
    47.6 64.1 0;
    35.8 60.5 0;
    22.8 55.7 0];
speed = [-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40;-40];
yaw =  [-360;1.4215362304494;6.03350373452813;10.7991809294139;23.3687632607283;29.389771635175;43.4011842089352;48.1528666619846;54.0521643008179;68.0529229248554;75.1981797674035;86.874999522123;92.0268463035633;99.3561063316352;105.051394645944;112.751031932379;129.192837606793;136.253035860114;146.781246505856;152.36206234288;166.972737527221;173.138486637244;174.015150924547;-174.272049886558;-169.214101654225;-162.758514652016;-153.575056546537;-140.766003107517;-135.223666521313;-133.452650116094;-116.850798240566;-104.518832739805;-86.8097052826747;-75.3381102826238;-66.8666433529767;-55.5019684630368;-47.0047518230594;-35.885874176782;-20.5154095051924;-10.0920992769319;2.81611464982012;17.5033470173878;30.7721657437663;47.8082457261108;61.1815681363841;72.8940801784191;88.6890557624364;107.71013197041;136.543374345306;152.461792142088;170.221452614904;-176.098481481129;-170.123715835212;-159.588190944488;-159.807358307761];
smoothTrajectory(egoVehicle, waypoints, speed, 'Yaw', yaw);

% Add the non-ego actors
truck = vehicle(scenario, ...
    'ClassID', 2, ...
    'Length', 8.2, ...
    'Width', 2.5, ...
    'Height', 3.5, ...
    'Position', [6.30518851607898 -67.0513516602017 0.01], ...
    'RearOverhang', 1, ...
    'FrontOverhang', 0.9, ...
    'Mesh', driving.scenario.truckMesh, ...
    'Name', 'Truck');
waypoints = [6.30518851607898 -67.0513516602017 0.01;
    22.7 -66.6 0;
    40.2 -65.2 0;
    56.3 -63.2 0;
    74.2 -59.4 0;
    92.9 -50.3 0;
    111.3 -33.9 0;
    123.7 -15.4 0;
    130 3.3 0;
    130 16 0;
    130.3 27.9 0;
    128.6 40.1 0;
    124.6 52.3 0;
    117.5 64.2 0;
    109.9 76.3 0;
    95.1 89.1 0;
    79.3 98.7 0;
    64.8 104.4 0;
    43 106.1 0;
    27.4 103.8 0;
    14.1 99 0;
    2.5 92.2 0;
    -5.2 84.8 0;
    -13.7 73.8 0;
    -19 63.9 0;
    -22.7 50.6 0;
    -23.6 38.1 0;
    -21.9 24.5 0;
    -16.8 9.2 0;
    -4.9 -4.1 0;
    11.8 -16.3 0;
    25.2 -21.4 0;
    37.6 -22.8 0;
    49.5 -22 0;
    60 -19.1 0;
    70.5 -13.2 0;
    80.7 -2.7 0;
    88.9 8.1 0;
    94 21.9 0;
    93.7 31.3 0;
    90 44.9 0;
    83.5 52.8 0;
    75.3 57.1 0;
    65.4 59.9 0;
    54 59.9 0;
    45.6 58.2 0;
    35.4 55.1 0;
    25.4 51.7 0];
speed = [-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25;-25];
smoothTrajectory(truck, waypoints, speed);

bicycle1 = actor(scenario, ...
    'ClassID', 3, ...
    'Length', 1.7, ...
    'Width', 0.45, ...
    'Height', 1.7, ...
    'Position', [1.18825897607424 -63.0982887733785 0.01], ...
    'Mesh', driving.scenario.bicycleMesh, ...
    'PlotColor', [0.494 0.184 0.556], ...
    'Name', 'Bicycle1');
waypoints = [1.18825897607424 -63.0982887733785 0.01;
    17.5 -63 0;
    29.3 -61.5 0;
    40 -61.2 0;
    57.4 -59.1 0;
    73.9 -54.6 0;
    86.6 -48.3 0;
    99.7 -40.2 0;
    112 -27.7 0;
    118.2 -15.8 0;
    122.6 -4.1 0;
    125.9 9.1 0;
    125.9 24.5 0;
    125 36.6 0;
    120.2 50.7 0;
    114.9 62.8 0;
    109.2 70.3 0;
    93.1 85.3 0;
    84.9 90.8 0;
    68.6 99.6 0;
    57 101.5 0;
    42.6 102.5 0;
    32 100.6 0;
    20.1 97.5 0;
    7.8 91.4 0;
    -2.9 80.9 0;
    -12.2 69.6 0;
    -17.4 57.2 0;
    -19.4 39.9 0;
    -16.9 23.3 0;
    -9.5 6.6 0;
    1.4 -4.2 0;
    14.2 -13.4 0;
    24.7 -17.3 0;
    35.4 -18.7 0;
    45.5 -18.5 0;
    54.9 -15.9 0;
    63.2 -13.3 0;
    70.2 -8.4 0;
    74.7 -4 0;
    78.7 0.6 0;
    82.7 5.5 0;
    85.2 9.2 0;
    87.5 14 0;
    89.1 23.8 0;
    90.7 29.1 0;
    89 34.9 0;
    86.8 42 0;
    81.2 48.6 0;
    73.9 52.9 0;
    62.8 56.1 0;
    51.9 55.9 0;
    44.2 53.9 0;
    35.6 51.5 0;
    26 48.5 0];
speed = [-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10;-10];
trajectory(bicycle1, waypoints, speed);

function output = getDetectorOutput(sensor)

if isa(sensor, 'visionDetectionGenerator')
    output = sensor.DetectorOutput;
elseif isa(sensor, 'lidarPointCloudGenerator')
    output = 'PointCloud';
elseif isa(sensor, 'insSensor')
    output = 'INSMeasurement';
else
    output = 'Objects only';
end

