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
    "diluent_mixer_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Mixer_Valve"), # Module 3 Valve from Diluent to Mixer
    "diluent_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Valve"), # Module 2 Diluent Valve
    "mixer_output_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Output_Valve"),
    "mixer_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Pump"),
    "mixer_tank_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Tank_Mixer"),
    "mixer_to_bottle": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_To_Bottle"),
    "stock_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer"), # Module 2 Valve for Stock (Mixer)
    "stock_mixer_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer_Valve"),
    "stock_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Valve"),
    "supply_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Supply_Pump"), # Module 1 Water Supply Pump/Valve
    "waste_valve1": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve1"), # Module 6 Waste Valve 1
    "waste_valve2": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve2"), # Module 6 Waste Valve 2
    
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

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    finally:
        opcua_client.disconnect()