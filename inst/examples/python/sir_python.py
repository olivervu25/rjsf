import jsf
import matplotlib.pyplot as plt 

#Initial state
N = 1000
I0 = 10
S0 = N - I0
R0 = 0

x0 = [S0, I0, R0]

#Parameters 
beta = 0.5
gamma = 0.1 

#Rates 
rates = lambda x, t: [
    beta * x[0] * x[1] / N, #infection: S + I -> 2I
    gamma * x[1], #recovery: I -> R
]

# Stoichiometry 

reactant = [
    [1, 1, 0],
    [0, 1, 0],
]

product = [
    [0, 2, 0],
    [0, 0, 1]
]

nu = [
    [p - r for p, r in zip(pr, re)]
    for pr, re in zip(product, reactant)
]

opts = {
    "EnforceDo": [0, 0, 0],
    "dt": 0.1,
    # S and R have high thresholds; I has a lower threshold.
    # This means stochasticity matters most for the infectious compartment.
    "SwitchingThreshold": [N, 10, N],
}

stoich = {
    "nu": nu, 
    "DoDisc": [0, 1, 0],
    "nuReactant": reactant,
    "nuProduct": product,
}

#jsf 
sim = jsf.jsf(
    x0,
    rates,
    stoich,
    t_max = 60,
    config = opts,
    method = "operator-splitting"
)


print("Type of sim:", type(sim))
print("Length of sim:", len(sim))

print("Type of sim[0]:", type(sim[0]))
print("Type of sim[1]:", type(sim[1]))

print("Number of trajectories:", len(sim[0]))
print("Length of time vector:", len(sim[1]))

print("First few times:", sim[1][:5])
print("First few S values:", sim[0][0][:5])
print("First few I values:", sim[0][1][:5])
print("First few R values:", sim[0][2][:5])

time = sim[1]
S = sim[0][0]
I = sim[0][1]
R = sim[0][2]

# plot 
plt.plot(time, S, label="Susceptible")
plt.plot(time, I, label="Infectious")
plt.plot(time, R, label="Recovered")

plt.axhline(y=10, linestyle="--", label="I switching threshold")

plt.xlabel("Time")
plt.ylabel("Population")
plt.title("SIR model via JSF")
plt.legend()
plt.show()