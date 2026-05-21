import jsf 
import matplotlib.pyplot as plt 

# Initial State 
x0 = [50, 10]

# Model parameters
mA = 2.00 # reproduction rate of the prey
mB = 0.05 # predation rate 
mC = 1.50 # death rate of the predators 

# Reaction rates
rates = lambda x, t: [
    mA * x[0],
    mC * x[1],
    mB * x[0] * x[1],
]

reactant = [
    [1,0],
    [0,1],
    [1,1]
]

product = [
    [2, 0],
    [0, 0],
    [0, 2],
]

nu = [
    [p - r for p, r in zip(pr, re)]
    for pr, re in zip(product, reactant)
]

# Stoichiometric matrices
stoich = {
    "nu": nu, 
    "DoDisc": [1, 1], # tells JSF which compartments/species are allowed to be treated as discrete/stochastic.
    "nuReactant": reactant, 
    "nuProduct": product,
}

# JSF 
opts = {
    "EnforceDo": [0, 0], # which species are allowed to be stochastic
    "dt": 0.01, # small time steps of size 0.01, 
    "SwitchingThreshold": [30, 30] # when switching should happen,
}

# Run simulation
sim = jsf.jsf(
    x0,
    rates,
    stoich,
    t_max=10,
    config=opts,
    method="operator-splitting",
)

# Inspect output
print("Type of sim:", type(sim))
print("Length of sim:", len(sim))
print("Type of sim[0]:", type(sim[0]))
print("Type of sim[1]:", type(sim[1]))
print("Number of trajectories:", len(sim[0]))
print("Length of time vector:", len(sim[1]))
print("First few times:", sim[1][:5])
print("First few prey values:", sim[0][0][:5])
print("First few predator values:", sim[0][1][:5])

# Extract output
time = sim[1]
prey = sim[0][0]
predator = sim[0][1]

# Plot
plt.plot(time, prey, label="Prey")
plt.plot(time, predator, label="Predator")
plt.axhline(y=30, linestyle="--", label="Switching threshold")
plt.xlabel("Time")
plt.ylabel("Population size")
plt.title("Lotka-Volterra via JSF")
plt.legend()
plt.show()