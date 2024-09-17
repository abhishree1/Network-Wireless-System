#importing libraries
import paho.mqtt.client as mqttClient
import time
import math
import sys
import ast

#Connection and players information
Connected = False
file_path = sys.argv[1]
player_name = file_path[:8]
broker_address = "127.0.0.1"
port = 1883 
file = open(file_path, 'r')
total_players = int(file.readline())
all_players_ready = False
players = []
sync =0
player_loc_pow=[]


for i in range(1, total_players + 1):
    players.append("player-" + str(i))

players.remove(player_name)
remaining_player = players.copy()

#Function to calculate distance from the neighbors
def calculateDistance(neigh, player):
    return math.sqrt((neigh[1]-player[1])**2+(neigh[0]-player[0])**2)

#Function to establish connection with broker
def on_connect(client, userdata, flags, rc):
    
    if rc == 0:
        print("Connected to broker")
        global Connected
        Connected = True
        # print("Fine till here")
        time.sleep(2)
       

    else:
        print("Connection failed Return Code: ", rc)

#Function that will be performed after calling subscribe on any topic
def on_message(client, userdata, message):
    global players, all_players_ready,remaining_player,sync
    
    topic = str(message.topic).split("/")
    if message.payload:
        #Checks readiness of players
        if topic[0] == "ready":
            print(message.payload.decode("utf-8"))
            player_ready = message.payload.decode("utf-8")
            if player_ready in remaining_player:
                remaining_player.remove(player_ready)
            print(f"Player {player_ready} is ready.")
           

        #Calculate the distance between neighbors and player and decides who is the winner
        if topic[0] == "location":
            neigh_loc_po = message.payload.decode("utf-8")
            neigh_loc_pow = ast.literal_eval(neigh_loc_po)

            print("Location of "+ topic[1]+" ",neigh_loc_pow)
            # print("userdata",userdata)
            dist = calculateDistance(neigh_loc_pow,player_loc_pow)
            print("Distance from Neighbour "+ topic[1],dist)
            
            if int(dist) == 1 and neigh_loc_pow[2]==1 and player_loc_pow[2]==0:
                msg = player_name + "  was killed by " + topic[1]
                client.publish("disconnect/",msg)
                
                print("Disconnecting....")
                client.publish("ready/"+player_name,"", retain=True)
                time.sleep(0.2)
                client.disconnect()
                client.loop_stop()
            
            
        #Checks which player got disconnected
        if topic[0]  == "disconnect":
            player_disconnected = message.payload.decode("utf-8")
            print("-------------------------------------------")
            print(player_disconnected)
            print("-------------------------------------------")
            player_disconnected = player_disconnected.split(" ")
            if player_disconnected[0] in players:
                players.remove(player_disconnected[0])
            # print("players",players)
            if len(players)==0:
                print(f"You are the winner {player_name} !!!")
                client.publish("ready/"+player_name,"", retain=True)
                client.disconnect()
                client.loop_stop()

    else:
        print("")

#Establishing Connection with broker
client = mqttClient.Client(mqttClient.CallbackAPIVersion.VERSION1,player_name)
client.on_connect = on_connect
client.on_message = on_message

client.connect(broker_address, port=port)

#Loops starts
client.loop_start()  

# Waiting for connection establishment
while Connected != True:
    time.sleep(0.1)

# Publishing player's readiness
time.sleep(0.2)

print("Sending ready message")
time.sleep(1)
# client.publish("ready/"+player_name,player_name)
client.publish("ready/"+player_name,player_name, retain=True)
print("Ready!!")
time.sleep(0.2)

# Continuously listen for "ready" messages from other players
while remaining_player:
    # print("in here")
    for player in players:
        client.subscribe("ready/"+ player)
    time.sleep(0.2)


#Subscribe to all players' "location" topics
for player in players:
    client.subscribe("location/"+player)
            

print("Starting....")

# Below code will check if any player is disconnected, neighbors location and publish its location
while(True):
    # print("Inside loop")
    next_line = file.readline()
    client.subscribe("disconnect/")
    player_loc_pow = [int(x) for x in next_line.split()]
    if not player_loc_pow:
        break

    print("Players location",player_loc_pow)
    for player in players:
        # print(player)
        time.sleep(0.1)
        client.subscribe("location/"+player)

    # #Checking if players location is inside the grid
    if player_loc_pow[0]>500 or player_loc_pow[1]>500 or player_loc_pow[0]<0 or player_loc_pow[1]<0:
        msg = player_name + " was killed"
        client.publish("disconnect/",msg)   
        print("Disconnecting....")
        time.sleep(1)
        break
    
    client.publish("location/"+player_name, str(player_loc_pow),retain=False)

    # sync=sync+1
    time.sleep(1)
    
client.publish("ready/"+player_name,"", retain=True)
client.disconnect()
client.loop_stop()

