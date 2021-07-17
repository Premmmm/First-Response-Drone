import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
from flask import Flask,render_template,request,Response,jsonify
from dronekit import connect, VehicleMode, LocationGlobalRelative
from haversine import haversine, Unit
import time
import cv2
import math



app=Flask(__name__)                     

cred = credentials.Certificate(r'C:\Users\91994\Desktop\flask\first-response-drone-5b1166ca3847.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://first-response-drone.firebaseio.com/'
})

ref = db.reference('people/')
cord=ref.get()




@app.route("/")
def home():
    ref = db.reference('people/')
    cord=ref.get()
    return render_template('1.html',cord=cord,l=len(cord))

@app.route("/drone")
def drone():
    id=request.args.get("id")
    return render_template('2.html',cord=cord[id])

@app.route("/dgps",methods=['POST'])
def gps():
        id1=request.args.get("idgps")
        d=request.args.get("d")
        print(type(d))
        if d =='1':
            dref = db.reference('Drone/')
            dr=dref.get()
            ref= db.reference('')
            ref2 = db.reference('people/')
            cordi=ref2.get()
            x=cordi[id1]['lat']
            y=cordi[id1]['lon']
            lat1=math.radians(x)
            lon1=math.radians(y)
            res=[]
            map1=dict()
            R = 6373.0
            ans=0
            for i in dr:
                lat2 = math.radians(dr[i]['hlat'])
                lon2 = math.radians(dr[i]['hlon'])
                dlon = lon2 - lon1
                dlat = lat2 - lat1
                a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
                c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
                distance = R * c                
                map1[i]=distance
                if dr[i]['status'] == 'offline':
                    res.append(distance)
                else:
                    res.append(1000000000000000)
            x1=min(res)
            for j in map1:
                if map1[j]==x1:
                    ans=j
            ref2.child(id1).update({
                'status':ans
            })
            dref.child(ans).update({
                'status': 'Online',
            }) 

            connection_string = "udp:127.0.0.1:14551"
            print('Connecting to vehicle on: %s' % connection_string)
            global vehicle 
            vehicle = connect(connection_string, wait_ready=True)

            def arm_and_takeoff(aTargetAltitude):
                dref.child(ans).update({
                'status': 'Taking Off',
                })
                print("Basic pre-arm checks")
                while not vehicle.is_armable:
                    print(" Waiting for vehicle to initialise...")
                    time.sleep(1)
                print("Arming motors")
                vehicle.mode = VehicleMode("GUIDED")
                vehicle.armed = True
                while not vehicle.armed:
                    print(" Waiting for arming...")
                    time.sleep(1)
                print("Taking off!")
                vehicle.simple_takeoff(aTargetAltitude)  

                while True:
                    print(" Altitude: ", vehicle.location.global_relative_frame.alt)
                    ref.child('z').update({
                    'alt': vehicle.location.global_relative_frame.alt,                
                    })
                    if vehicle.location.global_relative_frame.alt >= aTargetAltitude * 0.95:
                        print("Reached target altitude")
                        break
                    time.sleep(1)            



            
            arm_and_takeoff(10)

            print("Set default/target airspeed to 3")
            vehicle.airspeed = 50

            dref.child(ans).update({
                'status': 'Arriving',
            })
            print("Going towards first point for 30 seconds ...")
            point1 = LocationGlobalRelative(x,y, 10)
            while (((haversine((vehicle.location.global_relative_frame.lat,vehicle.location.global_relative_frame.lon), (x,y)))*1000)>1):
                vehicle.simple_goto(point1)
                print(vehicle.location.global_relative_frame,vehicle.airspeed,vehicle.groundspeed,vehicle.battery)
                # print(get_dist(vehicle.location.global_relative_frame.lat,vehicle.location.global_relative_frame.lon,x,y))
                print((haversine((vehicle.location.global_relative_frame.lat,vehicle.location.global_relative_frame.lon), (x,y)))*1000)
                ref.child('Drone').child(ans).update({
                'lat': vehicle.location.global_relative_frame.lat,
                'lon': vehicle.location.global_relative_frame.lon,
                'speed':vehicle.airspeed
                })
                ref.child('z').update({
                'lat': vehicle.location.global_relative_frame.lat,
                'lon': vehicle.location.global_relative_frame.lon,
                'alt': vehicle.location.global_relative_frame.alt,
                'aspeed':vehicle.airspeed,
                'gspeed':vehicle.groundspeed,                
                })
                time.sleep(1)
            dref.child(ans).update({
                'status': 'Landing',
            })
            time.sleep(5)
            dref.child(ans).update({
                'status': 'Landed',
            })
            time.sleep(5)
            ref2.child(id1).update({
                'status':"Completed"
            })
            vehicle.close()
            return "True"


@app.route('/rtl',methods=['POST'])
def rtl():
    connection_string = "udp:127.0.0.1:14551"
    print('Connecting to vehicle on: %s' % connection_string)
    global vehicle 
    vehicle = connect(connection_string, wait_ready=True)
    print("Returning to Launch")
    vehicle.mode = VehicleMode("RTL")
    print("Close vehicle object")
    vehicle.close()
    return "True"

def gen():
    cap = cv2.VideoCapture(0)
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    while(cap.isOpened()):
        ret, img = cap.read()
        if ret == True:
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, 1.1, 4)
            for (x, y, w, h) in faces:
                cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
            img = cv2.resize(img, (0,0), fx=0.5, fy=0.5) 
            frame = cv2.imencode('.jpg', img)[1].tobytes()
            yield (b'--frame\r\n'b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            time.sleep(0.1)
        else: 
            break
        

@app.route('/video_feed')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


if __name__=='__main__':
    app.run(debug=True)



