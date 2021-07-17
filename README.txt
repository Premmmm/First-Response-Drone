Important Files and Folders and their uses
------------------------------------------
Mobile App code - FRD Mobile App Code folder
Web App code - FRD Administrator Code folder
Powerpoint Presentation - FRD PPT file
Mobile App apk - FRD_Mobile_App.apk
Project Report - FRD Project Report (bonafide)
Simulation Video - FRD Simulation Video

Client Side
-----------
1) To run the FRD Mobile application, install and run FRD_Mobile_App.apk
2) The login screen will appear, login with your Google Account.
3) Grant Location permission if asked.
4) Three emergencies will be displayed Medical, Fire and Police, select any one emergency and the type of emergency from the drop down and hit OK.
5) You will now be navigated to the Map Screen.
6) The data from the drone which is streamed to the database is read continuously and showed in realtime in the client application.
7) Once the emergency is addressed the map screen will pop back to the emergency select screen.

Administrator Side
------------------
1) First pip install the libraries as instructed in the report.
2) Run d.py python file inside FRD Administrator Code folder.
3) Click on the localhost IP Address which appears in the terminal
4) All the emergencies reported will be visible in the website's first screen.
5) Hit "Take Case" button for any reported emergency to launch the drone simulation screen.
6) After selecting "Take Case" button, you'll be redirected to drone simulation screen
7) Hit Launch button to start the simulation for the autonomous drone.
8) The drone data will be stored in the database in realtime which will be streamed in the Client Side Mobile Application in real time.
9) Once the drone has reached the destination and landed and completed its job, hit "Return To Home", to command the drone to autonomously return to its base station.

Database Setup
--------------
1) Create a firebase database as instructed in the report
2) Enter the required Medical, Fire and Rescue and Police coordinates; drone node with FRD coordinates and details as shown in the images in FRD Mobile App Code/assets/GithbPictures folder.

Drone Power UP
--------------
1) Assemble the drone and make all the connections as per instructions in the report.
2) Connect both the batteries, one for the medibox and one to power up the Distribution Board and Flight Controller.
3) Turn on the Internet dongle.
4) Now the FRD is ready to fly.