# Time Series Forecasting using PSO and Intuitionistic Fuzzy Logic

## Overview

This project implements a time series forecasting approach using Particle Swarm Optimization (PSO) to optimize the fuzzy interval width, combined with Intuitionistic Fuzzy Logic for forecasting.

The model is applied to University of Alabama enrollment data from 1971 to 1992.

## Methodology

The forecasting workflow includes:

1. Loading historical enrollment data
2. Defining the universe of discourse
3. Optimizing fuzzy interval width using Particle Swarm Optimization
4. Constructing triangular fuzzy intervals
5. Calculating membership values
6. Converting membership values into Intuitionistic Fuzzy Sets
7. Fuzzifying the time-series observations
8. Constructing Fuzzy Logical Relationships (FLRs)
9. Generating forecasts
10. Evaluating forecasting performance using Mean Squared Error (MSE)

## PSO Configuration

- Number of particles: 20
- Maximum iterations: 50
- Inertia weight: 0.7
- Cognitive coefficient: 1.4
- Social coefficient: 1.4
- Interval width range: 300–700

## Dataset

The project uses University of Alabama enrollment data covering the period from 1971 to 1992.

## Evaluation

Forecasting performance is evaluated using Mean Squared Error (MSE).

## Technologies

- MATLAB
- Particle Swarm Optimization
- Intuitionistic Fuzzy Logic
- Time Series Forecasting    
