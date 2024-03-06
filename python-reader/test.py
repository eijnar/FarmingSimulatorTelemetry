import serial
import time
import ast

def read_and_parse_data(filename):
    with open(filename, "r", encoding='utf-8', errors='ignore') as file:
        current_line = file.readline().strip()
        if current_line:
            current_line = current_line.replace('=', ':').replace('true', 'True').replace('false', 'False')
            try:
                return ast.literal_eval(current_line)
            except ValueError:
                print("Error parsing the data. Skipping this line.")
    return {}

def process_engine_state(data, last_state):
    IsEngineStarted = data.get("IsEngineStarted", None)
    if IsEngineStarted is not None and IsEngineStarted != last_state:
        print(f"IsEngineStarted: {IsEngineStarted}")
        #command = '1' if IsEngineStarted else '0'
        #arduino.write(command.encode())
    return IsEngineStarted

def process_implement_lowered_state(data, last_front_state, last_back_state):
    front_implement_lowered = data.get("AttachedImplementsLowered", {}).get("-1", None)
    back_implement_lowered = data.get("AttachedImplementsLowered", {}).get("1", None)

    if front_implement_lowered is not None and front_implement_lowered != last_front_state:
        print(f"Front Implement Lowered: {front_implement_lowered}")
        command = '1' if front_implement_lowered else '0'  # Update these commands as per your Arduino code logic
        arduino.write(command.encode())

    if back_implement_lowered is not None and back_implement_lowered != last_back_state:
        print(f"Back Implement Lowered: {back_implement_lowered}")
        #command = '4' if back_implement_lowered else '5'  # Update these commands as per your Arduino code logic
        #arduino.write(command.encode())

    return front_implement_lowered, back_implement_lowered


arduino = serial.Serial('COM4', 9600, timeout=1)
time.sleep(2)

filename = r"C:\Program Files (x86)\Steam\steamapps\common\Farming Simulator 22\fstelemetry.sim"
last_IsEngineStarted = None
last_FrontImplementLowered = None
last_BackImplementLowered = None

try:
    while True:
        data = read_and_parse_data(filename)
        
        if data:
            last_IsEngineStarted = process_engine_state(data, last_IsEngineStarted)
            last_FrontImplementLowered, last_BackImplementLowered = process_implement_lowered_state(data, last_FrontImplementLowered, last_BackImplementLowered)

        time.sleep(0.2)

except KeyboardInterrupt:
    print("\nStopped monitoring.")
finally:
    arduino.close()
