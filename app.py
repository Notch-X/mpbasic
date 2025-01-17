from flask import Flask, jsonify, request
from opcua import Client

app = Flask(__name__)

# Create OPC UA client connection
opcua_client = Client("opc.tcp://192.168.250.11:4840")

try:
    opcua_client.connect()
    print("Successfully connected to OPC UA server")
except Exception as e:
    print(f"Failed to connect to OPC UA server: {e}")

# Define the Node IDs for each mode and valve
mode_nodes = {
    "auto": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_AUTO_PB"), # Main Process Page Auto Button
    "stop": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_STOP_PB"), # Main Process Page Stop Button
    "manual": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_MANUAL_PB"), # Main Process Page Manual Button
    # ==================================================================================================================================================
    # Manual Valves in PROGRESS
    "supply_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Supply_Pump"), # Module 1 Water Supply Pump/Valve
    "stock_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Valve"), #Module 2 Valve for Stock valve
    "diluent_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Valve"),  # Module 2 Valve for Diluent valve
    "stock_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer"), #Module 2 Valve for Stock (Mixer)
    "diluent_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Mixer_Valve"), #Module 3 Valve from Diluent to Mixer
    "stock_mixerur_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer_Valve"),  # Module 3 Valve from Stock to Mixer
    "mixer_tank": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Tank_Mixer"),  # Module 3 Valve from Mixer in Mixer Tank
    "mixer_output": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Output_Valve"), # Module 3 Mixer Tank Valve
    "mixer_bottle": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_To_Bottle"), # Module 4  Valve inbetween the Mixer and Bottles, V16 valve
    "mixer_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Pump"), # Module 4 Valve for Mixer Pump
    "bottle_valve1": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve1"),  # Module 4 : Bottle 1
    "bottle_valve2": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve2"),  # Module 4 : Bottle 2
    "bottle_valve3": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve3"),  # Module 4 : Bottle 3
    "bottle_valve4": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve4"),  # Module 4 : Bottle 4
    "bottle_valve5": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve5"),  # Module 4 : Bottle 5
    "bottle_valve6": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve6"),  # Module 4 : Bottle 6
    "bottle_valve7": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve7"),  # Module 4 : Bottle 7
    "bottle_valve8": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve8"),  # Module 4 : Bottle 8
    "bottle_valve9": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve9"),  # Module 4 : Bottle 9
    "bottle_valve10": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve10"),  # Module 4 : Bottle 10
    "v18_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve1"), # Module 5 Valve 18
    "v19_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve2"), # Module 5 Valve 19
    "bottle_tray": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Tray_Waste"),  # Module 6 Waste Bottle Tray
    # ==================================================================================================================================================
}

def set_mode_state(mode, state):
    """Helper function to set the mode state on OPC UA server"""
    try:
        node = mode_nodes.get(mode)
        if node:
            node.set_value(state)
            print(f"Set {mode} to {state}")
            return True
        return False
    except Exception as e:
        print(f"Error setting {mode}: {e}")
        return False

@app.route('/', methods=['POST'])
def control_mode():
    try:
        # Get the button states from the request
        data = request.json
        print(f"Received data: {data}")
        
        # Set the state for each mode based on the button presses
        success = True
        if data.get("button1"):
            success = all([
                set_mode_state("auto", True),
                set_mode_state("stop", False),
                set_mode_state("manual", False)
            ])
        elif data.get("button2"):
            success = all([
                set_mode_state("auto", False),
                set_mode_state("stop", True),
                set_mode_state("manual", False)
            ])
        elif data.get("button3"):
            success = all([
                set_mode_state("auto", False),
                set_mode_state("stop", False),
                set_mode_state("manual", True)
            ])
        
        if success:
            return jsonify({
                "status": "success",
                "message": "Mode updated successfully"
            })
        else:
            return jsonify({
                "status": "error",
                "message": "Failed to update mode"
            }), 500
            
    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Endpoint to check if the server is running"""
    return jsonify({"status": "healthy"})

# Dynamically create routes for each valve
valve_routes = [
    "supply_pump", "stock_valve", "diluent_valve", "stock_mixer", "diluent_mixer",
    "stock_mixerur_valve", "mixer_tank", "mixer_output", "mixer_bottle", "mixer_pump",
    "bottle_valve1", "bottle_valve2", "bottle_valve3", "bottle_valve4", "bottle_valve5",
    "bottle_valve6", "bottle_valve7", "bottle_valve8", "bottle_valve9", "bottle_valve10",
    "v18_valve", "v19_valve", "bottle_tray"
]

for route in valve_routes:
    @app.route(f'/{route}', methods=['POST'])
    def control_valve(route=route):
        try:
            data = request.get_json()
            control = data.get('control')
            state = data.get('state')

            # Process the control and state as needed
            print(f"Received control: {control}, state: {state}")

            # Example: Write to the OPC UA node
            node = mode_nodes.get(route)
            if node:
                node.set_value(state)
                print(f"Set {control} to {state}")

            # Respond with a success message
            return jsonify({'message': 'Control updated successfully'}), 200
        except Exception as e:
            print(f"Error: {e}")
            return jsonify({'message': 'Failed to update control'}), 500

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    finally:
        opcua_client.disconnect()