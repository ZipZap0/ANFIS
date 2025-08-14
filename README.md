# 🧠 Yaw Angle Control System Using ANFIS (Adaptive Neuro-Fuzzy Inference System)  
**Intelligent Orientation Stabilization with Neuro-Fuzzy Learning**

> 📌 *This project implements an intelligent adaptive control system based on ANFIS (Adaptive Neuro-Fuzzy Inference System) for correcting yaw angle (heading) in dynamic systems such as drones, autonomous robots, or mobile vehicles. By combining the reasoning power of fuzzy logic and the learning capability of neural networks, the system learns from data to generate optimal control decisions.*

---

## 📌 Project Overview

The **ANFIS-based yaw control system** is designed to address common challenges in navigation systems: **yaw deviation** caused by external disturbances (e.g., wind, friction, sensor drift). A heuristic fuzzy inference system (FIS) is initially designed, then **trained using a hybrid learning algorithm (least squares estimation + gradient descent)** to optimize membership functions and output parameters, resulting in a more accurate and stable control signal.

This implementation includes:
- Design of a 5-rule Sugeno-type FIS
- ANFIS training with input-output data
- Closed-loop control simulation
- Performance evaluation and result visualization

---

## 🔧 System Architecture

### 1. **Input: Yaw Error**
- Represents the difference between actual orientation and desired setpoint.
- Range: [-30°, +30°]
- Primary input to the control system.

### 2. **Output: Control Signal**
- Magnitude of correction applied to actuators (e.g., motors, servos).
- Range: [-30, +30] (in angular units or equivalent PWM).
- Used to correct system orientation.

### 3. **Fuzzy Inference System (FIS) – Sugeno Type**
- **Method**: Zero-order Sugeno (constant output)
- **Number of Inputs**: 1 (`Error`)
- **Number of Outputs**: 1 (`Control`)
- **Number of Rules**: 5
- **T-Norm**: min
- **Implication Method**: min
- **Aggregation**: max
- **Defuzzification**: Weighted Average

#### 🔹 Input Membership Functions (`Error`)
| Label             | MF Type   | Parameters (trimf) |
|-------------------|-----------|--------------------|
| Negative Large    | trimf     | [-30, -15, -5]     |
| Negative Small    | trimf     | [-15, -5, 0]       |
| Zero              | trimf     | [-7, 0, 7]         |
| Positive Small    | trimf     | [0, 5, 15]         |
| Positive Large    | trimf     | [5, 15, 30]        |

#### 🔹 Output Membership Functions (`Control`)
| Label     | Type       | Parameters (constant) |
|----------|------------|------------------------|
| Out1     | constant   | -15                    |
| Out2     | constant   | -5                     |
| Out3     | constant   | 0                      |
| Out4     | constant   | 5                      |
| Out5     | constant   | 15                     |

#### 🔹 Fuzzy Rule Base
| IF Error IS...       | THEN Control = ... |
|----------------------|--------------------|
| Negative Large       | -15                |
| Negative Small       | -5                 |
| Zero                 | 0                  |
| Positive Small       | 5                  |
| Positive Large       | 15                 |

> ⚠️ Note: The rule base is symmetric and intuitive, suitable for stabilization control.

---

## 🤖 ANFIS Training Process

### 🔎 Training Objective
Optimize:
- Parameters of input membership functions (`trimf`)
- Output constant parameters
- To minimize error between predicted and target control values.

### ⚙️ ANFIS Configuration
| Parameter               | Value                     |
|-------------------------|---------------------------|
| Initialization Method   | Custom FIS                |
| Epochs                  | 400                       |
| Learning Algorithm      | Hybrid (LSE + Gradient Descent) |
| Validation Data         | None                      |
| Error Display           | Every epoch               |

### 📈 Training Output
- Trained model saved as: `anfis_trained.fis`
- Training error plot (optional)
- RMSE between predicted and actual output

---

## 🔄 Dynamic Control Simulation

The system is tested in a **closed-loop control simulation** with the following scenario:

- **Setpoint**: `0°` (reference orientation)
- **Initial Yaw**: `20°`
- **Stopping Condition**: `|error| < 0.1°` and small control effort
- **Max Iterations**: 30

### 🧮 System Dynamics Update
At each iteration:
```matlab
error = yaw - set_point;
control = evalfis(FIS_trained, error);
yaw = yaw - control;  % Apply correction
