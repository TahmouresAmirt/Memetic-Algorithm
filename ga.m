
global nVar


%% Problem Definition

CostFunction = @(x) MinOne(x);     % Cost Function

nVar = 90;            % Number of Decision Variables

VarSize = [1 nVar];   % Decision Variables Matrix Size

%% GA Parameters

MaxIt = 500;	% Maximum Number of Iterations

nPop = 100;	% Population Size

pc = 0.8;                 % Crossover Percentage
nc = 2*round(pc*nPop/2);  % Number of Offsprings (also Parnets)

pm = 0.5;                 % Mutation Percentage
nm = round(pm*nPop);      % Number of Mutants
mu = 0.02;                % Mutation Rate

pl = 0.3;                 % Local Search Percentage
nl = round(pl*nPop);      % Number of Members Selected for Local Search
ml = 0.03;                % Local search Rate

ANSWER = 'Roulette Wheel';%questdlg('Choose selection method:', 'Genetic Algorithm', ...
    %'Roulette Wheel', 'Tournament', 'Random', 'Roulette Wheel');

UseRouletteWheelSelection = strcmp(ANSWER, 'Roulette Wheel');
UseTournamentSelection = strcmp(ANSWER, 'Tournament');
UseRandomSelection = strcmp(ANSWER, 'Random');

if UseRouletteWheelSelection
    beta = 8;         % Selection Pressure
end

if UseTournamentSelection
    TournamentSize = 3;   % Tournamnet Size
end

pause(0.01); % Needed due to a bug in older versions of MATLAB

%% Initialization

empty_individual.Position = [];
empty_individual.Cost = [];

pop = repmat(empty_individual, nPop, 1);

for i = 1:nPop
    
    % Initialize Position
    pop(i).Position = randi([0 1], VarSize);
    
    % Evaluation
    pop(i).Cost = CostFunction(pop(i).Position);
    
end

% Sort Population
Costs = [pop.Cost];
[Costs, SortOrder] = sort(Costs);
pop = pop(SortOrder);

% Store Best Solution
BestSol = pop(1);

% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

% Store Cost
WorstCost = pop(end).Cost;

%% Main Loop

for it = 1:MaxIt
    
    % Calculate Selection Probabilities
    if UseRouletteWheelSelection
        P = exp(-beta*Costs/WorstCost);
        P = P/sum(P);
    end
    
    % Crossover
    popc = repmat(empty_individual, nc/2, 2);
    for k = 1:nc/2
        
        % Select Parents Indices
        if UseRouletteWheelSelection
            i1 = RouletteWheelSelection(P);
            i2 = RouletteWheelSelection(P);
        end
        if UseTournamentSelection
            i1 = TournamentSelection(pop, TournamentSize);
            i2 = TournamentSelection(pop, TournamentSize);
        end
        if UseRandomSelection
            i1 = randi([1 nPop]);
            i2 = randi([1 nPop]);
        end

        % Select Parents
        p1 = pop(i1);
        p2 = pop(i2);
        
        % Perform Crossover
        [popc(k, 1).Position, popc(k, 2).Position] = Crossover(p1.Position, p2.Position);
        
        % Evaluate Offsprings
        popc(k, 1).Cost = CostFunction(popc(k, 1).Position);
        popc(k, 2).Cost = CostFunction(popc(k, 2).Position);
        
    end
    popc = popc(:);
    
    
    % Mutation
    popm = repmat(empty_individual, nm, 1);
    for k = 1:nm
        
        % Select Parent
        i = randi([1 nPop]);
        p = pop(i);
        
        % Perform Mutation
        popm(k).Position = Mutate(p.Position, mu);
        
        % Evaluate Mutant
        popm(k).Cost = CostFunction(popm(k).Position);
        
    end
    
    % Local Search
    popl = repmat(empty_individual, nl, 1);
    for k = 1:nl
        
        % Selection
        i = randi([1 nPop]);
        p = pop(i);
        
        % Perform Local Search
        popl(k).Position = Local_Search(p.Position, ml);
        
        % Evaluate them
        popl(k).Cost = CostFunction(popl(k).Position);
        
    end
    
    
    % Create Merged Population
    pop = [pop
         popc
         popm
         popl]; %#ok
     
    % Sort Population
    Costs = [pop.Cost];
    [Costs, SortOrder] = sort(Costs);
    pop = pop(SortOrder);
    
    % Update Worst Cost
    WorstCost = max(WorstCost, pop(end).Cost);
    
    % Truncation
    pop = pop(1:nPop);
    Costs = Costs(1:nPop);
    
    % Store Best Solution Ever Found
    BestSol = pop(1);
    
    % Store Best Cost Ever Found
    BestCost(it) = BestSol.Cost;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end

%% Results

figure;
plot(BestCost, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Cost');
grid on;
