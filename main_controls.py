from flask import Flask, jsonify, request
from opcua import Client

app = Flask(__name__)

# Create OPC UA client connection
opcua_client = Client("opc.tcp://192.168.250.11:4840")
opcua_client.connect()

# Define the Node IDs for each mode
mode_nodes = {
    "auto": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_AUTO_PB"),
    "stop": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_STOP_PB"),
    "manual": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_MANUAL_PB"),
}

# Helper function to set the mode state on OPC UA server
def set_mode_state(mode, state):
    node = mode_nodes.get(mode)
    if node:
        node.set_value(state)
        print(f"Set {mode} mode to {state}")

@app.route('/', methods=['POST'])
def control_mode():
    # Get the button states from the request
    data = request.json
    print(f"Received data: {data}")
    
    # Set the state for each mode based on the button presses
    if data.get("button1"):
        set_mode_state("auto", True)
        set_mode_state("stop", False)
        set_mode_state("manual", False)
    elif data.get("button2"):
        set_mode_state("auto", False)
        set_mode_state("stop", True)
        set_mode_state("manual", False)
    elif data.get("button3"):
        set_mode_state("auto", False)
        set_mode_state("stop", False)
        set_mode_state("manual", True)
    
    return jsonify({"status": "success", "message": "Mode updated successfully"})


if __name__ == '_main_':
    app.run(debug=True)