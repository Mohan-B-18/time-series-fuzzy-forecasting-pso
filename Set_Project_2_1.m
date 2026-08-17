clc; clear; close all;

%% ============================================================
%            UNIVERSITY OF ALABAMA ENROLLMENT DATA
% =============================================================
years = (1971:1992)';
enrollment = [13055 13563 13867 14696 15460 15311 15603 15861 ...
              16807 16919 16388 15433 15497 15145 15163 15984 ...
              16859 18150 17388 15433 13641 18876]';

Dmin = min(enrollment);
Dmax = max(enrollment);

P1 = 55; 
P2 = 663;

Umin = Dmin - P1;    % = 13000
Umax = Dmax + P2;    % = 20000


%% ============================================================
%                PARTICLE SWARM OPTIMIZATION
%    Optimize interval width (paper approach)
% =============================================================
num_particles = 20;
max_iter = 50;

w = 0.7;         % inertia
c1 = 1.4;        % cognitive
c2 = 1.4;        % social

lb = 300;        % lower bound for interval width
ub = 700;        % upper bound

% Initialize particle positions
pos = lb + (ub-lb).*rand(num_particles,1);
vel = zeros(num_particles,1);

pbest = pos;
pbest_val = inf(num_particles,1);

[gbest_val, idx] = min(pbest_val);
gbest = pos(idx);

%% ============================================================
%            PSO MAIN LOOP
% =============================================================
for iter = 1:max_iter

    for p = 1:num_particles
        interval_width = pos(p);

        % compute fitness (MSE)
        mse_val = compute_MSE(interval_width, enrollment, Umin, Umax);

        if mse_val < pbest_val(p)
            pbest_val(p) = mse_val;
            pbest(p) = pos(p);
        end

        if mse_val < gbest_val
            gbest_val = mse_val;
            gbest = pos(p);
        end
    end

    % Update particle velocity and position
    for p = 1:num_particles
        vel(p) = w*vel(p) ...
                 + c1*rand*(pbest(p)-pos(p)) ...
                 + c2*rand*(gbest-pos(p));

        pos(p) = pos(p) + vel(p);

        % Boundary check
        pos(p) = max(min(pos(p), ub), lb);
    end

    fprintf('Iteration %d  | Best MSE = %f | Best Interval = %f\n',...
            iter, gbest_val, gbest);

end

fprintf('\nOPTIMAL INTERVAL WIDTH FOUND BY PSO = %.4f\n', gbest);

%% ============================================================
%      FINAL RUN WITH OPTIMAL INTERVAL WIDTH (Generate Tables)
% =============================================================
interval_width = gbest;
[TABLE2, TABLE3, TABLE4, TABLE5, TABLE6, MSE_Final] = ...
        full_model(interval_width, enrollment, Umin, Umax);

disp('==================== FINAL TABLES ====================');
TABLE2      % Membership (Table 2)
TABLE3      % Intuitionistic Fuzzy μ,ν,π (Table 3)
TABLE4      % Fuzzified (Table 4)
TABLE5      % FLRs (Table 5)
TABLE6      % Forecasts (Table 6)
disp('MSE of Final Model =');
disp(MSE_Final);



%% ============================================================
%              SUPPORTING FUNCTION DEFINITIONS
% ============================================================


%% ---------- FITNESS FUNCTION FOR PSO (Compute MSE) ----------
function mse_val = compute_MSE(interval_width, enrollment, Umin, Umax)

num_sets = 14;

% build triangular fuzzy intervals
intervals = zeros(num_sets,3);
for i = 1:num_sets
    a = Umin + (i-1)*interval_width;
    b = a + interval_width;
    c = b + interval_width;
    intervals(i,:) = [a b c];
end

centroids = intervals(:,2);

% membership
membership = zeros(length(enrollment), num_sets);
for k = 1:length(enrollment)
    x = enrollment(k);
    for i = 1:num_sets
        a = intervals(i,1);
        b = intervals(i,2);
        c = intervals(i,3);

        if (x<=a || x>=c)
            membership(k,i) = 0;
        elseif (x > a && x <= b)
            membership(k,i) = (x-a)/(b-a);
        else
            membership(k,i) = (c-x)/(c-b);
        end
    end
end

% IFS conversion
deltaInd = 0.1;
mu = membership;
pi = deltaInd.*(1 - mu);
nu = 1 - mu - pi;

% fuzzification
[~, fuzzified] = min(pi,[],2);

% FLRs
FLR = [];
for i = 1:length(fuzzified)-1
    FLR = [FLR; fuzzified(i) fuzzified(i+1)];
end

% forecasting
forecast = nan(size(enrollment));
for i = 1:length(fuzzified)-1
    curr = fuzzified(i);
    conseq = FLR(FLR(:,1)==curr,2);
    if isempty(conseq)
        forecast(i+1) = centroids(curr);
    else
        forecast(i+1) = mean(centroids(conseq));
    end
end

valid = ~isnan(forecast);
mse_val = mean((enrollment(valid)-forecast(valid)).^2);

end


%% ---------- GET FULL TABLES USING BEST INTERVAL WIDTH ----------
function [TABLE2, TABLE3, TABLE4, TABLE5, TABLE6, MSE] = ...
            full_model(interval_width, enrollment, Umin, Umax)

num_sets = 14;
intervals = zeros(num_sets,3);

for i = 1:num_sets
    a = Umin + (i-1)*interval_width;
    b = a + interval_width;
    c = b + interval_width;
    intervals(i,:) = [a b c];
end

centroids = intervals(:,2);

% membership table (TABLE 2)
membership = zeros(length(enrollment), num_sets);
for k = 1:length(enrollment)
    x = enrollment(k);
    for i = 1:num_sets
        a = intervals(i,1);
        b = intervals(i,2);
        c = intervals(i,3);

        if (x<=a || x>=c)
            membership(k,i)=0;
        elseif (x > a && x <= b)
            membership(k,i)=(x-a)/(b-a);
        else
            membership(k,i)=(c-x)/(c-b);
        end
    end
end

TABLE2 = membership;

% QFS (TABLE 3)
deltaInd = 0.1;
mu = membership;
pi = deltaInd.*(1-mu);
nu = 1 - mu - pi;
TABLE3 = struct('mu',mu,'nu',nu,'pi',pi);

% fuzzified (TABLE 4)
[~, fuzzified] = min(pi,[],2);
TABLE4 = fuzzified;

% FLRs (TABLE 5)
FLR = [];
for i=1:length(fuzzified)-1
    FLR = [FLR; fuzzified(i) fuzzified(i+1)];
end
TABLE5 = FLR;

% forecasting (TABLE 6)
forecast = nan(size(enrollment));
for i = 1:length(fuzzified)-1
    curr = fuzzified(i);
    conseq = FLR(FLR(:,1)==curr,2);
    if isempty(conseq)
        forecast(i+1) = centroids(curr);
    else
        forecast(i+1) = mean(centroids(conseq));
    end
end
TABLE6 = forecast;

valid = ~isnan(forecast);
MSE = mean((enrollment(valid)-forecast(valid)).^2);

end
