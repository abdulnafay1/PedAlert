PedAlert: Software Infrastructure for Distracted Pedestrian Detection
PedAlert is an open-source, iOS-based software infrastructure system developed at Howard University designed to mitigate distracted pedestrian accidents near urban intersections. Leveraging mobile sensing, geospatial data, and real-time alerts, PedAlert operates passively on standard smartphones without requiring specialized roadside beacons or external hardware.
This repository contains both the source code for the iOS application and the machine learning pipeline used for distraction detection.
Version 1: Core Geofencing & Location Infrastructure
The initial version of PedAlert establishes the fundamental location tracking, spatial context, and notification pipeline. It uses iOS location frameworks to create configurable buffer zones around high-risk intersections and issues proactive alerts as a user approaches a crosswalk.
Key Features

Modular Architecture: Consists of four interconnected modules: User Device Management, Location Tracking, Distraction Detection, and Alert System.
Passive Geofencing: Employs iOS Core Location services and Apple Maps data to detect when a user enters a $\pm 5\text{--}10\text{ meter}$ geofenced buffer zone surrounding an intersection.
Hardware-Independent: Operates completely on-device without relying on Bluetooth Low Energy (BLE) beacons or physical infrastructure.
Alert Delivery: Triggers real-time visual, audible, or haptic notifications to refocus pedestrian attention before stepping into crosswalks.
Version 2: On-Device Machine Learning & Context Awareness
PedAlert v2 builds upon the location tracking infrastructure of Version 1 by integrating on-device machine learning to infer user distraction in real time using smartphone motion sensors.
Instead of issuing alerts based solely on proximity, PedAlert v2 acts as a dual-condition gating system: notifications are triggered only when a user is both inside a geofenced risk zone AND actively distracted.
What’s New in Version 2

ML-Based Distraction Detection: Integrated a Multi-Layer Perceptron (MLP) binary classifier trained on the public ExtraSensory dataset to recognize distracted walking states from raw accelerometer (raw_acc) and gyroscope (proc_gyro) signals.
CoreML Integration: The PyTorch model is converted and optimized for on-device CoreML inference, utilizing Apple's Neural Engine and CPU/GPU for low-latency predictions.
Safety-Weighted Optimization: Implemented weighted binary cross-entropy and class-weighting strategies during training, prioritizing high recall ($0.77$) for the distracted class to minimize dangerous false negatives (undetected distracted walking).
Reduced Alert Fatigue: By filtering out non-distracted pedestrians walking through geofenced zones, the system minimizes unnecessary notifications and increases overall user responsiveness.
Planned Advancements & Future Work

Field Deployments: Transitioning from lab/simulation environments to real-world intersection field trials to evaluate performance across diverse pedestrian walking patterns and changing GPS accuracy.
Model Optimization & Battery Conservation: Fine-tuning continuous background sensor polling and CoreML model execution loops to reduce power consumption for all-day passive monitoring.
Expanded Training Datasets: Training the classifier on broader, more diverse mobile sensor datasets to improve model generalization beyond the ExtraSensory dataset parameters.
V2X & Infrastructure Integration: Exploring integration with Vehicle-to-Everything (V2X) communication channels and smart traffic signals for dynamic, real-time vehicle speed and distance awareness.
Repository Structure
Plaintext



├── App/                      # Swift / SwiftUI iOS application source code
│   ├── UserDeviceModule/     # Motion permissions and background execution management
│   ├── LocationModule/       # Core Location, Apple Maps matching, & geofencing logic
│   ├── DistractionModule/    # Sensor integration & CoreML model execution
│   └── AlertModule/          # UserNotification triggers (visual, audible, haptic)
├── ML_Model/                 # Machine Learning pipeline source files
│   ├── data_processing.py    # ExtraSensory dataset filtering & feature extraction
│   ├── train_mlp.py          # PyTorch Multi-Layer Perceptron model & training loop
│   └── export_coreml.py      # Conversion script exporting PyTorch weights to .mlmodel
└── README.mdGetting Started
Prerequisites
macOS

 running Xcode 14 or later.
iOS Device running iOS 17 or later (a physical device is required for full motion sensor and Core Location background testing).
Running the App Locally
1. Clone this repository:
Bash



git clone 
https://github.com/your-org/PedAlert.git
cd PedAlert2. Open PedAlert.xcodeproj in Xcode.
3. Select your connected physical iOS device as the build target.
4. Ensure location and motion permissions are configured:
Under Signing & Capabilities, verify that Background Modes has Location updates checked.
Verify that NSLocationAlwaysAndWhenInUseUsageDescription and NSMotionUsageDescription are present in your Info.plist.
5. Build and run the project ($\text{Cmd} + \text{R}$).
License & Citation
This project is licensed under the GNU General Public License v3.0.
If you use PedAlert in your research, please cite our corresponding publications:
Code snippet



@inproceedings{subedi2024pedalert_v1,
  title={Software Infrastructure System to Reduce Pedestrian Distraction at Intersections},
  author={Subedi, Prakriti and Mohammed, Ahmed and Saleem, Abdul Nafay and Sharma, Sanjib},
  institution={Howard University},
  year={2024}
}

@inproceedings{subedi2025pedalert_v2,
  title={Geofencing and Machine Learning for Real-Time Detection of Distracted Pedestrians at Intersections},
  author={Subedi, Prakriti and Mohammed, Ahmed and Saleem, Abdul Nafay and Sharma, Sanjib},
  institution={Howard University},
  year={2025}
}
