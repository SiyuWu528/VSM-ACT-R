# VSM-ACT-R Model

## Overview
The VSM-ACT-R model is an ACT-R based simulation aimed at optimizing time reduction within assembly sectors. This model incorporates different levels of decision-making expertise, specifically tailored for novice and expert users. It is designed to evaluate the impact of time reduction on production quality, specifically focusing on defect rates in pre-assembly and assembly phases.


### Expert Level Decision-Making
At the expert level, the model conducts a series of calculations and comparisons to identify optimal sectors for time reduction, as follows:

1. **Calculate Predicted Defect Rate Increase:**
   - The model calculates the anticipated increase in defect rates for both pre-assembly and assembly phases. This is done using operational parameters such as Overall Equipment Effectiveness (OEE), Cycle Time (CT), and the proposed time reductions.

2. **Compare Defect Rate Increases:**
   - Predicted increases for each sector are compared to determine which phase exhibits a lower risk of quality degradation.

3. **Choose Optimal Sector:**
   - The sector with the lower predicted increase in defect rate is selected as the optimal choice for implementing time reductions.

## Getting Started
To get started with the VSM-ACT-R model, clone this repository and follow the instructions below:

```bash
git clone https://github.com/SiyuWu528/VSM-ACT-R.git
cd VSM-ACT-R
```
## Usage

1: You need Emacs and Lisp Slime to run the finished ACT-R model

2: You need to download ACT-R 7.27.9 http://act-r.psy.cmu.edu/software/ for execution

## License
Specify the license under which your project is made available. (e.g., MIT, GPL-3.0, etc.)

## Acknowlegement
This model is designed and devleoped when Siyu Wu worked in Bosch Center for AI and an AI intern under the supervision of Dr. Alessandro Oltramari. The manufacturing context is from Bosch plant floor. The data in the model was redacted.
