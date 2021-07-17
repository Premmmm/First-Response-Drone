import firebase_admin
from firebase_admin import credentials
from firebase_admin import db




cred = credentials.Certificate(r'C:\Users\91994\Desktop\flask\first-response-drone-5b1166ca3847.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://first-response-drone.firebaseio.com/'
})

dref = db.reference('Drone/')
dr=dref.get()

for i in dr:
    dref.child(i).update({
        'lat':dr[i]['hlat'] ,
        'lon':dr[i]['hlon'] ,
        'status':'offline',
        'speed':'0'
    })

dref1=db.reference('z/')

dref1.update({
    'alt'   :'0.00',
    'aspeed':'0.00',
})

dref2=db.reference('y/')

dref2.update({
    'alt'   :'0.00',
    'aspeed':'0.00',
})
