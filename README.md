# Stats-Project-3rd-Semester
##Brainstorming

Is there an association between type of conflict and conflict groups?
Total numbers ? (e.g. looting for Civilians)
Group actors (into Police force, Military, … ) -> grepl
Violence against Civilians ?

Is there a change in the type of conflict observable over time?

Heat Map of Nigerian Conflicts ? (package: Maps)
facet wrap of Maps (if possible)

change civilian targeting variable to boolean

Data Analysis first and then Read History on Wikipedia


##file structure
project/
├── data/                     # Directory for storing data files
│   ├── raw/                  # Raw data files (immutable)
│   │   └── 1997-01-01-2025-01-01-Nigeria.csv 
│   └── processed/            # Processed data files (cleaned and transformed)
│       ├── .RDS              
│       └── .RDS              
├── code/                     # Directory for utility scripts and helper functions
│   ├── .R                    
│   └── .R                    
├── R/                        # Directory for main R scripts
│   ├── 01_data_import.R      
│   ├── 02_data_cleaning.R    
│   ├── 03_analysis.R         
│   └── 04_visualization.R    
├── output/                   # Directory for storing output files
│   └── figures/              # Generated visualizations (e.g., plots, charts)
│   │   └── .png              
│   └── reports/              # Generated reports (e.g., HTML, PDF)
│   └── tables/               # Generated tables (e.g., CSV files)
├── setting.R                 # all used library
└── source_all.R              # Master script to run all R scripts in sequence



